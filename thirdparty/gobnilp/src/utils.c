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
 *  Contains some useful functions that may be needed in several other files.
 *
 *  Currently, there are two sorts of function included in this file.
 *  - Functions to simplify creating parameters.
 *    - @link UT_addBoolParam @endlink
 *    - @link UT_addIntParam @endlink
 *    - @link UT_addStringParam @endlink
 *  - Functions to simplify creating linear constraints.
 *    - @link UT_createEmptyLinearConstraint @endlink
 *    - @link UT_createEmptyLTEConstraint @endlink
 *    - @link UT_createEmptyGTEConstraint @endlink
 */

#include "utils.h"

// Some convenient wrappers for creating new parameters that set many values to sensible defaults
/** Adds a boolean parameter to those recognised by SCIP.
 *
 *  This is just a shortcut for SCIPaddBoolParam() with various options set to their most common values.
 *  Use the full function if you need any of the more advanced options.
 *
 *  @param scip The SCIP instance to add the parameter to.
 *  @param name The parameter's name.
 *  @param desc A description of the parameter.
 *  @param value The parameter's initial value.
 *  @return SCIP_OKAY if the operation suceeded.  Otherwise an appropriate error message.
 */
SCIP_RETCODE UT_addBoolParam(SCIP* scip, const char* name, const char* desc, SCIP_Bool value) {
   return SCIPaddBoolParam(scip, name, desc, NULL, FALSE, value, NULL, NULL);
}
/** Adds an integer parameter to those recognised by SCIP.
 *
 *  This is just a shortcut for SCIPaddIntParam() with various options set to their most common values.
 *  Use the full function if you need any of the more advanced options.  The minimum value of the
 *  parameter is the initial value; the maximum value of the parameter is INT_MAX.
 *
 *  @param scip The SCIP instance to add the parameter to.
 *  @param name The parameter's name.
 *  @param desc A description of the parameter.
 *  @param value The parameter's initial value.
 *  @return SCIP_OKAY if the operation suceeded.  Otherwise an appropriate error message.
 */
SCIP_RETCODE UT_addIntParam(SCIP* scip, const char* name, const char* desc, int value) {
   return SCIPaddIntParam(scip, name, desc, NULL, FALSE, value, value, INT_MAX, NULL, NULL);
}
/** Adds a string parameter to those recognised by SCIP.
 *
 *  This is just a shortcut for SCIPaddStringParam() with various options set to their most common values.
 *  Use the full function if you need any of the more advanced options.
 *
 *  @param scip The SCIP instance to add the parameter to.
 *  @param name The parameter's name.
 *  @param desc A description of the parameter.
 *  @param value The parameter's initial value.
 *  @return SCIP_OKAY if the operation suceeded.  Otherwise an appropriate error message.
 */
SCIP_RETCODE UT_addStringParam(SCIP* scip, const char* name, const char* desc, const char* value) {
   return SCIPaddStringParam(scip, name, desc, NULL, FALSE, value, NULL, NULL);
}

// Some convenient wrappers for creating empty linear constraints that set many values to sensible defaults
/** Creates an initially empty linear constraint with most options set to sensible defaults.
 *
 *  @param scip SCIP data structure
 *  @param cons pointer to hold the created constraint
 *  @param name name of constraint
 *  @param lhs left hand side of constraint
 *  @param rhs right hand side of constraint
 *  @return SCIP_OKAY if the operation succeeded or an error code otherwise.
 */
SCIP_RETCODE UT_createEmptyLinearConstraint(SCIP* scip, SCIP_CONS** cons, const char* name, SCIP_Real lhs, SCIP_Real rhs) {
   SCIP_CALL( SCIPcreateConsLinear(scip, cons, name, 0, NULL, NULL, lhs, rhs, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE) );
   return SCIP_OKAY;
}
/** Creates an initially empty less than or equal to linear constraint with most options set to sensible defaults.
 *
 *  @param scip SCIP data structure
 *  @param cons pointer to hold the created constraint
 *  @param name name of constraint
 *  @param rhs The value the constraint should be less than or equal to
 *  @return SCIP_OKAY if the operation succeeded or an error code otherwise.
 */
SCIP_RETCODE UT_createEmptyLTEConstraint(SCIP* scip, SCIP_CONS** cons, const char* name, SCIP_Real rhs) {
   SCIP_CALL( UT_createEmptyLinearConstraint(scip, cons, name, -SCIPinfinity(scip), rhs) );
   return SCIP_OKAY;
}
/** Creates an initially empty greater than or equal to linear constraint with most options set to sensible defaults.
 *
 *  @param scip SCIP data structure
 *  @param cons pointer to hold the created constraint
 *  @param name name of constraint
 *  @param lhs The value the constraint should be greater than or equal to
 *  @return SCIP_OKAY if the operation succeeded or an error code otherwise.
 */
SCIP_RETCODE UT_createEmptyGTEConstraint(SCIP* scip, SCIP_CONS** cons, const char* name, SCIP_Real lhs) {
   SCIP_CALL( UT_createEmptyLinearConstraint(scip, cons, name, lhs, SCIPinfinity(scip)) );
   return SCIP_OKAY;
}
