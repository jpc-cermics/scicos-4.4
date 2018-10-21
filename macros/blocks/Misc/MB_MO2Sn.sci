function [x,y,typ]=MB_MO2Sn(job,arg1,arg2)

  function blk_draw(o,sz,orig,orient)
    blue=xget('color','blue');
    dim = sci2exp(o.model.in);
    if orient then
      xx=orig(1)+[0 1 0 0]*sz(1);
      yy=orig(2)+[0 1/2 1 0]*sz(2);
      x1=0
    else
      xx=orig(1)+[0   1 1 0]*sz(1);
      yy=orig(2)+[1/2 0 1 1/2]*sz(2);
      x1=1/2;
    end
    xpoly(xx,yy,type='lines',color=blue,thickness=3);
    if orient then
      xstring(orig(1),orig(2),dim,fill=%t,w=sz(1)/2,h=sz(2),posx='center',posy='center');
    else
      xstring(orig(1)+sz(1)/2,orig(2),dim,fill=%t,w=sz(1)/2,h=sz(2),posx='center',posy='center');
    end
  endfunction
  
  x=[];y=[];typ=[];
  select job
    case 'plot' then
      standard_coselica_draw(arg1,%f);
    case 'getinputs' then
      [x,y,typ]=standard_inputs(arg1)
    case 'getoutputs' then
      [x,y,typ]=standard_outputs(arg1)
    case 'getorigin' then
      [x,y]=standard_origin(arg1)
    case 'set' then
      x=arg1;
      y=acquire('needcompile',def=0);
      exprs = arg1.graphics.exprs(1);
      execstr('n ='+ exprs);
      while %t do
	[ok,n_new,exprs_new]=getvalue('Set MB_MO2S block parameters',
				      'length of input vector (or -1)',list('vec',-1),exprs)
	if ~ok then;return;end;
	if n_new < -1 || n_new == 0 then
	  message("Errro: length should be positive or equal to -1");
	end
	if n_new <> n then
	  scsm= MB_MO2Sn_define(n_new);
	  x.model.rpar = scsm;
	  x.graphics.exprs(1) = sci2exp(n_new);
	  x.model.in = n_new;
	  x.model.out = n_new;
	  y = 4;
	end
	break;
      end
      resume(needcompile=y);
    case 'define' then
      if nargin == 2 then n=arg1;else n=-1;end 
      scsm= MB_MO2Sn_define(n);
      model = scicos_model(sim="csuper",in=[-1],in2=[1],intyp=1,out=[-1],
			   out2=[1],outtyp=1,rpar=scsm,blocktype="h");
      // model.equationns = scicos_modelica();
      gr_i=list("blk_draw(o,sz,orig,orient)",xget('color','white'))
      x=standard_define([1 1],model,[],gr_i,"MB_MO2Sn");
      // adapt to Modelica 
      x.graphics('3D') = %f; // coselica options
      x.graphics.in_implicit='I';
      x.graphics.out_implicit='E';
      x.graphics.exprs = string(n);
  end
endfunction

function scsm= MB_MO2Sn_define(n)
  // creates a new schema
  scsm= instantiate_diagram();
  
  blk_in = INIMPL_f('define');
  blk_in = set_block_size (blk_in, [20,10]);
  blk_in = set_block_origin (blk_in, [0;30]);
  // to be sure that silent eval will keep port, [in,in2, intyp
  blk_in.graphics.exprs=["1";sci2exp([n,1]);"1"];
  scsm.objs(1)= blk_in;
  
  // now a mux
  blk_mux = MUX('define');
  blk_mux.model.intyp= ones(max(n,1),1)
  blk_mux.model.outtyp= 1;
  blk_mux.graphics.exprs = string(max(n,1));
  blk_mux = set_block_size (blk_mux, [10,40]);
  blk_mux = set_block_origin (blk_mux, [120,10]);
  scsm.objs(2) =blk_mux;
  
  blk_out = OUT_f('define');
  blk_out = set_block_parameters (blk_out, { "prt", '1' });
  blk_out = set_block_size (blk_out, [20,10])
  blk_out = set_block_origin (blk_out, [200,30]);
  // to be sure that silent eval will keep port, [in,in2, intyp
  blk_out.graphics.exprs=["1";sci2exp([1,n]);"1"];
  scsm.objs(3)= blk_out;

  // need to make a silent eval before adding links
  // take care that MB_S2MO is to be excluded from this silent_eval
  scsm=do_silent_eval(scsm);

  // we know the insize/outsize of mux when n is positive 
  if n > 0 then
    scsm.objs(2).model.out = n;
    scsm.objs(2).model.outtyp = 1;
    scsm.objs(2).model.in =  ones(n,1);
    scsm.objs(2).model.intyp = ones(n,1);
  end
  
  blk_mo2s = MB_MO2S('define',n);
  blk_mo2s = set_block_size (blk_mo2s, [40,40]);
  blk_mo2s = set_block_origin (blk_mo2s, [50;10]);
  scsm.objs(4)=blk_mo2s;

  scsm = add_implicit_link(scsm,['1','1'],['4','1'],[]); 
  for i=1:max(n,1)
    scsm = add_explicit_link(scsm,['4',string(i)],['2',string(i)],[]);
  end
  scsm = add_explicit_link(scsm,['2','1'],['3','1'],[]);
  //scsm= do_silent_eval(scs_m);
endfunction
