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
 *  Function declarations for pedigrees.c
 */

#ifndef __PEDIGREES_H__
#define __PEDIGREES_H__

#include <scip/scip.h>

extern SCIP_Bool    PD_inPedigreeMode(SCIP* scip);
extern SCIP_RETCODE PD_addPedigreeParameters(SCIP* scip);
extern SCIP_RETCODE PD_readPedigreeData(SCIP* scip, SCIP_PROBDATA* probdata);
extern SCIP_RETCODE PD_addPedigreeVariables(SCIP* scip);
extern SCIP_RETCODE PD_addPedigreeConstraints(SCIP* scip);
extern SCIP_RETCODE PD_assignPedigreeVariables(SCIP* scip, SCIP_SOL* sol, SCIP_HEURDATA* heurdata, SCIP_Bool* possible);
extern SCIP_Bool*   PD_getCurrentPedigreeVarValues(SCIP* scip);
extern SCIP_RETCODE PD_printSolutionPedigreeFormat(SCIP* scip, SCIP_PROBDATA* probdata, SCIP_Real** Scores, SCIP_Bool** selected, SCIP_Real total_score, FILE* stream, SCIP_Bool* pedvars);
extern SCIP_RETCODE PD_freePedigreeData(SCIP* scip);

#endif
