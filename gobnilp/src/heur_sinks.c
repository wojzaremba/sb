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
 *  Defines all the functionality needed to find a heursitic solution to the Bayesian network problem.
 *
 *  The heursitic is based on repeatedly choosing the best parent set for a node to add to the network in
 *  a greedy manner, subject to the constraint that adding the new edges doesn't result in a cycle being
 *  formed.
 */

#include <string.h>

#include "heur_sinks.h"
#include "scip/scip.h"
#include "pedigrees.h"
#include "data_structures.h"

#define HEUR_NAME             "sinks"                          /**< The name of the heuristic. */
#define HEUR_DESC             "primal heuristic template"      /**< A description of the heuristic. */
#define HEUR_DISPCHAR         'k'                              /**< The character to display in the solver when the heuristic is used. */
#define HEUR_PRIORITY         10                               /**< The calling priority of the heuristic. */
#define HEUR_FREQ             1                                /**< The heursitic is called at every node. */
#define HEUR_FREQOFS          0                                /**< The heursitic is called from the first node onwards. */
#define HEUR_MAXDEPTH         -1                               /**< Set no depth limit for calling the heuristic. */
#define HEUR_TIMING           SCIP_HEURTIMING_DURINGLPLOOP     /**< Call the heuristic after each LP solve during the cut-and-price loop. */
#define HEUR_USESSUBSCIP      FALSE                            /**< The heuristic doesn't use a secondary SCIP instance. */

#define DEFAULT_INITSEED     0                                 /**< The initial seed to use for random values. */
#define EPSILON              1e-9                              /**< How much improvement a candidate parent set to add must have before we chose it. */

/** There is no copy method. */
#define heurCopySinks NULL
/** There is no deinitialization method. */
#define heurExitSinks NULL
/** There is no initialization method. */
#define heurInitsolSinks NULL
/** There is no deinitialization method. */
#define heurExitsolSinks NULL

/** destructor of primal heuristic to free user data (called when SCIP is exiting) */
static
SCIP_DECL_HEURFREE(heurFreeSinks)
{  /*lint --e{715}*/

   SCIP_HEURDATA* heurdata;
   int i;

   assert(heur != NULL);
   assert(strcmp(SCIPheurGetName(heur), HEUR_NAME) == 0);
   assert(scip != NULL);

   heurdata = SCIPheurGetData(heur);
   assert(heurdata != NULL);

   assert(heurdata->nParentSets != NULL);

   for (i=0; i<heurdata->n; ++i)
   {
      SCIPfreeBlockMemoryArray(scip, &(heurdata->vals[i]), heurdata->nParentSets[i]);
      SCIPfreeBlockMemoryArray(scip, &(heurdata->loss[i]), heurdata->nParentSets[i]);
   }

   SCIPfreeMemoryArray(scip, &(heurdata->nParentSets));


   SCIPfreeBlockMemoryArray(scip, &heurdata->bestparents, heurdata->n);
   SCIPfreeBlockMemoryArray(scip, &heurdata->not_sinks, heurdata->n);
   SCIPfreeBlockMemoryArray(scip, &heurdata->sink, heurdata->n);
   SCIPfreeBlockMemoryArray(scip, &heurdata->loss_ub, heurdata->n);
   SCIPfreeBlockMemoryArray(scip, &heurdata->vals, heurdata->n);
   SCIPfreeBlockMemoryArray(scip, &heurdata->loss, heurdata->n);

   SCIPfreeMemory(scip, &heurdata);

   SCIPheurSetData(heur, NULL);

   return SCIP_OKAY;
}

/** initialization method of primal heuristic (called after problem was transformed) */
static
SCIP_DECL_HEURINIT(heurInitSinks)
{  /*lint --e{715}*/

   SCIP_HEURDATA* heurdata;
   SCIP_PROBDATA* probdata;
   int i;
   char* filesols;

   assert(heur != NULL);
   assert(strcmp(SCIPheurGetName(heur), HEUR_NAME) == 0);
   assert(scip != NULL);

   heurdata = SCIPheurGetData(heur);
   assert(heurdata != NULL);

   probdata = SCIPgetProbData(scip);

   assert( probdata != NULL );

   assert( probdata->nParentSets != NULL );
   assert( probdata->nParents != NULL );
   assert( probdata->ParentSets != NULL );
   assert( probdata->PaVars != NULL );


   /* will get compile-time error here if not used with GOBNILP */
   heurdata->n = probdata->n;
   heurdata->nParents = probdata->nParents;
   heurdata->ParentSets = probdata->ParentSets;
   heurdata->PaVars = probdata->PaVars;
   /* have to copy these over, so we still know size of array
      even in probdata has been freed
   */
   SCIP_CALL( SCIPallocMemoryArray(scip, &(heurdata->nParentSets), heurdata->n) );
   for (i=0; i<heurdata->n; ++i)
      heurdata->nParentSets[i] = probdata->nParentSets[i];

   if (PD_inPedigreeMode(scip))
      heurdata->ped = probdata->ped;

   /* *(heurdata->seedp) = DEFAULT_INITSEED;*/
   SCIP_CALL( SCIPgetStringParam(scip, "heuristics/sinks/filesols", &filesols) );

   if ( strcmp(filesols,"") != 0 )
      heurdata->file = fopen(filesols, "w");
   else
      heurdata->file = NULL;


   SCIP_CALL( SCIPallocBlockMemoryArray(scip, &(heurdata->bestparents), heurdata->n) );
   SCIP_CALL( SCIPallocBlockMemoryArray(scip, &(heurdata->not_sinks), heurdata->n) );
   SCIP_CALL( SCIPallocBlockMemoryArray(scip, &(heurdata->sink), heurdata->n) );
   SCIP_CALL( SCIPallocBlockMemoryArray(scip, &(heurdata->loss_ub), heurdata->n) );
   SCIP_CALL( SCIPallocBlockMemoryArray(scip, &(heurdata->vals), heurdata->n) );
   SCIP_CALL( SCIPallocBlockMemoryArray(scip, &(heurdata->loss), heurdata->n) );

   for (i=0; i<heurdata->n; ++i)
   {
      SCIP_CALL( SCIPallocBlockMemoryArray(scip, &(heurdata->vals[i]), heurdata->nParentSets[i]) );
      SCIP_CALL( SCIPallocBlockMemoryArray(scip, &(heurdata->loss[i]), heurdata->nParentSets[i]) );
   }
   SCIPheurSetData(heur, heurdata);

   return SCIP_OKAY;
}

/** execution method of primal heuristic */
static
SCIP_DECL_HEUREXEC(heurExecSinks)
{

   SCIP_HEURDATA*  heurdata;

   int i,j,k,l;
   SCIP_SOL* sol;
   SCIP_Bool success;

   int sinks_to_choose;

   SCIP_Real bestloss, j_loss, improvement;
   int bestvariable;
   SCIP_VAR* pavar;
   SCIP_VAR* bestpavar;
   int bestindex;

   SCIP_Bool current_bestparents_for_j_allowed;
   /*unsigned int* seedp;
     int offset;*/

   SCIP_Real cum_loss;
   SCIP_Bool vgreedy = 1;

   int parent_to_check;

   FILE* output;

   assert(strcmp(SCIPheurGetName(heur), HEUR_NAME) == 0);
   assert(result != NULL);
   assert(SCIPhasCurrentNodeLP(scip));

   *result = SCIP_DIDNOTRUN;

   /* get heuristic data */
   heurdata = SCIPheurGetData(heur);
   assert(heurdata != NULL);

   output = heurdata->file == NULL ? stdout : heurdata->file;

   sinks_to_choose = heurdata->n;
   /*seedp = heurdata->seedp;*/

   assert(heurdata->loss != NULL);

   /* (re-)initialise */
   for ( i = 0; i < sinks_to_choose; ++i )
   {
      /* assume parent sets are ordered with best first */
      heurdata->bestparents[i] = 0;
      heurdata->not_sinks[i] = i;
      heurdata->sink[i] = 0;
      heurdata->loss_ub[i] = 1.0;
   }

   /*SCIPpermuteArray( (void**) &heurdata->not_sinks,0,sinks_to_choose,&randseed);*/

   /* initialises all values to zero */
   SCIP_CALL( SCIPcreateSol(scip,&sol,heur) );






   /* NOT USED AT PRESENT */
   if ( !vgreedy )
   {
      for ( i = 0; i < sinks_to_choose; ++i )


      {

    assert(heurdata->vals[i] != NULL);
    assert(heurdata->loss[i] != NULL);

    SCIP_CALL( SCIPgetSolVals(scip,NULL,heurdata->nParentSets[i],heurdata->PaVars[i],heurdata->vals[i]) );
    cum_loss = 0.0;
    for (k = heurdata->nParentSets[i]-1; k > -1; --k)
    {
       /* the loss incurred by setting PaVars[i][k] to 1, given that all earlier
          parent sets already set to 0 */
       heurdata->loss[i][k] = (1-heurdata->vals[i][k])*(1-heurdata->vals[i][k]) + cum_loss;
       cum_loss = cum_loss + heurdata->vals[i][k]*heurdata->vals[i][k];
    }
      }
   }


   while ( sinks_to_choose )
   {
      /* look for a new sink */

      bestvariable = -1;
      bestpavar = NULL;
      bestloss = SCIPinfinity(scip);
      bestindex = -1;

      /*offset = SCIPgetRandomInt(0,sinks_to_choose,seedp);*/

      for ( i = 0; i < sinks_to_choose; ++i )
      {

    /* consider variable j as a new sink */

    j = heurdata->not_sinks[i];

    /* get the best scoring parent set for j that is still allowed */

    pavar = heurdata->PaVars[j][heurdata->bestparents[j]];

    SCIPdebugMessage("considering variable %s as a sink.\n",SCIPvarGetName(pavar));

         /* /\* if a variable fixed to 1, just take that one *\/ */
    /* if ( SCIPisEQ(scip,SCIPvarGetLbLocal(pavar),1.0) )  */
    /*    { */
    /*       bestindex = i; */
    /*       bestloss = 0.0; */
    /*       bestvariable = j; */
    /*       bestpavar = pavar; */
    /*       break; */
    /*    } */

         /* /\* if a variable fixed to 0, can't choose it *\/ */
    /* /\* would be better to remove these before entering this loop *\/ */
    /* if ( SCIPisEQ(scip,SCIPvarGetUbLocal(pavar),0.0) )  */
    /* { */
    /*    SCIPdebugMessage("variable %s fixed to 0.\n",SCIPvarGetName(pavar)); */
    /*    continue; */
    /* } */

    if ( vgreedy )
       /* how much ( further ) do we move (in L1 metric) if this variable rounded to 1? */
       j_loss = heurdata->loss_ub[j] - SCIPgetSolVal(scip,NULL,pavar);
    else
       j_loss = heurdata->loss[j][heurdata->bestparents[j]];

    assert( !SCIPisNegative(scip,j_loss) );


    /* specifically, how much better is the loss for j compared to current best choice? */

    improvement = bestloss - j_loss;
    if ( improvement > EPSILON )
       /* if ( improvement > EPSILON || (improvement > -EPSILON && SCIPgetRandomInt(0,1,seedp)))*/
    {
       SCIPdebugMessage("variable %s is best sink so far.\n",SCIPvarGetName(pavar));
       bestindex = i;
       bestloss = j_loss;
       bestvariable = j;
       bestpavar = pavar;
    }
    else
    {
       SCIPdebugMessage("variable %s rejected as sink.\n",SCIPvarGetName(pavar));
    }
      }

      /* if ( bestvariable < 0 ) */
      /* { */
      /*     SCIPdebugMessage("Could not find a sink\n"); */
      /*     SCIP_CALL( SCIPfreeSol(scip,&sol) ); */
      /*     *result = SCIP_DIDNOTFIND; */
      /*     return SCIP_OKAY; */
      /* }  */

      assert(bestpavar != NULL);
      /*printf("%f\n",bestloss);*/
      assert(SCIPisLE(scip,bestloss,1.0));
      assert(bestindex > -1);
      assert(bestvariable > -1);

      heurdata->sink[bestvariable] = 1;
      SCIPdebugMessage("variable %s chosen as a sink.\n",SCIPvarGetName(bestpavar));
      /*printf("%d ",bestvariable);*/
      if (  SCIPisPositive(scip,SCIPvarGetUbLocal(bestpavar)) )
      {
    SCIPdebugMessage("Setting %s to 1 in primal solution.\n",SCIPvarGetName(bestpavar));
    SCIP_CALL( SCIPsetSolVal(scip,sol,bestpavar,1.0) );
      }
      /* best variable now a sink, so remove from list of not_sinks
    by overwriting its entry with last entry in this array
    decrement sinks_to_choose as well
      */
      heurdata->not_sinks[bestindex] = heurdata->not_sinks[--sinks_to_choose];

      /* update allowed parent sets */
      /* and update upper bound on distance moved by any future rounding */
      for ( i = 0; i < sinks_to_choose; ++i )
      {
    j = heurdata->not_sinks[i];
    /* 'do' loop, since at least one check must be made */
    do
    {
       current_bestparents_for_j_allowed = TRUE;

       /* check each parent of current best parent set for j */
       for (l = 0; l < heurdata->nParents[j][heurdata->bestparents[j]]; ++l)
       {
          parent_to_check = heurdata->ParentSets[j][heurdata->bestparents[j]][l];

          /* if parent_to_check is already a sink it cannot be a parent of j (which is currently a non-sink) */
          if ( heurdata->sink[parent_to_check]  )
          {
        /* current best parent set no longer allowed */
        current_bestparents_for_j_allowed = FALSE;
        break;
          }
       }

       if ( !current_bestparents_for_j_allowed )
       {
          /* check if variable fixed to 1, but we're trying to rule it out, so failure */
          if ( SCIPisEQ(scip,SCIPvarGetLbLocal(heurdata->PaVars[j][heurdata->bestparents[j]]),1.0) )
          {
        SCIP_CALL( SCIPfreeSol(scip,&sol) );
        *result = SCIP_DIDNOTFIND;
        return SCIP_OKAY;
          }

          /* update the least we can expect to loose by rounding some other, future parent set to 1 */
          /* for future choices we just care about how much *more* is lost */
          heurdata->loss_ub[j] = heurdata->loss_ub[j] - SCIPgetSolVal(scip,NULL,heurdata->PaVars[j][heurdata->bestparents[j]]);
          assert( SCIPgetSolVal(scip,sol,heurdata->PaVars[j][heurdata->bestparents[j]]) == 0 );
          /* update which is the best parent set for j */
          heurdata->bestparents[j]++;
       }

    } while ( !current_bestparents_for_j_allowed );
    /* stopped at the best permissible parent set */
      }
   }

   if (PD_inPedigreeMode(scip)) {
      SCIP_Bool possible = TRUE;
      SCIP_CALL( PD_assignPedigreeVariables(scip, sol, heurdata, &possible) );
      if (possible == FALSE) {
         SCIP_CALL( SCIPfreeSol(scip,&sol) );
         *result = SCIP_DIDNOTFIND;
         return SCIP_OKAY;
      }
   }

   if ( heurdata->printsols )
   {
      fprintf(output,"START sink heuristic solution.\n");
      SCIP_CALL(SCIPprintSol(scip, sol, heurdata->file, FALSE));
      fprintf(output,"END sink heuristic solution.\n");
   }


#ifdef SCIP_DEBUG
   /* trysolFree clears sol so print it now */
   SCIP_CALL(SCIPprintSol(scip,  sol, NULL, FALSE));
#endif

   SCIP_CALL( SCIPtrySolFree(scip, &sol,
              FALSE, /* don't want violations to be displayed */
              TRUE,  /* do check bounds */
              FALSE, /* no need to check integrality */
              TRUE,  /* do check LP rows */
              &success) );

   if ( success ){
      *result = SCIP_FOUNDSOL;
      SCIPdebugMessage("ok\n");
   }
   else {
      *result = SCIP_DIDNOTFIND;
      SCIPdebugMessage("not ok\n");
   }
   return SCIP_OKAY;
}

/** creates the sinks primal heuristic and includes it in SCIP.
 *  @return SCIP_OKAy if the operation suceeded, or an appropriate error message otherwise.
 */
SCIP_RETCODE HS_includePrimal(
   SCIP*                 scip                /**< SCIP data structure */
   )
{
   SCIP_HEURDATA* heurdata;

   /* create sinks primal heuristic data */
   SCIP_CALL( SCIPallocMemory(scip, &heurdata) );

   /* include primal heuristic */
   SCIP_CALL( SCIPincludeHeur(scip, HEUR_NAME, HEUR_DESC, HEUR_DISPCHAR, HEUR_PRIORITY, HEUR_FREQ, HEUR_FREQOFS,
         HEUR_MAXDEPTH, HEUR_TIMING, HEUR_USESSUBSCIP,
         heurCopySinks,
         heurFreeSinks, heurInitSinks, heurExitSinks,
         heurInitsolSinks, heurExitsolSinks, heurExecSinks,
         heurdata) );

   /* add sinks primal heuristic parameters */
   /* TODO: (optional) add primal heuristic specific parameters with SCIPaddTypeParam() here */

   SCIP_CALL (SCIPaddBoolParam(
       scip,
       "heuristics/sinks/printsols",
       "whether to print *every* BN found by sink heuristic (in SCIP solution format)",
       &heurdata->printsols,
       FALSE,
       FALSE,
       NULL,NULL) );

   SCIP_CALL( SCIPaddStringParam(
       scip,
       "heuristics/sinks/filesols",
       "where to print solutions found by sink heuristic",
       NULL,
       FALSE,
       "",
       NULL, NULL) );

   return SCIP_OKAY;
}
