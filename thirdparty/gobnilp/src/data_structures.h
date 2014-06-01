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
 *  Contains data structures that must be known about by several code files.
 */

#ifndef __DATA_STRUCTURES_H__
#define __DATA_STRUCTURES_H__

#include <scip/scip.h>
#include <scip/scipdefplugins.h>

/** All problem data that relates solely to pedigree-based constraints.
 */
typedef struct
{
   /** Variable recording the sex of each individual.
    *
    *  SexVars[i] = 1 iff individual i is female.
    */
   SCIP_VAR** SexVars;
   /** The ages of each individual.
    *
    *  ages[i] is the age of individual i.
    */
   int* ages;
} PedigreeData;

/** The main problem data structure that is used to moce data around the program.
 */
struct SCIP_ProbData
{
   int n;                   /**< number of elements */
   int* nParentSets;        /**< nParentSets[i] is the number of  parent sets for variable i*/
   int** nParents;          /**< nParents[i][k] is the number of  parents in the kth parent set for variable i*/
   SCIP_Real** Scores;      /**< Scores[i][k] is score of kth parent set of ith variable**/
   int*** ParentSets;       /**< ParentSets[i][k][l] is the lth parent in the kth parent set of ith variable **/
   SCIP_VAR*** PaVars;      /**< PaVars[i][k] = 1 if kth parent set of ith variable is selected */
   char** nodeNames;        /**< nodeNames[i] is the name of the ith node */
   PedigreeData* ped;       /**< Pedigree specific problem data. */
};

/** Data needed by the sinks primal heuristic.
 */
struct SCIP_HeurData
{
   int          n;               /**< number of variables in BN */
   int*         nParentSets;     /**< nParentSets[i] is the number of  parent sets for variable i*/
   int**        nParents;        /**< nParents[i][k] is the number of  parents in the kth parent set for variable i */
   int***       ParentSets;      /**< ParentSets[i][k][l] is the lth parent in the kth parent set of ith variable */
   SCIP_VAR***  PaVars;          /**< PaVars[i][k] = 1 if kth parent set of ith variable is selected */
   int*         bestparents;     /**< stores index of current best parent set for each i */
   int*         not_sinks;       /**< stores variables yet to be chosen as a sink */
   int*         sink;            /**< indicates whether a variable has been chosen as a sink */
   /*unsigned int*          seedp;*/
   SCIP_Real*   loss_ub;         /**< loss_ub[i] is an upper bound on distance moved by setting ith variable */
   SCIP_Real**  vals;            /**< vals[i][k] stores a solution value for Pavars[i][k] */
   SCIP_Real**  loss;            /**< loss[i][k] stores the loss incurred by setting PaVars[i][k] to 1 */
   SCIP_Bool    printsols;  /**< whether to print out candidate primal solutions */
   FILE*        file;            /**< where to print candidate primal solutions, NULL for stdout */
   PedigreeData* ped;            /**< Any heuristic data related to pedigrees.*/
};

#endif
