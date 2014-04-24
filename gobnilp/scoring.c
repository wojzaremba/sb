/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*   GOBNILP Copyright (C) 2012 James Cussens            	         */
/*    		    	       						 */
/*   This program is free software; you can redistribute it and/or       */
/*   modify it under the terms of the GNU General Public License as	 */
/*   published by the Free Software Foundation; either version 3 of the	 */
/*   License, or (at your option) any later version.   	       	    	 */
/*   	      	     	  	      	    				 */
/*   This program is distributed in the hope that it will be useful,	 */
/*   but WITHOUT ANY WARRANTY; without even the implied warranty of	 */
/*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU	 */
/*   General Public License for more details.	  	       	   	 */
/*    	      	     	     	      					 */ 
/*   You should have received a copy of the GNU General Public License	 */
/*   along with this program; if not, see   	 	 		 */
/*   <http://www.gnu.org/licenses>.   					 */ 
/*    									 */
/*   Additional permission under GNU GPL version 3 section 7		 */
/*    		 	    	      	  	    	    		 */
/*   If you modify this Program, or any covered work, by linking or	 */
/*   combining it with SCIP (or a modified version of that library),	 */
/*   containing parts covered by the terms of the ZIB Academic License,  */
/*   the licensors of this Program grant you additional permission to	 */
/*   convey the resulting work.    	      		 	    	 */
/*   	    		  						 */ 
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
#include <stdio.h>
#include <stdlib.h>
#define NDEBUG
#include <assert.h>
#include <math.h>
#include <limits.h>
#include <string.h>

#define OFFSET 0
#define min(A,B) ((A) < (B) ? (A) : (B))
#define FALSE 0
#define TRUE 1
#define BLOCKSIZE 10000

typedef unsigned short int ROW;
typedef unsigned short int VARIABLE;
typedef unsigned short int ARITY;
typedef unsigned short int VALUE;
typedef unsigned short int COUNT;
typedef unsigned short int BOOLEAN;


struct subset_tree
{
   struct subset_tree **children;
};
typedef struct subset_tree SUBSET_TREE;

static int nvars;
static ARITY *arity;
static int nrows;
static VALUE **data;
static ROW **tmp_cells;
static COUNT *valcount;
static COUNT *valcount2;

static double alpha;
static int palim;
static SUBSET_TREE bottom;
static SUBSET_TREE *bottom_ptr = &bottom;


static BOOLEAN check_subset(
   SUBSET_TREE *tree,
   VARIABLE* vars,
   int num_vars,
   int offset
   )
{

   SUBSET_TREE *child;
   
   assert( tree != NULL);
   assert( vars != NULL);
   assert( tree->children != NULL);
   assert( num_vars > 0 );
   assert( offset >= 0 );
   assert( offset < nvars );

   child = (tree->children)[vars[0]-offset];
   
   if( child == NULL )
      /* missing entry, subset is not there */
      return FALSE;
   else if( num_vars == 1)
      /* entry for last remaining variable present */
      return TRUE;
   else if( child == bottom_ptr )
      /* num_vars > 1 but no further variables stored */
      return FALSE;

   /* all OK so for, but further variables to check */
   return check_subset(child,vars+1,num_vars-1,vars[0]+1);
}


static void delete_tree(
   SUBSET_TREE *tree,
   int length
   )
{
   SUBSET_TREE *child;
   int i;

   assert( tree != NULL);
   assert( tree->children != NULL);
   assert( length > 0 );
   assert( length <= nvars );

   for( i = 0; i < length; ++i )
   {
      child = tree->children[i];
      if( child != NULL && child != bottom_ptr )
	 delete_tree(child,length-i-1);
   }
   free(tree->children);
   free(tree);
}

/* add a subset to the tree (if not already there ) */
static void add_subset(
   SUBSET_TREE *tree,
   VARIABLE* vars,
   int num_vars,
   int offset
   )
{
   int i;
   int size;

   SUBSET_TREE **child_ptr;
   SUBSET_TREE *child;

   assert( tree != NULL);
   assert( vars != NULL);
   assert( tree->children != NULL);
   assert( num_vars > 0 );
   assert( offset >= 0 );
   assert( offset < nvars );
   
   child_ptr = &((tree->children)[vars[0]-offset]);
   child = *child_ptr;

   if( num_vars == 1 )
   {
      *child_ptr = bottom_ptr;
      return;
   }
   
   if(  child == NULL || child == bottom_ptr )
   {
      *child_ptr = (SUBSET_TREE *) malloc(sizeof(SUBSET_TREE));
      /* enough room for vars[0]+1, vars[0]+2, ... , nvars-1 */
      size = nvars-vars[0]-1;
      /* always allocate room for children when a new node created */
      (*child_ptr)->children = (SUBSET_TREE **) malloc(size*sizeof(SUBSET_TREE *));
      for( i = 0; i < size; ++i )
	 (*child_ptr)->children[i] = NULL;
   }
   add_subset((*child_ptr),vars+1,num_vars-1,vars[0]+1);
}

struct contab
{
   int ncells;
   ROW *rows;
   COUNT *cell_sizes;
};
typedef struct contab CONTAB;

struct scored_parentset
{
   double score;
   int nvars;
   VARIABLE *vars;
};
typedef struct scored_parentset SCORED_PARENTSET;


/* extend an existing contab and score
   without creating a new contab
*/
static double extend_score(
   const CONTAB *incontab,
   VARIABLE var,  /* new parent */
   VARIABLE child,
   const int npa,      /* number of parents including new one */
   VARIABLE *parents  /* parents including new one */
   )
{
   const int incontab_ncells = incontab->ncells;
   const ROW *incontab_rows = incontab->rows;
   const COUNT *incontab_cellsizes = incontab->cell_sizes;

   VALUE val;
   const ROW *vardata = data[var];
   const ARITY arityvar = arity[var];
   ROW row;

   COUNT cell_size;
   int cell;
   int breakpoint = 0;

   int i,j;

   int q = 1;

   double aq, aqr;
   double skore = 0.0;

   const ARITY aritychild = arity[child];
   const VALUE *childdata = data[child];

   double lgamma_aq, lgamma_aqr;

   VALUE child_val;


   for ( i = 0; i < npa; ++i)
      q = q * arity[parents[i]];
   aq = alpha/q;
   aqr = aq/aritychild;
   lgamma_aq = lgamma(aq);
   lgamma_aqr = lgamma(aqr);

   for ( val = 0; val < arityvar; ++val )
      valcount[val] = 0;

   i = 0;
   for ( cell = 0; cell < incontab_ncells; ++cell )
   {
      cell_size = incontab_cellsizes[cell];
      breakpoint = breakpoint + cell_size;

      while ( i < breakpoint )
      {
	 row = incontab_rows[i++];
	 val = vardata[row];
	 tmp_cells[val][valcount[val]++] = row;       
      }

      /* now tmp_cells has data for new, bigger parent set */
      for ( val = 0; val < arityvar; ++val )
	 if ( valcount[val] > 0 )
	 {
	    skore = skore + lgamma_aq - lgamma(aq + valcount[val]);
	    
	    for ( child_val = 0; child_val < aritychild; ++child_val)
	       valcount2[child_val] = 0;
	    
	    for ( j = 0; j < valcount[val]; ++j )
	    {
	       row = tmp_cells[val][j];
	       child_val = childdata[row];
	       valcount2[child_val]++;
	    }

	    for ( child_val = 0; child_val < aritychild; ++child_val)
	       skore = skore + lgamma(aqr + valcount2[child_val]) - lgamma_aqr;
	    
	    valcount[val] = 0;
	 }
   }
   return skore;
}   

static void extend_contab(
   const CONTAB *incontab,
   VARIABLE var,
   CONTAB *outcontab
   )
{
   int i,j,k, k_end;
   int k_init, k_end_init;
   VALUE val;
   const ROW *vardata = data[var];
   const ARITY arityvar = arity[var];
   ROW row;
   int cell;
   int breakpoint = 0;

   const int incontab_ncells = incontab->ncells;
   const ROW *incontab_rows = incontab->rows;
   const COUNT *incontab_cellsizes = incontab->cell_sizes;

   int outcontab_ncells = 0; 
   ROW *outcontab_rows;
   COUNT *outcontab_cellsizes;

   COUNT cell_size;

   i = 0;
   k = 0;

   outcontab_rows = (ROW *) malloc(nrows*sizeof(ROW));
   assert(outcontab_rows != NULL);
   outcontab_cellsizes = (COUNT *) malloc(arityvar*incontab_ncells*sizeof(COUNT));
   assert(outcontab_cellsizes != NULL);

   for ( val = 0; val < arityvar; ++val )
      valcount[val] = 0;

   for ( cell = 0; cell < incontab_ncells; ++cell )
   {
      cell_size = incontab_cellsizes[cell];
      breakpoint = breakpoint + cell_size;

      if ( cell_size == 1)
      {
	 outcontab_rows[k++] = incontab_rows[i++];
	 outcontab_cellsizes[outcontab_ncells++] = 1;
	 continue;
      }


      while ( i < breakpoint )
      {
	 row = incontab_rows[i++];
	 val = vardata[row];
	 tmp_cells[val][valcount[val]++] = row;       
      }
      
      for ( val = 0; val < arityvar; ++val )
	 if ( valcount[val] > 0 )
	 {
	    for ( j = 0; j < valcount[val]; ++j )
	       outcontab_rows[k++] = tmp_cells[val][j];
	    outcontab_cellsizes[outcontab_ncells++] = valcount[val];
	    /*printf("%d ",valcount[val]);*/
	    valcount[val] = 0;
	 }
   }
   /*printf("\n");*/
   
   assert( i == nrows );

   outcontab->ncells = outcontab_ncells;
   outcontab->rows = outcontab_rows;
   outcontab->cell_sizes = (COUNT *) realloc(outcontab_cellsizes,outcontab_ncells*sizeof(COUNT));

}

   

static double score(
   VARIABLE child,
   const int npa,
   VARIABLE *parents,
   CONTAB *contab
   )
{
   int q = 1;
   int i;

   double aq, aqr;
   double skore;
   double lgamma_aqr;

   int cell;
   int breakpoint = 0;
   const ARITY aritychild = arity[child];
   const VALUE *childdata = data[child];
   
   ROW row;
   VALUE child_val;
   int nij;

   for ( i = 0; i < npa; ++i)
      q = q * arity[parents[i]];
   aq = alpha/q;
   aqr = aq/aritychild;
   lgamma_aqr = lgamma(aqr);

   /* score is:
      sum_nij [ lgamma(aq) - lgamma(aq+niij) + sum_k [ lgamma(aqr+nijk) - lgamma(aqr) ] ]
      so have a lgamma(aq) for each cell in parent contingency table,
      hence next line of code:
   */
   
   skore = lgamma(aq)*contab->ncells;
   
   i = 0;
   for ( cell = 0; cell < contab->ncells; ++cell )
   {

      nij = contab->cell_sizes[cell];
      skore = skore - lgamma(aq + nij);

      for ( child_val = 0; child_val < aritychild; ++child_val)
	 valcount[child_val] = 0;
      breakpoint = breakpoint + nij;
      while ( i < breakpoint )
      {
	 row = contab->rows[i++];
	 child_val = childdata[row];
	 valcount[child_val]++;
      }
      for ( child_val = 0; child_val < aritychild; ++child_val)
	 skore = skore + lgamma(aqr + valcount[child_val]) - lgamma_aqr;
   }

   assert( i == nrows);

   return skore;
}

static void free_contab(
   CONTAB *contab_ptr
   )
{
   free(contab_ptr->rows);
   free(contab_ptr->cell_sizes);
   free(contab_ptr);
}

static int sps_sort(
   const void *p1,
   const void *p2
   )
{
   const SCORED_PARENTSET **sps1 = (const SCORED_PARENTSET **) p1; 
   const SCORED_PARENTSET **sps2 = (const SCORED_PARENTSET **) p2;
   if (((*sps1)->score) > ((*sps2)->score))
      return -1;
   else 
      return 1;
}


static void skip_comment(
   FILE *file
   )
{
   int testchar;
   
   testchar=fgetc(file);
   if ( testchar == '#')
   {
      fscanf(file, "%*[^\n]%*c");
      skip_comment(file);
   }
   else
      ungetc(testchar,file);
}

int main(
   int    argc,
   char** argv
   )
{

   int i,j,k,kk,tmp_k;
   FILE *file;
   int status;
   ROW row;
   VARIABLE var;

   VALUE val;
   ARITY biggest_arity = 0;

   CONTAB initial;

   int npa;
   int old_layer_size, new_layer_size, new_layer_max_size;
   CONTAB **old_layer_pa;
   CONTAB **new_layer_pa;
   VARIABLE **old_layer_vars, **new_layer_vars;
   int old_layer_index;
   int lower_bound;

   CONTAB *old_contab_pa_ptr;
   VARIABLE *old_vars_ptr;

   CONTAB *new_contab_pa_ptr;
   VARIABLE *new_vars_ptr;

   CONTAB *all_parents_old, *all_parents_new;
   VARIABLE parent;

   VARIABLE new_parent;
   VARIABLE child;
   double skore;

   BOOLEAN* a_parent;
   int n_kept, n_new_kept;
   SCORED_PARENTSET *sps_ptr;
   SCORED_PARENTSET **kept, **new_kept, **tmp_kept;
   BOOLEAN keep, subset, prune, pruning;

   double logaritychild;
   double aq, aqr;
   double penalty, bound;

   int new_layer_allocated;
   int new_kept_allocated;

   BOOLEAN last_layer;
   SUBSET_TREE *subsets;
   VARIABLE* subset_ptr;

   int testchar;

   if ( argc != 4 && argc != 5 )
   {
      printf("Usage: scoring datafile alpha palim [noprune]\n");
      return 1;
   }

   if ( strcmp(argv[1],"-") == 0 )
      file = stdin;
   else
      file = fopen(argv[1], "r");
   alpha = atof(argv[2]);
   palim = atoi(argv[3]);
   if (argc == 5)
      pruning = FALSE;
   else
      pruning = TRUE;
	 

   if ( file == NULL )
   {
      printf("Could not open file %s.\n", argv[1]);
      return 1;
   }

   /* read number of variables */

   skip_comment(file);
   status = fscanf(file, "%d", &nvars);
   if ( ! status )
   {
      printf("Could not read number of variables \n");
      return 1;
   }
   testchar=fgetc(file);
   if ( testchar != '\n')
   {
      printf("Number of variables was followed by '%c', not a new line\n", testchar);
      return 1;
   }
      


   /* read in variable arities */
   arity = (ARITY *) malloc(nvars*sizeof(ARITY));
   skip_comment(file);
   for ( var = 0; var < nvars; ++var)
   {
      status = fscanf(file, "%hu", &(arity[var]));
      if ( ! status )
      {
	 printf("Could not read arity of variable %u\n", var);
	 return 1;
      }
      if ( arity[var] > biggest_arity )
	 biggest_arity = arity[var];
   }
   testchar=fgetc(file);
   if ( testchar != '\n')
   {
      printf("Variable arities were followed by '%c', not a new line\n", testchar);
      return 1;
   }


   
   /* read number of rows  */
   skip_comment(file);
   status = fscanf(file, "%d", &nrows);
   if ( ! status )
   {
      printf("Could not read number of data rows \n");
      return 1;
   }
   testchar=fgetc(file);
   if ( testchar != '\n')
   {
      printf("Number of data rows was followed by '%c', not a new line\n", testchar);
      return 1;
   }
   
   if ( nrows > USHRT_MAX ) 
      fprintf(stderr,"Warning: Too many rows to store them as unsigned short ints. \n");
   
   data = (VALUE **) malloc(nvars*sizeof(VALUE *));
   for ( var = 0; var < nvars; ++var)
      data[var] = (VALUE *) malloc(nrows*sizeof(VALUE));

   /* read in data */
   for ( row = 0; row < nrows; ++row)
   {
      skip_comment(file);
      for ( var = 0; var < nvars; ++var)
      {
	 status = fscanf(file, "%hu", &val);
	 if ( status == EOF )
	 {
	    printf("Found fewer rows than %d.\n", nrows);
	    return 1;
	 }
	 if ( ! status )
	 {
	    printf("Could not read value of variable %d on row %d\n", var, row);
	    return 1;
	 }
	 if ( val - OFFSET < 0 || val - OFFSET >= arity[var] )
	 {
	    printf("Invalid value %d for variable %d on row %d (should be non-negative and less than %d) \n", data[var][row], var, row, arity[var]);
	    return 1;
	 }
	 data[var][row] = val - OFFSET;
      }
      
      testchar=fgetc(file);
      if ( testchar != '\n')
      {
	 printf("Values on row %d (line %d+4) were followed by '%c', not a new line\n", row, row, testchar);
	 return 1;
      }
   }

   fclose(file);

   /* set up temporary working areas */
   tmp_cells = (ROW **) malloc(biggest_arity*sizeof(ROW*));
   for ( i = 0; i < biggest_arity; ++i )
      tmp_cells[i] = (ROW *) malloc(nrows*sizeof(ROW));
   valcount = (COUNT *) malloc(biggest_arity*sizeof(COUNT));
   valcount2 = (COUNT *) malloc(biggest_arity*sizeof(COUNT));
   a_parent = (BOOLEAN *) malloc(nvars*sizeof(BOOLEAN));
   subset_ptr = (VARIABLE *) malloc((nvars-1)*sizeof(VARIABLE));



   /* construct contingency table for no variables */
   /* there is only one cell containing all datapoints */
   initial.ncells = 1;
   initial.rows = (ROW *) malloc(nrows*sizeof(ROW));
   initial.cell_sizes = (COUNT *) malloc(sizeof(COUNT));
   for (i = 0; i < nrows; ++i)
      initial.rows[i] = i;
   initial.cell_sizes[0] = nrows;


   /* compute local scores, one child at a time */
   printf("%d\n",nvars);
   for ( child = 0; child < nvars; ++child ) 
   {
      
      double logaritychild = log(arity[child]);

      /* initialise subset store */
      subsets = (SUBSET_TREE *) malloc(sizeof(SUBSET_TREE));
      subsets->children = (SUBSET_TREE **) malloc(nvars*sizeof(SUBSET_TREE *)); 
      for( i = 0; i < nvars; ++i )
	 (subsets->children)[i] = NULL;


      /* no previous 'old layer' for this child so initialise it directly 
	 to contain just the empty parent set */

      old_layer_pa = (CONTAB **) malloc(sizeof(CONTAB *));
      old_layer_vars = (VARIABLE **) malloc(sizeof(VARIABLE *));
      old_layer_pa[0] = &initial;
      old_layer_vars[0] = NULL;
      old_layer_size = 1;

      /* score the empty parent set for this child */

      skore = score(child,0,old_vars_ptr,old_layer_pa[0]);

      /* this parent set and its score always kept */

      sps_ptr = (SCORED_PARENTSET *) malloc(sizeof(SCORED_PARENTSET));
      sps_ptr->score = skore;
      sps_ptr->nvars = 0;
      sps_ptr->vars = NULL;
      kept = (SCORED_PARENTSET **) malloc(sizeof(SCORED_PARENTSET *));
      kept[0] = sps_ptr;
      n_kept = 1;
      last_layer = FALSE;

      /* now compute local scores for increasing numbers of parents */

      for ( npa = 1; npa <= min(palim,nvars-1); ++npa )
      {
	 
	 if ( npa == min(palim,nvars-1) )
	      last_layer = TRUE;

	 /* create initial space for new layer */

	 new_layer_allocated = BLOCKSIZE;
	 new_kept_allocated = BLOCKSIZE;
	 new_layer_pa = (CONTAB **) malloc(new_layer_allocated*sizeof(CONTAB *));
	 new_layer_vars = (VARIABLE **) malloc(new_layer_allocated*sizeof(VARIABLE *));
	 new_kept = (SCORED_PARENTSET **) malloc(new_kept_allocated*sizeof(SCORED_PARENTSET *));

	 n_new_kept = 0;
	 new_layer_size = 0;
	 

	 for ( old_layer_index = 0; old_layer_index < old_layer_size; ++old_layer_index )
	 {
	    
	    /* grab an 'old' parent set to extend */
	    
	    old_contab_pa_ptr = old_layer_pa[old_layer_index];
	    old_vars_ptr = old_layer_vars[old_layer_index];
	       
	    if ( old_vars_ptr == NULL )
	       lower_bound = -1;
	    else
	       lower_bound = old_vars_ptr[npa-2];

	    /* extend old parent set to create new parent sets
	       by adding new parents strictly greater
	       than any in the old parent set 
	    */
	    
	    for ( new_parent = lower_bound+1; new_parent < nvars; ++new_parent )
	    { 
	       if ( new_parent == child )
		  continue;
	       
	       /* create new parent set */

	       new_vars_ptr = (VARIABLE *) malloc(npa*sizeof(VARIABLE));
	       for ( k = 0; k < npa-1; ++k )
		  new_vars_ptr[k] = old_vars_ptr[k];
	       new_vars_ptr[k] = new_parent;

	       /* check that all subsets of new_vars
		  are in the subset store
	       */


	       prune = FALSE;
	       if( pruning && npa > 1)
	       {
	       	  subset_ptr[npa-2] = new_parent;
	       	  for ( kk = 0; kk < npa-1; ++kk )
	       	  {
	       	     tmp_k = 0;
	       	     for ( k = 0; k < npa-1; ++k )
	       		if( k != kk )
	       		   subset_ptr[tmp_k++] = old_vars_ptr[k];
		     
	       	     if( !check_subset(subsets,subset_ptr,npa-1,0) )
	       	     {
	       		/* a subset has been 'exponentially' pruned */
			
	       		/* printf("This subset pruned: "); */
	       		/* for ( k = 0; k < npa; ++k ) */
	       		/*    printf(" %d",new_vars_ptr[k]); */
	       		/* printf("\nBecause this subset missing: "); */
	       		/* for ( tmp_k = 0; tmp_k < npa-1; ++tmp_k ) */
	       		/*    printf(" %d",new_vars_ptr[tmp_k]); */
	       		/* printf("\n"); */
	       		prune = TRUE;
	       		break;
	       	     }
	       	  }
	       }


	       if( prune )
	       {
	       	  free(new_vars_ptr);
	       	  continue;
	       }

		     
	       /* score new parent set */
		  
	       if ( last_layer )
		  skore = extend_score(old_contab_pa_ptr,new_parent,child,npa,new_vars_ptr);
	       else
	       {
		  new_contab_pa_ptr = (CONTAB *) malloc(sizeof(CONTAB));
		  extend_contab(old_contab_pa_ptr,new_parent,new_contab_pa_ptr);
		  skore = score(child,npa,new_vars_ptr,new_contab_pa_ptr);
	       }
	       /* set up bit set representation of new parent set
		  for fast subset checking */

	       keep = TRUE;
	       if ( pruning )
	       {
		  for ( k = 0; k < nvars; ++k )
		     a_parent[k] = 0;
		  for ( k = 0; k < npa; ++k )
		     a_parent[new_vars_ptr[k]] = 1;

		  /* decide whether to keep/prune this scored parentset */
		  
		  for ( i = 0; i < n_kept; ++i)
		  {
		     sps_ptr = kept[i];
		     if ( skore > sps_ptr->score )
			/* will also have better score than the rest
			   since scores are ordered best first */
			break;
		     subset = TRUE;
		     for ( k = 0; k < sps_ptr->nvars; ++k)
			if (! a_parent[sps_ptr->vars[k]] )
			{
			   subset = FALSE;
			   break;
			}
		     if ( subset )
		     {
			/* found a subset with a better score */
			keep = FALSE;
			/* de Campos and Ji style (without checking for small alpha ) */
			if ( (!last_layer) && (sps_ptr->score > -logaritychild * new_contab_pa_ptr->ncells) ) 
			   prune = TRUE; 
			
			break;
		     }
		  }
	       }

	       if ( keep )
	       {
		  sps_ptr = (SCORED_PARENTSET *) malloc(sizeof(SCORED_PARENTSET));
		  sps_ptr->score = skore;
		  sps_ptr->nvars = npa;
		  sps_ptr->vars = (VARIABLE *) malloc(npa*sizeof(VARIABLE));
		  for ( k = 0; k < npa; ++k )
		     sps_ptr->vars[k] = new_vars_ptr[k];
		  if ( n_new_kept >= new_kept_allocated )
		  {
		     new_kept_allocated = new_kept_allocated + BLOCKSIZE;
		     new_kept = (SCORED_PARENTSET **) realloc(new_kept,new_kept_allocated*sizeof(SCORED_PARENTSET *));
		  }
		  new_kept[n_new_kept++] = sps_ptr;
	       }
		  
	       /* store contabs, unless parent set is 'exponentially' pruned 
		  or this is the last layer
	       */
	       if ( prune )
	       {
		  free_contab(new_contab_pa_ptr);
		  free(new_vars_ptr);
	       }
	       else if ( last_layer )
	       {
		  free(new_vars_ptr);
	       }
	       else
	       {
		  /*printf("%d %d\n",new_layer_max_size,new_layer_size);*/
		  if ( new_layer_size >= new_layer_allocated )
		  {
		     new_layer_allocated = new_layer_allocated + BLOCKSIZE;
		     new_layer_pa = (CONTAB **) realloc(new_layer_pa,new_layer_allocated*sizeof(CONTAB *));
		     new_layer_vars = (VARIABLE **) realloc(new_layer_vars,new_layer_allocated*sizeof(VARIABLE *));
		  }
		  new_layer_pa[new_layer_size] = new_contab_pa_ptr;
		  new_layer_vars[new_layer_size] = new_vars_ptr;
		  new_layer_size++;
		  
		  if ( pruning )
		     add_subset(subsets,new_vars_ptr,npa,0);
	       }
	    }

	    /* discard old contabs immediately */
	    if ( old_contab_pa_ptr != &initial )
	       free_contab(old_contab_pa_ptr);
	    free(old_vars_ptr);
	 }

	 /* kill off old layer */
	 
	 free(old_layer_pa);
	 free(old_layer_vars);

	 /* here sort new_kept and then merge into kept */
	 
	 qsort(new_kept,n_new_kept,sizeof(SCORED_PARENTSET *),sps_sort);

	 tmp_kept = (SCORED_PARENTSET **) malloc((n_kept+n_new_kept)*sizeof(SCORED_PARENTSET *));
	 kk = 0;
	 tmp_k = 0;
	 for ( k = 0; k < n_kept; ++k)
	 {
	    while ( kk < n_new_kept && (new_kept[kk])->score > (kept[k])->score )
	       tmp_kept[tmp_k++] = new_kept[kk++];
	    tmp_kept[tmp_k++] = kept[k];
	 }
	 while ( kk < n_new_kept )
	    tmp_kept[tmp_k++] = new_kept[kk++];
	 
	 /* everything that needs to be kept, now in tmp_kept */
	 free(kept);
	 free(new_kept);
	 kept = tmp_kept;
	 n_kept = n_kept + n_new_kept;

	 old_layer_pa = (CONTAB **) realloc(new_layer_pa,new_layer_size*sizeof(CONTAB *));
	 old_layer_vars = (VARIABLE **) realloc(new_layer_vars,new_layer_size*sizeof(VARIABLE *));
	 old_layer_size = new_layer_size;
      }
      
      /* finished scoring parent sets for this child, 
	 but need a final clear up for this child */
      
      for ( old_layer_index = 0; old_layer_index < old_layer_size; ++old_layer_index )
      {
	 free_contab(old_layer_pa[old_layer_index]);
	 free(old_layer_vars[old_layer_index]);
      }
      free(old_layer_pa);
      free(old_layer_vars);
      
      delete_tree(subsets,nvars);
      
      /* print out parent sets for this child */
      printf("%d %d\n", child, n_kept);
      for ( k = 0; k < n_kept; ++k)
      {
	 sps_ptr = kept[k];
	 printf("%f %d",sps_ptr->score,sps_ptr->nvars);
	 for ( kk = 0; kk < sps_ptr->nvars; ++kk)
	    printf(" %d", sps_ptr->vars[kk]);
	 printf("\n");
	 free(sps_ptr->vars);
	 free(sps_ptr);
      }
      free(kept);
   }
   
   /* tidy up */

   free(initial.rows);
   free(initial.cell_sizes);
   for ( i = 0; i < biggest_arity; ++i )
      free(tmp_cells[i]);
   free(tmp_cells);
   free(valcount);
   free(valcount2);
   free(a_parent);
   free(arity);
   free(subset_ptr);
   for ( var = 0; var < nvars; ++var)
      free(data[var]);
   free(data);
}
