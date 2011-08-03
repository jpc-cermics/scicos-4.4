function hilite_path(path,mess,with_intermediates)
// Copyright INRIA
// path is here a vector of indices which gives a path 
// to a block path($). 
// hilite_path is used to hilite the block path($) and if 
// requested hilite also all the superblocks hierarchy which 
// leads to the block path($).
// mess: is the message which is to be given. 
// path(1) which is the first entry of the path must be a bloc 
// of currently opened diagram  
// for other blocks the function will take care of showing the 
// non opened superblocks
// 
// XXX: could be improved by non-reopening the already opened 
// superblocks on the path.
// 
// 
  if nargin<3 then with_intermediates=%f,end
  if nargin<2 then mess=' ',end
  scs_m=scs_m;
  scs_m_s=scs_m;
  mxwin=max(winsid()),opened_windows=[]
  hilite_obj(scs_m.objs(path(1)))
  
  if with_intermediates then
    scs_m=scs_m.objs(path(1)).model.rpar;
    for k=2:size(path,'*')
      scs_m=scs_show(scs_m,mxwin+k);opened_windows=[mxwin+k opened_windows]
      hilite_obj(scs_m.objs(path(k)))
      scs_m=scs_m.objs(path(k)).model.rpar;
    end
  else
    if size(path,'*')==1 then
      hilite_obj(scs_m.objs(path))
    else
      for k=1:size(path,'*')-1;scs_m=scs_m.objs(path(k)).model.rpar;end
      scs_m=scs_show(scs_m,mxwin+1);opened_windows=[mxwin+1 opened_windows]
      hilite_obj(scs_m.objs(path($)))
    end
  end
  message(mess)
  xdel(opened_windows)
  scs_m=scs_m_s
  xset('window',Main_Scicos_window)
  unhilite_obj(scs_m.objs(path(1)))
endfunction
