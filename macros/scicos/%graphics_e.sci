
function varargout=%graphics_e(i,o)
//function used only for backward compatibility of scicos blocks gui
  warning('Obsolete use of graphics(i) in this scicos block')
  varargout=list()
  for k=1:size(i,'*')
    varargout($+1)=getfield(i(k)+1,o)
  end
endfunction
