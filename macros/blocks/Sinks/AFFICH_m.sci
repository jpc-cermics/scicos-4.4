function [x,y,typ]=AFFICH_m(job,arg1,arg2)
// Copyright INRIA

  function str = affich_str(m,n,f)
    str = sprintf("%*.*f" , f(1),f(2),0.0);
    str = strcat(smat_create(1,n,str),' ');
    str  = smat_create(m,1,str);
  endfunction

  function blk_draw(sz,orig,orient,label)
    gin1=max(1,model.in);gin2=max(1,model.in2);
    fnt=xget("font");
    xset("font",ipar(1),ipar(2));
    str = affich_str(gin1,gin2,ipar(5:6)); 
    xstringb(orig(1),orig(2),str,sz(1),sz(2),'fill');
    xset("font",fnt(1),fnt(2));
  endfunction
  
  x=[];y=[];typ=[]
  select job
   case 'plot' then
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
    omodel = arg1.model;
    gv1= ['Input Size',
	  'Font number';
	  'Font size';
	  'Color';
	  'Total number of digits';
	  'Number of rational part digits';
	  'Block inherits (1) or not (0)'];
    gv2=list('mat',[1 2],'vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1);
    // get values through menus 
    while %t do
      [ok,in,font,fontsize,colr,nt,nd,herit,exprs]=getvalue('Set block parameters',..
						  gv1, gv2,exprs);
      if ~ok then break,end //user cancel modification
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
	//[model,graphics,ok]=check_io(model,graphics,1,[],ones(1-herit,1),[])
	[model,graphics,ok]=set_io(model,graphics,...
				   list(in,1),list(),...
				   ones(1-herit,1),[])
      end
      if ok then
	model.ipar=[font;fontsize;colr;xget('window');nt;nd;in(1,1)];
	//model.dstate = [-1;0;0;1;1;zeros(in(1,1)*in(1,2),1)]
	model.evtin=ones(1-herit,1)
	graphics.exprs=exprs;
	//if omodel.in2 <= 1 then graphics.sz(1)=10;end 
	//if omodel.in <= 1 then graphics.sz(2)=10;end 
	if %f then 
	  sz1 = graphics.sz(1)/max(omodel.in2,1);
	  graphics.sz(1)= sz1 *max(1,model.in2);
	  sz2 = graphics.sz(2)/max(omodel.in,1);
	  graphics.sz(2)= sz2 *max(1,model.in);
	end
	x.graphics=graphics;x.model=model
	break
      end
    end
    
   case 'compile'
    model=arg1
    in=[model.in,model.in2]
    model.ipar(7)=in(1,1)
    model.dstate = [-1;0;0;1;1;zeros(in(1,1)*in(1,2),1)]
    x=model
    // we should replot the icon here !
    o1=scs_m(scs_full_path(corinv(arg2)));
    if o1.iskey['gr'] then 
      // XXX Update the graphics if necessary 
      str = affich_str(model.in,model.in2,model.ipar(5:6))
      // o1 is a compound 
      l=o1.gr.children;
      // last is the string 
      grst=l($)
      grst.text = str;
      grst.invalidate[];
    end
   case 'define' then
    font = 1;
    fontsize = 1;
    colr = 1;
    nt = 5;
    nd = 1;
    in = [1 1];
    model = scicos_model();
    model.sim = 'affich2' ;
    model.in = in(1,1);
    model.in2 = in(1,2);
    model.evtin  = 1 ;
    model.dstate = [-1;0;0;1;1;zeros(in(1,1)*in(1,2),1)]
    model.ipar   = [font;fontsize;colr;1000;nt;nd;in(1,1)]
    model.blocktype = 'c' ;
    model.firing = []     ;
    model.dep_ut = [%t %f]
    model.label = '' ;
    model.grp=[1,1];// this is set up at 'compile' time 
    
    exprs = [ sci2exp([model.in model.in2]);
	      string(font);
	      string(fontsize);
	      string(colr);
	      string(nt);
	      string(nd);
	      string(0) ]
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x = standard_define([3 2],model,exprs,gr_i,'AFFICH_m');
  end
endfunction


