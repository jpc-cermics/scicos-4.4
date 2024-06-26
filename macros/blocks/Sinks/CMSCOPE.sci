function [x,y,typ]=CMSCOPE(job,arg1,arg2)
// Copyright INRIA
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
    gv_title= 'Set Scope parameters';
    gv_names= [ 'Input ports sizes';
	     'Drawing colors (>0) or mark (<0)';
	     'Output window number (-1 for automatic)';
	     'Output window position';
	     'Output window sizes';
	     'Ymin vector';
	     'Ymax vector';
	     'Refresh period';
	     'Buffer size';
	     'Accept herited events 0/1'
	     'Name of Scope (label&Id)'];
    gv_types = list('vec',-1,'vec',-1,'vec',1,'vec',-1,'vec',-1,...
		 'vec','size(%1,''*'')','vec','size(%1,''*'')','vec',-1,...
		 'vec',1,'vec',1,'str',1);
    model=arg1.model;
    //dstate=model.in
    while %t do
      [ok,in,clrs,win,wpos,wdim,ymin,ymax,per,N,heritance,nom,exprs]= ...
      getvalue(gv_title, gv_names, gv_types, exprs);
      if ~ok then break,end; //user cancel modification
      mess=[]
      if size(in,'*')<=0 then
	mess=[mess;'Block must have at least one input port';' ']
	ok=%f
      end
      if size(wpos,'*')<>0 &size(wpos,'*')<>2 then
	mess=[mess;'Window position must be [] or a 2 vector';' ']
	ok=%f
      end
      if size(wdim,'*')<>0 &size(wdim,'*')<>2 then
	mess=[mess;'Window dim must be [] or a 2 vector';' ']
	ok=%f
      end
      if win<-1 then
	mess=[mess;'Window number can''t be  < -1';' ']
	ok=%f
      end
      if size(per,'*')<>size(ymin,'*') then
	if size(per,'*')==1 then
	  per=per*ones(1,size(ymin,'*'))
	else
	  mess=[mess;'Size of Refresh Period must be consistent with size of Ymin/Ymax vectors';' ']
	  ok=%f
	end
      end
      for i=1:1:size(per,'*')
	if (per(i)<=0) then
	  mess=[mess;'Refresh Period must be positive';' ']
	  ok=%f
	end
      end
      if N<2 then
	mess=[mess;'Buffer size must be at least 2';' ']
	ok=%f
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
	message(['Some specified values are inconsistent:';
	         ' ';mess])
      end
      if ok then
	in = in(:);
	a = size(in,1);
	in2 = ones(a,1);
      	[model,graphics,ok]=set_io(model,graphics,list([in in2],ones(a,1)),list(),ones(1-heritance,1),[]);
      end
      if ok then
	if isempty(wpos) then wpos=[-1;-1];end
	if isempty(wdim) then wdim=[-1;-1];end
	if ok then
	  period=per(:)';
	  yy=[ymin(:)';ymax(:)']
	  rpar=[0;period(:);yy(:)]
	  // 	  clrs=clrs(1:sum(in))
	  ipar=[win;size(in,'*');N;wpos(:);wdim(:);in(:);clrs(:);heritance]
	  //if prod(size(dstate))<>(sum(in)+1)*N+1 then 
	  //dstate=-eye((sum(in)+1)*N+1,1),
	  //end
	  model.evtin=ones(1-heritance,1)
	  model.dstate=[]
	  //model.dstate=dstate;
	  if heritance then 
            model.blocktype='x'
	  else
            model.blocktype='d'
	  end
	  model.rpar=rpar;model.ipar=ipar
	  model.label=nom;
	  graphics.id=nom;
	  graphics.exprs=exprs;
	  x.graphics=graphics;x.model=model
	  //pause;
	  break
	end
      end
    end

  case 'compile' then
   model=arg1
   in=model.in
   ipar=model.ipar
   nu=size(in,'*')
   nc=sum(in)
   clrs=ipar(7+nu+1:$-1)
   nclrs=size(clrs,'*')
   if nclrs>=nc then
    clrs=clrs(1:nc)
   else
    clrs=[clrs;ones(nc-nclrs,1)*clrs($)]
   end
   model.ipar=[ipar(1:7);in;clrs;ipar($)]
   x=model

   case 'define' then
    win=-1;
    in=[1;1]
    wdim=[-1;-1]
    wpos=[-1;-1]
    clrs=[1;3;5;7;9;11;13;15];
    N=20;

    ymin=[-1;-5];ymax=[1;5];per=[30;30];
    yy=[ymin(:)';ymax(:)']
    period=per(:)'
    model=scicos_model()
    model.sim=list('cmscope',4)
    model.in=in
    model.in2=[1;1]
    model.intyp=[1;1]
    model.evtin=[]
    model.rpar=[0;period(:);yy(:)]
    model.ipar=[win;size(in,'*');N;wpos(:);wdim(:);in(:);clrs(1:sum(in))]
    model.blocktype='x'
    model.dep_ut=[%t %f]
    
    exprs=[strcat(string(in),' ');
	   strcat(string(clrs),' ');
	   string(win);
	   sci2exp([]);
	   sci2exp([]);
	   strcat(string(ymin),' ');
	   strcat(string(ymax),' ');
	   strcat(string(per),' ');
	   string(N);
	   string(1);
	   emptystr()];
    gr_i='xstringb(orig(1),orig(2),''MScope'',sz(1),sz(2),''fill'')'
    x=standard_define([2 2],model,exprs,gr_i,'CMSCOPE');
  end
endfunction
