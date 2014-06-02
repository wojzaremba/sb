/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *   GOBNILP Copyright (C) 2012 James Cussens                            *
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
 *  Function declarations for probdata_bn.c
 */

/*
This file was created by editing the file probdata_lop.h that comes with the linear ordering example
in SCIP
*/

#ifndef __BN_PROBDATA_BN__
#define __BN_PROBDATA_BN__

#include <scip/scip.h>

extern SCIP_RETCODE BN_readCommandLineArgs(SCIP* scip, int argc, char** argv);
extern        char* BN_getParameterFile(void);
extern SCIP_RETCODE BN_doIterativePrint(SCIP* scip, int run);
extern SCIP_RETCODE BN_printParameters(SCIP* scip);
extern SCIP_RETCODE BN_printHeader(SCIP* scip);
extern SCIP_RETCODE BN_includePlugins(SCIP* scip);
extern SCIP_RETCODE BN_createProb(SCIP* scip, const char* filename);
extern SCIP_RETCODE BN_generateModel(SCIP* scip);
extern SCIP_RETCODE BN_addNonRepetitionConstraint(SCIP* scip, int run);
extern SCIP_RETCODE BN_addParameters(SCIP* scip);
extern          int BN_getNumberOfRepeats(SCIP* scip);
#endif
