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
 *  Implements the functions needed to perform model averaging over the n best Bayesian networks.
 */

#include "model_averaging.h"
#include "data_structures.h"

/** The average scores of each of the variables in the program.
 *
 *  average_scores[i][j] is the likelihood weighted average score of the
 *  jth parent set of variable i.
 */
static SCIP_Real** average_scores;
/** The sum of the likelihoods of all networks found so far.
 *
 *  This is used to normalise the scores in @link average_scores @endlink .
 */
static SCIP_Real total_score = 0.0;

/** The number of seconds spent finding all of the solutions included in the average.
 */
static SCIP_Real total_time = 0.0;

/** Allocates memory for the data structures used for model averaging.
 *
 *  @param scip The SCIP instance on which the model averaging will be performed.
 *  @return SCIP_OKAY if memory allocation was successful or an appropriate error
*   message otherwise.
 */
SCIP_RETCODE MA_createAverageDataStructure(SCIP* scip) {
   int i;
   SCIP_PROBDATA* probdata = SCIPgetProbData(scip);
   SCIP_CALL( SCIPallocMemoryArray(scip, &average_scores, probdata->n) );
   for (i = 0; i < probdata->n; i++)
      SCIP_CALL( SCIPallocClearMemoryArray(scip, &(average_scores[i]), probdata->nParentSets[i]) );
   return SCIP_OKAY;
}
/** Frees memory used for the data structures used for model averaging.
 *
 *  @param scip The SCIP instance on which the model averaging was performed.
 *  @return SCIP_OKAY if memory deallocation was successful or an appropriate error
*   message otherwise.
 */
SCIP_RETCODE MA_destroyAverageDataStructure(SCIP* scip) {
   int i;
   SCIP_PROBDATA* probdata = SCIPgetProbData(scip);
   for (i = 0; i < probdata->n; i++)
      SCIPfreeMemoryArray(scip, &(average_scores[i]));
   SCIPfreeMemoryArray(scip, &average_scores);
   return SCIP_OKAY;
}

/** Updates the average scores based on a newly found solution.
 *
 *  @param scip The SCIP instance to which the solution belongs.
 *  @param sol The new solution to incorporate in to the averages.
 *  @return SCIP_OKAY if the operation succeeded or an appropriate error message otherwise.
 */
SCIP_RETCODE MA_updateAverageDataStructure(SCIP* scip, SCIP_SOL* sol) {
   int i,j;
   SCIP_Real overall_score = 0;
   SCIP_PROBDATA* probdata = SCIPgetProbData(scip);
   for (i = 0; i < probdata->n; i++)
      for (j = 0; j < probdata->nParentSets[i]; j++)
         if (SCIPgetSolVal(scip, sol, probdata->PaVars[i][j]) > 0.5)
            overall_score = overall_score + probdata->Scores[i][j];
   for (i = 0; i < probdata->n; i++)
      for (j = 0; j < probdata->nParentSets[i]; j++)
         if (SCIPgetSolVal(scip, sol, probdata->PaVars[i][j]) > 0.5)
            average_scores[i][j] += overall_score;
   total_score += overall_score;
   total_time += SCIPgetSolvingTime(scip);
   return SCIP_OKAY;
}

/** Returns the result of the model averaging.
 *
 *  The result will be returned through the scores parameter. scores must be
 *  initialised such that the number of elements in each array match
 *  the number of elements in array of the associated probdata for this SCIP
 *  instance.  The returned value of scores[i][j] will be the likelihood that the
 *  jth parent set is chosen for node i, based on the solutions used to create the
 *  model average.
 *
 *  @param scip The SCIP instance which the model averaging was performed on.
 *  @param scores An allocated but empty array which the result can be written to.
 *  @return SCIP_OKAY if the operation succeeded or an appropriate error code otherwise.
 */
SCIP_RETCODE MA_getAverageDataStructure(SCIP* scip, SCIP_Real*** scores) {
   int i,j;
   SCIP_PROBDATA* probdata = SCIPgetProbData(scip);
   for (i = 0; i < probdata->n; i++)
      for (j = 0; j < probdata->nParentSets[i]; j++)
         (*scores)[i][j] = average_scores[i][j] / total_score;
   return SCIP_OKAY;
}
/** Returns the total time spent solving for all the solutions included
 *  in the model average.
 *
 *  @return The number of seconds spend on solving all of the solutions
 *  that have been used to make up the average.
 */
SCIP_Real MA_getTotalAveragesTime(void) {
   return total_time;
}
/** Returns the total likelihood of all the solutions included
 *  in the model average.
 *
 *  @return The sum of the likelihoods of each of the solutions included.
 */
SCIP_Real MA_getTotalAveragesScore(void) {
   return total_score;
}
