function r=is_split(o)
// check if object o is a regular or event split
// Copyright INRIA
//if o(1)<>'Block' then r=%f,return,end
  if o.type <>'Block' then r=%f,return,end
  //r=o(3)(1)=='split'|o(3)(1)=='lsplit'
  r=o.model.sim(1)=='split'|o.model.sim(1)=='lsplit'
endfunction
