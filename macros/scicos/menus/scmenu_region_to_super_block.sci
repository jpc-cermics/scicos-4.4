function RegiontoSuperBlock_()
// Copyright INRIA
  Cmenu='Open/Set'
  xinfo(' Click, drag region and click (left to fix, right to cancel)')
  ierr=execstr('[%pt,scs_m]=do_region2block(%pt,scs_m)',errcatch=%t);
  if ~ierr then 
    message(lasterror());
  end
endfunction

function [%pt,scs_m]=do_region2block(%pt,scs_m)
// Copyright INRIA

  while %t
    if isempty(%pt) then
      [btn,%pt,win,Cmenu]=cosclick()
      if Cmenu<>"" then
        resume(%win=win,Cmenu=Cmenu,btn=btn)
        return;
      end
    else
      win=%win;
      break
    end
  end
  xc=%pt(1);yc=%pt(2);
  %pt=[]
  scs_m_save=scs_m,nc_save=needcompile

  // delete_2 is called during this part

  [scs_mb,rect,prt]=get_region2(xc,yc,win)

  if isempty(rect) then return,end
  if length(scs_mb.objs)==0 then return, end
  //superblock should not inherit the context nor the name
  scs_mb.props.context=' '
  scs_mb.props.title(1)='Untitled'
  ox=rect(1);oy=rect(2)+rect(4);w=rect(3),h=rect(4)

  n=0
  W=max(600,rect(3))
  H=max(400,rect(4))

  ng=new_graphics();

  if ng then
    // do not keep the recorded graphics 
    // in the super  block.
    for k=1:length(scs_mb.objs) 
      scs_mb.objs(k).delete['gr'];
    end
  end

  sup = SUPER_f('define')
  sup.graphics.orig   = [rect(1)+rect(3)/2-20,rect(2)+rect(4)/2-20]
  sup.graphics.sz     = [40 40]
  sup.model.in        = 1
  sup.model.out       = 1
  sup.model.rpar      = scs_mb
  sup.model.blocktype = 'h'
  sup.model.dep_ut    = [%f %f]
  // open the superblock in editor

  [ok,sup]=adjust_s_ports(sup)

  // detruire la region
  del=[]
  for k=1:length(scs_m.objs)
    o=scs_m.objs(k)
    if o.type =='Block'| o.type =='Text' then
      // check if block is outside rectangle
      orig=o.graphics.orig
      sz=o.graphics.sz
      x=[0 1 1 0]*sz(1)+orig(1)
      y=[0 0 1 1]*sz(2)+orig(2)
      ok=%f
      for kk=1:4
        data=[(ox-x(kk))'*(ox+w-x(kk)),(oy-h-y(kk))'*(oy-y(kk))];
        if data(1)<0&data(2)<0 then ok=%t;del=[del k];break;end
      end
    end
  end

  // scs_m now have some deleted blocks
  if ng then
    F=get_current_figure();
    F.draw_latter[];
    [scs_m1,DEL]=do_delete2(scs_m,del,%f)
    for k=DEL,
      if scs_m.objs(k).iskey['gr'] then
        F.remove[scs_m.objs(k).gr];
      end
      scs_m.objs(k)=mlist('Deleted');
    end
  else
    [scs_m,DEL]=do_delete2(scs_m,del,%f)
  end

  // add super block
  // drawobj(sup)

  if ng then
    F.draw_latter[];
    F.start_compound[];
    drawobj(sup);
    C=F.end_compound[];
    sup.gr = C;
  end

  scs_m.objs($+1)=sup
  // connect it
  nn=length(scs_m.objs)
  nnk=nn
  for k=1:size(prt,1)
    k1=prt(k,6);tp1=prt(k,8);
    ksup=prt(k,1);tpsup=prt(k,3)
    typ=prt(k,5)
    o1=scs_m.objs(k1) // block origin of the link outside the superblock
    if typ>0 then //regular link
      if tp1==0 then  //link connected to an output port of o1
	if typ>1 then //implicit regular link
	  [x,y,vtyp]=getoutputports(o1)
	else //explicit regular link
	  [x,y,vtyp]=getoutputs(o1)
	end
	if tpsup==1 then //link connected to an input port of the superblock 
	  if typ>1 then //implicit regular link
	    [xn,yn,vtypn]=getinputports(sup)
	  else	    //explicit regular link
	    [xn,yn,vtypn]=getinputs(sup),
	  end
	  Psup='pin'
	else //link connected to an output port of the superblock 
	  if typ>1 then //implicit regular link
	    [xn,yn,vtypn]=getoutputports(sup)
	  else //explicit regular link
	    [xn,yn,vtypn]=getoutputs(sup),
	  end
	  Psup='pout'
	end
	p=prt(k,7)
	pn=prt(k,2)
	xl=[x(p);xn(pn)]
	yl=[y(p);yn(pn)]
	from=prt(k,6:8)
	to=[nn,prt(k,2:3)]
	o1.graphics.pout(prt(k,7))=nnk+1
	scs_m.objs(nn).graphics(Psup)(prt(k,2))=nnk+1
      else //link connected to an input port of o1
	if typ>1 then //implicit regular link
	  [x,y,vtyp]=getinputports(o1)
	else
	  [x,y,vtyp]=getinputs(o1)
	end
	if tpsup==1 then //link connected to an input port of the superblock 
	  if typ>1 then //implicit regular link
	    [xn,yn,vtypn]=getinputports(sup)
	  else //explicit regular link
	    [xn,yn,vtypn]=getinputs(sup),
	  end
	  Psup='pin'
	else  //link connected to an output port of the superblock 
	  if typ>1 then //implicit regular link
	    [xn,yn,vtypn]=getoutputports(sup)
	  else //explicit regular link
	    [xn,yn,vtypn]=getoutputs(sup),
	  end
	  Psup='pout'
	end
	p=prt(k,7)
	pn=prt(k,2)
	xl=[xn(pn);x(p)]
	yl=[yn(pn);y(p)]
	from=[nn,prt(k,2:3)]
	to=prt(k,6:8)
	o1.graphics.pin(prt(k,7))=nnk+1
	scs_m.objs(nn).graphics(Psup)(prt(k,2))=nnk+1
      end
    else //event link
      if tpsup==1 then //link connected to an event input port of the superblock 
	[x,y,vtyp]=getoutputs(o1)
	[xn,yn,vtypn]=getinputs(sup),
	p=prt(k,7)+size(find(vtyp==1),'*')+size(find(vtyp==2),'*')
	pn=prt(k,2)+size(find(vtypn==1),'*')+size(find(vtypn==2),'*')
	xl=[x(p);xn(pn)]
	yl=[y(p);yn(pn)]
	from=prt(k,6:8)
	to=[nn,prt(k,2:3)]
	o1.graphics.peout(prt(k,7))=nnk+1
	scs_m.objs(nn).graphics.pein(prt(k,2))=nnk+1
      else //link connected to an event output port of the superblock 
	[x,y,vtyp]=getinputs(o1)
	[xn,yn,vtypn]=getoutputs(sup),
	p=prt(k,7)+size(find(vtyp==1),'*')+size(find(vtyp==2),'*')
	pn=prt(k,2)+size(find(vtypn==1),'*')+size(find(vtypn==2),'*')
	xl=[xn(pn);x(p)]
	yl=[yn(pn);y(p)]
	from=[nn,prt(k,2:3)]
	to=prt(k,6:8)
	o1.graphics.pein(prt(k,7))=nnk+1
	scs_m.objs(nn).graphics.peout(prt(k,2))=nnk+1
      end
    end
    if xl(1)<>xl(2)&yl(1)<>yl(2) then //oblique link
      if prt(k,4)>0 then //regular port
	xl=[xl(1);xl(1)+(xl(2)-xl(1))/2;xl(1)+(xl(2)-xl(1))/2;xl(2)]
	yl=[yl(1);yl(1);yl(2);yl(2)]
      else
	xl=[xl(1);xl(1);xl(2);xl(2)]
	yl=[yl(1);yl(1)+(yl(2)-yl(1))/2;yl(1)+(yl(2)-yl(1))/2;yl(2)]
      end
    end
    lk=scicos_link(xx=xl,yy=yl,ct=prt(k,4:5),from=from,to=to)
    if ng then
      F.start_compound[];
      drawobj(lk);
      C=F.end_compound[];
      lk.gr = C;
    else
      drawobj(lk)
    end

    scs_m.objs($+1)=lk
    scs_m.objs(k1)=o1
    nnk=nnk+1
  end

  // redraw
  if new_graphics() then 
    F.draw_now[];
  else
    xtape_status=xget('recording')
    [echa,echb]=xgetech();
    xclear(curwin,%t);
    xset("recording",1);
    xsetech(echa,echb);
    drawobjs(scs_m);
    xset('recording',xtape_status);
  end

  resume(scs_m_save,nc_save,needreplay,enable_undo=%t,edited=%t,needcompile=4);
endfunction
