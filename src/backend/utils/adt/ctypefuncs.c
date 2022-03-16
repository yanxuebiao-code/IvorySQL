/*-------------------------------------------------------------------------
 *
 * ctypefuncs.c
 *	  Support functions for collection type.
 *
 * Copyright (c) 2021-2022, IvorySQL
 *
 * IDENTIFICATION
 *    src/backend/utils/adt/ctypefuncs.c
 *
 *-------------------------------------------------------------------------
 */
#include "postgres.h"

#include "utils/array.h"
#include "utils/ctype.h"

/*
 * ctype_data_deleted_check
 * Check whether the element of the mutable collection type are deleted
 */
bool
ctype_data_deleted_check(Datum arraydatum, int refer_indx)
{
	int		   ndim,
			   *dim,
			   indx;
	int		   bitmask;
	bits8	   *bitmap;
	ArrayType  *arraytemp = DatumGetArrayTypeP(arraydatum);
	int32	   nitems = 0;
	bool	   delete = false;

	bitmask = 1;
	ndim = ARR_NDIM(arraytemp);
	dim = ARR_DIMS(arraytemp);
	nitems = ArrayGetNItems(ndim, dim);
	bitmap = AGG_ISDELETEDBITMAP(arraytemp, nitems);

	for(indx = 0; indx < nitems; indx++)
	{
		if (bitmap)
		{
			if ((indx == refer_indx -1) && (*bitmap & bitmask) == bitmask)
			{
				delete = true;
				break;
			}

			bitmask <<= 1;
			if (bitmask == 0x100)
			{
				bitmap++;
				bitmask = 1;
			}
		}
	}

	return delete;
}

/*
 * ctype_alldata_deleted_check
 * Check whether all the elements of the mutable collection type are deleted
 * and not keep placeholders for them
 */
bool
ctype_alldata_deleted_check(Datum arraydatum)
{
	int 		ndim,
			   *dim;
	ArrayType	   *arraytemp = DatumGetArrayTypeP(arraydatum);
	int32	   nitems = 0;
	bool	   alldelete = false;

	ndim = ARR_NDIM(arraytemp);
	dim = ARR_DIMS(arraytemp);
	nitems = ArrayGetNItems(ndim, dim);

	if (nitems == 0 && ndim != 0)
		alldelete = true;

	return alldelete;
}

/*
 * ctype_prior_data_deleted_num
 * the elements of the mutable collection type are deleted and keep placeholders
 * for them before location, return deleted elements number
 */
int32
ctype_prior_data_deleted_num(Datum arraydatum, int location)
{
	int 	   ndim,
			   *dim,
			   *lb;
	bits8	   *bitmap;
	int		   bitmask;
	ArrayType   *arraytemp = DatumGetArrayTypeP(arraydatum);
	int32	   nitems = 0;
	int		   indx;
	int32	   del_num = 0;
	int		   length;

	lb = ARR_LBOUND(arraytemp);
	ndim = ARR_NDIM(arraytemp);
	dim = ARR_DIMS(arraytemp);
	nitems = ArrayGetNItems(ndim, dim);
	bitmap = AGG_ISDELETEDBITMAP(arraytemp, nitems);
	length = dim[0] + lb[0] - 1;

	/* Offset position */
	if (location < length)
		bitmask = 1 << (location - 1);
	else
		bitmask = 1 << (length - 1);

	for(indx = 0; indx < location; indx++)
	{
		if (bitmap)
		{
			if ((*bitmap & bitmask) == 0x0)
			{
				break;
			}

			del_num++;
			bitmask >>= 1;
			if (bitmask == 0x0)
			{
				bitmap++;
				dim++;
				lb++;
				length = dim[0] + lb[0] - 1;
				bitmask = 1 << (length - 1);
			}
		}
	}

	return del_num;
}

/*
 * ctype_next_data_deleted_num
 * the elements of the mutable collection type are deleted and keep placeholders
 * for them after location, return deleted elements number
 */
int32
ctype_next_data_deleted_num(Datum arraydatum, int location)
{
	int 	   ndim,
			   *dim;
	bits8	   *bitmap;
	int		   bitmask;
	ArrayType   *arraytemp = DatumGetArrayTypeP(arraydatum);
	int32	   nitems = 0;
	int		   indx;
	int32	   del_num = 0;

	ndim = ARR_NDIM(arraytemp);
	dim = ARR_DIMS(arraytemp);
	nitems = ArrayGetNItems(ndim, dim);
	bitmap = AGG_ISDELETEDBITMAP(arraytemp, nitems);

	/* Offset position */
	bitmask = 1 << (location - 1);

	for(indx = location - 1; indx < nitems; indx++)
	{
		if (bitmap)
		{
			if ((*bitmap & bitmask) == 0x0)
			{
				break;
			}

			del_num++;
			bitmask <<= 1;
			if (bitmask == 0x100)
			{
				bitmap++;
				bitmask = 1;
			}
		}
	}

	return del_num;
}

/*
 * ctype_data_not_deleted
 * set element not deleted for the mutable collection type
 */
void
ctype_data_not_deleted(Datum arraydatum, int useindx)
{
	int 		ndim,
			   *dim;
	bits8	   *bitmap;
	int		   bitmask;
	ArrayType   *arraytemp = DatumGetArrayTypeP(arraydatum);
	int32	   nitems = 0;
	int		   indx;

	ndim = ARR_NDIM(arraytemp);
	dim = ARR_DIMS(arraytemp);
	nitems = ArrayGetNItems(ndim, dim);
	bitmap = AGG_ISDELETEDBITMAP(arraytemp, nitems);
	bitmask = 1;

	for(indx = 0; indx < nitems; indx++)
	{
		if (bitmap)
		{
			if ((indx == useindx -1) && (*bitmap & bitmask) == bitmask)
			{
				*bitmap &= ~bitmask;
				break;
			}

			bitmask <<= 1;
			if (bitmask == 0x100)
			{
				bitmap++;
				bitmask = 1;
			}
		}
	}
}

/*
 * ctype_somedata_not_deleted
 * set some elements deleted flag for the mutable collection type
 */
void
ctype_somedata_deleted(ArrayType *array, int nitems, bits8 *delflg)
{
	bits8	*bitmap = AGG_ISDELETEDBITMAP(array, nitems);

	if (delflg)
		*bitmap = *delflg;
	else
		*bitmap &= 0x0;
}

/*
* ctype_set_maxlenth_and_flag
* set the mutable collection type max lenth and flag
*/
void
ctype_set_maxlenth_and_flag(ArrayType *array,    int maxlenth, int flag)
{
	int *ctypemaxlenth = AGG_MAXLENTHMAP(array);
	int *ctypeflag = AGG_FLAGMAP(array);

	*ctypemaxlenth = maxlenth;
	*ctypeflag = flag;
}

/*
 * checkCtypeLenthIsValid
 * Whether the collection type flag is valid
 */
void
checkCtypeLenthIsValid(Datum arraydatum, int useindx)
{
	ArrayType	*arraytemp;
	int			*ctypemaxlenth ;
	int			*ctypeflag;
	int			*curlenth;

	if (!useindx)
		return;

	if(!arraydatum)
		ereport(ERROR,
			(errcode(ERRCODE_PROGRAM_LIMIT_EXCEEDED),
			 errmsg("Reference to uninitialized collection"),
			 errdetail("An element or member function of a nested table or varray was referenced (where an initialized collection is needed) without the collection having been initialized")));

	arraytemp = DatumGetArrayTypeP(arraydatum);
	ctypemaxlenth = AGG_MAXLENTHMAP(arraytemp);
	ctypeflag = AGG_FLAGMAP(arraytemp);
	curlenth = ARR_DIMS(arraytemp);

	if (*ctypeflag == CTYPE_MARK)
	{
		if (ctype_alldata_deleted_check(arraydatum) || !ARR_NDIM(arraytemp))
			ereport(ERROR,
					(errcode(ERRCODE_PROGRAM_LIMIT_EXCEEDED),
					 errmsg("Subscript beyond count"),
					 errdetail("A subscript was greater than the limit of a varray or non-positive for a varray or nested table. the varry was deleted")));

		if (ctype_data_deleted_check(arraydatum, useindx))
			ereport(ERROR,
					(errcode(ERRCODE_NO_DATA_FOUND),
					 errmsg("No data found"),
					 errdetail("There was no data from the varray or nested table which may be due to end of fetch")));

		if (useindx > *ctypemaxlenth)
			ereport(ERROR,
					(errcode(ERRCODE_PROGRAM_LIMIT_EXCEEDED),
					 errmsg("Subscript(%d) outside of limit (%d)", useindx, *ctypemaxlenth),
					 errdetail("A subscript was greater than the limit of a varray or non-positive for a varray or nested table.")));

		if (!*curlenth)
			ereport(ERROR,
					(errcode(ERRCODE_PROGRAM_LIMIT_EXCEEDED),
					 errmsg("Reference to uninitialized collection"),
					 errdetail("An element or member function of a nested table or varray was referenced (where an initialized collection is needed) without the collection having been initialized")));

		if (*curlenth < useindx || useindx < 0)
			ereport(ERROR,
					(errcode(ERRCODE_PROGRAM_LIMIT_EXCEEDED),
					 errmsg("Subscript(%d) outside of limit (%d)",useindx, *curlenth),
					 errdetail("An in-limit subscript was greater than the count of a varray or too large for a nested table.")));
	}
}