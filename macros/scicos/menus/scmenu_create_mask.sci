function CreateMask_()
// Copyright INRIA
  Cmenu="";%pt=[];
  if size(Select,1)<>1 || curwin<>Select(1,2) then
    return
  end
  i=Select(1)
  o=scs_m.objs(i)
  if o.type <> 'Block' then
    message('Mask can only be created for Super Blocks.')
    return;
  end
  model=o.model
  graphics=o.graphics;
  if model.sim <> 'super' then
    message('Mask can only be created for Super Blocks.')
    return;
  end
  // A revoir 
  [ok,params,param_types]=FindSBParams(model.rpar,[])
  // ok = %t; params=['x']; param_types=['int'];
  if ~ok then 
    message(['Error occured while masking the subsystem';
	     'The mask will not be created']);
    return
  end
  bname=model.rpar.props.title(1)
  model.sim='csuper'
  model.ipar=1 ;  // specifies the type of csuper (mask)
  graphics.exprs=list(params,list(params,..
				  ["Set block parameters";params],param_types));     
  graphics.gr_i=list('xstringb(orig(1),orig(2),'"'+..
		     bname+''",sz(1),sz(2),''fill'');',8)
  o.model=model;
  o.graphics=graphics;
  o.gui='DSUPER';
  scs_m_save = scs_m;
  scs_m.objs(i)=o;
  nc_save = needcompile ;
  needcompile=4  // this is perhaps too conservative
  enable_undo = %t
  edited=%t;
  // redraw the changed object.
  scs_m=update_redraw_obj(scs_m,list('objs',i),o);
endfunction
