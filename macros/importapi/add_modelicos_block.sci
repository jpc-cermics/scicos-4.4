function [scs_m,obj_num] = add_modelicos_block(scs_m,blk,identification)
  select blk.gui
    case 'MBM_Add' then
      // blk.graphics.exprs contains
      //params.concatd [ { "Datatype", '-1' } ];
      //params.concatd [ { "sgn", '[+1,-1]' } ];
      //params.concatd [ { "satur", '0' } ];
      // we just collect the signs. We should check th datatype
      // and add saturation if requested
      if %t then
	blk= add_modelicos_mbm_add(blk);
      else
	gains = evstr(blk.graphics.exprs(2));
	blk.graphics.exprs= string(gains)(:);
      end
    case 'MBC_Integrator' then
      // params.concatd [ { "x0", '0' } ];
      // params.concatd [ { "reinit", '0' } ];
      // params.concatd [ { "satur", '0' } ];
      // params.concatd [ { "maxp", '%inf' } ];
      // params.concatd [ { "lowp", '-%inf' } ];
      blk.graphics.exprs= ['1'; blk.graphics.exprs(1)];
    case 'MBS_Constant' then
      // nothing to do same parameters 
      // params.concatd [ { "C", '1' } ];
      // blk.graphics.exprs= blk.graphics.exprs;
    case 'IMPSPLIT_f' then
  end
  blk.graphics.id = identification;
  scs_m.objs($+1) = blk ; // add the object to the data structure
  obj_num = string(length(scs_m.objs))
endfunction

function blk= add_modelicos_mbm_add(blk)
  // generate a block for performing multiple additions
  // using mbm_add as basic block
  gains = evstr(blk.graphics.exprs(2));
  if size(gains,'*') == 2 then
    blk.graphics.exprs= string(gains)(:);
    return;
  else
    super_blk = instantiate_super_block ();
    super_blk = set_block_icon_text (super_blk, blk.graphics.exprs(2));
    super_blk = set_block_bg_color (super_blk, [1, 1, 1]);
    super_blk = set_block_fg_color (super_blk, [0, 0, 0]);
    super_blk = set_block_nin (super_blk,size(gains,'*') );
    super_blk = set_block_nout (super_blk, 1);
    super_blk = set_block_evtnin (super_blk, 0);
    super_blk = set_block_evtnout (super_blk, 0);
    super_blk = set_block_ident (super_blk, blk.graphics.id );
    super_blk = set_block_origin (super_blk, blk.graphics.orig);
    super_blk = set_block_size (super_blk, blk.graphics.sz);
    super_blk = set_block_theta (super_blk, blk.graphics.theta );
    super_blk = set_block_flip (super_blk, ~blk.graphics.flip);
    scsm = instantiate_diagram();
    I= size(gains,'*');
    blk_out = instantiate_block ('OUTIMPL_f');
    blk_out = set_block_parameters (blk_out, { "prt", '1' });
    blk_out = set_block_size (blk_out, blk.graphics.sz);
    xinter = blk.graphics.sz(1);
    yinter = blk.graphics.sz(2);
    top = 2*yinter*I;
    blk_out = set_block_origin (blk_out, [2*xinter + 2*xinter*(I-1); top - 2*yinter*(I-2)]); 
    scsm.objs($+1)= blk_out;
    for i=1:I
      blk_in = instantiate_block ('INIMPL_f');
      blk_in = set_block_size (blk_in, blk.graphics.sz);
      blk_in = set_block_origin (blk_in,[0; top - 2*yinter*(i-2) ]);
      blk_in= set_block_parameters (blk_in, { "prt", string(i) });
      scsm.objs($+1)= blk_in;
    end
    first=blk;
    first.graphics.exprs= string(gains(1:2))(:);
    first.graphics.orig = [2*xinter; top];
    scsm.objs($+1)= first;
    to = length(scsm.objs);
    scsm = add_implicit_link(scsm,['2','1'],[string(to),'1'],[]);
    scsm = add_implicit_link(scsm,['3','1'],[string(to),'2'],[]);
    from= to;
    for j=3:size(gains,'*') do
      new = MBM_Add('define');
      new = set_block_size (new, blk.graphics.sz);
      new = set_block_origin (new, [2*xinter+ 2*xinter*(j-2); top - 2*yinter*(j-2)]);
      new.graphics.exprs=['1';string(gains(j))];
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
  end
endfunction
