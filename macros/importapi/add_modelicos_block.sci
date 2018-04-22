function [scs_m,obj_num] = add_modelicos_block(scs_m,blk,identification)
  select blk.gui
    case 'MBM_Add' then
      // blk.graphics.exprs contains
      //params.concatd [ { "Datatype", '-1' } ];
      //params.concatd [ { "sgn", '[+1,-1]' } ];
      //params.concatd [ { "satur", '0' } ];
      // we just collect the signs. We should check th datatype
      // and add saturation if requested
      gains = evstr(blk.graphics.exprs(2));
      blk.graphics.exprs= string(gains)(:);
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

