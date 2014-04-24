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
 *  Contains all the functions related to writing data to files.
 */

#include "output.h"
#include "data_structures.h"
#include "pedigrees.h"
#include "model_averaging.h"
#include "utils.h"
#include "versiongit.c"
#include <string.h>

/** Adds the parameters to SCIP related to outputing results.
 *
 *  These parameters consist of all those of the form @c gobnilp/outputfile/\<param\> .
 *  Some other output parameters exist, but these can be currently found in probdata_bn.c .
 *
 * @param scip The SCIP instance to which parameters should be added.
 * @return SCIP_OKAY if all the parameters were added successfully, or an error otherwise.
 */
SCIP_RETCODE IO_addOutputParameters(SCIP* scip) {
   SCIP_CALL(UT_addStringParam(scip,
      "gobnilp/outputfile/solution",
      "file which solution should be printed to (stdout for standard out, empty string for nowhere)",
      "stdout"
   ));

   SCIP_CALL(UT_addStringParam(scip,
      "gobnilp/outputfile/dot",
      "file which dot output should be printed to (stdout for standard out, empty string for nowhere)",
      ""
   ));

   SCIP_CALL(UT_addStringParam(scip,
      "gobnilp/outputfile/pedigree",
      "file which pedigree output should be printed to (stdout for standard out, empty string for nowhere)",
      ""
   ));

   SCIP_CALL(UT_addStringParam(scip,
      "gobnilp/outputfile/scoreandtime",
      "file which additional score and time data should be printed to (stdout for standard out, empty string for nowhere)",
      ""
   ));

   SCIP_CALL(UT_addStringParam(scip,
      "gobnilp/outputfile/adjacencymatrix",
      "file which adjacency matrix output should be printed to (stdout for standard out, empty string for nowhere)",
      ""
   ));

   SCIP_CALL(UT_addIntParam(scip,
      "gobnilp/avgoutputoffset",
      "how many iterations to skip before first model averaging output (-1 to suppress always)",
      -1
   ));

   SCIP_CALL(UT_addIntParam(scip,
      "gobnilp/avgoutputstep",
      "how many iterations between outputting model averaging information",
      1
   ));

   SCIP_CALL(UT_addStringParam(scip,
      "gobnilp/outputfile/solutionavg",
      "file which model averging solution should be printed to (stdout for standard out, empty string for nowhere)",
      "stdout"
   ));

   SCIP_CALL(UT_addStringParam(scip,
      "gobnilp/outputfile/dotavg",
      "file which model averging dot output should be printed to (stdout for standard out, empty string for nowhere)",
      ""
   ));

   SCIP_CALL(UT_addStringParam(scip,
      "gobnilp/outputfile/pedigreeavg",
      "file which model averging pedigree output should be printed to (stdout for standard out, empty string for nowhere)",
      ""
   ));

   SCIP_CALL(UT_addStringParam(scip,
      "gobnilp/outputfile/scoreandtimeavg",
      "file which model averging additional score and time data should be printed to (stdout for standard out, empty string for nowhere)",
      ""
   ));

   SCIP_CALL(UT_addStringParam(scip,
      "gobnilp/outputfile/adjacencymatrixavg",
      "file which model averging adjacency matrix output should be printed to (stdout for standard out, empty string for nowhere)",
      ""
   ));

   return SCIP_OKAY;
}

/** Prints the solution in the traditional GOBNILP format.
 *
 *  @param scip The SCIP instance to which the solution belongs.
 *  @param probdata The problem data used by the solution.
 *  @param Scores The score data to use for the solution.
 *  @param selected Whether each of the variables is selected in the solution.
 *  @param total_score The overall score of this solution.
 *  @param stream Where to print the solution.
 *  @return SCIP_OKAY if the solution was printed correctly or an appropriate error message otherwise.
 */
static SCIP_RETCODE printSolutionLegacyFormat(SCIP* scip, SCIP_PROBDATA* probdata, SCIP_Real** Scores, SCIP_Bool** selected, SCIP_Real total_score, FILE* stream) {
   int i,k,l;
   SCIP_Bool no_parents;

   for (i = 0; i < probdata->n; ++i) {
      no_parents = TRUE;
      for (k = 0; k < probdata->nParentSets[i]; ++k) {
         if ( selected[i][k] ) {
            fprintf(stream, "%s<-",probdata->nodeNames[i]);
            for ( l=0; l<probdata->nParents[i][k]; ++l )
               fprintf(stream, "%s,",probdata->nodeNames[probdata->ParentSets[i][k][l]]);
            fprintf(stream, " %f\n",Scores[i][k]);
            no_parents = FALSE;
         }
      }
      if ( no_parents ) {
         fprintf(stream, " ,");
         fprintf(stream, " %f\n",Scores[i][probdata->nParentSets[i]-1]);
      }
   }
   fprintf(stream, "BN score is %f\n",total_score);
   return SCIP_OKAY;
}

/** Prints the solution in a Bayesian network format.
 *
 *  @param scip The SCIP instance to which the solution belongs.
 *  @param probdata The problem data used by the solution.
 *  @param Scores The score data to use for the solution.
 *  @param selected Whether each of the variables is selected in the solution.
 *  @param total_score The overall score of this solution.
 *  @param stream Where to print the solution.
 *  @return SCIP_OKAY if the solution was printed correctly or an appropriate error message otherwise.
 */
static SCIP_RETCODE printSolutionBNFormat(SCIP* scip, SCIP_PROBDATA* probdata, SCIP_Real** Scores, SCIP_Bool** selected, SCIP_Real total_score, FILE* stream) {
   int i,k,l;
   SCIP_Bool no_parents;

   for (i = 0; i < probdata->n; ++i) {
      SCIP_Bool first_line = TRUE;
      no_parents = TRUE;
      fprintf(stream, "%s\t<-",probdata->nodeNames[i]);
      for (k = 0; k < probdata->nParentSets[i]; ++k) {
         if ( selected[i][k] ) {
            if (first_line)
               first_line = FALSE;
            else
               fprintf(stream, "\t");
            fprintf(stream, "\t{");
            for ( l=0; l<probdata->nParents[i][k]-1; ++l ) {
               fprintf(stream, "%s,",probdata->nodeNames[probdata->ParentSets[i][k][l]]);
            }
            if (probdata->nParents[i][k] > 0)
               fprintf(stream, "%s",probdata->nodeNames[probdata->ParentSets[i][k][probdata->nParents[i][k]-1]]);
            fprintf(stream, "}\t%f\n",Scores[i][k]);
            no_parents = FALSE;
         }
      }
      if ( no_parents )
         fprintf(stream, "{}\t%f\n",Scores[i][probdata->nParentSets[i]-1]);
   }
   fprintf(stream, "BN score is %f\n",total_score);
   return SCIP_OKAY;
}

/** Prints the solution as a file suitable for plotting using the dot command from graphviz.
 *
 *  @param scip The SCIP instance to which the solution belongs.
 *  @param probdata The problem data used by the solution.
 *  @param Scores The score data to use for the solution.
 *  @param selected Whether each of the variables is selected in the solution.
 *  @param total_score The overall score of this solution.
 *  @param stream Where to print the solution.
 *  @return SCIP_OKAY if the solution was printed correctly or an appropriate error message otherwise.
 */
static SCIP_RETCODE printSolutionDotFormat(SCIP* scip, SCIP_PROBDATA* probdata, SCIP_Real** Scores, SCIP_Bool** selected, SCIP_Real total_score, FILE* stream) {
   int i,j,k,l;
   SCIP_Real **matrix;
   SCIP_Bool one_per_row;

   SCIP_CALL( SCIPallocMemoryArray(scip, &matrix, probdata->n) );
   for (i = 0; i < probdata->n; ++i)
      SCIP_CALL( SCIPallocClearMemoryArray(scip, &(matrix[i]), probdata->n) );

   one_per_row = TRUE;
   for (j = 0; j < probdata->n; ++j) {
      int entries_this_row = 0;
      for (k = 0; k < probdata->nParentSets[j]; ++k)
         if (selected[j][k])
            entries_this_row +=1;
      if (entries_this_row != 1)
         one_per_row = FALSE;
   }

   for (j = 0; j < probdata->n; ++j)
      for (k = 0; k < probdata->nParentSets[j]; ++k)
         if (selected[j][k]) {
            for ( l=0; l<probdata->nParents[j][k]; ++l ) {
               if (one_per_row)
                  matrix[probdata->ParentSets[j][k][l]][j] = 1 ;
               else
                  matrix[probdata->ParentSets[j][k][l]][j] += Scores[j][k] ;
            }
         }

   fprintf(stream, "digraph {\n");
   for (i = 0; i < probdata->n; ++i)
      fprintf(stream, "   %s;\n",probdata->nodeNames[i]);
   for (i = 0; i < probdata->n; ++i)
      for (k = 0; k < probdata->n; ++k)
         if ( matrix[i][k] != 0) {
            fprintf(stream, "   %s -> %s",probdata->nodeNames[i], probdata->nodeNames[k]);
            if (!one_per_row)
               fprintf(stream, "[penwidth=%d]",(int)(10*matrix[i][k]+0.4999999));
            fprintf(stream, ";\n");
         }
   fprintf(stream, "}\n");


   for ( i = 0 ; i < probdata->n ; ++i)
      SCIPfreeMemoryArray(scip, &(matrix[i]));
   SCIPfreeMemoryArray(scip, &matrix);

   return SCIP_OKAY;
}

/** Prints the solution as an adjacency matrix.
 *
 *  @param scip The SCIP instance to which the solution belongs.
 *  @param probdata The problem data used by the solution.
 *  @param Scores The score data to use for the solution.
 *  @param selected Whether each of the variables is selected in the solution.
 *  @param total_score The overall score of this solution.
 *  @param stream Where to print the solution.
 *  @return SCIP_OKAY if the solution was printed correctly or an appropriate error message otherwise.
 */
static SCIP_RETCODE printSolutionAdjacencyMatrixFormat(SCIP* scip, SCIP_PROBDATA* probdata, SCIP_Real** Scores, SCIP_Bool** selected, SCIP_Real total_score, FILE* stream) {
   int i,j,k,l;
   SCIP_Real **matrix;
   SCIP_Bool one_per_row;

   SCIP_CALL( SCIPallocMemoryArray(scip, &matrix, probdata->n) );
   for (i = 0; i < probdata->n; ++i)
      SCIP_CALL( SCIPallocClearMemoryArray(scip, &(matrix[i]), probdata->n) );

   one_per_row = TRUE;
   for (j = 0; j < probdata->n; ++j) {
      int entries_this_row = 0;
      for (k = 0; k < probdata->nParentSets[j]; ++k)
         if (selected[j][k])
            entries_this_row +=1;
      if (entries_this_row != 1)
         one_per_row = FALSE;
   }

   for (j = 0; j < probdata->n; ++j)
      for (k = 0; k < probdata->nParentSets[j]; ++k)
         if (selected[j][k]) {
            for ( l=0; l<probdata->nParents[j][k]; ++l ) {
               if (one_per_row)
                  matrix[probdata->ParentSets[j][k][l]][j] = 1 ;
               else
                  matrix[probdata->ParentSets[j][k][l]][j] += Scores[j][k] ;
            }
         }

   for (i = 0; i < probdata->n; ++i) {
      for (j = 0; j < (probdata->n)-1; ++j)
         if (one_per_row)
            fprintf(stream, "%d ",(int)matrix[i][j]);
         else
            fprintf(stream, "%f ",matrix[i][j]);
      if (one_per_row)
         fprintf(stream, "%d\n",(int)matrix[i][j]);
      else
         fprintf(stream, "%f\n",matrix[i][j]);
   }

   for ( i = 0 ; i < probdata->n ; ++i)
      SCIPfreeMemoryArray(scip, &(matrix[i]));
   SCIPfreeMemoryArray(scip, &matrix);

   return SCIP_OKAY;
}

/** Prints just the objective value of the given solution and the time taken to find the solution.
 *
 *  @param scip The SCIP instance to which the solution belongs.
 *  @param probdata The problem data used by the solution.
 *  @param Scores The score data to use for the solution.
 *  @param selected Whether each of the variables is selected in the solution.
 *  @param total_score The overall score of this solution.
 *  @param stream Where to print the solution.
 *  @param time The time taken to find the solution.
 *  @return SCIP_OKAY if the solution was printed correctly or an appropriate error message otherwise.
 */
static SCIP_RETCODE printSolutionScoreAndTimeFormat(SCIP* scip, SCIP_PROBDATA* probdata, SCIP_Real** Scores, SCIP_Bool** selected, SCIP_Real total_score, FILE* stream, SCIP_Real time) {
   fprintf(stream, "%f\t%f\n",total_score, time);
   return SCIP_OKAY;
}

/** Prints a solution to the problem.
 *
 *  @param scip The SCIP instance for which to print the solution.
 *  @param probdata The problem data used by the solution.
 *  @param Scores The score data to use for the solution.
 *  @param selected Whether each of the variables is selected in the solution.
 *  @param total_score The overall score of this solution.
 *  @param filename The filename to output to, "stdout" for stdout or "" for nowhere.
 *  @param format The format in which to print the solution.  Recognised values are dot, pedigree, scoreandtime, legacy, adjacencymatrx and normal.
 *  @param time The time taken to find the solution.
 *  @param pedVals Whether each of the pedigree specific variables is selected in the solution.
 *  @return SCIP_OKAY if the solution was printed correctly or an appropriate error message otherwise.
 */
static SCIP_RETCODE printToFile(SCIP* scip, SCIP_PROBDATA* probdata, SCIP_Real** Scores, SCIP_Bool** selected, char* filename, char* format, SCIP_Real time, SCIP_Real total_score, SCIP_Bool* pedVals) {
   // Open the file for writing
   FILE* file;
   if (strcmp(filename,"") == 0)
      return SCIP_OKAY;
   else if (strcmp(filename,"stdout") == 0)
      file = stdout;
   else {
      file = fopen(filename, "w");
      printf("Writing output to %s\n", filename);
   }
   if ( file == NULL ) {
      SCIPerrorMessage("Could not open file %s for writing.\n", filename);
      return SCIP_WRITEERROR;
   }

   // Print the solution to the file
   if (strcmp(format,"dot") == 0)
      printSolutionDotFormat(scip, probdata, Scores, selected, total_score, file);
   else if (strcmp(format,"pedigree") == 0)
      PD_printSolutionPedigreeFormat(scip, probdata, Scores, selected, total_score, file, pedVals);
   else if (strcmp(format,"scoreandtime") == 0)
      printSolutionScoreAndTimeFormat(scip, probdata, Scores, selected, total_score, file, time);
   else if (strcmp(format,"legacy") == 0)
      printSolutionLegacyFormat(scip, probdata, Scores, selected, total_score, file);
   else if (strcmp(format,"adjacencymatrix") == 0)
      printSolutionAdjacencyMatrixFormat(scip, probdata, Scores, selected, total_score, file);
   else
      printSolutionBNFormat(scip, probdata, Scores, selected, total_score, file);

   // Close the file
   if (file != stdout)
      fclose(file);

   return SCIP_OKAY;
}

/** Prints the solution of the problem after solving.
 *
 *  @param scip The SCIP instance for which to print the solution.
 *  @param filename The filename to output to, "stdout" for stdout or "" for nowhere.
 *  @param format The format in which to print the solution.  Recognised values are dot, pedigree, scoreandtime, legacy, adjacencymatrx and normal.
 *  @return SCIP_OKAY if the solution was printed correctly or an appropriate error message otherwise.
 */
static SCIP_RETCODE printSolution(SCIP* scip, char* filename, char* format) {
   SCIP_PROBDATA* probdata = SCIPgetProbData(scip);
   SCIP_SOL* sol = SCIPgetBestSol(scip);
   SCIP_Real** Scores;
   SCIP_Bool** selected;
   SCIP_Bool* pedVals = NULL;
   int i,j;
   SCIP_Real total_score = 0;

   SCIP_CALL( SCIPallocClearMemoryArray(scip, &selected, probdata->n) );
   SCIP_CALL( SCIPallocClearMemoryArray(scip, &Scores, probdata->n) );
   for (i = 0; i < probdata->n; i++) {
      SCIP_CALL( SCIPallocClearMemoryArray(scip, &(selected[i]), probdata->nParentSets[i]) );
      SCIP_CALL( SCIPallocClearMemoryArray(scip, &(Scores[i]), probdata->nParentSets[i]) );
   }

   for (i =0; i < probdata->n; i++)
      for (j =0; j < probdata->nParentSets[i]; j++)
         if (SCIPgetSolVal(scip, sol, probdata->PaVars[i][j]) > 0.5) {
            selected[i][j] = TRUE;
            Scores[i][j] = probdata->Scores[i][j];
            total_score += probdata->Scores[i][j];
         } else {
            selected[i][j] = FALSE;
            Scores[i][j] = 0;
         }

   if (PD_inPedigreeMode(scip))
      pedVals = PD_getCurrentPedigreeVarValues(scip);

   SCIP_CALL( printToFile(scip, probdata, Scores, selected, filename, format, SCIPgetSolvingTime(scip), total_score, pedVals) );

   for (i = 0; i < probdata->n; i++) {
      SCIPfreeMemoryArray(scip, &(Scores[i]));
      SCIPfreeMemoryArray(scip, &(selected[i]));
   }
   SCIPfreeMemoryArray(scip, &Scores);
   SCIPfreeMemoryArray(scip, &selected);
   if (pedVals != NULL)
      SCIPfreeMemoryArray(scip, &pedVals);

   return SCIP_OKAY;
}

/** Prints the model average data.
 *
 *  @param scip The SCIP instance for which to print the averages.
 *  @param filename The filename to output to, "stdout" for stdout or "" for nowhere.
 *  @param format The format in which to print the averages.  Recognised values are dot, pedigree, scoreandtime, legacy, adjacencymatrx and normal.
 *  @return SCIP_OKAY if the averages were printed correctly or an appropriate error message otherwise.
 */
static SCIP_RETCODE printAverages(SCIP* scip, char* filename, char* format) {
   int i,j;
   SCIP_Real** Scores;
   SCIP_Bool** selected;
   SCIP_PROBDATA* probdata = SCIPgetProbData(scip);

   // Allocate memory
   SCIP_CALL( SCIPallocClearMemoryArray(scip, &Scores, probdata->n) );
   SCIP_CALL( SCIPallocClearMemoryArray(scip, &selected, probdata->n) );
   for (i = 0; i < probdata->n; i++) {
      SCIP_CALL( SCIPallocClearMemoryArray(scip, &(Scores[i]), probdata->nParentSets[i]) );
      SCIP_CALL( SCIPallocClearMemoryArray(scip, &(selected[i]), probdata->nParentSets[i]) );
   }

   // Get data and print it
   SCIP_CALL( MA_getAverageDataStructure(scip, &Scores) );
   for (i = 0; i < probdata->n; i++)
      for (j = 0; j < probdata->nParentSets[i]; j++)
         if (Scores[i][j] != 0)
            selected[i][j] = TRUE;
         else
            selected[i][j] = FALSE;
   SCIP_CALL( printToFile(scip, probdata, Scores, selected, filename, format, MA_getTotalAveragesTime(), MA_getTotalAveragesScore(), NULL) );

   // Deallocate memory
   for (i = 0; i < probdata->n; i++) {
      SCIPfreeMemoryArray(scip, &(Scores[i]));
      SCIPfreeMemoryArray(scip, &(selected[i]));
   }
   SCIPfreeMemoryArray(scip, &Scores);
   SCIPfreeMemoryArray(scip, &selected);

   return SCIP_OKAY;
}

/** Prints the solution in SCIP format and the Markov equivalence class.
 *
 *  @return SCIP_OKAY if printing succeeded or an appropriate error code otherwise.
 */
static SCIP_RETCODE BNevalSolution(
   SCIP*                 scip                /**< SCIP data structure */
   )
{
   SCIP_PROBDATA* probdata;
   SCIP_SOL* sol;
   int i,j,k,l;

   SCIP_Real val = 0.0;
   SCIP_Bool printscipsol;
   SCIP_Bool printmecinfo;

   int** edges;
   int parent1;
   int parent2;
   int ll;

   SCIPgetBoolParam(scip,"gobnilp/printscipsol",&printscipsol);
   SCIPgetBoolParam(scip,"gobnilp/printmecinfo",&printmecinfo);

   /* get problem data */
   probdata = SCIPgetProbData(scip);
   assert( probdata != NULL );
   assert( probdata->PaVars != NULL );
   assert( probdata->nParentSets != NULL );
   assert( probdata->ParentSets != NULL );
   assert( probdata->nParents != NULL );
   assert( probdata->Scores != NULL );

   sol = SCIPgetBestSol(scip);

   if ( printscipsol )
      SCIP_CALL( SCIPprintSol(scip,sol,NULL,FALSE) );

   if ( printmecinfo )
   {
      SCIP_CALL( SCIPallocMemoryArray(scip, &edges, probdata->n) );

      for (i = 0; i < probdata->n; ++i)
    SCIP_CALL( SCIPallocClearMemoryArray(scip, &(edges[i]), probdata->n) );

      /* skeleton */

      printf("START MEC info\n");

      for (i = 0; i < probdata->n; ++i)
    for (k = 0; k < probdata->nParentSets[i]; ++k)
    {
       val = SCIPgetSolVal(scip, sol, probdata->PaVars[i][k]);
       assert( SCIPisIntegral(scip, val) );
       if ( val > 0.5 )
       {
          for ( l = 0; l < probdata->nParents[i][k]; ++l )
          {
        j = probdata->ParentSets[i][k][l];
        edges[i][j] = TRUE;
        edges[j][i] = TRUE;

          }
       }
    }

      for (i = 0; i < probdata->n; ++i)
    for (j = i+1; j < probdata->n; ++j)
       if ( edges[i][j] )
          printf("%s-%s\n",probdata->nodeNames[i],probdata->nodeNames[j]);


      /* immoralities */

      for (i = 0; i < probdata->n; ++i)
    for (k = 0; k < probdata->nParentSets[i]; ++k)
    {
       val = SCIPgetSolVal(scip, sol, probdata->PaVars[i][k]);
       assert( SCIPisIntegral(scip, val) );
       if ( val > 0.5 )
          for ( l = 0; l < probdata->nParents[i][k]; ++l )
          {
        parent1 = probdata->ParentSets[i][k][l];
        for ( ll = l+1; ll < probdata->nParents[i][k]; ++ll )
        {
           parent2 = probdata->ParentSets[i][k][ll];
           if ( !edges[parent1][parent2] )
         printf("%s->%s<-%s\n",probdata->nodeNames[parent1],probdata->nodeNames[i],probdata->nodeNames[parent2]);
        }
          }
    }

      printf("END MEC info\n");
      for ( i = 0 ; i < probdata->n ; ++i)
      {
    SCIPfreeMemoryArray(scip, &(edges[i]));
      }
      SCIPfreeMemoryArray(scip, &edges);
   }
   return SCIP_OKAY;
}



/** Finds the location in a string of the file extension.
 *
 *  @param filename The filename to inspect.
 *  @return The location of the "." marking the beginning of the file extension, or -1 if there is no extension.
 */
static int findExtension(char* filename) {
   int i;
   for (i = strlen(filename); i >= 0; i--)
      if (filename[i] == '.')
         return i;
      else if (filename[i] == '/')
         return -1;
   return -1;
}

/** Constructs a filename for output for a particular iteration of the program.
 *
 *  The filename constructed will be the input filename the iteration number appearing before the file extension
 *  or appended if there is no extension.  If there is only a single network to find, then the iteration number is
 *  not inserted.  For special values ("" and "stdout"), the value returned is the same value as given as input.
 *
 *  @param filename The filename to insert the string in to.
 *  @param nbns The number of Bayesian networks that the program is trying to find.
 *  @param iteration The current iteration of the program.
 *  @return The filename that should be used for output.
 */
static char* createFilename(char* filename, int nbns, int iteration) {
   if (strcmp(filename, "") == 0)
      // Blank string is a special string meaning nowhere
      return filename;
   else if (strcmp(filename, "stdout") == 0)
      // stdout is a special string meaning standard output
      return filename;
   else if (nbns == 1)
      // If only one BN, there is no need to add iteration numbers
      return filename;
   else {
      // Need to add iteration numbers for each BN
      int i;
      int extpos;
      char* ans;
      char insertion[SCIP_MAXSTRLEN];
      sprintf(insertion, "_%d", iteration+1);
      ans = malloc((strlen(filename)+strlen(insertion)+1) * sizeof(char));
      extpos = findExtension(filename);
      if (extpos == -1) {
         for (i = 0; i < (int)strlen(filename); i++)
            ans[i] = filename[i];
         for (i = 0; i < (int)strlen(insertion); i++)
            ans[i+strlen(filename)] = insertion[i];
         ans[strlen(filename)+strlen(insertion)] = '\0';
      } else {
         for (i = 0; i < extpos; i++)
            ans[i] = filename[i];
         for (i = 0; i < (int)strlen(insertion); i++)
            ans[i+extpos] = insertion[i];
         for (i = extpos; i < (int)strlen(filename); i++)
            ans[i+strlen(insertion)] = filename[i];
         ans[strlen(filename)+strlen(insertion)] = '\0';
      }
      return ans;
   }
}

/** Prints appropriate information about each optimal solution obtained.
 *
 *  @param scip The SCIP instance for which the solution has been found.
 *  @param run The iteration of the main loop that the solution was found on.
 *  @return SCIP_OKAY if printing succeeded or an appropriate error code otherwise.
 */
SCIP_RETCODE IO_doIterativePrint(SCIP* scip, int run) {
   char* solfile;
   char* dotfile;
   char* pedfile;
   char* satfile;
   char* matfile;

   int avgoutputoffset;
   int avgoutputstep;
   char* avgsolfile;
   char* avgdotfile;
   char* avgpedfile;
   char* avgsatfile;
   char* avgmatfile;

   SCIP_Bool printstatistics;
   SCIP_Bool printbranchingstatistics;
   char* statisticsfile;
   FILE* statsfile;

   int nbns;
   SCIPgetIntParam(scip,"gobnilp/nbns", &nbns);

   SCIPgetStringParam(scip,"gobnilp/outputfile/solution", &solfile);
   SCIPgetStringParam(scip,"gobnilp/outputfile/dot", &dotfile);
   SCIPgetStringParam(scip,"gobnilp/outputfile/pedigree", &pedfile);
   SCIPgetStringParam(scip,"gobnilp/outputfile/scoreandtime", &satfile);
   SCIPgetStringParam(scip,"gobnilp/outputfile/adjacencymatrix", &matfile);

   SCIPgetIntParam(scip,"gobnilp/avgoutputoffset", &avgoutputoffset);
   SCIPgetIntParam(scip,"gobnilp/avgoutputstep", &avgoutputstep);
   SCIPgetStringParam(scip,"gobnilp/outputfile/solutionavg", &avgsolfile);
   SCIPgetStringParam(scip,"gobnilp/outputfile/dotavg", &avgdotfile);
   SCIPgetStringParam(scip,"gobnilp/outputfile/pedigreeavg", &avgpedfile);
   SCIPgetStringParam(scip,"gobnilp/outputfile/scoreandtimeavg", &avgsatfile);
   SCIPgetStringParam(scip,"gobnilp/outputfile/adjacencymatrixavg", &avgmatfile);

   SCIPgetBoolParam(scip,"gobnilp/printstatistics", &printstatistics);
   SCIPgetBoolParam(scip,"gobnilp/printbranchingstatistics", &printbranchingstatistics);
   SCIPgetStringParam(scip,"gobnilp/statisticsfile", &statisticsfile);

   if ( strcmp(statisticsfile,"") != 0 ) {
      statsfile = fopen(statisticsfile, "w");
      if ( statsfile == NULL ) {
         SCIPerrorMessage("Could not open file %s.\n", statisticsfile);
         return SCIP_NOFILE;
      }
   } else
      statsfile = NULL;

   if ( printstatistics )
      SCIP_CALL( SCIPprintStatistics(scip, statsfile) );

   if ( printbranchingstatistics )
      SCIP_CALL( SCIPprintBranchingStatistics(scip, statsfile) );

   SCIP_CALL( printSolution(scip, createFilename(solfile, nbns, run), (char*)"legacy") );
   SCIP_CALL( printSolution(scip, createFilename(dotfile, nbns, run), (char*)"dot") );
   SCIP_CALL( printSolution(scip, createFilename(pedfile, nbns, run), (char*)"pedigree") );
   SCIP_CALL( printSolution(scip, createFilename(satfile, nbns, run), (char*)"scoreandtime") );
   SCIP_CALL( printSolution(scip, createFilename(matfile, nbns, run), (char*)"adjacencymatrix") );

   SCIP_CALL( BNevalSolution(scip) );

   if (avgoutputoffset > -1 && (run+1) >= avgoutputoffset) {
      if ((run - avgoutputoffset + 1) % avgoutputstep == 0) {
         SCIP_CALL( printAverages(scip, createFilename(avgsolfile, nbns, run), (char*)"legacy") );
         SCIP_CALL( printAverages(scip, createFilename(avgdotfile, nbns, run), (char*)"dot") );
         SCIP_CALL( printAverages(scip, createFilename(avgpedfile, nbns, run), (char*)"pedigree") );
         SCIP_CALL( printAverages(scip, createFilename(avgsatfile, nbns, run), (char*)"scoreandtime") );
         SCIP_CALL( printAverages(scip, createFilename(avgmatfile, nbns, run), (char*)"adjacencymatrix") );
      }
   }

   return SCIP_OKAY;
}

/** Prints any of the current SCIP or GOBNILP parameters not at their default value.
 *
 *  @param scip The SCIP instance to consult the parameters of.
 *  @return SCIP_OKAY if the parameters were printed correctly, or an error code otherwise.
 */
SCIP_RETCODE IO_printParameters(SCIP* scip) {
   SCIP_Bool printparameters;
   SCIPgetBoolParam(scip,"gobnilp/printparameters", &printparameters);

   if ( printparameters ) {
      printf("START Parameters not at default value\n");
      SCIP_CALL( SCIPwriteParams(scip,NULL,FALSE,TRUE) );
      printf("END Parameters not at default value\n");
      fflush(stdout);
   }

   return SCIP_OKAY;
}

/** Prints a header which describes the GOBNILP and SCIP systems being used.
 *
 *  @param scip The SCIP instance that is being used.
 *  @return SCIP_OKAY if printing succeeded or an error code otherwise.
 */
SCIP_RETCODE IO_printHeader(SCIP* scip) {
   // output version information
   printf("GOBNILP version %s [GitHash: %s ]\n", GOBNILP_VERSION, GOBNILP_GITHASH);
   printf("Solving the BN structure learning problem using SCIP.\n\n");
#if SCIP_VERSION >= 300
   assert( scip != NULL );
   SCIPprintVersion(scip,NULL);
#else
   SCIPprintVersion(NULL);
#endif
   printf("\n");
   return SCIP_OKAY;
}
