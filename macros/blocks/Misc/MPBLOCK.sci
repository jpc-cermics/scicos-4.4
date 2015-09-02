function [x,y,typ]=MPBLOCK(job,arg1,arg2)
// Modelica generic block 
// Copyright INRIA Oct 2006
//
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

      exprs = tlist(["MPBLOCK","in","intype","out","outtype",...
		     "param","paramv","pprop","nameF","funtxt"],...
		    exprs(1)(1), exprs(1)(2), exprs(1)(3),..
		    exprs(1)(4), exprs(1)(5), paramv,...
		    sci2exp(pprop(:)), exprs(1)(7),exprs(2));
    end

    // check if this is an interactive MBLOCK('set',o);
    non_interactive = exists('getvalue') && getvalue.get_fname[]== 'setvalue';

    while %t do
      // block parameters 
      [ok,cancel,model,graphics,in,intype,out,outtype,param,paramv,pprop,nameF,lab_1]= ...
	  MPBLOCK_get_parameters(exprs,model,graphics);
      if cancel then return;end 
      if ~ok && non_interactive then return;end 
      if ~ok then continue;end 

      //============================
      //generate second dialog box from Tparam
      [ok,cancel,paramv,lab_2]= MPBLOCK_get_parameters_values(param, ...
						  exprs);
      if cancel then return;end
      if ~ok && non_interactive then return;end 
      if ~ok then continue;end 
      //============================
      // here ok = %f means cancel in edition
      break;
    end

    if ~ok then return;end 
    // define new model 
    k=strindex(nameF,'.');lf=length(nameF);[ns,ms]=max(k);
    if isempty(ns) then 
      nameF1=nameF;
    else       
      nameF1=part(nameF,ns+1:lf);
    end
    mo=modelica()
    mo.model=nameF
    mo.inputs=in;
    mo.outputs=out;
    if ~isempty(pprop) then 
      if max(pprop)>0 then
	mo.parameters=list(param',paramv,pprop')
      else
	mo.parameters=list(param',paramv)
      end
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
    model.sim(1)=nameF1;//useless!
    //------------------
    exprs.in=lab_1(1)
    exprs.intype=lab_1(2)
    exprs.out=lab_1(3)
    exprs.outtype=lab_1(4)
    exprs.param=lab_1(5)
    exprs.paramv=list();
    for i=1:size(lab_2,'*')
      exprs.paramv(i)=lab_2(i);
    end
    exprs.pprop=lab_1(6)
    exprs.nameF=lab_1(7)
    exprs.funtxt='' // model is defined in the a package
    //label(2)=tt
    //------------------
    x.model=model
    graphics.gr_i(1)(1)='txt=['' ' + nameF1 + ' ''];'
    graphics.in_implicit =intype
    graphics.out_implicit=outtype
    //graphics.exprs=label
    graphics.exprs=exprs
    x.graphics=graphics

   case 'define' then
    in=['u']
    intype=['I']
    out=['y1';'y2']
    outtype=['I';'I']
    param=[];
    paramv=list()
    pprop=[];

    nameF='myPackage.myModels.model'
    k=strindex(nameF,'.');lf=length(nameF);[ns,ms]=max(k);
    nameF1=part(nameF,ns+1:lf);

    exprs = tlist(["MPBLOCK","in","intype","out","outtype",...
		   "param","paramv","pprop","nameF","funtxt"],...
		  sci2exp(in(:)),..
		  sci2exp(intype(:)),..
		  sci2exp(out(:)),..
		  sci2exp(outtype(:)),..
		  sci2exp(param(:)),..
		  list(string(0.1),string(.0001)),...
		  sci2exp(pprop(:)),..
		  nameF,[])

    model=scicos_model()
    model.blocktype='c'
    model.dep_ut=[%t %t]
    //model.rpar=paramv;
    model.rpar=[]
    for i=1:length(paramv)
      model.rpar=[model.rpar;
		  paramv(i)(:)]
    end

    mo=modelica()
    mo.model=nameF
    mo.parameters=list(param,paramv)
    model.sim=nameF1;
    mo.inputs=in
    mo.outputs=out
    model.in=ones(size(mo.inputs,'r'),1)
    model.out=ones(size(mo.outputs,'r'),1)
    model.equations=mo
    gr_i=['txt=['' '+nameF1+' ''];';
	  'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'')'];
    x=standard_define([3 2],model,exprs,gr_i,'MPBLOCK');
    x.graphics.in_implicit =intype
    x.graphics.out_implicit=outtype
  end
endfunction


function [ok,cancel,model,graphics,in,intype,out,outtype,param,paramv,pprop,nameF,lab_1]=...
      MPBLOCK_get_parameters(exprs,model,graphics)
  // get parameters 
  cancel=%f;
  in=[],out=[],param=[],paramv=[],pprop=[];intype=[];outtype=[];funam='void';
  lab_1=[];
  //lab_1 = [in,intype,out,outtype,param,nameF]
  lab_1 = list(exprs.in,..       //1
	       exprs.intype,..   //2
	       exprs.out,..      //3
	       exprs.outtype,..  //4
	       exprs.param,..    //5
	       exprs.pprop,..    //6
	       exprs.nameF)      //7

  [ok,Tin,Tintype,Tout,Touttype,Tparam,pprop,Tfunam,lab_1]=..
      getvalue(['Set Modelica generic block parameters:';..
		'The Modelica model of this block is defined in a package.';...
		'In variable field the name of the connectors or input/output '+...
		'variables in the Modelica model should be given.';..
		'The type of Modelica connectors: ""I"".';..
		'The type of variables from/to Scicos: ""E"".'],..
	       ['Input/lefthand variables';..
		'Input/lefthand variables types';..
		'Output/righthand variables';..
		'Output/righthand variables types';..
		'Common parameters between Modelica and Scicos';..
		'Parameters properties';..
		'Model name in the package'],..
	       list('str',-1,'str',-1,'str',-1,'str',-1,'str',-1,..
		    'vec',-1,'str',-1),lab_1)
  
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
    eok= eok && execstr(cmd,errcatch=%t);
  end
  eok= eok && execstr("nameF=stripblanks(Tfunam)",errcatch=%t);
  if ~eok then
    // something wrong when evaluating names 
    message("Error in evaluation of variables in block MPBLOCK.")
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
  if or(size(outtype)<>size(out)) then
    message("Output variables are not well defined!");
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
  if nameF=='' then
    message("The model name is not defined!")
    return;
  end
  // 
  //set_io checking
  intypex=find(intype=='I'); 
  outtypex=find(outtype=='I');
  [model,graphics,ok]=set_io(model,graphics,list([ones(size(in)),ones(size(in))],ones(size(in))),..
			     list([ones(size(out)),ones(size(out))],ones(size(out))),..
			     [],[],intypex,outtypex);
  ok = %t;
endfunction

function [ok,cancel,paramv,lab_2]=MPBLOCK_get_parameters_values(param,exprs)
// get parameters values 
  ok=%t;
  paramv=list();
  cancel=%f;
  lab_2 = exprs.paramv;//already a list
  Tparam_lab=param; //labels
  Tparam_sz=size(Tparam_lab,'*'); //numbers of labels
  //adjust size of lab_2 according to size of Tparam
  if Tparam_sz> length(lab_2) then
    for i=1:(Tparam_sz- length(lab_2))
      lab_2($+1)="0"
    end
  elseif Tparam_sz<length(lab_2) then
    lab_2_tmp=list()
    if Tparam_sz<>0 then //if param
      for i=1:Tparam_sz
	ee=evstr(exprs.param)
	for j=1:size(ee,'r')
	  if ee(j)==Tparam_lab(i) then 
	    lab_2_tmp(i)=lab_2(j)
	  end
	end
      end
      lab_2=lab_2_tmp
    end
  end
  // lab_2_tmp=list();ee=evstr(exprs.param);
  // for i=1:Tparam_sz
  //   flg=0;
  //   I= find(ee==Tparam_lab(i));
  //   if isempty(I) then 
  //     lab_2_tmp(i)="0";
  //   else
  //     lab_2_tmp(i)=lab_2(I(1));
  //   end
  // end
  // lab_2=lab_2_tmp;
  //generate lhs, label and rhs txt for getvalue
  if Tparam_sz<>0 then //if param
    lhs_txt = catenate('%v'+string(1:Tparam_sz),sep=',');
    rhs_txt = catenate(smat_create(1,Tparam_sz,'''vec'',-1'),sep=',');
    tag = ['',' (state) ',' (fixed state) '];
    lab_txt = ''''+Tparam_lab+ tag(pprop+1)+ '''';
    lab_txt = catenate(lab_txt,sep=';');
    //generate main getvalue cmd
    //warning here lab_2 is a list in input and a string in output
    getvalue_txt = '[ok,'+lhs_txt+',lab_2]=getvalue(''Set parameters values'',['+..
	lab_txt+'],'+..
	'list('+rhs_txt+'),lab_2)'
    //display the second dialog box
    execstr(getvalue_txt)
    if ~ok then cancel=%t;ok=%t; return;end;
    //restore original lab_2 if not ok
  end
  //put output param in the form of a list in paramv
  if ok then
    paramv=list();
    for i=1:Tparam_sz
      execstr('paramv('+string(i)+')=%v'+string(i))
    end
  end
endfunction


