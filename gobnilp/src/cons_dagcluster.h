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
 *  Function declarations for cons_dagcluster.c
 */

/*
 *
This file was created by editing the constraint handler template header file
in SCIP
*/

#ifndef __SCIP_CONS_DAGCLUSTER_H__
#define __SCIP_CONS_DAGCLUSTER_H__

#include "scip/scip.h"

extern SCIP_RETCODE DC_includeConshdlr(SCIP* scip);
extern SCIP_RETCODE DC_createCons(SCIP* scip, SCIP_CONS** cons, const char* name, int n, int* nParentSets, int** nParents, int*** ParentSets,
                                             SCIP_VAR*** PaVars, SCIP_Bool initial, SCIP_Bool separate, SCIP_Bool enforce, SCIP_Bool check, SCIP_Bool propagate,
                                             SCIP_Bool local, SCIP_Bool modifiable, SCIP_Bool dynamic, SCIP_Bool removable, SCIP_Bool stickingatnode);

#endif
