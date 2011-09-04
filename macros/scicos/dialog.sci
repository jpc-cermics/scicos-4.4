function result=dialog(labels,valueini)
//interface to x_dialog primitive to allow simple overloading for live demo 
// Copyright INRIA
  result=x_dialog(labels,valueini)
endfunction

function result=scicos_mdialog(varargin)
// wrapper of x_mdialog that changes when it is to 
// be called in a non-interactive way or in interactive way.
// jpc 
  non_interactive = exists('getvalue') && getvalue.get_fname[]== 'setvalue';
  if non_interactive then 
    result=varargin($);
  else
    result=x_mdialog(varargin(:));
  end
endfunction

function result=scicos_editsmat(title,txt,comment='Enter code:')
// wrapper of editsmap that changes when it is to 
// be called in a non-interactive way or in interactive way.
// jpc 
  non_interactive = exists('getvalue') && getvalue.get_fname[]== 'setvalue';
  if non_interactive then 
    result=txt
  else
    result=editsmat(title,txt,comment=comment);
  end
endfunction

