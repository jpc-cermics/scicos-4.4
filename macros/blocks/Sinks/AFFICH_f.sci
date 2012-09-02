function [x,y,typ]=AFFICH_f(job,arg1,arg2)
// Copyright INRIA

  function str = affich_str(m,n,f)
    str = sprintf("%*.*f" , f(1),f(2),0.0);
    str = strcat(smat_create(1,n,str),' ');
    str  = smat_create(m,1,str);
  endfunction

  function blk_draw(sz,orig,orient,label)
    gin1=max(1,model.in);gin2=1;
    fnt=xget("font");
    xset("font",ipar(1),ipar(2));
    str = affich_str(gin1,gin2,ipar(5:6)); 
    xstringb(orig(1),orig(2),str,sz(1),sz(2));
    xset("font",fnt(1),fnt(2));
  endfunction

  x=[];y=[];typ=[]
  select job
   case 'plot' then
    arg1.graphics.gr_i(1)="blk_draw(sz,orig,orient,model.label)"
    ipar = arg1.model.ipar
    standard_draw(arg1)
   case 'getinputs' then
    [x,y,typ]=standard_inputs(arg1)
   case 'getoutputs' then
    x=[];y=[];typ=[];
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x = arg1;
    graphics = arg1.graphics; exprs = graphics.exprs
    model = arg1.model;
    if size(exprs,'*')==5 then exprs(6)='0';end //compatibility
    if size(exprs,'*')==4 then exprs(4)=' ';exprs(5)=' ';end //compatibility
    if size(model.dstate,'*')<>6 then model.dstate=[0;-1;0;0;1;1];end //compatibility
    while %t do
      [ok,font,fontsize,colr,nt,nd,herit,exprs]=getvalue(..
						  'Set  parameters',..
						  ['Font number';
		    'Font size';
		    'Color';
		    'Total number of digits';
		    'Number of rational part digits';
		    'Block inherits (1) or not (0)'],..
						  list('vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1),exprs)
      if ~ok then break,end //user cancel modification
      //** ------------------------ Error checking ----------------------------------
      mess = [] ; //** no message
      if font<=0 then
	mess=[mess;'Font number must be positive';' ']
	ok=%f
      end
      if fontsize<=0 then
	mess=[mess;'Font size must be positive';' ']
	ok=%f
      end
      if nt<=3 then
	mess=[mess;'Total number of digits must be greater than 3';' ']
	ok=%f
      end
      if nd<0 then
	mess=[mess;'Number of rational part digits must be '
	      'greater or equal 0';' ']
	ok=%f
      end
      if ~ok then
	message(['Some specified values are inconsistent:';
		 ' ';mess]);
      end
      if ~or(herit==[0 1]) then
	mess=[mess;'Accept inherited values are 0 and 1';' ']
	ok=%f
      end
      if ~ok then
	message(['Some specified values are inconsistent:';
		 ' ';mess])
      end
      //** Positive case ->
      if ok then
	[model,graphics,ok]=check_io(model,graphics,1,[],ones(1-herit,1),[])
      end
      if ok then
	model.ipar=[font;fontsize;colr;xget('window');nt;nd];
	model.evtin=ones(1-herit,1)
	graphics.exprs=exprs;
	x.graphics=graphics;x.model=model
	break
      end
    end
   case 'define' then
    font = 1     ; //** 1 --> greek font 
    fontsize = 1 ; //** 1
    colr = 1 ;
    nt = 9   ;
    nd = 2   ;
    exprs = [ string(font);
	      string(fontsize);
	      string(colr);
	      string(nt);
	      string(nd);
	      string(0) ]
    
    model = scicos_model(); 
    model.sim = 'affich' ; 
    model.in = 1 ;
    model.evtin  = 1 ;
    model.dstate = [0;-1;0;0;1;1]
    model.ipar   = [font;fontsize;colr;1000;nt;nd]
    model.blocktype = 'c' ;
    model.firing = []     ;
    model.dep_ut = [%t %f]
    model.label = '' ;
    gr_i="blk_draw(sz,orig,orient,model.label)";	
    x = standard_define([3 2],model,exprs,gr_i,'AFFICH_f');
  end

endfunction
