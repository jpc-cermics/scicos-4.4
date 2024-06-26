function [x,y,typ]=CMAT3D(job,arg1,arg2)
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
    graphics=arg1.graphics;
    exprs=graphics.exprs
    if size(exprs,"*")<7 then
      exprs=[exprs;"35";"45"] //backward compatibility
    end
    model=arg1.model;
    gv_titles=['Bounds Vector X (-1 for standard)';
	       'Bounds Vector Y (-1 for standard)';
	       'ColorMap';
	       'Zmin';
	       'Zmax'
	       'Alpha';
	       'Theta'];
    gv_types=list('vec',-1,'vec',-1,'vec',-1,'vec',1,'vec',1,'vec',1,'vec',1);
    
    while %t do
      [ok,vec_x,vec_y,colormap,cmin,cmax,al,th,exprs]=getvalue('Set Scope parameters',...
						  gv_titles,gv_types,exprs);
      if ~ok then return;end //user cancel modification
      mess=[]
      if size(vec_x,'*')<>size(vec_y,'*') then
	message(['Vector X and Vector Y must have the same size']);
	continue;
      end
      if cmax<=cmin then
	message(['Error Zmax should be greater than Zmin']);
	continue;
      end
      break;
    end
    size_x = size(vec_x,'*');
    size_c=size(colormap,1);
    ipar=[cmin;cmax;size_c;size_x];
    rpar=[colormap(:);vec_x(:);vec_y(:)];
    model.ipar=ipar;
    model.rpar=rpar;
    model.opar=list(al,th)
    graphics.exprs=exprs;
    x.graphics=graphics;
    x.model=model;
   case 'define' then
    cmin = 0;
    cmax = 100;
    colormap = jetcolormap(25);
    size_c = 25;
    x=-1;
    y=-1;
    size_x = 1;
    size_y = 1;
    al=35;
    th=45;

    model=scicos_model()
    model.sim=list('cmat3d',4)
    model.in=-1
    model.in2=-2
    model.intyp=1
    model.evtin=1
    model.ipar=[cmin;cmax;size_c;size_x;size_y]
    model.rpar=[colormap(:);x;y]
    model.opar=list(al,th)
    model.blocktype='c'
    model.dep_ut=[%t %f]
    
    exprs=[strcat(string(x),' ');
	   strcat(string(y),' ');
	   string('jetcolormap(25)');
	   string(cmin);
	   string(cmax)];
    gr_i='xstringb(orig(1),orig(2),''Mat. 3D'',sz(1),sz(2),''fill'')'
    x=standard_define([2 2],model,exprs,gr_i,'CMAT3D')
  end
endfunction
