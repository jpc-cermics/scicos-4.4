function [x,y,typ]=MBLOCK(job,arg1,arg2)
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
	[ok,cancel,model,graphics,in,intype,out,outtype,param,paramv,pprop,funam,lab_1]= ...
	MBLOCK_get_parameters(exprs,model,graphics);
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
	  [ok,tt]=MODCOM_NI(funam,tt,in,out,param,paramv,pprop);
	else 
	  [ok,tt]=MODCOM(funam,tt,in,out,param,paramv,pprop);
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
      exprs.out=lab_1(3)
      exprs.outtype=lab_1(4)
      exprs.param=lab_1(5)
      exprs.paramv=list();
      for i=1:size(lab_2,'*')
	exprs.paramv(i)=lab_2(i);
      end
      exprs.pprop=lab_1(6)
      exprs.nameF=lab_1(7)
      exprs.funtxt=tt
      //label(2)=tt
      //------------------
      x.model=model
      graphics.gr_i(1)(1)='txt=[''Modelica'';'' ' + nameF + ' ''];'
    graphics.in_implicit =intype
    graphics.out_implicit=outtype
    //graphics.exprs=label
    graphics.exprs=exprs
    x.graphics=graphics

   case 'define' then
      //----------- Define
      in=['u1']
      intype=['I']
      out=['y1';'y2']
      outtype=['I';'E']
      param=['R';'L'];
      //paramv=[0.1;0.0001];
      paramv=list(0.1,.0001)
      pprop=[0;0];
      nameF='generic'

      exprs = tlist(["MBLOCK","in","intype","out","outtype",...
		     "param","paramv","pprop","nameF","funtxt"],...
		    sci2exp(in(:)),...
		    sci2exp(intype(:)),...
		    sci2exp(out(:)),...
		    sci2exp(outtype(:)),...
		    sci2exp(param(:)),...
		    list(string(0.1),string(.0001)),...
		    sci2exp(pprop(:)),...
		    nameF,m2s([]))

      model=scicos_model()
      model.blocktype='c'
      model.dep_ut=[%f %t]
      //model.rpar=paramv;
      model.rpar=[]
      for i=1:length(paramv)
	model.rpar=[model.rpar; paramv(i)(:)]
      end
      mo=modelica()
      mo.model=nameF
      mo.parameters=list(param,paramv)
      model.sim=list(mo.model,30004)
      mo.inputs=in
      mo.outputs=out
      model.in=ones(size(mo.inputs,'r'),1)
      model.out=ones(size(mo.outputs,'r'),1)
      model.equations=mo
      gr_i=["txt=[""Modelica"";"" "+nameF+" ""];";
	    "xstringb(orig(1),orig(2),txt,sz(1),sz(2),""fill"")"]
      //x=standard_define([3 2],model,label,gr_i,'MBLOCK');
      x=standard_define([3 2],model,exprs,gr_i,'MBLOCK');
      x.graphics.in_implicit =intype
      x.graphics.out_implicit=outtype
  end
endfunction


function [ok,cancel,model,graphics,in,intype,out,outtype,param,paramv,pprop,funam,lab_1]=...
	 MBLOCK_get_parameters(exprs,model,graphics)
  // get parameters 
  cancel=%f;
  in=[],out=[],param=[],paramv=[],pprop=[];intype=[];outtype=[];funam='void';
  lab_1=[];
  //lab_1 = [in,intype,out,outtype,param,nameF]
  lab_1 = list(exprs.in,      
	       exprs.intype,   
	       exprs.out,      
	       exprs.outtype,  
	       exprs.param,    
	       exprs.pprop,    
	       exprs.nameF);
  names_1 = ['Input variables       ';
	     'Input variables types ';
	     'Output variables      ';
	     'Output variables types';
	     'Parameters in Modelica';
	     'Parameters properties ';
	     'Function name         '];
  types_1 = list('str',-1,'str',-1,'str',-1,'str',-1,'str',-1, 'vec',-1,'str',-1);
  [ok,Tin,Tintype,Tout,Touttype,Tparam,pprop,Tfunam,lab_1]=..
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
    eok= eok && execstr(cmd,errcatch=%t);
  end
  eok= eok && execstr("funam=stripblanks(Tfunam)",errcatch=%t);
  if ~eok then
    // something wrong when evaluating names 
    message("Error in evaluation of variables in block MBLOCK.")
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
  [model,graphics,ok]=set_io(model,graphics,list([ones(size(in)),ones(size(in))],ones(size(in))),..
						list([ones(size(out)),ones(size(out))],ones(size(out))),..
						[],[],intypex,outtypex);
  ok = %t;
endfunction

function [ok,cancel,paramv,lab_2]=MBLOCK_get_parameters_values(param,exprs)
  // get parameters values
  // param are the labels,
  // ee=evstr(exprs.param) is also the labels by maybe in a different order
  // exprs.paramv is a list giving th evalues (same order as ee).
  ok=%t;
  paramv=list();
  cancel=%f;
  param_sz=size(param,'*'); //numbers of labels
  exprs_param = evstr(exprs.param);
  // when exprs.param = '[]'; we obtain a wrong type
  if isempty(exprs_param) then exprs_param = m2s([]);end
  // fills lab_2 with values associated to param 
  lab_2 = list();
  for i=1:param_sz
    I= find(exprs_param==param(i));
    if isempty(I) || length(exprs.paramv)<=I(1) then 
      lab_2(i)= "0";
    else
      lab_2(i)= exprs.paramv(I(1));
    end
  end
  //generate lhs, label and rhs txt for getvalue
  if param_sz<>0 then
    // 
    lhs_txt = catenate('%v' + m2s(1:param_sz,"%.0f"),sep= ',');
    rhs_txt = catenate(smat_create(1,param_sz,'''vec'',-1'),sep= ',');
    tag = ['',' (state) ',' (fixed state) '];
    lab_txt = ''''+param+ tag(pprop+1)+ '''';
    lab_txt = catenate(lab_txt,sep= ';');
    //generate main getvalue cmd
    //warning here lab_2 is a list in input and a string in output
    getvalue_txt = '[ok, Lrep, lab_2]=getvalue_list(''Set parameters values'',[' +  ...
		   lab_txt+ '],' + 'list(' + rhs_txt + '),lab_2);';
    //display the second dialog box
    execstr(getvalue_txt)
    if ~ok then cancel=%t;ok=%t; return;end;
    //restore original lab_2 if not ok
  end
  //put output param in the form of a list in paramv
  if ok then
    paramv = Lrep;
  end
endfunction

function [ok,tt]=MODCOM(funam,tt,vinp,vout,vparam,vparamv,vpprop)
  // Copyright INRIA
  [dirF,nameF,extF]=splitfilepath(funam);
  //the new head
  class_txt_new=build_classhead(funam,vinp,vout,vparam,vparamv,vpprop)
  
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
    I =strstr(tt,'////do not modif above this line ////');
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

function class_txt=build_classhead(funam,vinp,vout,vparam,vparamv,vpprop)
  //build_classhead : build the head of the modelica function
  //
  
  //[dirF,nameF,extF]=fileparts(funam);
  [dirF,nameF,extF]=splitfilepath(funam);
  
  ni=size(vinp,'r');   //** number of inputs
  no=size(vout,'r');   //** number of outputs
  np=size(vparam,'r'); //** number of params

  tete1=['model '+nameF]

  //** parameters head
  if np<>0 then
    tete1b= '      //parameters';
    for i=1:np
      //** param
      if vpprop(i)==0 then
	head= '      parameter Real '
	if size(vparamv(i),'*')==1 then
	  head=head+ sprintf('%s = %e;', vparam(i), vparamv(i));
	else
	  head=head+vparam(i)+ '[' + string(size(vparamv(i),'*')) + ']={';
	  for j=1:size(vparamv(i),'*')
	    head=head+sprintf('%e', vparamv(i)(j));
	    if j<>size(vparamv(i), '*') then
	      head=head+ ','
	    end
	  end
	  head=head+ '};'
	end
	//** state
      elseif vpprop(i)==1 then
	head= '      Real           '
	if size(vparamv(i),'*')==1 then
	  head=head+ sprintf('%s (start=%e);', vparam(i), vparamv(i));
	else
	  head=head+vparam(i)+ '['+string(size(vparamv(i),'*'))+ '](start={';
	  for j=1:size(vparamv(i),'*')
	    head=head+sprintf('%e', vparamv(i)(j));
	    if j<>size(vparamv(i),'*') then
	      head=head+ ','
	    end
	  end
	  head=head+ '});'
	end
	//** fixed state
      elseif vpprop(i)==2 then
	head= '      Real           '
	if size(vparamv(i), '*' )==1 then
	  head=head+sprintf('%s (fixed=true,start=%e);', vparam(i), vparamv(i));
	else
	  head=head+vparam(i)+ '['+string(size(vparamv(i), '*'))+ '](start={';
	  P_fix= 'fixed={'
	  for j=1:size(vparamv(i),'*')
	    head=head+sprintf('%e', vparamv(i)(j));
	    P_fix=P_fix+'true'
	    if j<>size(vparamv(i),'*') then
	      head=head+ ','
	      P_fix=P_fix+ ','
	    end
	  end
	  head=head+ '},' +P_fix + '});'
	end
      end
      tete1b=[tete1b
              head]
    end
  else
    tete1b=[];
  end

  //** inputs head
  if ni<>0 then
    tete2= '      Real ';
    for i=1:ni
      tete2=tete2+vinp(i);
      if (i==ni) then  tete2=tete2+ ';'; else  tete2=tete2+ ',';end
    end
    tete2=['      //input variables';
	   tete2];
  else
    tete2=[];
  end
  
  //** outputs head
  if no<>0 then
    tete3= '      Real '
    for i=1:no
      tete3=tete3+vout(i);
      if (i==no) then  tete3=tete3+ ';';else  tete3=tete3+ ',';end
    end
    tete3=['      //output variables';
	   tete3];
  else
    tete3=[];
  end
  
  tete4='  ////do not modif above this line ////'
	//-----------------------------------------
	
	class_txt=[tete1;
		   '  ////automatically generated ////';
		   tete1b;tete2;tete3;tete4]
endfunction

function [ok,tt]=MODCOM_NI(funam,tt,vinp,vout,vparam,vparamv,vpprop)
  // This is the non interactive version used in eval or load 
  //printf('In non interactive MODCOM \n');
  ok = %t;
  // create Modelica dir if it does not exists 
  md =file('join',[getenv('NSP_TMPDIR');'Modelica'])
  if ~file('exists',md) then file('mkdir',md);end 
  // fill the funam file 
  nameF=file('root',file('tail',funam));
  extF =file('extension',funam);
  // tt should be a string and it was initialized to [] in the past.
  if type(tt,'short')=='m' then tt=m2s([]);end 
  if extF=='' then 
    funam1=file('join',[getenv('NSP_TMPDIR');'Modelica';nameF+'.mo']);
    scicos_mputl(tt,funam1);
  elseif ~file('exists',funam) then
    funam1=funam;
    scicos_mputl(tt,funam1);
  end
endfunction

