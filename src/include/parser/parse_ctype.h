/*-------------------------------------------------------------------------
 *
 * parse_ctype.h
 *	  Handle collection type code.
 *
 * Copyright (c) 2021-2022, IvorySQL
 *
 * src/include/parser/parse_ctype.h
 *
 *-------------------------------------------------------------------------
 */
#ifndef PARSE_CTYPE_H
#define PARSE_CTYPE_H

#include "parser/parse_node.h"

extern Node *transformCallCtypestmt(ParseState *pstate, CallStmt *stmt);
extern bool transformIndirectionCheckIsCtypeFunc(ParseState *pstate, Node *ColumnRefNode,
																 List *funcnamelist);
extern Node *transformFuncCallCtypeSubscriptFunction(ParseState *pstate, FuncCall *fn,
																	   bool proccall);
extern bool transformSubCallCheckIsCtypeFunc(ParseState *pstate, A_Indirection *typeexpr);
extern bool transformFuncCallCheckIsCtypeFunc(ParseState *pstate, List *funcnamelist);
extern Node *transformFuncCallCheckIsCtypeConstructor(ParseState *pstate, FuncCall *fn);

#endif							/* PARSE_CTYPE_H */
