--
--Basic type correlation test: assignment, value, etc
--
create function test_varray_basic1() returns VOID as $$
DECLARE
 type newtype1 as varray(7) of int;
 va newtype1;
BEGIN
 va = newtype1(111,222);
 raise notice 'value= % ', va(2);
end; $$ language plisql;
select test_varray_basic1();

create function test_varray_basic2() returns VOID as $$
DECLARE
 TYPE new_int as varray(5) OF varchar(64) ;
 va new_int;
BEGIN
 va(1) = '11';
 va(2) = '222';
 va(3) = '3333';
 va(4) = '4';
 raise notice '%', va(1);
 raise notice '%', va(2);
 raise notice '%', va(3);
 raise notice '%', va(4);
end; $$ language plisql;
select test_varray_basic2();

create function test_varray_basic3() returns VOID as $$
DECLARE
 type newtype1 as varray(7) of int;
 aaaa newtype1;
 bbbb newtype1;
BEGIN
 aaaa = newtype1(111,222);
 bbbb = newtype1(333,444);
 raise notice 'value= % ', aaaa;
 raise notice 'value= % ', bbbb(2);
end; $$ language plisql;
select test_varray_basic3();

create function test_varray_basic4() returns VOID as $$
DECLARE
 type newtype1 as varray(7) of int;
 type newtype2 as varray(7) of text;
 aaaa newtype1;
 bbbb newtype2;
BEGIN
 aaaa = newtype1(111,222);
 bbbb = newtype2('aaa', 'bbb');
 raise notice 'value= % ', aaaa(2);
 raise notice 'value= % ', bbbb(2);
end; $$ language plisql;
select test_varray_basic4();

create function test_varray_basic5() returns VOID as $$
DECLARE
 type newtype1 as varray(7) of int;
 type newtype2 as varray(7) of text;
 aaaa1 newtype1;
 aaaa2 newtype1;
 bbbb1 newtype2;
 bbbb2 newtype2;
BEGIN
 aaaa1 = newtype1(111,222);
 aaaa2 = newtype1(333,444);
 bbbb1 = newtype2('aaa', 'bbb');
 bbbb2 = newtype2('ccc', 'ddd');
 raise notice 'value= % ', aaaa1;
 raise notice 'value= % ', aaaa2(2);
 raise notice 'value= % ', bbbb1;
 raise notice 'value= % ', bbbb2(2);
end; $$ language plisql;
select test_varray_basic5();

create function test_varray_basic6() returns VOID as $$
DECLARE
 TYPE new_int1 as varray(5) OF int ;
 TYPE new_text as varray(5) OF text ;
 TYPE new_int2 as varray(5) OF int ;
 a new_int1;
 b new_text;
 c new_int2;
BEGIN
 a = new_int1(11, 222, 3333, 4);
 b = new_text('t11', '22b2', '33a33', '4');
 c = new_int2(11, 222, 3333, 4);
 raise notice '%', a(1);
 raise notice '%', b(2);
 raise notice '%', c(3);
end; $$ language plisql;
select test_varray_basic6();

create function test_varray_basic7() returns VOID as $$
DECLARE
 TYPE new_text as varray(5) OF text ;
 a new_text;
BEGIN
 a = new_text(11, 222, 3333, 4);
 raise notice '%', a(1);
end; $$ language plisql;
select test_varray_basic7();

create function test_varray_basic8() returns VOID as $$
DECLARE
 TYPE new_int as varray(5) OF int ;
 a new_int;
BEGIN
 a = new_int(11, 222, 3333, 4);
 raise notice '%', a(1);
end; $$ language plisql;
select test_varray_basic8();

create function test_varray_basic9() returns VOID as $$
DECLARE
 TYPE new_int as varray(5) OF int ;
 a new_int;
BEGIN
 a = new_int('aa', 'bbb', '3333', 'ddd');
 raise notice '%', a(1);
end; $$ language plisql;
select test_varray_basic9();

create function test_varray_basic10() returns VOID as $$
DECLARE
 TYPE new_int as varray(5) OF int ;
 a new_int := new_int(NULL, 0, 3333, 0);
BEGIN
 a(1) = 11;
 a(2) = 222;
 a(3) = 3333;
 a(4) = 4;
 raise notice '%', a(1);
 raise notice '%', a(2);
 raise notice '%', a(3);
 raise notice '%', a(4);
end; $$ language plisql;
select test_varray_basic10();

create function test_varray_basic11() returns VOID as $$
DECLARE
 TYPE new_text as varray(5) OF text ;
 a new_text := new_text('aa', 'bbb', '3333', 'ddd');
BEGIN
 a(1) = 11;
 a(2) = 222;
 a(3) = 3333;
 a(4) = 4;
 raise notice '%', a(1);
 raise notice '%', a(2);
 raise notice '%', a(3);
 raise notice '%', a(4);
end; $$ language plisql;
select test_varray_basic11();

create function test_varray_basic12() returns VOID as $$
DECLARE
 TYPE new_int as varray(5) OF int ;
 a new_int:= new_int(NULL, NULL, NULL, NULL);
BEGIN
 a(1) = 'a';
 a(2) = 'bb';
 a(3) = 'ccc';
 a(4) = 'dddd';
 raise notice '%', a(1);
 raise notice '%', a(2);
 raise notice '%', a(3);
 raise notice '%', a(4);
end; $$ language plisql;
select test_varray_basic12();

create function test_varray_basic13() returns VOID as $$
DECLARE
 TYPE new_int as varray(5) OF int ;
 a1 new_int;
 a2 new_int;
BEGIN
 a1 = new_int(11, 222, 3333, 4);
 a2 = a1;
 raise notice '%', a2(1);
 raise notice '%', a2;
end; $$ language plisql;
select test_varray_basic13();

create function test_varray_basic14() returns VOID as $$
DECLARE
 TYPE new_int1 as varray(5) OF int ;
 a1 new_int1;
 TYPE new_int2 as varray(5) OF int ;
 b1 new_int2;
BEGIN
 a1 = new_int1(11, 222, 3333, 4);
 b1 = a1;
 raise notice '%', b1(1);
 raise notice '%', b1;
end; $$ language plisql;
select test_varray_basic14();

create function test_varray_basic15() returns VOID as $$
DECLARE
 TYPE new_int1 as varray(5) OF int ;
 a1 new_int1;
 b1 int array;
BEGIN
 a1 = new_int1(11, 222, 3333, 4);
 b1 = a1;
 raise notice '%', b1[1];
 raise notice '%', b1;
end; $$ language plisql;
select test_varray_basic15();

create function test_varray_basic16() returns VOID as $$
DECLARE
 TYPE new_int1 as varray(5) OF int ;
 a new_int1;
 b int;
 c text;
BEGIN
 a = new_int1(11, 222, 3333, 4);
 b = a(2);
 c = a(2);
 raise notice '%', a(1);
 raise notice '%', b;
 raise notice '%', c;
end; $$ language plisql;
select test_varray_basic16();

create function test_varray_basic17() returns VOID as $$
DECLARE
 TYPE new_int1 as varray(5) OF int ;
 a new_int1;
 b int;
 c text;
BEGIN
 a = new_int1(11, 222, 3333, 4);
 b = a(2);
 c = a(2);
 raise notice '%', a(1);
 raise notice '%', b;
 raise notice '%', c;
end; $$ language plisql;
select test_varray_basic17();

create function test_varray_basic18() returns VOID as $$
DECLARE
 TYPE new_int1 as varray(5) OF int ;
 a new_int1;
 b int;
 TYPE new_text as varray(5) OF text ;
 c int;
 d new_text;
BEGIN
 a = new_int1(11, 222, 3333, 4);
 b = a(2);
 d = new_text('t11', '22b2', '33a33', '4');
 c = d(1);
 raise notice '%', a(1);
 raise notice '%', b;
 raise notice '%', c;
 raise notice '%', d;
end; $$ language plisql;
select test_varray_basic18();

create function test_varray_basic19() returns VOID as $$
DECLARE
 TYPE new_int1 as varray(5) OF int ;
 a new_int1;
 b int;
 TYPE new_text as varray(5) OF text ;
 c int array;
 d new_text;
BEGIN
 a = new_int1(11, 222, 3333, 4);
 b = a(2);
 d = new_text('t11', '22b2', '33a33', '4');
 c[1] = a(2);
 raise notice '%', a(1);
 raise notice '%', b;
 raise notice '%', d(3);
 raise notice '%', c[1];
end; $$ language plisql;
select test_varray_basic19();

create function test_varray_basic20() returns VOID as $$
DECLARE
 TYPE new_int1 as varray(5) OF int ;
 a new_int1;
 b int;
 TYPE new_text as varray(5) OF text ;
 c int array;
 d new_text;
BEGIN
 a = new_int1(11, 222, 3333, 4);
 b = a(2);
 d = new_text('t11', '22b2', '33a33', '4');
 c[1] = a(2);
 raise notice '%', a(1);
 raise notice '%', b;
 raise notice '%', d(3);
 raise notice '%', c[1];
end; $$ language plisql;
select test_varray_basic20();

create function test_varray_basic21() returns VOID as $$
DECLARE
 TYPE new_int1 is varray(5) OF int ;
 TYPE new_text is varray(5) OF text ;
 TYPE new_int2 is varray(5) OF int ;
 a new_int1;
 b new_text;
 c new_int2;
BEGIN
 a = new_int1(11, 222, 3333, 4);
 b = new_text('t11', '22b2', '33a33', '4');
 c = new_int2(11, 222, 3333, 4);
 raise notice '%', a(1);
 raise notice '%', b(2);
 raise notice '%', c(3);
end; $$ language plisql;
select test_varray_basic21();

create function test_varray_basic22() returns VOID as $$
DECLARE
 TYPE new_text as varray(5) OF text ;
 a new_text;
BEGIN
 a = new_text(1, 22, 333, 4444, 55555, 666666);
 raise notice '%', a(1);
end; $$ language plisql;
select test_varray_basic22();

create function test_varray_basic23() returns VOID as $$
DECLARE
 TYPE new_text as varray(5) OF text ;
 a new_text := new_text('t11', '22b2', '33a33', '4','55');
BEGIN
 a(6) = 666666;
 raise notice '%', a(6);
end; $$ language plisql;
select test_varray_basic23();

create function test_varray_basic24() returns VOID as $$
DECLARE
 TYPE new_text as varray(5) OF text ;
 a new_text:= new_text('t11', '22b2', '33a33', '4','55');
BEGIN
 a(0) = 11;
 raise notice '%', a(0);
end; $$ language plisql;
select test_varray_basic24();

create function test_varray_basic25() returns VOID as $$
DECLARE
 TYPE new_text as varray(5) OF text ;
 a new_text = new_text('t11', '22b2', '3a33', '4','55');
BEGIN
 a(-1) = 11;
 raise notice '%', a(-1);
end; $$ language plisql;
select test_varray_basic25();

create function test_varray_basic26() returns VOID as $$
DECLARE
 TYPE new_text as varray(5) OF text ;
 a new_text;
BEGIN
 a(-1) = 11;
 raise notice '%', a(-1);
end; $$ language plisql;
select test_varray_basic26();
--
--Basic type operation and function testing: execution, modification, etc
--
create function test_varray_func_basic1() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type:= va_type('11', '22', '33', '44', '55', '66');
 BEGIN
 va.delete(); 
 raise notice '%', va;
end; $$ language plisql;
select test_varray_func_basic1();

create function test_varray_func_basic2() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type:= va_type('11', '22', '33', '44', '55', '66');
BEGIN
 va.DELETE(); 
 raise notice '%', va(2);
end; $$ language plisql;
select test_varray_func_basic2();

create function test_varray_func_basic3() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type:= va_type('11', '22', '33', '44', '55', '66');
BEGIN
 va.DELETE(); 
 va(2) = 'bb';
 raise notice '%', va(2);
end; $$ language plisql;
select test_varray_func_basic3();

create function test_varray_func_basic4() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type:= va_type('11', '22', '33', '44', '55', '66');
BEGIN
 raise notice '%',(va);
 va.trim();
 raise notice '%',(va);
 va.TRIM(4);
 raise notice '%',(va);
end; $$ language plisql;
select test_varray_func_basic4();

create function test_varray_func_basic5() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type:= va_type('11', '22', '33', '44', '55', '66', '77');
BEGIN
 raise notice '%',(va);
 va(3) = '333';
 va(4) = '444';
 va(7) = '777';
 raise notice '%',(va);
 va.trim(9);
 raise notice '%',(va);
end; $$ language plisql;
select test_varray_func_basic5();


create function test_varray_func_basic6() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type:= va_type('11', '22', '33');
BEGIN
 raise notice '%',(va);
 va.extend(); 
 raise notice '%',(va);
 va.extend(2); 
 raise notice '%',(va);
 va.extend(1,1); 
 raise notice '%',(va);
 va.extend(3,3); 
 raise notice '%',(va);
end; $$ language plisql;
select test_varray_func_basic6();

create function test_varray_func_basic7() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type:= va_type('11', '22', '33');
BEGIN
 raise notice '%',(va);
 va.extend(); 
 raise notice '%',(va);
 va.extend(2); 
 raise notice '%',(va);
 va.extend(1,1); 
 raise notice '%',(va);
 va.extend(1,3); 
 raise notice '%',(va);
 va.extend(3,3); 
 raise notice '%',(va);
end; $$ language plisql;
select test_varray_func_basic7();

create function test_varray_func_basic8() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type:= va_type('11', '22', '33');
 va1 va_type;
 va2 va_type;
BEGIN
 va.extend(); 
 va1=va;
 va2 = va1;
 va(4) = '44';
 va1(4) = 'ff';
 va2(4) = 'gg';
 raise notice '%',(va);
 raise notice '%',(va1);
 raise notice '%',(va2);
end; $$ language plisql;
select test_varray_func_basic8();

create function test_varray_func_basic9() returns VOID as $$
DECLARE
 TYPE va_type as varray(15) OF text;
 va va_type:= va_type('11', '22', '33', '44', '55', '66');
BEGIN
 raise notice '%',(va);
 va.extend(); 
 raise notice '%',(va);
 va.extend(2); 
 raise notice '%',(va);
 va.extend(6,1); 
 raise notice '%',(va);
 va.extend(8); 
 raise notice '%',(va);
end; $$ language plisql;
select test_varray_func_basic9();

create function test_varray_func_basic10() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type:= va_type('11', '22', '33', '44', '55', '66');
 aa text ;
 isexists bool;
BEGIN
 FOR i IN 1..3 LOOP
 isexists = va.exists(i);
 IF isexists THEN
 raise notice 'va(%) = %',i,va(i);
 ELSE
 raise notice 'va(%) does not exist',i;
 END IF;
 END LOOP;
end; $$ language plisql;
select test_varray_func_basic10();

create function test_varray_func_basic11() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va1 va_type:= va_type('11', '22', '33', '44', '55', '66');
 va2 va_type:=va_type('11', '22', '33', '44', '55', '66');
 aa text ;
 isexists bool;
BEGIN
 raise notice 'va1.first = %',va1.first();
 raise notice 'va1.last = %',va1.last();
 va2.extend();
 va2(3) = '333';
 va2(4) = '444';
 va2(7) = '777';
 raise notice 'va2.first = %',va2.first();
 raise notice 'va2.last = %',va2.last();
end; $$ language plisql;
select test_varray_func_basic12();

create function test_varray_func_basic13() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type:= va_type('11', '22', '33');
 num text;
BEGIN
 va.EXTEND(4);
 raise notice 'va = %',va;
 raise notice 'va.last = %',va.last();
 raise notice 'va.count = %',va.count();
 va.trim(3);
 raise notice 'va = %',va;
 raise notice 'va.last = %',va.last();
 raise notice 'va.count = %',va.count();
end; $$ language plisql;
select test_varray_func_basic13();

create function test_varray_func_basic14() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va2 va_type:= va_type('11', '22', '33','44','55','66','77');
 aa text ;
 isexists bool;
BEGIN
 va2(3) = '333';
 va2(4) = '444';
 va2(7) = '777';
 raise notice 'va2.last = %',va2.last();
 raise notice 'va2.count = %',va2.count();
end; $$ language plisql;
select test_varray_func_basic14();

create function test_varray_func_basic15() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type:= va_type('11', '22', '33');
 num text;
BEGIN
 raise notice 'va.COUNT = %',va.COUNT();
 raise notice 'va.LIMIT = %',va.limit();
end; $$ language plisql;
select test_varray_func_basic15();

create function test_varray_func_basic16() returns VOID as $$
DECLARE
 TYPE va_type IS VARRAY(10) OF int;
 va va_type:= va_type('11', '22', '33', '44');
BEGIN
 va(1) := 10;
 va(2) := 20;
 va(3) := 30;
 va(4) := 40;
 raise notice 'va.prior(3) = %',va.prior (3);
 raise notice 'va.next(3) = %',va.next (3);
 raise notice 'va.prior(3400) = %',va.prior (3400);
 raise notice 'va.next(3400) = %',va.next (3400);
end; $$ language plisql;
select test_varray_func_basic16();

--
--Basic type operation and function test: joint test, test if deleted after deletion is normal return----------------------------------------------------
--
create function test_varray_func_err1_1() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type:= va_type('11', '22', '33', '44', '55', '66');
BEGIN
 va.DELETE(); 
 va = va_type('aa', 'bb');
 raise notice '%', va(2);
end; $$ language plisql;
select test_varray_func_err1_1();

create function test_varray_func_err1_2() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type ;
BEGIN
 va(3) = '333';
 va(4) = '444';
 va.delete();
 raise notice '%', va(3);
end; $$ language plisql;
select test_varray_func_err1_2();

create function test_varray_func_err1_3() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type:= va_type('11', '22');
BEGIN
 va(3) = '333';
 va(4) = '444';
 raise notice '%', va(4);
end; $$ language plisql;
select test_varray_func_err1_3();

create function test_varray_func_err1_4() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type:= va_type('11', '22', '33', '44', '55', '66');
BEGIN
 raise notice '%',(va);
 va.delete();
 va.TRIM(4);
 raise notice '%',(va);
end; $$ language plisql;
select test_varray_func_err1_4();

create function test_varray_func_err1_5() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type:= va_type('11', '22', '33', '44', '55', '66');
BEGIN
 raise notice '%',(va);
 va.delete();
 va.EXTEND(2,1); 
 raise notice '%',(va);
end; $$ language plisql;
create function test_varray_func_err1_5() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type:= va_type('11', '22', '33', '44', '55', '66');
BEGIN
 raise notice '%',(va);
 va.delete();
 va.EXTEND(3); 
 raise notice '%',(va);
end; $$ language plisql;
select test_varray_func_err1_5();

create function test_varray_func_err1_6() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type:= va_type('11', '22', '33', '44', '55', '66');
BEGIN
 raise notice '%',(va);
 va.delete();
 va.EXTEND(3); 
 va.extend(2);
 va(4) = 'aa';
 raise notice '%',(va);
end; $$ language plisql;
select test_varray_func_err1_6();

create function test_varray_func_err1_7() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type:= va_type('11', '22', '33', '44', '55', '66');
BEGIN
 raise notice '%',(va);
 va.delete();
 va.EXTEND(3); 
 va(2) = 'aa';
 raise notice '%',(va);
end; $$ language plisql;
select test_varray_func_err1_7();

create function test_varray_func_err1_8() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type:= va_type('11', '22', '33', '44', '55', '66');
 isexists bool;
BEGIN
 FOR i IN 1..3 LOOP
 isexists = va.exists(i);
 IF isexists THEN
 raise notice 'va(%) = %',i,va(i);
 ELSE
 raise notice 'va(%) does not exist',i;
 END IF;
 END LOOP;
 va.delete();
 FOR i IN 1..3 LOOP
 isexists = va.exists(i);
 IF isexists THEN
 raise notice 'va(%) = %',i,va(i);
 ELSE
 raise notice 'va(%) does not exist',i;
 END IF;
 END LOOP;
end; $$ language plisql;
select test_varray_func_err1_8();

create function test_varray_func_err1_9() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type:= va_type('11', '22', '33', '44', '55', '66','77');
BEGIN
 va(3) = '333';
 va(4) = '444';
 va(7) = '777';
 raise notice 'va.first = %',va.first();
 raise notice 'va.last = %',va.last();
 va.delete();
 raise notice 'va.first = %',va.first();
 raise notice 'va.last = %',va.last();
end; $$ language plisql;
select test_varray_func_err1_9();

create function test_varray_func_err1_10() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type:= va_type('11', '22', '33', '44', '55', '66');
BEGIN
 raise notice 'va.first = %',va.first();
 raise notice 'va.last = %',va.last();
 va.delete();
 raise notice 'va.first = %',va.first();
 raise notice 'va.last = %',va.last();
end; $$ language plisql;
select test_varray_func_err1_10();

create function test_varray_func_err1_11() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type:= va_type('11', '22', '33');
BEGIN
 va.EXTEND(4);
 raise notice 'va = %',va;
 raise notice 'va.last = %',va.last();
 raise notice 'va.count = %',va.count();
 va.trim(3);
 raise notice 'va = %',va;
 raise notice 'va.last = %',va.last();
 raise notice 'va.count = %',va.count();
 va.delete();
 raise notice 'va.last = %',va.last();
 raise notice 'va.count = %',va.count();
end; $$ language plisql;
select test_varray_func_err1_11();

create function test_varray_func_err1_12() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type:= va_type('11', '22', '33');
 num text;
BEGIN
 va.delete();
 raise notice 'va.COUNT = %',va.COUNT();
 raise notice 'va.LIMIT = %',va.limit();
end; $$ language plisql;
select test_varray_func_err1_12();

create function test_varray_func_err1_13() returns VOID as $$
DECLARE
 TYPE va_type IS VARRAY(10) OF int;
 va va_type:= va_type('11', '22', '33', '44', '55', '66');
BEGIN
 va(1) := 10;
 va(2) := 20;
 va(3) := 30;
 va(4) := 40;
 raise notice 'va.prior(3) = %',va.prior (3);
 raise notice 'va.next(3) = %',va.next (3);
 raise notice 'va.prior(3400) = %',va.prior (3400);
 raise notice 'va.next(3400) = %',va.next (3400);
 va.delete(); 
 raise notice 'va.prior(3) = %',va.prior (3);
 raise notice 'va.next(3) = %',va.next (3);
 raise notice 'va.prior(3400) = %',va.prior (3400);
 raise notice 'va.next(3400) = %',va.next (3400);
end; $$ language plisql;
select test_varray_func_err1_13();

create function test_varray_func_err1_14() returns VOID as $$
DECLARE
 TYPE va_type IS VARRAY(10) OF int;
 va va_type:= va_type('11', '22', '33', '44');
BEGIN
 raise notice 'va.prior(1) = %',va.prior (1);
 raise notice 'va.next(1) = %',va.next (1);
 raise notice 'va.prior(3) = %',va.prior (3);
 raise notice 'va.next(3) = %',va.next (3);
 raise notice 'va.prior(3400) = %',va.prior (3400);
 raise notice 'va.next(3400) = %',va.next (3400);
 va.delete(); 
 raise notice 'va.prior(3) = %',va.prior (3);
 raise notice 'va.next(3) = %',va.next (3);
 raise notice 'va.prior(3400) = %',va.prior (3400);
 raise notice 'va.next(3400) = %',va.next (3400);
end; $$ language plisql;
select test_varray_func_err1_14();
--
--Basic type operation and function test: test the empty array call function to execute correctly
--
create function test_varray_func_err2_1() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type;
BEGIN
 va.DELETE(); 
 raise notice '%', va(2);
end; $$ language plisql; 
select test_varray_func_err2_1();

create function test_varray_func_err2_2() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type;
BEGIN
 va.TRIM(4);
 raise notice '%',(va);
end; $$ language plisql; 
select test_varray_func_err2_2();

create function test_varray_func_err2_3() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type;
BEGIN
 va.EXTEND(); 
 raise notice '%',(va);
end; $$ language plisql; 
select test_varray_func_err2_3();

create function test_varray_func_err2_4() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type;
BEGIN
 va.EXTEND(2,1); 
 raise notice '%',(va);
end; $$ language plisql; 
select test_varray_func_err2_4();

create function test_varray_func_err2_5() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type;
 isexists bool;
BEGIN
 isexists = va.exists(1);
 raise notice 'isexists = %',isexists;
end; $$ language plisql; 
select test_varray_func_err2_5();

create function test_varray_func_err2_6() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type;
BEGIN
 raise notice 'va.first = %',va.first();
 raise notice 'va.last = %',va.last();
end; $$ language plisql; 
select test_varray_func_err2_6();

create function test_varray_func_err2_7() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type;
BEGIN
 raise notice 'va.count = %',va.count();
end; $$ language plisql; 
select test_varray_func_err2_7();

create function test_varray_func_err2_8() returns VOID as $$
DECLARE
 TYPE va_type as varray(10) OF text;
 va va_type;
BEGIN
 raise notice 'va.LIMIT = %',va.limit();
end; $$ language plisql; 
select test_varray_func_err2_8();

create function test_varray_func_err2_9() returns VOID as $$
DECLARE
 TYPE va_type IS VARRAY(10) OF int;
 va va_type;
BEGIN
 raise notice 'va.prior(3) = %',va.prior (3);
 raise notice 'va.next(3) = %',va.next (3);
end; $$ language plisql; 
select test_varray_func_err2_9();
--
--Basic type constructor test
--
create function test_varray_construction_func1() returns VOID as $$
DECLARE
 TYPE va_type IS VARRAY(44) OF int;
 va va_type;
BEGIN
 va := va_type('22',33,'345',345);
 va(1) = 222;
 raise notice '%',va;
end; $$ language plisql; 
select test_varray_construction_func1();

create function test_varray_construction_func2() returns VOID as $$
DECLARE
 TYPE va_type IS VARRAY(44) OF int;
 va va_type;
BEGIN
 va := va_type(22,33,345,345);
 va(1) = 222;
 raise notice '%',va;
end; $$ language plisql; 
select test_varray_construction_func2();

create function test_varray_construction_func3() returns VOID as $$
DECLARE
 TYPE va_type IS VARRAY(44) OF int;
 va va_type;
BEGIN
 va := va_type();
 raise notice '%',va;
end; $$ language plisql; 
select test_varray_construction_func3();

create function test_varray_construction_func4() returns VOID as $$
DECLARE
 TYPE va_type IS VARRAY(44) OF int;
 va va_type;
BEGIN
 va := va_type();
 va(1) = 333;
 raise notice '%',va(1);
end; $$ language plisql; 
select test_varray_construction_func4();

create function test_varray_construction_func5() returns VOID as $$
DECLARE
 TYPE va_type IS VARRAY(44) OF int;
 va va_type;
BEGIN
 va := va_type();
 raise notice '%',va(1);
end; $$ language plisql; 
select test_varray_construction_func5();
--
--Basic type multidimensional testing: multidimensional long array testing
--
create function test_varray_multiple_dimensions1() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; -- varray of integer
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; -- varray of varray of integer
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
 i INTEGER;
BEGIN
 i := nva(2)(3);
 raise notice 'i = %',i;
 raise notice 'nva(2)(3) = %',nva(2)(3);
end; $$ language plisql; 
select test_varray_multiple_dimensions1();

create function test_varray_multiple_dimensions2() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; -- varray of integer
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; -- varray of varray of integer
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
 i INTEGER;
BEGIN
 i := nva(2)(3);
 raise notice 'nva = %',nva;
 nva(2)(3) = 3;
 raise notice 'i = %',i;
 raise notice 'nva(2)(3) = %',nva(2)(3);
 raise notice 'nva = %',nva;
end; $$ language plisql; 
select test_varray_multiple_dimensions2();

create function test_varray_multiple_dimensions3() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; -- varray of integer
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; -- varray of varray of integer
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
BEGIN
 raise notice 'nva = %',nva;
 --nva = nva.EXTEND;
 nva.extend;
 raise notice 'nva = %',nva;
 nva(5) := t1(56, 32); 
 nva(4) := t1(45,43,67,43345);
 raise notice 'nva = %',nva;
end; $$ language plisql; 
select test_varray_multiple_dimensions3();

create function test_varray_multiple_dimensions4() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; -- varray of integer
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; -- varray of varray of integer
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
 new t1;
 num int;
BEGIN
 raise notice 'nva = %',nva;
 nva.EXTEND;
 raise notice 'nva = %',nva;
 nva(4) := t1(45,43,67,43345);
 raise notice 'nva = %',nva;
 new = nva(5); 
 num = nva(5)(1);
 raise notice 'nva = %',nva;
 raise notice 'new = %',new;
 raise notice 'num = %',num;
end; $$ language plisql; 
select test_varray_multiple_dimensions4();

create function test_varray_multiple_dimensions5() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; -- varray of integer
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; -- varray of varray of integer
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
BEGIN
 raise notice 'nva = %',nva;
 nva.EXTEND;
 --nva.extend;
 raise notice 'nva = %',nva;
 nva(5) := t1(56, 32); 
 raise notice 'nva = %',nva;
end; $$ language plisql; 
select test_varray_multiple_dimensions5();

create function test_varray_multiple_dimensions6() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; -- varray of integer
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; -- varray of varray of integer
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
BEGIN
 raise notice 'nva = %',nva;
 --nva = nva.EXTEND;
 nva.extend;
 raise notice 'nva = %',nva;
 nva(5)(1) := 444;
 raise notice 'nva = %',nva;
end; $$ language plisql; 
select test_varray_multiple_dimensions6();

create function test_varray_multiple_dimensions7() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; -- varray of integer
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; -- varray of varray of integer
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
BEGIN
 raise notice 'nva = %',nva;
 --nva = nva.EXTEND;
 nva.extend;
 raise notice 'nva = %',nva;
 nva(5) := t1(444);
 raise notice 'nva = %',nva;
end; $$ language plisql; 
select test_varray_multiple_dimensions7();

create function test_varray_multiple_dimensions8() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; -- varray of integer
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; -- varray of varray of integer
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
 i INTEGER;
 va1 t1;
BEGIN
 raise notice 'va = %',va; 
 raise notice 'nva = %',nva;
 raise notice 'va1 = %',va1;
 i := nva(2)(3);
 raise notice 'i = %',i;
 va1 = t1(88,99);
 nva(4) := va1; 
 raise notice 'va = %',va; 
 raise notice 'nva = %',nva;
 raise notice 'va1 = %',va1;
end; $$ language plisql; 
select test_varray_multiple_dimensions8();

create function test_varray_multiple_dimensions9() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; -- varray of integer
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; -- varray of varray of integer
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
 i INTEGER;
 va1 t1;
BEGIN
 raise notice 'nva = %',nva;
 nva(4)(2) := 1; 
 nva(4).extend; 
 nva(4)(1) := 89; 
 raise notice 'nva = %',nva;
end; $$ language plisql; 
select test_varray_multiple_dimensions9();

create function test_varray_multiple_dimensions10() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; -- varray of integer
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; -- varray of varray of integer
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
 i INTEGER;
 va1 t1;
BEGIN
 i := nva(2)(3);
 raise notice 'i = %',i;
 nva.EXTEND;
 nva(5) := t1(56, 32); 
 nva(4) := t1(45,43,67,43345);
 nva(4)(3) := 1; 
 nva(4).EXTEND; 
 nva(4)(4) := 89; 
 raise notice 'va = %',va; 
 raise notice 'nva = %',nva;
 raise notice 'va1 = %',va1;
end; $$ language plisql; 
select test_varray_multiple_dimensions10();

create function test_varray_multiple_dimensions11() returns VOID as $$
DECLARE
 TYPE tb1 as varray(15) OF int;
 v4 tb1 = tb1(11,22,33,44);
 v5 tb1 = tb1(11,22,33,44);
 TYPE tb2 as varray(15) OF tb1;
 v2 tb2 = tb2(tb1(11),tb1(22),v5);
BEGIN
 v4(1) := 666;
 v4(2) := 777;
 v2(1) := v4;
 raise notice '%', v2;
 raise notice '%', v2(1)(1);
 raise notice '%', v2(1)(2);
end; $$ language plisql; 
select test_varray_multiple_dimensions11();

create function test_varray_multiple_dimensions12() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; -- varray of integer
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; -- varray of varray of integer
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
 TYPE nt3 IS VARRAY(33) OF nt1;
 nva3 nt3 := nt3(nva, nva);
 i INTEGER;
BEGIN
 i := nva(2)(3);
 raise notice 'nva = %',nva;
 nva(2)(3) = 3;
 raise notice 'i = %',i;
 raise notice 'nva(2)(3) = %',nva(2)(3);
 raise notice 'nva = %',nva;
 raise notice 'nva3 = %',nva3;
 nva3(1)(1)(1) = 999;
 nva3(2)(2)(2) = 888;
 raise notice 'nva3 = %',nva3;
 raise notice 'nva3(1)(1)(1) = %',nva3(1)(1)(1);
end; $$ language plisql; 
select test_varray_multiple_dimensions12();
--
--Basic type multidimensional invocation function test
--
create function test_varray_multiple_dimensions_func1() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; 
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; 
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
 BEGIN
 nva.delete(); 
 raise notice '%', nva;
end; $$ language plisql; 
select test_varray_multiple_dimensions_func1();

create function test_varray_multiple_dimensions_func2() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; 
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; 
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
BEGIN
 nva(1).delete(); 
 raise notice '%', nva;
end; $$ language plisql; 
select test_varray_multiple_dimensions_func2();

create function test_varray_multiple_dimensions_func3() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; 
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; 
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
BEGIN
 nva(1).delete(); 
 raise notice '%', nva(2);
end; $$ language plisql; 
select test_varray_multiple_dimensions_func3();

create function test_varray_multiple_dimensions_func4() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; 
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; 
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
BEGIN
 raise notice '%',(nva(1));
 nva(1).trim();
 raise notice '%',(nva(1));
 nva(1).trim;
 raise notice '%',(nva(1));
 nva(1).TRIM(4);
 raise notice '%',(nva(1));
end; $$ language plisql;
select test_varray_multiple_dimensions_func4();

create function test_varray_multiple_dimensions_func5() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; 
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; 
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
BEGIN
 raise notice '%',(nva);
 nva.trim(1);
 raise notice '%',(nva);
end; $$ language plisql; 
select test_varray_multiple_dimensions_func5();

create function test_varray_multiple_dimensions_func6() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; 
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; 
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
BEGIN
 raise notice '%',(nva);
 nva.trim(9);
 raise notice '%',(nva);
end; $$ language plisql; 
select test_varray_multiple_dimensions_func6();

create function test_varray_multiple_dimensions_func7() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; 
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; 
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
BEGIN
 raise notice '%',(nva);
 nva(1).extend(); 
 raise notice '%',(nva);
 nva(1).extend(2); 
 raise notice '%',(nva);
 nva(1).extend(1,1); 
 raise notice '%',(nva);
 nva(1).extend(3,3); 
 raise notice '%',(nva);
end; $$ language plisql; 
select test_varray_multiple_dimensions_func7();

create function test_varray_multiple_dimensions_func8() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; 
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; 
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
BEGIN
 raise notice '%',(nva);
 nva.extend(); 
 raise notice '%',(nva);
 nva.extend(2); 
 raise notice '%',(nva);
 nva.extend(1,1); 
 raise notice '%',(nva);
 nva.extend(1,3); 
 raise notice '%',(nva);
 nva.extend(3,3); 
 raise notice '%',(nva);
end; $$ language plisql; 
select test_varray_multiple_dimensions_func8();


create function test_varray_multiple_dimensions_func9() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; 
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; 
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
BEGIN
 raise notice '%',(nva);
 nva(1).extend(10); 
 raise notice '%',(nva);
end; $$ language plisql; 
select test_varray_multiple_dimensions_func9();

create function test_varray_multiple_dimensions_func10() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; 
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(11) OF t1; 
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
BEGIN
 raise notice '%',(nva);
 nva.extend(8); 
 raise notice '%',(nva);
end; $$ language plisql; 
select test_varray_multiple_dimensions_func10();

create function test_varray_multiple_dimensions_func11() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; 
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; 
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
 isexists bool;
BEGIN
 FOR i IN 1..4 LOOP
 isexists = nva(1).exists(i);
 IF isexists THEN
 raise notice 'nva(1)(%) = %',i,nva(1)(i);
 ELSE
 raise notice 'nva(1)(%) does not exist',i;
 END IF;
 END LOOP;
end; $$ language plisql; 
select test_varray_multiple_dimensions_func11();

create function test_varray_multiple_dimensions_func12() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; 
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; 
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
 isexists bool;
BEGIN
 FOR i IN 1..5 LOOP
 isexists = nva.exists(i);
 IF isexists THEN
 raise notice 'nva(%) = %',i,nva(i);
 ELSE
 raise notice 'nva(%) does not exist',i;
 END IF;
 END LOOP;
end; $$ language plisql; 
select test_varray_multiple_dimensions_func12();

create function test_varray_multiple_dimensions_func13() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; 
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; 
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
 isexists bool;
BEGIN
 raise notice 'nva(1).first = %',nva(1).first;
 raise notice 'nva(1).last = %',nva(1).last();
 raise notice 'nva.first = %',nva.first;
 raise notice 'nva.last = %',nva.last();
end; $$ language plisql; 
select test_varray_multiple_dimensions_func13();

create function test_varray_multiple_dimensions_func14() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; 
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; 
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
BEGIN
 raise notice 'nva = %',nva;
 raise notice 'nva(1).last = %',nva(1).last();
 raise notice 'nva(1).count = %',nva(1).count();
 va.trim(3);
 raise notice 'nva = %',nva;
 raise notice 'nva.last = %',nva.last();
 raise notice 'nva.count = %',nva.count();
end; $$ language plisql; 
select test_varray_multiple_dimensions_func14();

create function test_varray_multiple_dimensions_func15() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(23) OF INTEGER; 
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; 
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
BEGIN
 raise notice 'nva(1).COUNT = %',nva(1).COUNT();
 raise notice 'nva(1).LIMIT = %',nva(1).limit();
 raise notice 'nva.COUNT = %',nva.COUNT();
 raise notice 'nva.LIMIT = %',nva.limit();
end; $$ language plisql; 
select test_varray_multiple_dimensions_func15();

create function test_varray_multiple_dimensions_func16() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; 
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; 
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
BEGIN
 raise notice 'nva(1).prior(3) = %',nva(1).prior (3);
 raise notice 'nva(1).next(3) = %',nva(1).next (3);
 raise notice 'nva(1).prior(3400) = %',nva(1).prior (3400);
 raise notice 'nva(1).next(3400) = %',nva(1).next (3400);
 raise notice 'nva.prior(3) = %',nva.prior (3);
 raise notice 'nva.next(3) = %',nva.next (3);
 raise notice 'nva.prior(3400) = %',nva.prior (3400);
 raise notice 'nva.next(3400) = %',nva.next (3400);
end; $$ language plisql; 
select test_varray_multiple_dimensions_func16();
--
--Multi-dimensional collection type exception scenario test
--
create function test_varray_multiple_dimensions_err_test1() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; -- varray of integer
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; -- varray of varray of integer
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
 TYPE nt3 IS VARRAY(33) OF nt1;
 nva3 nt3 := nt3(nva, nva);
 i INTEGER;
BEGIN
 i := nva(2)(3);
 raise notice 'nva = %',nva;
 nva(2)(3) = 3;
 raise notice 'i = %',i;
 raise notice 'nva(2)(3) = %',nva(2)(3);
 raise notice 'nva = %',nva;
 raise notice 'nva3 = %',nva3;
 nva3(1)(1)(1) = 999;
 nva3(2)(2)(2) = 888;
 raise notice 'nva3 = %',nva3;
 raise notice 'nva3(1)(1)(1) = %',nva3(1)(1)(1);
end; $$ language plisql; 
select test_varray_multiple_dimensions_err_test1();

create function test_varray_multiple_dimensions_err_test2() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER;
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; 
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
 TYPE nt2 IS VARRAY(33) OF t1;
 nva2 nt2 := nt2(t1, t1);
BEGIN
 raise notice 'nva = %',nva;
 raise notice 'nva2 = %',nva2;
 nt2 = nt1;
 raise notice 'nva = %',nva;
 raise notice 'nva2 = %',nva2;
end; $$ language plisql; 
select test_varray_multiple_dimensions_err_test2();

create function test_varray_multiple_dimensions_err_test3() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER;
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; 
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
 TYPE nt3 IS VARRAY(33) OF nt1;
 nva3 nt3 := nt3(nva, nva);
BEGIN
 raise notice 'nva = %',nva;
 raise notice 'nva = %',nva;
 raise notice 'nva3 = %',nva3;
 va = nva3(1)(1);
 nva = nva3(1)(1);
 raise notice 'va = %',va;
 raise notice 'nva = %',nva;
 raise notice 'nva3 = %',nva3;
end; $$ language plisql; 
select test_varray_multiple_dimensions_err_test3();

create function test_varray_multiple_dimensions_err_test4() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER;
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; 
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
 TYPE nt3 IS VARRAY(33) OF nt1;
 nva3 nt3 := nt3(nva, nva);
BEGIN
 raise notice 'nva = %',nva;
 raise notice 'nva = %',nva;
 raise notice 'nva3 = %',nva3;
 nva(1) = nva3(1);
 raise notice 'va = %',va;
 raise notice 'nva = %',nva;
 raise notice 'nva3 = %',nva3;
end; $$ language plisql; 
select test_varray_multiple_dimensions_err_test4();

create function test_varray_multiple_dimensions_err_test5() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER;
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; 
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
 TYPE nt3 IS VARRAY(33) OF nt1;
 nva3 nt3 := nt3(nva, nva);
BEGIN
 raise notice 'nva = %',nva;
 raise notice 'nva = %',nva;
 raise notice 'nva3 = %',nva3;
 nva(1) = nva3;
 raise notice 'va = %',va;
 raise notice 'nva = %',nva;
 raise notice 'nva3 = %',nva3;
end; $$ language plisql; 
select test_varray_multiple_dimensions_err_test5();

create function test_varray_multiple_dimensions_err_test6() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER;
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; 
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
 TYPE nt3 IS VARRAY(33) OF nt1;
 nva3 nt3 := nt3(nva, nva);
BEGIN
 raise notice 'nva = %',nva;
 raise notice 'nva = %',nva;
 raise notice 'nva3 = %',nva3;
 va(1) = nva3(1)(1)(1);
 --nva(1) = nva3;
 raise notice 'va = %',va;
 raise notice 'nva = %',nva;
 raise notice 'nva3 = %',nva3;
end; $$ language plisql; 
select test_varray_multiple_dimensions_err_test6();

create function test_varray_multiple_dimensions_err_test7() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER;
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; 
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
 TYPE nt3 IS VARRAY(33) OF nt1;
 nva3 nt3 := nt3(nva, nva);
BEGIN
 raise notice 'nva = %',nva;
 raise notice 'nva = %',nva;
 raise notice 'nva3 = %',nva3;
 va(1) = nva3(1)(1);
 --nva(1) = nva3;
 raise notice 'va = %',va;
 raise notice 'nva = %',nva;
 raise notice 'nva3 = %',nva3;
end; $$ language plisql; 
select test_varray_multiple_dimensions_err_test7();

create function test_varray_multiple_dimensions_err_test8() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER;
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; 
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
 TYPE nt3 IS VARRAY(33) OF nt1;
 nva3 nt3 := nt3(nva, nva);
BEGIN
 raise notice 'nva = %',nva;
 raise notice 'nva = %',nva;
 raise notice 'nva3 = %',nva3;
 va = nva3(1)(1)(1);
 --nva(1) = nva3;
 raise notice 'va = %',va;
 raise notice 'nva = %',nva;
 raise notice 'nva3 = %',nva3;
end; $$ language plisql; 
select test_varray_multiple_dimensions_err_test8();

create or replace function test_varray_func1() returns varray as $$
DECLARE
 TYPE va_type is varray(77) of integer;
 var va_type:= va_type(1,2,3);
BEGIN
 raise notice 'test_varray_func1:var=%', var;
 var.delete;
 return var;
end; $$ language plisql;

create or replace function test_varray_func2() returns VOID as $$
DECLARE
 TYPE va_type is varray(99) of integer;
 var va_type:= va_type(11,22,33);
BEGIN
 raise notice 'test_varray_func1 return %', test_varray_func1();
 raise notice 'test_varray_func2:var=%', var;
 var.delete;
 raise notice 'test_varray_func2:var=%', var;
end; $$ language plisql;
select test_varray_func2();

create or replace function test_varray_func1() returns varray as $$
DECLARE
 TYPE va_type as varray(77) of integer;
 var va_type:= va_type(1,2,3);
BEGIN
 raise notice 'test_varray_func1:var=%', var;
 var.trim();
 return var;
end; $$ language plisql;

create or replace function test_varray_func2() returns VOID as $$
DECLARE
 TYPE va_type is varray(99) of integer;
 var va_type:= va_type(11,22,33);
BEGIN
 raise notice 'test_varray_func1 return %', test_varray_func1();
 raise notice 'test_varray_func2:var=%', var;
 var.trim();
 raise notice 'test_varray_func2:var=%', var;
end; $$ language plisql;
select test_varray_func2();

create or replace function test_varray_func1() returns varray as $$
DECLARE
 TYPE va_type is varray(77) of integer;
 var va_type:= va_type(1,2,3);
BEGIN
 raise notice 'test_varray_func1:var=%', var;
 var.extend;
 var(4) = 4;
 return var;
end; $$ language plisql;

create or replace function test_varray_func2() returns VOID as $$
DECLARE
 TYPE va_type is varray(99) of integer;
 var va_type:= va_type(11,22,33);
BEGIN
 raise notice 'test_varray_func1 return %', test_varray_func1();
 raise notice 'test_varray_func2:var=%', var;
 var.extend();
 raise notice 'test_varray_func2:var=%', var;
end; $$ language plisql;
select test_varray_func2();

create or replace function test_varray_func1() returns varray as $$
DECLARE
 TYPE va_type is varray(77) of integer;
 var va_type:= va_type(1,2,3);
 isexists bool;
BEGIN
 raise notice 'test_varray_func1:var=%', var;
 var.extend(2);
 FOR i IN 1..5 LOOP
  isexists = var.exists(i);
  IF isexists THEN
   raise notice 'var(%) = %',i,var(i);
  ELSE
   raise notice 'var(%) does not exist',i;
  END IF;
 END LOOP;
 return var;
end; $$ language plisql;

create or replace function test_varray_func2() returns VOID as $$
DECLARE
 TYPE va_type is varray(99) of integer;
 var va_type:= va_type(11,22,33);
 isexists bool;
BEGIN
 raise notice 'test_varray_func1 return %', test_varray_func1();
 raise notice 'test_varray_func2:var=%', var;
 var.extend(2);
 var(4) = 44;
 FOR i IN 1..5 LOOP
 isexists = var.exists(i);
  IF isexists THEN
   raise notice 'var(%) = %',i,var(i);
  ELSE
   raise notice 'var(%) does not exist',i;
  END IF;
 END LOOP;
 raise notice 'test_varray_func2:var=%', var;
end; $$ language plisql;

select test_varray_func2();

create or replace function test_varray_func1() returns varray as $$
DECLARE
 TYPE va_type is varray(77) of integer;
 var va_type:= va_type(1,2,3);
BEGIN
 raise notice 'test_varray_func1:var=%', var;
 raise notice 'var.first = %',var.first();
 raise notice 'var.last = %',var.last();
 var.extend();
 var(3) = '333';
 var(4) = '444';
 var(7) = '777';
 raise notice 'var.first = %',var.first();
 raise notice 'var.last = %',var.last();
 return var;
end; $$ language plisql;

create or replace function test_varray_func2() returns VOID as $$
DECLARE
 TYPE va_type is varray(99) of integer;
 var va_type:= va_type(11,22,33);
BEGIN
 raise notice 'test_varray_func1 return %', test_varray_func1();
 raise notice 'test_varray_func2:var=%', var;
 raise notice 'var.first = %',var.first();
 raise notice 'var.last = %',var.last();
 var.extend();
 var(3) = '33333';
 var(4) = '444444';
 var(7) = '7777777';
 raise notice 'var.first = %',var.first();
 raise notice 'var.last = %',var.last();
 raise notice 'test_varray_func2:var=%', var;
end; $$ language plisql;
select test_varray_func2();

create or replace function test_varray_func1() returns varray as $$
DECLARE
 TYPE va_type is varray(77) of integer;
 var va_type:= va_type(1,2,3);
BEGIN
 raise notice 'test_varray_func1:var=%', var;
 raise notice 'var.first = %',var.first();
 raise notice 'var.last = %',var.last();
 var.extend(6);
 var(3) = '333';
 var(4) = '444';
 var(7) = '777';
 raise notice 'var.first = %',var.first();
 raise notice 'var.last = %',var.last();
 return var;
end; $$ language plisql;

create or replace function test_varray_func2() returns VOID as $$
DECLARE
 TYPE va_type is varray(99) of integer;
 var va_type:= va_type(11,22,33);
BEGIN
 raise notice 'test_varray_func1 return %', test_varray_func1();
 raise notice 'test_varray_func2:var=%', var;
 raise notice 'var.first = %',var.first();
 raise notice 'var.last = %',var.last();
 var.extend(6);
 var(3) = '333333';
 var(4) = '444444';
 var(7) = '777777';
 raise notice 'var.first = %',var.first();
 raise notice 'var.last = %',var.last();
 raise notice 'test_varray_func2:var=%', var;
end; $$ language plisql;
select test_varray_func2();

create or replace function test_varray_func1() returns varray as $$
DECLARE
 TYPE va_type is varray(77) of integer;
 var va_type:= va_type(1,2,3);
BEGIN
 raise notice 'test_varray_func1:var=%', var;
 var.EXTEND(4);
 raise notice 'var.last = %',var.last();
 raise notice 'var.count = %',var.count();
 var.trim(3);
 raise notice 'var = %',var;
 raise notice 'var.last = %',var.last();
 raise notice 'var.count = %',var.count();
 return var;
end; $$ language plisql;

create or replace function test_varray_func2() returns VOID as $$
DECLARE
 TYPE va_type is varray(99) of integer;
 var va_type:= va_type(11,22,33);
BEGIN
 raise notice 'test_varray_func1 return %', test_varray_func1();
 raise notice 'test_varray_func2:var=%', var;
 var.EXTEND(5);
 raise notice 'var.last = %',var.last();
 raise notice 'var.count = %',var.count();
 var.trim(3);
 raise notice 'var = %',var;
 raise notice 'var.last = %',var.last();
 raise notice 'var.count = %',var.count();
 raise notice 'test_varray_func2:var=%', var;
end; $$ language plisql;
select test_varray_func2();

create or replace function test_varray_func1() returns varray as $$
DECLARE
 TYPE va_type is varray(77) of integer;
 var va_type:= va_type(1,2,3);
BEGIN
 raise notice 'test_varray_func1:var=%', var;
 raise notice 'var.COUNT = %',var.COUNT();
 raise notice 'var.LIMIT = %',var.limit;
 return var;
end; $$ language plisql;

create or replace function test_varray_func2() returns VOID as $$
DECLARE
 TYPE va_type is varray(99) of integer;
 var va_type:= va_type(11,22,33);
BEGIN
 raise notice 'test_varray_func1 return %', test_varray_func1();
 raise notice 'test_varray_func2:var=%', var;
 raise notice 'var.COUNT = %',var.COUNT();
 raise notice 'var.LIMIT = %',var.limit;
 raise notice 'test_varray_func2:var=%', var;
end; $$ language plisql;
select test_varray_func2();

create or replace function test_varray_func1() returns varray as $$
DECLARE
 TYPE va_type is varray(77) of integer;
 var va_type:= va_type(1,2,3);
BEGIN
 raise notice 'test_varray_func1:var=%', var;
 raise notice 'var.prior(3) = %',var.prior (3);
 raise notice 'var.next(3) = %',var.next (3);
 raise notice 'var.prior(3400) = %',var.prior (3400);
 raise notice 'var.next(3400) = %',var.next (3400);
 return var;
end; $$ language plisql;

create or replace function test_varray_func2() returns VOID as $$
DECLARE
 TYPE va_type is varray(99) of integer;
 var va_type:= va_type(11,22,33);
BEGIN
 raise notice 'test_varray_func1 return %', test_varray_func1();
 raise notice 'test_varray_func2:var=%', var;
 raise notice 'var.prior(2) = %',var.prior (2);
 raise notice 'var.next(2) = %',var.next (2);
 raise notice 'var.prior(3400) = %',var.prior (3400);
 raise notice 'var.next(3400) = %',var.next (3400);
 raise notice 'test_varray_func2:var=%', var;
end; $$ language plisql;
select test_varray_func2();
--
--Determine whether the test is empty
--
create or replace function is_null_test1() returns VOID as $$
DECLARE
 TYPE nt_type IS VARRAY(11) OF text;
 team nt_type; 
 TYPE nt1_type IS VARRAY(22) OF text; 
 names nt1_type := nt1_type('zhangsan', 'lisi'); 
BEGIN
 IF team IS NULL THEN
  raise notice 'team IS NULL';
 ELSE
  raise notice 'team IS NOT NULL';
 END IF;
 IF names IS NOT NULL THEN
  raise notice 'names IS NOT NULL';
 ELSE
  raise notice 'names IS NULL';
 END IF; 
end; $$ language plisql;
select is_null_test1();

create or replace function is_null_test2() returns VOID as $$
DECLARE
 TYPE nt_type IS VARRAY(11) OF text;
 team nt_type; 
 TYPE nt1_type IS VARRAY(22) OF nt_type; 
 names nt1_type := nt1_type(nt_type('zhangsan'),team); 
BEGIN
 IF team IS NULL THEN
  raise notice 'team IS NULL';
 ELSE
  raise notice 'team IS NOT NULL';
 END IF;
 
 IF names IS NOT NULL THEN
  raise notice 'names IS NOT NULL';
 ELSE
  raise notice 'names IS NULL';
 END IF; 
 
 IF names(1) IS NOT NULL THEN
  raise notice 'names(1) IS NOT NULL';
 ELSE
  raise notice 'names(1) IS NULL';
 END IF; 
 IF names(2) IS NOT NULL THEN
  raise notice 'names(2) IS NOT NULL';
 ELSE
  raise notice 'names(2) IS NULL';
 END IF; 
end; $$ language plisql;
select is_null_test2();
--
--nested call function
--
create or replace function test_varray_multiple_dimensions10() return VOID as
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER;
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1;
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
 TYPE nt2 IS VARRAY(22) OF nt1;
 vat2 nt2 := nt2(nva, nt1(va, t1(1, 2, 3)));
BEGIN
 va.Extend(1,1);
 nva(4) := t1(45,43,67,43345);
 nva(4).EXTEND;
 nva(4)(4) := 89;
 raise notice 'va = %',va;
 raise notice 'nva = %',nva;
 raise notice 'vat2 = %',vat2;
 vat2(2)(1).extend;
 vat2(2)(1)(4) := 6;
 raise notice 'vat2 = %',vat2;
end;
/
select test_varray_multiple_dimensions10();

create or replace function test_varray_func3() returns VOID as $$
DECLARE
 TYPE t1 IS VARRAY(11) OF INTEGER; -- varray of integer
 va t1 := t1(2,3,5);
 TYPE nt1 IS VARRAY(22) OF t1; -- varray of varray of integer
 nva nt1 := nt1(va, t1(55,6,73), t1(2,4), va);
 flg bool;
BEGIN
 va.extend(2);
 raise notice 'isexists = %',va.exists(6);
 raise notice 'isexists = %',nva(2).exists(2);
 raise notice 'isexists = %',nva(2).exists(5);
 raise notice 'isexists = %',nva(2)(3).exists(2);
end; $$ language plisql;
select test_varray_func3();
--
--type is UDT
--
create type type1 as object (tname varchar(20), id int,
	member function func_1 return int);
create type body type1 as
	member function func_1 return int as
	begin
		return 11;
	end;
end;
/

create or replace function test_varray_multiple_dimensions11() return VOID as
DECLARE
 TYPE t1 IS VARRAY(11) OF type1;
 va t1 := t1(type1('aa', 1), type1('bb', type1('cc', 2).func_1));
BEGIN
 raise notice 'va = %',va;
 va.Extend(1,1);
 raise notice 'va = %',va;
 va(3) := type1('dd', 3);
 raise notice 'va = %',va;
end;
/
select test_varray_multiple_dimensions11();