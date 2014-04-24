/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *   GOBNILP Copyright (C) 2012 James Cussens, Mark Bartlett             *
 *                                                                       *
 *   This program is free software; you can redistribute it and/or       *
 *   modify it under the terms of the GNU General Public License as      *
 *   published by the Free Software Foundation; either version 3 of the  *
 *   License, or (at your option) any later version.                     *
 *                                                                       *
 *   This program is distributed in the hope that it will be useful,     *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of      *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU    *
 *   General Public License for more details.                            *
 *                                                                       *
 *   You should have received a copy of the GNU General Public License   *
 *   along with this program; if not, see                                *
 *   <http://www.gnu.org/licenses>.                                      *
 *                                                                       *
 *   Additional permission under GNU GPL version 3 section 7             *
 *                                                                       *
 *   If you modify this Program, or any covered work, by linking or      *
 *   combining it with SCIP (or a modified version of that library),     *
 *   containing parts covered by the terms of the ZIB Academic License,  *
 *   the licensors of this Program grant you additional permission to    *
 *   convey the resulting work.                                          *
 *                                                                       *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/** @file
 *  Provides the core functionality for the Bayesian network learning problem.
 */

/*
This file was created by editing the file probdata_lop.c that comes with the linear ordering example
in SCIP
*/

#include <string.h>
#include "probdata_bn.h"
#include "pedigrees.h"
#include "cons_dagcluster.h"
#include "heur_sinks.h"
#include "utils.h"
#include "output.h"
#include "data_structures.h"

/** There is no method for transforming the problem. */
#define probtransBN NULL
/** There is no method for deleting a transformation of the problem. */
#define probdeltransBN NULL
/** There is no method for initialising a solution to the problem. */
#define probinitsolBN NULL
/** There is no method for exiting from the solution to the problem. */
#define probexitsolBN NULL
/** There is no method for copying the problem. */
#define probcopyBN NULL

/** Deletes any memory being used by the problem after solving is complete.
 *
 *  @return SCIP_OKAY if all memory could be deallocated or an error code otherwise.
 */
static
SCIP_DECL_PROBDELORIG(probdelorigBN)
{
   int i, k;

   assert( probdata != NULL );
   assert( *probdata != NULL );

   assert( (*probdata)->Scores != NULL );
   assert( (*probdata)->PaVars != NULL );
   assert( (*probdata)->nParents != NULL );
   assert( (*probdata)->ParentSets != NULL );
   assert( (*probdata)->nParentSets != NULL );

   for (i = 0; i < (*probdata)->n; ++i)
   {
      for (k = 0; k < (*probdata)->nParentSets[i]; ++k)
      {
       SCIP_CALL( SCIPreleaseVar(scip, &(*probdata)->PaVars[i][k]) );
       SCIPfreeMemoryArray(scip, &((*probdata)->ParentSets[i][k]));
      }
      SCIPfreeMemoryArray(scip, &(*probdata)->PaVars[i]);
      SCIPfreeMemoryArray(scip, &((*probdata)->Scores[i]));
      SCIPfreeMemoryArray(scip, &(*probdata)->nParents[i]);
      SCIPfreeMemoryArray(scip, &(*probdata)->ParentSets[i]);
      SCIPfreeMemoryArray(scip, &(*probdata)->nodeNames[i]);
   }
   SCIPfreeMemoryArray(scip, &(*probdata)->PaVars);
   SCIPfreeMemoryArray(scip, &((*probdata)->Scores));
   SCIPfreeMemoryArray(scip, &((*probdata)->nParents));
   SCIPfreeMemoryArray(scip, &((*probdata)->nParentSets));
   SCIPfreeMemoryArray(scip, &((*probdata)->ParentSets));
   SCIPfreeMemoryArray(scip, &((*probdata)->nodeNames));

   // Free pedigree specific data if necessary
   if (PD_inPedigreeMode(scip)) {
      SCIP_CALL( PD_freePedigreeData(scip) );
      SCIPfreeMemory(scip, &((*probdata)->ped));
   }

   SCIPfreeMemory(scip, probdata);

   return SCIP_OKAY;
}

// Data and functions related to initialising the problem before data is read in.
/** The default file from which to attempt to read parameters. */
#define DEFAULT_GOBNILP_PARAMS_FILE "gobnilp.set"
/** The name of the file from which the parameters are to be read. */
const char* parameterfile = DEFAULT_GOBNILP_PARAMS_FILE;
/** Includes all plugins needed by the problem.
 *
 *  @param scip The SCIP instance to add the plugins to.
 *  @return SCIP_OKAY if all plugins were added successfully, or an error otherwise.
 */
SCIP_RETCODE BN_includePlugins(SCIP* scip) {
   SCIP_CALL( SCIPincludeDefaultPlugins(scip) );
   SCIP_CALL( DC_includeConshdlr(scip) );
   SCIP_CALL( HS_includePrimal(scip) );
   return SCIP_OKAY;
}
/** Reads the command line arguments.
 *
 *  @param scip The SCIP instance to apply the arguments to.
 *  @param argc The number of command line arguments.
 *  @param argv The command line arguments.
 *  @return SCIP_OKAY if reading succeeded or an error otherwise.
 */
SCIP_RETCODE BN_readCommandLineArgs(SCIP* scip, int argc, char** argv) {
   int i;
   for ( i = 1; i < argc-1; i++ )
      if ( argv[i][0] != '-' ) {
         printf( "Each optional argument must be preceded by '-'.\n" );
         return 1;
      } else {
         switch ( argv[i][1] ) {
            case 'g':
               parameterfile = argv[i]+2;
               break;
            default:
               printf( "Unrecognised optional argument. Can only be g.\n" );
               return 1;
         }
      }
   return SCIP_OKAY;
}
/** Adds GOBNILP specific parameters to those recognised by SCIP.
 *
 *  @param scip The SCIP instance to add to the parameters to.
 *  @return SCIP_OKAY if the operation succeeded or an appropriate error coede otherwise.
 */
SCIP_RETCODE BN_addParameters(SCIP* scip) {
   SCIP_CALL(UT_addBoolParam(scip,
      "gobnilp/noimmoralities",
      "whether to disallow immoralities",
      FALSE
   ));

   SCIP_CALL(UT_addBoolParam(scip,
      "gobnilp/orderedcoveredarcs",
      "whether to only allow a covered arc i<-j if i<j",
      FALSE
   ));

   SCIP_CALL(UT_addBoolParam(scip,
      "gobnilp/implicitfounders",
      "whether to represent empty parent sets implicitly",
      FALSE
   ));

   SCIP_CALL(UT_addBoolParam(scip,
      "gobnilp/printscipsol",
      "whether to (additionally) print BNs in SCIP solution format",
      FALSE
   ));

   SCIP_CALL(UT_addIntParam(scip,
      "gobnilp/nbns",
      "gobnilp to find the 'nbns' best BNs ( in decreasing order of score )",
      1
   ));

   SCIP_CALL(UT_addIntParam(scip,
      "gobnilp/minfounders",
      "minimum number of founders",
      0
   ));

   SCIP_CALL(UT_addIntParam(scip,
      "gobnilp/maxfounders",
      "maximum number of founders (-1 for no upper bound )",
      -1
   ));

   SCIP_CALL(UT_addIntParam(scip,
      "gobnilp/minedges",
      "minimum number of edges",
      0
   ));

   SCIP_CALL(UT_addIntParam(scip,
      "gobnilp/maxedges",
      "maximum number of edges (-1 for no upper bound )",
      -1
   ));

   SCIP_CALL(UT_addBoolParam(scip,
      "gobnilp/printparameters",
      "whether to print parameters not at default values",
      TRUE
   ));

   SCIP_CALL(UT_addBoolParam(scip,
      "gobnilp/printmecinfo",
      "whether to print edges in the undirected skeleton and any immoralities",
      FALSE
   ));

   SCIP_CALL(UT_addStringParam(scip,
      "gobnilp/dagconstraintsfile",
      "file containing constraints on dag structure",
      ""
   ));

   SCIP_CALL(UT_addStringParam(scip,
      "gobnilp/statisticsfile",
      "file for statistics",
      ""
   ));

   SCIP_CALL(UT_addBoolParam(scip,
      "gobnilp/printstatistics",
      "whether to print solving statistics",
      FALSE
   ));

   SCIP_CALL(UT_addBoolParam(scip,
      "gobnilp/printbranchingstatistics",
      "whether to print variable branching statistics",
      FALSE
   ));

   SCIP_CALL( IO_addOutputParameters(scip) );
   SCIP_CALL( PD_addPedigreeParameters(scip) );

   return SCIP_OKAY;
}
/** Gets the file from which parameters should be read.
 *
 * @return The name of the file from which to read the parameters.
 */
char* BN_getParameterFile(void) {
   return (char*) parameterfile;
}

// Functions for reading in the problem
/** Reads local score BN file (in Jaakkola format)
 *
 *  Format:
 *  - first line is: number of variables
 *  then local scores for each variable
 *  - first line of section of local scores is "variable number_of_parent_sets"
 *  - other lines are like "score 3 parent1 parent2 parent3" (e.g. when there are 3 parents)
 *
 *  @return SCIP_OKAY if reading was successful, or an appropriate error code otherwise.
 */
static
SCIP_RETCODE readFile(
   SCIP*        scip,          /**< SCIP data structure */
   const char*  filename,      /**< name of file to read */
   SCIP_PROBDATA* probdata     /**< problem data to be filled */
   ) {
   int i, k, l, m;
   FILE *file;
   int status;
   int n;            /* number of variables */
   SCIP_Real** Scores;
   int* nParentSets;
   int** nParents;
   int*** ParentSets;
   char** nodeNames;
   char**** tmp_ParentSets;
   int numCandidateParentSets = 0;

   /* open file */
   if (strcmp(filename,"-") == 0)
      file = stdin;
   else
      file = fopen(filename, "r");
   if ( file == NULL ) {
      SCIPerrorMessage("Could not open file %s.\n", filename);
      return SCIP_NOFILE;
   }

   /* read number of elements */
   status = fscanf(file, "%d", &n);
   if ( ! status ) {
      SCIPerrorMessage("Reading failed: first line did not state number of variables.\n");
      return SCIP_READERROR;
   }
   assert( 0 < n );
   printf("Number of variables: %d\n", n);
   probdata->n = n;

   SCIP_CALL( SCIPallocMemoryArray(scip, &Scores, n) );
   SCIP_CALL( SCIPallocMemoryArray(scip, &nParentSets, n) );
   SCIP_CALL( SCIPallocMemoryArray(scip, &nParents, n) );
   SCIP_CALL( SCIPallocMemoryArray(scip, &ParentSets, n) );
   SCIP_CALL( SCIPallocMemoryArray(scip, &tmp_ParentSets, n) );
   SCIP_CALL( SCIPallocMemoryArray(scip, &nodeNames, n) );
   for (i = 0; i <n; i++)
      nodeNames[i] = malloc(SCIP_MAXSTRLEN*sizeof(char));

   probdata->Scores = Scores;
   probdata->nParentSets = nParentSets;
   probdata->nParents = nParents;
   probdata->ParentSets = ParentSets;
   probdata->nodeNames = nodeNames;

   for (i = 0; i < n; ++i) {
      status = fscanf(file, "%s %d", nodeNames[i], &(nParentSets[i]));
      if ( ! status ) {
         SCIPerrorMessage("Reading failed: did not get number of parents for variable %d.\n", i);
         return SCIP_READERROR;
      }
      /*SCIPmessagePrintInfo("%d %d\n\n", i, nParentSets[i]);*/
      numCandidateParentSets += nParentSets[i];

      SCIP_CALL( SCIPallocMemoryArray(scip, &(nParents[i]), nParentSets[i]) );
      SCIP_CALL( SCIPallocMemoryArray(scip, &(Scores[i]), nParentSets[i]) );
      SCIP_CALL( SCIPallocMemoryArray(scip, &(ParentSets[i]), nParentSets[i]) );
      SCIP_CALL( SCIPallocMemoryArray(scip, &(tmp_ParentSets[i]), nParentSets[i]) );

      for (k = 0; k < nParentSets[i]; ++k) {
         status = fscanf(file, "%lf %d", &(Scores[i][k]), &(nParents[i][k]));
         if ( ! status ) {
            SCIPerrorMessage("Reading failed: did not get size of parent set %d for variable %d.\n", k, i);
            return SCIP_READERROR;
         }

         SCIP_CALL( SCIPallocMemoryArray(scip, &(ParentSets[i][k]), nParents[i][k]) );
         SCIP_CALL( SCIPallocMemoryArray(scip, &(tmp_ParentSets[i][k]), nParents[i][k]) );

         for (l = 0; l < nParents[i][k]; ++l) {
            tmp_ParentSets[i][k][l] = malloc(SCIP_MAXSTRLEN*sizeof(char));
            status = fscanf(file, "%s", tmp_ParentSets[i][k][l]);
            if ( ! status ) {
               SCIPerrorMessage("Reading failed: did not get parent %d for parent set %d for variable %d.\n", l, k, i);
               return SCIP_READERROR;
            }
         }
         SCIPsortInt(ParentSets[i][k],nParents[i][k]);
      }
   }

   fclose( file );

   // Find the ParentSet numbers now that all names are known
   for (i = 0; i < n; i++)
      for (k = 0; k < nParentSets[i]; k++)
         for (l = 0; l < nParents[i][k]; l++) {
            SCIP_Bool foundMatch = FALSE;
            for (m = 0; m < n && foundMatch == FALSE; m++)
               if (strcmp(nodeNames[m],tmp_ParentSets[i][k][l]) == 0) {
                  ParentSets[i][k][l] = m;
                  foundMatch = TRUE;
               }
            if (!foundMatch) {
               SCIPerrorMessage("Reading failed: unable to identify node %s, a potential parent of node %s.\n", tmp_ParentSets[i][k][l], nodeNames[i]);
               return SCIP_READERROR;
            }
         }

   // Free the allocated memory that is no longer needed
   for (i = 0; i < n; i++) {
      for (k = 0; k < nParentSets[i]; k++) {
         for (l = 0; l < nParents[i][k]; l++)
            free(tmp_ParentSets[i][k][l]);
         SCIPfreeMemoryArray(scip, &(tmp_ParentSets[i][k]));
      }
      SCIPfreeMemoryArray(scip, &(tmp_ParentSets[i]));
   }
   SCIPfreeMemoryArray(scip, &tmp_ParentSets);

   printf("Number of candidate parent sets: %d\n", numCandidateParentSets);
   printf("File reading successful\n\n");
   return SCIP_OKAY;
}





/* static */
/* SCIP_RETCODE add_last_constraint( */
/*    SCIP* scip, */
/*    SCIP_Bool*** store,  /\*binary representation of parent sets *\/ */
/*    int last, */
/*    int other1, */
/*    int other2 */
/*    ) */
/* { */

/*    int k; */

/*    SCIP_Bool ok; */

/*    SCIP_PROBDATA* probdata; */
/*    SCIP_CONS* cons; */

/*    char cluster_name[SCIP_MAXSTRLEN]; */

/*    /\* get problem data *\/ */
/*    probdata = SCIPgetProbData(scip); */
/*    assert( probdata != NULL ); */


/*    (void) SCIPsnprintf(cluster_name, SCIP_MAXSTRLEN, "lastcut(%d:%d,%d)",last,other1,other2); */

/*    SCIP_CALL( SCIPcreateConsLinear(scip, &cons, cluster_name, 0, NULL, NULL, */
/* 				   -SCIPinfinity(scip), */
/* 				   2, */
/* 				   TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE) ); */
/*    ok = FALSE; */
/*    for ( k = 0; k < probdata->nParentSets[last]; ++k ) */
/*       if ( store[last][k][other1] && store[last][k][other2] ) */
/*       { */
/* 	 SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[last][k], 2) ); */
/* 	 ok = TRUE; */
/*       } */
/*    if ( !ok ) */
/*       return SCIP_OKAY; */

/*    ok = FALSE; */
/*    for ( k = 0; k < probdata->nParentSets[other1]; ++k ) */
/*       if ( store[other1][k][last] ) */
/*       { */
/* 	 SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[other1][k], 1) ); */
/* 	 ok = TRUE; */
/*       } */
/*    if ( !ok ) */
/*       return SCIP_OKAY; */

/*    ok = FALSE; */
/*    for ( k = 0; k < probdata->nParentSets[other2]; ++k ) */
/*       if ( store[other2][k][last] ) */
/*       { */
/* 	 SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[other2][k], 1) ); */
/* 	 ok = TRUE; */
/*       } */
/*    if ( !ok ) */
/*       return SCIP_OKAY; */

/*    SCIP_CALL( SCIPaddCons(scip, cons) ); */
/*    SCIP_CALL( SCIPprintCons(scip, cons, NULL) ); */
/*    SCIP_CALL( SCIPreleaseCons(scip, &cons) ); */

/*    return SCIP_OKAY; */
/* } */

static
SCIP_Bool add_clique_constraint(
   SCIP* scip,
   SCIP_Bool*** store,  /*binary representation of parent sets */
   int* cluster,
   int cluster_size
   )
{
   int i,k,kk;
   int ci,ci2;
   int* k_indices;
   int n_k_indices;
   int k_indices_size = 0;

   int parent;
   
   char cluster_name[SCIP_MAXSTRLEN];
   char tmp_str[SCIP_MAXSTRLEN];
   SCIP_PROBDATA* probdata;
   SCIP_CONS* cons;

   SCIP_Bool first;
   SCIP_Bool ok = TRUE;

   /* get problem data */
   probdata = SCIPgetProbData(scip);
   assert( probdata != NULL );
   
   for ( ci = 0 ; ci < cluster_size ; ++ci)
      if ( probdata->nParentSets[cluster[ci]] > k_indices_size )
	 k_indices_size = probdata->nParentSets[cluster[ci]];
   SCIP_CALL( SCIPallocMemoryArray(scip, &k_indices, k_indices_size) );

   (void) SCIPsnprintf(cluster_name, SCIP_MAXSTRLEN, "cliquecut(");
   for ( ci = 0 ; ci < cluster_size ; ++ci)
   {
      (void) SCIPsnprintf(tmp_str, SCIP_MAXSTRLEN, "%d,", cluster[ci]);
      (void) strcat(cluster_name, tmp_str);
      }
   (void) strcat(cluster_name, ")");

   /* lazily create linear constraint, SCIP will upgrade it to set packing */
   SCIP_CALL( SCIPcreateConsLinear(scip, &cons, cluster_name, 0, NULL, NULL,
				   -SCIPinfinity(scip),
				   1,
				   TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE) );
   
   
   for (ci = 0; ci < cluster_size; ++ci)
   {
      i = cluster[ci];

      /* find all (indices of) parent sets for i containing
	 all of the other elements in cluster
      */
      first = TRUE;
      n_k_indices = 0;
      for (ci2 = 0; ci2 < cluster_size; ++ci2)
      {
	 if (ci == ci2)
	    continue;
	 
	 parent = cluster[ci2];
	 if ( first )
	 {
	    /* for first 'parent' just copy ( indices of ) parent
	       sets containing the 'parent' into k_indices
	    */
	    for ( k = 0; k < probdata->nParentSets[i]; ++k )
	       if ( store[i][k][parent] )
		  k_indices[n_k_indices++] = k;
	    first = FALSE;
	 }
	 else
	 {
	    /* for non-first parents, remove from k_indices
	       those ( indices of ) parents sets not containing parent
	    */
	    kk = 0;
	    while ( kk < n_k_indices )
	    {
	       if ( !store[i][k_indices[kk]][parent] )
	       {
		  /* parent missing, remove entry from k_indices */
		  n_k_indices--;
		  if ( kk < n_k_indices  )
		     k_indices[kk] = k_indices[n_k_indices];
	       }
	       else
		  kk++;
	    }
	 }
      }
      if ( n_k_indices == 0 )
      {
	 ok = FALSE;
	 break;
      }
      /* now have correct indices in k_indices*/
      for ( kk = 0; kk < n_k_indices; ++kk )
	 SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[i][k_indices[kk]], 1) );
   }
   if ( ok )
   {
      SCIP_CALL( SCIPaddCons(scip, cons) );
      /*SCIP_CALL( SCIPprintCons(scip, cons, NULL) );*/
   }
   SCIP_CALL( SCIPreleaseCons(scip, &cons) );
   SCIPfreeMemoryArray(scip, &k_indices);

   return ok;
}


static
SCIP_RETCODE add_clique_constraints(
   SCIP* scip
   )
{
   SCIP_PROBDATA* probdata;

   int i,k,l;
   int i0, i1, i2, i3;
   int n;
   SCIP_Bool*** store;

   int cluster[4];

   /* get problem data */
   probdata = SCIPgetProbData(scip);
   assert( probdata != NULL );

   n = probdata->n;

   SCIP_CALL( SCIPallocMemoryArray(scip, &store, n) );
   for (i = 0; i < n; ++i)
   {
      SCIP_CALL( SCIPallocMemoryArray(scip, &(store[i]), probdata->nParentSets[i]) );
      for (k = 0; k < probdata->nParentSets[i]; ++k)
      {
	 SCIP_CALL( SCIPallocMemoryArray(scip, &(store[i][k]), n) );
	 for ( l = 0; l < n; ++l )
	    store[i][k][l] = FALSE;
	 for ( l = 0; l < probdata->nParents[i][k]; ++l )
	    store[i][k][probdata->ParentSets[i][k][l]] = TRUE;
      }
   }

   for (i0 = 0; i0 < n; ++i0)
   {
      cluster[0] = i0;
      for (i1 = i0+1; i1 < n; ++i1)
      {
	 cluster[1] = i1;
	 if ( !add_clique_constraint(scip,store,cluster,2) )
	    continue;
	 
	 for (i2 = i1+1; i2 < n; ++i2) 
	 {
	    cluster[2] = i2;
	    if ( !add_clique_constraint(scip,store,cluster,3) )
	       continue;
	    /* add_last_constraint(scip,store,i0,i1,i2); */
	    /* add_last_constraint(scip,store,i1,i0,i2); */
	    /* add_last_constraint(scip,store,i2,i0,i1); */
	 
	    for (i3 = i2+1; i3 < n; ++i3)
	    {
	       cluster[3] = i3;
	       add_clique_constraint(scip,store,cluster,4);
	    }
	 }
      }
   }

   for (i = 0; i < n; ++i)
   {
      for (k = 0; k < probdata->nParentSets[i]; ++k)
	 SCIPfreeMemoryArray(scip, &(store[i][k]));
      SCIPfreeMemoryArray(scip, &(store[i]) );
   }
   SCIPfreeMemoryArray(scip, &store);

   return SCIP_OKAY;
}


/** Gets a problem name based on the file from whicbh it was read.
 *
 *  This function copied from LOP example written by March Pfetsch.
 *
 *  @return SCIP_OKAY if the name could be found.  An error otherwise.
 */
static
SCIP_RETCODE getProblemName(
   const char* filename,         /**< input filename */
   char*       probname,         /**< output problemname */
   int         maxSize           /**< maximum size of probname */
   )
{
   int i = 0;
   int j = 0;
   int l;

   /* first find end of string */
   while ( filename[i] != 0)
      ++i;
   l = i;

   /* go back until '.' or '/' or '\' appears */
   while ((i > 0) && (filename[i] != '.') && (filename[i] != '/') && (filename[i] != '\\'))
      --i;

   /* if we found '.', search for '/' or '\\' */
   if (filename[i] == '.')
   {
      l = i;
      while ((i > 0) && (filename[i] != '/') && (filename[i] != '\\'))
    --i;
   }

   /* correct counter */
   if ((filename[i] == '/') || (filename[i] == '\\'))
      ++i;

   /* copy name */
   while ( (i < l) && (filename[i] != 0) )
   {
      probname[j++] = filename[i++];
      if (j > maxSize-1)
    return SCIP_ERROR;
   }
   probname[j] = 0;

   return SCIP_OKAY;
}
/** create BN learning problem instance.
 *
 *  @return SCIP_OKAY if the problem was read in from file correctly, or an appropriate
 *  error otherwise.
 */
SCIP_RETCODE BN_createProb(
   SCIP*                 scip,               /**< SCIP data structure */
   const char*           filename            /**< name of file to read */
   )
{
   SCIP_PROBDATA* probdata = NULL;
   char probname[SCIP_MAXSTRLEN];

   /* allocate memory */
   SCIP_CALL( SCIPallocMemory(scip, &probdata) );

   /* take filename as problem name */
   SCIP_CALL( getProblemName(filename, probname, SCIP_MAXSTRLEN) );

   printf("File name:\t\t%s\n", filename);
   printf("Problem name:\t\t%s\n", probname);

   /* read file */
   SCIP_CALL( readFile(scip, filename, probdata) );
   // Read in pedigree data if necessary
   if (PD_inPedigreeMode(scip))
      PD_readPedigreeData(scip, probdata);
   probdata->PaVars = NULL;

   SCIP_CALL( SCIPcreateProb(scip, probname, probdelorigBN, probtransBN, probdeltransBN,
    probinitsolBN, probexitsolBN, probcopyBN, probdata) );

   return SCIP_OKAY;
}

// Functions for adding variables and constraints
/** Adds a constraint enforcing or preventing an immorality constraint.
 *
 *  @param scip The SCIP instance in which to add the constraint.
 *  @param i A parent involved in the immorality constraint.
 *  @param j The other parent involved.
 *  @param child The child involved in the constraint.
 *  @param truthvalue TRUE if the immorality must exist, FALSE if it must not exist.
 *
 *  @return SCIP_OK if the constraint was added, or an error code otherwise.
 */
static SCIP_RETCODE immorality_constraint(SCIP* scip, int i, int j, int child, SCIP_Bool truthvalue) {
   SCIP_PROBDATA* probdata;
   SCIP_CONS* cons;

   int k,l;

   int found;

   char s[SCIP_MAXSTRLEN];

   /* get problem data */
   probdata = SCIPgetProbData(scip);
   assert( probdata != NULL );

  /* scip will upgrade from linear to specialised */
   if ( truthvalue )
      (void) SCIPsnprintf(s, SCIP_MAXSTRLEN, "user_immorality_yes#%d#%d#%d", child, i, j);
   else
      (void) SCIPsnprintf(s, SCIP_MAXSTRLEN, "user_immorality_no#%d#%d#%d",  child, i, j);
   SCIP_CALL( SCIPcreateConsLinear(scip, &cons, s, 0, NULL, NULL,
               truthvalue ? 1 : -SCIPinfinity(scip),
               truthvalue ? SCIPinfinity(scip) : 0,
               TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE) );

   for (k = 0; k < probdata->nParentSets[child]; ++k)
   {
      found = 0;
      for ( l = 0; l < probdata->nParents[child][k]; ++l )
      {
    if ( probdata->ParentSets[child][k][l] == i || probdata->ParentSets[child][k][l] == j )
       found++;

    if ( found == 2 )
    {
       SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[child][k], 1) );
       break;
    }
      }
   }

   for (k = 0; k < probdata->nParentSets[i]; ++k)
      for ( l = 0; l < probdata->nParents[i][k]; ++l )
    if ( probdata->ParentSets[i][k][l] == j )
    {
       SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[i][k], -1) );
       break;
    }

   for (k = 0; k < probdata->nParentSets[j]; ++k)
      for ( l = 0; l < probdata->nParents[j][k]; ++l )
    if ( probdata->ParentSets[j][k][l] == i )
    {
       SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[j][k], -1) );
       break;
    }

   SCIP_CALL( SCIPaddCons(scip, cons) );
   /*SCIP_CALL( SCIPprintCons(scip, cons, NULL) );*/
   SCIP_CALL( SCIPreleaseCons(scip, &cons) );

   return SCIP_OKAY;
}
/** Adds a constraint stating that an edge must be present or absent.
 *
 *  @param scip The SCIP instance in which to add the constraint.
 *  @param i The node from which the edge starts.
 *  @param j The node at which the edge finishes.
 *  @param undirected Whether the edge is undirected or not.
 *  @param truthvalue Whether the edge must appear or must not appear.
 *
 *  @return SCIP_OKAY if the constraint on the edge was added successfully or an error code otherwise.
 */
static SCIP_RETCODE edge_constraint(SCIP* scip, int i, int j, SCIP_Bool undirected, SCIP_Bool truthvalue) {
   SCIP_PROBDATA* probdata;
   SCIP_CONS* cons;

   int k,l;

   char s[SCIP_MAXSTRLEN];

   /* get problem data */
   probdata = SCIPgetProbData(scip);
   assert( probdata != NULL );

   /* scip will upgrade from linear to specialised */
   if ( undirected )
      (void) SCIPsnprintf(s, SCIP_MAXSTRLEN, "user_edge#%d#%d", i, j);
   else
      (void) SCIPsnprintf(s, SCIP_MAXSTRLEN, "user_arrow#%d#%d", i, j);
   SCIP_CALL( SCIPcreateConsLinear(scip, &cons, s, 0, NULL, NULL,
               truthvalue,
               truthvalue,
               TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE) );

   for (k = 0; k < probdata->nParentSets[i]; ++k)
      for ( l = 0; l < probdata->nParents[i][k]; ++l )
    if ( probdata->ParentSets[i][k][l] == j )
    {
       SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[i][k], 1) );
       break;
    }

   if ( undirected )
      for (k = 0; k < probdata->nParentSets[j]; ++k)
    for ( l = 0; l < probdata->nParents[j][k]; ++l )
       if ( probdata->ParentSets[j][k][l] == i )
       {
          SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[j][k], 1) );
          break;
       }

   SCIP_CALL( SCIPaddCons(scip, cons) );
   /*SCIP_CALL( SCIPprintCons(scip, cons, NULL) );*/
   SCIP_CALL( SCIPreleaseCons(scip, &cons) );

   return SCIP_OKAY;
}
/** Adds a constraint on the DAG structure.
 *
 *  @param scip The SCIP instance in which to add the constraint.
 *  @param line The description of the constraint to add.
 *
 *  @return SCIP_OKAY if tyhe constraint was added or an error otherwise.
 */
static SCIP_RETCODE process_constraint(SCIP* scip, const char* line) {

   int i,j,child;

   if ( line[0] == '#' )
      return SCIP_OKAY;

   if ( sscanf(line,"%d-%d",&i,&j) == 2 )
      edge_constraint(scip,i,j,TRUE,TRUE);
   else if ( sscanf(line,"~%d-%d",&i,&j) == 2 )
      edge_constraint(scip,i,j,TRUE,FALSE);
   else if ( sscanf(line,"%d<-%d",&i,&j) == 2 )
      edge_constraint(scip,i,j,FALSE,TRUE);
   else if ( sscanf(line,"~%d<-%d",&i,&j) == 2 )
      edge_constraint(scip,i,j,FALSE,FALSE);
   else if ( sscanf(line,"%d->%d<-%d",&i,&child,&j) == 3 )
      immorality_constraint(scip,i,j,child,TRUE);
   else if ( sscanf(line,"~%d->%d<-%d",&i,&child,&j) == 3 )
      immorality_constraint(scip,i,j,child,FALSE);
   else
   {
      SCIPerrorMessage("Not recognised as a DAG constraint: %s\n",line);
      return SCIP_READERROR;
   }

   return SCIP_OKAY;
}
/** Determines if two parent sets differ by just a single given item.
 *
 *  @param scip The SCIP instance the variable sets belong to.
 *  @param i The child variable.
 *  @param ki1 The index of one parent set of i.
 *  @param ki2 The index of another parent set of i.
 *  @param j A variable.
 *
 *  @return True if the parent sets ki1 and ki2 of i are the same except for
 *  the presence of variable j in one of them but not the other.
 */
static SCIP_Bool differ( SCIP* scip, int i, int ki1, int ki2, int j) {
   int big,small,l_big,l_small;
   SCIP_PROBDATA* probdata;

   int nParents_diff;

  /* get problem data */
   probdata = SCIPgetProbData(scip);
   assert( probdata != NULL );

   nParents_diff = probdata->nParents[i][ki1] - probdata->nParents[i][ki2];

   if ( nParents_diff == 1 )
   {
      small = ki2;
      big = ki1;
   }
   else if ( nParents_diff == -1 )
   {
      small = ki1;
      big = ki2;
   }
   else
      return FALSE;

   l_small = 0;
   for (l_big = 0;  l_big < probdata->nParents[i][big]; ++l_big )
   {
      if ( probdata->ParentSets[i][big][l_big] == j )
    continue;

      if ( l_small < probdata->nParents[i][small] && probdata->ParentSets[i][big][l_big] == probdata->ParentSets[i][small][l_small] )
    l_small++;
      else
    return FALSE;
   }
   return TRUE;
}
/** Generates all the variables and constraitns in the problem.
 *
 *  This function is far too long &mdash; It needs breaking into managable chunks at some point.
 *
 *  @return SCIP_OKAY if the problem was successfully created, or an error code otherwise.
 */
SCIP_RETCODE BN_generateModel(
   SCIP*                 scip               /**< SCIP data structure */
   )
{
   SCIP_PROBDATA* probdata;
   SCIP_CONS* cons;
   int i;        /* indexes variables */
   int k;        /* indexes parentsets for a particular variable */
   int l;

   char s[SCIP_MAXSTRLEN];
   char tmp[SCIP_MAXSTRLEN];

   int n;

   SCIP_Bool noimmoralities;
   SCIP_Bool orderedcoveredarcs;
   SCIP_Bool implicitfounders;
   /* SCIP_Bool sosscores; */
   /* SCIP_Bool sosnparents; */

   int small_i, big_i, small_j, big_j;



   int ki1, ki2, kj1, kj2;
   int j, jj, l2;
   SCIP_Bool ok2;
   SCIP_VAR* arc_tmp[2];

   int minfounders;
   int maxfounders;

   int minedges;
   int maxedges;

   char* dagconstraintsfile;
   /*char* adhocconstraintsfile;*/

   FILE* dagconstraints;
   /*FILE* adhocconstraints;*/

   int status;

   SCIPgetBoolParam(scip,"gobnilp/noimmoralities",&noimmoralities);
   SCIPgetBoolParam(scip,"gobnilp/orderedcoveredarcs",&orderedcoveredarcs);
   SCIPgetBoolParam(scip,"gobnilp/implicitfounders",&implicitfounders);
   /* SCIPgetBoolParam(scip,"gobnilp/sosscores",&sosscores); */
   /* SCIPgetBoolParam(scip,"gobnilp/sosnparents",&sosnparents); */

   SCIPgetIntParam(scip,"gobnilp/minfounders",&minfounders);
   SCIPgetIntParam(scip,"gobnilp/maxfounders",&maxfounders);

   SCIPgetIntParam(scip,"gobnilp/minedges",&minedges);
   SCIPgetIntParam(scip,"gobnilp/maxedges",&maxedges);

   SCIPgetStringParam(scip,"gobnilp/dagconstraintsfile",&dagconstraintsfile);
   /*SCIPgetStringParam(scip,"gobnilp/adhocconstraintsfile",&adhocconstraintsfile);*/


   /* get problem data */
   probdata = SCIPgetProbData(scip);
   assert( probdata != NULL );

   n = probdata->n;

   /* generate variables */

   // Create pedigree specific variables if necessary
   if (PD_inPedigreeMode(scip))
      SCIP_CALL( PD_addPedigreeVariables(scip) );

   SCIP_CALL( SCIPallocMemoryArray(scip, &probdata->PaVars, n) );
   for (i = 0; i < n; ++i)
   {
      SCIP_CALL( SCIPallocMemoryArray(scip, &(probdata->PaVars[i]), probdata->nParentSets[i]) );

      /* sort, best parent set first */
      /* for primal heuristics */
      for (k=0; k < probdata->nParentSets[i]; ++k)
    probdata->Scores[i][k] = -probdata->Scores[i][k];

      SCIPsortRealPtrPtrInt(probdata->Scores[i],(void**)probdata->PaVars[i],
             (void**)probdata->ParentSets[i],probdata->nParents[i],probdata->nParentSets[i]);

      for (k=0; k < probdata->nParentSets[i]; ++k)
    probdata->Scores[i][k] = -probdata->Scores[i][k];


      for (k = 0; k < probdata->nParentSets[i]; ++k)
   {
     (void) SCIPsnprintf(s, SCIP_MAXSTRLEN, "I(%s<-{", probdata->nodeNames[i]);
     for (l = 0; l < (probdata->nParents[i][k]); ++l)
       {
         (void) SCIPsnprintf(tmp, SCIP_MAXSTRLEN, "%s,", probdata->nodeNames[probdata->ParentSets[i][k][l]]);
         (void) strcat(s, tmp);
       }
     (void) SCIPsnprintf(tmp, SCIP_MAXSTRLEN, "})");
     (void) strcat(s, tmp);

     /* still create variable for empty parent set */
     /* but if implicit founders it appears in no constraints and has zero objective coefficient */

     if ( implicitfounders )
        SCIP_CALL( SCIPcreateVar(scip, &(probdata->PaVars[i][k]), s, 0.0, 1.0, (probdata->Scores[i][k])-(probdata->Scores[i][(probdata->nParentSets[i])-1]),
                  SCIP_VARTYPE_BINARY,
                  TRUE, FALSE, NULL, NULL, NULL, NULL, NULL));
     else
        SCIP_CALL( SCIPcreateVar(scip, &(probdata->PaVars[i][k]), s, 0.0, 1.0, probdata->Scores[i][k],
                  SCIP_VARTYPE_BINARY,
                  TRUE, FALSE, NULL, NULL, NULL, NULL, NULL));

     SCIP_CALL( SCIPaddVar(scip, probdata->PaVars[i][k]) );
     SCIPdebugMessage("adding variable %s with obj coefficient %f\n", SCIPvarGetName(probdata->PaVars[i][k]), SCIPvarGetObj(probdata->PaVars[i][k]));

   }


      /* constraint that at most one parent set chosen for variable i */

      if ( implicitfounders )
      {
    (void) SCIPsnprintf(s, SCIP_MAXSTRLEN, "setpack#%d", i);
    SCIP_CALL( SCIPcreateConsSetpack(scip,&cons,s,probdata->nParentSets[i],probdata->PaVars[i],
                     TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE) );
      }
      else
      {
    (void) SCIPsnprintf(s, SCIP_MAXSTRLEN, "setpart#%d", i);
    SCIP_CALL( SCIPcreateConsSetpart(scip,&cons,s,probdata->nParentSets[i],probdata->PaVars[i],
                     TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE) );
      }
      SCIP_CALL( SCIPaddCons(scip, cons) );
      SCIP_CALL( SCIPreleaseCons(scip, &cons) );

      /* constraint that at most one parent set chosen for variable i */
      /* SOS versions */
      /* if ( sosscores ) */
      /* { */
      /*     (void) SCIPsnprintf(s, SCIP_MAXSTRLEN, "sos#%d", i); */
      /*     SCIP_CALL( SCIPcreateConsSOS1(scip,&cons,s,probdata->nParentSets[i],probdata->PaVars[i], probdata->Scores[i], */
      /*                    TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE) ); */
      /*     SCIP_CALL( SCIPaddCons(scip, cons) ); */
      /*     SCIP_CALL( SCIPreleaseCons(scip, &cons) ); */
      /* } */

      /* if ( sosnparents ) */
      /* { */
      /*     (void) SCIPsnprintf(s, SCIP_MAXSTRLEN, "sos#%d", i); */
      /*     SCIP_CALL( SCIPcreateConsSOS1(scip,&cons,s,probdata->nParentSets[i],probdata->PaVars[i],(double *) probdata->nParents[i], */
      /*                    TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE) ); */
      /*     SCIP_CALL( SCIPaddCons(scip, cons) ); */
      /*     SCIP_CALL( SCIPreleaseCons(scip, &cons) ); */
      /* } */



   }
   
   SCIP_CALL( add_clique_constraints(scip));

   if ( orderedcoveredarcs )
   {
      /*

    rule out covered arcs from higher to lower vertex

    for each i,j,C (j>i,C a set) such that the following variables exist:
    I(i<-C), I(i<-C+j), I(j<-C), I(j<-C+i)

    if I(i<-C+j)=1,I(j<-C)=1
    then the edge i<-j is 'covered' and
    can be replaced by:
    I(i<-C)=1,I(j<-C+i)
    which reverse the edge


    without creating a cycle or changing Markov equivalence
    class, so add constraint:
    I(i<-C+j) + I(j<-C) <= 1
    to rule out first case
      */

      for (i = 0; i < n; ++i)
      {
    for (ki1 = 0; ki1 < probdata->nParentSets[i]; ++ki1)
    {
       for (ki2 = ki1+1; ki2 < probdata->nParentSets[i]; ++ki2)
       {
          if ( probdata->nParents[i][ki1] - probdata->nParents[i][ki2] == 1 )
          {
        big_i = ki1;
        small_i = ki2;
          }
          else if ( probdata->nParents[i][ki2] - probdata->nParents[i][ki1] == 1 )
          {
        big_i = ki2;
        small_i = ki1;
          }
          else
        /* need to at least find two parent sets for i
           differing in size by 1 */
        continue;

          for (j = i+1; j < n; ++j)
          {
        /* ki1 and ki2 can only differ by j */
        if ( !differ(scip,i,ki1,ki2,j) )
           continue;

        for (kj1 = 0; kj1 < probdata->nParentSets[j]; ++kj1)
        {
           for (kj2 = kj1+1; kj2 < probdata->nParentSets[j]; ++kj2)
           {
         if ( probdata->nParents[j][kj1] - probdata->nParents[j][kj2] == 1 )
         {
            small_j = kj2;
            big_j = kj1;
         }
         else if ( probdata->nParents[j][kj2] - probdata->nParents[j][kj1] == 1 )
         {
            small_j = kj1;
            big_j = kj2;
         }
         else
            /* need to at least find two parent sets for j
               differing in size by 1 */
            continue;

         if ( !differ(scip,j,kj1,kj2,i) )
            continue;

         /* small_i and small_j  must be the same */
         /* if so big_i is small_j with j added */
         if (  probdata->nParents[i][small_i] !=  probdata->nParents[j][small_j] )
            continue;

         l2 = 0;
         ok2 = TRUE;
         for (l = 0; l < probdata->nParents[i][small_i]; ++l)
         {
            if ( probdata->ParentSets[i][small_i][l] != probdata->ParentSets[j][small_j][l2] )
            {
               ok2 = FALSE;
               break;
            }
            else
               l2++;
         }

         if ( !ok2 )
            continue;

         SCIPdebugMessage("Ruling out having both %s and %s since arc %d<-%d is covered and there exists %s and %s\n",
                SCIPvarGetName(probdata->PaVars[i][big_i]),SCIPvarGetName(probdata->PaVars[j][small_j]),i,j,
                SCIPvarGetName(probdata->PaVars[i][small_i]),SCIPvarGetName(probdata->PaVars[j][big_j]));
         arc_tmp[0] = probdata->PaVars[i][big_i];
         arc_tmp[1] = probdata->PaVars[j][small_j];
         (void) SCIPsnprintf(s, SCIP_MAXSTRLEN, "covered_arc#%s#%s", probdata->nodeNames[i], probdata->nodeNames[j]);
         SCIP_CALL( SCIPcreateConsSetpack(scip,&cons,s,2,arc_tmp,
                      TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE) );
         SCIP_CALL( SCIPaddCons(scip, cons) );
         /*SCIP_CALL( SCIPprintCons(scip, cons, NULL) );*/
         SCIP_CALL( SCIPreleaseCons(scip, &cons) );
           }
        }
          }
       }
    }
      }
   }
         /* post constraint */

         /* do ki1, ki2, kj1, kj2 lead to a constraint? */


    /* { */

    /* /\* check each as a potential 'C' *\/ */
    /* /\* small_i = 'k' *\/ */
    /* for (small_i = 0; small_i < probdata->nParentSets[i]; ++small_i) */
    /* { */

    /*    c = probdata->ParentSets[i][small_i]; */
    /*    csize = probdata->nParents[i][small_i]; /\* can be zero *\/ */
    /*    /\* is parent set k a suitable 'C'? *\/ */



    /*    { */
    /*       if ( probdata->nParents[i][kk] != csize+1 ) */
    /*     continue; */


    /*    /\* is there another parent set of i which is C+j?*\/ */

    /*    { */
    /*       big_i = -1; */




    /*     ok2 = TRUE; */
    /*     l2 = 0; */
    /*     for ( l = 0; l < probdata->nParents[i][kk]; ++l ) */
    /*     { */
    /*        /\*printf("%d,%d,%d\n",l,l2,csize);*\/ */
    /*        if ( probdata->ParentSets[i][kk][l] == j ) */
    /*      continue; */

    /*        if ( csize == 0 || probdata->ParentSets[i][kk][l] != c[l2] ) */
    /*        { */
    /*      ok2 = FALSE; */
    /*      break; */
    /*        } */
    /*        l2++; */
    /*     } */
    /*     if ( ok2 ) */
    /*     { */
    /*        big_i = kk; */
    /*        break; */
    /*     } */
    /*     /\* otherwise keep looking *\/ */
    /*       } */
    /*       if ( big_i < 0 ) */
    /*     /\* couldn't find one *\/ */
    /*       { */
    /*     /\*printf("No arc-reversal constraint for i=%d, j=%d, c=%s.\n",i,j,SCIPvarGetName(probdata->PaVars[i][small_i]));*\/ */
    /*     continue; */
    /*       } */

    /*       /\* are C and C+i parent sets of j ? *\/ */
    /*       small_j = -1; */
    /*       big_j = -1; */
    /*       for (kk = 0; kk < probdata->nParentSets[j]; ++kk) */
    /*       { */
    /*     if ( small_j < 0 && probdata->nParents[j][kk] == csize ) */
    /*     { */
    /*        /\* need to see whether it is 'c' *\/ */

    /*        ok2 = TRUE; */
    /*        l2 = 0; */
    /*        for ( l = 0; l < probdata->nParents[j][kk]; ++l ) */
    /*        { */
    /*      if ( probdata->ParentSets[j][kk][l] != c[l] ) */
    /*      { */
    /*         ok2 = FALSE; */
    /*         break; */
    /*      } */
    /*      l2++; */
    /*        } */
    /*        if ( ok2 ) */
    /*      small_j = kk; */
    /*     } */

    /*     if ( big_j < 0 && probdata->nParents[j][kk] == csize+1 ) */
    /*     { */
    /*         /\* need to see whether it is 'c'+i *\/ */

    /*        ok2 = TRUE; */
    /*        l2 = 0; */
    /*        for ( l = 0; l < probdata->nParents[j][kk]; ++l ) */
    /*        { */
    /*      if ( probdata->ParentSets[j][kk][l] == i ) */
    /*         continue; */

    /*      if ( csize == 0 || probdata->ParentSets[j][kk][l] != c[l2] ) */
    /*      { */
    /*         ok2 = FALSE; */
    /*         break; */
    /*      } */
    /*      l2++; */
    /*        } */
    /*        if ( ok2 ) */
    /*      big_j = kk; */
    /*     } */

    /*     if ( small_j>0 && big_j>0 ) */
    /*        break; */
    /*       } */

   /*           if ( small_j>0 && big_j>0 ) */
   /*           { */
   /*         /\*printf("Found arc-reversal constraint for i=%d, j=%d, c=%s.\n",i,j,SCIPvarGetName(probdata->PaVars[i][small_i]));*\/ */
   /*         /\*ok, constraint can be posted *\/ */
   /*         /\*printf("%d,%d,%d,%d\n",small_i,big_i,small_j,big_j);*\/ */
   /*         arc_tmp[0] = probdata->PaVars[i][big_i];   */
   /*         arc_tmp[1] = probdata->PaVars[j][small_j]; */
   /*         (void) SCIPsnprintf(s, SCIP_MAXSTRLEN, "covered_arc#%d#%d", i, j); */
   /*         SCIP_CALL( SCIPcreateConsSetpack(scip,&cons,s,2,arc_tmp, */
   /*                      TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE) ); */
   /*         SCIP_CALL( SCIPaddCons(scip, cons) ); */
   /*         /\*SCIP_CALL( SCIPprintCons(scip, cons, NULL) );*\/ */
   /*         SCIP_CALL( SCIPreleaseCons(scip, &cons) ); */
   /*           } */
   /*           /\*printf("No arc-reversal constraint for i=%d, j=%d, c=%s.\n",i,j,SCIPvarGetName(probdata->PaVars[i][small_i]));*\/ */
   /*        } */
   /*     } */
   /*    } */
   /* } */

   SCIP_CALL( SCIPcreateConsLinear(scip, &cons, "edges", 0, NULL, NULL,
               minedges,
               maxedges > 0 ? maxedges : SCIPinfinity(scip),
               TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE) );
   for (i = 0; i < n; ++i)
      for (k=0; k < probdata->nParentSets[i]; ++k)
    SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[i][k], probdata->nParents[i][k]) );

   SCIP_CALL( SCIPaddCons(scip, cons) );
   /*SCIP_CALL( SCIPprintCons(scip, cons, NULL) );*/
   SCIP_CALL( SCIPreleaseCons(scip, &cons) );

   /* add in constraint on number of founders */
   if ( implicitfounders )
   {
      SCIP_CALL( SCIPcreateConsLinear(scip, &cons, "founders", 0, NULL, NULL,
                  minfounders-n,
                  (maxfounders > 0 ? maxfounders : SCIPinfinity(scip))-n,
                  TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE) );
      for (i = 0; i < n; ++i)
    for (k=0; k < probdata->nParentSets[i]; ++k)
       if ( probdata->nParents[i][k] > 0 )
          SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[i][k], -1) );
   }
   else
   {
      SCIP_CALL( SCIPcreateConsLinear(scip, &cons, "founders", 0, NULL, NULL,
                  minfounders,
                  maxfounders > 0 ? maxfounders : SCIPinfinity(scip),
                  TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE) );
      for (i = 0; i < n; ++i)
    for (k=0; k < probdata->nParentSets[i]; ++k)
       if ( probdata->nParents[i][k] == 0 )
       {
          SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[i][k], 1) );
          break;
       }
   }

   SCIP_CALL( SCIPaddCons(scip, cons) );
   /*SCIP_CALL( SCIPprintCons(scip, cons, NULL) );*/
   SCIP_CALL( SCIPreleaseCons(scip, &cons) );

   /* 2 clique cuts ...*/

   /* for (i = 0; i < n; ++i) */
   /* { */
   /*    for (j = i+1; j < n; ++j) */
   /*    { */
    /* SCIP_CALL( SCIPcreateConsLinear(scip, &cons, "todo", 0, NULL, NULL, */
    /*             -SCIPinfinity(scip), */
    /*             1, */
    /*             TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE) ); */

    /* for (k=0; k < probdata->nParentSets[i]; ++k) */
    /* { */
    /*    for ( l=0; l<probdata->nParents[i][k]; ++l ) */
    /*    { */
    /*       if ( probdata->ParentSets[i][k][l] == j ) */
    /*       { */
    /*     SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[i][k], 1) ); */
    /*     break; */
    /*       } */
    /*    } */
    /* } */
    /* for (k=0; k < probdata->nParentSets[j]; ++k) */
    /* { */
    /*    for ( l=0; l<probdata->nParents[j][k]; ++l ) */
    /*    { */
    /*       if ( probdata->ParentSets[j][k][l] == i ) */
    /*       { */
    /*     SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[j][k], 1) ); */
    /*     break; */
    /*       } */
    /*    } */
    /* } */
    /* SCIP_CALL( SCIPaddCons(scip, cons) ); */
    /* /\*SCIP_CALL( SCIPprintCons(scip, cons, NULL) );*\/ */
    /* SCIP_CALL( SCIPreleaseCons(scip, &cons) ); */


   /*     for (jj = j+1; jj < n; ++jj) */
   /*     { */
   /*        (void) SCIPsnprintf(s, SCIP_MAXSTRLEN, "clique#%d#%d#%d", i, j, jj); */
   /*        SCIP_CALL( SCIPcreateConsLinear(scip, &cons, s, 0, NULL, NULL, */
   /*                    -SCIPinfinity(scip), */
   /*                    2, */
   /*                    TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE) ); */
   /*        ok2=FALSE; */
   /*        for (k=0; k < probdata->nParentSets[i]; ++k) */
   /*        { */
   /*           found = 0; */
   /*           for ( l=0; l<probdata->nParents[i][k]; ++l ) */
   /*         if ( probdata->ParentSets[i][k][l] == j || probdata->ParentSets[i][k][l] == jj ) */
   /*            found++; */
   /*           if ( found == 2 ) */
   /*         ok2 = TRUE; */
   /*           SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[i][k], found) ); */
   /*        } */

   /*        for (k=0; k < probdata->nParentSets[j]; ++k) */
   /*        { */
   /*           found = 0; */
   /*           for ( l=0; l<probdata->nParents[j][k]; ++l ) */
   /*         if ( probdata->ParentSets[j][k][l] == i  || probdata->ParentSets[j][k][l] == jj ) */
   /*            found++; */
   /*           if ( found == 2 ) */
   /*         ok2=TRUE; */
   /*           SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[j][k], found) ); */
   /*        } */

   /*        for (k=0; k < probdata->nParentSets[jj]; ++k) */
   /*        { */
   /*           found = 0; */
   /*           for ( l=0; l<probdata->nParents[jj][k]; ++l ) */
   /*         if ( probdata->ParentSets[jj][k][l] == i  || probdata->ParentSets[jj][k][l] == j ) */
   /*            found++; */
   /*           if ( found == 2 ) */
   /*         ok2 = TRUE;  */
   /*           SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[jj][k], found) ); */
   /*        } */
   /*        if (!ok2) */
   /*           continue; */
   /*        SCIP_CALL( SCIPaddCons(scip, cons) ); */
   /*        SCIP_CALL( SCIPprintCons(scip, cons, NULL) ); */
   /*        SCIP_CALL( SCIPreleaseCons(scip, &cons) ); */
   /*     } */
   /*    } */
   /* } */




   /* generate DAG cluster constraint */
   SCIP_CALL( DC_createCons(
                   scip,
                   &cons,
                   "DagCluster",
                   probdata->n,
                   probdata->nParentSets,
                   probdata->nParents,
                   probdata->ParentSets,
                   probdata->PaVars,
                   TRUE,
                   TRUE,
                   TRUE,
                   TRUE,
                   TRUE,
                   FALSE,
                   FALSE,
                   FALSE,
                   FALSE,
                   FALSE
                   ));
   SCIP_CALL( SCIPaddCons(scip, cons) );
   SCIP_CALL( SCIPreleaseCons(scip, &cons) );


   if ( strcmp(dagconstraintsfile,"") != 0 )
   {
      dagconstraints = fopen(dagconstraintsfile, "r");
      if ( dagconstraints == NULL )
      {
    SCIPerrorMessage("Could not open file %s.\n", dagconstraintsfile);
    return SCIP_NOFILE;
      }
      status = fscanf(dagconstraints,"%[^\n]%*c", s);
      while ( status == 1 )
      {
    process_constraint(scip,s);
    status = fscanf(dagconstraints,"%[^\n]%*c", s);
      }
      fclose(dagconstraints);
   }

   if ( noimmoralities )
   {
      for (i = 0; i < n; ++i)
      {
    for (j = 0; j < n; ++j)
    {
       if ( i == j )
          continue;

       for (jj = j+1; jj < n; ++jj)
       {
          if ( i == jj  )
        continue;

          SCIP_CALL( immorality_constraint(scip,j,jj,i,FALSE) );
       }
    }
      }
   }

   // Create pedigree specific constraints if necessary
   if (PD_inPedigreeMode(scip))
      SCIP_CALL( PD_addPedigreeConstraints(scip) );

   /* set maximization */
   SCIP_CALL_ABORT( SCIPsetObjsense(scip, SCIP_OBJSENSE_MAXIMIZE) );

   return SCIP_OKAY;
}

// Functions related to finding the n best networks
/** Gets the number of most likely Bayesian networks that should be found.
 *
 *  @param scip The SCIP inatance used for finding the networks.
 *  @return The number of Bayesian networks that should be found.
 */
int BN_getNumberOfRepeats(SCIP* scip) {
   int nbns;
   SCIPgetIntParam(scip,"gobnilp/nbns", &nbns);
   return nbns;
}
/** Adds a constraint that prevents the current best network being found again.
 *
 *  @param scip The SCIP instance being used for the optimisation.
 *  @param run The iteration of the loop that this soilution was found on.
 *
 *  @return SCIP_OKAY if a constraint could be added, or an error otherwise.
 */
SCIP_RETCODE BN_addNonRepetitionConstraint(SCIP* scip, int run) {
   int n_empty = 0;
   int i,k;
   SCIP_PROBDATA* probdata = SCIPgetProbData(scip);
   SCIP_SOL* sol = SCIPgetBestSol(scip);
   char consname[SCIP_MAXSTRLEN];
   SCIP_CONS *cons;
   int* chosen;
   SCIP_CALL( SCIPallocMemoryArray(scip, &chosen, probdata->n) );

   /* record which BN just found before doing 'free transform' */


   for (i = 0; i < probdata->n; ++i) {
      SCIP_Bool no_parents = TRUE;
      for (k = 0; k < probdata->nParentSets[i]; ++k) {
         SCIP_Real val = SCIPgetSolVal(scip, sol, probdata->PaVars[i][k]);
         assert( SCIPisIntegral(scip, val) );
         if ( val > 0.5 ) {
            chosen[i] = k;
            no_parents = FALSE;
            break;
         }
      }
      if ( no_parents ) {
         n_empty++;
         chosen[i] = -1;
      }
   }

   SCIP_CALL( SCIPfreeTransform(scip) );
   (void) SCIPsnprintf(consname, SCIP_MAXSTRLEN, "ruleout#%d", run);
   /* maybe change this to set covering constraint */
   /* rather than rely on upgrading */
   /* basically the same as CUTOFF_CONSTRAINT(addBinaryCons) in cons_countsols.c */
   SCIP_CALL( SCIPcreateConsLinear(scip, &cons, consname, 0, NULL, NULL, -SCIPinfinity(scip),(probdata->n)-1-n_empty,
                      TRUE,
                      TRUE,
                      TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE) );

   for (i = 0; i < probdata->n; ++i) {
      if ( chosen[i] == -1 )
         for (k = 0; k < probdata->nParentSets[i]-1; ++k)
            SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[i][k], -1) );
      else
         SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[i][chosen[i]], 1) );
   }
   SCIP_CALL( SCIPaddCons(scip, cons) );
   SCIP_CALL( SCIPreleaseCons(scip, &cons) );

   SCIPfreeMemoryArray(scip, &chosen);

   return SCIP_OKAY;
}

// Functions for printing
/** Prints appropriate information about each optimal solution obtained.
 *
 *  @param scip The SCIP instance for which the solution has been found.
 *  @param run The iteration of the main loop that the solution was found on.
 *  @return SCIP_OKAY if printing succeeded or an appropriate error code otherwise.
 */
SCIP_RETCODE BN_doIterativePrint(SCIP* scip, int run) {
   SCIP_CALL( IO_doIterativePrint(scip, run) );
   return SCIP_OKAY;
}
/** Prints any of the current SCIP or GOBNILP parameters not at their default value.
 *
 *  @param scip The SCIP instance to consult the parameters of.
 *  @return SCIP_OKAY if the parameters were printed correctly, or an error code otherwise.
 */
SCIP_RETCODE BN_printParameters(SCIP* scip){
   SCIP_CALL( IO_printParameters(scip) );
   return SCIP_OKAY;
}
/** Prints a header which describes the GOBNILP and SCIP systems being used.
 *
 *  @param scip The SCIP instance that is being used.
 *  @return SCIP_OKAY if printing succeeded or an error code otherwise.
 */
SCIP_RETCODE BN_printHeader(SCIP* scip){
   SCIP_CALL( IO_printHeader(scip) );
   return SCIP_OKAY;
}

