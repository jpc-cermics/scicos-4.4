function CustomizeMask_()
// Copyright INRIA
  Cmenu="";%pt=[];
  if size(Select,1)<>1 | curwin<>Select(1,2) then
    return
  end
  i=Select(1)
  o=scs_m.objs(i)
  // check that o is a block 
  if o.type <> 'Block' then
    message('Select a block.')
    return;
  end
  // the block is masked ? 
  if ~(o.model.sim =='csuper' & isequal(o.model.ipar,1))  then
    message('This block is not masked.')
    return;
  end
  // 
  items=o.graphics.exprs(2)(1)
  result=x_mdialog(['Customize block GUI:';'Modify title and menu labels.'],..
		 ['Title of the GUI';items],[o.graphics.exprs(2)(2);items])
  if ~isempty(result) && ~isequal(items,result) then
    o.graphics.exprs(2)(2)=result;
    scs_m.objs(i)=o;
    edited=%t
  end
endfunction
