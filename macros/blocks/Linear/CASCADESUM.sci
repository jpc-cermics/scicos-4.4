function [x,y,typ]=CASCADESUM(job,arg1,arg2)
  // This is a block used to demonstrate that a csuper can contain
  // a schema which can de redefined as parameters are changed
  // Copyright ENPC

  function CASCADESUM_draw(o,sz,orig)
    [x,y,typ]=standard_inputs(o) 
    dd=sz(1)/8,de=0;
    if ~arg1.graphics.flip then dd=6*sz(1)/8,de=-sz(1)/8,end
    if ~exists("%zoom") then %zoom=1, end;
    fz=2*%zoom*4;
    for k=1:size(x,'*');
      if size(sgn,1) >= k then
	if sgn(k) > 0 then;
	  xstring(orig(1)+dd,y(k)-4,'+',size=fz);
	else;
	  xstring(orig(1)+dd,y(k)-4,'-',size=fz);
	end;
      end;
    end;
    xx=sz(1)*[.8 .4 0.75 .4 .8]+orig(1)+de;
    yy=sz(2)*[.8 .8 .5 .2 .2]+orig(2);
    xpoly(xx,yy,type='lines');
  endfunction
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    sgn=arg1.model.ipar
    standard_draw(arg1)
   case 'getinputs' then
    [x,y,typ]=standard_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=standard_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    exprs=x.graphics.exprs
    gv_title ="Set sum block parameters";
    gv_titles="sign vector (of +1, -1)";
    while %t do
      [ok,sgn,exprs]=getvalue(gv_title, gv_titles, list('vec',-1), exprs);
      if ~ok then return;end // cancel in getvalue;
      sgn=sgn(:);
      if ~and(abs(sgn)==1) then
	message('Signs can only be +1 or -1')
	continue;
      else
	in= ones(size(sgn,1),1);in2=in
	nout=1;nout2=2
      end
      it=ones(1,size(in,1));
      ot=1;
      [model,graphics,ok]=set_io(x.model,x.graphics,...
				 list([in,in2],it),...
				 list([nout,nout2],ot),[],[]);
      if ok then break;end 
    end
    x.model = model;
    x.graphics = graphics;
    if ~x.model.ipar.equal[sgn] then
      scsm= CASCADESUM_define(sgn);
      resume(needcompile=4);
      y=4;
      x.model.rpar = scsm;
    end
    x.model.ipar=sgn;
    x.graphics.exprs = exprs;
   case 'compile' then
    // 
    model=arg1
    satur=model.rpar
    model.rpar=[]
    Datatype=model.outtyp(1)
    Dt=["","_z","i32","i16","i8","ui32","ui16","ui8"];
    Tag=["n","s","e"];
    if Datatype==1 then 
      model.sim=list('summation',4)
    elseif Datatype==2 then
      model.sim=list('summation_z',4)
    elseif Datatype>8 then
      error("Datatype is not supported");
    else
      simstr=sprintf('summation_%s%s',Dt(Datatype),Tag(satur+1))
      model.sim=list(simstr,4);
    end
    x=model
    
   case 'define' then
     sgn=[1;-1];
     scsm= CASCADESUM_define(sgn);
     model=scicos_model()
     model.rpar=scsm;
     model.sim='csuper';
     model.in=[1;1]
     model.out=1;
     model.in2=[1;1]
     model.out2=1;
     model.ipar=sgn
     model.blocktype='h'; // 'c'
     model.dep_ut=[%t %f]
     exprs=sci2exp(sgn);
     gr_i=['CASCADESUM_draw(o,sz,orig);'];
     x=standard_define([2 3],model, exprs,gr_i,'CASCADESUM');
  end
endfunction

function scsm= CASCADESUM_define(signs,coselica=%f)
  // generate a block for performing multiple additions
  // using mbm_add as basic block
  if coselica then
    OUTBLK='OUTIMPL_f'; INBLK = 'INIMPL_f'; ADDER = 'MBM_Add';
  else
    OUTBLK='OUT_f'; INBLK = 'IN_f'; ADDER = 'SUMMATION';
  end
  graphics_szf=1; xinter = 40; yinter = 40;
  
  scsm = instantiate_diagram();
  I= size(signs,'*');
  blk_out = instantiate_block (OUTBLK);
  blk_out = set_block_parameters (blk_out, { "prt", '1' });
  blk_out = set_block_size (blk_out, graphics_szf*blk_out.graphics.sz);
  top = 2*yinter*I;
  blk_out = set_block_origin (blk_out, [2*xinter + 2*xinter*(I-1); top - 2*yinter*(I-2)]); 
  scsm.objs($+1)= blk_out;
  for i=1:I
    blk_in = instantiate_block (INBLK);
    blk_in = set_block_size (blk_in,  graphics_szf*blk_in.graphics.sz);
    blk_in = set_block_origin (blk_in,[0; top - 2*yinter*(i-2) ]);
    blk_in= set_block_parameters (blk_in, { "prt", string(i) });
    scsm.objs($+1)= blk_in;
  end
  
  first = instantiate_block (ADDER); // MBM_Add('define');
  if coselica then 
    params = cell (0, 2);
    params.concatd [ { "k1", string(signs(1)) } ];
    params.concatd [ { "k2", string(signs(2)) }];
  else
    params = cell (0, 2);
    params.concatd [ { "data", string(1) } ];
    params.concatd [ { "signs", sci2exp([signs(1);signs(2)])} ];
    params.concatd [ { "satur", string(0) }];
  end
  first = set_block_parameters (first, params);
  first = set_block_nin (first, 2);
  first = set_block_nout (first, 1);
  first = set_block_evtnin (first, 0);
  first = set_block_evtnout (first, 0);
  first = set_block_flip (first, %f);
  first = set_block_theta (first, 0);
  first = set_block_size (first,  graphics_szf*first.graphics.sz);
  first = set_block_origin (first, [2*xinter; top]);

  scsm.objs($+1)= first;
  to = length(scsm.objs);
  scsm = add_implicit_link(scsm,['2','1'],[string(to),'1'],[]);
  scsm = add_implicit_link(scsm,['3','1'],[string(to),'2'],[]);
  from= to;
  for j=3:size(signs,'*') do
    new = instantiate_block (ADDER);
    if coselica then 
      params = cell (0, 2);
      params.concatd [ { "k1", '1' } ];
      params.concatd [ { "k2", string(signs(j)) }];
    else
      params = cell (0, 2);
      params.concatd [ { "data", string(1) } ];
      params.concatd [ { "signs", sci2exp([1;signs(j)])} ];
      params.concatd [ { "satur", string(0) }];
    end
    new = set_block_parameters (new, params);
    new = set_block_nin (new, 2);
    new = set_block_nout (new, 1);
    new = set_block_evtnin (new, 0);
    new = set_block_evtnout (new, 0);
    new = set_block_flip (new, %f);
    new = set_block_theta (new, 0);
    new = set_block_size (new,  graphics_szf*new.graphics.sz);
    new = set_block_origin (new, [2*xinter+ 2*xinter*(j-2); top - 2*yinter*(j-2)]);
    scsm.objs($+1)= new;
    to =  length(scsm.objs);
    scsm = add_implicit_link(scsm,[string(from),'1'],[string(to),'1'],[]);
    scsm = add_implicit_link(scsm,[string(j+1),'1'],[string(to),'2'],[]);
    from=to;
  end
  // last link to the output port which is at position 1
  scsm = add_implicit_link(scsm,[string(from),'1'],['1','1'],[]);
  scsm=do_silent_eval(scsm);
endfunction
