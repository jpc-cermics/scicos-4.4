function [scs_m,obj_num] = add_modelicos_block(scs_m,blk,identification)
  // no more used: translations from scicos to modelica are
  // done in scicos
endfunction

function blk= add_modelicos_mbm_add(gains)
  // generate a block for performing multiple additions
  // using mbm_add as basic block
  super_blk = instantiate_super_block ();
  super_blk = set_block_bg_color (super_blk, [1, 1, 1]);
  super_blk = set_block_fg_color (super_blk, [0, 0, 0]);
  super_blk = set_block_nin (super_blk,size(gains,'*') );
  super_blk = set_block_nout (super_blk, 1);
  super_blk = set_block_evtnin (super_blk, 0);
  super_blk = set_block_evtnout (super_blk, 0);
  // super_blk = set_block_ident (super_blk, blk.graphics.id );
  // super_blk = set_block_origin (super_blk, blk.graphics.orig);
  // super_blk = set_block_size (super_blk, blk.graphics.sz);
  // super_blk = set_block_theta (super_blk, blk.graphics.theta );
  // super_blk = set_block_flip (super_blk, ~blk.graphics.flip);
  scsm = instantiate_diagram();
  I= size(gains,'*');
  blk_out = instantiate_block ('OUTIMPL_f');
  blk_out = set_block_parameters (blk_out, { "prt", '1' });
  xinter = 20;
  yinter = 20;
  top = 2*yinter*I;
  blk_out = set_block_origin (blk_out, [3*xinter + 2*xinter*(I-1); top - 2*yinter*(I-2)]); 
  scsm.objs($+1)= blk_out;
  for i=1:I
    blk_in = instantiate_block ('INIMPL_f');
    blk_in = set_block_origin (blk_in,[0; top - 2*yinter*(i-2) ]);
    blk_in= set_block_parameters (blk_in, { "prt", string(i) });
    scsm.objs($+1)= blk_in;
  end
  
  first = MBM_Add('define');
  params = cell (0, 2);
  params.concatd [ { "k1", string(gains(1)) } ];
  params.concatd [ { "k2", string(gains(2)) }];
  first = set_block_parameters (first, params);
  first = set_block_nin (first, 2);
  first = set_block_nout (first, 1);
  first = set_block_evtnin (first, 0);
  first = set_block_evtnout (first, 0);
  first = set_block_flip (first, %f);
  first = set_block_theta (first, 0);
  first = set_block_size (first, [30,30]);
  first = set_block_origin (first, [2*xinter; top]);

  scsm.objs($+1)= first;
  to = length(scsm.objs);
  scsm = add_implicit_link(scsm,['2','1'],[string(to),'1'],[]);
  scsm = add_implicit_link(scsm,['3','1'],[string(to),'2'],[]);
  from= to;
  for j=3:size(gains,'*') do
    new = MBM_Add('define');
    params = cell (0, 2);
    params.concatd [ { "k1", '1' } ];
    params.concatd [ { "k2", string(gains(j)) }];
    new = set_block_parameters (new, params);
    new = set_block_nin (new, 2);
    new = set_block_nout (new, 1);
    new = set_block_evtnin (new, 0);
    new = set_block_evtnout (new, 0);
    new = set_block_flip (new, %f);
    new = set_block_theta (new, 0);
    new = set_block_size (new, [30,30]);
    new = set_block_origin (new, [2*xinter+ 2*xinter*(j-2); top - 2*yinter*(j-2)]);
    scsm.objs($+1)= new;
    to =  length(scsm.objs);
    scsm = add_implicit_link(scsm,[string(from),'1'],[string(to),'1'],[]);
    scsm = add_implicit_link(scsm,[string(j+1),'1'],[string(to),'2'],[]);
    from=to;
  end
  // last link to the output port which is at position 1
  scsm = add_implicit_link(scsm,[string(from),'1'],['1','1'],[]);
  super_blk = fill_super_block (super_blk, scsm);
  blk = super_blk;
endfunction

