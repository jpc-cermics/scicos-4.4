function [x,y,typ]=VMBLOCK(job,arg1,arg2)
  // Similar to MBLOCK but variables may have
  // dimensions and are declared RealOutput or RealInput instead of Real
  // to be used in Coselica
  // Note that Explicit Outputs or Inputs must be scalars (since communication
  // between scicos and modlica should be through scalar links
  // XXXXX: Il faut v�rifier que les arguments explicites sont scalaires
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
	[ok,cancel,paramv,lab_2]= VMBLOCK_get_parameters_values(exprs_values.param,exprs_values.pprop, exprs.param, exprs.paramv);
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
  if nargin == 2 then
    exprs.funtxt = H.funtxt;
    H.delete['funtxt'];
  end
  
  for key=(H.__keys)' do
    if type(key,'short') <> 'l' then val =sci2exp(H(key));else val=map(H(key),sci2exp);end
    exprs(key)=val;
  end
  exprs.nameF=H.nameF;
  
  // model.equations;
  model_equations=modelica();
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
  model.intype = H.intype;
  model.outtype= H.outtype;
  model.equations=model_equations;
  if nargin == 2 then
    blk = old;
    intypex=find(H.intype=='I'); 
    outtypex=find(H.outtype=='I');
    [model,graphics,ok]= set_io(model,old.graphics,list([H.in_r(:),H.in_c(:)],ones(size(H.in))),..
						       list([H.out_r(:),H.out_c(:)],ones(size(H.out))),..
						       [],[],intypex,outtypex);
    blk.model = model;
    blk.graphics = graphics;
    blk.graphics.exprs = exprs;
  else
    // we could here call set_io to fix graphics
    gr_i=["txt=[""Modelica"";"" "+H.nameF+" ""];";
	  "xstringb(orig(1),orig(2),txt,sz(1),sz(2),""fill"")"]
    blk=standard_define([40 40],model,exprs,gr_i,'VMBLOCK');
    // standard define should incorporate that 
    blk.graphics.in_implicit =H.intype
    blk.graphics.out_implicit=H.outtype
    blk.graphics.exprs.funtxt = m2s([]);
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
  class_txt_new=vmblock_build_classhead(V.nameF,V.in,V.intype,[V.in_r,V.in_c],V.out,V.outtype,[V.out_r,V.out_c],V.param,V.paramv,V.pprop)
  
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

function class_txt=vmblock_build_classhead(funam,vinp,vintype,vin_size,vout,vouttype,vout_size,vparam,vparamv,vpprop)
  // builds the head of the modelica function
  // with proper declarations for variables

  [dirF,nameF,extF]=splitfilepath(funam);
  
  np=size(vparam,'r'); // number of params

  txt = ['model '+nameF]
  txt.concatd["  //// automatically generated ////"];

  function [vsize,val] = modelica_value(v)
    // gives strings that can be used for modelica declaration for v
    if and(size(v)<>1) then
      vsize=stripblanks(sci2exp(size(v)));
      S=m2s([]);
      for i=1:size(v,'r')
	s=sprint(v(i,:),as_read=%t);
	s=strsubst(s(2),['[',']'],['{','}']);
	S.concatr[s];
      end
      val = "{"+ catenate(S,sep=",") + "}";
    elseif and(size(v)==1) then
      vsize= "";
      val=sci2exp(v);
    else
      vsize= "["+ sci2exp(prod(size(v))) + "]";
      val=sci2exp(v(:)');
      val=strsubst(val,['[',']'],['{','}']);
    end
  endfunction

  function [val] = modelica_true(vsize)
    // gives strings that can be used for modelica declaration for v
    [vsize,val] = modelica_value(bmat_create(vsize(1),vsize(2)));
    val=strsubst(val,"%t","true");
  endfunction
  
  // parameters head
  if np<>0 then
    txt.concatd["    //parameters"];
    for i=1:np
      if vpprop(i)==0 then
	// parameters
	[vsize,sval] = modelica_value(vparamv(i));
	head= sprintf("    parameter Real %s%s = %s;", vparam(i),vsize, sval);
      elseif vpprop(i)==1 then
	// state with start value
	[vsize,sval] = modelica_value(vparamv(i));
	head= sprintf("    Real %s%s (start=%s);", vparam(i), vsize, sval);
      elseif vpprop(i)==2 then
	// fixed state
	[vsize,sval] = modelica_value(vparamv(i));
	strue = modelica_true(size(vparamv(i)));
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
      [vsize,sval] = modelica_value(ones(vin_size(i,:)));
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
      [vsize,sval] = modelica_value(ones(vout_size(i,:)));
      if vouttype(i)=='I' then stype = "Output"; else stype="";end;
      head= sprintf("    Real%s %s%s;",stype, vout(i), vsize);
      txt.concatd[head];
    end
  end
  
  txt.concatd["  //// do not modify above this line ////"];
  //-----------------------------------------
  class_txt=txt;
endfunction

function [ok,tt]=VMODCOM_NI(funam,tt,vinp,vintype,vin_size,vout,vouttype,vout_size,vparam,vparamv,vpprop)
  // This is the non interactive version used in eval or load 
  //printf("In non interactive MODCOM \n");
  ok = %t;
  // create Modelica dir if it does not exists 
  md =file("join",[getenv("NSP_TMPDIR");"Modelica"])
  if ~file("exists",md) then file("mkdir",md);end 
  // fill the funam file 
  nameF=file("root",file("tail",funam));
  extF =file("extension",funam);
  // tt should be a string and it was initialized to [] in the past.
  if type(tt,"short")=="m" then tt=m2s([]);end 
  if extF=="" then 
    funam1=file("join",[getenv("NSP_TMPDIR");"Modelica";nameF+".mo"]);
    scicos_mputl(tt,funam1);
  elseif ~file("exists",funam) then
    funam1=funam;
    scicos_mputl(tt,funam1);
  end
endfunction



function [x,y,typ]=MBM_Addn(job,arg1,arg2)
// Copyright INRIA

  function SUMMATION_draw(o,sz,orig)
    [x,y,typ]=standard_inputs(o) 
    dd=sz(1)/8,de=0;
    if ~arg1.graphics.flip then dd=6*sz(1)/8,de=-sz(1)/8,end
    if ~exists("%zoom") then %zoom=1, end;
    fz=2*%zoom*4;
    for k=1:size(x,'*');
      if size(sgn,1) >= k then
	if sgn(k) > 0 then;
	  xstring(orig(1)+dd,y(k)-4,'+',size=fz);
	else;
	  xstring(orig(1)+dd,y(k)-4,'-',size=fz);
	end;
      end;
    end;
    xx=sz(1)*[.8 .4 0.75 .4 .8]+orig(1)+de;
    yy=sz(2)*[.8 .8 .5 .2 .2]+orig(2);
    xpoly(xx,yy,type='lines');
  endfunction
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    sgn=arg1.model.ipar
    standard_draw(arg1)
   case 'getinputs' then
    [x,y,typ]=standard_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=standard_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics
    model=arg1.model
    exprs=graphics.exprs;
    ok = execstr('value='+exprs.paramv);
    value= list(sci2exp(value(1)));
    
    gv_titles='Set sum block parameters';
    gv_names=['sign vector (of +1, -1)'];
    gv_types = list('vec',-1);
    [ok,sgn, value_n]=getvalue(gv_titles,gv_names,gv_types,value);
    if ~ok then return;end; // cancel in getvalue;
    x= MBM_Addn_define(sgn(:),x);
   case 'define' then
     sgn=[1;-1];
     x= MBM_Addn_define(sgn);
  end
endfunction

function blk= MBM_Addn_define(vect,old)
  // used when gains is given by a matrix or vector
  // we use a VMBLOCK;

  global(modelica_count=0);
  nameF='generic'+string(modelica_count);
  modelica_count =       modelica_count +1;
  n=size(vect,'*');
  H=hash(in=["u"+string(1:n)'], intype=smat_create(n,1,"I"), in_r=ones(n,1), in_c=ones(n,1),
	 out=["y"], outtype=["I"], out_r= 1, out_c=1,
	 param=["G"], paramv=list(vect),
	 pprop=[0], nameF=nameF);
  
  txt=[sprintf("model %s", nameF)];
  txt.concatd[sprintf("parameter Real G[%d]=",size(vect,"*"))];
  s=sprint(vect(:)',as_read=%t);
  s=strsubst(s(2),["[","]"],["{","}"]);
  txt = txt + catenate(s,sep=",") +";";
  txt.concatd[sprintf("  RealOutput y;")]
  txt.concatd[sprintf("  RealInput %s,",catenate("u"+string(1:n),sep=","))];
  txt.concatd["  equation"];
  start = m2s([]);
  for i=1: size(vect,"*")
    start.concatr[sprintf("G[%d]*u%d.signal",i,i)];
  end
  txt.concatd["    y.signal=" + catenate(start,sep="+") + ";"];
  txt.concatd[sprintf("end %s;", nameF)];

  H.funtxt = txt;
  if nargin == 2 then 
    blk = VMBLOCK_define(H,old);
  else
    blk = VMBLOCK_define(H);
  end
  
  blk.graphics.exprs.funtxt = txt;
  blk.graphics.gr_i=["SUMMATION_draw(o,sz,orig);"];
  blk.gui = "MBM_Addn";
  
  // // XXX
  // diag = scicos_diagram();
  // diag.objs= list(blk);
  // [diag1,ok]=do_silent_eval(diag);
  // blk = diag1.objs(1);
endfunction
