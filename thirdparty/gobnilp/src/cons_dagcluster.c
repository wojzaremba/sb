/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *   GOBNILP Copyright (C) 2012 James Cussens, Mark Barlett              *
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
 *  Implements a constraint for preventing cycles in the graph.
 *
 *  The constraint states that for any group of k nodes, at least one node must have no parents in
 *  that cluster.  This generalises such that there must also be at least two nodes with at most one parent,
 *  at least three with at most two parents and so on.
 *
 *  As there are exponentially many of these constraints, it is implemented as a series of cutting planes.
 *
 *  In the price-and-cut loop, cluster cutting planes are sought first (due to high SEPAPRIORITY), then other separators
 *  e.g. Gomory may kick in. Once the price-and-cut loop is finished, cluster cutting planes are looked for again
 *  (due to high ENFOPRIORITY). This may succeed since eg Gomory cuts will have 'moved' the LP solution.
 *  If one is found then LP solving is re-invoked (p35 Achterberg) which may lead to yet more cluster
 *  cutting planes.
 */

// This file was created by editing the constraint handler template file in SCIP

#include <string.h>
#include "cons_dagcluster.h"
#include "scip/scipdefplugins.h"

#define DEFAULT_KMAX 1
#define DEFAULT_KMAX_ROOT 1

#define EPSILON 0.0001
#define min(A,B) ((A) > (B) ? (B) : (A))

/* for SCIP 3.0.0 */
#define consGetVarsDagcluster NULL
#define consGetNVarsDagcluster NULL

// Constraint handler properties
#define CONSHDLR_NAME       "dagcluster"               /**< Name of the constraint handler. */
#define CONSHDLR_DESC            "DAG cluster-based acyclicity constraint handler" /**< Deascription of the constraint handler. */
#define CONSHDLR_SEPAPRIORITY      100000000           /**< priority of the constraint handler for separation */
#define CONSHDLR_ENFOPRIORITY       -90                /**< priority of the constraint handler for constraint enforcing,  (JC: -ve so only deal with graphs) */
#define CONSHDLR_CHECKPRIORITY      -90                /**< priority of the constraint handler for checking feasibility,  (JC: -ve so only deal with graphs) */
#define CONSHDLR_SEPAFREQ                  1           /**< frequency for separating cuts; zero means to separate only in the root node */
#define CONSHDLR_PROPFREQ                  1           /**< frequency for propagating domains; zero means only preprocessing propagation */
#define CONSHDLR_EAGERFREQ               100           /**< frequency for using all instead of only the useful constraints in separation,
                                                             propagation and enforcement, -1 for no eager evaluations, 0 for first only, JC: irrelevant */
#define CONSHDLR_MAXPREROUNDS             -1           /**< maximal number of presolving rounds the constraint handler participates in (-1: no limit), JC irrelevant */
#define CONSHDLR_DELAYSEPA             FALSE           /**< should separation method be delayed, if other separators found cuts?, */
#define CONSHDLR_DELAYPROP             FALSE           /**< should propagation method be delayed, if other propagators found reductions?, */
#define CONSHDLR_DELAYPRESOL           FALSE           /**< should presolving method be delayed, if other presolvers found reductions?, JC: irrelevant */
#define CONSHDLR_NEEDSCONS              TRUE           /**< should the constraint handler be skipped, if no constraints are available?, JC: there will be a constraint! */
#define CONSHDLR_PROP_TIMING       SCIP_PROPTIMING_BEFORELP /**< propagation timing mask of the constraint handler, */


// Data structures

/** constraint data for dagcluster constraints */
struct SCIP_ConsData
{
   int          n;            /* number of variables */
   int*          nParentSets;          /* nParentSets[i] is the number of  parent sets for variable i */
   int**        nParents;             /* nParents[i][k] is the number of  parents in the kth parent set for variable i */
   int***       ParentSets;           /* ParentSets[i][k][l] is the lth parent in the kth parent set of ith variable */
   SCIP_VAR*** PaVars;                /* PaVars[i][k] = 1 if kth parent set of ith variable is selected */
   SCIP_Bool**  parent_min;
   SCIP_Bool**  parent_max;
   SCIP_Bool**  ancestor_min;
   SCIP_Bool**  ancestor_max;
   int          biggest_nParentSets;  /* max_{i} nParentSets[i] */
   /* int*         nCandidateParents;    /\* nCandidateParents[i] is the number of other variables which might be parents of i *\/ */
   /* int**        CandidateParents;     /\* CandidateParents[i][l] is the lth possible parents for i *\/ */
};

/** constraint handler data */
struct SCIP_ConshdlrData
{
   int kmax;
   int kmaxroot;
};

struct Dagcluster_AuxIPData
{
   SCIP*     subscip;          /* sub MIP for finding good clusters for cutting planes */
   SCIP_VAR***     family;        /* family[i][k] = 1 if kth parent set of ith variable is one of those in cluster */
   SCIP_VAR**      incluster;        /* incluster[i] if variable i in cluster */
   SCIP_VAR*             kvar;                 /* lower bound on number of parents to be in cluster for family variable to be set */
   SCIP_CONS***          clausecons;           /* clausecons[i][k] is the constraint  "if family[i][k]=1 then incluster[i]=1" */
   SCIP_CONS***          overlapcons;          /* overlapcons[i][k] is the constraint  "if family[i][k]=1 then \sum_{u \in W} >= kvar" */
   /*SCIP_CONS**          parentscons;  */        /* parentscons[i] is the constraint  "if incluster[i] then one of i's possible parents also incluster */
   SCIP_CONS*            ck_cons;
};
typedef struct Dagcluster_AuxIPData DAGCLUSTER_AUXIPDATA;

/* Checks an integer solution to see whether it contains any cycles. */
static
SCIP_RETCODE
check_for_cycles(
   SCIP*          scip,
   SCIP_CONSHDLR* conshdlr,
   SCIP_CONS**    conss,
   int            nconss,
   SCIP_SOL*      sol,
   SCIP_RESULT*   result) {

   int c, i, k;

   assert( scip != NULL );
   assert( conshdlr != NULL );
   assert( strcmp(SCIPconshdlrGetName(conshdlr), CONSHDLR_NAME) == 0 );
   assert( conss != NULL );
   assert( result != NULL );

   *result = SCIP_FEASIBLE;

   // loop through all constraints (only expect there to actually be one)
   for (c = 0; (c < nconss) && (*result != SCIP_INFEASIBLE) ; ++c) {
      SCIP_CONSDATA* consdata;
      SCIP_CONS* cons;
      int num_nodes;

      int*     num_parents_of;
      int**    parents_of;

      cons = conss[c];
      assert( cons != NULL );
      SCIPdebugMessage("checking dag cluster constraint <%s>.\n", SCIPconsGetName(cons));

      // get constraint data
      consdata = SCIPconsGetData(cons);
      assert( consdata != NULL );
      num_nodes = consdata->n;

      // extract the parent sets which are selected
      // check there is one parent set per node as we go
      SCIP_CALL( SCIPallocMemoryArray(scip, &num_parents_of, num_nodes) );
      SCIP_CALL( SCIPallocMemoryArray(scip, &parents_of, num_nodes) );

      for (i = 0; (i < num_nodes) && (*result != SCIP_INFEASIBLE) ; ++i)
      {
         int sum = 0;
         for (k = 0; k < consdata->nParentSets[i]; ++k)
    {
       assert( SCIPisFeasIntegral(scip, SCIPgetSolVal(scip, sol, consdata->PaVars[i][k])) );
       if (SCIPisGT(scip, SCIPgetSolVal(scip, sol, consdata->PaVars[i][k]), 0.5))
       {
               sum += 1;
               num_parents_of[i] = consdata->nParents[i][k];
               parents_of[i] = consdata->ParentSets[i][k];
            }
         }
         //SCIPdebugMessage("checking node %d - %d parent set(s) selected\n", i, sum);
         if (sum != 1)
            *result = SCIP_INFEASIBLE;
      }
      // do the actual acyclicity check
      if (*result != SCIP_INFEASIBLE) {
         int made_progress = 1;
         int* dealt_with;
         //SCIPdebugMessage("checking for cycles\n");
         SCIP_CALL( SCIPallocClearMemoryArray(scip, &dealt_with, num_nodes) );
         while (made_progress) {
            made_progress = 0;
            for (i = 0; i < num_nodes; ++i)
               if (!dealt_with[i]) {
                  int all_parents_dealt_with = 1;
                  for (k = 0; k < num_parents_of[i]; ++k)
                     all_parents_dealt_with = all_parents_dealt_with && dealt_with[parents_of[i][k]];
                  if (all_parents_dealt_with) {
                     dealt_with[i] = 1;
                     made_progress = 1;
                  }
               }
         }
         for (i = 0; i < num_nodes; ++i)
            if (!dealt_with[i]) {
               *result = SCIP_INFEASIBLE;
               //SCIPdebugMessage("cycle found\n");
            }
         SCIPfreeMemoryArray(scip, &dealt_with);
      }

      SCIPfreeMemoryArray(scip, &num_parents_of);
      SCIPfreeMemoryArray(scip, &parents_of);

   }

   return SCIP_OKAY;
}



static
SCIP_RETCODE transitive_closure(
   SCIP_Bool** parent,
   SCIP_Bool** ancestor,
   int n
   )
{
   int i,j,k;
   SCIP_Bool fixpoint = FALSE;

   for ( i = 0; i < n; ++i)
      for ( j = 0; j < n; ++j)
    ancestor[i][j] = parent[i][j] ? TRUE : FALSE;

   while ( !fixpoint )
   {
      fixpoint = TRUE;

      for ( i = 0; i < n; ++i)
      {
    for ( j = 0; j < n; ++j)
    {
       if ( !ancestor[i][j] )
       {
          for ( k = 0; k < n; ++k)
          {
        if ( ancestor[i][k] && ancestor[k][j] )
        {
           ancestor[i][j] = TRUE;
           fixpoint = FALSE;
           break;
        }
          }
       }
    }
      }
   }
   return SCIP_OKAY;
}




static
SCIP_RETCODE AuxIPDataFree(
   SCIP*                 scip,               /**< SCIP data structure */
   DAGCLUSTER_AUXIPDATA*  auxipdata,           /**< pointer of data structure */
   SCIP_CONSDATA*  consdata        /**< constraint data */
   )
{
   int i;

   if ( auxipdata->subscip != NULL )
   {
      /*SCIP_CALL( SCIPprintOrigProblem(auxipdata->subscip, NULL, NULL, TRUE) );*/

      SCIP_CALL( SCIPfree(&(auxipdata->subscip)) );
   }
   for ( i = 0 ; i < consdata->n ; ++i)
   {
      SCIPfreeMemoryArray(scip, &(auxipdata->family[i]));
      SCIPfreeMemoryArray(scip, &(auxipdata->clausecons[i]));
      SCIPfreeMemoryArray(scip, &(auxipdata->overlapcons[i]));
   }
   SCIPfreeMemoryArray(scip, &(auxipdata->family));
   SCIPfreeMemoryArray(scip, &(auxipdata->clausecons));
   SCIPfreeMemoryArray(scip, &(auxipdata->overlapcons));
   /*SCIPfreeMemoryArray(scip, &(auxipdata->parentscons));*/
   SCIPfreeMemoryArray(scip, &(auxipdata->incluster));

   SCIPfreeMemory(scip, &auxipdata);
   auxipdata = NULL;

   return SCIP_OKAY;
}


/*
 main routine for
 looking for cutting planes separating an arbitrary primal solution. Call from: CONSSEPASOL (during price-and-cut loop)
 looking for cutting planes separating the current LP solution. Call from: CONSSEPALP (during price-and-cut loop)
 looking for cutting planes separating the current LP solution. Call from CONSENFOLP (after price-and-cut loop)

For CONSENFOLP, CONSSEPASOL and CONSSEPALP a search for the best cutting plane is performed.

The number of found cutting planes is recorded in *nGen. A positive value indicates that the current solution is infeasible.
 */


/* 1-cluster separator */
/* static */
/* SCIP_RETCODE DagClusterSeparate1( */
/*    SCIP*     scip, */
/*    SCIP_CONSDATA*  consdata,       /\* constraint data *\/ */
/*    SCIP_SOL*       sol,         /\* solution to be separated *\/ */
/*    int*   nGen,                               /\* *nGen is number of cutting planes found *\/ */
/*    SCIP_CONSHDLR* conshdlr */
/* ) */
/* { */


/*    int i,k,l; */
/*    SCIP_STATUS status; */
/*    int s,nsols; */
/*    SCIP_SOL** subscip_sols; */
/*    SCIP_SOL* subscip_sol; */

/*    char consname[SCIP_MAXSTRLEN]; */
/*    char varname[SCIP_MAXSTRLEN]; */

/*    SCIP_ROW* cut; */
/*    SCIP_Real lhs; */
/*    SCIP_Real val; */
/*    SCIP_Bool include_in_cut; */
/*    int n_included; */
/*    int n_excluded; */
/*    SCIP_VAR** included; */
/*    SCIP_VAR** excluded; */
/*    /\*int cluster_size;*\/ */


/*    SCIP_VAR** clausevars; */
/*    int nvars; */

/*    DAGCLUSTER_AUXIPDATA* auxipdata;          /\* data for subscip *\/ */

/*    char cluster_name[SCIP_MAXSTRLEN]; */
/*    char tmp_str[SCIP_MAXSTRLEN]; */


/*    /\* const SCIP_Real unit_cost = 0.0; *\/ */
/*    /\* /\\* cost of I(W->u) having high value in LP solution *\\/ *\/ */
/*    /\* const SCIP_Real alpha = 10.0; *\/ */
/*    /\* /\\* reward for I(W->u) having high objective coefficient (for objective parallelism ) *\\/ *\/ */
/*    /\* const SCIP_Real beta = 0.0; *\/ */
/*    /\* /\\* how much below 1 cutting plane must be (for numerator of efficacy and correctness *\\/ *\/ */
/*    /\* const SCIP_Real epsilon = 0.005; *\/ */
/*    /\* SCIP_Real coeff; *\/ */
/*    /\* SCIP_CONS* bound_cons; *\/ */

/*    /\*SCIP_CALL( SCIPprintSol(scip,sol,NULL,FALSE) );*\/ */

/*    SCIP_CALL( SCIPallocMemoryArray(scip, &included, consdata->biggest_nParentSets) ); */
/*    SCIP_CALL( SCIPallocMemoryArray(scip, &excluded, consdata->biggest_nParentSets) ); */

/*    /\* allocate temporary memory for building clausal constraints *\/ */

/*    SCIP_CALL( SCIPallocMemoryArray(scip, &clausevars, (consdata->n)+1) ); */

/*    /\* create and initialise auxiliary IP data structure *\/ */

/*    SCIP_CALL(SCIPallocMemory(scip, &auxipdata)); */
/*    auxipdata->subscip = NULL; */
/*    auxipdata->family = NULL; */
/*    auxipdata->incluster = NULL; */
/*    auxipdata->kvar = NULL; */
/*    auxipdata->clausecons = NULL; */
/*    auxipdata->overlapcons = NULL; */
/*    /\*auxipdata->parentscons = NULL;*\/ */
/*    auxipdata->ck_cons = NULL; */

/*    /\* allocate temporary memory for subscip elements *\/ */

/*    SCIP_CALL(SCIPallocMemoryArray(scip, &(auxipdata->family), consdata->n)); */
/*    SCIP_CALL(SCIPallocMemoryArray(scip, &(auxipdata->incluster), consdata->n)); */
/*    SCIP_CALL(SCIPallocMemoryArray(scip, &(auxipdata->clausecons), consdata->n)); */
/*    SCIP_CALL(SCIPallocMemoryArray(scip, &(auxipdata->overlapcons), consdata->n)); */
/*    /\*SCIP_CALL(SCIPallocMemoryArray(scip, &(auxipdata->parentscons), consdata->n));*\/ */

/*    for ( i = 0 ; i < consdata->n ; ++i) */
/*    { */
/*       SCIP_CALL(SCIPallocMemoryArray(scip, &(auxipdata->family[i]), consdata->nParentSets[i])); */
/*       SCIP_CALL(SCIPallocMemoryArray(scip, &(auxipdata->clausecons[i]), consdata->nParentSets[i])); */
/*       SCIP_CALL(SCIPallocMemoryArray(scip, &(auxipdata->overlapcons[i]), consdata->nParentSets[i])); */
/*    } */

/*    /\* initialize allocated data structures *\/ */

/*    BMSclearMemoryArray(auxipdata->incluster, consdata->n); */
/*    for ( i = 0 ; i < consdata->n ; ++i) */
/*    { */
/*       BMSclearMemoryArray(auxipdata->family[i], consdata->nParentSets[i]); */
/*       BMSclearMemoryArray(auxipdata->clausecons[i], consdata->nParentSets[i]); */
/*       BMSclearMemoryArray(auxipdata->overlapcons[i], consdata->nParentSets[i]); */
/*    } */

/*    /\* create and initialise subscip *\/ */

/*    SCIP_CALL( SCIPcreate(&(auxipdata->subscip)) ); */


/*    SCIP_CALL( SCIPincludeDefaultPlugins(auxipdata->subscip) ); */

/*    SCIP_CALL( SCIPcreateProb(auxipdata->subscip, "DAG cluster separating MIP", NULL, NULL , NULL , NULL , NULL , NULL , NULL) ); */

/*    SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "display/verblevel", 0) ); */
/*    SCIP_CALL( SCIPsetCharParam(auxipdata->subscip, "nodeselection/childsel", 'd') ); */
/*    SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "limits/maxsol", 100000) ); */
/*    SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "limits/maxorigsol", 2000) ); */
/*    SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "nodeselection/dfs/stdpriority",536870911 ) ); */
/*    SCIP_CALL( SCIPsetHeuristics(auxipdata->subscip,SCIP_PARAMSETTING_OFF,TRUE) ); */

/*    /\*SCIP_CALL( SCIPsetRealParam(auxipdata->subscip, "limits/time",0.1 ) );*\/ */

/*    SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "lp/solvefreq", 1) ); */

/*    SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/closecuts/freq", -1) ); */
/*    SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/cgmip/freq", -1) ); */
/*    SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/cmir/freq", -1) ); */
/*    SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/flowcover/freq", -1) ); */
/*    SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/impliedbounds/freq", -1) ); */
/*    SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/intobj/freq", -1) ); */
/*    SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/mcf/freq", -1) ); */
/*    SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/oddcycle/freq", -1) ); */
/*    SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/rapidlearning/freq", -1) ); */
/*    SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/strongcg/freq", -1) ); */
/*    SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/zerohalf/freq", -1) ); */
/*    SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/clique/freq", -1) ); */
   
/*    /\* experimental *\/ */
/*    /\*SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/gomory/freq", -1) );*\/ */

/*    /\* forbid recursive call of heuristics solving subMIPs *\/ */
/*    SCIP_CALL(SCIPsetIntParam(auxipdata->subscip, "heuristics/rins/freq", -1)); */
/*    SCIP_CALL(SCIPsetIntParam(auxipdata->subscip, "heuristics/rens/freq", -1)); */
/*    SCIP_CALL(SCIPsetIntParam(auxipdata->subscip, "heuristics/localbranching/freq", -1)); */
/*    SCIP_CALL(SCIPsetIntParam(auxipdata->subscip, "heuristics/crossover/freq", -1)); */

/*    SCIP_CALL(SCIPsetBoolParam(auxipdata->subscip, "constraints/logicor/negatedclique", FALSE)); */


/*    /\* create subscip family variables for each main-problem family variable that is positive in the current solution *\/ */
/*    /\* This solution will typically be the solution to the linear relaxation *\/ */
/*    /\* use the same name for both *\/ */

/*    for ( i = 0 ; i < consdata->n ; ++i) */
/*    { */
/*       for ( k = 0 ; k < consdata->nParentSets[i]; ++k) */
/*       { */
/* 	 val = SCIPgetSolVal(scip, sol, consdata->PaVars[i][k]); */
/* 	 if ( SCIPisPositive(scip,val) ) */
/* 	 { */
/* 	    SCIP_CALL( SCIPcreateVar(auxipdata->subscip, &(auxipdata->family[i][k]), SCIPvarGetName(consdata->PaVars[i][k]), 0.0, 1.0, val, SCIP_VARTYPE_BINARY, TRUE, FALSE, NULL, NULL, NULL, NULL, NULL) ); */
/* 	    SCIP_CALL( SCIPaddVar(auxipdata->subscip, auxipdata->family[i][k]) ); */
/* 	 } */
/* 	 else */
/* 	    /\* calls to BMSclearMemoryArray(auxipdata->family[i], consdata->nParentSets[i]) should have made a NULL pointer *\/ */
/* 	    assert( auxipdata->family[i][k] ==  NULL ); */
/*       } */
/*    } */

/*    /\* create variables to identify clusters *\/ */

/*    for ( i = 0 ; i < consdata->n ; ++i) */
/*    { */
/*       (void) SCIPsnprintf(varname, SCIP_MAXSTRLEN, "incluster#%d", i); */
/*       SCIP_CALL( SCIPcreateVar(auxipdata->subscip, &(auxipdata->incluster[i]), varname, 0.0, 1.0, 0.0, SCIP_VARTYPE_BINARY, TRUE, FALSE, NULL, NULL, NULL, NULL, NULL) ); */
/*       SCIP_CALL( SCIPaddVar(auxipdata->subscip, auxipdata->incluster[i]) ); */
/*       SCIP_CALL( SCIPchgVarBranchPriority(auxipdata->subscip, auxipdata->incluster[i], 10) ); */
/*    } */

/*    /\* for each family variable, if child is in the cluster and none of its parents are then it is included in the sum *\/ */
   
/*    for ( i = 0 ; i < consdata->n ; ++i) */
/*    { */
/*       for ( k = 0 ; k < consdata->nParentSets[i] ; ++k) */
/*       { */
/* 	 if ( auxipdata->family[i][k] !=  NULL ) */
/* 	 { */
/* 	    (void) SCIPsnprintf(consname, SCIP_MAXSTRLEN, "clause#%d#%d", i, k); */
/* 	    SCIP_CALL( SCIPgetNegatedVar(auxipdata->subscip,auxipdata->incluster[i],&(clausevars[0])) ); */
/* 	    clausevars[1] = auxipdata->family[i][k]; */
/* 	    nvars = 2; */
/* 	    for (l = 0; l < consdata->nParents[i][k]; ++l) */
/* 	       clausevars[nvars++] = auxipdata->incluster[consdata->ParentSets[i][k][l]]; */
/* 	    SCIP_CALL( SCIPcreateConsLogicor(auxipdata->subscip,&(auxipdata->clausecons[i][k]),consname,nvars,clausevars, */
/* 					     TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE) ); */
/* 	    SCIP_CALL( SCIPaddCons(auxipdata->subscip, auxipdata->clausecons[i][k]) ); */
/* 	 } */
/* 	 else */
/* 	    assert( auxipdata->clausecons[i][k] == NULL ); */
/*       } */
/*    } */

/*    /\* must remove LP sol (by epsilon) *\/ */

/*    /\* SCIP_CALL( SCIPcreateConsLinear(auxipdata->subscip, &bound_cons, "bound_constraint", 0, NULL, NULL, *\/ */
/*    /\* 				   -SCIPinfinity(scip), 1-epsilon,  *\/ */
/*    /\* 				   TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE) ); *\/ */
/*    /\* for ( i = 0 ; i < consdata->n ; ++i) *\/ */
/*    /\* { *\/ */
/*    /\*    for ( k = 0 ; k < consdata->nParentSets[i]; ++k) *\/ */
/*    /\*    { *\/ */
/*    /\* 	 val = SCIPgetSolVal(scip, sol, consdata->PaVars[i][k]); *\/ */
/*    /\*       SCIP_CALL( SCIPaddCoefLinear(auxipdata->subscip, bound_cons, auxipdata->family[i][k], val) ); *\/ */
/*    /\*    } *\/ */
/*    /\* } *\/ */
/*    /\* SCIP_CALL( SCIPaddCons(auxipdata->subscip, bound_cons) ); *\/ */
/*    /\*SCIP_CALL( SCIPprintCons(auxipdata->subscip,  bound_cons, NULL) );*\/ */

/*    /\* 2 <= |C|  <= inf : for the added cut to make sense *\/ */

/*    SCIP_CALL( SCIPcreateConsLinear(auxipdata->subscip, &(auxipdata->ck_cons), "ck_constraint", 0, NULL, NULL, */
/* 				   2, SCIPinfinity(scip),  */
/* 				   TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE) ); */
/*    for ( i = 0 ; i < consdata->n ; ++i) */
/*    { */
/*       SCIP_CALL( SCIPaddCoefLinear(auxipdata->subscip, auxipdata->ck_cons, auxipdata->incluster[i], 1) ); */
/*    } */
/*    SCIP_CALL( SCIPaddCons(auxipdata->subscip, auxipdata->ck_cons) ); */

/*    /\* all constraints posted - free temporary memory *\/ */

/*    SCIPfreeMemoryArray(scip, &clausevars); */

/*    SCIP_CALL_ABORT( SCIPsetObjsense(auxipdata->subscip, SCIP_OBJSENSE_MINIMIZE) ); */

/*    /\*SCIP_CALL(SCIPwriteOrigProblem(auxipdata->subscip,NULL,NULL,FALSE) );*\/ */

/*    /\* must be below 1 to be a cut *\/ */
/*    SCIP_CALL( SCIPsetObjlimit(auxipdata->subscip,1) ); */

/*    SCIP_CALL( SCIPsolve(auxipdata->subscip) ); */

/*    status = SCIPgetStatus(auxipdata->subscip); */
/*    /\*SCIP_CALL(SCIPprintStatus(auxipdata->subscip,NULL));*\/ */

/*    if ( status == SCIP_STATUS_USERINTERRUPT || status == SCIP_STATUS_INFEASIBLE || status == SCIP_STATUS_INFORUNBD ) */
/*    { */
/*       /\* print out LP relaxation that could not be separated *\/ */
/*       /\*SCIP_CALL( SCIPwriteMIP(scip,"foo",FALSE,TRUE) ); */
/*       SCIP_CALL( SCIPprintSol(scip,NULL,NULL,FALSE) ); */
/*       exit(1);*\/ */
/*       /\*printf("infeasible.\n"); */
/*       SCIP_CALL( SCIPprintSol(scip,NULL,NULL,FALSE) );*\/ */
/*       SCIPdebugMessage("could not find a cluster cut.\n"); */
/*       SCIP_CALL(AuxIPDataFree(scip, auxipdata, consdata)); */
/*       SCIPfreeMemoryArray(scip, &included); */
/*       SCIPfreeMemoryArray(scip, &excluded); */

/*       return SCIP_OKAY; */
/*    } */

/*    /\* if there are feasible solutions but the best has objective value not better that */
/*       1, then we have not found a cutting plane. */
/*       This code snippet from Timo Berthold */
/*    *\/ */
/*    nsols = SCIPgetNSols(auxipdata->subscip); */
/*    if ( nsols > 0 && SCIPisFeasGE(auxipdata->subscip, SCIPgetSolOrigObj(auxipdata->subscip,SCIPgetBestSol(auxipdata->subscip)), 1.0 ) ) */
/*       { */
/*        /\*printf("obj value too low.\n"); */
/*        SCIP_CALL( SCIPprintSol(scip,NULL,NULL,FALSE) ); */
/*        *\/ */
/*        SCIP_CALL(AuxIPDataFree(scip, auxipdata, consdata)); */
/*        SCIPfreeMemoryArray(scip, &included); */
/*        SCIPfreeMemoryArray(scip, &excluded); */

/*        return SCIP_OKAY; */
/*       } */

/*    if ( status != SCIP_STATUS_SOLLIMIT && status != SCIP_STATUS_GAPLIMIT && status != SCIP_STATUS_OPTIMAL && status != SCIP_STATUS_NODELIMIT  && status != SCIP_STATUS_TIMELIMIT) */
/*    { */
/*       SCIPerrorMessage("Solution of subscip for DAG cluster separation returned with invalid status %d.\n", status); */
/*       SCIP_CALL(AuxIPDataFree(scip, auxipdata, consdata)); */
/*       SCIPfreeMemoryArray(scip, &included); */
/*       SCIPfreeMemoryArray(scip, &excluded); */

/*       return SCIP_ERROR; */
/*    } */

/*    /\* To get here a cutting plane must have been found *\/ */

/*    subscip_sols = SCIPgetSols(auxipdata->subscip); */

/*    for (s = 0; s <  nsols; ++s) */
/*    { */

/*       subscip_sol = subscip_sols[s]; */

/*       /\*SCIP_CALL( SCIPprintSol(auxipdata->subscip,subscip_sol,NULL,FALSE) );*\/ */

/*       lhs = 1; */

/*       /\* keep deprecated function for 2.1 compatibility *\/ */
/*       (void) SCIPsnprintf(cluster_name, SCIP_MAXSTRLEN, "clustercut("); */
/*       for ( i = 0 ; i < consdata->n ; ++i) */
/* 	 if ( SCIPisPositive(scip, SCIPgetSolVal(auxipdata->subscip, subscip_sol, auxipdata->incluster[i])) ) */
/* 	 { */
/* 	    (void) SCIPsnprintf(tmp_str, SCIP_MAXSTRLEN, "%d,", i); */
/* 	    (void) strcat(cluster_name, tmp_str); */
/* 	 } */
/*       (void) strcat(cluster_name, ")"); */


/*       SCIP_CALL( SCIPcreateEmptyRow(scip, &cut, cluster_name, lhs, SCIPinfinity(scip), */
/* 				    FALSE, FALSE, TRUE) ); */
/*       /\*SCIP_CALL( SCIPcreateEmptyRow(scip, &cut, conshdlr, "clustercut", -SCIPinfinity(scip), 0, */
/* 	FALSE, FALSE, TRUE) ); */
/*       *\/ */
/*       for ( i = 0 ; i < consdata->n ; ++i) */
/*       { */
/* 	 /\* if child i is not in the cluster then no need to consider its family variables *\/ */
/* 	 if ( SCIPisZero(scip, SCIPgetSolVal(auxipdata->subscip, subscip_sol, auxipdata->incluster[i])) ) */
/* 	    continue; */

/* 	 n_included = 0; */
/* 	 n_excluded = 0; */
/* 	 /\* include all parents sets with no parents in the cluster *\/ */
/* 	 for ( k = 0;  k < consdata->nParentSets[i]; ++k) */
/* 	 { */
/* 	    include_in_cut = TRUE; */
/* 	    for (l = 0; l < consdata->nParents[i][k]; ++l) */
/* 	       if ( SCIPisPositive(scip, SCIPgetSolVal(auxipdata->subscip, subscip_sol, auxipdata->incluster[consdata->ParentSets[i][k][l]])) ) */
/* 	       { */
/* 		  include_in_cut = FALSE; */
/* 		  break; */
/* 	       } */

/* 	    if ( include_in_cut ) */
/* 	       /\*SCIP_CALL( SCIPaddVarToRow(scip, cut, consdata->PaVars[i][k], 1.0) );*\/ */
/* 	       included[n_included++] = consdata->PaVars[i][k]; */
/* 	    else */
/* 	       excluded[n_excluded++] = consdata->PaVars[i][k]; */
/* 	 } */
/* 	 /\* use convexity constraint to reduce variables in the cut *\/ */
/* 	 if( n_included < consdata->nParentSets[i]  / 2 ) */
/* 	    /\* not too many variables for cut, so add as normal *\/ */
/* 	    SCIP_CALL( SCIPaddVarsToRowSameCoef(scip, cut, n_included, included, 1.0) ); */
/* 	 else */
/* 	 { */
/* 	    SCIP_CALL( SCIPaddVarsToRowSameCoef(scip, cut, n_excluded, excluded, -1.0) ); */
/* 	    lhs--; */
/* 	 } */
/*       } */


/*       assert( SCIPisIntegral(scip,lhs) ); */
/*       /\*assert( SCIPisGE(scip,rhs,1.0) ); *\/ */
/*       SCIP_CALL (SCIPchgRowLhs(scip, cut, lhs) ); */
/*       SCIP_CALL( SCIPaddCut(scip, sol, cut, FALSE) ); */
/*       /\*SCIP_CALL( SCIPaddPoolCut(scip, cut) );*\/ */
/*       (*nGen)++; */
/*       /\*printf("cluster size %d\n", cluster_size);*\/ */
/*       /\*SCIP_CALL( SCIPprintRow(scip, cut, NULL));*\/ */
/*       SCIP_CALL( SCIPreleaseRow(scip, &cut)); */
/*    } */

/*    SCIPdebugMessage("added %d cluster cuts.\n", *nGen); */

/*    SCIPfreeMemoryArray(scip, &included); */
/*    SCIPfreeMemoryArray(scip, &excluded); */

/*    SCIP_CALL(AuxIPDataFree(scip, auxipdata, consdata)); */
/*    return SCIP_OKAY; */
/* } */

static
SCIP_RETCODE DagClusterSeparate(
   SCIP*     scip,
   SCIP_CONSDATA*  consdata,       /* constraint data */
   SCIP_SOL*       sol,         /* solution to be separated */
   int*   nGen,                               /* *nGen is number of cutting planes found */
   int k_lb,                                 /* lowerbound on 'k' values , always positive */
   int k_ub,                                 /* upperbound on 'k' values */
   SCIP_CONSHDLR* conshdlr
)
{


   int i,k,l;
   SCIP_STATUS status;
   int s,nsols;
   SCIP_SOL** subscip_sols;
   SCIP_SOL* subscip_sol;

   char consname[SCIP_MAXSTRLEN];
   char varname[SCIP_MAXSTRLEN];

   SCIP_ROW* cut;
   SCIP_Real rhs, kval;
   SCIP_Real val;
   int overlap;
   SCIP_Bool include_in_cut;
   int n_included;
   int n_excluded;
   SCIP_VAR** included;
   SCIP_VAR** excluded;
   /*int cluster_size;*/


   SCIP_VAR** clausevars;
   int nvars;

   DAGCLUSTER_AUXIPDATA* auxipdata;          /* data for subscip */

   char cluster_name[SCIP_MAXSTRLEN];
   char tmp_str[SCIP_MAXSTRLEN];


   /* SCIP_Bool flag; */
   /* SCIP_Longint sparse_nsols; */

   /* SCIP_VAR** sparse_vars; */
   /* int sparse_nvars; */
   /* SCIP_SPARSESOL** sparse_sols; */
   /* int sparse_nsols; */
   /* SCIP_SPARSESOL* sparsesol; */

   /* check called with sensible 'k' values */

   assert( k_lb > 0 );
   assert( k_ub >= k_lb );

   SCIP_CALL( SCIPallocMemoryArray(scip, &included, consdata->biggest_nParentSets) );
   SCIP_CALL( SCIPallocMemoryArray(scip, &excluded, consdata->biggest_nParentSets) );


   /* allocate temporary memory for building clausal constraints */

   SCIP_CALL( SCIPallocMemoryArray(scip, &clausevars, (consdata->n)+1) );

   /* create and initialise auxiliary IP data structure */

   SCIP_CALL(SCIPallocMemory(scip, &auxipdata));
   auxipdata->subscip = NULL;
   auxipdata->family = NULL;
   auxipdata->incluster = NULL;
   auxipdata->kvar = NULL;
   auxipdata->clausecons = NULL;
   auxipdata->overlapcons = NULL;
   /*auxipdata->parentscons = NULL;*/
   auxipdata->ck_cons = NULL;

   /* allocate temporary memory for subscip elements */

   SCIP_CALL(SCIPallocMemoryArray(scip, &(auxipdata->family), consdata->n));
   SCIP_CALL(SCIPallocMemoryArray(scip, &(auxipdata->incluster), consdata->n));
   SCIP_CALL(SCIPallocMemoryArray(scip, &(auxipdata->clausecons), consdata->n));
   SCIP_CALL(SCIPallocMemoryArray(scip, &(auxipdata->overlapcons), consdata->n));
   /*SCIP_CALL(SCIPallocMemoryArray(scip, &(auxipdata->parentscons), consdata->n));*/

   for ( i = 0 ; i < consdata->n ; ++i)
   {
      SCIP_CALL(SCIPallocMemoryArray(scip, &(auxipdata->family[i]), consdata->nParentSets[i]));
      SCIP_CALL(SCIPallocMemoryArray(scip, &(auxipdata->clausecons[i]), consdata->nParentSets[i]));
      SCIP_CALL(SCIPallocMemoryArray(scip, &(auxipdata->overlapcons[i]), consdata->nParentSets[i]));
   }

   /* initialize allocated data structures */

   BMSclearMemoryArray(auxipdata->incluster, consdata->n);
   for ( i = 0 ; i < consdata->n ; ++i)
   {
      BMSclearMemoryArray(auxipdata->family[i], consdata->nParentSets[i]);
      BMSclearMemoryArray(auxipdata->clausecons[i], consdata->nParentSets[i]);
      BMSclearMemoryArray(auxipdata->overlapcons[i], consdata->nParentSets[i]);
   }

   /* create and initialise subscip */

   SCIP_CALL( SCIPcreate(&(auxipdata->subscip)) );


   SCIP_CALL( SCIPincludeDefaultPlugins(auxipdata->subscip) );

   SCIP_CALL( SCIPcreateProb(auxipdata->subscip, "DAG cluster separating MIP", NULL, NULL , NULL , NULL , NULL , NULL , NULL) );

   SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "display/verblevel", 0) );
   SCIP_CALL( SCIPsetCharParam(auxipdata->subscip, "nodeselection/childsel", 'd') );
   SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "limits/maxsol", 100000) ); 
   SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "limits/maxorigsol", 2000) );
   SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "nodeselection/dfs/stdpriority",536870911 ) );
   SCIP_CALL( SCIPsetHeuristics(auxipdata->subscip,SCIP_PARAMSETTING_OFF,TRUE) );

   /*SCIP_CALL( SCIPsetRealParam(auxipdata->subscip, "limits/time",0.1 ) );*/

   SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "lp/solvefreq", 1) );

   SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/closecuts/freq", -1) );
   SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/cgmip/freq", -1) );
   SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/cmir/freq", -1) );
   SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/flowcover/freq", -1) );
   SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/impliedbounds/freq", -1) );
   SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/intobj/freq", -1) );
   SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/mcf/freq", -1) );
   SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/oddcycle/freq", -1) );
   SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/rapidlearning/freq", -1) );
   SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/strongcg/freq", -1) );
   SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/zerohalf/freq", -1) );
   SCIP_CALL( SCIPsetIntParam(auxipdata->subscip, "separating/clique/freq", -1) );

   /* forbid recursive call of heuristics solving subMIPs */
   SCIP_CALL(SCIPsetIntParam(auxipdata->subscip, "heuristics/rins/freq", -1));
   SCIP_CALL(SCIPsetIntParam(auxipdata->subscip, "heuristics/rens/freq", -1));
   SCIP_CALL(SCIPsetIntParam(auxipdata->subscip, "heuristics/localbranching/freq", -1));
   SCIP_CALL(SCIPsetIntParam(auxipdata->subscip, "heuristics/crossover/freq", -1));

   SCIP_CALL(SCIPsetBoolParam(auxipdata->subscip, "constraints/logicor/negatedclique", FALSE));


   /* create subscip family variables for each main-problem family variable that is positive in the current solution */
   /* This solution will typically be the solution to the linear relaxation */
   /* use the same name for both */

   for ( i = 0 ; i < consdata->n ; ++i)
   {
      /* essential not to consider the empty parent set, hence the '-1' */
      for ( k = 0 ; k < consdata->nParentSets[i]-1; ++k)
      {
	 val = SCIPgetSolVal(scip, sol, consdata->PaVars[i][k]);
	 if ( SCIPisPositive(scip,val) )
	 {
	    SCIP_CALL( SCIPcreateVar(auxipdata->subscip, &(auxipdata->family[i][k]), SCIPvarGetName(consdata->PaVars[i][k]), 0.0, 1.0, val, SCIP_VARTYPE_BINARY, TRUE, FALSE, NULL, NULL, NULL, NULL, NULL) );
	    SCIP_CALL( SCIPaddVar(auxipdata->subscip, auxipdata->family[i][k]) );
	 }
	 else
	    /* calls to BMSclearMemoryArray(auxipdata->family[i], consdata->nParentSets[i]) should have made a NULL pointer */
	    assert( auxipdata->family[i][k] ==  NULL );
      }
   }

   /* create variable for lower bound */
   /* convenient to create it, even if k_lb=k_ub=1 */

   SCIP_CALL( SCIPcreateVar(auxipdata->subscip, &(auxipdata->kvar), "kvar", k_lb, k_ub, 1.0, SCIP_VARTYPE_INTEGER, TRUE, FALSE, NULL, NULL, NULL, NULL, NULL) );
   SCIP_CALL( SCIPaddVar(auxipdata->subscip, auxipdata->kvar) );

   /* create variables to identify clusters */

   for ( i = 0 ; i < consdata->n ; ++i)
   {
      (void) SCIPsnprintf(varname, SCIP_MAXSTRLEN, "incluster#%d", i);
      SCIP_CALL( SCIPcreateVar(auxipdata->subscip, &(auxipdata->incluster[i]), varname, 0.0, 1.0, -1.0, SCIP_VARTYPE_BINARY, TRUE, FALSE, NULL, NULL, NULL, NULL, NULL) );
      SCIP_CALL( SCIPaddVar(auxipdata->subscip, auxipdata->incluster[i]) );
      SCIP_CALL( SCIPchgVarBranchPriority(auxipdata->subscip, auxipdata->incluster[i], 10) );
   }

   /* if a variable is in the cluster then so must at least one of its potential parents */
   
   /* for ( i = 0 ; i < consdata->n ; ++i) */
   /* { */
   /*    (void) SCIPsnprintf(consname, SCIP_MAXSTRLEN, "only_candparents#%d", i); */
   /*    SCIP_CALL( SCIPgetNegatedVar(auxipdata->subscip,auxipdata->incluster[i],&(clausevars[0])) ); */
   /*    for (l = 0; l < consdata->nCandidateParents[i]; ++l) */
   /* 	 clausevars[l+1] = auxipdata->incluster[consdata->CandidateParents[i][l]]; */
   /*    SCIP_CALL( SCIPcreateConsLogicor(auxipdata->subscip,&(auxipdata->parentscons[i]),consname,1+consdata->nCandidateParents[i],clausevars, */
   /* 				       TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE) ); */
   /*    SCIP_CALL( SCIPaddCons(auxipdata->subscip, auxipdata->parentscons[i]) ); */
   /*    /\*SCIP_CALL( SCIPprintCons(auxipdata->subscip,  auxipdata->parentscons[i], NULL) );*\/ */
   /* } */

   /* if family[i][k]=1 then incluster[i]=1 */
   /*  ~family[i][k]=1 + incluster[i] >= 1 */

   for ( i = 0 ; i < consdata->n ; ++i)
   {
      for ( k = 0 ; k < consdata->nParentSets[i]-1 ; ++k)
      {
	 if ( auxipdata->family[i][k] !=  NULL )
	 {
	    (void) SCIPsnprintf(consname, SCIP_MAXSTRLEN, "clause#%d#%d", i, k);
	    SCIP_CALL( SCIPgetNegatedVar(auxipdata->subscip,auxipdata->family[i][k],&(clausevars[0])) );
	    clausevars[1] = auxipdata->incluster[i];
	    SCIP_CALL( SCIPcreateConsLogicor(auxipdata->subscip,&(auxipdata->clausecons[i][k]),consname,2,clausevars,
					     TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE) );
	    SCIP_CALL( SCIPaddCons(auxipdata->subscip, auxipdata->clausecons[i][k]) );
	 }
	 else
	    assert( auxipdata->clausecons[i][k] == NULL );
      }
   }


   /* k_ub*I(W->v) <= \sum_{u \in W} - k + k_ub */
   /* if I(W->v)=1 this becomes \sum_{u \in W} >= k */
   /* if I(W->v)=0 this becomes vacuous */
   /* just post as a normal linear constraint:
      -inf <= k_ub*I(W->v) - \sum_{u \in W} + k <= k_ub

      note: in the code below 'k' has a different meaning. It indexes
      parent sets
      ' u \in W' is represented by the binary variable incluster[consdata->ParentSets[i][k][l]]

      if k_ub == 1 use an equivalent logicor representation

   */

   if ( k_ub == 1 )
   {
      for ( i = 0 ; i < consdata->n ; ++i)
      {
	 for ( k = 0 ; k < consdata->nParentSets[i]-1 ; ++k)
	 {
	    if ( auxipdata->family[i][k] !=  NULL )
	    {
	       (void) SCIPsnprintf(consname, SCIP_MAXSTRLEN, "overlap#%d#%d", i, k);
	       
	       SCIP_CALL( SCIPgetNegatedVar(auxipdata->subscip,auxipdata->family[i][k],&(clausevars[0])) );
	       nvars = 1;
	       for (l = 0; l < consdata->nParents[i][k]; ++l)
	       {
		  clausevars[nvars++] = auxipdata->incluster[consdata->ParentSets[i][k][l]];
	       }
	       SCIP_CALL( SCIPcreateConsLogicor(auxipdata->subscip,&(auxipdata->clausecons[i][k]),consname,nvars,clausevars,
						TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE) );
	       SCIP_CALL( SCIPaddCons(auxipdata->subscip, auxipdata->clausecons[i][k]) );
	    }
	 }
      }
   }
   else
   {
      for ( i = 0 ; i < consdata->n ; ++i)
      {
	 for ( k = 0 ; k < consdata->nParentSets[i]-1 ; ++k)
	 {
	    if ( auxipdata->family[i][k] !=  NULL )
	    {
	       (void) SCIPsnprintf(consname, SCIP_MAXSTRLEN, "overlap#%d#%d", i, k);
	       SCIP_CALL( SCIPcreateConsLinear(auxipdata->subscip, &(auxipdata->overlapcons[i][k]), consname, 0, NULL, NULL,
					       -SCIPinfinity(scip), k_ub,
					       TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE) );
	       SCIP_CALL( SCIPaddCoefLinear(auxipdata->subscip, auxipdata->overlapcons[i][k], auxipdata->family[i][k], k_ub) );
	       for (l = 0; l < consdata->nParents[i][k]; ++l)
	       {
		  SCIP_CALL( SCIPaddCoefLinear(auxipdata->subscip, auxipdata->overlapcons[i][k], auxipdata->incluster[consdata->ParentSets[i][k][l]], -1) );
	       }
	       SCIP_CALL( SCIPaddCoefLinear(auxipdata->subscip, auxipdata->overlapcons[i][k], auxipdata->kvar, 1) );
	       SCIP_CALL( SCIPaddCons(auxipdata->subscip, auxipdata->overlapcons[i][k]) );
	    }
	    else
	       assert( auxipdata->overlapcons[i][k] == NULL );
	 }
      }
   }


   /* 1 <= |C|-k  <= inf : for the added cut to make sense */
   if ( k_ub == 1 )
      SCIP_CALL( SCIPcreateConsLinear(auxipdata->subscip, &(auxipdata->ck_cons), "ck_constraint", 0, NULL, NULL,
                  2, SCIPinfinity(scip),
                  TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE) );
   else
      SCIP_CALL( SCIPcreateConsLinear(auxipdata->subscip, &(auxipdata->ck_cons), "ck_constraint", 0, NULL, NULL,
                  1, SCIPinfinity(scip),
                  TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE) );

   for ( i = 0 ; i < consdata->n ; ++i)
   {
      SCIP_CALL( SCIPaddCoefLinear(auxipdata->subscip, auxipdata->ck_cons, auxipdata->incluster[i], 1) );
   }
   if ( k_ub != 1)
      SCIP_CALL( SCIPaddCoefLinear(auxipdata->subscip, auxipdata->ck_cons, auxipdata->kvar, -1) );
   SCIP_CALL( SCIPaddCons(auxipdata->subscip, auxipdata->ck_cons) );

   /* all constraints posted - free temporary memory */

   SCIPfreeMemoryArray(scip, &clausevars);

   /* let I(u) denote u is in the cluster, then
      objective function is \sum_{v,W}I(W->v) - \sum_{u}I(u) + k
      If a feasible solution has a positive objective value,
      then a cutting plane has been found,
      so maximise and rule out non-positive solutions
   */

   SCIP_CALL_ABORT( SCIPsetObjsense(auxipdata->subscip, SCIP_OBJSENSE_MAXIMIZE) );

   /* rule out non-positive solutions using SCIPsetObjlimit */
   SCIP_CALL( SCIPsetObjlimit(auxipdata->subscip,0) );

   /*SCIP_CALL(SCIPwriteOrigProblem(auxipdata->subscip,NULL,NULL,FALSE) );
     SCIP_CALL(SCIPwriteParams(auxipdata->subscip,NULL,FALSE,TRUE) );
   */
   SCIP_CALL( SCIPsolve(auxipdata->subscip) );
   /* SCIP_CALL( SCIPsetParamsCountsols(auxipdata->subscip) ); */
   /* SCIP_CALL( SCIPsetLongintParam(auxipdata->subscip,"constraints/countsols/sollimit", 1000) ); */
   /* SCIP_CALL( SCIPsetBoolParam(auxipdata->subscip,"constraints/countsols/collect", TRUE) ); */
   /* SCIP_CALL( SCIPcount(auxipdata->subscip) ); */


   /* SCIPgetCountedSparseSols(auxipdata->subscip,&sparse_vars,&sparse_nvars,&sparse_sols,&sparse_nsols); */
   /* printf("foo %lld\n", sparse_nsols); */

   status = SCIPgetStatus(auxipdata->subscip);
   /*SCIP_CALL(SCIPprintStatus(auxipdata->subscip,NULL));*/

   if ( status == SCIP_STATUS_USERINTERRUPT || status == SCIP_STATUS_INFEASIBLE || status == SCIP_STATUS_INFORUNBD )
   {
      /* /\* print out LP relaxation that could not be separated *\/ */
      /*SCIP_CALL( SCIPwriteMIP(scip,"foo",TRUE,TRUE) );
      SCIP_CALL( SCIPprintSol(scip,NULL,NULL,FALSE) );
      exit(1);*/
      /*printf("infeasible.\n");
	SCIP_CALL( SCIPprintSol(scip,NULL,NULL,FALSE) );*/
      SCIPdebugMessage("could not find a cluster cut.\n");
      SCIP_CALL(AuxIPDataFree(scip, auxipdata, consdata));
      SCIPfreeMemoryArray(scip, &included);
      SCIPfreeMemoryArray(scip, &excluded);

      return SCIP_OKAY;
   }

   /* if there are feasible solutions but the best has objective value not better that
      0, then we have not found a cutting plane.
      This code snippet from Timo Berthold
   */
   nsols = SCIPgetNSols(auxipdata->subscip);
   if ( nsols > 0 && SCIPisFeasLE(auxipdata->subscip, SCIPgetSolOrigObj(auxipdata->subscip,SCIPgetBestSol(auxipdata->subscip)), 0.0 ) )
      {
       /*printf("obj value too low.\n");
       SCIP_CALL( SCIPprintSol(scip,NULL,NULL,FALSE) );
       */
       SCIP_CALL(AuxIPDataFree(scip, auxipdata, consdata));
    SCIPfreeMemoryArray(scip, &included);
    SCIPfreeMemoryArray(scip, &excluded);

       return SCIP_OKAY;
      }

   if ( status != SCIP_STATUS_SOLLIMIT && status != SCIP_STATUS_GAPLIMIT && status != SCIP_STATUS_OPTIMAL && status != SCIP_STATUS_NODELIMIT  && status != SCIP_STATUS_TIMELIMIT)
   {
      SCIPerrorMessage("Solution of subscip for DAG cluster separation returned with invalid status %d.\n", status);
      SCIP_CALL(AuxIPDataFree(scip, auxipdata, consdata));
      SCIPfreeMemoryArray(scip, &included);
      SCIPfreeMemoryArray(scip, &excluded);

      return SCIP_ERROR;
   }

   /* To get here a cutting plane must have been found */

   subscip_sols = SCIPgetSols(auxipdata->subscip);

   for (s = 0; s <  nsols; ++s)
   {

      /* sparsesol = sparse_sols[s]; */
      /* assert(sparsesol != NULL); */
      /* assert(SCIPsparseSolGetNVars(sparsesol) == sparse_nvars); */

      /* /\* get first solution of the sparse solution *\/ */
      /* SCIPsparseSolGetFirstSol(sparsesol, sol, sparse_vars); */

      subscip_sol = subscip_sols[s];

      /*SCIP_CALL( SCIPprintSol(auxipdata->subscip,subscip_sol,NULL,FALSE) );*/

       if ( k_ub == 1)
	  kval = 1;
      else
	 kval = SCIPgetSolVal(auxipdata->subscip, subscip_sol, auxipdata->kvar);
      rhs = -kval;


      (void) SCIPsnprintf(cluster_name, SCIP_MAXSTRLEN, "clustercut(");
      for ( i = 0 ; i < consdata->n ; ++i)
	 if ( SCIPisPositive(scip, SCIPgetSolVal(auxipdata->subscip, subscip_sol, auxipdata->incluster[i])) )
	 {
	    (void) SCIPsnprintf(tmp_str, SCIP_MAXSTRLEN, "%d,", i);
	    (void) strcat(cluster_name, tmp_str);
	 }
      (void) strcat(cluster_name, ")");


#if SCIP_VERSION >= 300
       SCIP_CALL( SCIPcreateEmptyRowCons(scip, &cut, conshdlr, "clustercut", -SCIPinfinity(scip), 0,
                 FALSE, FALSE, TRUE) );
#else
      /* use deprecated function for 2.1 compatibility */
       SCIP_CALL( SCIPcreateEmptyRow(scip, &cut, "clustercut", -SCIPinfinity(scip), 0,
                 FALSE, FALSE, TRUE) );
#endif

      for ( i = 0 ; i < consdata->n ; ++i)
      {
	 /* if child i is not in the cluster then no need to consider its family variables */
	 if ( SCIPisZero(scip, SCIPgetSolVal(auxipdata->subscip, subscip_sol, auxipdata->incluster[i])) )
	    continue;

	 /*cluster_size++;*/
	 rhs++;
	 n_included = 0;
	 n_excluded = 0;
	 /* include all parents sets with at least kval parents in cluster */
	 for ( k = 0;  k < consdata->nParentSets[i]; ++k)
	 {
	    include_in_cut = FALSE;
	    overlap = 0;
	    for (l = 0; l < consdata->nParents[i][k]; ++l)
	    {
	       if ( SCIPisPositive(scip, SCIPgetSolVal(auxipdata->subscip, subscip_sol, auxipdata->incluster[consdata->ParentSets[i][k][l]])) )
	       {
		  overlap++;
		  if ( SCIPisGE(scip,overlap,kval) )
		  {
		     include_in_cut = TRUE;
		     break;
		  }
	       }
	    }
	    if ( include_in_cut )
	       /*SCIP_CALL( SCIPaddVarToRow(scip, cut, consdata->PaVars[i][k], 1.0) );*/
	       included[n_included++] = consdata->PaVars[i][k];
	    else
	       excluded[n_excluded++] = consdata->PaVars[i][k];
	 }
	 /* use convexity constraint to reduce variables in the cut */
	 if(  n_included < consdata->nParentSets[i]  / 2 )
	    /* not too many variables for cut, so add as normal */
	    SCIP_CALL( SCIPaddVarsToRowSameCoef(scip, cut, n_included, included, 1.0) );
	 else
	 {
	    SCIP_CALL( SCIPaddVarsToRowSameCoef(scip, cut, n_excluded, excluded, -1.0) );
	    rhs--;
	 }
      }


      assert( SCIPisIntegral(scip,rhs) );
      /*assert( SCIPisGE(scip,rhs,1.0) ); */
      SCIP_CALL (SCIPchgRowRhs(scip, cut, rhs) );
      SCIP_CALL( SCIPaddCut(scip, sol, cut, FALSE) );
      /*SCIP_CALL( SCIPaddPoolCut(scip, cut) );*/
      (*nGen)++;
      /*printf("cluster size %d\n", cluster_size);*/
      /*SCIP_CALL( SCIPprintRow(scip, cut, NULL));*/ 
      SCIP_CALL( SCIPreleaseRow(scip, &cut));
   }

   SCIPdebugMessage("added %d cluster cuts.\n", *nGen);

   SCIPfreeMemoryArray(scip, &included);
   SCIPfreeMemoryArray(scip, &excluded);

   SCIP_CALL(AuxIPDataFree(scip, auxipdata, consdata));
   return SCIP_OKAY;
}



/** creates constraint handler data for dagcluster constraint handler */
static
SCIP_RETCODE conshdlrdataCreate(
   SCIP*                 scip,               /**< SCIP data structure */
   SCIP_CONSHDLRDATA**   conshdlrdata        /**< pointer to store the constraint handler data */
   )
{
   assert(scip != NULL);
   assert(conshdlrdata != NULL);

   SCIP_CALL( SCIPallocMemory(scip, conshdlrdata) );

   return SCIP_OKAY;
}

// Callback methods of constraint handler
/** copy method for constraint handler plugins (called when SCIP copies plugins) */
#define conshdlrCopyDagcluster NULL
/** initialization method of constraint handler (called after problem was transformed) */
#define consInitDagcluster NULL
/** deinitialization method of constraint handler (called before transformed problem is freed) */
#define consExitDagcluster NULL
/** presolving initialization method of constraint handler (called when presolving is about to begin) */
#define consInitpreDagcluster NULL
/** presolving deinitialization method of constraint handler (called after presolving has been finished) */
#define consExitpreDagcluster NULL
/** solving process initialization method of constraint handler (called when branch and bound process is about to begin) */
#define consInitsolDagcluster NULL
/** solving process deinitialization method of constraint handler (called before branch and bound process data is freed) */
#define consExitsolDagcluster NULL
/** transforms constraint data into data belonging to the transformed problem */
#define consTransDagcluster NULL
/** LP initialization method of constraint handler */
#define consInitlpDagcluster NULL
/** presolving method of constraint handler */
#define consPresolDagcluster NULL
/** constraint activation notification method of constraint handler */
#define consActiveDagcluster NULL
/** constraint deactivation notification method of constraint handler */
#define consDeactiveDagcluster NULL
/** constraint enabling notification method of constraint handler */
#define consEnableDagcluster NULL
/** constraint disabling notification method of constraint handler */
#define consDisableDagcluster NULL
/** variable deletion of constraint handler */
#define consDelvarsDagcluster NULL
/** constraint display method of constraint handler */
#define consPrintDagcluster NULL
/** constraint copying method of constraint handler */
#define consCopyDagcluster NULL
/** constraint parsing method of constraint handler */
#define consParseDagcluster NULL

/** destructor of constraint handler to free constraint handler data (called when SCIP is exiting) */
static
SCIP_DECL_CONSFREE(consFreeDagcluster)
{
   SCIP_CONSHDLRDATA* conshdlrdata;

   conshdlrdata = SCIPconshdlrGetData(conshdlr);
   assert(conshdlrdata != NULL);

   SCIPfreeMemory(scip, &conshdlrdata);

   SCIPconshdlrSetData(conshdlr, NULL);

   return SCIP_OKAY;
}

/** frees specific constraint data */
static
SCIP_DECL_CONSDELETE(consDeleteDagcluster)
{  /*lint --e{715}*/

   int i;

   assert( scip != NULL );
   assert( conshdlr != NULL );
   assert( strcmp(SCIPconshdlrGetName(conshdlr), CONSHDLR_NAME) == 0 );
   assert( cons != NULL );
   assert( consdata != NULL);
   assert( *consdata != NULL);
   assert( (*consdata)->PaVars != NULL );
   assert( (*consdata)->nParentSets != NULL );

   SCIPdebugMessage("deleting DAG cluster constraint <%s>.\n", SCIPconsGetName(cons));

   /* probably need to do more than this */

   for ( i = 0; i < (*consdata)->n; ++i )
   {
      SCIPfreeMemoryArray(scip, &((*consdata)->parent_min[i]));
      SCIPfreeMemoryArray(scip, &((*consdata)->parent_max[i]));
      SCIPfreeMemoryArray(scip, &((*consdata)->ancestor_min[i]));
      SCIPfreeMemoryArray(scip, &((*consdata)->ancestor_max[i]));
   }
   SCIPfreeMemoryArray(scip, &((*consdata)->parent_min));
   SCIPfreeMemoryArray(scip, &((*consdata)->parent_max));
   SCIPfreeMemoryArray(scip, &((*consdata)->ancestor_min));
   SCIPfreeMemoryArray(scip, &((*consdata)->ancestor_max));

   SCIPfreeBlockMemory(scip, consdata);

   return SCIP_OKAY;
}

/** separation method of constraint handler for DAG  solutions */
static
SCIP_DECL_CONSSEPALP(consSepalpDagcluster)
{
   int c;
   int nGen = 0;

   SCIP_CONSHDLRDATA* conshdlrdata;
   SCIP_CONSDATA* consdata;
   SCIP_CONS* cons;

   assert( scip != NULL );
   assert( conshdlr != NULL );
   assert( strcmp(SCIPconshdlrGetName(conshdlr), CONSHDLR_NAME) == 0 );
   assert( conss != NULL );
   assert( result != NULL );

   conshdlrdata = SCIPconshdlrGetData(conshdlr);
   assert(conshdlrdata != NULL);

   *result = SCIP_DIDNOTRUN;

   for (c = 0; c < nconss; ++c)
   {

      cons = conss[c];
      assert( cons != NULL );
      SCIPdebugMessage("separating LP solution for dag cluster constraint <%s>.\n", SCIPconsGetName(cons));

      consdata = SCIPconsGetData(cons);
      assert( consdata != NULL );

      *result = SCIP_DIDNOTFIND;

      /*SCIP_CALL( DagClusterSeparate1(scip, consdata, NULL, &nGen, conshdlr) );*/
      SCIP_CALL( DagClusterSeparate(scip, consdata, NULL, &nGen, 1,1,conshdlr) );
	 /* if (nGen > 0) */
	 /* { */
	 /*    printf("cluster above separated what e1 could not\n"); */
	 /* } */
	 /* else */
	 /* { */
	 /*    printf("old version no good either\n"); */
	 /* } */

      if ( nGen == 0 )
      {
	 if ( SCIPgetDepth(scip) == 0 )
	 {
	    if ( conshdlrdata->kmaxroot > 1)
	    {
	       /*printf("separating in root with %d\n",conshdlrdata->kmaxroot);*/
	       SCIP_CALL( DagClusterSeparate(scip, consdata, NULL, &nGen,  2, conshdlrdata->kmaxroot, conshdlr) );
	    }
	 }
	 else
	 {
	    if ( conshdlrdata->kmax > 1)
	    {
	       printf("separating outside of  root with %d\n",conshdlrdata->kmax);
	       SCIP_CALL( DagClusterSeparate(scip, consdata, NULL, &nGen,  2, conshdlrdata->kmax, conshdlr) );
	    }
	 }
      }

      if (nGen > 0)
	 *result = SCIP_SEPARATED;

   }
   SCIPdebugMessage("separated %d cuts in separation method.\n", nGen);

   return SCIP_OKAY;
}

/** separation method of constraint handler for arbitrary primal solutions */
static
SCIP_DECL_CONSSEPASOL(consSepasolDagcluster)
{  /*lint --e{715}*/
   int c;
   int nGen = 0;

   SCIP_CONSDATA* consdata;
   SCIP_CONS* cons;

   assert( scip != NULL );
   assert( conshdlr != NULL );
   assert( strcmp(SCIPconshdlrGetName(conshdlr), CONSHDLR_NAME) == 0 );
   assert( conss != NULL );
   assert( result != NULL );

   *result = SCIP_DIDNOTRUN;

   /* loop through all constraints */
   for (c = 0; c < nconss; ++c)
   {
      cons = conss[c];
      assert( cons != NULL );
      SCIPdebugMessage("separating solution for an arbitrary primal solution for the DAG cluster constraint <%s>.\n", SCIPconsGetName(cons));

      consdata = SCIPconsGetData(cons);
      assert( consdata != NULL );

      *result = SCIP_DIDNOTFIND;
      SCIP_CALL( DagClusterSeparate(scip, consdata, sol, &nGen,  1, 1, conshdlr) );
   }
   if (nGen > 0)
      *result = SCIP_SEPARATED;

   return SCIP_OKAY;
}

/** constraint enforcing method of constraint handler for LP solutions */
static
SCIP_DECL_CONSENFOLP(consEnfolpDagcluster)
{  /*lint --e{715}*/
   int c;
   int nGen = 0;

   SCIP_CONSDATA* consdata;
   SCIP_CONS* cons;

   assert( scip != NULL );
   assert( conshdlr != NULL );
   assert( strcmp(SCIPconshdlrGetName(conshdlr), CONSHDLR_NAME) == 0 );
   assert( conss != NULL );
   assert( result != NULL );

   *result = SCIP_FEASIBLE;

   /* loop through all constraints */
   for (c = 0; c < nconss; ++c)
   {
      cons = conss[c];
      assert( cons != NULL );
      SCIPdebugMessage("enforcing LP solution for dag cluster constraint <%s>.\n", SCIPconsGetName(cons));

      consdata = SCIPconsGetData(cons);
      assert( consdata != NULL );
      /* only have to deal with integer solutions, so just look for a directed cycle */
      SCIP_CALL( DagClusterSeparate(scip, consdata, NULL, &nGen,  1, 1, conshdlr) );
      /*SCIP_CALL( DagClusterSeparate1(scip, consdata, NULL, &nGen,  conshdlr) );*/
   }
   if (nGen > 0)
      *result = SCIP_SEPARATED;
   SCIPdebugMessage("separated %d cuts in enforcement method.\n", nGen);

   return SCIP_OKAY;
}

/** constraint enforcing method of constraint handler for pseudo solutions */
static
SCIP_DECL_CONSENFOPS(consEnfopsDagcluster)
{  /*lint --e{715}*/

   check_for_cycles(scip, conshdlr, conss, nconss, NULL, result);

   if (*result == SCIP_INFEASIBLE) {
      SCIPdebugMessage("pseudo solution DOES NOT satify the DAG cluster constraint.\n");
   } else {
      SCIPdebugMessage("pseudo solution satifies the DAG cluster constraint.\n");
   }

   return SCIP_OKAY;
}

/** feasibility check method of constraint handler for integral solutions **/
static
SCIP_DECL_CONSCHECK(consCheckDagcluster)
{  /*lint --e{715}*/

   check_for_cycles(scip, conshdlr, conss, nconss, sol, result);

   if (*result == SCIP_INFEASIBLE) {
      SCIPdebugMessage("primal solution DOES NOT satify the DAG cluster constraint.\n");
   } else {
      SCIPdebugMessage("primal solution satifies the DAG cluster constraint.\n");
   }

   return SCIP_OKAY;
}

/** domain propagation method of constraint handler */
static
SCIP_DECL_CONSPROP(consPropDagcluster)
{
   int c;
   int nGen = 0;

   SCIP_CONSDATA* consdata;
   SCIP_CONS* cons;
   int i,j,k,l;

   int i_parent;

   SCIP_Bool infeasible, tightened;
   /*SCIP_Bool sink;*/

   assert( scip != NULL );
   assert( conshdlr != NULL );
   assert( strcmp(SCIPconshdlrGetName(conshdlr), CONSHDLR_NAME) == 0 );
   assert( conss != NULL );
   assert( result != NULL );
   *result = SCIP_DIDNOTRUN;

   /* loop through all constraints */
   for (c = 0; c < nconss; ++c)
   {

      cons = conss[c];
      assert( cons != NULL );
      SCIPdebugMessage("propagating dagcluster constraint <%s>.\n", SCIPconsGetName(cons));

      *result = SCIP_DIDNOTFIND;
      consdata = SCIPconsGetData(cons);

      /* printf("In this node\n"); */
      /* printf("These fixed to 1:\n"); */
      /* for ( i = 0; i < consdata->n; ++i ) */
      /*     for (k = 0 ; k < consdata->nParentSets[i]-1; ++k) */
      /*        if ( SCIPisPositive(scip,SCIPvarGetLbLocal(consdata->PaVars[i][k]))) */
      /*            printf("%s\n",SCIPvarGetName(consdata->PaVars[i][k])); */

      /* printf("These fixed to 0:\n"); */
      /* for ( i = 0; i < consdata->n; ++i ) */
      /*     for (k = 0 ; k < consdata->nParentSets[i]-1; ++k) */
      /*        if ( ! SCIPisPositive(scip,SCIPvarGetUbLocal(consdata->PaVars[i][k]))) */
      /*           printf("%s %g\n",SCIPvarGetName(consdata->PaVars[i][k]),SCIPvarGetUbLocal(consdata->PaVars[i][k]));          */


      /* set parent_min and parent_max relations */
      /* "parent_min[i][j] = TRUE" means j is a parent of i in current node */
      /* "parent_max[i][j] = TRUE" means j may be a parent of i in some child node */
      for ( i = 0; i < consdata->n; ++i )
      {
    for ( j = 0; j < consdata->n; ++j )
    {
       consdata->parent_min[i][j] = FALSE;
       /*consdata->parent_max[i][j] = FALSE;*/
    }

    for (k = 0 ; k < consdata->nParentSets[i]; ++k)
    {
       if ( SCIPisPositive(scip,SCIPvarGetLbLocal(consdata->PaVars[i][k])))
       {
                for (l = 0; l < consdata->nParents[i][k]; ++l)
          {
        consdata->parent_min[i][consdata->ParentSets[i][k][l]] = TRUE;
          }

       }
       /* if ( SCIPisPositive(scip,SCIPvarGetUbLocal(consdata->PaVars[i][k]))) */
       /* { */
             /*    for (l = 0; l < consdata->nParents[i][k]; ++l) */
       /*    { */
       /*     consdata->parent_max[i][consdata->ParentSets[i][k][l]] = TRUE; */
       /*    } */

       /* } */
    }
      }

      /* compute transitive closures */
      SCIP_CALL( transitive_closure(consdata->parent_min,consdata->ancestor_min,consdata->n) );
      /* SCIP_CALL( transitive_closure(consdata->parent_max,consdata->ancestor_max,consdata->n) ); */

      /* for ( i = 0; i < consdata->n; ++i ) */
      /*     for ( j = 0; j < consdata->n; ++j ) */
      /*     { */
      /*        if (   consdata->parent_min[i][j] || consdata->ancestor_min[i][j] || */
      /*          consdata->parent_max[i][j] || consdata->ancestor_max[i][j] ) */
      /*        { */
      /*           printf("%d,%d: parent_min=%d, ancestor_min=%d, parent_max=%d, ancestor_max=%d\n",i,j, */
      /*             consdata->parent_min[i][j],consdata->ancestor_min[i][j], */
      /*             consdata->parent_max[i][j],consdata->ancestor_max[i][j]) ; */
      /*        } */
      /*     } */

      /* propagations using ancestor_min */
      for (i = 0 ; i < consdata->n ; ++i)
      {
    for (k = 0 ; k < consdata->nParentSets[i]; ++k)
    {
       for (l = 0; l < consdata->nParents[i][k]; ++l)
       {
          i_parent = consdata->ParentSets[i][k][l];

          if ( consdata->ancestor_min[i_parent][i] )
          {
        SCIP_CALL( SCIPinferBinvarCons(scip, consdata->PaVars[i][k], FALSE, cons, i*consdata->n + k, &infeasible, &tightened) );
        if ( infeasible )
        {
           SCIPdebugMessage(" -> node infeasible.\n");
           /*printf("Infeasibility Ruling out: %s\n",SCIPvarGetName(consdata->PaVars[i][k]));*/
           SCIP_CALL( SCIPinitConflictAnalysis(scip) );
           for ( i = 0; i < consdata->n; ++i )
           {
         for (k = 0 ; k < consdata->nParentSets[i]; ++k)
         {
            if ( SCIPisPositive(scip,SCIPvarGetLbLocal(consdata->PaVars[i][k])))
               SCIP_CALL( SCIPaddConflictBinvar(scip, consdata->PaVars[i][k]) );
         }
           }
           SCIP_CALL( SCIPanalyzeConflictCons(scip, cons, NULL) );
           *result = SCIP_CUTOFF;
           return SCIP_OKAY;
        }
        if ( tightened )
        {
           /*printf("Ruling out: %s\n",SCIPvarGetName(consdata->PaVars[i][k]));*/
           ++nGen;
        }

        /* one illegal parent is enough */
        break;
          }
       }
    }
      }

      /* /\* propagations using ancestor_max *\/ */
      /* for (i = 0 ; i < consdata->n ; ++i) */
      /* { */
      /*     sink = FALSE; */
      /*     for (k = 0 ; k < consdata->nParentSets[i]-1; ++k) */
      /*     { */
      /*        if ( SCIPisPositive(scip,SCIPvarGetUbLocal(consdata->PaVars[i][k]))) */
      /*        { */
      /*           sink = TRUE; */
      /*           for (l = 0; l < consdata->nParents[i][k]; ++l) */
      /*           { */
      /*         i_parent = consdata->ParentSets[i][k][l]; */
      /*         /\* if i_parent might become an ancestor of i in future then */
      /*            can't select this parent set */
      /*         *\/ */
      /*         if ( consdata->ancestor_max[i_parent][i] ) */
      /*         { */
      /*            sink = FALSE; */
      /*            break; */
      /*         } */
      /*           } */
      /*           if ( sink ) */
      /*           { */
      /*         /\* no parents can ever become ancestors so */
      /*            choose this parent set right away *\/ */
      /*         SCIP_CALL( SCIPinferBinvarCons(scip, consdata->PaVars[i][k], TRUE, cons, i*consdata->n + k, &infeasible, &tightened) ); */
      /*         if ( infeasible ) */
      /*         { */
      /*            SCIPdebugMessage(" -> node infeasible.\n"); */
      /*            /\*SCIP_CALL( SCIPinitConflictAnalysis(scip) ); */
      /*              SCIP_CALL( SCIPaddConflictBinvar(scip, vars[i][j]) ); */
      /*              SCIP_CALL( SCIPanalyzeConflictCons(scip, cons, NULL) );*\/ */
      /*            *result = SCIP_CUTOFF; */
      /*            return SCIP_OKAY; */
      /*         } */
      /*         if ( tightened ) */
      /*         { */
      /*            /\* for ( ii = 0; ii < consdata->n; ++ii ) *\/ */
      /*            /\*    for ( j = 0; j < consdata->n; ++j ) *\/ */
      /*            /\*       printf("%d,%d: parent_min=%u, ancestor_min=%u, parent_max=%u, ancestor_max=%u\n",ii,j, *\/ */
      /*            /\*            (consdata->parent_min)[ii][j],(consdata->ancestor_min)[ii][j], *\/ */
      /*            /\*            (consdata->parent_max)[ii][j],(consdata->ancestor_max)[ii][j]); *\/ */

      /*            printf("Selecting: %s\n",SCIPvarGetName(consdata->PaVars[i][k])); */
      /*            ++nGen; */
      /*         } */
      /*           } */
      /*           /\* can only consider first parent set, not already ruled out *\/ */
      /*           break; */
      /*        } */
      /*     } */
      /* } */


   }
   if (nGen > 0)
      *result = SCIP_REDUCEDDOM;
   SCIPdebugMessage("propagated %d domains.\n", nGen);
   /*printf("propagated %d domains.\n", nGen);*/

   return SCIP_OKAY;
}

/** propagation conflict resolving method of constraint handler */
static
SCIP_DECL_CONSRESPROP(consRespropDagcluster)
{  /*lint --e{715}*/
   /*SCIP_CONSDATA* consdata;*/

   assert( scip != NULL );
   assert( conshdlr != NULL );
   assert( strcmp(SCIPconshdlrGetName(conshdlr), CONSHDLR_NAME) == 0 );
   assert( cons != NULL );
   assert( infervar != NULL );
   assert( bdchgidx != NULL );
   assert( result != NULL );

   SCIPdebugMessage("Propagation resolution of constraint <%s>.\n", SCIPconsGetName(cons));
   *result = SCIP_DIDNOTFIND;

   /* consdata = SCIPconsGetData(cons); */
   /* assert( consdata != NULL); */

   /* /\* inferinfo encodes a vector of n+1 non-negative integers  */
   /*    1st integer identifies the variable set to zero */
   /*    elements 0+1,...i+1,... (n-1)+1 have the index of parent set used in conflict  */
   /*    if variable i was not used this is set to = nParentSets[i] (ie out of bounds) */
   /* *\/ */

   /* ub = 1; */
   /* for ( i = 0; i < consdata->n; ++i ) */
   /* { */
   /*    ub = ub * (1 + consdata->nParentSets[i]); */
   /* } */
   /* ub = ub * consdata->n; */

   /* assert( 0 <= inferinfo <= ub ); */

   /* infervar = inferinfo / div; */
   /* inferinfo = inferinfo % div; */

   /* for ( i = 0; i < consdata->n; ++i ) */
   /* { */
   /*    k = inferinfo / div[i]; */

   /*    if ( i == infervar ) */
   /*    { */
   /*     assert( k < consdata->nParentSets[i] ); */
   /*     /\* parent set fixed to 0 *\/ */
   /*     assert( SCIPvarGetUbAtIndex(consdata->PaVars[i][k], bdchgidx, FALSE) > 0.5 && SCIPvarGetUbAtIndex(consdata->[i][k], bdchgidx, TRUE) < 0.5 ); */
   /*     SCIPdebugMessage("Result: %s = 0 ... \n", SCIPvarGetName(consdata->PaVars[i][k])); */
   /*    } */
   /*    else if ( k < consdata->nParentSets[i] ) */
   /*    { */
   /*     SCIPdebugMessage("Reason: %s = 1 ... \n", SCIPvarGetName(consdata->PaVars[i][k])); */
   /*     SCIP_CALL( SCIPaddConflictLb(scip, consdata->PaVars[i][k], bdchgidx) ); */
   /*    } */
   /*    inferinfo = inferinfo % div[i]; */
   /* } */
   /*   *result = SCIP_SUCCESS; */
     return SCIP_OKAY;
}

/** variable rounding lock method of constraint handler */
static
SCIP_DECL_CONSLOCK(consLockDagcluster)
{  /*lint --e{715}*/

  SCIP_CONSDATA* consdata;
  int i,k;

  assert( scip != NULL );
  assert( conshdlr != NULL );
  assert( strcmp(SCIPconshdlrGetName(conshdlr), CONSHDLR_NAME) == 0 );
  assert( cons != NULL );


  consdata = SCIPconsGetData(cons);
  assert(consdata != NULL);
  assert(consdata->PaVars != NULL);
  assert(consdata->nParentSets != NULL);

  for( i = 0; i < consdata->n; ++i)
  {
     for( k = 0; k < consdata->nParentSets[i]; ++k)
     {
   /* rounding down always OK  with or without implicit founders */
      SCIP_CALL( SCIPaddVarLocks(scip, consdata->PaVars[i][k], nlocksneg, nlockspos) );
     }
  }
   return SCIP_OKAY;
}



/** creates the handler for dagcluster constraints and includes it in SCIP */
SCIP_RETCODE DC_includeConshdlr(
   SCIP*                 scip                /**< SCIP data structure */
   )
{

   SCIP_CONSHDLRDATA* conshdlrdata;

   /* create  constraint handler data */
   SCIP_CALL( conshdlrdataCreate(scip, &conshdlrdata) );

  /* include constraint handler */
#if SCIP_VERSION >= 300
 SCIP_CALL( SCIPincludeConshdlr(scip, CONSHDLR_NAME, CONSHDLR_DESC,
         CONSHDLR_SEPAPRIORITY, CONSHDLR_ENFOPRIORITY, CONSHDLR_CHECKPRIORITY,
         CONSHDLR_SEPAFREQ, CONSHDLR_PROPFREQ, CONSHDLR_EAGERFREQ, CONSHDLR_MAXPREROUNDS,
         CONSHDLR_DELAYSEPA, CONSHDLR_DELAYPROP, CONSHDLR_DELAYPRESOL, CONSHDLR_NEEDSCONS,
         CONSHDLR_PROP_TIMING,
         conshdlrCopyDagcluster,
         consFreeDagcluster, consInitDagcluster, consExitDagcluster,
         consInitpreDagcluster, consExitpreDagcluster, consInitsolDagcluster, consExitsolDagcluster,
         consDeleteDagcluster, consTransDagcluster, consInitlpDagcluster,
         consSepalpDagcluster, consSepasolDagcluster, consEnfolpDagcluster, consEnfopsDagcluster, consCheckDagcluster,
         consPropDagcluster, consPresolDagcluster, consRespropDagcluster, consLockDagcluster,
         consActiveDagcluster, consDeactiveDagcluster,
         consEnableDagcluster, consDisableDagcluster, consDelvarsDagcluster,
         consPrintDagcluster, consCopyDagcluster, consParseDagcluster,
              consGetVarsDagcluster, consGetNVarsDagcluster,
         conshdlrdata) );
#else
   SCIP_CALL( SCIPincludeConshdlr(scip, CONSHDLR_NAME, CONSHDLR_DESC,
         CONSHDLR_SEPAPRIORITY, CONSHDLR_ENFOPRIORITY, CONSHDLR_CHECKPRIORITY,
         CONSHDLR_SEPAFREQ, CONSHDLR_PROPFREQ, CONSHDLR_EAGERFREQ, CONSHDLR_MAXPREROUNDS,
         CONSHDLR_DELAYSEPA, CONSHDLR_DELAYPROP, CONSHDLR_DELAYPRESOL, CONSHDLR_NEEDSCONS,
         CONSHDLR_PROP_TIMING,
         conshdlrCopyDagcluster,
         consFreeDagcluster, consInitDagcluster, consExitDagcluster,
         consInitpreDagcluster, consExitpreDagcluster, consInitsolDagcluster, consExitsolDagcluster,
         consDeleteDagcluster, consTransDagcluster, consInitlpDagcluster,
         consSepalpDagcluster, consSepasolDagcluster, consEnfolpDagcluster, consEnfopsDagcluster, consCheckDagcluster,
         consPropDagcluster, consPresolDagcluster, consRespropDagcluster, consLockDagcluster,
         consActiveDagcluster, consDeactiveDagcluster,
         consEnableDagcluster, consDisableDagcluster, consDelvarsDagcluster,
         consPrintDagcluster, consCopyDagcluster, consParseDagcluster,
         conshdlrdata) );
#endif


   SCIP_CALL( SCIPaddIntParam(scip,
               "constraints/"CONSHDLR_NAME"/kmax",
               "maximum k to try for k-cluster cutting planes",
               &conshdlrdata->kmax, FALSE, DEFAULT_KMAX, 1, INT_MAX, NULL, NULL) );

   SCIP_CALL( SCIPaddIntParam(scip,
               "constraints/"CONSHDLR_NAME"/kmaxroot",
               "maximum k to try for k-cluster cutting planes in the root",
               &conshdlrdata->kmaxroot, FALSE, DEFAULT_KMAX_ROOT, 1, INT_MAX, NULL, NULL) );


   return SCIP_OKAY;
}

/** creates and captures a dagcluster constraint */
SCIP_RETCODE DC_createCons(
   SCIP*     scip,           /**< SCIP data structure */
   SCIP_CONS**           cons,           /**< pointer to hold the created constraint */
   const char*           name,           /**< name of constraint */
   int          n,           /**< number of elements */
   int*         nParentSets,        /**< nParentSets[i] is the number of  parent sets for variable i*/
   int**     nParents,       /**< nParents[i][k] is the number of  parents in the kth parent set for variable i*/
   int***       ParentSets,        /**< ParentSets[i][k][l] is the lth parent in the kth parent set of ith variable **/
   SCIP_VAR***     PaVars,      /**< PaVars[i][k] = 1 if kth parent set of ith variable is selected */
   SCIP_Bool             initial,            /**< should the LP relaxation of constraint be in the initial LP?
                                              *   Usually set to TRUE. Set to FALSE for 'lazy constraints'. */
   SCIP_Bool             separate,           /**< should the constraint be separated during LP processing?
                                              *   Usually set to TRUE. */
   SCIP_Bool             enforce,            /**< should the constraint be enforced during node processing?
                                              *   TRUE for model constraints, FALSE for additional, redundant constraints. */
   SCIP_Bool             check,              /**< should the constraint be checked for feasibility?
                                              *   TRUE for model constraints, FALSE for additional, redundant constraints. */
   SCIP_Bool             propagate,          /**< should the constraint be propagated during node processing?
                                              *   Usually set to TRUE. */
   SCIP_Bool             local,              /**< is constraint only valid locally?
                                              *   Usually set to FALSE. Has to be set to TRUE, e.g., for branching constraints. */
   SCIP_Bool             modifiable,         /**< is constraint modifiable (subject to column generation)?
                                              *   Usually set to FALSE. In column generation applications, set to TRUE if pricing
                                              *   adds coefficients to this constraint. */
   SCIP_Bool             dynamic,            /**< is constraint subject to aging?
                                              *   Usually set to FALSE. Set to TRUE for own cuts which
                                              *   are seperated as constraints. */
   SCIP_Bool             removable,          /**< should the relaxation be removed from the LP due to aging or cleanup?
                                              *   Usually set to FALSE. Set to TRUE for 'lazy constraints' and 'user cuts'. */
   SCIP_Bool             stickingatnode      /**< should the constraint always be kept at the node where it was added, even
                                              *   if it may be moved to a more global node?
                                              *   Usually set to FALSE. Set to TRUE to for constraints that represent node data. */
                  )
{

  SCIP_CONSHDLR* conshdlr;
  SCIP_CONSDATA* consdata;

  int i,k,l;
  int* tmp;

  assert( scip != NULL );

  /* find the dagcluster constraint handler */
  conshdlr = SCIPfindConshdlr(scip, CONSHDLR_NAME);
  if( conshdlr == NULL )
  {
      SCIPerrorMessage("dagcluster constraint handler not found\n");
      return SCIP_PLUGINNOTFOUND;
  }

  /* create constraint data */

  SCIP_CALL( SCIPallocBlockMemory(scip, &consdata) );

  consdata->n = n;
  consdata->nParentSets = nParentSets;
  consdata->ParentSets = ParentSets;
  consdata->nParents = nParents;
  consdata->PaVars = PaVars;
  consdata->biggest_nParentSets = 0;

  SCIP_CALL( SCIPallocMemoryArray(scip, &consdata->parent_min, consdata->n) );
  SCIP_CALL( SCIPallocMemoryArray(scip, &consdata->parent_max, consdata->n) );
  SCIP_CALL( SCIPallocMemoryArray(scip, &consdata->ancestor_min, consdata->n) );
  SCIP_CALL( SCIPallocMemoryArray(scip, &consdata->ancestor_max, consdata->n) );
  /* SCIP_CALL( SCIPallocMemoryArray(scip, &consdata->nCandidateParents, consdata->n) ); */
  /* SCIP_CALL( SCIPallocMemoryArray(scip, &consdata->CandidateParents, consdata->n) ); */
  SCIP_CALL( SCIPallocMemoryArray(scip, &tmp, consdata->n) );
  for ( i = 0; i < consdata->n; ++i )
  {
     if( nParentSets[i] > consdata->biggest_nParentSets )
	consdata->biggest_nParentSets = nParentSets[i];
     SCIP_CALL( SCIPallocMemoryArray(scip, &(consdata->parent_min[i]), consdata->n) );
     SCIP_CALL( SCIPallocMemoryArray(scip, &(consdata->parent_max[i]), consdata->n) );
     SCIP_CALL( SCIPallocMemoryArray(scip, &(consdata->ancestor_min[i]), consdata->n) );
     SCIP_CALL( SCIPallocMemoryArray(scip, &(consdata->ancestor_max[i]), consdata->n) );

     for ( l = 0; l < consdata->n; ++l )
	tmp[l] = FALSE;
     
     for (k = 0; k < consdata->nParentSets[i]; ++k)
     {
	for (l = 0; l < consdata->nParents[i][k]; ++l)
	{
	   tmp[consdata->ParentSets[i][k][l]] = TRUE;
	}
     }
     /* SCIP_CALL( SCIPallocMemoryArray(scip, &(consdata->CandidateParents[i]), consdata->n) ); */
     /* consdata->nCandidateParents[i] = 0; */
     /* for (l = 0; l < consdata->n; ++l) */
     /* 	if ( tmp[l] ) */
     /* 	   consdata->CandidateParents[i][consdata->nCandidateParents[i]++] = l; */
  }

  SCIPfreeMemoryArray(scip, &tmp);


  /* create constraint */
  SCIP_CALL( SCIPcreateCons(scip, cons, name, conshdlr, consdata, initial, separate, enforce, check, propagate,
             local, modifiable, dynamic, removable, stickingatnode) );

  return SCIP_OKAY;
}

