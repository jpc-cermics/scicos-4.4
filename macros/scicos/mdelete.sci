function mdelete(filename)
  if type(filename,'short')<>'s' || size(filename,"*")<>1 then
    error("Error: expecting a string");
    return;
  end
  // expand possible pathnames 
  fn = glob(filename);
  for i=1:size(fn,'*') 
    file('delete',fn(i));
  end
endfunction

