/*-------------------------------------------------------------------------
 *
 * pl_ctype.c
 *			collection type function and procedure.
 *
 *Copyright (c) 2021-2022, IvorySQL
 *
 * IDENTIFICATION
 *	  src/pl/plisql/src/pl_ctype.c
 *
 *-------------------------------------------------------------------------
 */
#include "postgres.h"

#include "access/hash.h"
#include "access/htup_details.h"
#include "catalog/namespace.h"
#include "catalog/pg_type.h"
#include "fmgr.h"
#include "funcapi.h"
#include "libpq/pqformat.h"
#include "mb/pg_wchar.h"
#include "nodes/nodeFuncs.h"
#include "nodes/supportnodes.h"
#include "optimizer/optimizer.h"
#include "utils/array.h"
#include "utils/arrayaccess.h"
#include "utils/builtins.h"
#include "utils/ctype.h"
#include "utils/datum.h"
#include "utils/lsyscache.h"
#include "utils/memutils.h"
#include "utils/selfuncs.h"
#include "utils/typcache.h"
#include "utils/fmgrprotos.h"
#include "utils/array.h"

#define ASSGN "="

PG_FUNCTION_INFO_V1(collection_constructor);
PG_FUNCTION_INFO_V1(collection_delete);
PG_FUNCTION_INFO_V1(collection_trim);
PG_FUNCTION_INFO_V1(collection_extend);
PG_FUNCTION_INFO_V1(collection_exists);
PG_FUNCTION_INFO_V1(collection_first);
PG_FUNCTION_INFO_V1(collection_last);
PG_FUNCTION_INFO_V1(collection_count);
PG_FUNCTION_INFO_V1(collection_limit);
PG_FUNCTION_INFO_V1(collection_prior);
PG_FUNCTION_INFO_V1(collection_next);

static ArrayType * trim_delete_func(ArrayType  *array, int nums, bits8 *delflg);
static ArrayType * ctype_flag_add_func(ArrayType  *array, int ctypemaxlen, bits8 *delflg);
static void check_array_datum(Datum value);

/*
 * collection_constructor:
 * Construct a array, and the parameters are empty and the empty array is built
 */
Datum
collection_constructor(PG_FUNCTION_ARGS)
{
	ArrayType  *array;
	Oid			element_type = PG_GETARG_OID(0);
	int32		ctypemaxlen = PG_GETARG_INT32(1);
	ArrayType    *result;

	if (2 == PG_NARGS())
	{
		result = construct_empty_array(element_type);
		result = ctype_flag_add_func(result, ctypemaxlen, 0);
	}
	else
	{
		array = PG_GETARG_ARRAYTYPE_P(2);
		result = ctype_flag_add_func(array, ctypemaxlen, 0);
	}

	PG_RETURN_ARRAYTYPE_P(result);
}

static
void check_array_datum(Datum value)
{
	if (!value)
		ereport(ERROR,
				(errcode(ERRCODE_PROGRAM_LIMIT_EXCEEDED),
				 errmsg("Reference to uninitialized collection"),
				 errdetail("An element or member function of a nested table or varray was referenced ,without the collection having been initialized")));
}

Datum
collection_delete(PG_FUNCTION_ARGS)
{
	ArrayType	   *array;
	int		   ndim;
	int		   *dim;
	int		   indx;
	int		   nitems;
	bits8	   *bitmap;
	int		   bitmask;
	int		   del_indx;
	int		   start_indx;
	int		   end_indx;
	int		   nargs = PG_NARGS();

	check_array_datum(fcinfo->args[0].value);

	bitmask = 1;
	array = DatumGetArrayTypeP(fcinfo->args[0].value);

	ndim = ARR_NDIM(array);
	dim = ARR_DIMS(array);
	nitems = ArrayGetNItems(ndim, dim);

	/* Execute delete() */
	if (nargs == 1)
	{
		array = trim_delete_func(array, nitems, 0);
		PG_RETURN_ARRAYTYPE_P(array);
	}
	else if (nargs == 2)
	{
		del_indx = PG_GETARG_INT32(1);
	}
	else if (nargs == 3)
	{
		start_indx = PG_GETARG_INT32(1);
		end_indx = PG_GETARG_INT32(2);
	}

	bitmap = AGG_ISDELETEDBITMAP(array, nitems);
	for(indx =0 ; indx < nitems; indx++)
	{
		if (bitmap)
		{
			/* Execute delete(m) */
			if (nargs == 2)
			{
				if (indx == del_indx - 1)
				{
					*bitmap |= bitmask;
					break;
				}
			}
			/* Execute delete(m, n) */
			else if (nargs == 3)
			{
				if (indx >= start_indx - 1 && indx <= end_indx - 1)
					*bitmap |= bitmask;
			}

			bitmask <<= 1;
			if (bitmask == 0x100)
			{
				bitmap++;
				bitmask = 1;
			}
		}
	}

	PG_RETURN_ARRAYTYPE_P(array);
}

static
ArrayType *trim_delete_func(ArrayType *array, int trimnums, bits8 *delflg)
{
	Datum	   *values;
	bool	   *nulls;
	int 		ndim;
	int 		nitems;
	int		   *dim;
	int32		nbytes = 0;
	Datum		elt;
	char	   *arraydataptr;
	bits8	   *bitmap;
	int 		bitmask;
	int32		dataoffset;
	bool		hasnulls = false;
	int 		elementnums = 0;
	int        *pctypemaxlen;
	int 		ctypemaxlen;
	char		typalign;
	int			typlen;
	bool		typbyval;
	TypeCacheEntry *typentry;
	ArrayType  *result;

	pctypemaxlen = AGG_MAXLENTHMAP(array);
	ctypemaxlen = *pctypemaxlen;

	ndim = ARR_NDIM(array);
	dim = ARR_DIMS(array);
	nitems = ArrayGetNItems(ndim, dim);

	nitems -= trimnums;
	values = (Datum *) palloc(nitems * sizeof(Datum));
	nulls = (bool *) palloc(nitems * sizeof(bool));

	arraydataptr = ARR_DATA_PTR(array);
	bitmap = ARR_NULLBITMAP(array);
	bitmask = 1;

	typentry = lookup_type_cache(array->elemtype,
								 TYPECACHE_EQ_OPR_FINFO);

	typlen = typentry->typlen;
	typbyval = typentry->typbyval;
	typalign = typentry->typalign;

	for (elementnums = 0; elementnums < nitems; elementnums++)
	{
		if (bitmap && (*bitmap & bitmask) == 0)
		{
			nulls[elementnums] = true;
			hasnulls = true;
		}
		else
		{
			elt= fetch_att(arraydataptr, typbyval, typlen);
			arraydataptr = att_addlength_datum(arraydataptr, typlen, elt);
			arraydataptr = (char *) att_align_nominal(arraydataptr, typalign);
			/* Update total result size */
			nbytes = att_addlength_datum(nbytes, typlen, elt);
			nbytes = att_align_nominal(nbytes, typalign);
			/* check for overflow of total request */
			if (!AllocSizeIsValid(nbytes))
			{
				ereport(ERROR,
						(errcode(ERRCODE_PROGRAM_LIMIT_EXCEEDED),
						 errmsg("array size exceeds the maximum allowed (%d)",
								(int) MaxAllocSize)));
			}

			values[elementnums] = elt;
			nulls[elementnums] = false;
		}
		if (bitmap)
		{
			bitmask <<= 1;
			if (bitmask == 0x100)
			{
				bitmap++;
				bitmask = 1;
			}
		}
	}

	/* Allocate and initialize the result array */
	if (hasnulls)
	{
		dataoffset = ARR_OVERHEAD_WITHNULLS(ndim, elementnums);
		nbytes += dataoffset;
	}
	else
	{
		dataoffset = 0; 		/* marker for no null bitmap */
		nbytes += ARR_OVERHEAD_NONULLS(ndim);
	}

	/* set isdeleted and ctypemaxlenth*/
	nbytes = nbytes +  (nitems + 7) / 8;
	nbytes = nbytes + sizeof(int); //ctypemaxlenth is int;
	nbytes = nbytes + sizeof(int); //flag is int;

	result = (ArrayType *) palloc0(nbytes);
	SET_VARSIZE(result, nbytes);
	result->ndim = ndim;
	result->dataoffset = dataoffset;
	result->elemtype = array->elemtype;
	memcpy(ARR_DIMS(result), ARR_DIMS(array), ndim * sizeof(int));
	memcpy(ARR_LBOUND(result), ARR_LBOUND(array), ndim * sizeof(int));

	ARR_DIMS(result)[0] = nitems;

	/* Insert data into result array */
	CopyArrayEls(result,
				 values, nulls, nitems,
				 typlen, typbyval, typalign,
				 false);

	/* set isdeleted */
	if (delflg && nitems > 0)
		*delflg &= ((1 << nitems) - 1);
	ctype_somedata_deleted(result, nitems, delflg);
	ctype_set_maxlenth_and_flag(result, ctypemaxlen, CTYPE_MARK);

	pfree(values);
	pfree(nulls);

	return result;
}

Datum
collection_trim(PG_FUNCTION_ARGS)
{
	ArrayType	   *array;
	ArrayType	   *result = NULL;
	int		   trimnums = 0;
	int 	   *dimv,
			   *lb;
	int		   resultint;
	int		   ndim,
			   *dim;
	int32	   nitems = 0;
	bits8	   *bitmap;

	check_array_datum(fcinfo->args[0].value);
	array = DatumGetArrayTypeP(fcinfo->args[0].value);

	if (ctype_alldata_deleted_check(PointerGetDatum(array)))
		ereport(ERROR,
				(errcode(ERRCODE_PROGRAM_LIMIT_EXCEEDED),
				 errmsg("Subscript beyond count"),
				 errdetail("A subscript was greater than the limit of a varray or non-positive for a varray or nested table. the varry was deleted")));

	lb = ARR_LBOUND(array);
	dimv = ARR_DIMS(array);

	resultint = dimv[0] + lb[0] - 1;

	ndim = ARR_NDIM(array);
	dim = ARR_DIMS(array);
	nitems = ArrayGetNItems(ndim, dim);
	bitmap = AGG_ISDELETEDBITMAP(array, nitems);

	if (1 == PG_NARGS())
	{
		trimnums = 1;
	}
	else if (2 == PG_NARGS())
	{
		trimnums = PG_GETARG_INT32(1);
		if (trimnums == 0)
			PG_RETURN_ARRAYTYPE_P(array);
		else if (trimnums < 0)
		{
			ereport(ERROR,
					(errcode(ERRCODE_PROGRAM_LIMIT_EXCEEDED),
					 errmsg("Subscript beyond count"),
					 errdetail("A subscript was greater than the limit of a varray or non-positive for a varray or nested table. the varry was deleted")));
		}
	}

	if (trimnums > resultint)
		ereport(ERROR,
				(errcode(ERRCODE_PROGRAM_LIMIT_EXCEEDED),
				 errmsg("Subscript beyond count"),
				 errdetail("An in-limit subscript was greater than the count of a varray or too large for a nested table.")));

	result = trim_delete_func(array, trimnums, bitmap);

	PG_RETURN_ARRAYTYPE_P(result);
}


static
Datum copy_datum(Datum indatum , int typlen, bool typbyval )
{
	Datum newdatum;
	newdatum = datumCopy(indatum, typbyval, typlen);

	return newdatum;
}

static
Datum get_ctype_value(ArrayType* ctypedata, int copyvalueindx)
{
	Datum		elt;
	Datum		result;
	bits8	   *bitmap;
	int			bitmask;
	int         forloopnum = 0;
	char	   *ctypedataptr;
	char		typalign;
	int			typlen;
	bool		typbyval;
	TypeCacheEntry *typentry;

	typentry = lookup_type_cache(ctypedata->elemtype,
								 TYPECACHE_EQ_OPR_FINFO);
	typlen = typentry->typlen;
	typbyval = typentry->typbyval;
	typalign = typentry->typalign;

	ctypedataptr = ARR_DATA_PTR(ctypedata);

	bitmap = ARR_NULLBITMAP(ctypedata);
	bitmask = 1;

	for (forloopnum = 0; forloopnum< copyvalueindx; forloopnum++)
	{
		/* Get source element, checking for NULL */
		if (bitmap && (*bitmap & bitmask) == 0)
		{
			result = (Datum)0;
		}
		else
		{
			elt= fetch_att(ctypedataptr, typbyval, typlen);
			ctypedataptr = att_addlength_datum(ctypedataptr, typlen, elt);
			ctypedataptr = (char *) att_align_nominal(ctypedataptr, typalign);

			result = copy_datum(elt, typlen, typbyval);
		}
		if (bitmap)
		{
			bitmask <<= 1;
			if (bitmask == 0x100)
			{
				bitmap++;
				bitmask = 1;
			}
		}
	}

	return result;
}

static
ArrayType * ctype_flag_add_func(ArrayType *array, int ctypemaxlen, bits8 *delflg)
{
	Datum		*values;
	bool		*nulls;
	int 		ndim;
	int 		nitems;
	int			*dim;
	int32		nbytes = 0;
	Datum		elt;
	bits8		*bitmap;
	int 		bitmask;
	int32		dataoffset;
	bool		hasnulls = false;
	int 		elementnums = 0;
	char		*arraydataptr;
	char		typalign;
	int			typlen;
	bool		typbyval;
	TypeCacheEntry *typentry;
	ArrayType  *result;

	arraydataptr = ARR_DATA_PTR(array);
	ndim = ARR_NDIM(array);
	dim = ARR_DIMS(array);
	nitems = ArrayGetNItems(ndim, dim);

	values = (Datum *) palloc(nitems * sizeof(Datum));
	nulls = (bool *) palloc(nitems * sizeof(bool));

	bitmap = ARR_NULLBITMAP(array);
	bitmask = 1;

	typentry = lookup_type_cache(array->elemtype,
								 TYPECACHE_EQ_OPR_FINFO);

	typlen = typentry->typlen;
	typbyval = typentry->typbyval;
	typalign = typentry->typalign;

	for (elementnums = 0;  elementnums < nitems;  elementnums++)
	{
		if (bitmap && (*bitmap & bitmask) == 0)
		{
			nulls[elementnums] = true;
			hasnulls = true;
		}
		else
		{
			elt= fetch_att(arraydataptr, typbyval, typlen);
			arraydataptr = att_addlength_datum(arraydataptr, typlen, elt);
			arraydataptr = (char *) att_align_nominal(arraydataptr, typalign);
			/* Update total result size */
			nbytes = att_addlength_datum(nbytes, typlen, elt);
			nbytes = att_align_nominal(nbytes, typalign);
			/* check for overflow of total request */
			if (!AllocSizeIsValid(nbytes))
			{
				ereport(ERROR,
						(errcode(ERRCODE_PROGRAM_LIMIT_EXCEEDED),
						 errmsg("array size exceeds the maximum allowed (%d)",
								(int) MaxAllocSize)));
			}

			values[elementnums] = elt;
			nulls[elementnums] = false;
		}
		if (bitmap)
		{
			bitmask <<= 1;
			if (bitmask == 0x100)
			{
				bitmap++;
				bitmask = 1;
			}
		}
	}

	/* Allocate and initialize the result array */
	if (hasnulls)
	{
		dataoffset = ARR_OVERHEAD_WITHNULLS(ndim, elementnums);
		nbytes += dataoffset;
	}
	else
	{
		dataoffset = 0; 		/* marker for no null bitmap */
		nbytes += ARR_OVERHEAD_NONULLS(ndim);
	}

	/* set isdeleted and ctypemaxlenth*/
	nbytes = nbytes +  (nitems + 7) / 8;
	nbytes = nbytes + sizeof(int); //ctypemaxlenth is int;
	nbytes = nbytes + sizeof(int); //flag is int;

	result = (ArrayType *) palloc0(nbytes);
	SET_VARSIZE(result, nbytes);
	result->ndim = ndim;
	result->dataoffset = dataoffset;
	result->elemtype = array->elemtype;
	memcpy(ARR_DIMS(result), ARR_DIMS(array), ndim * sizeof(int));
	memcpy(ARR_LBOUND(result), ARR_LBOUND(array), ndim * sizeof(int));

	/* Insert data into result array */
	CopyArrayEls(result,
				 values, nulls, nitems,
				 typlen, typbyval, typalign,
				 false);

	/* set isdeleted */
	ctype_somedata_deleted(result, nitems, delflg);
	ctype_set_maxlenth_and_flag(result, ctypemaxlen, CTYPE_MARK);

	pfree(values);
	pfree(nulls);

	return result;
}

Datum
collection_extend(PG_FUNCTION_ARGS)
{
	int			extendnum = 0;
	int	        copyvalueindx = 0;
	ArrayType  *array;
	FunctionCallInfo fcinfonew;
	int 	   *dimv, *lb;
	int 		currentlen;
	int        *pctypemaxlen;
	Datum       newvalue;
	int 		ndim,
			   *dim;
	int32	   nitems = 0;
	bits8	   *bitmap;

	check_array_datum(fcinfo->args[0].value);

	fcinfonew = fcinfo;
	fcinfonew->isnull = false;
	array = DatumGetArrayTypeP(fcinfo->args[0].value);

	pctypemaxlen = AGG_MAXLENTHMAP(array);
	lb = ARR_LBOUND(array);
	dimv = ARR_DIMS(array);
	currentlen = dimv[0] + lb[0] - 1;
	fcinfonew->args[0].value = PointerGetDatum(array);
	fcinfonew->args[0].isnull = false;

	ndim = ARR_NDIM(array);
	dim = ARR_DIMS(array);
	nitems = ArrayGetNItems(ndim, dim);
	if (nitems == 0)
		bitmap = 0;
	else
		bitmap = AGG_ISDELETEDBITMAP(array, nitems);

	if (1 == PG_NARGS())
	{
		extendnum = 1;
		copyvalueindx = 0;
		fcinfonew->args[1].isnull = true;
	}
	else if (2 == PG_NARGS())
	{
		if (ctype_alldata_deleted_check(PointerGetDatum(array)))
			fcinfonew->args[0].value = PointerGetDatum(construct_empty_array(array->elemtype));
		extendnum = PG_GETARG_INT32(1);
		copyvalueindx = 0;
		fcinfonew->args[1].isnull = true;
	}
	else if (3 == PG_NARGS())
	{
		if (ctype_alldata_deleted_check(PointerGetDatum(array)))
			ereport(ERROR,
					(errcode(ERRCODE_PROGRAM_LIMIT_EXCEEDED),
					 errmsg("Subscript beyond count"),
					 errdetail("A subscript was greater than the limit of a varray or non-positive for a varray or nested table. the varry was deleted")));

		extendnum = PG_GETARG_INT32(1);
		copyvalueindx = PG_GETARG_INT32(2);
		if (copyvalueindx <= 0 || copyvalueindx > nitems)
			ereport(ERROR,
					(errcode(ERRCODE_PROGRAM_LIMIT_EXCEEDED),
					 errmsg("Subscript beyond count"),
					 errdetail("A subscript was greater than the limit of a varray or non-positive for a varray or nested table. the varry was deleted")));
		else if (ctype_data_deleted_check(PointerGetDatum(array), copyvalueindx))
			ereport(ERROR,
					(errcode(ERRCODE_NO_DATA_FOUND),
					 errmsg("No data found"),
					 errdetail("There was no data from the varray or nested table which may be due to end of fetch")));

		fcinfonew->args[1].value = get_ctype_value(array, copyvalueindx);
		if (0 == fcinfonew->args[1].value)
			fcinfonew->args[1].isnull = true;
		else
			fcinfonew->args[1].isnull = false;
	}
	else
	{
		ereport(ERROR,
				(errcode(ERRCODE_PROGRAM_LIMIT_EXCEEDED),
				 errmsg("more than Reference number")));
	}

	/* check parameter is legal? */
	if (extendnum == 0)
		PG_RETURN_ARRAYTYPE_P(array);

	if (extendnum < 0)
		ereport(ERROR,
				(errcode(ERRCODE_PROGRAM_LIMIT_EXCEEDED),
				 errmsg("Subscript beyond count"),
				 errdetail("A subscript was greater than the limit of a varray or non-positive for a varray or nested table. the varry was deleted")));

	/* check lenth is more than maxlen */
	if ((currentlen + extendnum) > *pctypemaxlen)
		ereport(ERROR,
			(errcode(ERRCODE_PROGRAM_LIMIT_EXCEEDED),
			 errmsg("Subscript(%d) outside of limit(%d)", currentlen + extendnum , *pctypemaxlen),
			 errdetail("A subscript was greater than the limit of a varray or non-positive for a varray or nested table. Check the program logic and increase the varray limit if necessary.")));

	while(0 < extendnum)
	{
		newvalue = array_append(fcinfonew);
		fcinfonew->args[0].value = newvalue;
		fcinfonew->args[0].isnull = false;
		extendnum--;
	}
	array = DatumGetArrayTypeP(newvalue);
	array = ctype_flag_add_func(array, *pctypemaxlen, bitmap);

	PG_RETURN_ARRAYTYPE_P(array);
}

Datum
collection_exists(PG_FUNCTION_ARGS)
{
	int			indxint;
	ArrayType	*array;
	int			arrnum;
	int			ndim,
				*dims;

	if (0 == fcinfo->args[0].value)
		PG_RETURN_BOOL(false);

	array = PG_GETARG_ARRAYTYPE_P(0);
	if (ctype_alldata_deleted_check(PointerGetDatum(array)))
		PG_RETURN_BOOL(false);

	indxint = PG_GETARG_INT32(1);

	ndim = ARR_NDIM(array);
	dims = ARR_DIMS(array);
	arrnum = ArrayGetNItems(ndim, dims);

	/* Sanity check: does it look like an array at all? */
	if (ndim <= 0 || ndim > MAXDIM)
		PG_RETURN_BOOL(false);

	if (indxint <= 0 || indxint > arrnum)
	{
		PG_RETURN_BOOL(false);
	}
	else
	{
		if (ctype_data_deleted_check(PointerGetDatum(array), indxint))
			PG_RETURN_BOOL(false);
		else
			PG_RETURN_BOOL(true);
	}
}

Datum
collection_first(PG_FUNCTION_ARGS)
{
	int		   ndim,
			   *dim;
	int32	   nitems = 0;
	ArrayType	   *array;
	int		   first = 0;

	check_array_datum(fcinfo->args[0].value);
	array = PG_GETARG_ARRAYTYPE_P(0);

	if (ctype_alldata_deleted_check(PointerGetDatum(array)))
	{
		PG_RETURN_NULL();
	}

	ndim = ARR_NDIM(array);
	dim = ARR_DIMS(array);
	nitems = ArrayGetNItems(ndim, dim);

	/* Sanity check: does it look like an array at all? */
	if (ndim <= 0 || ndim > MAXDIM)
		PG_RETURN_NULL();

	first = ctype_next_data_deleted_num(PointerGetDatum(array), 1);

	if (first == nitems)
		PG_RETURN_NULL();
	else
		PG_RETURN_INT32(first + 1);
}

Datum
collection_last(PG_FUNCTION_ARGS)
{
	int 	   ndim,
			   *dim;
	int		   nitems;
	int32		   i;
	ArrayType	   *array;

	check_array_datum(fcinfo->args[0].value);
	array = PG_GETARG_ARRAYTYPE_P(0);

	if (ctype_alldata_deleted_check(PointerGetDatum(array)))
		PG_RETURN_NULL();

	ndim = ARR_NDIM(array);
	dim = ARR_DIMS(array);
	nitems = ArrayGetNItems(ndim, dim);

	/* Sanity check: does it look like an array at all? */
	if (ndim <= 0 || ndim > MAXDIM)
		PG_RETURN_NULL();

	i = ctype_prior_data_deleted_num(PointerGetDatum(array), nitems);

	if (i == nitems)
		PG_RETURN_NULL();
	else
		PG_RETURN_INT32(nitems - i);
}

Datum
collection_count(PG_FUNCTION_ARGS)
{
	ArrayType	   *array ;
	int 	   *dimv;
	int		   ndim;
	int32	   nitems = 0;
	int		   i,
			   indx;
	bits8	   *bitmap;
	int		   bitmask;

	check_array_datum(fcinfo->args[0].value);
	array = PG_GETARG_ARRAYTYPE_P(0);

	if (ctype_alldata_deleted_check(PointerGetDatum(array)))
		PG_RETURN_INT32(0);

	/* Sanity check: does it look like an array at all? */
	if (ARR_NDIM(array) <= 0 || ARR_NDIM(array) > MAXDIM)
		PG_RETURN_INT32(0);

	dimv = ARR_DIMS(array);
	ndim = ARR_NDIM(array);
	nitems = ArrayGetNItems(ndim, dimv);
	bitmap = AGG_ISDELETEDBITMAP(array, nitems);
	i = 0;
	bitmask = 1;

	for(indx = 0; indx < nitems; indx++)
	{
		if (bitmap)
		{
			if ((*bitmap & bitmask) == 0x0)
				i++;

			bitmask <<= 1;
			if (bitmask == 0x100)
			{
				bitmap++;
				bitmask = 1;
			}
		}
	}

	PG_RETURN_INT32(i);
}

Datum
collection_limit(PG_FUNCTION_ARGS)
{
	int		   result;
	ArrayType	   *array;
	int		   *pctypemaxlen;
	Oid		   argtype;

	check_array_datum(fcinfo->args[0].value);

	/* Nested table always return NULL */
	argtype = get_call_expr_argtype(fcinfo->flinfo->fn_expr, 0);
	if (argtype == TypenameGetTypid("nestedtab"))
		PG_RETURN_NULL();

	array = PG_GETARG_ARRAYTYPE_P(0);
	pctypemaxlen = AGG_MAXLENTHMAP(array);
	result = *pctypemaxlen;

	PG_RETURN_INT32(result);
}

Datum
collection_prior(PG_FUNCTION_ARGS)
{
	int		   reqindx;
	int		   result;
	ArrayType	   *array;
	int 	   ndim,
			   *dim;
	int32	   nitems = 0;
	int32	   i;
	int		   *lb;

	check_array_datum(fcinfo->args[0].value);
	array = PG_GETARG_ARRAYTYPE_P(0);

	reqindx = PG_GETARG_INT32(1);
	ndim = ARR_NDIM(array);
	dim = ARR_DIMS(array);
	lb = ARR_LBOUND(array);
	nitems = ArrayGetNItems(ndim, dim);

	if (ctype_alldata_deleted_check(PointerGetDatum(array)))
		PG_RETURN_NULL();

	/* Sanity check: does it look like an array at all? */
	if (ndim <= 0 || ndim > MAXDIM)
		PG_RETURN_NULL();

	if (reqindx > nitems)
	{
		/* Data be deleted but keep placeholders for them before location */
		i = ctype_prior_data_deleted_num(PointerGetDatum(array), nitems);
		if (i == nitems)
			PG_RETURN_NULL();

		result = dim[0] + lb[0] - 1 - i;
	}
	else if (reqindx <= 1)
	{
		PG_RETURN_NULL();
	}
	else
	{
		/* Data be deleted but keep placeholders for them before location */
		i = ctype_prior_data_deleted_num(PointerGetDatum(array), reqindx - 1);
		if (i == reqindx - 1)
			PG_RETURN_NULL();

		result = reqindx - 1 - i;
	}

	PG_RETURN_INT32(result);
}

Datum
collection_next(PG_FUNCTION_ARGS)
{
	int		   reqindx;
	int		   result;
	ArrayType	   *array;
	int 	   ndim,
			   *dim;
	int32	   nitems = 0;
	int32	   i;

	check_array_datum(fcinfo->args[0].value);
	array = PG_GETARG_ARRAYTYPE_P(0);

	reqindx = PG_GETARG_INT32(1);
	ndim = ARR_NDIM(array);
	dim = ARR_DIMS(array);
	nitems = ArrayGetNItems(ndim, dim);

	if (ctype_alldata_deleted_check(PointerGetDatum(array)))
		PG_RETURN_NULL();

	/* Sanity check: does it look like an array at all? */
	if (ndim <= 0 || ndim > MAXDIM)
		PG_RETURN_NULL();

	if (reqindx >= nitems)
	{
		PG_RETURN_NULL();
	}
	else if (reqindx < nitems && reqindx > 0)
	{
		/* Data be deleted but keep placeholders for them after location */
		i = ctype_next_data_deleted_num(PointerGetDatum(array), reqindx + 1);
		if (i == nitems - reqindx)
			PG_RETURN_NULL();

		result = reqindx + 1 + i;
	}
	else
	{
		/* Data be deleted but keep placeholders for them before location */
		i = ctype_next_data_deleted_num(PointerGetDatum(array), 1);
		if (i == nitems)
			PG_RETURN_NULL();

		result = i + 1;
	}

	PG_RETURN_INT32(result);
}