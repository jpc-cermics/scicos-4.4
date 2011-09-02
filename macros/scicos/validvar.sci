function r=validvar(s,id='NAME')
// Copyright INRIA
// checks if the string s is a valid object of 
// type id. id can be choosen among 
// 'NAME', 'NUMBER','INUMBER32', INUMBER64, UNUMBER32,UNUMBER64
// rewriten for nsp (jpc Nov 2010) 
// 
  s=stripblanks(s)
  r=%f
  if size(s,'*')<>1 then return,end
  if s=='' then return, end
  //create a function with s as single statement
  ok= execstr('function foo()'+ s + ';endfunction',errcatch=%t);
  if ~ok then  lasterror(); return;end 
  ast = pl2l(foo);
  ok= execstr('name = ast(3)(2)(2)',errcatch=%t);
  if ~ok then  lasterror(); return;end 
  if type(name,'short')== 'astnode' && name.get_idname[] == id  then 
    r=%t;
  end 
endfunction

