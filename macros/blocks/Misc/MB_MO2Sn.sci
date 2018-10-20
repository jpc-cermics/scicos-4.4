function [x,y,typ]=MB_MO2Sn(job,arg1,arg2)

  x=[];y=[];typ=[];
  select job
    case 'plot' then
      standard_coselica_draw(arg1);
    case 'getinputs' then
      [x,y,typ]=standard_inputs(arg1)
    case 'getoutputs' then
      [x,y,typ]=standard_outputs(arg1)
    case 'getorigin' then
      [x,y]=standard_origin(arg1)
    case 'set' then
      x=arg1;
      y=acquire('needcompile',def=0);
      execstr('n ='+ arg1.graphics.exprs(1));
      if arg1.model.in >= 1 && arg1.model.in <> n;
	n = arg1.model.in;
	scsm= MB_MO2Sn_define(n);
	x.model.rpar= scsm;
	x.graphics.exprs = string(n);
	y = 4;
      end
      resume(needcompile=y);
    case 'define' then
      scsm= MB_MO2Sn_define(-1);
      model = scicos_model(sim="csuper",in=[-1],in2=[1],intyp=1,out=[-1],
			   out2=[1],outtyp=1,rpar=scsm,blocktype="h");
      // model.equationns = scicos_modelica();
      gr_i=["txt=[""Mo2s""];";
	    "xstringb(orig(1),orig(2),txt,sz(1),sz(2),""fill"")"];
      blk=standard_define([2 2],model,[],gr_i,"MB_MO2Sn");
      // adapt to Modelica 
      blk.graphics('3D') = %f; // coselica options
      blk.graphics.in_implicit='I';
      blk.graphics.out_implicit='E';
      blk.graphics.exprs = string(1);
      x=blk;
  end
endfunction

function scsm= MB_MO2Sn_define(n)
  // creates a new schema
  scsm= instantiate_diagram();
  
  blk_in = INIMPL_f('define');
  blk_in = set_block_size (blk_in, [20,10]);
  blk_in = set_block_origin (blk_in, [0;30]);
  blk_in.model.out = n;
  blk_in.model.out2= 1;
  
  scsm.objs(1)= blk_in;
  
  blk_mo2s = MB_MO2S('define',n);
  blk_mo2s = set_block_size (blk_mo2s, [40,40]);
  blk_mo2s = set_block_origin (blk_mo2s, [50;10]);
  
  scsm.objs(2)=blk_mo2s;
  
  // now a mux
  blk_mux = MUX('define');
  blk_mux.model.in= sign(n)* ones(max(n,1),1);
  blk_mux.model.intyp= ones(max(n,1),1)
  if n > 0 then 
    blk_mux.model.out= n ;
  else
    blk_mux.model.out= -2 ;
  end
  blk_mux.model.outtyp= 1;
  gr_i="blk_draw(sz,orig,orient,model.label)";
  blk_mux =standard_define([10 40],blk_mux.model,string(max(n,1)),gr_i,'MUX')
  blk_mux = set_block_origin (blk_mux, [120,10]);
  scsm.objs(3) =blk_mux;
  
  blk_out = OUT_f('define');
  blk_out = set_block_parameters (blk_out, { "prt", '1' });
  blk_out = set_block_size (blk_out, [20,10])
  blk_out = set_block_origin (blk_out, [200,30]);
  blk_out.model.in2=1;
  blk_out.model.in = n;
  blk_out.model.intyp =1;
  scsm.objs(4)= blk_out;
  
  scsm = add_implicit_link(scsm,['1','1'],['2','1'],[]); 
  for i=1:max(n,1)
    scsm = add_explicit_link(scsm,['2',string(i)],['3',string(i)],[]);
  end
  scsm = add_explicit_link(scsm,['3','1'],['4','1'],[]);
endfunction
