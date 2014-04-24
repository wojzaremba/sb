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
 *  Function declarations for model_averaging.c
 */

#ifndef __MODEL_AVERAGING_H__
#define __MODEL_AVERAGING_H__

#include <scip/scip.h>

extern SCIP_RETCODE MA_createAverageDataStructure(SCIP* scip);
extern SCIP_RETCODE MA_destroyAverageDataStructure(SCIP* scip);

extern SCIP_RETCODE MA_updateAverageDataStructure(SCIP* scip, SCIP_SOL* sol);

extern SCIP_RETCODE MA_getAverageDataStructure(SCIP* scip, SCIP_Real*** scores);
extern    SCIP_Real MA_getTotalAveragesTime(void);
extern    SCIP_Real MA_getTotalAveragesScore(void);

#endif
