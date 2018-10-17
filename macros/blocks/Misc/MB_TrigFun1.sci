function [x,y,typ]=MB_TrigFun1(job,arg1,arg2)
  // A modelica block for non-scalar trig functions
  
  function blk_draw(sz,orig,orient,label)
    blue=xget('color','blue');
    white=xget('color','white');
    black=xget('color','black');
    gray=xget('color','gray');
    red = xget('color','red');
    if orient then
      xx=orig(1);yy=orig(2);
      ww=sz(1);hh=sz(2);
    else
      xx=orig(1)+sz(1);yy=orig(2);
      ww=-sz(1);hh=sz(2);
    end
    // frame 
    if orient then
      xrect(orig(1)+sz(1)*0,orig(2)+sz(2)*1,sz(1)*1,sz(2)*1,color=blue,background=white);
    else
      xrect(orig(1)+sz(1)*(1-0-1),orig(2)+sz(2)*1,sz(1)*1,sz(2)*1,color=blue,background=white);
    end
    // label 
    if orient then
      xstringb(orig(1)+sz(1)*-0.25,orig(2)+sz(2)*1.05,label,sz(1)*1.5,sz(2)*0.2,"fill");
    else
      xstringb(orig(1)+sz(1)*(1--0.25-1.5),orig(2)+sz(2)*1.05,label,sz(1)*1.5,sz(2)*0.2,"fill");
    end    
    xpoly(xx+ww*[0.1;0.1],yy+hh*[0.84;0.1],color=gray);
    xfpoly(xx+ww*[0.1;0.06;0.14;0.1],yy+hh*[0.95;0.84;0.84;0.95],color=gray,fill_color=gray);
    xpoly(xx+ww*[0.05;0.91],yy+hh*[0.15;0.15],color=gray);
    xfpoly(xx+ww*[0.95;0.84;0.84;0.95],yy+hh*[0.15;0.19;0.11;0.15],color=gray,fill_color=gray);
    xv = linspace(0,2*%pi,20);yv = sin(xv);
    xv = 0.1 + 0.8* (xv - min(xv)) ./ (max(xv) -min(xv)) 
    yv = 0.15 + 0.8* (yv - min(yv)) ./ (max(yv) -min(yv)) 
    xpoly(xx+ww*xv,yy+hh*yv,color=blue);
    if orient then
       xstringb(orig(1)+sz(1)*-0.25,orig(2)+sz(2)*-0.25,C,sz(1)*1.5,sz(2)*0.2,"fill");
    else
       xstringb(orig(1)+sz(1)*(1--0.25-1.5),orig(2)+sz(2)*-0.25,C,sz(1)*1.5,sz(2)*0.2,"fill");
    end
  endfunction
  
  x=[];y=[];typ=[];
  select job
    case 'plot' then
      // get string inside list(str);
      C = "sin";
      standard_coselica_draw(arg1);
    case 'getinputs' then
      [x,y,typ]=standard_inputs(arg1)
    case 'getoutputs' then
      [x,y,typ]=standard_outputs(arg1)
    case 'getorigin' then
      [x,y]=standard_origin(arg1)
    case 'set' then
      x=arg1;
      // get string inside list(str);
      value= "sin";
      gv_titles='Set MB_TrigFun1 block parameters';
      gv_names=['trigonometric function'];
      gv_types = list('str',-1);
      [ok,C, value_n]=getvalue(gv_titles,gv_names,gv_types,value);
      if ~ok then return;end; // cancel in getvalue;
      if ~value_n.equal[value] then 
	// x= MB_TrigFun1_define(-1,value_n,x);
      end
    case 'define' then
      x= MB_TrigFun1_define (-1,'sin');
    case 'compile'
      pause MB_TrigFun1_compile
      x=arg1;
  end
endfunction

function blk=MB_TrigFun1_define (n,fname,old)
  // define or update a MB_TrigFun1;
  
  if nargin <= 2 then 
    global(modelica_count=0);
    nameF='generic'+string(modelica_count);
    modelica_count =       modelica_count +1;
  else
    nameF=old.graphics.exprs.nameF;
  end

  // first: define or redefine the VMBLOCK;
  // n can be negative !
  
  H=hash(in=["u"], intype="I", in_r=[n], in_c=[1],
	 out=["y"], outtype="I", out_r=[n], out_c=[1],
	 param=[], paramv=list(), pprop=[], nameF=nameF);
  
  txt=VMBLOCK_classhead(H.nameF,H.in,H.intype,[H.in_r,H.in_c],H.out,H.outtype,[H.out_r,H.out_c],H.param,H.paramv,H.pprop)
  txt.concatd["  equation"];
  if n > 0 then 
    if n==1 then
      txt.concatd["    y.signal= C;"];
    else
      for i=1:n
	txt.concatd[sprintf("    y[%d].signal= %s(u[%d].signal);",i,fname,i)];
      end
    end
  else
    txt.concatd[sprintf("    y[:].signal= %s(u[:].signal);",fname)];
  end
  txt.concatd[sprintf("end %s;", nameF)];
    
  H.funtxt = txt;
  
  if nargin == 3 then 
    vmblock = VMBLOCK_define(H,old.model.rpar.objs(3));
  else
    vmblock = VMBLOCK_define(H);
  end
  vmblock.graphics('3D') = %f; // coselica options 
  vmblock.model.in = n;
  vmblock.model.out = n;
  
  scs_m = instantiate_diagram ();

  blk = instantiate_block("INIMPL_f");
  exprs= [ "1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nout (blk, 1);
  blk = set_block_origin (blk, [    50,160 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_1] = add_block(scs_m, blk);
  blk = instantiate_block("OUTIMPL_f");
  exprs= [ "1" ]

  blk=set_block_exprs(blk,exprs);
  blk = set_block_bg_color (blk, 8);
  blk = set_block_nin (blk, 1);
  blk = set_block_origin (blk, [   230,160 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_2] = add_block(scs_m, blk);
  
  blk = vmblock;
  blk = set_block_origin (blk, [   140,150 ]);
  blk = set_block_size (blk, [   40,40 ]);
  [scs_m, block_tag_3] = add_block(scs_m, blk);
  
  points=mat_create(0,0)
  [scs_m,obj_num] = add_implicit_link (scs_m, [block_tag_1, "1", "output"],
				       [block_tag_3, "1", "input"], points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_implicit_link (scs_m, [block_tag_3, "1", "output"],
				       [block_tag_2, "1", "input"], points);

  model = scicos_model(sim="csuper",in=[-1],in2=[1],intyp=1,out=[-1],
		       out2=[1],outtyp=1,rpar=scs_m,blocktype="h");
  gr_i=list("blk_draw(sz,orig,orient,model.label)",xget('color','blue'));
  blk=standard_define([2 2],model,[],gr_i,"MB_TrigFun1");
  // adapt to Modelica 
  blk.graphics('3D') = %f; // coselica options
  blk.graphics.in_implicit='I';
  blk.graphics.out_implicit='I';
endfunction
