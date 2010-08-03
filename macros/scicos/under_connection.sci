function ninnout=under_connection(path_out,path_in)
// alert for badly connected blocks
// path_out : Path of the "from block" in scs_m
// path_in  : Path of the "to block" in scs_m
//!
  if path_in==-1 then
    hilite_obj(scs_m.objs(path_out));
    message(['One of this block''s outputs has negative size';
	     'Please check.'])
    unhilite_obj(scs_m.objs(path_out));
    ninnout=0
    return
  end
  
  lp=min(size(path_out,'*'),size(path_in,'*'))
  k=find(path_out(1:lp)<>path_in(1:lp))
  path=path_out(1:k(1)-1) // common superbloc path
  path_out=path_out(k(1)) // "from" block number
  path_in=path_in(k(1))   // "to" block number
  
  if isempty(path) then
    hilite_obj(scs_m.objs(path_out))
    if or(path_in<>path_out) then hilite_obj(scs_m.objs(path_in)),end

    ninnout=evstr(dialog(['Hilited block(s) have connected ports ';
		    'with  sizes that cannot be determiend by the context';
		    'what is the size of this link'],'1'))
    unhilite_obj(scs_m.objs(path_out))
    if or(path_in<>path_out) then hilite_obj(scs_m.objs(path_in)),end
  else
    mxwin=max(winsid())
    for k=1:size(path,'*')
      hilite_obj(scs_m.objs(path(k)))
      scs_m=scs_m.objs(path(k)).model.rpar;
      scs_show(scs_m,mxwin+k)
    end
    hilite_obj(scs_m.objs(path_out))
    if or(path_in<>path_out) then hilite_obj(scs_m.objs(path_in)),end
    ninnout=evstr(dialog(['Hilited block(s) have connected ports ';
		    'with  sizes that cannot be determiend by the context';
		    'what is the size of this link'],'1'))
    for k=size(path,'*'):-1:1,xdel(mxwin+k),end
    //scs_m=null()
    clear('scs_m');
    unhilite_obj(scs_m.objs(path(1)))
  end
endfunction


