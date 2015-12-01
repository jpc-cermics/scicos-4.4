function [x,y,typ]=ForIterator(job,arg1,arg2)

  function blk_draw(sz,orig,orient,label)
    [x,y,typ]=standard_inputs(o) ;
    dd=sz(1)/16,;
    if ~arg1.graphics.flip then dd=6*sz(1)/8,end;
    zoom=acquire("%zoom",def=1);
    for k=1:size(x,"*");
      if typ(k)==1;
	if k==1 & arg1.graphics.exprs(3)=="1" then
	  txt="n";
	else
	  txt="Next i";
	end;
	rectstr=stringbox(txt,orig(1)+dd,y(k)-4,0,1,1);
	w=(rectstr(1,3)-rectstr(1,2))*zoom;
	h=(rectstr(2,2)-rectstr(2,4))*zoom;
	xstringb(orig(1)+dd,y(k)-4,txt,w,h,"fill");
      end;
    end;
    [x,y,typ]=standard_outputs(o) ;
    dd=6*sz(1)/8,;
    if ~arg1.graphics.flip then dd=sz(1)/16,end;
    for k=1:size(x,"*");
      if arg1.graphics.exprs(1)=="1" then
	txt="1:n";
      else
	txt="0:n-1";
      end;
      rectstr=stringbox(txt,orig(1)+dd,y(k)-4,0,1,1);
      w=(rectstr(1,3)-rectstr(1,2))*zoom;
      h=(rectstr(2,2)-rectstr(2,4))*zoom;
      xstringb(orig(1)+dd,y(k)-4,txt,w,h,"fill");
    end;
    xstringb(orig(1)+2*sz(1)/8,orig(2),["   For  ";"   Iterator   "],sz(1)/2,sz(2),"fill");
  endfunction
  
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
    model=arg1.model;graphics=arg1.graphics;exprs=graphics.exprs
    while %t do
      [ok,init_out,nbre_iter,ext_iter,ext_out,ext_i,iter_dtype,resetstate,exprs]=..
	  getvalue('For Iterator parameters',..
		   ['Initial Output (0 or 1)';
		    'Number of Iteration';
		    'Iteration Source (0=internal 1=External)';
		    'Show iteration variable(0=No 1=Yes)';
		    'Set Next i externally(0=No 1=Yes) if show iteration variable is selected';
		    'Iteration Datatype (1=Double 3=int32 4=int16 5=int8)'
		    'State when starting (0=held 1=reset)'],..
		   list('vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1),exprs);
      if ~ok then break,end
      if and(init_out<>[0,1]) then message('Initial Output must be zero or one');ok=%f;
      elseif and(ext_iter<>[0,1]) then message('Iteration Source must be zero or one');ok=%f;
      elseif and(ext_out<>[0,1]) then message('Show Iteration Variable must be zero or one');ok=%f;    
      elseif and(ext_i<>[0,1]) then message('Set Next i externally must be zero or one');ok=%f;
      elseif (ext_i==1&ext_out==0) then message('Next i can be set only if Show iteration variable is set');ok=%f;
      elseif and(iter_dtype<>[1,3,4,5]) then message('Data type must be one three four five');ok=%f;
      elseif ((nbre_iter<0)|(nbre_iter<>floor(nbre_iter))) then message('Number of Iteration must be an integer greater than 0');ok=%f;
      elseif and(resetstate<>[0,1]) then message('State when starting must be zero or one');ok=%f; 
      end
      if ok then
	inh=ext_iter;
	model.dstate=[];
	old_in=size(model.in,'*');
	old_ext_i=model.ipar;
	out=ones(ext_out,2);
	ot=iter_dtype*ones(size(out,1),1);
	in=[ones(ext_iter,2);ones(ext_i,2)];
	it=iter_dtype*ones(size(in,1),1);
	model.dep_ut=[%f;%f]
	[model,graphics,ok]=set_io(model,graphics,list(in,it),list(out,ot),ones(1-ext_iter,1),[])
	if ok then
	  //if ((size(old_in,'*')<>size(in(:,1),'*')) | old_ext_i<>ext_i) then graphics.pin=zeros(size(in,1),1);end
	  vv=['double','','int32','int16','int8']
	  execstr('model.odstate=list('+vv(iter_dtype)+'(init_out))');
	  graphics.exprs=exprs;
	  model.ipar=ext_i;
	  x.model=model;x.graphics=graphics;
	  break;
	end
      end
    end
   case 'define' then
    model=scicos_model()
    junction_name='foriterator';
    funtyp=4;
    model.sim=list(junction_name,funtyp)

    model.in=[]
    model.in2=[]
    model.intyp=[]

    model.out=1
    model.out2=1
    model.outtyp=1
    model.evtin=1;
    model.evtout=[]
    model.state=[]
    model.dstate=[];
    model.odstate=list(1)
    model.rpar=[]
    model.ipar=0
    model.blocktype='d' 
    model.firing=[]
    model.dep_ut=[%f %f]
    exprs=['1';'5';'0';'1';'0';'1';'0']
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([4 2],model,exprs,gr_i,'ForIterator');
  end
endfunction

