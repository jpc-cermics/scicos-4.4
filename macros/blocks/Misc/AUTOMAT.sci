function [x,y,typ]=AUTOMAT(job,arg1,arg2)
  x=[];y=[];typ=[]
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
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;ipar=model.ipar;
    NMode=evstr(exprs(1));
    NX=evstr(exprs(3))

    non_interactive = scicos_non_interactive();
    while %t do
      CX='C1';
      MSG0='''Jump from Mode '; MSG2=':[..;M_final(Guard=In(';MSG3=').i);..]'''
      MSG=MSG0+'1'+MSG2+'1'+MSG3;
      VEC=list('mat',[-1,1]);
      for i=2:NMode
	CX=CX+','+'C'+string(i);
	MSG=MSG+';'+MSG0+string(i)+MSG2+string(i)+MSG3;
	VEC=list_concat(VEC,'mat',[-1,1]);
      end
      gv_title='Set Finite state machine model';
      execstr('gv_names=['+MSG+']');
      gv_names=['Number (finite-state) Modes';
		'Initial Mode';
		'Number of continuous-time states';
		'Continuous-time states intial values';
		'Xproperties of continuous-time states in each Mode';
		gv_names];
      gv_types=list('vec',1,'vec',1,'vec',1,'mat',[-1,-1],'mat',[-1,-1]);
      gv_types=list_concat(gv_types,VEC);
      GTV='[ok,NMode,Minitial,NX,X0,XP,'+CX+',exprs]=getvalue(gv_title,gv_names,gv_types,exprs)';
      execstr(GTV); if ~ok then break,end
      NMode_old=size(exprs,'*')-5;//-number of fileds before CX
      ModifEncore=%f;
      
      if (NMode_old>NMode) then
	exprs(NMode+6:NMode_old+5)=[];// number of fileds
	ModifEncore=%t;
      end
      if (NMode_old<NMode) then
	exprs(NMode_old+6:NMode+5)=exprs(NMode_old+4);// number of fileds
	ModifEncore=%t;
      end
      if (NX<>size(X0,'*')) then
	message('the size of initial continuous-time states should be NX='+string(NX));
	ModifEncore=%t;
      end
      
      [rXP,cXP]=size(XP)
      if cXP<>NX then 
	message('Xproperty matrix is not valid: it should have NX='+string(NX)+' columns');
	ModifEncore=%t;
      elseif ((rXP<>NMode) & (rXP>1))
	message('Xproperty matrix is not valid: it should have NMode='+string(NMode)+' or 1 row(s)');
	ModifEncore=%t;
      elseif (rXP==1)
	for i=1:NMode-1
	  XP=[XP;XP(1,:)];// xproprties are identical in modes.
	end
      end
      
      if (NMode_old==NMode)&(~ModifEncore) then 
	XP=matrix(XP',NMode*NX,1);// put XP in column vector to be stocked in ipar
	ipar=[NMode;Minitial;NX;XP];
	rpar=matrix(X0,NX,1);// put X0 in a column vector;
	INP=ones(NMode,1);
	if NX>0 then OUT=[2;2*NX];else OUT=[2];end
	MaxModes=1;
	nzcross=0;
	for i=1:NMode
	  Ci=evstr(exprs(5+i));// number of fileds
	  ipar=[ipar;Ci(:)];
	  INP(i,1)=2*NX+length(Ci);
	  if (nzcross<length(Ci)) then 
	    nzcross=length(Ci);
	  end	 
	  if (MaxModes<max(Ci)) then 
	    MaxModes=max(Ci);
	    imax=i;
	  end
	end 
	
	if MaxModes>NMode then 
	  message(['Warning: Number of Modes should be '+string(MaxModes);..
		     'A destination Mode in Mode#'+string(imax)+'''s targets is invalid!']);
	  ModifEncore=%t;
	end
	if MaxModes<NMode then 
	  message(['Warning: There is an unused Mode or the Number of Modes should be '+string(MaxModes)]);
	  ModifEncore=%t;
	end
      end
      if ModifEncore && non_interactive then 
	message(['Error: set failed for AUTOMAT but we are in a non ";
		 '  interactive function and thus we abort the set !']);
	ModifEncore=%f;
      end
      if ~ModifEncore then 
	[model,graphics,ok]=check_io(model,graphics,INP,OUT,[1],[1])
	if ~ok then break,end
	model.nzcross=nzcross;
	model.state=ones(2*NX,1);
	graphics.gr_i(1)(1)='txt=[''Automaton'';''nM='+string(NMode)+',nX='+string(NX)+'''];'
	graphics.exprs=exprs;
	x.graphics=graphics;
	model.ipar=ipar;
	model.rpar=rpar;
	x.model=model;
	break
      end
    end;//while

   case 'define' then
    NMode=2; //number of Modes
    Minitial=1; //initial Mode
    NX=1; //number of states (NX is identical for all Modes)
    X0=[0.0]
    XP=[1;1]//xproperties for each Mode
    C1=[2];//final_Mode after Jump du to in(2*Nx+i)
    C2=[1];
    exprs=[string(NMode);string(Minitial);string(NX);sci2exp(X0);sci2exp(XP);sci2exp(C1);sci2exp(C2)]; 
    ipar=[NMode;Minitial;NX;XP;C1;C2];
    rpar=[X0];

    model=scicos_model()    
    model.sim=list('automat',10004)
    model.in=[2*NX+1;2*NX+1];//number of Modes
    model.out=[2;2*NX];// [Mode;(x,xd)]
    model.state=ones(2*NX,1);// [x;xd]
    model.nzcross=1;// max(taille_zc(Mode_i))
    model.blocktype='c';
    model.evtout=1
    model.evtin=1
    model.firing=0; // -1;
    model.dep_ut=[%f %t];
    model.ipar=ipar;
    model.rpar=rpar;

    gr_i=['txt=[''Automaton'';''nM='+string(NMode)+',nX='+string(NX)+'''];'..
	  ;'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'')']    

    x=standard_define([2.5 2],model,exprs,gr_i,'AUTOMAT');
  end
endfunction

