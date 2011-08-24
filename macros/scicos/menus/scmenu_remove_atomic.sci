function scmenu_remove_atomic()
  if alreadyran then
    // first terminate 
    Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
		     '[alreadyran,%cpr]=do_terminate();%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1';
		     'Select='+sci2exp(Select)+';Cmenu='"Remove Atomic"''];
    return 
  end
  Cmenu='';%pt=[];
  if size(Select,1)<>1 | curwin<>Select(1,2) then
    return
  end
  [o,needcompile,ok]=do_remove_atomic(scs_m.objs(Select(1)));
  if ok then 
    scs_m = update_redraw_obj(scs_m,list('objs',i),o);
  end
endfunction

function [o,needcompile,ok]=do_remove_atomic(o)
  ok=%t
  if o.type =='Block' && o.model.sim(1)=='asuper' then 
    model=o.model
    graphics=o.graphics;
    o.model.sim='super';
    o.model.in=-ones(size(model.in,1),size(model.in,2))
    o.model.in2=-2*ones(size(model.in2,1),size(model.in2,2))
    o.model.out=-ones(size(model.out,1),size(model.out,2))
    o.model.out2=-2*ones(size(model.out2,1),size(model.out,2))
    o.model.intyp=-ones(1,size(model.intyp,'*'))
    o.model.outtyp=o.model.intyp
    o.graphics.exprs=graphics.exprs(1)
    needcompile=4;
  else
    message('Remove Atomic can only be applied to Atomic Super Blocks');
    ok=%f;
    return
  end
endfunction
