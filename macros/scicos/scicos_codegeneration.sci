function [ok,scs_m,%cpr] = scicos_codegeneration(scs_m,Params)
// Function for running scicos code generation of a diagram
// in batch mode.
// [ok,scs_m,%cpr] = scicos_codegeneration(scs_m,Params)
//
// scs_m: scicos diagram (obtained by "load file.cos")
//
// Params: a list of properties for scicos code generation
//
// Params(1) : silent_mode : if 1 then no message are displayed
//             during the code generation and default values
//             are taken for the target directory and names.
// Params(2) : cblock : if 1 the generated block is replaced by
//             a CBLOCK4 that enclosed the generic parameters
//             and the generated computational function.
// Params(3) : rdnom : sets the default name for the generated
//             code.
// Params(4) : rpat : sets the default target path for the
//             generated code.
// Params(5) : libs : sets the additional external libraries
//             needed by code generation.
// Params(6) : opt : if 0, then the standalone code will not
//             be generated -default 1-.
// Params(7) : enable_debug : says if additionnal code must be
//             generated to debug generated code.
// Params(8) : scopes : list of additionnal scopes used in scs_m;
//             this params must be a matrix of string of size -1,2
// Params(9) : remove : list of blocks that must be removed for the
//             generated code; this params must be a matrix of string
//             of size -1,2
//
  //@@ default value
  %cpr=list()

  //** check type/number of rhs parameters
  mess=[]
  if nargin>=1 then
    if ~isequal(type(scs_m,'string'),'Hash') then
      mess='First Rhs must be a scicos diagram.'
    end
    if nargin>=2 then
      if ~isequal(type(Params,'string'),'List') then
        mess=[mess;'Second Rhs must be a list.']
      end
    else
      Params=list()
    end
  else
    mess='Incorrect number of arguments in function call...'
  end

  if ~isempty(mess) then
    error('scicos_codegeneration : '+strcat(mess,', '))
  end

  %scicos_context=hash(1);

  //** define Scicos data tables
  scicos_library_initialize()

  //** initialize a "scicos_debug_gr" variable
  %scicos_debug_gr = %f;

  //** load macros libraries and palettes of scicos
  //CodeGeneration_=CodeGeneration_

  //@@ check version of scicos diagram
  [ierr,scicos_ver,scs_m]=update_version(scs_m);
  if ~ierr then
    error("scicos_codegeneration : Can''t convert old diagram (problem in version)");
  end

  //@@ define some variable used by scicos
  %pt=[];
  %tcur=0;
  %cpr=list();
  alreadyran=%f;
  needstart=%t;
  needcompile=4;
  %state0=list();
  tolerances=scs_m.props.tol;
  solver=tolerances(6);
  %scicos_solver=solver;
  curwin=0;
  %zoom=1.8;

  //check/set values of Params
  [mess,scs_m]=checkParams(scs_m,Params)
  if ~isempty(mess) then error('scicos_codegeneration : '+strcat(mess,', ')), end

  //## tk widgets
  /////////////////////if with_tk() & ~silent_mode then//////////////
//   if with_tk() then
//     prot = funcprot();
//     funcprot(0);
// 
//     if with_ttk() then
//       tk_getvalue         = ttk_getvalue
//       tk_message          = ttk_message
//       tk_messageW         = ttk_message
//       scstxtedit_tk       = ttk_txtedit
//       x_choices           = ttk_choices
//       tk_message_modeless = ttk_message_modeless
//     end
// 
//     x_message_modeless = tk_message_modeless
//     scstxtedit         = scstxtedit_tk
// 
//     if MSDOS then  
//       getvalue  = tk_getvalue
//       choose    = tk_scicos_choose
//       getfile   = tk_getfile_scicos
//       savefile  = tk_savefile_scicos
//       x_message = tk_messageW
//     else
//       getfile   = tk_getfile_scicos
//       savefile  = tk_savefile_scicos
//       getvalue  = tk_getvalue
//       x_message = tk_message
//       deff('x=choose(varargin)', 'x=x_choose(varargin(1:$))')
//     end
//     funcprot(prot);
//   end

  //## overload some functions in silent mode
  if scs_m.codegen.silent==1 then
    function message(txt)
      printf("%s\n",txt)
    endfunction
    function x_message(txt)
      printf("%s\n",txt)
    endfunction
  end
  
  //** set variables of context
  [%scicos_context,ierr]=script2var(scs_m.props.context, ...
				    %scicos_context);
  if isequal(ierr,0) then
    [scs_m,%cpr,needcompile,ok]=do_eval(scs_m,%cpr,%scicos_context);
    if needcompile<>4&size(%cpr)>0 then %state0=%cpr.state,end
    alreadyran=%f;
  else
    error("scicos_codegeneration : Incorrect context definition, "+lasterror());
  end

  //@@ entire diagram generation
  ALL         = %t;

  //@@ input function of codegeneration
  ierr=execstr('[ok, XX, gui_path, flgcdgen, szclkINTemp, freof, c_atomic_code, cpr] ='+...
                          'do_compile_superblock42(scs_m, -1);',errcatch=%t);

  if ~ierr then error(lasterror()), end

  if ~isequal(ok,%t) then ok=%f, end

  //@@ update the diagram with the new block generated
  if ok then
    props              = scs_m.props;
    nscs_m             = get_new_scs_m()
    nscs_m.props       = props
    XX.graphics.pein   = 2
    XX.graphics.peout  = 2
    YY                 = scicos_link(xx   = [20;20;70;70;20;20],...
                                     yy   = [-5.70;-25;-25;60;60;45.7],...
                                     ct   = [5;-1],...
                                     from = [1,1,0],...
                                     to   = [1,1,1])
    nscs_m.objs(1)     = XX
    nscs_m.objs(2)     = YY

    if scs_m.codegen.cblock==1 then
      scs_m = nscs_m
      [%cpr,ok]=do_compile(nscs_m)
    else
      scs_m_save=scs_m
      scs_m=nscs_m 
      [%cpr,ok]=do_compile(scs_m)
      scs_m=scs_m_save
      %cpr.cor=update_cor_cdgen(cpr.cor)
      corinv=list()
      for i =1:lstsize(cpr.corinv)
        if cpr.corinv(i)<>0 then
          corinv($+1)=cpr.corinv(i)
        end
      end
      %cpr.corinv(1)=corinv
      %cpr.sim.critev=0
    end
  end
endfunction

function [mess,scs_m]=checkParams(scs_m,Params)

  mess=[]
  if isequal(Params,list()) then return, end

  //
  silent=scs_m.codegen.silent
  cblock=scs_m.codegen.cblock
  rdnom=scs_m.codegen.rdnom
  rpat=scs_m.codegen.rpat
  libs=scs_m.codegen.libs
  opt=scs_m.codegen.opt
  enable_debug=scs_m.codegen.enable_debug
  scopes=scs_m.codegen.scopes
  remove=scs_m.codegen.remove
  replace=scs_m.codegen.replace

  //@@ check silent
  if size(Params)>=1 then
    if size(Params(1),'*') <> 1 then
      mess=['Silent mode must be a scalar.']
      return
    end
    if isempty(find(Params(1)==[0 1])) then
      mess=['Silent mode must be 0 or 1.']
      return
    end
    silent=Params(1)
  end

  //@@ check cblock
  if size(Params)>=2 then
    if size(Params(2),'*') <> 1 then
      mess=['cblock must be a scalar.']
      return
    end
    if isempty(find(Params(2)==[0 1])) then
      mess=['cblock must be 0 or 1.']
      return
    end
    cblock=Params(2)
  end

  //@@ check rdnom
  if size(Params)>=3 then
    if ~isempty(Params(3)) then
      if size(Params(3),'*') <> 1 then
        mess=['rdnom must have a size 1.']
        return
      end
      if ~isequal(type(Params(3),'string'),'SMat') then
        mess=['rdnom must be a string.']
        return
      end
    end
    rdnom=Params(3)
  end

  //@@ check rpat
  if size(Params)>=4 then
    if ~isempty(Params(4)) then
      if size(Params(4),'*') <> 1 then
        mess=['rpat must have a size 1.']
        return
      end
      if ~isequal(type(Params(4),'string'),'SMat') then
        mess=['rpat must be a string.']
        return
      end
    end
    rpat=Params(4)
  end

  //@@ check libs
  if size(Params)>=5 then
    if ~isempty(Params(5)) then
      if ~isequal(type(Params(5),'string'),'SMat') then
        mess=['libs must be a vector of strings.']
        return
      end
    end
    libs=Params(5)
  end

  //@@ check opt
  if size(Params)>=6 then
    if size(Params(6),'*') <> 1 then
      mess=['opt must be a scalar.']
      return
    end
    if isempty(find(Params(6)==[0 1])) then
      mess=['opt must be 0 or 1.']
      return
    end
    opt=Params(6)
  end

  //@@ check enable_debug
  if size(Params)>=7 then
    if size(Params(7),'*') <> 1 then
      mess=['enable_debug must be a scalar.']
      return
    end
    if isempty(find(Params(7)==[0 1])) then
      mess=['enable_debug must be 0 or 1.']
      return
    end
    enable_debug=Params(7)
  end

  //@@ check scopes
  if size(Params)>=8 then
    if ~isempty(Params(8)) then
      if size(Params(8),2) <> 2 then
        mess=['List of Scopes must be a matrix of strings of size -1,2.']
        return
      end
      if ~isequal(type(Params(8),'string'),'SMat') then
        mess=['List of Scopes must be a matrix of strings of size -1,2.']
        return
      end
    end
    scopes=Params(8)
  end

  //@@ check remove
  if size(Params)>=9 then
    if ~isempty(Params(9)) then
      if size(Params(9),2) <> 2 then
        mess=['List of blocks to remove must be a matrix of strings of size -1,2.']
        return
      end
      if ~isequal(type(Params(9),'string'),'SMat') then
        mess=['List of blocks to remove must be a matrix of strings of size -1,2.']
        return
      end
    end
    remove=Params(9)
  end

  //
  scs_m.codegen.silent=silent
  scs_m.codegen.cblock=cblock
  scs_m.codegen.rdnom=rdnom
  scs_m.codegen.rpat=rpat
  scs_m.codegen.libs=libs
  scs_m.codegen.opt=opt
  scs_m.codegen.enable_debug=enable_debug
  scs_m.codegen.scopes=scopes
  scs_m.codegen.remove=remove
  scs_m.codegen.replace=replace
endfunction
