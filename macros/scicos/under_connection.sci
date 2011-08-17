function ninnout=under_connection(path_out,prt_out,nout,path_in,prt_in,nin,flagg)
// alert for badly connected blocks
// path_out : Path of the "from block" in scs_m
// path_in  : Path of the "to block" in scs_m

  if path_in==-1 | path_in==-2 then
    path=path_out(1:$-1)
    path_out=path_out($)
    mxwin=max(winsid())
    for k=1:size(path,'*')
      hilite_obj(scs_m.objs(path(k)))
      scs_m=scs_m.objs(path(k)).model.rpar;
      scs_m=scs_show(scs_m,mxwin+k)
    end
   
    hilite_obj(scs_m.objs(path_out));
    if path_in==-1 then
      message(['One of this block''s outputs has negative size';
	     'Please check.'])
    else
      message(['The input port '+string(prt_out)+' of this block have a negative size.';
	     'Please check.'])
    end
    unhilite_obj(scs_m.objs(path_out));

    for k=size(path,'*'):-1:1,
      xdel(mxwin+k)
    end
    if ~isempty(path) then
      unhilite_obj(scs_m.objs(path(1)))
    end

    ninnout=0
    return
  end


  lp=min(size(path_out,'*'),size(path_in,'*'))
  k=find(path_out(1:lp)<>path_in(1:lp))
  if isempty(k) then k=lp,end  // same block on  both ends
  path=path_out(1:k(1)-1) // common superbloc path

  if (size(path_out,'*')==size(path_in,'*'))&(size(path_out,'*')==size(path,'*')+1) then
     canshowlink=%t
  else
     canshowlink=%f
  end

  path_out=path_out(k(1)) // "from" block number
  path_in=path_in(k(1))   // "to" block number

  if exists('Code_gene_run') then
    mxwin=max(winsid())
    if isempty(path) then path=0, end
    path=path+1 // Consider locally compiled superblock as a superblock
    for k=1:size(path,'*')
      hilite_obj(all_scs_m.objs(numk(k)))
      scs_m=all_scs_m.objs(numk(k)).model.rpar;
      scs_m=scs_show(scs_m,mxwin+k)
    end
    hilite_obj(scs_m.objs(path_out))
    if or(path_in<>path_out) then hilite_obj(scs_m.objs(path_in)),end
    if flagg==1 then
      ninnout=evstr(dialog(['Hilited block(s) have connected ports ';
		    'with  sizes that cannot be determined by the context';
		    'what is the size of this link'],'[1,1]'))
    else 
      ninnout=evstr(dialog(['Hilited block(s) have connected ports ';
		    'with  types that cannot be determined by the context';
		    'what is the type of this link'],'1'))
    end
	      
    for k=size(path,'*'):-1:1,
      xdel(mxwin+k)
    end
    unhilite_obj(all_scs_m.objs(numk(1)))
  else

    mxwin=max(winsid())
    kk=[];
    for k=1:size(path,'*')
      hilite_obj(scs_m.objs(path(k)))
      scs_m=scs_m.objs(path(k)).model.rpar;
      scs_m=scs_show(scs_m,mxwin+k)
    end
    kk=[path_out]
    if or(path_in<>path_out) then kk=[kk;path_in], end
    if canshowlink then  
      if ~isempty(prt_in) & ~isempty(prt_out) then
        if prt_in >0 & prt_out >0 then
          if scs_m.objs(path_out).graphics.pout(prt_out) == ...
              scs_m.objs(path_in).graphics.pin(prt_in) then // in absence of split
                kk=[kk;scs_m.objs(path_out).graphics.pout(prt_out)]
          end
        end
      end
    end
    for k=1:size(kk,'*')
      hilite_obj(scs_m.objs(kk(k)))
    end
    if flagg==1 then
	ninnout=evstr(dialog(['Hilited block(s) have connected ports ';
	    'with  sizes that cannot be determined by the context';
	    'what is the size of this link'],'[1,1]'))
    else
	ninnout=evstr(dialog(['Hilited block(s) have connected ports ';
	    'with  types that cannot be determined by the context';
	    'what is the size of this link'],'1'))
    end
    for k=1:size(kk,'*')
      unhilite_obj(scs_m.objs(kk(k)))
    end

    for k=size(path,'*'):-1:1,
      xdel(mxwin+k)
    end
    if ~isempty(path) then
      unhilite_obj(scs_m.objs(path(1)))
    end
  end
endfunction
