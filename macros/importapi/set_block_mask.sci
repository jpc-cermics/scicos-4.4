function o = set_block_mask (blk, mask, ptitle)
  [m,n]=size(mask);
  params_names=m2s([])
  params_values=m2s([])
  params_prompts=m2s([])
  param_types=list();
  for i=1:m
    params_names.concatd[mask{i,1}];
    params_values.concatd[mask{i,2}];
    params_prompts.concatd[mask{i,3}];
//  XXXXXX 
//  we should take care of this boolean 
//  params_evaluate.concatd[mask{i,3}];
    param_types($+1)="gen";
    param_types($+1)= -1;
  end
  if blk.type == 'Block' then
    o = blk
    model=o.model
    graphics=o.graphics;
    if or(model.sim==['super','asuper']) then  //
      bname=model.rpar.props.title(1)
      model.sim='csuper'
      model.ipar=1 ;  // specifies the type of csuper (mask)
      graphics.exprs=list(params_values,list(params_names,..
					     [sci2exp(ptitle,0);params_prompts],param_types));     
      graphics.gr_i=list('xstringb(orig(1),orig(2),'"'+..
			 bname+''",sz(1),sz(2),''fill'');',8)
      o.model=model;
      o.graphics=graphics;
      o.gui='DSUPER';
    else
      error('Mask can only be created for Super Blocks.')
    end
  else
    error('Mask can only be created for Super Blocks.')
  end
endfunction
