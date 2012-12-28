function [x,y,typ]=DMSCOPE(job,arg1,arg2)
// Copyright INRIA

  function blk_draw(sz,orig,orient,label)  
    // used in C-code to obtain orig and sz;
    xrect(orig(1),orig(2)+sz(2),sz(1),sz(2));
  endfunction
  
  x=[];y=[];typ=[]
  select job
   case 'plot' then
    standard_draw(arg1)
   case 'getinputs' then
    [x,y,typ]=standard_inputs(arg1)
   case 'getoutputs' then
    x=[];y=[];typ=[];
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    titles=['Input ports sizes';
	    'Drawing colors (>0) or mark (<0)';
	    'Ymin vector';
	    'Ymax vector';
	    'Refresh period';
	    'Grid color(>=0) or No(-1)';
	    'Buffer size';
	    'Max number of points to store';
	    'Accept herited events 0/1'];
    while %t do
     [ok,in,clrs,ymin,ymax,per,grid,buffer_size,Npts,heritance,exprs]=getvalue(...
	  'Set Scope parameters',titles,...
	  list('vec',-1,'vec',-1,'vec','size(%1,''*'')','vec','size(%1,''*'')','vec','size(%1,''*'')',...
	       'vec',1,'vec',1,'vec',1,'vec',1),exprs);
      if ~ok then break,end //user cancel modification
      mess=[]
      if size(in,'*')<=0 then
	mess=[mess;'Block must have at least one input port';' ']
	ok=%f
      end
      if size(per,'*')<>size(ymin,'*') then
	mess=[mess;'Size of Refresh Period must equal size of Ymin/Ymax vector';' ']
	ok=%f
      end
      for i=1:1:size(per,'*')
	if (per(i)<=0) then
	  mess=[mess;'Refresh Period must be positive';' ']
	  ok=%f
	end
      end
      if Npts < 10 then
	mess=[mess;'Max number of points must be at least 10';' ']
	ok=%f;
      end
      if or(ymin>=ymax) then
	mess=[mess;'Ymax must be greater than Ymin';' ']
	ok=%f
      end
      if ~or(heritance==[0 1]) then
	mess=[mess;'Accept herited events must be 0 or 1';' ']
	ok=%f
      end
      if ~ok then
	message(['Some specified values are inconsistent:';' ';mess])
      end
      if ok then
	in = in(:);
	a = size(in,1);
	in2 = ones(a,1);
      	[model,graphics,ok]=set_io(model,graphics,list([in in2],ones(a,1)),list(),ones(1-heritance,1),[]);
      end
      if ok then
	period=per(:)';
	yy=[ymin(:)';ymax(:)']
	rpar=[0;period(:);yy(:)];
	ipar=[buffer_size;Npts;grid;size(in,'*');in(:);clrs(:);heritance]
	model.evtin=ones(1-heritance,1)
	model.dstate=[]
	//model.dstate=dstate;
	if heritance then 
	  model.blocktype='x'
	else
	  model.blocktype='d'
	end
	model.rpar=rpar;model.ipar=ipar
	graphics.exprs=exprs;
	x.graphics=graphics;x.model=model
	break;
      end
    end
   case 'compile' then
    model=arg1
    in=model.in
    ipar=model.ipar
    nu=size(in,'*')
    nc=sum(in)
    // [Npts;size(in,'*');in(:);clrs(:);heritance]
    clrs=ipar(4+nu+1:$-1)
    nclrs=size(clrs,'*')
    if nclrs>=nc then
      clrs=clrs(1:nc)
    else
      clrs=[clrs;ones(nc-nclrs,1)*clrs($)]
    end
    model.ipar=[ipar(1:4);in;clrs;ipar($)];
    x=model
   case 'define' then
    win=-1;
    in=[1;1]
    wdim=[-1;-1]
    wpos=[-1;-1]
    clrs=[1;3;5;7;9;11;13;15];
    buffer_size=20;
    Npts = 5000;
    ymin=[-1;-5];ymax=[1;5];per=[30;30];
    yy=[ymin(:)';ymax(:)']
    period=per(:)'
    grid=-1;
    model=scicos_model()
    model.sim=list('dmscope',4)
    model.in=in
    model.in2=[1;1]
    model.intyp=[1;1]
    model.evtin=[]
    model.rpar=[0;period(:);yy(:)]
    model.ipar=[buffer_size;Npts;grid;size(in,'*');in(:);clrs(1:sum(in))];
    model.blocktype='x'
    model.dep_ut=[%t %f]
    
    exprs=[strcat(string(in),' ');
	   strcat(string(clrs),' ');
	   strcat(string(ymin),' ');
	   strcat(string(ymax),' ');
	   strcat(string(per),' ');
	   string(grid);
	   string(buffer_size);
	   string(Npts);
	   string(1)];
    gr_i="blk_draw(sz,orig,orient,model.label)";	
    x=standard_define([2 2],model,exprs,gr_i,'DMSCOPE');
  end
endfunction

