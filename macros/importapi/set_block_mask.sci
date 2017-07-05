function o = set_block_mask (blk, mask, ptitle)
  [m,n]=size(mask);
  if m*n == 0 then 
    o = blk; return;
  end
  params_names=m2s([])
  params_values=m2s([])
  params_prompts=m2s([])
  params_flags=m2b([])
  param_types=list();
  for i=1:m
    params_names.concatd[mask{i,1}];
    // 3 booleans : evaluate, enable, visible
    params_flags.concatd[mask{i,4}];
    // take care of a popup case where params is
    // "name", '''A''', 'Select Rate ReconstructionMethod',
    //           [ %t, %t, %t ], [ 'popup', [ 'A', 'B', 'C' ] ] } ];
    if mask{i,4}(1) && type(mask{i,5},'short')=='s' && mask{i,5}(1)=='popup' then
      // search the value in possible values
      values = mask{i,5}(2:$);
      [_void,position]= values.has[evstr(mask{i,2})];

      new_prompt = [mask{i,3},[string(1:size(values,'*'))+":"+values]];
      new_prompt = catenate(new_prompt,sep='\n');
      params_values.concatd[string(position)];
      params_prompts.concatd[new_prompt];
    elseif mask{i,4}(1) &&  type(mask{i,5},'short')=='s' && mask{i,5}(1)=='checkbox' then
      if mask{i,2}.equal['''on'''] then 
	params_values.concatd['1'];
      else
	params_values.concatd['0'];
      end
      params_prompts.concatd[mask{i,3}];
    else
      params_values.concatd[mask{i,2}];
      params_prompts.concatd[mask{i,3}];
    end
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
