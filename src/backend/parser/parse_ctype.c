/*-------------------------------------------------------------------------
 *
 * parse_ctype.c
 *    Handle collection type code.
 *
 * Copyright (c) 2021-2022, IvorySQL
 *
 * IDENTIFICATION
 *    src/backend/parser/parse_ctype.c
 *
 *-------------------------------------------------------------------------
 */
#include "postgres.h"

#include "catalog/pg_type.h"
#include "nodes/nodeFuncs.h"
#include "nodes/nodes.h"
#include "parser/parse_ctype.h"
#include "parser/parse_expr.h"
#include "parser/parse_func.h"
#include "parser/parse_node.h"
#include "parser/parse_relation.h"
#include "parser/parse_type.h"
#include "utils/builtins.h"

static bool checkCtypeVar(ParseState *pstate, Node *node);

/*
 * transformIndirectionCheckIsCtypeFunc:
 * Check if the variable collection type function is called, and if it returns true.
 * The callback function query is a variable array variable
 */
bool
transformIndirectionCheckIsCtypeFunc(ParseState *pstate, Node *ColumnRefNode, List *funcnamelist)
{
	char	   *funcnametemp = NULL;
	ListCell	  *i;
	bool	   isCtype = false;
	bool	   isCtypeName = false;
	bool	   isCtypeFunc = false;

	if (!pstate || !pstate->p_find_ctype_hook)
		return isCtype;

	if (IsA(ColumnRefNode, A_Indirection))
	{
		A_Indirection	   *fn = (A_Indirection *) ColumnRefNode;

		isCtypeName = checkCtypeVar(pstate, fn->arg);
	}
	else
		isCtypeName = checkCtypeVar(pstate, ColumnRefNode);

	if (!isCtypeName)
		return isCtype;

	foreach (i, funcnamelist)
	{
		Node		*n = lfirst(i);

		if (IsA(n, String))
		{
			funcnametemp = strVal(n);

			if ((0 == strcmp(funcnametemp, "extend"))
				|| (0 == strcmp(funcnametemp, "trim"))
				|| (0 == strcmp(funcnametemp, "delete"))
				|| (0 == strcmp(funcnametemp, "exists"))
				|| (0 == strcmp(funcnametemp, "first"))
				|| (0 == strcmp(funcnametemp, "last"))
				|| (0 == strcmp(funcnametemp, "count"))
				|| (0 == strcmp(funcnametemp, "limit"))
				|| (0 == strcmp(funcnametemp, "prior"))
				|| (0 == strcmp(funcnametemp, "next")))
			{
				if (0 == strcmp(funcnametemp, "trim"))
					strVal(n) = strdup("collection_trim");
				else if (0 == strcmp(funcnametemp, "exists"))
					strVal(n) = strdup("collection_exists");
				else if (0 == strcmp(funcnametemp, "limit"))
					strVal(n) = strdup("collection_limit");
				else if (0 == strcmp(funcnametemp, "extend"))
					strVal(n) = strdup("collection_extend");
				else if (0 == strcmp(funcnametemp, "delete"))
					strVal(n) = strdup("collection_delete");
				else if (0 == strcmp(funcnametemp, "prior"))
					strVal(n) = strdup("collection_prior");
				else if (0 == strcmp(funcnametemp, "first"))
					strVal(n) = strdup("collection_first");
				else if (0 == strcmp(funcnametemp, "last"))
					strVal(n) = strdup("collection_last");
				else if (0 == strcmp(funcnametemp, "count"))
					strVal(n) = strdup("collection_count");
				else if (0 == strcmp(funcnametemp, "next"))
					strVal(n) = strdup("collection_next");
				isCtypeFunc = true;
			}
		}
	}

	if (isCtypeFunc && isCtypeName)
	{
		isCtype = true;
	}

	return isCtype;
}

static void
unknown_ctype_attribute(ParseState *pstate, Node *relref, const char *attname,
				  int location)
{
	RangeTblEntry *rte;

	if (IsA(relref, Var) &&
		((Var *) relref)->varattno == InvalidAttrNumber)
	{
		/* Reference the RTE by alias not by actual table name */
		rte = GetRTEByRangeTablePosn(pstate,
									 ((Var *) relref)->varno,
									 ((Var *) relref)->varlevelsup);
		ereport(ERROR,
				(errcode(ERRCODE_UNDEFINED_COLUMN),
				 errmsg("column %s.%s does not exist",
						rte->eref->aliasname, attname),
				 parser_errposition(pstate, location)));
	}
	else
	{
		/* Have to do it by reference to the type of the expression */
		Oid			relTypeId = exprType(relref);

		if (ISCOMPLEX(relTypeId))
			ereport(ERROR,
					(errcode(ERRCODE_UNDEFINED_COLUMN),
					 errmsg("column \"%s\" not found in data type %s",
							attname, format_type_be(relTypeId)),
					 parser_errposition(pstate, location)));
		else if (relTypeId == RECORDOID)
			ereport(ERROR,
					(errcode(ERRCODE_UNDEFINED_COLUMN),
					 errmsg("could not identify column \"%s\" in record data type",
							attname),
					 parser_errposition(pstate, location)));
		else
			ereport(ERROR,
					(errcode(ERRCODE_WRONG_OBJECT_TYPE),
					 errmsg("column notation .%s applied to type %s, "
							"which is not a composite type",
							attname, format_type_be(relTypeId)),
					 parser_errposition(pstate, location)));
	}
}

/*
 * transformFuncCallCtypeSubscriptFunction:
 * Invoke the collection type function, get the variable information and
 * function information, and build the multidimensional collection type expression
 */
Node *
transformFuncCallCtypeSubscriptFunction(ParseState *pstate, FuncCall *fn, bool proccall)
{
	/* Processing collection type's element method expressions , eg: aa(2)(2).extend()*/
	Node	   *last_srf = pstate->p_last_srf;
	char       *funcnametemp = NULL;
	List       *targs = NIL;
	ListCell   *args;
	List	   *subscripts = NIL;
	Node	   *ctypeDatum = NULL;
	Node	   *funcnamenode;
	Node	   *ctypenode;
	Node	   *newresult;
	ListCell   *i;
	int listlenth = fn->funcname->length;

	/* Transform the list of arguments ... 
	targs = NIL;*/
	foreach(args, fn->args)
	{
		targs = lappend(targs, transformExpr(pstate,
											 (Node *) lfirst(args),
											 pstate->p_expr_kind));
	}

	foreach(i, fn->funcname)
	{
		Node	   *n = lfirst(i);

		if (IsA(n, A_Indices))
			subscripts = lappend(subscripts, n);
		else if (IsA(n, String))
		{
			funcnametemp = strVal(n);
			funcnamenode = n;

			if((0 == strcmp(funcnametemp, "collection_extend"))
				|| (0 == strcmp(funcnametemp, "collection_trim"))
				|| (0 == strcmp(funcnametemp, "collection_delete"))
				|| (0 == strcmp(funcnametemp, "collection_exists"))
				|| (0 == strcmp(funcnametemp, "collection_first"))
				|| (0 == strcmp(funcnametemp, "collection_last"))
				|| (0 == strcmp(funcnametemp, "collection_count"))
				|| (0 == strcmp(funcnametemp, "collection_limit"))
				|| (0 == strcmp(funcnametemp, "collection_prior"))
				|| (0 == strcmp(funcnametemp, "collection_next")))
			{
				int inttemp;

				/* process subscripts before this field selection */
				if (subscripts)
				{
					/*delect ColumnRef Node*/
					targs = list_delete_first(targs);
					ctypeDatum = (Node *) transformContainerSubscripts(pstate,
																   ctypenode,
																   exprType(ctypenode),
																   exprTypmod(ctypenode),
																   subscripts,
																   false);
					subscripts = NIL;

					targs = lcons(ctypeDatum, targs);
				}

				/* if schemanametemp is collection type, delete schemaname */
				for(inttemp = 0; inttemp < listlenth-1; inttemp++)
					fn->funcname = list_delete_first(fn->funcname);
			}
			else
			{
				ColumnRef  *c = makeNode(ColumnRef);
				c->fields = list_make1(makeString(funcnametemp));
				c->location = -1;

				ctypenode = transformExpr(pstate, (Node *)c, pstate->p_expr_kind);

				targs = lcons(ctypenode, targs);
				fn->args = lcons(c, fn->args);
			}
		}
		else
		{
			ereport(ERROR,
					(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
					 errmsg("varray or nested table not supported here")));
		}
	}

	newresult = ParseFuncOrColumn(pstate,
								  list_make1(funcnamenode),
								  targs,
								  last_srf,
								  fn,
								  proccall,
								  fn->location);

	if (!newresult)
		unknown_ctype_attribute(pstate, newresult, strVal(funcnamenode), fn->location);

	return newresult;
}

/*
 * transformSubCallCheckIsCtypeFunc:
 * A_Indirection expr check.
 * Whether a query is a collection type function call, if is return true
 */
bool
transformSubCallCheckIsCtypeFunc(ParseState *pstate, A_Indirection *typeexpr)
{
	bool	   isSubCtype = false;
	bool	   isCtypeName = false;
	bool	   isCtypeFunc = false;
	ListCell	   *cell2 = NULL;

	if (!pstate->p_find_ctype_hook)
		return isSubCtype;

	if (IsA(typeexpr->arg, A_Indirection))
	{
		A_Indirection	   *fn = (A_Indirection *) typeexpr->arg;

		isCtypeName = checkCtypeVar(pstate, fn->arg);
	}
	else
		isCtypeName = checkCtypeVar(pstate, typeexpr->arg);

	if (!isCtypeName)
		return isSubCtype;

	foreach(cell2, typeexpr->indirection)
	{
		Node	   *va = lfirst(cell2);

		if (IsA(va, String))
		{
			if ((0 == strcmp(strVal(va), "collection_extend")) ||
				(0 == strcmp(strVal(va), "collection_delete")) ||
				(0 == strcmp(strVal(va), "collection_trim")))
			{
				isCtypeFunc = true;
				break;
			}
		}
	}

	if (isCtypeName && isCtypeFunc)
		isSubCtype = true;

	return isSubCtype;
}

/*
 * checkCtypeVar:
 * Whether a query is a collection type variable.
 */
static bool
checkCtypeVar(ParseState *pstate, Node *node)
{
	bool	   isCtypeName = false;
	ListCell	   *cell = NULL;

	if (IsA(node, FuncCall))
	{
		FuncCall	   *fn = (FuncCall *) node;

		foreach(cell, fn->funcname)
		{
			Node	   *n = lfirst(cell);

			if (IsA(n, String))
			{
				Oid elemOid = pstate->p_find_ctype_hook(pstate, strVal(n), NULL, NULL, NULL);
				if (InvalidOid != elemOid )
				{
					isCtypeName = true;
					break;
				}
			}
		}
	}
	else if (IsA(node, ColumnRef))
	{
		ColumnRef	   *fn = (ColumnRef *) node;

		foreach(cell, fn->fields)
		{
			Node	   *n = lfirst(cell);

			if (IsA(n, String))
			{
				Oid elemOid = pstate->p_find_ctype_hook(pstate, strVal(n), NULL, NULL, NULL);
				if (InvalidOid != elemOid )
				{
					isCtypeName = true;
					break;
				}
			}
		}
	}

	return isCtypeName;
}

/*
 * transformFuncCallCheckIsCtypeFunc:
 * funcname list expr check.
 * Whether a query is a collection type function call, if is return true
 */
bool
transformFuncCallCheckIsCtypeFunc(ParseState *pstate, List *funcnamelist)
{
	char *funcnametemp = NULL;
	bool isCtype = false;
	bool isCtypeName = false;
	bool isCtypeFunc = false;
	ListCell   *i;

	if (!pstate->p_find_ctype_hook || list_length(funcnamelist) == 1)
		return isCtype;

	foreach(i, funcnamelist)
	{
		Node	   *n = lfirst(i);

		if (IsA(n, String))
		{
			funcnametemp = strVal(n);

			if (isCtypeName)
			{
				if ((0 == strcmp(funcnametemp, "extend")) ||
					(0 == strcmp(funcnametemp, "trim")) ||
					(0 == strcmp(funcnametemp, "delete")) ||
					(0 == strcmp(funcnametemp, "exists")) ||
					(0 == strcmp(funcnametemp, "first")) ||
					(0 == strcmp(funcnametemp, "last")) ||
					(0 == strcmp(funcnametemp, "count")) ||
					(0 == strcmp(funcnametemp, "limit")) ||
					(0 == strcmp(funcnametemp, "prior")) ||
					(0 == strcmp(funcnametemp, "next")))
				{
					if(0 == strcmp(funcnametemp, "trim"))
						strVal(n) = strdup("collection_trim");
					else if(0 == strcmp(funcnametemp, "exists"))
						strVal(n) = strdup("collection_exists");
					else if(0 == strcmp(funcnametemp, "limit"))
						strVal(n) = strdup("collection_limit");
					else if(0 == strcmp(funcnametemp, "extend"))
						strVal(n) = strdup("collection_extend");
					else if(0 == strcmp(funcnametemp, "delete"))
						strVal(n) = strdup("collection_delete");
					else if (0 == strcmp(funcnametemp, "prior"))
						strVal(n) = strdup("collection_prior");
					else if (0 == strcmp(funcnametemp, "first"))
						strVal(n) = strdup("collection_first");
					else if (0 == strcmp(funcnametemp, "last"))
						strVal(n) = strdup("collection_last");
					else if (0 == strcmp(funcnametemp, "count"))
						strVal(n) = strdup("collection_count");
					else if (0 == strcmp(funcnametemp, "next"))
						strVal(n) = strdup("collection_next");

					isCtypeFunc = true;
				}
			}
			else
			{
				Oid elemOid = pstate->p_find_ctype_hook(pstate, funcnametemp, NULL, NULL, NULL);
				if (InvalidOid != elemOid )
					isCtypeName = true;
			}
		}
	}

	if (isCtypeFunc && isCtypeName)
		isCtype = true;

	return isCtype;
}

/*
 * transformFuncCallCheckIsCtypeConstructor:
 * funccall expr check.
 * Whether a query is a collection type Constructor function call, if is return true
 */
Node *
transformFuncCallCheckIsCtypeConstructor(ParseState *pstate, FuncCall *fn)
{
	char *funcnametemp = strVal(linitial(fn->funcname));
	bool isctype = false;
	Node *node = NULL;

	/* Check collection type constructor function */
	if (pstate->p_find_ctype_hook != NULL)
	{
		int32 ctypemaxlen;
		char *typname;
		Oid elemOid = pstate->p_find_ctype_hook(pstate, funcnametemp, &typname, &ctypemaxlen, &isctype);
		if (InvalidOid != elemOid)
		{
			/* Modify function name */
			if (isctype)
			{
				A_Const *varraymaxlennode;
				A_Const *varrayelemtype;

				varraymaxlennode = makeNode(A_Const);
				varraymaxlennode->type = T_A_Const;
				varraymaxlennode->val.ival.type = T_Integer;
				varraymaxlennode->val.ival.ival = ctypemaxlen;
				varraymaxlennode->location = -1;
				fn->args = lcons(varraymaxlennode, fn->args);

				varrayelemtype = makeNode(A_Const);
				varrayelemtype->type = T_A_Const;
				varrayelemtype->val.ival.type = T_Integer;
				varrayelemtype->val.ival.ival = elemOid;
				varrayelemtype->location = -1;
				fn->args = lcons(varrayelemtype, fn->args);

				if (!strcmp(typname, "nestedtab"))
					ModifyQualifiedName(fn->funcname, "nestedtab_constructor");
				else
					ModifyQualifiedName(fn->funcname, "varray_constructor");
			}
			/* As array to parse */
			else
			{
				A_Indirection *i = makeNode(A_Indirection);
				A_Indices *ai = makeNode(A_Indices);
				ColumnRef *c = makeNode(ColumnRef);
				char *colname = NULL;
				FuncCall *tmp_fn = copyObject(fn);

				if (list_length(tmp_fn->args) > 1)
					elog(ERROR, "varray array reference error");

				ai->is_slice = false;
				ai->lidx = NULL;
				ai->uidx = linitial(tmp_fn->args);

				colname = strVal(linitial(tmp_fn->funcname));
				c->fields = list_make1(makeString(colname));
				i->indirection =list_concat(list_delete_first(tmp_fn->funcname), list_make1(ai));
				i->arg = (Node *)c;

				node = transformExpr(pstate, (Node *)i, pstate->p_expr_kind);
			}
		}
	}

	return node;
}

/*
 * transformCallCtypestmt
 * Add collection type procedure arguments and parse it.
 */
Node *
transformCallCtypestmt(ParseState *pstate, CallStmt *stmt)
{
	Node	   *node = NULL;
	bool	   isCtype = false;
	bool	   isSubCtype = false;
	ListCell	   *args1 = NULL;
	List	   *targs = NULL;

	if (stmt && stmt->funccall)
		isCtype = transformFuncCallCheckIsCtypeFunc(pstate, stmt->funccall->funcname);
	else if (stmt && stmt->typeexpr)
		isSubCtype = transformSubCallCheckIsCtypeFunc(pstate, stmt->typeexpr);

	if(isCtype)
	{
		pstate->p_expr_kind = EXPR_KIND_CALL_ARGUMENT;
		node = transformFuncCallCtypeSubscriptFunction(pstate, stmt->funccall, true);
	}
	/* Parse collection type procedure */
	else if (isSubCtype)
	{
		ListCell	   *cell = NULL;

		/* Transform the list of arguments ... */
		if (stmt->typeexpr->func_args)
		{
			foreach(args1, stmt->typeexpr->func_args->args)
			{
				targs = lappend(targs, transformExpr(pstate,
													   (Node *) lfirst(args1),
													   EXPR_KIND_CALL_ARGUMENT));
			}
		}
		targs = lcons(node, targs);

		foreach(cell, stmt->typeexpr->indirection)
		{
			Node	   *newresult;
			Node	   *n = lfirst(cell);

			Assert(IsA(n, String));

			newresult = ParseFuncOrColumn(pstate,
										 list_make1(n),
										 targs,
										 NULL,
										 NULL,
										 true,
										 -1);

			if (!newresult)
				ereport(ERROR,
						(errcode(ERRCODE_UNDEFINED_COLUMN),
						 errmsg("procedure \"%s\" does not exist", strVal(n))));

			node = newresult;
			targs = list_make1(newresult);
		}
	}

	return node;
}