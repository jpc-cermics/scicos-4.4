function r=validvar(s)
// Copyright INRIA
// check if the string s is a valid identifier
// rewriten for nsp (jpc Nov 2010) 
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
  if type(name,'short')== 'astnode' && name.get_idname[] == 'NAME' then r=%t;return;end 
  return;
endfunction
