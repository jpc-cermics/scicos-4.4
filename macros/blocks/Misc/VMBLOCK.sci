function [x,y,typ]=VMBLOCK(job,arg1,arg2)
  // Similar to MBLOCK but variables may have
  // dimensions and are declared RealOutput or RealInput instead of Real
  // to be used in Coselica
  // Note that Explicit Outputs or Inputs must be scalars (since communication
  // between scicos and modlica should be through scalar links
  // XXXXX: Il faut vérifier que les arguments explicites sont scalaires
  x=[];y=[];typ=[];
  select job
    case 'plot' then
      standard_draw(arg1)
    case 'getinputs' then
      [x,y,typ]=standard_inputs(arg1)
    case 'getoutputs' then
      [x,y,typ]=standard_outputs(arg1)
    case 'getorigin' then
      [x,y]=standard_origin(arg1)
    case 'set' then
      x=arg1
      model=arg1.model
      graphics=arg1.graphics
      exprs=graphics.exprs
      // check if this is an interactive MBLOCK('set',o);
      non_interactive = exists('getvalue') && getvalue.get_fname[]== 'setvalue';
      
      while %t do
	// get bloc parameters 
	[ok,cancel,exprs_values,exprs_strings]=VMBLOCK_get_parameters(exprs)
	if cancel then return;end 
	if ~ok && non_interactive then return;end 
	if ~ok then continue;end
	// block <<parameters>> values 
	[ok,cancel,paramv,lab_2]= VMBLOCK_get_parameters_values(exprs_values.param,exprs_values.pprop,
								exprs.param, exprs.paramv);
	if cancel then return;end
	if ~ok && non_interactive then return;end 
	if ~ok then continue;end
	
	exprs_values.paramv = paramv;

	// the modelica code can be in a file or given in exprs
	[dirF,nameF,extF]=splitfilepath(exprs_values.nameF);
	if extF=='mo' && file('exists',exprs_values.nameF) then
	  tt=scicos_mgetl(exprs_values.nameF);
	else
	  tt=exprs.funtxt
	end
	if non_interactive then 
	  [ok,tt]=VMODCOM_NI(exprs_values,tt);
	else 
	  [ok,tt]=VMODCOM(exprs_values,tt);
	end
	if ok &&  file('exists',exprs_values.nameF) then
	  // must save back the results
	  scicos_mputl(tt,exprs_values.nameF)
	end
	// here ok = %f means cancel in edition
	break;
      end
      
      if ~ok then return;end 
      // define new model 
      //model.rpar=paramv;
      //------------------
      exprs_values.funtxt = tt;
      x = VMBLOCK_define(exprs_values,x);
      
    case 'define' then
      //----------- Define
      x= VMBLOCK_define();
    case 'zzcompile' then
      pause VMBLOCK
      x=arg1
  end
endfunction

function blk = VMBLOCK_define(H,old)

  // define a VMBLOCK given data 
  // or define the block when data have changed
  if nargin < 1 then
    H=hash(in=['u1'], intype=['I'], in_r= [2], in_c=[1],
	   out=['y1';'y2'], outtype=['I';'E'], out_r= [2;3], out_c=[1;1],
	   param=['R';'L'], paramv=list(0.1,.0001),
	   pprop=[0;0], nameF='genericv');
  end
  // build a hash table with string expressions from H values
  exprs = hash(10);
  if H.iskey["funtxt"] then
    exprs.funtxt = H.funtxt;
    H.delete['funtxt'];
  else
    funtxt=VMBLOCK_classhead(H.nameF,H.in,H.intype,[H.in_r,H.in_c],H.out,H.outtype,[H.out_r,H.out_c],H.param,H.paramv,H.pprop)
    exprs.funtxt = [funtxt;
		    "  equation";
		    sprintf("//  y[%d].signal= %s(u[%d].signal);",1,'sin',1);
		    sprintf("end %s;", H.nameF)];
  end
  
  for key=(H.__keys)' do
    if type(key,'short') <> 'l' then val =sci2exp(H(key));else val=map(H(key),sci2exp);end
    exprs(key)=val;
  end
  exprs.nameF=H.nameF;
  
  // model.equations;
  model_equations=scicos_modelica();
  model_equations.model=H.nameF;
  model_equations.parameters=list(H.param,H.paramv,H.pprop);
  model_equations.inputs=H.in
  model_equations.outputs=H.out
  // build a model
  model=scicos_model();
  model.blocktype='c';
  model.dep_ut=[%f %t];
  model.rpar=[]
  for i=1:length(H.paramv) do
    xx=H.paramv(i)(:);
    if type(xx,'short')== 'i' then xx=i2m(xx);end 
    if type(xx,'short')== 'b' then xx=b2m(xx);end 
    model.rpar=[model.rpar; xx];
  end
  model.sim=list(H.nameF,30004)
  model.in=H.in_r; // must be column 
  model.in2=H.in_c;// must be column 
  model.out=H.out_r; // must be column 
  model.out2=H.out_c; // must be column
  model.intyp = ones(size(model.in));
  model.outtyp= ones(size(model.out));
  model.equations=model_equations;
  if nargin == 2 then
    graphics = old.graphics;
    graphics.exprs = exprs;
    nin=size(model.in,1);
    nin_old = size(old.graphics.pin,'*');
    pin =[];
    if nin >0 && nin >= nin_old then
      pin(nin,1)=0;pin(1:nin_old,1)=old.graphics.pin;
    end
    if nin <  nin_old then pin=old.graphics.pin(1:nin);end
    graphics.pin = pin;
    nout=size(model.out,1);
    nout_old = size(old.graphics.pout,'*');
    pout=[];
    if nout >0 && nout >= nout_old then
      pout(nout,1)=0;pout(1:nout_old,1)=old.graphics.pout;
    end
    if nout <  nout_old then pout=old.graphics.pout(1:nout);end
    graphics.pout = pout;
    graphics.in_implicit = H.intype(:);
    graphics.out_implicit =H.outtype(:);
    blk = old;
    blk.model = model;
    blk.graphics = graphics;
  else
    // we could here call set_io to fix graphics
    gr_i=["txt=[""Modelica"";"" "+H.nameF+" ""];";
	  "xstringb(orig(1),orig(2),txt,sz(1),sz(2),""fill"")"];
    blk=standard_define([2 2],model,exprs,gr_i,'VMBLOCK');
    // standard define should incorporate that 
    blk.graphics.in_implicit =H.intype
    blk.graphics.out_implicit=H.outtype
  end
endfunction

function [ok,cancel,exprs_values,exprs_strings]= VMBLOCK_get_parameters(exprs)
  // get parameters 
  cancel=%f;
  exprs_values=hash(10);
  exprs_strings=hash(10);
  
  names = ["in";"intype";"in_r";"in_c";"out";"outtype";"out_r";"out_c";"param";"pprop";"nameF"];
  
  lab_1 = h2l(exprs,names);
  
  names_1 = ["Input variables           ";
	     "Input variables types     ";
	     "Input variables row sizes ";
	     "Input variables col sizes ";
	     "Output variables          ";
	     "Output variables types    ";
	     "Output variables row sizes";
	     "Output variables col sizes";
	     "Parameters in Modelica    ";
	     "Parameters properties     ";
	     "Function name             "];
  title="Set Modelica generic block parameters";
  
  types_1 = list("str",-1,"str",-1,"vec",-1, "vec",-1,"str",-1,"str",-1,"vec",-1, "vec",-1,"str",-1, "vec",-1,"str",-1);
  [ok,L, S_out]=getvalue_list(title, names_1, types_1,lab_1);

  // check cancel case
  if ~ok then cancel=%t;ok=%t; return;end 
  // default return value
  ok = %f;
  
  // Hash tables with expressions 
  exprs_strings= s2h([names,S_out]);

  // Hash table with values 
  exprs_values = hash(size(names,'*'));  
  for i=1:size(S_out,'*')-1
    // XXX do we need to consider if isempty(%s) then %s=m2s([]);
    cmd=sprintf("value=%s",S_out(i));
    eok = execstr(cmd,errcatch=%t);
    if ~eok then lasterror(); message("Failed to evaluate "+S_out(i));return;
    else
      if type(value,'short')=='s' then value = stripblanks(value);end 
      exprs_values(names(i))= value;
    end
  end
  exprs_values('nameF')=S_out($);
  //check for valid name variable
  function ok= mblock_validvar(in)
    ok=%f;
    for i=1:size(in,'*')
      valid=%f;
      eok=execstr('valid=validvar(in(i))',errcatch=%t);
      if ~eok then lasterror();end;
      if ~valid then
	message(["Invalid variable name for the input "+string(i)+".";
		 """"+in(i)+"""";
		 "Please choose another variable name."] );
	return;
      end
    end
    ok=%t;
  endfunction
  
  // variable in
  if ~mblock_validvar(exprs_values.in) then return;end 
  // variable out
  if ~mblock_validvar(exprs_values.out) then return;end 
  // variable param
  if ~mblock_validvar(exprs_values.param) then return;end 
  // type checking
  if ~and(exprs_values.outtype == 'I' | exprs_values.outtype == 'E') then
    message("Output type should be ''E'' or ''I''!");
    return;
  end
  if ~and(exprs_values.intype == 'I' | exprs_values.intype == 'E') then
    message("Input type should be ''E'' or ''I''!");
    return;
  end
  //cross size checking
  if or(size(exprs_values.intype)<>size(exprs_values.in)) then
    message("Input variables types and input names should have same sizes");
    return;
  end

  if or(size(exprs_values.in_r)<>size(exprs_values.in)) then
    message("Input row sizes and input names should share the same sizes");
    return;
  end
  
  if or(size(exprs_values.in_c)<>size(exprs_values.in)) then
    message("Input col sizes and input names should share the same sizes");
    return;
  end
  
  if or(size(exprs_values.outtype)<>size(exprs_values.out)) then
    message("Output variables types and output names should have same sizes");
    return;
  end

  if or(size(exprs_values.out_r)<>size(exprs_values.out)) then
    message("Output row sizes and output names should share the same sizes");
    return;
  end
  if or(size(exprs_values.out_c)<>size(exprs_values.out)) then
    message("Output col sizes and output names should share the same sizes");
    return;
  end
  
  //check param properties
  exprs_values.pprop = exprs_values.pprop(:);
  if (size(exprs_values.param,'*')<>size(exprs_values.pprop,'*')) then
    message("param size and param properties should share the same sizes");
    return;
  end
  if max(exprs_values.pprop)>2 | min(exprs_values.pprop)<0 then
    message(["Parameters properties must be:";
	     "0: for a paramaters";
	     "1: for a state with an initial value";
	     "2: for a statie with fixed initial value." ])
    return;
  end
  
  //check name of modelica file
  if exprs_values.nameF=='' then
    message("The filename is not defined!")
    return;
  end
  // name or path with .mo extension 
  [dirF,nameF,extF]=splitfilepath(exprs_values.nameF);
  if (extF<>'' & extF<>'mo')|(dirF<>'./' & extF<>'mo') then
    message("Filename extention should be ''.mo'' !")
    return;
  end
  // 
  ok = %t;
endfunction

function [ok,tt]=VMODCOM(V,tt)
  // Copyright INRIA
  
  [dirF,nameF,extF]=splitfilepath(V.nameF);
  //the new head
  class_txt_new=VMBLOCK_classhead(V.nameF,V.in,V.intype,[V.in_r,V.in_c],V.out,V.outtype,[V.out_r,V.out_c],V.param,V.paramv,V.pprop)
  
  if isempty(tt) then
    tete4= ["";" //     Real x(start=1), y(start=2);"]
    tete5="equation";
    tete6=["  // exemple"];
    tete7="  //der(x)=x-x*y;";
    tete8="  //der(y)+2*y=x*y;";
    tete9="end "+nameF+";";
    textmp=[class_txt_new;tete4;tete5;tete6;tete7;tete8;tete9];
  else
    textmp=tt;
    I =strstr(tt,'//// do not modify above this line ////');
    I = find(I<>0);
    if ~isempty(I) then
      textmp=[class_txt_new;tt(I(1)+1:$)];
    end
  end
  
  head = ['Function definition in Modelica';
	  'Here is a skeleton of the functions'+...
	  ' which you should edit'];
  cm = catenate(head,sep='\n');
  
  if (extF=='' | (extF=='mo' & ~file('exists',V.nameF))) then
    editblk=%t;
    txt = scicos_editsmat('Modelica class edition',textmp,comment=cm);
    Quit = %t;
  elseif (extF=='mo' && file('exists',V.nameF)) then
    editblk=%f;
    txt = textmp;
  end
  
  if isempty(txt) then 
    ok=%f;
    tt=tt;
  else
    // create Modelica dir if it does not exists 
    md =file('join',[getenv('NSP_TMPDIR');'Modelica'])
    if ~file('exists',md) then file('mkdir',md);end 
    // saving in a file
    if (extF=='')  then
      V.nameF=file('join',[getenv('NSP_TMPDIR'),'Modelica',nameF+'.mo']);
      scicos_mputl(txt,V.nameF);
    elseif ~file('exists',V.nameF) then
      scicos_mputl(txt,V.nameF);
    end
    tt= txt;
    ok = %t;
  end
endfunction

function [ok,cancel,paramv,lab_res]=VMBLOCK_get_parameters_values(params,pprop,params_old,old_param_values)
  // get parameters values
  // param are the labels,
  // ee=evstr(exprs.param) is also the labels by maybe in a different order
  // exprs.paramv is a list giving th evalues (same order as ee).
  ok=%t; cancel=%f; paramv=[]; lab_res =[];
  // pause VMBLOCK_get_parameters_values
  ok = execstr("params_oldv="+params_old,errcatch=%t);
  if ~ok then lasterror();params_oldv=m2s([]);end
  
  ok = execstr("Lvm="+old_param_values,errcatch=%t);
  if ~ok then lasterror();params_oldv=m2s([]);end
  
  param_sz=size(params,'*');
  
  lab_2 = m2s([]);
  for i=1:param_sz
    I= find(params(i)==params_oldv);
    if isempty(I) then 
      lab_2(i,1)= "0";
    else
      lab_2(i,1)= sci2exp(Lvm(I(1)));
    end
  end
  
  //generate lhs, label and rhs txt for getvalue
  if param_sz<>0 then
    // 
    lhs_txt = catenate('%v' + m2s(1:param_sz,"%.0f"),sep= ',');
    rhs_txt = catenate(smat_create(1,param_sz,'''vec'',-1'),sep= ',');
    tag = ['',' (state) ',' (fixed state) '];
    lab_txt = ''''+params+ tag(pprop+1)+ '''';
    lab_txt = catenate(lab_txt,sep= ';');
    //generate main getvalue cmd
    //warning here lab_2 is a list in input and a string in output
    getvalue_txt = '[ok, Lrep, lab_res]=getvalue_list(''Set parameters values'',[' +  ...
		   lab_txt+ '],' + 'list(' + rhs_txt + '),lab_2);';
    //display the second dialog box
    ok = execstr(getvalue_txt,errcatch=%t);
    if ~ok then cancel=%t;ok=%t; return;end;
  else
    Lrep=list();
  end
  //put output param in the form of a list in paramv
  if ok then
    paramv = Lrep;
  end
endfunction

function class_txt=VMBLOCK_classhead(funam,vinp,vintype,vin_size,vout,vouttype,vout_size,vparam,vparamv,vpprop)
  // builds the head of the modelica function
  // with proper declarations for variables
  [dirF,nameF,extF]=splitfilepath(funam);

  np=size(vparam,'r'); // number of params

  txt = ['model '+nameF]
  txt.concatd["  //// automatically generated ////"];

  function [vsize,val] = modelica_value(sz, v, is_parameter = %f)
    // gives strings that can be used for modelica declaration for v
    if and(sz==1) then
      vsize= "";
      val=sci2exp(v);
    elseif and(sz<>1) || (is_parameter && sz(2)==1) then
      // [m,n] || [m,1]
      vsize=stripblanks(sci2exp(sz));
      if sz(1) < 0 then vsize="[:]";end
      if is_parameter then 
	S=m2s([]);
	for i=1:sz(1)
	  s=sprint(v(i,:),as_read=%t);
	  s=strsubst(s(2),['[',']'],['{','}']);
	  S.concatr[s];
	end
	val = "{"+ catenate(S,sep=",") + "}";
      else
	val=[];
      end
    else
      // 
      vsize= "["+ sci2exp(prod(sz)) + "]";
      if sz(2) < 0 || sz(1) < 0 then vsize= "[:]";end
      val=sci2exp(v);
      val=strsubst(val,['[',']',';'],['{','}',',']);
    end
  endfunction
  
  function [val] = modelica_true(vsize, is_parameter = %f)
    // gives strings that can be used for modelica declaration for v
    [vsize,val] = modelica_value(vsize, bmat_create(vsize(1),vsize(2)),  is_parameter = is_parameter);
    val=strsubst(val,"%t","true");
  endfunction
  
  // parameters head
  if np<>0 then
    txt.concatd["    //parameters"];
    for i=1:np
      [vsize,sval] = modelica_value(size(vparamv(i)),vparamv(i) ,is_parameter = %t);
      if vpprop(i)==0 then
	// parameters
	head= sprintf("    parameter Real %s%s = %s;", vparam(i),vsize, sval);
      elseif vpprop(i)==1 then
	// state with start value
	head= sprintf("    Real %s%s (start=%s);", vparam(i), vsize, sval);
      elseif vpprop(i)==2 then
	// fixed state
	strue = modelica_true(size(vparamv(i)),is_parameter = %t);
	head= sprintf("    Real %s%s (fixed=%s, start=%s);", vparam(i),vsize, strue, sval);
      end
      txt.concatd[head];
    end
  end
  
  // inputs head
  ni=size(vinp,'r');
  if ni<>0 then
    txt.concatd["    // inputs "];
    for i=1:ni
      [vsize,sval] = modelica_value(vin_size(i,:),[]);
      if vintype(i)=='I' then stype = "Input"; else stype="";end;
      head= sprintf("    Real%s %s%s;",stype, vinp(i), vsize);
      txt.concatd[head];
    end
  end
  
  // outputs head
  no=size(vout,'r');
  if no<>0 then
    txt.concatd["    // outputs"]
    for i=1:no
      [vsize,sval] = modelica_value(vout_size(i,:),[]);
      if vouttype(i)=='I' then stype = "Output"; else stype="";end;
      head= sprintf("    Real%s %s%s;",stype, vout(i), vsize);
      txt.concatd[head];
    end
  end
  
  txt.concatd["  //// do not modify above this line ////"];
  //-----------------------------------------
  class_txt=txt;
endfunction

function [ok,tt]=VMODCOM_NI(V,tt)
  // This is the non interactive version used in eval or load 
  //printf("In non interactive MODCOM \n");
  ok = %t;
  // create Modelica dir if it does not exists 
  md =file("join",[getenv("NSP_TMPDIR");"Modelica"])
  if ~file("exists",md) then file("mkdir",md);end 
  // fill the funam file 
  nameF=file("root",file("tail",V.nameF));
  extF =file("extension",V.nameF);
  // tt should be a string and it was initialized to [] in the past.
  if type(tt,"short")=="m" then tt=m2s([]);end 
  if extF=="" then 
    funam1=file("join",[getenv("NSP_TMPDIR");"Modelica";nameF+".mo"]);
    scicos_mputl(tt,funam1);
  elseif ~file("exists",V.nameF) then
    funam1=V.nameF;
    scicos_mputl(tt,funam1);
  end
endfunction


function [x,y,typ]=MBM_Constantn(job,arg1,arg2)
  // A <<coselica>> block for non-scalar constants

  function blk_draw(sz,orig,orient,label)
    blue=xget('color','blue');
    white=xget('color','white');
    black=xget('color','black');
    gray=xget('color','gray');
    red = xget('color','red');
    if length(C) > 15 then C ="...";end
    
    if orient then
      xx=orig(1);yy=orig(2);
      ww=sz(1);hh=sz(2);
    else
      xx=orig(1)+sz(1);yy=orig(2);
      ww=-sz(1);hh=sz(2);
    end
    // frame 
    if orient then
      xrect(orig(1)+sz(1)*0,orig(2)+sz(2)*1,sz(1)*1,sz(2)*1,color=blue,background=white);
    else
      xrect(orig(1)+sz(1)*(1-0-1),orig(2)+sz(2)*1,sz(1)*1,sz(2)*1,color=blue,background=white);
    end
    // label 
    if orient then
      xstringb(orig(1)+sz(1)*-0.25,orig(2)+sz(2)*1.05,label,sz(1)*1.5,sz(2)*0.2,"fill");
    else
      xstringb(orig(1)+sz(1)*(1--0.25-1.5),orig(2)+sz(2)*1.05,label,sz(1)*1.5,sz(2)*0.2,"fill");
    end    
    xpoly(xx+ww*[0.1;0.1],yy+hh*[0.84;0.1],color=gray);
    xfpoly(xx+ww*[0.1;0.06;0.14;0.1],yy+hh*[0.95;0.84;0.84;0.95],color=gray,fill_color=gray);
    xpoly(xx+ww*[0.05;0.91],yy+hh*[0.15;0.15],color=gray);
    xfpoly(xx+ww*[0.95;0.84;0.84;0.95],yy+hh*[0.15;0.19;0.11;0.15],color=gray,fill_color=gray);
    xpoly(xx+ww*[0.1;0.9],yy+hh*[0.5;0.5],color=black);
    xpoly(xx+ww*[0.1;0.9],yy+hh*[0.6;0.6],color=red);
    xpoly(xx+ww*[0.1;0.9],yy+hh*[0.3;0.3],color=blue);
    if orient then
       xstringb(orig(1)+sz(1)*-0.25,orig(2)+sz(2)*-0.25,"K="+C,sz(1)*1.5,sz(2)*0.2,"fill");
    else
       xstringb(orig(1)+sz(1)*(1--0.25-1.5),orig(2)+sz(2)*-0.25,"K="+C,sz(1)*1.5,sz(2)*0.2,"fill");
    end
  endfunction
  
  function blk_draw_old(sz,orig,orient,label)
    dx=sz(1)/5;dy=sz(2)/10;
    w=sz(1)-2*dx;h=sz(2)-2*dy;
    txt="C";
    xstringb(orig(1)+dx,orig(2)+dy,txt,w,h,'fill');
  endfunction
  
  function blk= MBM_Constantn_define(C,paramv, old)
    if nargin <= 2 then 
      global(modelica_count=0);
      nameF='generic'+string(modelica_count);
      modelica_count =       modelica_count +1;
    else
      nameF=old.graphics.exprs.nameF;
    end
    n=size(C,'*');
    
    H=hash(in=[], intype=[], in_r=[], in_c=[],
	   out=["y"], outtype="I", out_r=size(C,1), out_c=size(C,2),
	   param=["C"], paramv=list(C),
	   pprop=[0], nameF=nameF);

    txt=VMBLOCK_classhead(H.nameF,H.in,H.intype,[H.in_r,H.in_c],H.out,H.outtype,[H.out_r,H.out_c],H.param,H.paramv,H.pprop)
    txt.concatd["  equation"];
    if and(size(C)==1) then
      txt.concatd["    y.signal= C;"];
    elseif and(size(C)<>1) then
      for i=1:size(C,1)
	for j=1:size(C,2)
	  txt.concatd[sprintf("    y[%d,%d].signal= C[%d,%d];",i,j,i,j)];
	end
      end
    elseif size(C,2)==1 
      for i=1:size(C,'*')
	txt.concatd[sprintf("    y[%d].signal= C[%d,1];",i,i)];
      end
    else
      for i=1:size(C,'*')
	txt.concatd[sprintf("    y[%d].signal= C[%d];",i,i)];
      end
    end
    txt.concatd[sprintf("end %s;", nameF)];
    
    H.funtxt = txt;
    if nargin == 3 then 
      blk = VMBLOCK_define(H,old);
    else
      blk = VMBLOCK_define(H);
    end
    // remove leading and trainling () 
    paramv=regsub(paramv,"^\(+(.*)\)+$","\\1")
    blk.graphics.exprs.paramv = sprintf("list(%s)", paramv);
    blk.graphics.exprs.funtxt = txt;
    blk.graphics('3D') = %f; // coselica options 
    blk.graphics.gr_i=list("blk_draw(sz,orig,orient,model.label)",xget('color','blue'))
    blk.gui = "MBM_Constantn";

  endfunction
  
  x=[];y=[];typ=[];
  select job
    case 'plot' then
      // get string inside list(str);
      xparamv=regsub(arg1.graphics.exprs.paramv,"^list\(+(.*)\)+$","\\1")
      paramv=arg1.graphics.exprs.paramv;
      C = xparamv;
      standard_coselica_draw(arg1);
    case 'getinputs' then
      [x,y,typ]=standard_inputs(arg1)
    case 'getoutputs' then
      [x,y,typ]=standard_outputs(arg1)
    case 'getorigin' then
      [x,y]=standard_origin(arg1)
    case 'set' then
      x=arg1;
      // get string inside list(str);
      xparamv=regsub(arg1.graphics.exprs.paramv,"^list\(+(.*)\)+$","\\1")
      value=list(strsubst(xparamv,'list',''));
      gv_titles='Set MBM_Constantn block parameters';
      gv_names=['constant'];
      gv_types = list('vec',-1);
      [ok,C, value_n]=getvalue(gv_titles,gv_names,gv_types,value);
      if ~ok then return;end; // cancel in getvalue;
      
      x= MBM_Constantn_define(C,value_n,x);
      
    case 'define' then
      cte = [1,2;3,7;8,9];
      x= MBM_Constantn_define(cte,"[1,2;3,7;8,9]");
  end
endfunction

