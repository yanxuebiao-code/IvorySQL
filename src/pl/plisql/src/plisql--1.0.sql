/* src/pl/plisql/src/plisql--1.0.sql */

CREATE FUNCTION plisql_call_handler() RETURNS language_handler
  LANGUAGE c AS 'MODULE_PATHNAME';

CREATE FUNCTION plisql_inline_handler(internal) RETURNS void
  STRICT LANGUAGE c AS 'MODULE_PATHNAME';

CREATE FUNCTION plisql_validator(oid) RETURNS void
  STRICT LANGUAGE c AS 'MODULE_PATHNAME';

CREATE TRUSTED LANGUAGE plisql
  HANDLER plisql_call_handler
  INLINE plisql_inline_handler
  VALIDATOR plisql_validator;

-- The language object, but not the functions, can be owned by a non-superuser.
ALTER LANGUAGE plisql OWNER TO @extowner@;

--
--varray function
--
CREATE FUNCTION varray_in(cstring)
RETURNS varray
AS '$libdir/plisql','collection_in'
LANGUAGE C
STRICT
IMMUTABLE
PARALLEL SAFE;

CREATE FUNCTION varray_out(varray)
RETURNS cstring
AS '$libdir/plisql','collection_out'
LANGUAGE C
STRICT
IMMUTABLE
PARALLEL SAFE;

CREATE TYPE varray (
	input = varray_in,
	output = varray_out,
	category = 'S',
	INTERNALLENGTH=VARIABLE,
	collatable = true
);

--constructor
CREATE FUNCTION varray_constructor(integer, integer, variadic anyarray)
RETURNS varray
AS '$libdir/plisql','collection_constructor'
LANGUAGE C
CALLED ON NULL INPUT;

CREATE FUNCTION varray_constructor(integer, integer)
RETURNS varray
AS '$libdir/plisql','collection_constructor'
LANGUAGE C
CALLED ON NULL INPUT;

--delete
CREATE FUNCTION varray_delete_func(varray)
RETURNS varray
AS '$libdir/plisql','collection_delete'
LANGUAGE C
CALLED ON NULL INPUT;

CREATE PROCEDURE collection_delete(INOUT varray) AS $$
BEGIN
	$1 := varray_delete_func($1);
END;$$
LANGUAGE plisql;

--trim
CREATE FUNCTION varray_trim_func(varray)
RETURNS varray
AS '$libdir/plisql','collection_trim'
LANGUAGE C
CALLED ON NULL INPUT;

CREATE FUNCTION varray_trim_func(varray, integer)
RETURNS varray
AS '$libdir/plisql','collection_trim'
LANGUAGE C
CALLED ON NULL INPUT;

CREATE PROCEDURE collection_trim(INOUT varray) AS $$
BEGIN
	$1 := varray_trim_func($1);
END;$$
LANGUAGE plisql;

CREATE PROCEDURE collection_trim(INOUT varray, integer) AS $$
BEGIN
	$1 := varray_trim_func($1, $2);
END;$$
LANGUAGE plisql;

--extend
CREATE FUNCTION varray_extend_func(varray)
RETURNS varray
AS '$libdir/plisql','collection_extend'
LANGUAGE C
CALLED ON NULL INPUT;

CREATE FUNCTION varray_extend_func(varray, integer)
RETURNS varray
AS '$libdir/plisql','collection_extend'
LANGUAGE C
CALLED ON NULL INPUT;

CREATE FUNCTION varray_extend_func(varray, integer, integer)
RETURNS varray
AS '$libdir/plisql','collection_extend'
LANGUAGE C
CALLED ON NULL INPUT;

CREATE PROCEDURE collection_extend(INOUT varray) AS $$
BEGIN
	$1 := varray_extend_func($1);
END;$$
LANGUAGE plisql;

CREATE PROCEDURE collection_extend(INOUT varray, integer) AS $$
BEGIN
	$1 := varray_extend_func($1, $2);
END;$$
LANGUAGE plisql;

CREATE PROCEDURE collection_extend(INOUT varray, integer, integer) AS $$
BEGIN
	$1 := varray_extend_func($1, $2, $3);
END;$$
LANGUAGE plisql;

--exists
CREATE FUNCTION collection_exists(varray, integer)
RETURNS bool
AS '$libdir/plisql','collection_exists'
LANGUAGE C
CALLED ON NULL INPUT;

--first
CREATE FUNCTION collection_first(varray)
RETURNS integer
AS '$libdir/plisql','collection_first'
LANGUAGE C
CALLED ON NULL INPUT;

--last
CREATE FUNCTION collection_last(varray)
RETURNS integer
AS '$libdir/plisql','collection_last'
LANGUAGE C
CALLED ON NULL INPUT;

--count
CREATE FUNCTION collection_count(varray)
RETURNS integer
AS '$libdir/plisql','collection_count'
LANGUAGE C
CALLED ON NULL INPUT
IMMUTABLE
PARALLEL SAFE;

--limit
CREATE FUNCTION collection_limit(varray)
RETURNS integer
AS '$libdir/plisql','collection_limit'
LANGUAGE C
CALLED ON NULL INPUT
IMMUTABLE
PARALLEL SAFE;

--prior
CREATE FUNCTION collection_prior(varray, integer)
RETURNS integer
AS '$libdir/plisql','collection_prior'
LANGUAGE C
CALLED ON NULL INPUT
IMMUTABLE
PARALLEL SAFE;

--next
CREATE FUNCTION collection_next(varray, integer)
RETURNS integer
AS '$libdir/plisql','collection_next'
LANGUAGE C
CALLED ON NULL INPUT
IMMUTABLE
PARALLEL SAFE;

--
--nested table function
--
CREATE FUNCTION nested_in(cstring)
RETURNS nestedtab
AS '$libdir/plisql','collection_in'
LANGUAGE C
STRICT
IMMUTABLE
PARALLEL SAFE;

CREATE FUNCTION nested_out(nestedtab)
RETURNS cstring
AS '$libdir/plisql','collection_out'
LANGUAGE C
STRICT
IMMUTABLE
PARALLEL SAFE;

CREATE TYPE nestedtab (
	input = nested_in,
	output = nested_out,
	category = 'S',
	INTERNALLENGTH=VARIABLE,
	collatable = true
);

--constructor
CREATE FUNCTION nestedtab_constructor(integer, integer, variadic anyarray)
RETURNS nestedtab
AS '$libdir/plisql','collection_constructor'
LANGUAGE C
CALLED ON NULL INPUT;

CREATE FUNCTION nestedtab_constructor(integer, integer)
RETURNS nestedtab
AS '$libdir/plisql','collection_constructor'
LANGUAGE C
CALLED ON NULL INPUT;

--delete
CREATE FUNCTION nestedtab_delete_func(nestedtab)
RETURNS nestedtab
AS '$libdir/plisql','collection_delete'
LANGUAGE C
CALLED ON NULL INPUT;

CREATE FUNCTION nestedtab_delete_func(nestedtab, integer)
RETURNS nestedtab
AS '$libdir/plisql','collection_delete'
LANGUAGE C
CALLED ON NULL INPUT;

CREATE FUNCTION nestedtab_delete_func(nestedtab, integer, integer)
RETURNS nestedtab
AS '$libdir/plisql','collection_delete'
LANGUAGE C
CALLED ON NULL INPUT;

CREATE PROCEDURE collection_delete(INOUT nestedtab) AS $$
BEGIN
	$1 := nestedtab_delete_func($1);
END;$$
LANGUAGE plisql;

CREATE PROCEDURE collection_delete(INOUT nestedtab, integer) AS $$
BEGIN
	$1 := nestedtab_delete_func($1, $2);
END;$$
LANGUAGE plisql;

CREATE PROCEDURE collection_delete(INOUT nestedtab, integer, integer) AS $$
BEGIN
	$1 := nestedtab_delete_func($1, $2, $3);
END;$$
LANGUAGE plisql;

--trim
CREATE FUNCTION nestedtab_trim_func(nestedtab)
RETURNS nestedtab
AS '$libdir/plisql','collection_trim'
LANGUAGE C
CALLED ON NULL INPUT;

CREATE FUNCTION nestedtab_trim_func(nestedtab, integer)
RETURNS nestedtab
AS '$libdir/plisql','collection_trim'
LANGUAGE C
CALLED ON NULL INPUT;

CREATE PROCEDURE collection_trim(INOUT nestedtab) AS $$
BEGIN
	$1 := nestedtab_trim_func($1);
END;$$
LANGUAGE plisql;

CREATE PROCEDURE collection_trim(INOUT nestedtab, integer) AS $$
BEGIN
	$1 := nestedtab_trim_func($1, $2);
END;$$
LANGUAGE plisql;

--extend
CREATE FUNCTION nestedtab_extend_func(nestedtab)
RETURNS nestedtab
AS '$libdir/plisql','collection_extend'
LANGUAGE C
CALLED ON NULL INPUT;

CREATE FUNCTION nestedtab_extend_func(nestedtab, integer)
RETURNS nestedtab
AS '$libdir/plisql','collection_extend'
LANGUAGE C
CALLED ON NULL INPUT;

CREATE FUNCTION nestedtab_extend_func(nestedtab, integer, integer)
RETURNS nestedtab
AS '$libdir/plisql','collection_extend'
LANGUAGE C
CALLED ON NULL INPUT;

CREATE PROCEDURE collection_extend(INOUT nestedtab) AS $$
BEGIN
	$1 := nestedtab_extend_func($1);
END;$$
LANGUAGE plisql;

CREATE PROCEDURE collection_extend(INOUT nestedtab, integer) AS $$
BEGIN
	$1 := nestedtab_extend_func($1, $2);
END;$$
LANGUAGE plisql;

CREATE PROCEDURE collection_extend(INOUT nestedtab, integer, integer) AS $$
BEGIN
	$1 := nestedtab_extend_func($1, $2, $3);
END;$$
LANGUAGE plisql;

--exists
CREATE FUNCTION collection_exists(nestedtab, integer)
RETURNS bool
AS '$libdir/plisql','collection_exists'
LANGUAGE C
CALLED ON NULL INPUT;

--first
CREATE FUNCTION collection_first(nestedtab)
RETURNS integer
AS '$libdir/plisql','collection_first'
LANGUAGE C
CALLED ON NULL INPUT;

--last
CREATE FUNCTION collection_last(nestedtab)
RETURNS integer
AS '$libdir/plisql','collection_last'
LANGUAGE C
CALLED ON NULL INPUT;

--count
CREATE FUNCTION collection_count(nestedtab)
RETURNS integer
AS '$libdir/plisql','collection_count'
LANGUAGE C
CALLED ON NULL INPUT
IMMUTABLE
PARALLEL SAFE;

--limit
CREATE FUNCTION collection_limit(nestedtab)
RETURNS integer
AS '$libdir/plisql','collection_limit'
LANGUAGE C
CALLED ON NULL INPUT
IMMUTABLE
PARALLEL SAFE;

--prior
CREATE FUNCTION collection_prior(nestedtab, integer)
RETURNS integer
AS '$libdir/plisql','collection_prior'
LANGUAGE C
CALLED ON NULL INPUT
IMMUTABLE
PARALLEL SAFE;

--next
CREATE FUNCTION collection_next(nestedtab, integer)
RETURNS integer
AS '$libdir/plisql','collection_next'
LANGUAGE C
CALLED ON NULL INPUT
IMMUTABLE
PARALLEL SAFE;

COMMENT ON LANGUAGE plisql IS 'PL/iSQL procedural language';
