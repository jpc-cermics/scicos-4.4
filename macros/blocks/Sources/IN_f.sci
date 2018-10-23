function [x,y,typ]=IN_f(job,arg1,arg2)
  // Copyright INRIA
  x=[];y=[];typ=[]
  select job
    case 'plot' then
      // draw Icon 
      orig=arg1.graphics.orig;
      sz=arg1.graphics.sz;
      orient=arg1.graphics.flip;
      //xrect(orig(1),orig(2)+sz(2),sz(1),sz(2),color=9,thickness=4);
      prt=arg1.model.ipar
      color = default_color(1);
      if orient then
	x=orig(1)+sz(1)*[-1/6;-1/6;1/1.5;1;1/1.5]
	y=orig(2)+sz(2)*[0;1;1; 1/2;0]
	xo=orig(1);yo=orig(2)
      else
	x=orig(1)+sz(1)*[0;1/3;7/6;7/6;1/3]
	y=orig(2)+sz(2)*[1/2;1;1;0;0]
	xo=orig(1)+sz(1)/3;yo=orig(2)
      end
      gr_i=arg1.graphics.gr_i;
      if type(gr_i,'short')=='l' then 
	xfpoly(x,y,color=color,thickness=2,fill_color=gr_i(2))
      else
	xfpoly(x,y,color=color,thickness=2);
      end
      xstringb(xo,yo,string(prt),sz(1)/1.5,sz(2),'fill');
      //xstringb(xo,yo,string(prt),sz(1)/1.5,sz(2));
      // Identification 
      ident = arg1.graphics.id
      if ~isempty(ident) && length(ident)<>0 then
	fz=2*acquire("%zoom",def=1)*4;
	xstring(orig(1)+sz(1)/2,orig(2),ident,posx='center',posy='up',size=fz);
      end
      x=[];y=[]
    case 'getinputs' then
      x=[];y=[];typ=[]
    case 'getoutputs' then
      orig=arg1.graphics.orig;
      sz=arg1.graphics.sz;
      orient=arg1.graphics.flip;

      if orient then
	x=orig(1)+sz(1)
	y=orig(2)+sz(2)/2
      else
	x=orig(1)
	y=orig(2)+sz(2)/2
      end
      typ=ones_deprecated(x)
    case 'getorigin' then
      [x,y]=standard_origin(arg1)
    case 'set' then
      y=acquire('needcompile',def=0);
      x=arg1;
      // just in case this is an old bloc
      if size(x.graphics.exprs,'*') <>3 then x = IN_f('update',x);end
      exprs = x.graphics.exprs;
      gv_title = 'Set Input block parameters';
      gv_titles = ['Port number';
		   'Outport Size (-1 for inherit)';
		   'Outport Type (-1 for inherit)'];
      while %t do
	[ok,port_n,size_n,type_n,exprs_n]=getvalue(gv_title, gv_titles,
						   list('vec',1,'vec',-1,'vec',1),exprs);
	if ~ok then return;end
	port_n=int(port_n);
	if port_n <= 0 then
	  message('Port number must be a positive integer');
	elseif size(size_n,'*')<>2 && ~size_n.equal[-1] then
	  message('Outport Size must be a 2 elements vector or -1 for inheritence')
	elseif ((type_n<1 | type_n>9) &(type_n<>-1)) then
	  message('Outport type must be a number between 1 and 9, or -1 for inheritance.')
	else
	  if x.model.ipar<>port_n then y=4;end
	  x.model.ipar=port_n
	  if size(size_n,'*')==2 then
	    x.model.out=size_n(1);
	    x.model.out2=size_n(2)
	  else
	    x.model.out=-1;
	    x.model.out2=-2
	  end
	  x.model.outtyp=type_n;
	  x.graphics.exprs=exprs_n;
	  break
	end
      end
      resume(needcompile=y);
    case 'define' then
      // after define, no silent update needed
      if nargin == 2 then prt=arg1; else prt=1;end
      if nargin == 3 then out=arg2(1);out2=arg2(2);else out=-1; out2=-2;end
      model=scicos_model(sim='input', out=out, out2=out2, outtyp=-1, ipar=prt,
			 blocktype='c', dep_ut=[%f %f]);
      exprs=[sci2exp(prt);'-1';'-1']
      gr_i=" ";
      x=standard_define([1 1],model,exprs,gr_i,'IN_f');
      x.model.ipar = prt;
    case 'update' then
      // build exprs if size is not 3
      x=arg1;
      outsizes = [x.model.out, x.model.out2];
      x.graphics.exprs=[x.graphics.exprs(1);sci2exp(outsizes);sci2exp(x.model.outtyp)]
      x.model.firing=[];
      ok = execstr(sprintf("prti=int(%s);",x.graphics.exprs(1)),errcatch=%t);
      if ok then x.model.ipar= prti;else x.graphics.exprs(1)="1";x.model.ipar=1;end
  end
endfunction
