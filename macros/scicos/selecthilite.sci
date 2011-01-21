function selecthilite(Select, flag)
  if isempty(Select) then
    return
  end
  for i=1:size(Select)
    ogr=Select(i);
    ogr.hilited=flag;
    ogr.invalidate[];
  end
endfunction
