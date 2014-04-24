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
 *  Function declarations for utils.c
 */

#ifndef __UTILS_H__
#define __UTILS_H__

#include <scip/scip.h>
#include <scip/scipdefplugins.h>

// Some convenient wrappers for creating new parameters that set many values to sensible defaults
extern SCIP_RETCODE UT_addBoolParam(SCIP* scip, const char* name, const char* desc, SCIP_Bool value);
extern SCIP_RETCODE UT_addIntParam(SCIP* scip, const char* name, const char* desc, int value);
extern SCIP_RETCODE UT_addStringParam(SCIP* scip, const char* name, const char* desc, const char* value);

// Some convenient wrappers for creating empty linear constraints that set many values to sensible defaults
extern SCIP_RETCODE UT_createEmptyLinearConstraint(SCIP* scip, SCIP_CONS** cons, const char* name, SCIP_Real lhs, SCIP_Real rhs);
extern SCIP_RETCODE UT_createEmptyGTEConstraint(SCIP* scip, SCIP_CONS** cons, const char* name, SCIP_Real rhs);
extern SCIP_RETCODE UT_createEmptyLTEConstraint(SCIP* scip, SCIP_CONS** cons, const char* name, SCIP_Real lhs);

#endif
