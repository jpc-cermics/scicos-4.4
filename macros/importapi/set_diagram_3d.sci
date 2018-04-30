function scs_m = set_diagram_3d(scs_m,b)
  // b must be boolean 
  if type(b,'short')=='m' then b=m2b(b);end
  scs_m.props.options("3D")(1)=b
endfunction
