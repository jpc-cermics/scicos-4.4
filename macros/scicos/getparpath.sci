function ppath=getparpath(scs_m,bpath,ppath)
// getparpath - computes path to block parameter data structure in scicos structure
//%Syntax
//  ppath=getparpath(scs_m)  standard call
//  ppath=getparpath(scs_m,bpath,ppath) recursive call
//%Parameters
//   scs_m : scicos data structure
//   bpath : current path to scs_m
//   ppath : list, each element is a vector giving the path to a block
//           with non empty rpar or ipar or states
//!
// Copyright INRIA
  excluded=['IN_f','OUT_f','CLKIN_f','CLKOUT_f','CLKINV_f','CLKOUTV_f']
  if nargin < 2 then bpath=[],end
  if nargin < 3 then ppath=list(),end
  for k=1:length(scs_m.objs)
    o=scs_m.objs(k)
    if o.type =='Block' then
      if and(o.gui<>excluded) then
	model=o.model
	if model.sim(1)=='super'| model.sim(1)=='csuper' then
	  o=scs_m.objs(k).model.rpar
	  ppath=getparpath(o,[bpath k],ppath)
	else
	  if ~isempty(model.state) | ~isempty(model.dstate) | ~isempty(model.rpar) | ~isempty(model.ipar) then
	    ppath(size(ppath)+1)=[bpath k],
	  end
	end
      end
    end
  end
endfunction
