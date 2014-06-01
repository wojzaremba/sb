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
 *  Contains all the functions related to the use of pedigrees in the program.
 */

#include "pedigrees.h"
#include "data_structures.h"
#include "utils.h"

#include <string.h>

// Useful auxillary functions
/** @brief Determines whether the program is being run for learning pedigrees.
 *
 *  @param scip The SCIP instance that is running.
 *  @return TRUE if the program is being used to learn pedigrees. FALSE otherwsie.
 */
SCIP_Bool PD_inPedigreeMode(SCIP* scip) {
   SCIP_Bool pedigreemode;
   SCIPgetBoolParam(scip,"gobnilp/pedigreemode",&pedigreemode);
   return pedigreemode;
}
/** Checks whether the program is enforcing sex consistency.
 *
 *  If the deprecated version of rhe sex consistency parameter is being used then
 *  a message will warn the user of this.
 *
 *  @param scip The SCIP instance of which to check the status.
 *  @return TRUE if the program should enforcing sex consistency.  FALSE otherwise.
 */
static SCIP_Bool usingSexConsistency(SCIP* scip) {
   if (PD_inPedigreeMode(scip)) {
      SCIP_Bool sexconsistentold;
      SCIP_Bool sexconsistentnew;
      SCIPgetBoolParam(scip,"gobnilp/sexconsistent", &sexconsistentold);
      SCIPgetBoolParam(scip,"gobnilp/pedigree/sexconsistent", &sexconsistentnew);
      if (sexconsistentnew) {
         return TRUE;
      } else if (!sexconsistentnew && sexconsistentold) {
         // Old sex consistency parameter is set to true and new version is either unused or set to false.
         printf("WARNING: gobnilp/sexconsistent has been deprecated.\n Please use gobnilp/pedigree/sexconsistent instead.\n");
         return TRUE;
      } else {
         return FALSE;
      }
   } else {
      return FALSE;
   }
}
/** Checks whether a SCIP problem is suitable for use as a pedigree.
 *
 *  A problem is acceptable as a pedigree if it has no parent sets of more than size 2.
 *
 *  @param scip The SCIP instance for which to check the data.
 *  @return TRUE if this problem represents a valid pedigree problem, FALSE otherwise.
 */
static SCIP_Bool checkSuitableForPedigree(SCIP* scip) {
   int i,j;
   SCIP_PROBDATA* probdata = SCIPgetProbData(scip);
   for (i = 0; i < probdata->n; i++)
      for (j = 0; j < probdata->nParentSets[i]; j++)
         if (probdata->nParents[i][j] > 2)
            return FALSE;
   return TRUE;
}

// Functions related to parameters
/** Makes SCIP recognise parameters related to pedigree reconstruction.
 *
 *  @param scip The SCIP instance to which to add the parameters.
 *  @return SCIP_OKAY if the operation succeeded or an appropriate error code otherwise.
 */
SCIP_RETCODE PD_addPedigreeParameters(SCIP* scip) {
   SCIP_CALL(UT_addBoolParam(scip,
      "gobnilp/pedigreemode",
      "whether to use GOBNILP for pedigrees",
      FALSE
   ));

   SCIP_CALL(UT_addBoolParam(scip,
      "gobnilp/sexconsistent",
      "whether to enforce sexual consistency in the dag",
      FALSE
   ));

   SCIP_CALL(UT_addBoolParam(scip,
      "gobnilp/pedigree/sexconsistent",
      "whether to enforce sexual consistency in the dag",
      FALSE
   ));

   SCIP_CALL(UT_addIntParam(scip,
      "gobnilp/pedigree/maxsibagegap",
      "maximum age gap permitted between full siblings (-1 for no restriction)",
      -1
   ));

   SCIP_CALL(UT_addIntParam(scip,
      "gobnilp/pedigree/maxhalfsibagegap",
      "maximum age gap permitted between half siblings (-1 for no restriction)",
      -1
   ));

   SCIP_CALL(UT_addIntParam(scip,
      "gobnilp/pedigree/maxsibsetsize",
      "maximum number of children a pair of parents can have together (-1 for no restriction)",
      -1
   ));

   SCIP_CALL(UT_addIntParam(scip,
      "gobnilp/pedigree/maxchildren",
      "maximum number of children any individual can have (-1 for no restriction)",
      -1
   ));

   SCIP_CALL(UT_addIntParam(scip,
      "gobnilp/pedigree/maxchildrenmother",
      "maximum number of children a mother can have (-1 for no restriction)",
      -1
   ));

   SCIP_CALL(UT_addIntParam(scip,
      "gobnilp/pedigree/maxchildrenfather",
      "maximum number of children a father can have (-1 for no restriction)",
      -1
   ));

   SCIP_CALL(UT_addStringParam(scip,
      "gobnilp/pedigree/agedatafile",
      "file containing individual's age data",
      ""
   ));
   return SCIP_OKAY;
}

// Functions for memory management
/** Allocates memory to store the pedigree data in the problem instance.
 *
 *  @param scip The SCIP instance to which the problem belongs.
 *  @param probdata The data which the memory allocation should take place in.
 *  @return SCIP_OKAY if the memory allocation was successful, or an approriate error code otherwise.
 */
static SCIP_RETCODE allocPedigreeData(SCIP* scip, SCIP_PROBDATA* probdata) {
   char* agedatafile;
   PedigreeData* peddata;

   SCIP_CALL( SCIPallocMemory(scip, &peddata) );
   probdata->ped = peddata;

   SCIP_CALL( SCIPgetStringParam(scip,"gobnilp/pedigree/agedatafile", &agedatafile) );
   if (strcmp(agedatafile,"") != 0) {
      int* ages;
      int i;
      SCIP_CALL( SCIPallocMemoryArray(scip, &ages, probdata->n) );
      for (i = 0; i < probdata->n; i++)
         ages[i] = -1;
      probdata->ped->ages = ages;
   }
   return SCIP_OKAY;
}
/** Deallocates the memory used to store the pedigree data in the problem instance.
 *
 *  @param scip The SCIP instance to which the problem belongs.
 *  @return SCIP_OKAY if the memory deallocation was successful, or an approriate error code otherwise.
 */
SCIP_RETCODE PD_freePedigreeData(SCIP* scip) {
   int i;
   char* agedatafile;
   SCIP_PROBDATA* probdata = SCIPgetProbData(scip);
   SCIP_CALL( SCIPgetStringParam(scip,"gobnilp/pedigree/agedatafile", &agedatafile) );

   if (usingSexConsistency(scip)) {
      for (i = 0; i < probdata->n; i++) {
         SCIP_CALL( SCIPreleaseVar(scip, &(probdata->ped->SexVars[i])) );
      }
      SCIPfreeMemoryArray(scip, &(probdata->ped->SexVars));
   }

   if (strcmp(agedatafile,"") != 0)
      SCIPfreeMemoryArray(scip, &(probdata->ped->ages));

   return SCIP_OKAY;
}

// Functions for input and output
/** Reads in age information from a file.
 *
 *  @param scip The SCIP instance to read data in to.
 *  @param filename The file containing the age data.
 *  @param probdata The data in to which to read the information.
 *  @return SCIP_OKAY if reading succeeded or an appropriate error otherwise.
 */
static SCIP_RETCODE readAgeData(SCIP* scip, char* filename, SCIP_PROBDATA* probdata) {
   FILE* file;
   int age;
   int status;
   int i, j;
   char* name = malloc(SCIP_MAXSTRLEN*sizeof(char));

   // Open the file
   file = fopen(filename, "r");
   if (file == NULL) {
      SCIPerrorMessage("Could not open file %s.\n", filename);
      return SCIP_NOFILE;
   }

   // For each person in the pedigree
   for (i = 0; i < probdata->n; i++) {
      SCIP_Bool found = FALSE;
      // Read the data line
      status = fscanf(file, "%s %d", name, &age);
      if (!status) {
         SCIPerrorMessage("Reading age data failed: Parsing problem at line %d.\n", i);
         return SCIP_READERROR;
      }
      // Find out who the data belongs to
      for (j = 0; j < probdata->n; j++) {
         if (strcmp(probdata->nodeNames[j], name) == 0) {
            found = TRUE;
            // Check the person hasn't already had age data entered
            if (probdata->ped->ages[j] == -1)
               probdata->ped->ages[j] = age;
            else {
               SCIPerrorMessage("Reading age data failed:.%s has age declared twice.\n", name);
               return SCIP_READERROR;
            }
         }
      }
      if (!found) {
         SCIPerrorMessage("Reading age data failed:.%s unknown.\n", name);
         return SCIP_READERROR;
      }
   }
   fclose(file);
   free(name);
   return SCIP_OKAY;
}
/** Reads in an pedigree specific information from files.
 *
 *  @param scip The SCIP instance to read data in to.
 *  @param probdata The data in to which to read the information.
 *  @return SCIP_OKAY if reading was successful or an appropriate error code otherwise.
 */
SCIP_RETCODE PD_readPedigreeData(SCIP* scip, SCIP_PROBDATA* probdata) {
   char* agedatafile;

   allocPedigreeData(scip, probdata);

   SCIP_CALL( SCIPgetStringParam(scip,"gobnilp/pedigree/agedatafile", &agedatafile) );
   if (strcmp(agedatafile,"") != 0)
      SCIP_CALL( readAgeData(scip, agedatafile, probdata) );

   return SCIP_OKAY;
}
/** Prints the solution as a pedigree.
 *
 *  The pedigree consists of four columns.  The first is the individual, thes second is the sex of the individual, the third
 *  is its father and the fourth is its mother.  If either the father or the mother is not present in the sample, a '-' is
 *  printed instead.  If sex consistency is enforced, then individuals will not appear as father of one individual and mother
 *  of another.  The pedigree is sorted such that all individuals are declared on a earlier line than those in which they
 *  appear as parents.
 *
 *  @param scip The SCIP instance to which the solution belongs.
 *  @param probdata The problem data used by the solution.
 *  @param Scores The score data to use for the solution.
 *  @param selected Whether each of the variables is selected in the solution.
 *  @param total_score The overall score of this solution.
 *  @param stream Where to print the solution.
 *  @param pedvars Whether each of the pedigree specific variables is selected in the solution.
 *  @return SCIP_OKAY if the solution was printed correctly or an appropriate error message otherwise.
 */
SCIP_RETCODE PD_printSolutionPedigreeFormat(SCIP* scip, SCIP_PROBDATA* probdata, SCIP_Real** Scores, SCIP_Bool** selected, SCIP_Real total_score, FILE* stream, SCIP_Bool* pedvars) {
   if (!checkSuitableForPedigree(scip)) {
      SCIPerrorMessage("The specified problem is not a valid pedigree problem.\n");
      return SCIP_ERROR;
   } else {
      int i,k;
      SCIP_Bool no_parents;
      SCIP_Bool Done[probdata->n];
      int numDone = 0;
      char sex;
      for (i = 0; i < probdata->n; i++)
         Done[i] = FALSE;

      while (numDone < probdata->n) {
         for (i = 0; i < probdata->n; ++i) {
            if (Done[i] == FALSE) {
               no_parents = TRUE;
               if (usingSexConsistency(scip) == FALSE || pedvars == NULL)
                  sex = 'U';
               else if (pedvars[i])
                  sex = 'F';
               else
                  sex = 'M';
               for (k = 0; k < probdata->nParentSets[i]; ++k) {
                  if ( selected[i][k] ) {
                     no_parents = FALSE;
                     if (probdata->nParents[i][k] == 0) {
                        fprintf(stream, "%s\t%c\t-\t-\n",probdata->nodeNames[i],sex);
                        Done[i] = TRUE;
                        numDone++;
                     } else if (probdata->nParents[i][k] == 1) {
                        if (Done[probdata->ParentSets[i][k][0]] == TRUE) {
                           if (!usingSexConsistency(scip) || pedvars == NULL || pedvars[probdata->ParentSets[i][k][0]])
                              fprintf(stream, "%s\t%c\t-\t%s\n",probdata->nodeNames[i],sex,probdata->nodeNames[probdata->ParentSets[i][k][0]]);
                           else
                              fprintf(stream, "%s\t%c\t%s\t-\n",probdata->nodeNames[i],sex,probdata->nodeNames[probdata->ParentSets[i][k][0]]);
                           Done[i] = TRUE;
                           numDone++;
                        }
                     } else {
                        if (Done[probdata->ParentSets[i][k][0]] == TRUE && Done[probdata->ParentSets[i][k][1]] == TRUE) {
                           if (!usingSexConsistency(scip) || pedvars == NULL || pedvars[probdata->ParentSets[i][k][0]])
                              fprintf(stream, "%s\t%c\t%s\t%s\n",probdata->nodeNames[i],sex,probdata->nodeNames[probdata->ParentSets[i][k][1]],probdata->nodeNames[probdata->ParentSets[i][k][0]]);
                           else
                              fprintf(stream, "%s\t%c\t%s\t%s\n",probdata->nodeNames[i],sex,probdata->nodeNames[probdata->ParentSets[i][k][0]],probdata->nodeNames[probdata->ParentSets[i][k][1]]);
                           Done[i] = TRUE;
                           numDone++;
                        }
                     }
                     break;
                  }
               }
               if ( no_parents ) {
                  fprintf(stream, "%s\t%c\t-\t-\n",probdata->nodeNames[i],sex);
                  Done[i] = TRUE;
                  numDone++;
               }
            }
         }
      }
      return SCIP_OKAY;
   }
}

// Functions related to variables
/** Creates any needed variables needed specifically for learning pedigrees.
 *
 *  @param scip The SCIP instance in which to create the variables.
 *  @return SCIP_OKAY if the variable was successful, or an approriate error code otherwise.
 */
SCIP_RETCODE PD_addPedigreeVariables(SCIP* scip) {
   if (!checkSuitableForPedigree(scip)) {
      SCIPerrorMessage("The specified problem is not a valid pedigree problem.\n");
      return SCIP_ERROR;
   } else {
      if (usingSexConsistency(scip)) {
         int i;
         char s[SCIP_MAXSTRLEN];
         SCIP_PROBDATA* probdata = SCIPgetProbData(scip);
         SCIP_CALL( SCIPallocMemoryArray(scip, &(probdata->ped->SexVars), probdata->n) );
         for (i = 0; i < probdata->n; i++) {
            (void) SCIPsnprintf(s, SCIP_MAXSTRLEN, "isFemale(%s)", probdata->nodeNames[i]);
            SCIP_CALL( SCIPcreateVar(scip, &(probdata->ped->SexVars[i]), s, 0.0, 1.0, 0.0, SCIP_VARTYPE_BINARY, TRUE, FALSE, NULL, NULL, NULL, NULL, NULL) );
            SCIP_CALL( SCIPaddVar(scip, probdata->ped->SexVars[i]) );
         }
      }
      return SCIP_OKAY;
   }
}
/** Gets the values of the pedigree specific variables in the current solution.
 *
 *  If no pedigree specific variables are being used, NULL is returned.
 *
 *  @param scip The SCIP instance for which to find the variable values.
 *  @return A list of SCIP_Bools which are TRUE for all variables included in the solution and FALSE otherwise.
 */
SCIP_Bool* PD_getCurrentPedigreeVarValues(SCIP* scip) {
   if (usingSexConsistency(scip)) {
      int i;
      SCIP_Bool* vals;
      SCIP_PROBDATA* probdata = SCIPgetProbData(scip);
      SCIP_SOL* sol = SCIPgetBestSol(scip);
      SCIPallocClearMemoryArray(scip, &vals, probdata->n);
      for (i = 0; i < probdata->n; i++)
         if (SCIPgetSolVal(scip, sol, probdata->ped->SexVars[i]) > 0.5)
            vals[i] = 1;
         else
            vals[i] = 0;
      return vals;
   } else {
      return NULL;
   }
}

// Functions that create constraints
/** Creates constraints stating that individuals cannot have more than a given number of children.
 *
 *  @param scip The SCIP instance this applies in.
 *  @param max_size The maximum number of children an indiivdual may have.
 *  @param mother Whether the constraint should apply to mothers.
 *  @param father Whether the constraint should apply to fathers.
 *  @return SCIP_OKAY if adding the constraints worked.  An appropriate error code otherwise.
 */
static SCIP_RETCODE addMaximumNumberOfOffspringConstraint(SCIP* scip, int max_size, SCIP_Bool mother, SCIP_Bool father) {
   SCIP_PROBDATA* probdata;
   SCIP_CONS* cons;
   char s[SCIP_MAXSTRLEN];
   int i,j,k,l;

   // Constraints must apply to either mothers or fathers or both.
   if (!mother && !father) {
      SCIPerrorMessage("Maximum number of offspring constraint must apply to mothers, fathers or both.\n");
      return SCIP_ERROR;
   }

   probdata = SCIPgetProbData(scip);
   for (i = 0; i < probdata->n; i++) {
      int slack = max_size;
      if (mother && father)
         (void) SCIPsnprintf(s, SCIP_MAXSTRLEN, "maximum offspring of %s", probdata->nodeNames[i]);
      else if (mother && !father)
         (void) SCIPsnprintf(s, SCIP_MAXSTRLEN, "maximum offspring of %s (as mother)", probdata->nodeNames[i]);
      else
         (void) SCIPsnprintf(s, SCIP_MAXSTRLEN, "maximum offspring of %s (as father)", probdata->nodeNames[i]);
      SCIP_CALL( UT_createEmptyLTEConstraint(scip, &cons, s, max_size) );
      for (j = 0; j < probdata->n; j++)
         for (k = 0; k < probdata->nParentSets[j]; k++)
            for (l = 0; l < probdata->nParents[j][k]; l++)
               if (i == probdata->ParentSets[j][k][l]) {
                  SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[j][k], 1) );
                  slack--;
               }
      if (mother && !father) {
         SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->ped->SexVars[i], probdata->n) );
         SCIP_CALL( SCIPchgRhsLinear(scip, cons, SCIPgetRhsLinear(scip,cons) + probdata->n) );
      } else if (!mother && father) {
         SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->ped->SexVars[i], -probdata->n) );
      }
      if (slack < 0) {
         // Only add constraint if it is not always satisfied
         SCIP_CALL( SCIPaddCons(scip, cons) );
      }
      SCIP_CALL( SCIPreleaseCons(scip, &cons) );
   }

   return SCIP_OKAY;
}
/** Creates constraints stating that a pair of individuals cannot have more than a given number of children together.
 *
 *  @param scip The SCIP instance this applies in.
 *  @param max_size The maximum number of children an indiivdual may have.
 *  @return SCIP_OKAY if adding the constraints worked.  An appropriate error code otherwise.
 */
static SCIP_RETCODE addMaximumSibsetSizeConstraint(SCIP* scip, int max_size) {
   SCIP_PROBDATA* probdata;
   SCIP_CONS* cons;
   char s[SCIP_MAXSTRLEN];
   int par1, par2;
   int i,j;

   probdata = SCIPgetProbData(scip);
   for (par1 = 0; par1 < probdata->n-1; par1++)
      for (par2 = par1+1; par2 < probdata->n; par2++) {
         int terms = 0;
         (void) SCIPsnprintf(s, SCIP_MAXSTRLEN, "maximum family size of_%s and %s", probdata->nodeNames[par1], probdata->nodeNames[par2]);
         SCIP_CALL( UT_createEmptyLTEConstraint(scip, &cons, s, max_size) );
         for (i = 0; i < probdata->n; i++)
            for (j = 0; j < probdata->nParentSets[i]; j++)
               if (probdata->nParents[i][j] == 2)
                  if ((par1 == probdata->ParentSets[i][j][0] && par2 == probdata->ParentSets[i][j][1]) ||
                      (par1 == probdata->ParentSets[i][j][1] && par2 == probdata->ParentSets[i][j][0])) {
                     SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[i][j], 1) );
                     terms++;
                  }
         if (terms > max_size) {
            // Constraint isn't trivially satisfied
            SCIP_CALL( SCIPaddCons(scip, cons) );
         }
         SCIP_CALL( SCIPreleaseCons(scip, &cons) );
      }

   return SCIP_OKAY;
}
/** Creates constraints which prevent the age gap better a pair of full siblings being too great.
 *
 *  @param scip The SCIP instance in which to apply the constraint.
 *  @param max_age_gap The maximum permissible age gap.
 *  @return SCIP_OKAY if all needed constraints were created successfully.  An appropriate error code otherwise.
 */
static SCIP_RETCODE addFullSiblingAgeGapConstraint(SCIP* scip, int max_age_gap) {
   SCIP_PROBDATA* probdata;
   SCIP_CONS* cons;
   char s[SCIP_MAXSTRLEN];
   int par1, par2;
   int child1, child2;
   int i,j;

   probdata = SCIPgetProbData(scip);
   for (child1 = 0; child1 < probdata->n-1; child1++)
      for (i = 0; i < probdata->nParentSets[child1]; i++)
         if (probdata->nParents[child1][i] == 2) {
            par1 = probdata->ParentSets[child1][i][0];
            par2 = probdata->ParentSets[child1][i][1];
            for (child2 = child1+1; child2 < probdata->n; child2++)
               for (j = 0; j < probdata->nParentSets[child2]; j++)
                  if (probdata->nParents[child2][j] == 2)
                     if ((par1 == probdata->ParentSets[child2][j][0] && par2 == probdata->ParentSets[child2][j][1]) ||
                         (par1 == probdata->ParentSets[child2][j][1] && par2 == probdata->ParentSets[child2][j][0])) {
                        // Found a matching parent set
                        (void) SCIPsnprintf(s, SCIP_MAXSTRLEN, "maximum sibling age difference for %s and %s as children of %s and %s", probdata->nodeNames[child1], probdata->nodeNames[child2], probdata->nodeNames[par1], probdata->nodeNames[par2]);
                        SCIP_CALL( UT_createEmptyLTEConstraint(scip, &cons, s, max_age_gap + probdata->ped->ages[child1] + probdata->ped->ages[child2]) );
                        SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[child1][i], probdata->ped->ages[child1]) );
                        SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[child2][j], probdata->ped->ages[child1]) );
                        SCIP_CALL( SCIPaddCons(scip, cons) );
                        SCIP_CALL( SCIPreleaseCons(scip, &cons) );
                        (void) SCIPsnprintf(s, SCIP_MAXSTRLEN, "maximum sibling age difference for %s and %s as children of %s and %s", probdata->nodeNames[child2], probdata->nodeNames[child1], probdata->nodeNames[par1], probdata->nodeNames[par2]);
                        SCIP_CALL( UT_createEmptyLTEConstraint(scip, &cons, s, max_age_gap + probdata->ped->ages[child1] + probdata->ped->ages[child2]) );
                        SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[child1][i], probdata->ped->ages[child2]) );
                        SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[child2][j], probdata->ped->ages[child2]) );
                        SCIP_CALL( SCIPaddCons(scip, cons) );
                        SCIP_CALL( SCIPreleaseCons(scip, &cons) );
                     }

         }

   return SCIP_OKAY;
}
/** Creates constraints which prevent the age gap better a pair of half siblings with a common mother being too great.
 *
 *  @param scip The SCIP instance in which to apply the constraint.
 *  @param max_age_gap The maximum permissible age gap.
 *  @return SCIP_OKAY if all needed constraints were created successfully.  An appropriate error code otherwise.
 */
static SCIP_RETCODE addHalfSiblingAgeGapConstraint(SCIP* scip, int max_age_gap) {
   SCIP_PROBDATA* probdata;
   SCIP_CONS* cons1;
   SCIP_CONS* cons2;
   char s[SCIP_MAXSTRLEN];
   int child1, child2, par;
   int i,j;

   probdata = SCIPgetProbData(scip);
   for (child1 = 0; child1 < probdata->n-1; child1++)
      for (child2 = child1+1; child2 < probdata->n; child2++)
         for (par = 0; par < probdata->n; par++) {
            SCIP_Bool isEverParentOfChild1 = FALSE;
            SCIP_Bool isEverParentOfChild2 = FALSE;

            (void) SCIPsnprintf(s, SCIP_MAXSTRLEN, "maximum half sibling age difference for %s and %s with %s as mother", probdata->nodeNames[child1], probdata->nodeNames[child2], probdata->nodeNames[par]);
            SCIP_CALL( UT_createEmptyLTEConstraint(scip, &cons1, s, max_age_gap + probdata->ped->ages[child1] + probdata->ped->ages[child2]) );
            SCIP_CALL( SCIPaddCoefLinear(scip, cons1, probdata->ped->SexVars[par], probdata->ped->ages[child1]) );

            (void) SCIPsnprintf(s, SCIP_MAXSTRLEN, "maximum half sibling age difference for %s and %s with %s as mother", probdata->nodeNames[child2], probdata->nodeNames[child1], probdata->nodeNames[par]);
            SCIP_CALL( UT_createEmptyLTEConstraint(scip, &cons2, s, max_age_gap + probdata->ped->ages[child1] + probdata->ped->ages[child2]) );
            SCIP_CALL( SCIPaddCoefLinear(scip, cons2, probdata->ped->SexVars[par], probdata->ped->ages[child2]) );

            for (i = 0; i < probdata->nParentSets[child1]; i++) {
               SCIP_Bool parInThisSet = FALSE;
               for (j = 0; j < probdata->nParents[child1][i]; j++)
                  if (par == probdata->ParentSets[child1][i][j]) {
                     // parent is in this parent set of child 1
                     SCIP_CALL( SCIPaddCoefLinear(scip, cons1, probdata->PaVars[child1][i], probdata->ped->ages[child1]) );
                     parInThisSet = TRUE;
                     isEverParentOfChild1 = TRUE;
                  }
               if (parInThisSet == FALSE) {
                  // parent is not in this parent set of child 1
                  SCIP_CALL( SCIPaddCoefLinear(scip, cons2, probdata->PaVars[child1][i], probdata->ped->ages[child2]) );
               }
            }

            for (i = 0; i < probdata->nParentSets[child2]; i++) {
               SCIP_Bool parInThisSet = FALSE;
               for (j = 0; j < probdata->nParents[child2][i]; j++)
                  if (par == probdata->ParentSets[child2][i][j]) {
                     // parent is in this parent set of child 2
                     SCIP_CALL( SCIPaddCoefLinear(scip, cons2, probdata->PaVars[child2][i], probdata->ped->ages[child2]) );
                     parInThisSet = TRUE;
                     isEverParentOfChild2 = TRUE;
                  }
               if (parInThisSet == FALSE) {
                  // parent is not in this parent set of child 2
                  SCIP_CALL( SCIPaddCoefLinear(scip, cons1, probdata->PaVars[child2][i], probdata->ped->ages[child1]) );
               }
            }

            // Only add the constraints if the children can be half-sibs
            if (isEverParentOfChild1 && isEverParentOfChild2) {
               SCIP_CALL( SCIPaddCons(scip, cons1) );
               SCIP_CALL( SCIPaddCons(scip, cons2) );
            }

            SCIP_CALL( SCIPreleaseCons(scip, &cons1) );
            SCIP_CALL( SCIPreleaseCons(scip, &cons2) );
         }

   return SCIP_OKAY;
}
/** Creates constraints enforcing sexual consistency on a pedigree.
 *
 *  @param scip The SCIP instance in which the constraints should be added.
 *  @return SCIP_OKAY if the constraints were added successfully, or an appropriate error code otherwsie.
 */
static SCIP_RETCODE addSexConsistencyConstraint(SCIP* scip) {
   SCIP_PROBDATA* probdata;
   SCIP_CONS* cons;
   char s[SCIP_MAXSTRLEN];
   int i,j;

   probdata = SCIPgetProbData(scip);
   for (i = 0; i < probdata->n; i++)
      for (j = 0; j < probdata->nParentSets[i]; j++)
         if (probdata->nParents[i][j] == 2) {
            (void) SCIPsnprintf(s, SCIP_MAXSTRLEN, "sex_consistency_1_for_%s", SCIPvarGetName(probdata->PaVars[i][j]));
            SCIP_CALL( UT_createEmptyLTEConstraint(scip, &cons, s, 2) );
            SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[i][j], 1) );
            SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->ped->SexVars[probdata->ParentSets[i][j][0]], 1) );
            SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->ped->SexVars[probdata->ParentSets[i][j][1]], 1) );
            SCIP_CALL( SCIPaddCons(scip, cons) );
            SCIP_CALL( SCIPreleaseCons(scip, &cons) );
            (void) SCIPsnprintf(s, SCIP_MAXSTRLEN, "sex_consistency_2_for_%s", SCIPvarGetName(probdata->PaVars[i][j]));
            SCIP_CALL( UT_createEmptyLTEConstraint(scip, &cons, s, 0) );
            SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->PaVars[i][j], 1) );
            SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->ped->SexVars[probdata->ParentSets[i][j][0]], -1) );
            SCIP_CALL( SCIPaddCoefLinear(scip, cons, probdata->ped->SexVars[probdata->ParentSets[i][j][1]], -1) );
            SCIP_CALL( SCIPaddCons(scip, cons) );
            SCIP_CALL( SCIPreleaseCons(scip, &cons) );
         }
   return SCIP_OKAY;
}
/** Adds all appropriate pedigree based constraints to the problem.
 *
 *  @param scip The SCIP instance in which to add the constraints.
 *  @return SIP_OKAY if the constraints were added successfully, or an appropriate error code otherwise.
 */
SCIP_RETCODE PD_addPedigreeConstraints(SCIP* scip) {
   if (!checkSuitableForPedigree(scip)) {
      SCIPerrorMessage("The specified problem is not a valid pedigree problem.\n");
      return SCIP_ERROR;
   } else {
      int maxsibagegap;
      int maxhalfsibagegap;
      int maxsibsetsize;
      int maxchildren;
      int maxchildrenmother;
      int maxchildrenfather;
      char* agedatafile;
      SCIP_CALL( SCIPgetIntParam(scip,"gobnilp/pedigree/maxsibagegap",      &maxsibagegap     ) );
      SCIP_CALL( SCIPgetIntParam(scip,"gobnilp/pedigree/maxhalfsibagegap",  &maxhalfsibagegap ) );
      SCIP_CALL( SCIPgetIntParam(scip,"gobnilp/pedigree/maxsibsetsize",     &maxsibsetsize    ) );
      SCIP_CALL( SCIPgetIntParam(scip,"gobnilp/pedigree/maxchildren",       &maxchildren      ) );
      SCIP_CALL( SCIPgetIntParam(scip,"gobnilp/pedigree/maxchildrenmother", &maxchildrenmother) );
      SCIP_CALL( SCIPgetIntParam(scip,"gobnilp/pedigree/maxchildrenfather", &maxchildrenfather) );
      SCIP_CALL( SCIPgetStringParam(scip,"gobnilp/pedigree/agedatafile", &agedatafile) );
      if (maxsibagegap != -1) {
         if (strcmp(agedatafile,"") == 0) {
            SCIPerrorMessage("Can't enforce maximum sibling age gap when no age data is given.\n");
            return SCIP_ERROR;
         } else {
            SCIP_CALL( addFullSiblingAgeGapConstraint(scip, maxsibagegap) );
         }
      }
      if (maxhalfsibagegap != -1) {
         if (strcmp(agedatafile,"") == 0) {
            SCIPerrorMessage("Can't enforce maximum maternal half-sibling age gap when no age data is given.\n");
            return SCIP_ERROR;
         } else if (!usingSexConsistency(scip)) {
            SCIPerrorMessage("Can't enforce maximum maternal half-sibling age gap without sexual consistency.\n");
            return SCIP_ERROR;
         } else {
            SCIP_CALL( addHalfSiblingAgeGapConstraint(scip, maxhalfsibagegap) );
         }
      }
      if (maxsibsetsize != -1)
         SCIP_CALL( addMaximumSibsetSizeConstraint(scip, maxsibsetsize) );
      if (maxchildren != -1)
         SCIP_CALL( addMaximumNumberOfOffspringConstraint(scip, maxchildren, TRUE, TRUE) );
      if (maxchildrenmother != -1) {
         if (usingSexConsistency(scip))
            SCIP_CALL( addMaximumNumberOfOffspringConstraint(scip, maxchildrenmother, TRUE, FALSE) );
         else {
            SCIPerrorMessage("Can't use a limit on the maximum number of children a mother can have without using sexual consistency.\n");
            return SCIP_ERROR;
         }
      }
      if (maxchildrenfather != -1) {
         if (usingSexConsistency(scip))
            SCIP_CALL( addMaximumNumberOfOffspringConstraint(scip, maxchildrenfather, FALSE, TRUE) );
         else {
            SCIPerrorMessage("Can't use a limit on the maximum number of children a father can have without using sexual consistency.\n");
            return SCIP_ERROR;
         }
      }
      if (usingSexConsistency(scip))
         SCIP_CALL( addSexConsistencyConstraint(scip) );
      return SCIP_OKAY;
   }
}

// Functions related to the primal heuristic
/** Determines a possible assignment of the sex variables for a given primal solution.
 *
 *  If there is no possible assignment of sex variables (i.e. the primal is sexually
 *  inconsistent) then the function returns an appropriate error message.
 *
 *  @param scip The SCIP instance on which the heuristic is running.
 *  @param sol The heuristic solution being worked on.
 *  @param heurdata The heursitic data related to this primal heursitic.
 *  @param possible Will be set to TRUE if an assignment was possible.
 *  @return SCIP_OKAY if a consistent labelling could be found and was made to sol.
 *  An appropriate error code otherwise.
 */
static SCIP_RETCODE assignSexVariables(SCIP* scip, SCIP_SOL* sol, SCIP_HEURDATA* heurdata, SCIP_Bool* possible) {
   int i,k;
   int numTwoParents = 0;              // The number of individuals with two parents who haven't yet had sexes assigned
   SCIP_Bool isFinished[heurdata->n];  // TRUE iff we have dealt with all the parents of the node
   SCIP_Bool isSexed[heurdata->n];     // TRUE iff a sex has been assigned to the node
   SCIP_Bool isFemale[heurdata->n];    // TRUE if the node has been made female, FALSE if it has been made male and undefined if isSexed[i] == FALSE
   int chosenSet[heurdata->n];         // The parent set of i that is selected
   SCIP_Bool no_parents;
   SCIP_Bool assignment_made;
   int val;

   // Initialise the data structures
   for (i = 0; i < heurdata->n; i++) {
      isFinished[i] = FALSE;
      isSexed[i] = FALSE;
   }

   // Check if any sexes are already fixed
   for (i = 0; i < heurdata->n; i++)
      if (SCIPvarGetLbLocal(heurdata->ped->SexVars[i]) > 0.5) {
         isSexed[i] = TRUE;
         isFemale[i] = TRUE;
      } else if (SCIPvarGetUbLocal(heurdata->ped->SexVars[i]) < 0.5) {
         isSexed[i] = TRUE;
         isFemale[i] = FALSE;
      }

   // Quick pass through to find individuals with two parents
   for (i = 0; i < heurdata->n; ++i) {
      no_parents = TRUE;
      for (k = 0; k < heurdata->nParentSets[i]; ++k) {
         val = SCIPgetSolVal(scip, sol, heurdata->PaVars[i][k]);
         assert( SCIPisIntegral(scip, val) );
         if ( val > 0.5 ) {
            chosenSet[i] = k;
            if (heurdata->nParents[i][k] == 2)
               numTwoParents++;
            else
               isFinished[i] = TRUE;
            no_parents = FALSE;
            break;
         }
      }
      if (no_parents == TRUE)
         isFinished[i] = TRUE;
   }
   // Main loop
   // We assign sexes to any parent whose mate is already sexed
   // If that is not possible, we randomly assign sex to any individual
   while (numTwoParents > 0) {
      assignment_made = FALSE;
      for (i = 0; i < heurdata->n; i++) {
         if (isFinished[i] == FALSE) {
            int       parent1 = heurdata->ParentSets[i][chosenSet[i]][0];
            int       parent2 = heurdata->ParentSets[i][chosenSet[i]][1];
            SCIP_Bool known1  = isSexed[parent1];
            SCIP_Bool known2  = isSexed[parent2];
            if (known1 && known2) {
               if (isFemale[parent1] == isFemale[parent2]) {
                  // SEXUAL INCONSISTENT ASSIGNMENT
                  // Just exit and let the calling procedure deal with it
                  *possible = FALSE;
                  return SCIP_OKAY;
               } else {
                  // Just make it as done
                  isFinished[i] = TRUE;
                  numTwoParents--;
               }
            } else if (known1 && !known2) {
               // Assign parent2 the opposite sex
               if (isFemale[parent1])
                  SCIP_CALL( SCIPsetSolVal(scip, sol, heurdata->ped->SexVars[parent2], 0) );
               else
                  SCIP_CALL( SCIPsetSolVal(scip, sol, heurdata->ped->SexVars[parent2], 1) );
               isFemale[parent2] = !isFemale[parent1];
               isSexed[parent2] = TRUE;
               isFinished[i] = TRUE;
               numTwoParents--;
               assignment_made = TRUE;
            } else if (!known1 && known2) {
               // Assign parent1 the opposite sex
               if (isFemale[parent2])
                  SCIP_CALL( SCIPsetSolVal(scip, sol, heurdata->ped->SexVars[parent1], 0) );
               else
                  SCIP_CALL( SCIPsetSolVal(scip, sol, heurdata->ped->SexVars[parent1], 1) );
               isFemale[parent1] = !isFemale[parent2];
               isSexed[parent1] = TRUE;
               isFinished[i] = TRUE;
               numTwoParents--;
               assignment_made = TRUE;
            } else {
               // Can't do anything
            }
         }
      }
      if (assignment_made == FALSE && numTwoParents > 0) {
         // Need to make a random assignment
         // Make the first unsexed individual female
         i = 0;
         while (assignment_made == FALSE) {
            if (isSexed[i] == FALSE) {
               SCIP_CALL( SCIPsetSolVal(scip, sol, heurdata->ped->SexVars[i], 1) );
               isSexed[i] = TRUE;
               isFemale[i] = TRUE;
               assignment_made = TRUE;
            }
            i++;
         }
      }
   }

   //Go through and assign sexes to anyone still unsexed now
   for (i = 0; i < heurdata->n; i++)
      if (isSexed[i] == FALSE)
         SCIP_CALL( SCIPsetSolVal(scip, sol, heurdata->ped->SexVars[i], 1) );

   // All nodes have been assigned sexes in a consistent way
   *possible = TRUE;
   return SCIP_OKAY;
}
/** Trys to find values for any pedigree specific variables in a given primal solution.
 *
 *  If there is no possible assignment of pedigree variables then the function returns
 *  an appropriate error message.
 *
 *  @param scip The SCIP instance on which the heuristic is running.
 *  @param sol The heuristic solution being worked on.
 *  @param heurdata The heursitic data related to this primal heursitic.
 *  @param possible Returns whether a valid assignment was possible.
 *  @return SCIP_OKAY if a consistent labelling could be found and was made to sol.
 *  An appropriate error code otherwise.
 */
SCIP_RETCODE PD_assignPedigreeVariables(SCIP* scip, SCIP_SOL* sol, SCIP_HEURDATA* heurdata, SCIP_Bool* possible) {
   if (!checkSuitableForPedigree(scip)) {
      SCIPerrorMessage("The specified problem is not a valid pedigree problem.\n");
      *possible = FALSE;
      return SCIP_ERROR;
   } else {
      *possible = TRUE;
      if (usingSexConsistency(scip)) {
         SCIP_Bool sex_possible = TRUE;
         SCIP_CALL( assignSexVariables(scip, sol, heurdata, &sex_possible) );
         if (sex_possible == FALSE)
            *possible = FALSE;
      }
      return SCIP_OKAY;
   }
}
