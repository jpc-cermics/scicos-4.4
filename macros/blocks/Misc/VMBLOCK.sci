function [x,y,typ]=VMBLOCK(job,arg1,arg2)
  // Similar to MBLOCK but variables may have
  // dimensions and are declared RealOutput or RealInput instead of Real
  // to be used in Coselica
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
      //label=graphics.exprs;
      exprs=graphics.exprs

      if type(exprs,'short')=='l' then
	//Compatibility
	paramv=list();
	pprop=[];
	//must do something better than that !
	for i=1:size(model.rpar,'*')
	  paramv($+1)=string(model.rpar(i))
	  pprop($+1) = 0
	end

	exprs = tlist(["MBLOCK","in","intype","out","outtype",...
		       "param","paramv","pprop","nameF","funtxt"],...
		      exprs(1)(1), exprs(1)(2), exprs(1)(3),...
		      exprs(1)(4), exprs(1)(5), paramv,...
		      sci2exp(pprop(:)), exprs(1)(7),exprs(2));
      end

      // check if this is an interactive MBLOCK('set',o);
      non_interactive = exists('getvalue') && getvalue.get_fname[]== 'setvalue';

      while %t do
	// block parameters 
	[ok,cancel,model,graphics,in,intype,in_r,in_c,out,outtype,out_r,out_c,param,paramv,pprop,funam,lab_1]= ...
	VMBLOCK_get_parameters(exprs,model,graphics);
	if cancel then return;end 
	if ~ok && non_interactive then return;end 
	if ~ok then continue;end 
	//============================
	//generate second dialog box from Tparam
	[ok,cancel,paramv,lab_2]= MBLOCK_get_parameters_values(param, exprs);
	if cancel then return;end
	if ~ok && non_interactive then return;end 
	if ~ok then continue;end 
	//============================
	[dirF,nameF,extF]=splitfilepath(funam);
	if extF=='mo' && file('exists',funam) then
	  tt=scicos_mgetl(funam);
	else
	  tt=exprs.funtxt
	  mo=model.equations
	end
	if non_interactive then 
	  [ok,tt]=VMODCOM_NI(funam,tt,in,intype,[in_r,in_c],out,outtype,[out_r,out_c],param,paramv,pprop);
	else 
	  [ok,tt]=VMODCOM(funam,tt,in,intype,[in_r,in_c],out,outtype,[out_r,out_c],param,paramv,pprop);
	end
	if ok &&  file('exists',funam) then
	  // must save back the results
	  scicos_mputl(tt,funam)
	end
	// here ok = %f means cancel in edition
	break;
      end
      
      if ~ok then return;end 
      // define new model 
      mo=modelica()
      mo.model=nameF
      mo.inputs=in;
      mo.outputs=out;
      if max(pprop)>0 then
	mo.parameters=list(param',paramv,pprop')
      else
	mo.parameters=list(param',paramv)
      end
      model.equations=mo
      //------------------
      //model.rpar=paramv;
      model.rpar=[];
      for i=1:length(paramv)
	xx= paramv(i)(:);
	if type(xx,'short')== 'i' then xx=i2m(xx);end 
	if type(xx,'short')== 'b' then xx=b2m(xx);end 
	model.rpar=[model.rpar; xx];
      end
      model.sim(1)=funam
      //------------------
      exprs.in=lab_1(1)
      exprs.intype=lab_1(2)
      exprs.in_r=lab_1(3)
      exprs.in_c=lab_1(4)
      exprs.out=lab_1(5)
      exprs.outtype=lab_1(6)
      exprs.out_r=lab_1(7)
      exprs.out_c=lab_1(8)
      exprs.param=lab_1(9)
      exprs.paramv=list();
      for i=1:size(lab_2,'*')
	exprs.paramv(i)=lab_2(i);
      end
      exprs.pprop=lab_1(10)
      exprs.nameF=lab_1(11)
      exprs.funtxt=tt
      //label(2)=tt
      //------------------
      x.model=model
      graphics.gr_i(1)(1)="txt=[""Modelica"";"" " + nameF + " ""];"
      graphics.in_implicit =intype
      graphics.out_implicit=outtype
      //graphics.exprs=label
      graphics.exprs=exprs
      x.graphics=graphics

   case 'define' then
     //----------- Define
     in=['u1'];intype=['I']; in_r= [2]; in_c=[1];
     out=['y1';'y2']; outtype=['I';'E']; out_r= [2,3]; out_c=[1,1];
     param=['R';'L']; paramv=list(0.1,.0001)
     pprop=[0;0];
     nameF='genericv';
     
     exprs = tlist(["MBLOCK","in","intype","in_r","in_c","out","outtype","out_r","out_c",...
		    "param","paramv","pprop","nameF","funtxt"],...
		   sci2exp(in(:)),...
		   sci2exp(intype(:)),...
		   sci2exp(in_r(:)),...
		   sci2exp(in_c(:)),...
		   sci2exp(out(:)),...
		   sci2exp(outtype(:)),...
		   sci2exp(out_r(:)),...
		   sci2exp(out_c(:)),...
		   sci2exp(param(:)),...
		   map(paramv,sci2exp),...
		   sci2exp(pprop(:)),...
		   nameF,m2s([]))
     
     model=scicos_model();
     model.blocktype='c';
     model.dep_ut=[%f %t];
     //model.rpar=paramv;
     model.rpar=[]
     for i=1:length(paramv)
       model.rpar=[model.rpar; paramv(i)(:)]
     end
     // mo is model.equations;
     mo=modelica();
     mo.model=nameF
     mo.parameters=list(param,paramv)
     mo.inputs=in
     mo.outputs=out
     // model 
     model.sim=list(mo.model,30004)
     model.in=in_r(:);
     model.in2=in_c(:);
     model.out=out_r(:);
     model.out2=out_c(:);
     model.equations=mo
     gr_i=["txt=[""Modelica"";"" "+nameF+" ""];";
	   "xstringb(orig(1),orig(2),txt,sz(1),sz(2),""fill"")"]
     x=standard_define([3 2],model,exprs,gr_i,'VMBLOCK');
     x.graphics.in_implicit =intype
     x.graphics.out_implicit=outtype
  end
endfunction

function [ok,cancel,model,graphics,in,intype,in_r,in_c,out,outtype,out_r,out_c,param,paramv,pprop,funam,lab_1]=...
	 VMBLOCK_get_parameters(exprs,model,graphics)
  // get parameters 
  cancel=%f;
  in=[];intype=[];in_r=[],int_c=[];out=[];outtype=[];out_r=[];out_c=[];param=[];paramv=[];pprop=[];funam='void';lab_1=[];
  //lab_1 = [in,intype,out,outtype,param,nameF]
  lab_1 = list(exprs.in,      
	       exprs.intype,
	       exprs.in_r,
	       exprs.in_c,
	       exprs.out,
	       exprs.outtype,  
	       exprs.out_r,
	       exprs.out_c,
	       exprs.param,    
	       exprs.pprop,    
	       exprs.nameF);
  names_1 = ['Input variables       ';
	     'Input variables types ';
	     'Input variables row sizes';
	     'Input variables col sizes';
	     'Output variables      ';
	     'Output variables types';
	     'Output variables row sizes';
	     'Output variables col sizes';
	     'Parameters in Modelica';
	     'Parameters properties ';
	     'Function name         '];
  types_1 = list('str',-1,'str',-1,'vec',-1, 'vec',-1,'str',-1,'str',-1,'vec',-1, 'vec',-1,'str',-1, 'vec',-1,'str',-1);
  [ok,Tin,Tintype,Tin_r,Tin_c,Tout,Touttype,Tout_r,Tout_c,Tparam,pprop,Tfunam,lab_1]=..
  getvalue('Set Modelica generic block parameters', names_1, types_1,lab_1)
  // check cancel case
  if ~ok then cancel=%t;ok=%t; return;end 
  // default return value
  ok = %f;
  // check variable names
  eok = %t;
  vars=['in','intype','out','outtype','param'];
  for var=vars
    cmd= sprintf('%s=evstr(T%s);if isempty(%s) then %s=m2s([]);else %s=stripblanks(%s);end',...
		 var,var,var,var,var,var);
    ook= execstr(cmd,errcatch=%t);
    //if ~ook then pause;bug;end 
    eok= eok && ook;
  end
  eok= eok && execstr("funam=stripblanks(Tfunam)",errcatch=%t);
  for var=['in_r','in_c','out_r','out_c']
    cmd= sprintf('%s=evstr(T%s);',var,var);
    ook= execstr(cmd,errcatch=%t);
    //if ~ook then pause bug;end 
    eok= eok && ook;
  end
  
  if ~eok then
    // something wrong when evaluating names 
    message("Error in evaluation of variables in block VMBLOCK.")
    return;
  end
  //check for valid name variable
  function ok= mblock_validvar(in)
    ok=%f;
    for i=1:size(in,'*')
      valid=%f;
      eok=execstr('valid=validvar(in(i))',errcatch=%t);
      if ~eok then latserror();end;
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
  if ~mblock_validvar(in) then return;end 
  // variable out
  if ~mblock_validvar(out) then return;end 
  // variable param
  param=param(:);
  if ~mblock_validvar(param) then return;end 
  // type checking
  for i=1:size(intype,'*')
    if intype(i)<>'E' && intype(i)<>'I' then
      message("Input type should be ''E'' or ''I''!");
      return;
    end
  end
  for i=1:size(outtype,'*')
    if outtype(i)<>'E'&outtype(i)<>'I' then
      message("Output type should be ''E'' or ''I''!");
      return;
    end
  end
  //cross size checking
  if or(size(intype)<>size(in)) then
    message("Input variables are not well defined!");
    return;
  end

  if or(size(in_r)<>size(in)) then
    message("Input row sizes and input names shoudl share the same sizes");
    return;
  end
  if or(size(in_c)<>size(in)) then
    message("Input col sizes and input names shoudl share the same sizes");
    return;
  end
  
  if or(size(outtype)<>size(out)) then
    message("Output variables are not well defined!");
    return;
  end

  if or(size(out_r)<>size(out)) then
    message("Output row sizes and input names shoudl share the same sizes");
    return;
  end
  if or(size(out_c)<>size(out)) then
    message("Output col sizes and input names shoudl share the same sizes");
    return;
  end
  
  //check param properties
  pprop = pprop(:);
  if (size(param,'*')<>size(pprop,'*')) then
    message(["There is differences in";
	     "size of param and size ";
	     "of param properties." ])
    return;
  end
  if max(pprop)>2 | min(pprop)<0 then
    message(["Parameters properties must be :";
	     "0 : if it is a paramaters";
	     "1 : if it is an initial value of state,";
	     "2 : it it is a fixed initial state value." ])
    return;
  end
  //check name of modelica file
  if funam=='' then
    message("The filename is not defined!")
    return;
  end
  // name or path with .mo extension 
  [dirF,nameF,extF]=splitfilepath(funam);
  if (extF<>'' & extF<>'mo')|(dirF<>'./' & extF<>'mo') then
    message("Filename extention should be ''.mo'' !")
    return;
  end
  // 
  //set_io checking
  intypex=find(intype=='I'); 
  outtypex=find(outtype=='I');
  [model,graphics,ok]=set_io(model,graphics,list([in_r(:),in_c(:)],ones(size(in))),..
						list([out_r(:),out_c(:)],ones(size(out))),..
						[],[],intypex,outtypex);
  ok = %t;
endfunction

function [ok,tt]=VMODCOM(funam,tt,vinp,vintype,vin_size,vout,vouttype,vout_size,vparam,vparamv,vpprop)
  // Copyright INRIA
  [dirF,nameF,extF]=splitfilepath(funam);
  //the new head
  class_txt_new=vmblock_build_classhead(funam,vinp,vintype,vin_size,vout,vouttype,vout_size,vparam,vparamv,vpprop)

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
  
  if (extF=='' | (extF=='mo' & ~file('exists',funam))) then
    editblk=%t;
    txt = scicos_editsmat('Modelica class edition',textmp,comment=cm);
    Quit = %t;
  elseif (extF=='mo' && file('exists',funam)) then
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
      funam=file('join',[getenv('NSP_TMPDIR'),'Modelica',nameF+'.mo']);
      scicos_mputl(txt,funam);
    elseif ~file('exists',funam) then
      scicos_mputl(txt,funam);
    end
    tt= txt;
    ok = %t;
  end
endfunction

function class_txt=vmblock_build_classhead(funam,vinp,vintype,vin_size,vout,vouttype,vout_size,vparam,vparamv,vpprop)
  // builds the head of the modelica function
  // with proper declarations for variables

  [dirF,nameF,extF]=splitfilepath(funam);
  
  np=size(vparam,'r'); // number of params

  txt = ['model '+nameF]
  txt.concatd["  //// automatically generated ////"];

  function txt = param_value_as_string(paramv)
    txt=sci2exp(paramv);
    txt=strsubst(txt,['[',']'],['{','}']);
  endfunction
  
  // parameters head
  if np<>0 then
    txt.concatd["    //parameters"];
    for i=1:np
      if vpprop(i)==0 then
	// parameters
	sval = param_value_as_string(vparamv(i));
	if size(vparamv(i),'*')==1 then
	  head= sprintf("    parameter Real %s = %s;", vparam(i), sval);
	else
	  head= sprintf("    parameter Real %s[%d] = %s;", vparam(i),size(vparamv(i),'*'),sval);
	end
      elseif vpprop(i)==1 then
	// state with start value
	sval = param_value_as_string(vparamv(i));
	if size(vparamv(i),'*')==1 then
	  head= sprintf("    Real %s (start=%s);", vparam(i),sval);
	else
	  head= sprintf("    Real %s[%d] = (start=%s);", vparam(i), size(vparamv(i),'*'),sval);
	end
      elseif vpprop(i)==2 then
	// fixed state
	sval = param_value_as_string(vparamv(i));
	if size(vparamv(i), '*' )==1 then
	  head= sprintf("    Real %s (fixed=true, start=%s);", vparam(i),sval);
	else
	  fval = smat_create(1,size(vparamv(i),'*'),'fixed');
	  fval = "{" + catenate(fval,sep=",") + "}";
	  head= sprintf("    Real %s[%d] = (fixed=%d,start=%s);", vparam(i), size(vparamv(i),'*'),fval,sval);
	end
      end
      txt.concatd[head];
    end
  end

  function S=build_sizes(vsize)
    S=m2s([]);
    for i=1:size(vsize,'r')
      rsize= vsize(i,:);
      if prod(rsize)==1 then s="";
      elseif rsize(2)==1 then s=sprintf("[%d]",rsize(1));
      else s = sprintf("[%d,%d]",rsize(1),rsize(2));
      end
      S.concatd[s];
    end
  endfunction
  
  // inputs head
  ni=size(vinp,'r');
  if ni<>0 then
    I=find(vintype=='I');
    J=find(vintype<>'I');
    S=build_sizes(vin_size);
    txt.concatd["    // inputs "];
    if ~isempty(I) then txt.concatd["    RealInput "+ catenate(vinp(I)+S(I),sep=",") + ";"];end
    if ~isempty(J) then txt.concatd["    Real "+ catenate(vinp(J)+S(J),sep=",") + ";"];end
  end
  // outputs head
  no=size(vout,'r');
  if no<>0 then
    I=find(vouttype=='I');
    J=find(vouttype<>'I');
    S=build_sizes(vout_size);
    txt.concatd["    // outputs"]
    if ~isempty(I) then txt.concatd["    RealOutput "+ catenate(vout(I)+S(I),sep=",") + ";"];end
    if ~isempty(J) then txt.concatd["    Real "+ catenate(vout(J)+S(J),sep=",") + ";"];end
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

