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
 *  Main entry point for the program.
 *
 *  This file contains only general information about the sequence that operations
 *  should be performed in.  Much of what is in this file should be applicable to
 *  ILP problems in general, not just Bayesian network learning.  Functions that are
 *  more specific to BN learning are found in @link probdata_bn.c @endlink .
 */

/** @mainpage notitle
 *
 * @section whatisthis Should I be reading this documentation?
 * This is the documentation for the @b GOBNILP source code for development purposes.\n
 *
 * For help in using @b GOBNILP, see the PDF manual included in the distribution.\n
 *
 *
 *
 * @section overview Overview of the code layout
 *
 * @subsection overview_gobnilp gobnilp.c
 * The main entry point in to the code is in the file @c gobnilp.c .  This
 * file contains a single procedure mostly laying out the general order of operations for
 * a problem in SCIP.  The idea is that this main calling function should able to be
 * largely ignorant of how the underlaying implementation of the problem so that
 * representations and functionality can be altered without affecting the general order
 * of operations of the program.\n
 *
 * Unless you are adding a new plugin, command line parameter or altering the basic
 * workflow of the code, you probably shouldn't be making alterations in this file.\n
 *
 *
 *
 * @subsection overview_probdata probdata.c
 * The majority of operations that are more specific to Bayesian network learning are in
 * the file @c probdata_bn.c .  For example, the functions that create the
 * variables and constraints needed to learn BNs are found in this file.\n
 *
 * If adding a relatively small change in functionality to @b GOBNILP , this is probably
 * the first place to consider adding it.\n
 *
 *
 *
 * @subsection overview_pedigrees pedigrees.c
 * @b GOBNILP is capable of learning pedigrees in addition to general purpose Bayesian
 * network learning.  As much of the additional behaviour that this requires is unrelated
 * to normal Bayesian network learning, the code for it is all assembled in one place
 * where it can be altered without affecting the main program.  Any functions related to
 * pedigrees should appear in this file.  Outside @c pedigrees.c , the data and constraints
 * that the pedigree part of the program is using should be treated as a black box.\n
 *
 * A function @link PD_inPedigreeMode @endlink is defined which allows the rest of the
 * program to determine whether pedigrees are being used and call the appropriate
 * pedigree specific functions if so.\n
 *
 *
 *
 * @subsection overview_model_averaging model_averaging.c
 * @c model_averaging.c contains all the functionality to perform model averaging over
 * tbe n best networks found.  As far as possible, the fact that @b GOBNILP is capable
 * of model averaging should be hidden from other parts of the program.\n
 *
 * There are two exceptions to this.  First, @c gobnilp.c needs to know about model
 * averaging in order that it can make appropriate calls to perform the model averaging.
 * Second, @c output.c needs to be aware that the program can perform model averaging so
 * that the output functions can produce suitable output if a model average is to be
 * printed.
 *
 *
 *
 * @subsection overview_cons_dagcluster cons_dagcluster.c
 * Enforcing a constraint to rule out cycles in the Bayesian network is non-trivial.  The
 * approach in @b GOBNILP is to use &lsquo;cluster constraints&rsquo;.  As there are
 * exponentially many of these, they are added during solving as cutting planes.  All the
 * code associated with creating and updating these constraints is contained in
 * @c cons_dagcluster.c .\n
 *
 * Any extra functionality related to these cluster constraints
 * should be placed in this file.  Nothing should have any view of the cluster constraints
 * except for creating and including them in the problem.\n
 *
 *
 *
 * @subsection overview_heur_sinks heur_sinks.c
 * @c heur_sinks.c has most of the code necessary to implement a heuristic for finding
 * Bayesian networks.  In general, this file should be self contained, except for the
 * function needed to include the heuristic in the program.  The one excpetion to this is
 * that the heuristic shouldn't assign variables for the pedigree problem.  These should
 * instead be set from @c pedigrees.c in order to maintain the correct modularisation of
 * data.
 *
 *
 *
 * @subsection overview_output output.c
 * As the name suggests, @c output.c contains functions related to outputing data.  In
 * fact, with a small number of exceptions, all functions related to file output should
 * appear in this file.  The exceptions to this are those functions which would break
 * the modular nature of the program if put into this file.  At present, the only
 * substantial output function not appearing in this file is that for outputting
 * pedigrees, which instead appears in @c pedigrees.c .\n
 *
 * Functions appearing in this file for outputting solutions should also be capable of
 * sensible output when called with model averaging data.\n
 *
 *
 *
 * @subsection overview_utils utils.c
 * @c utils.c contains a number of functions that may be useful in several other files.\n
 *
 * At present these are shortcuts to several commonly used SCIP functions which have lots
 * of parameters but which are nearly always called with the same parameters for many of
 * these.  The functions in this file just make the rest of the code easier to read by
 * hiding this distraction.\n
 *
 *
 *
 * @subsection overview_versiongit versiongit.c
 * @c versiongit.c just contains some versioning information and probably shouldn't be
 * changed, except to update the version numbers.\n
 *
 *
 *
 * @subsection overview_data_structures data_structures.h
 * There is no @c data_structures.c file as the header file @c data_structures.h
 * doesn't contain any function declarations.  Instead it defines several
 * data structures that are used throughout the program.  Most importantly, this is
 * where the main data structure for storing instance data @c SCIP_ProbData
 * is defined.\n
 *
 * The data structure needed for moving pedigree related information around the program
 * is @c PedigreeData .  The structuring of the program means that this
 * should be treated as a black box by the program except for the pedigree related code.
 * However, as this data must be passed around the program as part of @c SCIP_ProbData
 * and @c SCIP_HeurData data structures, it must be declared here.
 *
 * @c SCIP_HeurData defines the data needed for an instance of
 * the sink primal heuristic.  While this is primarily needed by the heuristic itself,
 * it is also necessary for the part of the program handling pedigrees to be able to
 * access it in order to set any pedigree related variables to suitable values.
 *
 *
 *
 * @subsection overview_summary Summary
 * @c gobnilp.c has the overall structure of the program.  @c probdata_bn.c provides the
 * functions related to creating the Bayesian network problem.  @c data_structures.h
 * contain the main shared data structures for the programs.  Pedigree functions are
 * all in @c pedigrees.c , the behaviour of which should be separated from the rest of
 * the program, such that pedigree related constraints can be added or removed without
 * effecting the correctness of the rest of the program.  @c cons_dagcluster.c and @c
 * heur_sinks.c provide SCIP plugins and should be entirely self contained except for
 * calls to pedigree functions.  The program should be unaware of model averaging except
 * for calls from @c gobnilp.c and @c output.c .
 *
 */

#include <scip/scip.h>
#include "probdata_bn.h"
#include "model_averaging.h"

/** Main function which starts the solution of the BN learning problem.
 *  @param argc The number of command line arguments supplied to the program.
 *  @param argv The command line arguments supplied to the program.
 */
int main(int argc, char** argv) {
   SCIP* scip = NULL;
   const char* filename;
   int i, nbns;
   SCIP_Bool foundAll = FALSE;

   // Initialize SCIP and add plugins
   SCIP_CALL( SCIPcreate(&scip) );
   SCIP_CALL( BN_printHeader(scip) );
   SCIP_CALL( BN_includePlugins(scip) );

   // Read the parameters
   SCIP_CALL( BN_readCommandLineArgs(scip, argc, argv) );
   SCIP_CALL( BN_addParameters(scip) );
   filename = BN_getParameterFile();
   if( SCIPfileExists(filename) ) {
      printf("reading parameter file <%s>\n", filename);
      SCIP_CALL( SCIPreadParams(scip, filename) );
   } else {
      printf("parameter file <%s> not found.\n", filename);
      return SCIP_NOFILE;
   }
   SCIP_CALL( BN_printParameters(scip) );

   // Read problem data
   SCIP_CALL( BN_createProb(scip, argv[argc-1]) );

   // Generate BN learning model
   SCIP_CALL( BN_generateModel(scip) );
   SCIP_CALL( MA_createAverageDataStructure(scip) );

   // Solve the model (n times)
   nbns = BN_getNumberOfRepeats(scip);
   for ( i = 0; i < nbns && !foundAll; i++ ) {
      SCIP_CALL( SCIPsolve(scip) );
      if (SCIPgetBestSol(scip) == NULL) {
         if (i == 0)
            printf("No solutions possible.\n");
         else
            printf("No further solutions possible.\n");
         foundAll = TRUE;
      } else {
         SCIP_CALL( MA_updateAverageDataStructure(scip, SCIPgetBestSol(scip)) );
         SCIP_CALL( BN_doIterativePrint(scip, i) );
         SCIP_CALL( BN_addNonRepetitionConstraint(scip, i) );
      }
   }

   // Deallocate any memory being used
   SCIP_CALL( MA_destroyAverageDataStructure(scip) );
   SCIP_CALL( SCIPfree(&scip) );
   BMScheckEmptyMemory();

   return 0;
}
