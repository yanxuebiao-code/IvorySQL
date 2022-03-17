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

#define ASSGN	 "="

static bool
array_isspace(char ch)
{
	if (ch == ' ' ||
		ch == '\t' ||
		ch == '\n' ||
		ch == '\r' ||
		ch == '\v' ||
		ch == '\f')
		return true;
	return false;
}
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

/*
 * collection_in :
 * use constructor function
 */
Datum
collection_in(PG_FUNCTION_ARGS)
{
	const char *str = PG_GETARG_CSTRING(0);

	ereport(ERROR,
			(errcode(ERRCODE_DATATYPE_MISMATCH),
			errmsg("\"%s\" is invalid, please use correct type", str)));
}

/*
 * collection_out :
 * takes the internal representation of an array and returns a string
 * containing the array in its external format.
 */
Datum
collection_out(PG_FUNCTION_ARGS)
{
	ArrayType  *array = PG_GETARG_ARRAYTYPE_P(0);
	Oid			element_type = ARR_ELEMTYPE(array);
	int			typlen;
	bool		typbyval;
	char		typalign;
	char		typdelim;
	char	   *p,
			   *tmp,
			   *retval,
			  **values,
				dims_str[(MAXDIM * 33) + 2];

	bool	   *needquotes,
				needdims = false;
	size_t		overall_length;
	int			nitems,
				i,
				j,
				k,
				indx[MAXDIM];
	int			ndim,
			   *dims,
			   *lb;
	array_iter	iter;
	ArrayMetaState *my_extra;

	int *ctypeflag = AGG_FLAGMAP(array);
	if (*ctypeflag != CTYPE_MARK)
		ereport(ERROR,
				(errcode(ERRCODE_PROGRAM_LIMIT_EXCEEDED),
				 errmsg("collection type error")));

	if (ctype_alldata_deleted_check(PointerGetDatum(array)))
		ereport(ERROR,
			(errcode(ERRCODE_PROGRAM_LIMIT_EXCEEDED),
			 errmsg("Subscript beyond count"),
			 errdetail("A subscript was greater than the limit of a varray or non-positive for a varray or nested table. the varry was deleted")));

	/*
	 * We arrange to look up info about element type, including its output
	 * conversion proc, only once per series of calls, assuming the element
	 * type doesn't change underneath us.
	 */
	my_extra = (ArrayMetaState *) fcinfo->flinfo->fn_extra;
	if (my_extra == NULL)
	{
		fcinfo->flinfo->fn_extra = MemoryContextAlloc(fcinfo->flinfo->fn_mcxt,
													  sizeof(ArrayMetaState));
		my_extra = (ArrayMetaState *) fcinfo->flinfo->fn_extra;
		my_extra->element_type = ~element_type;
	}

	if (my_extra->element_type != element_type)
	{
		/*
		 * Get info about element type, including its output conversion proc
		 */
		get_type_io_data(element_type, IOFunc_output,
						 &my_extra->typlen, &my_extra->typbyval,
						 &my_extra->typalign, &my_extra->typdelim,
						 &my_extra->typioparam, &my_extra->typiofunc);
		fmgr_info_cxt(my_extra->typiofunc, &my_extra->proc,
					  fcinfo->flinfo->fn_mcxt);
		my_extra->element_type = element_type;
	}
	typlen = my_extra->typlen;
	typbyval = my_extra->typbyval;
	typalign = my_extra->typalign;
	typdelim = my_extra->typdelim;

	ndim = ARR_NDIM(array);
	dims = ARR_DIMS(array);
	lb = ARR_LBOUND(array);
	nitems = ArrayGetNItems(ndim, dims);

	if (nitems == 0)
	{
		retval = pstrdup("{}");
		PG_RETURN_CSTRING(retval);
	}

	/*
	 * we will need to add explicit dimensions if any dimension has a lower
	 * bound other than one
	 */
	for (i = 0; i < ndim; i++)
	{
		if (lb[i] != 1)
		{
			needdims = true;
			break;
		}
	}

	/*
	 * Convert all values to string form, count total space needed (including
	 * any overhead such as escaping backslashes), and detect whether each
	 * item needs double quotes.
	 */
	values = (char **) palloc(nitems * sizeof(char *));
	needquotes = (bool *) palloc(nitems * sizeof(bool));
	overall_length = 0;

	array_iter_setup(&iter, (AnyArrayType *)array);

	for (i = 0; i < nitems; i++)
	{
		Datum		itemvalue;
		bool		isnull;
		bool		needquote;

		/* Check element whether be deleted */
		if (ctype_data_deleted_check(PointerGetDatum(array), i + 1))
		{
			values[i] = pstrdup("");
			needquote = false;

			/* Skip this element */
			(void)array_iter_next(&iter, &isnull, i,
							typlen, typbyval, typalign);
		}
		else
		{
			/* Get source element, checking for NULL */
			itemvalue = array_iter_next(&iter, &isnull, i,
										typlen, typbyval, typalign);

			if (isnull)
			{
				values[i] = pstrdup("NULL");
				overall_length += 4;
				needquote = false;
			}
			else
			{
				values[i] = OutputFunctionCall(&my_extra->proc, itemvalue);

				/* count data plus backslashes; detect chars needing quotes */
				if (values[i][0] == '\0')
					needquote = true;	/* force quotes for empty string */
				else if (pg_strcasecmp(values[i], "NULL") == 0)
					needquote = true;	/* force quotes for literal NULL */
				else
					needquote = false;

				for (tmp = values[i]; *tmp != '\0'; tmp++)
				{
					char		ch = *tmp;

					overall_length += 1;
					if (ch == '"' || ch == '\\')
					{
						needquote = true;
						overall_length += 1;
					}
					else if (ch == '{' || ch == '}' || ch == typdelim ||
							 array_isspace(ch))
						needquote = true;
				}
			}
		}

		needquotes[i] = needquote;

		/* Count the pair of double quotes, if needed */
		if (needquote)
			overall_length += 2;
		/* and the comma (or other typdelim delimiter) */
		overall_length += 1;
	}

	/*
	 * The very last array element doesn't have a typdelim delimiter after it,
	 * but that's OK; that space is needed for the trailing '\0'.
	 *
	 * Now count total number of curly brace pairs in output string.
	 */
	for (i = j = 0, k = 1; i < ndim; i++)
	{
		j += k, k *= dims[i];
	}
	overall_length += 2 * j;

	/* Format explicit dimensions if required */
	dims_str[0] = '\0';
	if (needdims)
	{
		char	   *ptr = dims_str;

		for (i = 0; i < ndim; i++)
		{
			sprintf(ptr, "[%d:%d]", lb[i], lb[i] + dims[i] - 1);
			ptr += strlen(ptr);
		}
		*ptr++ = *ASSGN;
		*ptr = '\0';
		overall_length += ptr - dims_str;
	}

	/* Now construct the output string */
	retval = (char *) palloc(overall_length);
	p = retval;

#define APPENDSTR(str)	(strcpy(p, (str)), p += strlen(p))
#define APPENDCHAR(ch)	(*p++ = (ch), *p = '\0')

	if (needdims)
		APPENDSTR(dims_str);
	APPENDCHAR('{');
	for (i = 0; i < ndim; i++)
		indx[i] = 0;
	j = 0;
	k = 0;
	do
	{
		for (i = j; i < ndim - 1; i++)
			APPENDCHAR('{');

		if (needquotes[k])
		{
			APPENDCHAR('"');
			for (tmp = values[k]; *tmp; tmp++)
			{
				char		ch = *tmp;

				if (ch == '"' || ch == '\\')
					*p++ = '\\';
				*p++ = ch;
			}
			*p = '\0';
			APPENDCHAR('"');
		}
		else
			APPENDSTR(values[k]);
		pfree(values[k++]);

		for (i = ndim - 1; i >= 0; i--)
		{
			if (++(indx[i]) < dims[i])
			{
				APPENDCHAR(typdelim);
				break;
			}
			else
			{
				indx[i] = 0;
				APPENDCHAR('}');
			}
		}
		j = i;
	} while (j != -1);

#undef APPENDSTR
#undef APPENDCHAR

	/* Assert that we calculated the string length accurately */
	Assert(overall_length == (p - retval + 1));

	pfree(values);
	pfree(needquotes);

	PG_RETURN_CSTRING(retval);
}