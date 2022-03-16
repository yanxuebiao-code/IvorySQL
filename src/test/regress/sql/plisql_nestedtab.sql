--
--create nested table type
--
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var type_aa;
begin
	null;
end;
/

--
--not support multiple elements
--
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of (id int, flg char);
	var type_aa;
begin
	null;
end;
/

--
--assign value to nested table variable
--
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var type_aa;
begin
	var := type_aa(11, 22, 33, 44, 55);
	raise notice 'var = %', var;
	raise notice 'var(5) = %', var(5);
end;
/
select nested_tab_func1();

--
--nested table type and variable can declare anywhere
--
create or replace function nested_tab_func1() return void as
declare
	var1 int;
	type type_aa is table of int;
	var2 text;
	var3 type_aa := type_aa(11, 22, 33, 44, 55);
	var4 char;
begin
	raise notice 'var3(1) = %', var3(1);
	raise notice 'var3(5) = %', var3(5);
end;
/
select nested_tab_func1();

--
--is not support assigned value to nested, must use construct function
--
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var_aa type_aa;
begin
	var_aa := (11, 22, 33, 44, 55);
	raise notice '%', var_aa.id;
end;
/
select nested_tab_func1();

--
--assign a value to nested table element
--
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var type_aa := type_aa(11, 22, 33, 44, 55);
begin
	var(1) := 66;
	var(5) := 77;
	raise notice 'var(1) = %', var(1);
	raise notice 'var(5) = %', var(5);
end;
/
select nested_tab_func1();

--
--define multiple nested table
--
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
	type type_bb is table of type_aa;
	var2 type_bb := type_bb(var1, type_aa(66, 77), type_aa(88));
begin
	raise notice 'var1 = %', var1;
	raise notice 'var1(2) = %', var1(2);
	raise notice 'var2 = %', var2;
	raise notice 'var2(1) = %', var2(1);
	raise notice 'var2(3) = %', var2(3);
	raise notice 'var2(1)(5) = %', var2(1)(5);
end;
/
select nested_tab_func1();

--
--construct function use error
--
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
	type type_bb is table of type_aa;
	var2 type_bb := type_bb(var1, type_bb(66, 77), type_aa(88));
begin
	raise notice 'var1 = %', var1;
end;
/
select nested_tab_func1();

--
--subscript beyond range
--
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
	type type_bb is table of type_aa;
	var2 type_bb := type_bb(var1, type_aa(66, 77), type_aa(88));
begin
	var2(2)(3) := 99;
	raise notice 'var2 = %', var2;
end;
/
select nested_tab_func1();

--
--same type assign value
--
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
	var2 type_aa;
begin
	var1(5) := 66;
	var2 := var1;
	var2(1) := 77;
	raise notice 'var2 = %', var2;
	raise notice 'num = %', var2(1) + var1(3);
end;
/
select nested_tab_func1();

--
--delete function
--
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
begin
	var1.delete(1);
	raise notice 'var1 = %', var1(1);
end;
/
select nested_tab_func1();

create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
begin
	var1.delete(1, 5);
	raise notice 'var1 = %', var1;
end;
/
select nested_tab_func1();

create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
begin
	var1.delete(1);
	var1.delete(6); --do nothing
	raise notice 'var1 = %, %, %, %', var1(2), var1(3), var1(4), var1(5);
	raise notice 'var1 = %, %', var1(2), var1(1);
end;
/
select nested_tab_func1();

create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
begin
	var1.delete(1);
	raise notice 'var1 = %', var1(0);
end;
/
select nested_tab_func1();

create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
begin
	var1.delete(1);
	var1.delete(1);
	var1.delete(5);
	raise notice 'var1 = %', var1;
	var1(1) := 66;
	raise notice 'var1(1) = %', var1(1);
	raise notice 'var1 = %', var1;
	raise notice '%', var1(5);
end;
/
select nested_tab_func1();

create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
begin
	raise notice 'var1 = %', var1;
	var1.delete(1, 3);
	raise notice 'var1 = %', var1;
	var1.delete(-1, 4);
	raise notice 'var1 = %', var1;
	var1(1) := 66;
	raise notice 'var1(1) = %', var1(1);
	raise notice 'var1 = %', var1;
	var1.delete(1);
	raise notice 'var1 = %', var1;
end;
/
select nested_tab_func1();

create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
begin
	raise notice 'var1 = %', var1;
	var1.delete(-1, 3);
	raise notice 'var1 = %', var1;
	var1.Delete();
	var1(1) := 66;
end;
/
select nested_tab_func1();

--varray array can not call delete function which have parameters
create or replace function nested_tab_func1() return void as
declare
	type type_aa is varray(10) of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
begin
	var1.delete(-1, 3);
end;
/
select nested_tab_func1();

create or replace function nested_tab_func1() return void as
declare
	type type_aa is varray(10) of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
	type type_bb is varray(10) of type_aa;
	var2 type_bb := type_bb(var1);
	type type_cc is varray(10) of type_bb;
	var3 type_cc := type_cc(var2);
begin
	var3(1)(1).delete(1);
end;
/
select nested_tab_func1();

--
--mix use delete function
--
create or replace function nested_tab_func1() return void as
declare
	type type_aa is varray(10) of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
	var2 type_aa := type_aa(66, 77);
	type type_bb is table of type_aa;
	var3 type_bb := type_bb(var1, var2, type_aa(88, 99));
	var4 int;
begin
	raise notice 'var3 = %', var3;
	var2.delete; -- varray function
	raise notice 'var3 = %', var3;
	raise notice 'var3(2)(1) = %', var3(2)(1);
	var3.delete(1); --nested table function
	raise notice 'var3 = %', var3;
	var4 := 10;
	var3(1) := type_aa(var4);
	raise notice 'var3(1) = %', var3(1);
	var3.delete(1, 2);
	raise notice 'var3 = %', var3;
end;
/
select nested_tab_func1();

--
--trim function
--
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
begin
	raise notice 'var1 = %', var1;
	var1.trim;
	raise notice 'var1 = %', var1;
	var1.Delete(5); --element does not eixst, not throw error
end;
/
select nested_tab_func1();

create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
begin
	var1.delete(1, 5);
	var1.trim;
	raise notice 'var1 = %', var1;
end;
/
select nested_tab_func1();

create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
begin
	var1.delete(1);
	var1.trim;
	raise notice 'var1(1) = %', var1(1);
end;
/
select nested_tab_func1();

create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
begin
	raise notice 'var1 = %', var1;
	var1.Delete(5); --keep placeholder
	raise notice 'var1 = %', var1;
	var1.trim(1);
	raise notice 'var1 = %', var1;
end;
/
select nested_tab_func1();

create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
begin
	var1.trim(0);
	raise notice 'var1 = %', var1;
end;
/
select nested_tab_func1();

--parameter can not is negative
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
begin
	var1.trim(-1);
	raise notice 'var1 = %', var1;
end;
/
select nested_tab_func1();

--after trim, can not restore it
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
begin
	raise notice 'var1 = %', var1;
	var1.trim(2);
	raise notice 'var1 = %', var1;
	var1(4) := 66;
end;
/
select nested_tab_func1();

--delete all and trim it
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
begin
	raise notice 'var1 = %', var1;
	var1.delete;
	var1.trim;
end;
/
select nested_tab_func1();

--mix use varray and nested table
create or replace function nested_tab_func1() return void as
declare
	type type_aa is varray(10) of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
	type type_bb is table of type_aa;
	var2 type_bb := type_bb(type_aa(66, 77), var1);
	type type_cc is table of type_bb;
	var3 type_cc := type_cc(var2, var2);
begin
	raise notice 'var1 = %', var1;
	raise notice 'var2 = %', var2;
	var1.trim;
	raise notice 'var2 = %', var2;
	var2(2).trim(1);
	raise notice 'var1 = %', var1;
	raise notice 'var2 = %', var2;
	var3(1)(1).trim;
	raise notice 'var3 = %', var3;
	var3(2).delete(2);
	raise notice 'var3 = %', var3;
end;
/
select nested_tab_func1();

--
--extend function
--
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of varchar(10);
	var1 type_aa := type_aa('aa', 'bb', 'cc');
begin
	raise notice 'var1 = %', var1;
	var1.extend;
	raise notice 'var1 = %', var1;
	raise notice 'var1(4) = %', var1(4);
	var1(3) := 'dd';
	var1(4) := 'ee';
	raise notice 'var1 = %', var1;
end;
/
select nested_tab_func1();

create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of varchar(10);
	var1 type_aa := type_aa('aa', 'bb', 'cc');
begin
	var1.delete(1, 3);
	raise notice 'var1 = %', var1;
	var1.extend(2);
	raise notice 'var1 = %', var1;
	var1.delete(4, 5);
	raise notice 'var1 = %', var1;
end;
/
select nested_tab_func1();

create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of varchar(10);
	var1 type_aa := type_aa('aa', 'bb', 'cc');
begin
	var1.delete(1, 3);
	var1.extend(1, 2);
end;
/
select nested_tab_func1();

create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of varchar(10);
	var1 type_aa := type_aa('aa', 'bb', 'cc');
begin
	var1.extend(1, 4);
end;
/
select nested_tab_func1();

--mix use extend, delete and trim function
create or replace procedure nested_tab_proc1() as
declare
	type type_aa is table of varchar(10);
	var1 type_aa := type_aa('aa', 'bb', 'cc');
begin
	raise notice 'var1 = %', var1;
	var1.extend;
	raise notice 'var1 = %', var1;
	var1.delete(4);
	raise notice 'var1 = %', var1;
	var1.trim(1);
	raise notice 'var1 = %', var1;
	var1.extend(2);
	raise notice 'var1 = %', var1;
	var1(5) := 'dd';
	raise notice 'var1 = %', var1;
	var1.extend(2, 5);
	raise notice 'var1 = %', var1;
	var1.delete(7, 7);
	raise notice 'var1 = %', var1;
end;
/
call nested_tab_proc1();

create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of varchar(10);
	var1 type_aa := type_aa('aa', 'bb', 'cc');
begin
	var1.extend(2, 0);
end;
/
select nested_tab_func1();

create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of varchar(10);
	var1 type_aa := type_aa('aa', 'bb', 'cc');
begin
	var1.extend(0);
	raise notice 'var1 = %', var1;
	var1.extend(-1);
end;
/
select nested_tab_func1();

--mix use varray and nested table
create or replace function nested_tab_func1() return void as
declare
	type type_aa is varray(10) of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
	type type_bb is table of type_aa;
	var2 type_bb := type_bb(type_aa(66, 77), var1);
	type type_cc is table of type_bb;
	var3 type_cc := type_cc(var2, var2);
begin
	raise notice 'var1 = %', var1;
	raise notice 'var2 = %', var2;
	var1.extend(2);
	var3.extend();
	var3(3) := type_bb(var1);
	raise notice 'var3 = %', var3;
	var3(1)(1).extend(1, 1);
	raise notice 'var3 = %', var3;
	var3(1).extend(1);
	raise notice 'var3 = %', var3;
	var3(1)(1).trim(1);
	raise notice 'var3 = %', var3;
end;
/
select nested_tab_func1();

--
--exists function
--
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of varchar(10);
	var1 type_aa := type_aa('aa', 'bb', 'cc');
begin
	raise notice 'var1(1) = %, var1(4) = %', var1.exists(1), var1.exists(4);
	raise notice 'var1(0) = %, var1(-1) = %', var1.exists(0), var1.exists(-1);
end;
/
select nested_tab_func1();

create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of varchar(10);
	var1 type_aa := type_aa('aa', 'bb', 'cc');
begin
	raise notice 'var1(4) = %', var1.exists(4);

	var1.extend(2);
	if var1.exists(4) then
		raise notice 'var1.exists(4) exists';
	else
		raise notice 'var1.exists(4) not exists';
	end if;

	var1.delete(3);
	if var1.exists(3) = 't' then
		raise notice 'var1.exists(3) exists';
	else
		raise notice 'var1.exists(3) not exists';
	end if;

	var1.trim(3);
	if var1.exists(2) then
		raise notice 'var1.exists(2) exists';
	else
		raise notice 'var1.exists(2) not exists';
	end if;

	if var1.exists(3) then
		raise notice 'var1.exists(3) exists';
	else
		raise notice 'var1.exists(3) not exists';
	end if;

	var1.delete();
	raise notice 'var1(1) = %', var1.exists(1);
end;
/
select nested_tab_func1();

--mix use varray and nested table
create or replace function nested_tab_func1() return void as
declare
	type type_aa is varray(10) of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
	type type_bb is table of type_aa;
	var2 type_bb := type_bb(type_aa(66, 77), var1);
	type type_cc is table of type_bb;
	var3 type_cc := type_cc(var2, var2);
begin
	raise notice 'var3(2)(2) = %', var3(2).exists(2);
	var3(2).delete(2);
	raise notice 'var3(2)(2) = %', var3(2).exists(2);
	raise notice 'var3(2)(1)(3) = %', var3(2)(1).exists(3);
	var3(2)(1).extend;
	raise notice 'var3(2)(1)(3) = %', var3(2)(1).exists(3);
end;
/
select nested_tab_func1();

create or replace function nested_tab_func2() return bool as
declare
	type type_aa is table of varchar(10);
	var1 type_aa := type_aa('aa', 'bb', 'cc', 'dd', 'ee');
begin
	var1.delete(1, 5);
	return var1.exists(5);
end;
/
select nested_tab_func2();

--
--first and last function
--
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of varchar(10);
	var1 type_aa := type_aa('aa', 'bb', 'cc', 'dd', 'ee');
begin
	raise notice 'var1.first = %', var1.first;
	raise notice 'var1.last = %', var1.last;
	var1.delete(1);
	var1.delete(4, 5);
	raise notice 'var1.first = %', var1.first;
	raise notice 'var1.last = %', var1.last;
end;
/
select nested_tab_func1();

create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of varchar(10);
	var1 type_aa := type_aa('aa', 'bb', 'cc', 'dd', 'ee');
begin
	raise notice 'var1.first = %', var1.first;
	raise notice 'var1.last = %', var1.last;
	var1.delete(1);
	var1.delete(4, 5);
	var1.extend();
	raise notice 'var1.first = %', var1.first;
	raise notice 'var1.last = %', var1.last;
	var1.trim(4);
	raise notice 'var1.first = %', var1.first;
	raise notice 'var1.last = %', var1.last;
	var1.delete();
	raise notice 'var1.first = %', var1.first;
	raise notice 'var1.last = %', var1.last;
	var1.extend(2);
	raise notice 'var1.first = %', var1.first;
	raise notice 'var1.last = %', var1.last;
	raise notice 'var1 = %', var1;
end;
/
select nested_tab_func1();

--mix use varray and nested table
create or replace function nested_tab_func1() return void as
declare
	type type_aa is varray(10) of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
	type type_bb is table of type_aa;
	var2 type_bb := type_bb(type_aa(66, 77), var1);
	type type_cc is table of type_bb;
	var3 type_cc := type_cc(var2, var2);
	var4 type_aa;
begin
	raise notice 'var3(1)(2).first = %', var3(1)(2).first(); --1
	raise notice 'var3(1)(2).last = %', var3(1)(2).last(); --5
	var3(1)(1).delete;
	raise notice 'var3(1)(1).first = %', var3(1)(1).first(); --NULL
	raise notice 'var3(1)(1).last = %', var3(1)(1).last(); --NULL
	var4 := type_aa(88, 99, 100);
	var3(1)(1) := var4;
	raise notice 'var3(1)(1)(3) = %', var3(1)(1)(3);
	var3(1).delete(1, 2);
	raise notice 'var3(1).first = %', var3(1).first;
	raise notice 'var3(1).last = %', var3(1).last;
end;
/
select nested_tab_func1();

--
--count function
--
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of varchar(10);
	var1 type_aa := type_aa('aa', 'bb', 'cc', 'dd', 'ee');
begin
	raise notice 'var1.count = %', var1.count; --5
	var1.delete(1);
	raise notice 'var1 = %', var1;
	raise notice 'var1.count = %', var1.count;
	var1.delete(1, 5);
	raise notice 'var1.count = %', var1.count; --0
	var1.trim();
	raise notice 'var1.count = %', var1.count; --0
	var1.extend(3);
	raise notice 'var1 = %', var1;
	raise notice 'var1.count = %', var1.count; --3
	var1.delete(6, 7);
	raise notice 'var1.count = %', var1.count; --1
	var1.delete;
	raise notice 'var1.count = %', var1.count; --0
end;
/
select nested_tab_func1();

--mix use varray and nested table
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
	type type_bb is table of type_aa;
	var2 type_bb := type_bb(type_aa(66, 77), var1);
	type type_cc is varray(10) of type_bb;
	var3 type_cc := type_cc(var2, var2);
begin
	raise notice 'var1.count = %', var1.count(); --5
	raise notice 'var2.count = %', var2.count(); --2
	raise notice 'var3.count = %', var3.count(); --2

	if var2.count = var2.last then
		raise notice 'var2.count equal var2.last';
	else
		raise notice 'var2.count not equal var2.last';
	end if;

	var3(1).delete(1);
	raise notice 'var3(1).count = %', var3(1).count; --1
	var2(1).trim(2);
	raise notice 'var2(1).count = %', var2(1).count; --0
	var3(1).extend(2, 2);
	raise notice 'var3(1).count = %', var3(1).count; --3
end;
/
select nested_tab_func1();

--
--limit function
--
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of varchar(10);
	var1 type_aa := type_aa('aa', 'bb', 'cc', 'dd', 'ee');
begin
	raise notice 'var1.limit = %', var1.limit;
	var1.delete(1, 5);
	raise notice 'var1.limit = %', var1.limit;
	var1.delete();
	raise notice 'var1.limit = %', var1.limit;
end;
/
select nested_tab_func1();

--mix use varray and nested table
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
	type type_bb is table of type_aa;
	var2 type_bb := type_bb(type_aa(66, 77), var1);
	type type_cc is varray(10) of type_bb;
	var3 type_cc := type_cc(var2, var2);
begin
	raise notice 'var2.limit = %', var2.limit; --NULL
	raise notice 'var3.limit = %', var3.limit; --10
	raise notice 'var3(1)(2).limit = %', var3(1)(2).limit; --NULL

	if var3(1).limit is null then
		raise notice 'var3(1).limit is null';
	else
		raise notice 'var3(1).limit is not null';
	end if;

	var3(1)(1).extend(1, 2);
	raise notice 'var3(1)(1).limit = %', var3(1)(1).limit; --NULL
end;
/
select nested_tab_func1();

--
--prior and next function
--
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of varchar(10);
	var1 type_aa := type_aa('aa', 'bb', 'cc', 'dd', 'ee');
begin
	raise notice 'var1.prior(5) = %', var1.prior(var1.last); --4
	raise notice 'var1.prior(6) = %', var1.prior(6); --5
	raise notice 'var1.prior(6) = %', var1.prior(var1.first); --NULL
	var1.delete(1, 2);
	raise notice 'var1.prior(4) = %', var1.prior(4); --3
	raise notice 'var1.prior(3) = %', var1.prior(4 - 1); --NULL
	var1.delete(1, 5);
	var1.extend;
	raise notice 'var1.prior(6) = %', var1.prior(6); --NULL
	raise notice 'var1.prior(7) = %', var1.prior(7); --6
	var1.delete;
	raise notice 'var1.prior(7) = %', var1.prior(7); --NULL
	raise notice 'var1.prior(3) = %', var1.prior(3); --NULL
	var1.extend(2);
	raise notice 'var1.prior(3) = %', var1.prior(3); --2
	var1.trim(1);
	raise notice 'var1.prior(3) = %', var1.prior(3); --1
end;
/
select nested_tab_func1();

create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of varchar(10);
	var1 type_aa := type_aa('aa', 'bb', 'cc', 'dd', 'ee');
begin
	raise notice 'var1.next(-1) = %', var1.next(-1); --1
	raise notice 'var1.next(1) = %', var1.next(1); --2
	raise notice 'var1.next(5) = %', var1.next(var1.last); --NULL
	var1.delete(3, 4);
	raise notice 'var1.next(0) = %', var1.next(0); --1
	raise notice 'var1.next(3) = %', var1.next(3); --5
	var1.delete(1);
	var1(3) := 'ff';
	raise notice 'var1.next(0) = %', var1.next(0); --2
	raise notice 'var1.next(2) = %', var1.next(2); --3
	var1.delete(1, 5);
	raise notice 'var1.next(-2) = %', var1.next(-2); --NULL
	raise notice 'var1.next(6) = %', var1.next(6); --NULL
	var1.extend(2);
	raise notice 'var1.next(3) = %', var1.next(3); --6
	var1.trim(1);
	raise notice 'var1.next(3) = %', var1.next(3); --6
end;
/
select nested_tab_func1();

--mix use varray and nested table
create table nestedtab_test(id int, flg int);
create or replace function nested_tab_func3() return int as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
	type type_bb is table of type_aa;
	var2 type_bb := type_bb(type_aa(66, 77), var1);
	type type_cc is varray(10) of type_bb;
	var3 type_cc := type_cc(var2, var2);
	var4 int;
begin
	if var3.next(1) = var2(1).prior(3) then
		raise notice 'var3.next(1) equal var2(1).prior(3)';--y
	else
		raise notice 'var3.next(1) not equal var2(1).prior(3)';
	end if;

	var4 := var3(1)(1).last;
	insert into nestedtab_test values(var4, var2(2)(5)), (var3(1)(1)(2), var1(2)); --2, 55/77, 22
	update nestedtab_test set id = var3(2)(1)(1), flg = var1(3) where id = var2(2)(1) - 9; --66, 33/77, 22

	var3(1).trim;
	var2.delete(2);
	if var3(1).next(0) = var2.prior(4) then
		raise notice 'var3(1).next(0) equal var2(1).prior(3)';--y
	else
		raise notice 'var3(1).next(0) not equal var2.prior(4)';
	end if;

	var2.extend(1);
	var3.extend(1, 2);
	if var3.prior(5) = var2.next(1) then
		raise notice 'var3.prior(5) equal var2.next(1)';--y
	else
		raise notice 'var3.prior(5) not equal var2.next(1)';
	end if;

	return var3(3)(2).next(1) + var3(3)(2).prior(5); --6
end;
/
select nested_tab_func3();
select id, flg from nestedtab_test;

--init empty value and assign value to it
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa();
	type type_bb is varray(10) of varchar(10);
	var2 type_bb := type_bb();
begin
	raise notice 'var1.count = %', var1.count; --0
	raise notice 'var2.count = %', var2.count; --0
	raise notice 'var1.first = %', var1.first; --NULL
	raise notice 'var2.last = %', var2.last; --NULL
	raise notice 'var2.exists(1) = %', var2.exists(1); --f
	raise notice 'var1.limit = %', var1.limit; --NULL
	raise notice 'var2.limit = %', var2.limit; --10
	var1.extend;
	var1(1) := 11;
	raise notice 'var1 = %', var1; --11
	raise notice 'var1.count = %', var1.count; --1
	raise notice 'var1.last = %', var1.last; --1
	raise notice 'var1.exists(1) = %', var1.exists(1); --t
end;
/
select nested_tab_func1();

--if is empty, it will not throw error when delete
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa();
begin
	var1.delete;
	var1.delete(2);
	raise notice 'var1 = %', var1;
end;
/
select nested_tab_func1();

--if is empty, it will throw error when trim
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa;
begin
	var1 := type_aa();
	var1.trim;
end;
/
select nested_tab_func1();

--
--extend is procedure, not is function
--
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22);
begin
	var1 := var1.extend();
end;
/
select nested_tab_func1();

--
--test empty for nested table function
--
create or replace function nested_tab_func1() return void as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa();
begin
	raise notice 'var1.exists(1) = %', var1.exists(1);
	raise notice 'var1.first = %', var1.first;
	raise notice 'var1.last = %', var1.last;
	raise notice 'var1.count = %', var1.count;
	raise notice 'var1.limit = %', var1.limit;
	raise notice 'var1.prior(0) = %', var1.prior(0);
	raise notice 'var1.next(0) = %', var1.next(0);
end;
/
select nested_tab_func1();

--
--use collection type as return type
--
drop function nested_tab_func1;
create or replace function nested_tab_func1() return nestedtab as
declare
	type type_aa is table of int;
	var type_aa;
begin
	var := type_aa(11, 22, 33, 44, 55);
	raise notice 'var = %', var;
	raise notice 'var(5) = %', var(5);

	return var;
end;
/
select nested_tab_func1();

drop function nested_tab_func1;
create or replace function nested_tab_func1() return varray as
declare
	type type_aa is table of int;
	var1 type_aa := type_aa(11, 22, 33, 44, 55);
	type type_bb is varray(10) of type_aa;
	var2 type_bb := type_bb(var1, type_aa(66, 77));
begin
	return var2;
end;
/
select nested_tab_func1();

drop function nested_tab_func1;
create or replace function nested_tab_func1() return nestedtab as
declare
	type type_aa is table of int;
	var type_aa := type_aa(11);
begin
	return var(1);
end;
/
select nested_tab_func1();

--collection type can not as common type
drop function nested_tab_func1;
create or replace function nested_tab_func1() return int as
declare
	type type_aa is table of varray;
	var type_aa := type_aa(11);
begin
	return var(1);
end;
/

create or replace function nested_tab_func1() returns int as $$
declare
	id nestedtab;
begin
	return 1;
end; $$language plpgsql;

create table test(id int, flg varray);