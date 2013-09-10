function bad_connection(path_out,prt_out,nout,outtyp,path_in,prt_in,nin,intyp,typ)
// Copyright INRIA
// alert for badly connected blocks
// path_out : Path of the "from block" in scs_m
// path_in  : Path of the "to block" in scs_m
// typ : a flag. If not present or equal to zero then
//               display a message concerning size.
//               Else if equal to 1 then display a message
//               concerning type.
//

  function new_path= bad_connection_path(mpath,tag,prt)
  // look for modelica bloc associated with prt
    outports=list()
    for b= mpath
      path= scs_full_path(b);
      mb=scs_m(path);
      k=find(mb.graphics(tag) =='E')
      for kk=k,outports($+1)=path,end
    end
    new_path =outports(prt);
  endfunction

  function show_bad_connection(path,mess)
  // one block given by path
    if type(path,'short')<>'l' then 
      path = scs_full_path(path);
    end
    ret = hilite_obj(scs_m(path));
    if ret then 
      // object was hilited 
      message(mess);
      unhilite_obj(scs_m(path));
    else
      // object was not hilited we try to hilite the path 
      hilite_path(path,mess,%f);
    end    
  endfunction

  function show_bad_connections(path1,path2,mess)
  // two blocks 
    if type(path1,'short')<>'l' then 
      path1 = scs_full_path(path1);
    end
    if type(path2,'short')<>'l' then 
      path2 = scs_full_path(path2);
    end
    hilite_obj(scs_m(path1));
    if ~path1.equal[path2] then hilite_obj(scs_m(path2));end
    message(mess);
    unhilite_obj(scs_m(path1));
    if ~path1.equal[path2] then unhilite_obj(scs_m(path2));end
  endfunction
    
  if nargin <= 8 then typ=0;end 
    
  if type(path_out,'short')=='l' then //set of modelica blocks
    // look for modelica bloc associated with prt_out
    path_out = bad_connection_path(path_out,'out_implicit',prt_out);
  end

  if type(path_in,'short')=='l' then //set of modelica blocks
    // look for modelica bloc associated with prt_in
    path_in = bad_connection_path(path_in,'in_implicit',prt_in);
  end

  // here path_in and path_out can be full_pathes or vectors 
    
  if path_in ==-1 then
    if typ==0 then str_typ= 'sizes' else str_typ = 'types';end 
    mess=['Hilited block has connected ports ';
	  'with  incompatible '+ str_typ];
    show_bad_connection(path_out,mess);
    return;
  end
  
  if prt_in <> -1 then  
    //two connected blocks
    lp=min(size(path_out,'*'),size(path_in,'*'))
    k=find(path_out(1:lp)<>path_in(1:lp))
    path=path_out(1:k(1)-1) // common superbloc path
    path_out=path_out(k(1)) // "from" block number
    path_in=path_in(k(1))   // "to" block number

    if isempty(path) then
      // no common superblock
      if typ==0 then
        mess=['Hilited block(s) have connected ports ';
	      'with  incompatible sizes';
	      ' output port '+string(prt_out)+' size is :'+sci2exp(nout);
	      ' input port '+string(prt_in)+' size is  :'+sci2exp(nin)];
      else
        mess=['Hilited block(s) have connected ports ';
	      'with  incompatible type';
	      ' output port '+string(prt_out)+' type is :'+sci2exp(outtyp);
	      ' input port '+string(prt_in)+' type is  :'+sci2exp(intyp)];

      end
      show_bad_connections(path_out,path_in,mess);
      return;
    else
      // What is the value of path here 
      mxwin=max(winsid())
      for k=1:size(path,'*')
	hilite_obj(scs_m.objs(path(k)))
	scs_m=scs_m.objs(path(k)).model.rpar;
	scs_m=scs_show(scs_m,mxwin+k)
      end
      if typ==0 then
        mess=['Hilited block(s) have connected ports ';
	      'with  incompatible sizes';
	      string(prt_out)+' output port size is :'+sci2exp(nout);
	      string(prt_in)+' input port size is  :'+sci2exp(nin)];
      else
        mess=['Hilited block(s) have connected ports ';
	      'with  incompatible type';
	      ' output port '+string(prt_out)+' type is :'+sci2exp(outtyp);
	      ' input port '+string(prt_in)+' type is  :'+sci2exp(intyp)];
      end
      show_bad_connections(path_out,path_in,mess);
      for k=size(path,'*'):-1:1,xdel(mxwin+k),end
      //XXX TODO Alan
      //bad_connection(path,
      //['Simulation problem with hilited block:';lasterror()])
      //scs_m=null() reset scs_m to get the calling frame value;
      clear('scs_m');
      //printf("Unhilite in bad_connection\n");
      unhilite_obj(scs_m.objs(path(1)))
    end
  else 
    // connected links do not verify block contraints
    mess=prt_out;
    if type(path_out,'short')=='l' then //problem with implicit block
      message('Problem with the block generated from modelica blocks')
    else
      path=path_out(1:$-1) // superbloc path
      path_out=path_out($) //  block number
      if isempty(path) then
	show_bad_connection(path,mess);
      else
        mxwin=max(winsid());
        scs_m_kp=scs_m;
        for k=1:size(path,'*')
	  hilite_obj(scs_m.objs(path(k)))
	  scs_m=scs_m.objs(path(k)).model.rpar;
	  scs_m=scs_show(scs_m,mxwin+k)
	end
        // XXX: Il y a un probleme avec hilite 
        // c'est que comme le hilite n'est pas recordé 
        // si un redessin est fait on le perd car dans 
        // les sous fenetres pour les super blocks scs_show 
        // ne nous fait pas passer en fenetre a scroll
        // 
	show_bad_connection(path_out,mess);
        for k=size(path,'*'):-1:1,xdel(mxwin+k),end
        scs_m=scs_m_kp;
        unhilite_obj(scs_m.objs(path(1)))
      end
    end
  end
endfunction
