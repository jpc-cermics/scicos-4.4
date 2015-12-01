function [x,y,typ]=VUMETER(job,arg1,arg2)
// Copyright Enpc
  
  function blk_draw(sz,orig,orient,label)
    xx=[orig(1)+sz(1)/2,orig(1)+sz(1)/2];
    yy=[orig(2)+sz(2)/2,orig(2)+sz(2)];
    xarrows(xx,yy,style=1,arsize=10);//scs_color(10));
    xarc([orig(1),orig(2)+sz(2),sz(1),sz(2),0,180*64],thickness=2,color=ipar(4));
    fnt=xget("font");
    xset("font",ipar(2),ipar(3));
    str = sprintf("%0*.*f" , ipar(5),ipar(6),0.0);
    fz=2*acquire("%zoom",def=1)*4;
    xstring(orig(1)+sz(1)/2,orig(2)+sz(2)/2,str,posx='center',posy='up',size=fz);
    xpoly([orig(1),orig(1)+sz(1)],[orig(2)+sz(2)/2,orig(2)+sz(2)/2],color=ipar(4));
    xset("font",fnt(1),fnt(2));
  endfunction
  
  x=[];y=[];typ=[]
  select job
   case 'plot' then
    ipar=arg1.model.ipar
    dpar=arg1.model.rpar
    standard_draw(arg1,%f,standard_draw_ports,%f,%t);
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
    titles= ['Min range';
	     'Max range';
	     'Display string Yes(1) No(0)';
	     'Font Number';
	     'Font size';
	     'Color';
	     'Total number of digits';
	     'Number of rational part digits';
	     'Block inherits (1) or not (0)'];
    type_list=list('vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1);
    while %t do
      [ok,min_r,max_r,show_text,font,font_size,color,nt,nd,herit,exprs]=...
	  getvalue('Set  parameters', titles, type_list,exprs);
      if ~ok then break,end //user cancel modification
      mess=[]
      if max_r <= min_r then
	mess=[mess;'min range < max range ';' ']
	ok=%f
      end
      if ~ok then
	message(['Some specified values are inconsistent:'; ' ';mess]);
      end
      if ~or(show_text==[0 1]) then
	mess=[mess;'Accept Display string values are 0 and 1';' ']
	ok=%f;
      end
      if ~ok then
	message(['Some specified values are inconsistent:'; ' ';mess])
      end
      if ~or(herit==[0 1]) then
	mess=[mess;'Accept inherited values are 0 and 1';' ']
	ok=%f
      end
      if ~ok then
	message(['Some specified values are inconsistent:'; ' ';mess])
      end
      if ok then
	[model,graphics,ok]=check_io(model,graphics,1,[],ones_new(1-herit,1),[])
      end
      if ok then
	model.ipar= [show_text;font;font_size;color;nt;nd];
	model.rpar=[min_r;max_r];
	model.evtin=ones_new(1-herit,1)
	graphics.exprs=exprs;
	x.graphics=graphics;x.model=model
	break
      end
    end
   case 'define' then
    min_r= 0; max_r= 1;
    color=1;
    nt=5;nd=2;
    show_text=1;
    font =2; font_size=1;
    model=scicos_model()
    model.sim=list('vumeter',4);
    model.in=1
    model.evtin=1
    model.dstate=[1:10]';
    model.rpar=[min_r;max_r]
    model.ipar=[show_text;font;font_size;color;nt;nd];
    model.blocktype='d'
    model.dep_ut=[%t %f]
    
    exprs=[string(min_r);
	   string(max_r);
	   string(show_text);
	   string(font)
	   string(font_size);
	   string(color);
	   string(nt);
	   string(nd);
	  string(0)];
    
    gr_i="blk_draw(sz,orig,orient,model.label)";	
    x=standard_define([2 2],model,exprs,gr_i,'VUMETER');
  end
endfunction


