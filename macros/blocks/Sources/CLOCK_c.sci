function [x,y,typ]=CLOCK_c(job,arg1,arg2)
  // Copyright INRIA
  // contains a diagram inside
  
  function blk_draw(sz,orig,orient,label)
    wd=xget("wdim").*[1.016,1.12];
    thick=xget("thickness");xset("thickness",2);
    p=wd(2)/wd(1);p=1;
    rx=sz(1)*p/2;ry=sz(2)/2;
    xarcs([orig(1)+0.05*sz(1);
	   orig(2)+0.95*sz(2);
	   0.9*sz(1)*p;
	   0.9*sz(2);
	   0;
	   360*64],scs_color(5));
    xset("thickness",1);
    xx=[orig(1)+rx    orig(1)+rx;
	orig(1)+rx    orig(1)+rx+0.6*rx*cos(%pi/6)];
    yy=[orig(2)+ry    orig(2)+ry ;
	orig(2)+1.8*ry  orig(2)+ry+0.6*ry*sin(%pi/6)];
    xsegs(xx,yy,style=scs_color(10));
    xset("thickness",thick);
  endfunction
  
  x=[];y=[],typ=[]
  select job
    case 'plot' then
      // ident str is to be up.
      standard_draw(arg1,%t,standard_draw_ports,%f,%t);
    case 'getinputs' then
      [x,y,typ]=standard_inputs(arg1)
    case 'getoutputs' then
      [x,y,typ]=standard_outputs(arg1)
    case 'getorigin' then
      [x,y]=standard_origin(arg1)
    case 'set' then
      y=acquire('needcompile',def=0);
      // be sure that exprs is now in block
      [x,changed]=CLOCK_c('upgrade',arg1);
      if changed then y = max(y,2);end
      newpar=list();
      exprs=x.graphics.exprs;
      t0_old=x.model.rpar.objs(2).firing;
      dt_old=x.model.rpar.objs(2).rpar(1);
      while %t do
	[ok,dt,t0,exprs0]=getvalue('Set Clock block parameters',
				   ['Period';'Init time'],list('vec',1,'vec',1),exprs)
	if ~ok then break,end
	if dt<=0 then
	  message('period must be positive')
	  ok=%f
	end
	if ok then
	  x.graphics.exprs=exprs0;
	  x.model.rpar.objs(2).graphics.exprs=exprs0;
	  x.model.rpar.objs(2).model.rpar=[dt;t0]
	  x.model.rpar.objs(2).model.firing=t0;
	  break
	end
      end
      if ~and([t0_old dt_old]==[t0 dt]) then 
	// parameter  changed
	newpar(1)=path; // Notify modification
      end
      if t0_old<>t0 then y=max(y,2);end
      typ=newpar;
      resume(needcompile=y);
      
    case 'define' then
      blk_evtdly=EVTDLY_c('define')
      blk_evtdly.graphics.orig=[320,232]
      blk_evtdly.graphics.sz=[40,40]
      blk_evtdly.graphics.flip=%t
      blk_evtdly.graphics.exprs=['0.1';'0.1']
      blk_evtdly.graphics.pein=6
      blk_evtdly.graphics.peout=3
      blk_evtdly.model.rpar=[0.1;0.1]
      blk_evtdly.model.firing=0.1
      
      blk_output_port=CLKOUT_f('define')
      blk_output_port.graphics.orig=[399,162]
      blk_output_port.graphics.sz=[20,20]
      blk_output_port.graphics.flip=%t
      blk_output_port.graphics.exprs='1'
      blk_output_port.graphics.pein=5
      blk_output_port.model.ipar=1
      
      blk_split=CLKSPLIT_f('define')
      blk_split.graphics.orig=[380.71066;172]
      blk_split.graphics.pein=3,
      blk_split.graphics.peout=[5;6]
      
      diagram=scicos_diagram();
      diagram.objs(1)=blk_output_port   
      diagram.objs(2)=blk_evtdly
      diagram.objs(3)=scicos_link(xx=[340;340;380.71],
				  yy=[226.29;172;172],
				  ct=[5,-1],from=[2,1],to=[4,1])  
      diagram.objs(4)=blk_split
      diagram.objs(5)=scicos_link(xx=[380.71;399],yy=[172;172],
				  ct=[5,-1],from=[4,1],to=[1,1])  
      diagram.objs(6)=scicos_link(xx=[380.71;380.71;340;340],
				  yy=[172;302;302;277.71],
				  ct=[5,-1],from=[4,2],to=[2,1]) 
      x=scicos_block()
      x.gui='CLOCK_c'
      x.graphics.sz=[2,2]
      x.graphics.gr_i=list("blk_draw(sz,orig,orient,model.label)",8);
      x.graphics.peout=0
      x.model.sim='csuper'
      x.model.evtout=1
      x.model.blocktype='h'
      x.model.firing=%f
      x.model.dep_ut=[%f %f]
      x.model.rpar=diagram
      x.graphics.exprs = x.model.rpar.objs(2).graphics.exprs
    case 'upgrade' then
      // upgrade if necessary
     y = %f;
     if ~arg1.graphics.iskey['exprs'] || isempty(arg1.graphics.exprs) then
       // arg1 do not have a correct exprs field
       //compatibility with translated blocks
       exprs =  arg1.model.rpar.objs(2).graphics.exprs;
       x = CLOCK_c('define');
       x.graphics.exprs = exprs;
       x.model.rpar.objs(2).graphics.exprs = exprs;
     else
       x=arg1;
       y=%f;
     end
  end
endfunction
