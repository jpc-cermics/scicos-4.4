// exec ../../../nsp2-jpc/plist_code/macrovar.sci
// function f(a,b,c); x(56);sin(56);endfunction;

function H=macrovar(x)
  // Feb 2011: unfinished since we should 
  // consider cases like y=x(5);x=67; 
  // where x should be in H.called and H.lhs 
    
  if type(x,'short')=='s' then 
    execstr('g='+x);
  end
  if type(x,'short') <> 'pl' then 
    error('Error: expecting a function");
    return;
  end
  H=hash(name=x.get_fname[]);
  [a,b]=x.get_args[];
  // arguments of function 
  H.in=a;
  // returned values of function 
  H.out=b;
  ast=pl2l(x);
  // all symbols found 
  H.all= ast_names(ast)
  // lhs of equality arguments 
  H.lhs= ast_mlhs_names(ast);
  // x(...) or x. or x{...}
  // removing in out lhs and fname 
  H.called = H.all;
  H.called.delete[H.in];
  H.called.delete[H.out];
  H.called.delete[H.lhs];// .__keys];
  H.called.delete[H.name];
  // remove from called the functions or 
  // macros by searching callable symbols 
  // in the called keys (name and name_m or name_b).
  // We keep in H.funs all the callable functions.
  vals=H.called.__keys;
  H.funs = hash(10);
  for v=vals';
    if or(exists(v+['','_m','_s','_i'],'callable')) then 
      H.called.delete[v];
      H.funs(v)=%t;
    end
  end
endfunction

function H=ast_names(ast, H, mlhs)
// get all the astnode of id NAME in 
// the ast i.e all the symbols used 
// in the function 
  if nargin <= 1 then H=hash(10);end 
  if nargin <= 2 then mlhs=%t;end 
  str=type(ast,'short');
  if type(ast,'short') == 'l' then 
    if ast(1).is["MLHS"] && mlhs == %f then return; end
    for i=1:length(ast)
      H=ast_names(ast(i),H,mlhs);
    end
  else
    if ast.is["NAME"] then 
      H(ast.get_str[])=%t;
    end
  end
endfunction

function H=ast_mlhs_names(ast, H)
// get all the symbol names found 
// in a lhs part of = 
// this values could also be found 
// directly in the pl or ast object 
  if nargin <= 1 then H=hash(10);end 
  if type(ast,'short') == 'l' then 
    if ast(1).is["MLHS"] && length(ast) >=2 then 
      for i=2:length(ast) 
	if type(ast(i),'short')== 'l' then 
	  // a listeval or calleval 
	  name = ast(i)(2).get_str[];
	  H(name)=%t;
	elseif ast(i).is["NAME"] then 
	  H(ast(i).get_str[])=%t;
	end
      end
    else
      for i=1:length(ast) 
	H=ast_mlhs_names(ast(i),H);
      end
    end
  end
endfunction


