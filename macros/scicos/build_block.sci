function [model,ok]=build_block(o)
// build the simulation function associated with the block if necessary
  ok=%t;
  model=o.model
  graphics=o.graphics
  if model.sim(1)=='scifunc' then
    // take care that model.ipar is not always a scalar.
    if model.ipar.equal[0] then
      message('A scifunc block has not been defined')
      ok=%f; return
    end
    model.sim=list(genmac(model.ipar,size(model.in,'*'),size(model.out,'*')),3)
  elseif type(model.sim,'short')=='l' then
    if int(model.sim(2)/1000)==1 then   //fortran block
      funam=model.sim(1)
      if ~c_link(funam) then
	tt=graphics.exprs(2);
	ok=scicos_block_link(funam,tt,'f')
      end
    elseif int(model.sim(2)/1000)==2 then   //C block
      funam=model.sim(1)
      if ~c_link(funam) then
	tt=graphics.exprs(2);
	ok=scicos_block_link(funam,tt,'c')
      end
    end
  end
endfunction
