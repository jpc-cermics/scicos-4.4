function scmenu_set_code_gen_properties()
  Cmenu=''
  inside_sblock=%f
  if size(Select,1)==1 then
    if Select(1,2)==curwin then
      if scs_m.objs(Select(1,1)).type=='Block' then
        if scs_m.objs(Select(1,1)).model.sim(1)=='super' | ...
           scs_m.objs(Select(1,1)).gui=='DSUPER' then
          inside_sblock=%t
        end
      end
    end
  end
  if inside_sblock then
    o=scs_m.objs(Select(1,1)).model.rpar
    [changed,codegen]=do_set_codegen(o.codegen)
    if changed then
      scs_m.objs(Select(1,1)).model.rpar.codegen=codegen
      edited=%t
    end
  else
    [changed,codegen]=do_set_codegen(scs_m.codegen)
    if changed then
      scs_m.codegen=codegen
      edited=%t
    end
  end
endfunction

function [edited,codegeneration]=do_set_codegen(codegen)
// setup default parameters for code generation 
//
  ok=%f
  edited=%f
  if ~codegen.iskey['pcodegen_target'] then 
    codegen.pcodegen_target = [];
  end
  codegeneration=codegen
  
  mess='Set default properties for Code Generation'
  
  silent_in       = sci2exp(codegeneration.silent)
  cblock_in       = sci2exp(codegeneration.cblock)
  rdnom_in        = sci2exp(codegeneration.rdnom)
  rpat_in         = sci2exp(codegeneration.rpat)
  libs_in         = sci2exp(codegeneration.libs)
  opt_in          = sci2exp(codegeneration.opt)
  enable_debug_in = sci2exp(codegeneration.enable_debug)
  pcodegen_target_in= sci2exp(codegeneration.pcodegen_target);
  
  %scs_help='Setup_CodeGen'
  
  while %t do
    [ok,silent,cblock,rdnom,rpat,libs,opt,enable_debug,pcodegen_target]=...
	getvalue(mess,...
		 ["Silent mode (0:no, 1:yes)";
		  "Use CBLOCK4 (0:no, 1:yes)";
		  "Target name ([] means default)";
		  "Target path ([] means default)";
		  "External libraries ([] means default)";
		  "Standalone generation (0:no, 1:yes)";
		  "Enable debug (0:no, 1:yes)";
		  "P-code target (""C"", ""P"" or [])"],...
		 list("vec",[1],...
		      "vec",[1],...
		      "str",[1],...
		      "str",[1],...
		      "str",[-1],...
		      "vec",[1],...
		      "vec",[1],...
		      "str",[1]),...
		 [silent_in,...
		  cblock_in,...
		  rdnom_in,...
		  rpat_in,...
		  libs_in,...
		  opt_in,...
		  enable_debug_in,...
		  pcodegen_target_in]);

    if ~ok then break, end

    err_mess=[]
    if isempty(find(silent==[0 1])) then
      err_mess=[err_mess;'Silent mode must be 0 or 1.']
    else
      silent_in=sci2exp(silent)
    end
    if isempty(find(cblock==[0 1])) then
      err_mess=[err_mess;'Use CBLOCK4 must be 0 or 1.']
    else
      cblock_in=sci2exp(cblock)
    end
    [H,ierr]=evstr(rdnom)
    if ierr==%t then
      err_mess=[err_mess;'Target Name must be a string.']
    else
      rdnom_in=sci2exp(evstr(rdnom))
    end
    [H,ierr]=evstr(rpat)
    if ierr==%t then
      err_mess=[err_mess;'Target path must be a string.']
    else
      rpat_in=sci2exp(evstr(rpat))
    end
    [H,ierr]=evstr(libs)
    if ierr==%t then
      err_mess=[err_mess;'External libraries must be a vector of strings.']
    else
      libs_in=sci2exp(evstr(libs))
    end
    if isempty(find(opt==[0 1])) then
      err_mess=[err_mess;'Standalone generation must be 0 or 1.']
    else
      opt_in=sci2exp(opt)
    end
    if isempty(find(enable_debug==[0 1])) then
      err_mess=[err_mess;'Enable debug must be 0 or 1.']
    else
      enable_debug_in=sci2exp(enable_debug)
    end
    [H,ierr]=evstr(pcodegen_target)
    if ierr==%t then
      err_mess=[err_mess;'Target Name must a string']
    else
      if ~isempty(H) && isempty(find(H==["C" "P" ])) then
	err_mess=[err_mess;'Pcodegen target must be C or P or []']
      else
	pcodegen_target_in=sci2exp(evstr(pcodegen_target))
      end
    end
    if ~isempty(err_mess) then
      message(err_mess)
    else
      codegeneration.silent=silent
      codegeneration.cblock=cblock
      codegeneration.rdnom=evstr(rdnom)
      codegeneration.rpat=evstr(rpat)
      codegeneration.libs=evstr(libs)
      codegeneration.opt=opt
      codegeneration.enable_debug=enable_debug
      codegeneration.pcodegen_target = evstr(pcodegen_target)
      if or(codegen<>codegeneration) then
        edited=%t
      end
      break
    end
  end
endfunction
