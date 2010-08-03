function bad_connection(path_out,prt_out,nout,path_in,prt_in,nin)
// alert for badly connected blocks
// path_out : Path of the "from block" in scs_m
// path_in  : Path of the "to block" in scs_m
//!
// Copyright INRIA
  if type(path_out,'short')=='l' then //set of modelica blocks
    // look for modelica bloc associated with prt_out
    outports=list()
    for b=path_out,
      path=list();
      for l=b(1:$-1),
	path($+1)=l;path($+1)='model';path($+1)='rpar';path($+1)='objs';
      end
      path($+1)=b($);
      if size(path)==1 then path=path(1),end
      mb=scs_m.objs(path)
      k=find(mb.graphics.out_implicit=='E')
      for kk=k,outports($+1)=path,end
    end
    path_out=outports(prt_out)
  end
  if type(path_in,'short')=='l' then //set of modelica blocks
    // look for modelica bloc associated with prt_in
    inports=list()
    for b=path_in,
      path=list();
      for l=b(1:$-1),
	path($+1)=l;path($+1)='model';path($+1)='rpar';path($+1)='objs';
      end
      path($+1)=b($);
      if size(path)==1 then path=path(1),end
      mb=scs_m.objs(path)
      k=find(mb.graphics.in_implicit=='E')
      for kk=k,inports($+1)=path,end
    end
    path_in=inports(prt_in)
  end

  if path_in==-1 then
    hilite_obj(scs_m.objs(path_out));
    message(['Hilited block has connected ports ';
	     'with  incompatible sizes'])
    unhilite_obj(scs_m.objs(path_out));
    return;
  end

  if prt_in <> -1 then  //two connected blocks
    lp=min(size(path_out,'*'),size(path_in,'*'))
    k=find(path_out(1:lp)<>path_in(1:lp))
    path=path_out(1:k(1)-1) // common superbloc path
    path_out=path_out(k(1)) // "from" block number
    path_in=path_in(k(1))   // "to" block number

    if isempty(path) then
      hilite_obj(scs_m.objs(path_out))
      if or(path_in<>path_out) then hilite_obj(scs_m.objs(path_in)),end

      message(['Hilited block(s) have connected ports ';
	       'with  incompatible sizes';
	       ' output port '+string(prt_out)+' size is :'+string(nout);
	       ' input port '+string(prt_in)+' size is  :'+string(nin)]); 
      unhilite_obj(scs_m.objs(path_out))
      if or(path_in<>path_out) then unhilite_obj(scs_m.objs(path_in)),end
    else
      mxwin=max(winsid())
      for k=1:size(path,'*')
	hilite_obj(scs_m.objs(path(k)))
	scs_m=scs_m.objs(path(k)).model.rpar;
        if new_graphics() then
	  scs_m=scs_show(scs_m,mxwin+k)
        else
	  scs_show(scs_m,mxwin+k)
        end
      end
      hilite_obj(scs_m.objs(path_out))
      if or(path_in<>path_out) then hilite_obj(scs_m.objs(path_in)),end
      message(['Hilited block(s) have connected ports ';
	       'with  incompatible sizes';
	       string(prt_out)+' output port size is :'+string(nout);
	       string(prt_in)+' input port size is  :'+string(nin)]); 
      for k=size(path,'*'):-1:1,xdel(mxwin+k),end
      //TODO Alan
      //bad_connection(path,
      //['Simulation problem with hilited block:';lasterror()])
      //scs_m=null() reset scs_m to get the calling frame value;
      clear('scs_m');
      //printf("Unhilite in bad_connection\n");
      unhilite_obj(scs_m.objs(path(1)))
    end
  else // connected links do not verify block contraints
    mess=prt_out;
    if type(path_out,'short')=='l' then //problem with implicit block
      message('Problem with the block generated from modelica blocks')
    else
      path=path_out(1:$-1) // superbloc path
      path_out=path_out($) //  block number
      if isempty(path) then
        hilite_obj(scs_m.objs(path_out))
        message(mess)
        unhilite_obj(scs_m.objs(path_out))
      else
        mxwin=max(winsid());
        scs_m_kp=scs_m;
        for k=1:size(path,'*')
	  hilite_obj(scs_m.objs(path(k)))
	  scs_m=scs_m.objs(path(k)).model.rpar;
          if new_graphics() then
	    scs_m=scs_show(scs_m,mxwin+k)
          else
	    scs_show(scs_m,mxwin+k);
          end
        end
        // XXX: Il y a un probleme avec hilite 
        // c'est que comme le hilite n'est pas recordé 
        // si un redessin est fait on le perd car dans 
        // les sous fenetres pour les super blocks scs_show 
        // ne nous fait pas passer en fenetre a scroll
        // 
        hilite_obj(scs_m.objs(path_out));
        message(mess)
        for k=size(path,'*'):-1:1,xdel(mxwin+k),end
        //scs_m=null() reset scs_m to get the calling frame value;
        //clear('scs_m');
        scs_m=scs_m_kp;
        //printf("Unhilite in bad_connection\n");
        unhilite_obj(scs_m.objs(path(1)))
      end
    end
  end
endfunction
