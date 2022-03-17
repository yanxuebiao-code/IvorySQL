/*-------------------------------------------------------------------------
 *
 * parse_ctype.h
 *	  Handle collection type functions.
 *
 * Copyright (c) 2021-2022, IvorySQL
 *
 * src/include/utils/ctype.h
 *
 *-------------------------------------------------------------------------
 */
#ifndef CTYPE_H
#define CTYPE_H

#include "utils/array.h"
#include "utils/fmgrprotos.h"
#include "utils/arrayaccess.h"
#include "utils/lsyscache.h"

/* Collection type mark */
#define CTYPE_MARK 0x100

/* nested table maximum element number */
#define NESTED_TAB_MAX_ELEMENT_NUM INT_MAX	/* (2 ^ 31) - 1 */

#define AGG_ISDELETEDBITMAP(a, nitems) \
		 ((bits8 *) (((char *) (a)) + (VARSIZE_ANY(a)) - 2 * sizeof(int) -((nitems) + 7) / 8))

#define AGG_MAXLENTHMAP(a) \
		 ((int *) (((char *) (a)) + (VARSIZE_ANY(a)) - 2 * sizeof(int)))

#define AGG_FLAGMAP(a) \
		 ((int *) (((char *) (a)) + (VARSIZE_ANY(a)) - sizeof(int)))

extern bool ctype_data_deleted_check(Datum arraydatum, int refer_indx);
extern bool ctype_alldata_deleted_check(Datum arraydatum);
extern int32 ctype_prior_data_deleted_num(Datum arraydatum, int location);
extern int32 ctype_next_data_deleted_num(Datum arraydatum, int location);
extern void ctype_data_not_deleted(Datum arraydatum, int useindx);
extern void ctype_somedata_deleted(ArrayType *array, int nitems, bits8 *delflg);
extern void ctype_set_maxlenth_and_flag(ArrayType *array, int maxlenth, int flag);
extern void checkCtypeLenthIsValid(Datum arraydatum, int useindx);

#endif							/* CTYPE_H */

