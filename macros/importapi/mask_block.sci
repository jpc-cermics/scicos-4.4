function out = mask_block(blk,sblkctx,sblkparams,sblkdesc)
  
  function rep = context_is_empty(ctx)
    rep = size(ctx,'*') == 0 || sum(length(ctx))==0;
  endfunction

  if blk.gui.equal['OUT_f'] || blk.gui.equal['IN_f'] then
    // do not mask in or out 
    out=blk;
    return;
  end
  
  if context_is_empty(sblkctx) && size(sblkparams,'r')==0 then
    out = blk;
    return;
  end
  sblk=instantiate_super_block ()
  //pos=blk.position ? 
  pos = blk.graphics.orig;
  name="maskedBlock"
  sz=blk.graphics.sz
  scsm0 = instantiate_diagram ();
  [scsm0,blktag] = add_block (scsm0, blk, name);
  
  nin= size(blk.model.in,1);
  nout= size(blk.model.out,1);
  nevout= size(blk.model.evtout,1);
  nevin= size(blk.model.evtin,1);
  
  for i=1:nin do
    blk0 = instantiate_block ("IN_f");// system/Ports/Input");
    params = cell (0, 2);
    // params.concatd[{"prt", '1'}];
    params.concatd[{"portNumber",string(i)}];
    params.concatd[{"outsize","[-1,-2]"}];
    params.concatd[{"outtyp","""inherit"""}];
    params.concatd[{"dept","0"}];
    blk0 = set_block_parameters (blk0, params);
    blk0 = set_block_size (blk0, [15, 10]);
    blk0 = set_block_nin (blk0, 0);
    blk0 = set_block_nout (blk0, 1);
    blk0 = set_block_flip (blk0, 0);
    blk0 = set_block_origin (blk0, [pos(1)-50, pos(2)+20*(i-1)]);
    blk0.angle=0;
    [scsm0, block_tag0]= add_block (scsm0, blk0, "in"+ string(i));
    scsm0 = add_explicit_link (scsm0, [block_tag0, "1"], [blktag, string(i)], []);
  end

  for i=1:nout do
    blk0 = instantiate_block ("OUT_f");//system/Ports/Output");
    params = {};
    params.concatd[{"portNumber","1"}];
    blk0 = set_block_parameters (blk0, params);
    blk0 = set_block_size (blk0, [15, 10]);
    blk0 = set_block_nin (blk0, 1);
    blk0 = set_block_nout (blk0, 0);
    blk0 = set_block_flip (blk0, 0);
    blk0 = set_block_origin (blk0, [pos(1)+sz(1)+50, pos(2)+20*(i-1)]);
    blk0.angle=0;
    [scsm0, block_tag0] = add_block (scsm0, blk0, "out"+ string(i));
    scsm0 = add_explicit_link (scsm0, [blktag, string(i)], [block_tag0, "1"], []);
  end

  for i=1:nevin do
    blk0 = instantiate_block ("CLKINV_f");//system/Ports/EventInput");
    params = {};
    params.concatd[{"portNumber","1"}];
    blk0 = set_block_parameters (blk0, params);
    blk0 = set_block_size (blk0, [15, 10]);
    blk0 = set_block_nin (blk0, 0);
    blk0 = set_block_nout (blk0, 0);
    blk0 = set_block_evtnin (blk0, 1);
    blk0 = set_block_flip (blk0, 0);
    blk0 = set_block_origin (blk0, [pos(1)+20*(i-1), pos(2)-50]);
    blk0.angle=0;
    [scsm0, block_tag0]= add_block (scsm0, blk0, "evin"+string(i));
    scsm0 = add_event_link (scsm0, [block_tag0, "1"], [blktag, string(i)], []);
  end

  for i=1:nevout do
    blk0 = instantiate_block ("CLKOUTV_f");//system/Ports/EventOutput");
    params = {};
    params.concatd[{"portNumber","1"}];
    blk0 = set_block_parameters (blk0, params);
    blk0 = set_block_size (blk0, [15, 10]);
    blk0 = set_block_nin (blk0, 0);
    blk0 = set_block_nout (blk0, 0);
    blk0 = set_block_evtnout (blk0, 1);
    blk0 = set_block_flip (blk0, 0);
    blk0 = set_block_origin (blk0, [pos(1)+20*(i-1), pos(2)+sz(2)+50]);
    blk0.angle=0;
    [scsm0, block_tag0]= add_block (scsm0, blk0, "evout"+string(i));
    scsm0 = add_event_link (scsm0, [blktag,string(i)], [block_tag0, "1"], []);
  end
  scsm0 = set_diagram_context (scsm0, sblkctx);
  sblk = fill_super_block (sblk, scsm0);
  sblk = set_block_mask (sblk, sblkparams, sblkdesc);
  out = sblk
endfunction

