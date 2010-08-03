function [%pt,scs_m,needcompile]=getlink(%pt,scs_m,needcompile)
//edition of a link from an output block to an input  block
// Copyright INRIA
  dash=xget('color')
  outin=['out','in']
  //----------- get link origin --------------------------------------
  //------------------------------------------------------------------
  while %t
    if isempty(%pt) then
      [btn,%pt,win,Cmenu]=cosclick()
      if Cmenu<>"" then
	resume(%win=win,Cmenu=Cmenu,btn=btn)
	return;
      end
    else
      win=%win;
    end
    xc1=%pt(1);yc1=%pt(2);%pt=[]
    [kfrom,wh]=getblocklink(scs_m,[xc1;yc1])
    if ~isempty(kfrom) then o1=scs_m.objs(kfrom);break,end
  end
  scs_m_save=scs_m,nc_save=needcompile
  if o1.type =='Link' then  //add a split block
    pt=[xc1;yc1]
    [xx,yy,ct,from,to]=(o1.xx,o1.yy,o1.ct,o1.from,o1.to);
    if (-wh==size(xx,'*')) then
      wh=-(wh+1)
    end

    // get split type
    [xout,yout,typout]=getoutputports(scs_m.objs(from(1)))
    clr=ct(1)
    [m,kp1]=min((yc1-yout).^2+(xc1-xout).^2)
    k=kp1
    typo=ct(2)
    if typo==-1 then typp='evtout',else typp=outin(from(3)+1), end
    szout=getportsiz(scs_m.objs(from(1)),from(2),typp)

    // get initial split position
    wh=wh(1)
    if wh>0 then
      d=projaff(xx(wh:wh+1),yy(wh:wh+1),pt)
    else // a corner
      wh=-wh
      d=[xx(wh);yy(wh)]
    end
    // Note : creation of the split block and modifications of links are
    //        done later, the sequel assumes that the split block is added
    //        at the end of scs_m
    ks=kfrom;
    kfrom=length(scs_m.objs)+1;port_number=2;
    fromsplit=%t
    from=[kfrom,port_number,0]
    xo=d(1);yo=d(2)
    xl=d(1);yl=d(2)
  else //connection comes from a block
    graphics1=o1.graphics
    orig = graphics1.orig
    sz   = graphics1.sz
    io   = graphics1.flip
    op   = graphics1.pout
    impi = graphics1.pin
    cop  = graphics1.peout
    [xout,yout,typout]=getoutputports(o1)
    if isempty(xout) then
      message('This block has no output port'),
      xset('color',dash)
      return
    end
    [m,kp1]=min((yc1-yout).^2+(xc1-xout).^2)
    k=kp1
    xo=xout(k);yo=yout(k);typo=typout(k)
    if typo==1 then
      port_number=k
      if op(port_number)<>0 then
	message('selected port is already connected'),
	xset('color',dash)
	return
      end
      typpfrom='out'
    elseif (typo==2 & k<=size(op,'*')) then //implicit  output port
      port_number=k
      if op(port_number)<>0 then
	message('selected port is already connected'),
	xset('color',dash)
	return
      end
      typpfrom='out'
    elseif (typo==2 & k>size(op,'*')) then //implicit  input port
      k=k-size(op,'*')
      port_number=k,//out port
      if impi(port_number)<>0 then
	message('selected port is already connected'),
	xset('color',dash)
	return
      end
      typpfrom='in'
    else
      port_number=k-prod(size(find(typout==1)))
      if cop(port_number)<>0 then
	message('selected port is already connected'),
	xset('color',dash)
	return
      end
      typpfrom='evtout'
    end
    fromsplit=%f
    clr=default_color(typo)
    szout=getportsiz(o1,port_number,typpfrom)
    from=[kfrom,port_number,b2m(typpfrom=='in'|typpfrom=='evtin')]
    xl=xo
    yl=yo
  end

  //----------- get link path ----------------------------------------
  //------------------------------------------------------------------
  xset('color',clr);
  xtape_status=xget('recording')
  // record the objects in graphics
  [echa,echb]=xgetech();
  xclear(curwin,%t);
  xset("recording",1);
  xsetech(echa,echb);
  drawobjs(scs_m);
  xset('recording',0);

  while %t do ; //loop on link segments
    xe=xo;ye=yo
    xpoly([xo;xe],[yo;ye])
    rep(3)=-1
    while rep(3)==-1 do //get a new point

      rep=xgetmouse(clearq=%f)
      // redraw the non moving objects.
      xset("recording",1);
      xclear(curwin,%f);
      xtape('replay',curwin);
      xset("recording",0);

      if rep(3)==2 then 
	if pixmap then xset('wshow'),end
	xset('color',dash)
	xset("recording",xtape_status);
	return
      end
      //plot new position of last link segment
      xe=rep(1);ye=rep(2)
      xpoly([xl;xe],[yl;ye])
      if pixmap then xset('wshow'),end
    end
    kto=getblock(scs_m,[xe;ye])
    if ~isempty(kto) then //new point designs the "to block"
      o2=scs_m.objs(kto);
      graphics2=o2.graphics;
      orig  = graphics2.orig
      sz    = graphics2.sz
      ip    = graphics2.pin
      impo  = graphics2.pout
      cip   = graphics2.pein
      [xin,yin,typin]=getinputports(o2)
      //check connection
      if isempty(xin) then
	message('This block has no input port'),
	xset("recording",1);
	xclear(curwin,%f);
	xtape('replay',curwin);
	xset("recording",0);
//	xpoly([xl;xe],[yl;ye])
	if pixmap then xset('wshow'),end
	xset('color',dash)
	xset("recording",xtape_status);
	return
      end
      [m,kp2]=min((ye-yin).^2+(xe-xin).^2)
      k=kp2
      xc2=xin(k);yc2=yin(k);typi=typin(k)
      if typo<>typi
	message(['selected ports don''t have the same type'
		 'The port at the origin of the link has type '+string(typo);
		 'the port at the end has type '+string(typin(k))])
	xset("recording",1);
	xclear(curwin,%f);
	xtape('replay',curwin);
	xset("recording",0);
	//xpoly([xl;xe],[yl;ye])
	if pixmap then xset('wshow'),end
	xset('color',dash)
	xset("recording",xtape_status);
	return
      end
      if typi==1 then
	port_number=k
	if ip(port_number)<>0 then
	  message('selected port is already connected'),
	  xset("recording",1);
	  xclear(curwin,%f);
	  xtape('replay',curwin);
	  xset("recording",0);
	  //xpoly([xl;xe],[yl;ye])
	  if pixmap then xset('wshow'),end
	  xset('color',dash)
	  xset("recording",xtape_status);
	  return
	end
	typpto='in'
	szin=getportsiz(o2,port_number,'in')
	if szin<>szout & min([szin szout])>0 then
	  message(['Warning';
		   'selected ports don''t have the same  size';
		   'The port at the origin of the link has size '+string(szout);
		   'the port at the end has size '+string(szin)])
	end
      elseif (typi==2 & k<=size(ip,'*')) then //implicit "input" port
	port_number=k
	if ip(port_number)<>0 then
	  message('selected port is already connected'),
	  xset("recording",1);
	  xclear(curwin,%f);
	  xtape('replay',curwin);
	  xset("recording",0);
	  //xpoly([xl;xe],[yl;ye],'lines') //erase
	  if pixmap then xset('wshow'),end
	  xset('color',dash)
	  xset("recording",xtape_status);
	  return
	end
	typpto='in'
	szin=getportsiz(o2,port_number,'in')
	if szin<>szout & min([szin szout])>0 then
	  message(['Warning';
		   'selected ports don''t have the same  size';
		   'The port at the origin of the link has size '+string(szout);
		   'the port at the end has size '+string(szin)])
	end
      elseif (typi==2 & k>size(ip,'*')) then //implicit "output" port
	k=k-size(ip,'*')
	typpto='out'
	port_number=k
	if impo(port_number)<>0 then
	  message('selected port is already connected'),
	  xset("recording",1);
	  xclear(curwin,%f);
	  xtape('replay',curwin);
	  xset("recording",0);
	  //xpoly([xl;xe],[yl;ye],'lines') //erase
	  if pixmap then xset('wshow'),end
	  xset('color',dash)
	  xset("recording",xtape_status);
	  return
	end
	typpto='out'
	szin=getportsiz(o2,port_number,'out')
	if szin<>szout & min([szin szout])>0 then
	  message(['Warning';
		   'selected ports don''t have the same  size';
		   'The port at the origin of the link has size '+string(szout);
		   'the port at the end has size '+string(szin)])
	end
      else
	port_number=k-prod(size(find(typin==1)))
	if cip(port_number)<>0 then
	  message('selected port is already connected'),
	  xset("recording",1);
	  xclear(curwin,%f);
	  xtape('replay',curwin);
	  xset("recording",0);
	  //xpoly([xl;xe],[yl;ye])
	  if pixmap then xset('wshow'),end
	  xset('color',dash)
	  xset("recording",xtape_status);
	  return
	end
	typpto='evtin'
	szin=getportsiz(o2,port_number,'evtin')
	if szin<>szout & min([szin szout])>0 then
	  message(['Warning';
		   'selected ports don''t have the same  size'
		   'The port at the origin of the link has size '+string(szout);
		   'the port at the end has size '+string(szin)])
	end
      end
      xpoly([xo;xe],[yo;ye])
      xpoly([xo;xc2],[yo;yc2])
      if pixmap then xset('wshow'),end
      if kto==kfrom&size(xl,'*')==1 then
        //direct link between two port of the same block (add a point)
        xl=[xl;(xl+xc2)/2]
        yl=[yl;(yl+yc2)/2]
      end
      break;
    else //new point ends current line segment
      if xe<>xo|ye<>yo then //to avoid null length segments
	xc2=xe;yc2=ye
	xpoly([xo;xc2],[yo;yc2])
	if abs(xo-xc2)<abs(yo-yc2) then
	  xc2=xo
	else
	  yc2=yo
	end
	xpoly([xo;xc2],[yo;yc2])
	if pixmap then xset('wshow'),end
	xl=[xl;xc2]
	yl=[yl;yc2]
	xo=xc2
	yo=yc2
      end
    end
  end ; //loop on link segments

  //make last segment horizontal or vertical
  typ=typo
  to=[kto,port_number,b2m(typpto=='in'|typpto=='evtin')]
  if from==to then
    message('selected port is already connected'),
    xset("recording",1);
    xclear(curwin,%f);
    xtape('replay',curwin);
    xset("recording",0);
    //xpoly([xl;xe],[yl;ye],'lines')
    if pixmap then xset('wshow'),end
      xset('color',dash)
      xset("recording",xtape_status);
    return
  end

  nx=prod(size(xl))
  if nx==1 then //1 segment link

    if fromsplit&(xl<>xc2|yl<>yc2) then
      //try to move split point
      if xx(wh)==xx(wh+1) then //split is on a vertical link
	if (yy(wh)-yc2)*(yy(wh+1)-yc2)<0 then
	  //erase last segment
	  //xpoly([xl;xc2],[yl;yc2])
	  yl=yc2,
	  //draw last segment
	  xset("recording",1);
	  xclear(curwin,%f);
	  xtape('replay',curwin);
	  xset("recording",0);
	  xpoly([xl;xc2],[yl;yc2])
	  if pixmap then xset('wshow'),end
	end
      elseif yy(wh)==yy(wh+1) then //split is on a horizontal link
	if (xx(wh)-xc2)*(xx(wh+1)-xc2)<0 then
	  //erase last segment
	  //xpoly([xl;xc2],[yl;yc2])
	  xl=xc2,
	  //draw last segment
	  xset("recording",1);
	  xclear(curwin,%f);
	  xtape('replay',curwin);
	  xset("recording",0);
	  xpoly([xl;xc2],[yl;yc2])
	  if pixmap then xset('wshow'),end
	end
      end
      d=[xl,yl]
    end
    //form link datas
    xl=[xl;xc2];yl=[yl;yc2]
  else
    if xl(nx)==xl(nx-1) then 
      //previous segment is vertical

      //erase last and previous segments
      //xpoly([xl(nx-1);xl(nx);xo;xc2],[yl(nx-1);yl(nx);yo;yc2])
      //draw last 2 segments
      xset("recording",1);
      xclear(curwin,%f);
      xtape('replay',curwin);
      xset("recording",0);
      xpoly([xl(nx-1);xl(nx);xc2],[yl(nx-1);yc2;yc2])
      if pixmap then xset('wshow'),end
      //form link datas
      xl=[xl;xc2];yl=[yl(1:nx-1);yc2;yc2]
    elseif yl(nx)==yl(nx-1) then 
      //previous segment is horizontal

      //erase last and previous segments
      //xpoly([xl(nx-1);xl(nx);xo;xc2],[yl(nx-1);yl(nx);yo;yc2])
      //draw last 2 sgements
      xset("recording",1);
      xclear(curwin,%f);
      xtape('replay',curwin);
      xset("recording",0);
      xpoly([xl(nx-1);xc2;xc2],[yl(nx-1);yl(nx);yc2])
      if pixmap then xset('wshow'),end
      //form link datas
      xl=[xl(1:nx-1);xc2;xc2];yl=[yl;yc2]
    else //previous segment is oblique
	 //nothing particular is done
	 xl=[xl;xc2];yl=[yl;yc2]
    end
  end
  lk=scicos_link(xx=xl,yy=yl,ct=[clr,typ],from=from,to=to)

  xset("recording",1);
  xclear(curwin,%f);
  xtape('replay',curwin);
  xset("recording",0);
  drawobj(lk)
  xset("recording",xtape_status);
  //----------- update objects structure -----------------------------
  //------------------------------------------------------------------
  if fromsplit then //link comes from a split
    nx=length(scs_m.objs)+1
    //split old link
    from1=o1.from
    to1=o1.to
    link1=o1;
    link1.xx   = [xx(1:wh);d(1)];
    link1.yy   = [yy(1:wh);d(2)];
    link1.to   = [nx,1,1]

    link2=o1;
    link2.xx   = [d(1);xx(wh+1:size(xx,1))];
    link2.yy   = [d(2);yy(wh+1:size(yy,1))];
    link2.from = [nx,1,0];


    // create split block
    if typo==1 then
      sp=SPLIT_f('define')
      sp.graphics.orig = d;
      sp.graphics.pin  = ks;
      sp.graphics.pout = [nx+1;nx+2];
      SPLIT_f('plot',sp)
    elseif typo==2 then
      sp=IMPSPLIT_f('define')
      sp.graphics.orig = d;
      sp.graphics.pin  = ks;
      sp.graphics.pout = [nx+1;nx+2];
      inoutfrom='out'
      IMPSPLIT_f('plot',sp)
    else
      sp=CLKSPLIT_f('define')
      sp.graphics.orig  = d;
      sp.graphics.pein  = ks;
      sp.graphics.peout = [nx+1;nx+2];
      CLKSPLIT_f('plot',sp)
    end

    scs_m.objs(ks)=link1;
    scs_m.objs(nx)=sp
    scs_m.objs(nx+1)=link2;
    scs_m.objs(to1(1))=mark_prt(scs_m.objs(to1(1)),to1(2),outin(to1(3)+1),typ,nx+1)
  end

  //add new link in objects structure
  nx=length(scs_m.objs)+1
  scs_m.objs($+1)=lk
  //update connected blocks
  scs_m.objs(kfrom)=mark_prt(scs_m.objs(kfrom),from(2),outin(from(3)+1),typ,nx)
  scs_m.objs(kto)=mark_prt(scs_m.objs(kto),to(2),outin(to(3)+1),typ,nx)

  xset("recording",1);
  xclear(curwin,%f);
  xtape('replay',curwin);
  drawobj(lk)
  xset("recording",0);
  xset('color',dash)
  needcompile=4
  resume(scs_m_save,nc_save,enable_undo=%t,edited=%t);
endfunction

function [%pt,scs_m,needcompile]=getlink_new(%pt,scs_m,needcompile)
//edition of a link from an output block to an input  block
// Copyright INRIA
  dash=xget('color')
  outin=['out','in']
  //----------- get link origin --------------------------------------
  //------------------------------------------------------------------
  while %t
    if isempty(%pt) then
      [btn,%pt,win,Cmenu]=cosclick()
      if Cmenu<>"" then
	resume(%win=win,Cmenu=Cmenu,btn=btn)
	return;
      end
    else
      win=%win;
    end
    xc1=%pt(1);yc1=%pt(2);%pt=[]
    [kfrom,wh]=getblocklink(scs_m,[xc1;yc1])
    if ~isempty(kfrom) then o1=scs_m.objs(kfrom);break,end
  end
  scs_m_save=scs_m; nc_save=needcompile; 
  if o1.type =='Link' then  //add a split block
    pt=[xc1;yc1]
    [xx,yy,ct,from,to]=(o1.xx,o1.yy,o1.ct,o1.from,o1.to);
    if (-wh==size(xx,'*')) then
      wh=-(wh+1)
    end

    // get split type
    [xout,yout,typout]=getoutputports(scs_m.objs(from(1)))
    clr=ct(1)
    [m,kp1]=min((yc1-yout).^2+(xc1-xout).^2)
    k=kp1
    typo=ct(2)
    if typo==-1 then typp='evtout',else typp=outin(from(3)+1), end
    szout=getportsiz(scs_m.objs(from(1)),from(2),typp)

    // get initial split position
    wh=wh(1)
    if wh>0 then
      d=projaff(xx(wh:wh+1),yy(wh:wh+1),pt)
    else // a corner
      wh=-wh
      d=[xx(wh);yy(wh)]
    end
    // Note : creation of the split block and modifications of links are
    //        done later, the sequel assumes that the split block is added
    //        at the end of scs_m
    ks=kfrom;
    kfrom=length(scs_m.objs)+1;port_number=2;
    fromsplit=%t
    from=[kfrom,port_number,0]
    xo=d(1);yo=d(2)
    xl=d(1);yl=d(2)
  else //connection comes from a block
    graphics1=o1.graphics
    orig = graphics1.orig
    sz   = graphics1.sz
    io   = graphics1.flip
    op   = graphics1.pout
    impi = graphics1.pin
    cop  = graphics1.peout
    [xout,yout,typout]=getoutputports(o1)
    if isempty(xout) then
      message('This block has no output port'),
      xset('color',dash)
      return
    end
    [m,kp1]=min((yc1-yout).^2+(xc1-xout).^2)
    k=kp1
    xo=xout(k);yo=yout(k);typo=typout(k)
    if typo==1 then
      port_number=k
      if op(port_number)<>0 then
	message('selected port is already connected'),
	xset('color',dash)
	return
      end
      typpfrom='out'
    elseif (typo==2 & k<=size(op,'*')) then //implicit  output port
      port_number=k
      if op(port_number)<>0 then
	message('selected port is already connected'),
	xset('color',dash)
	return
      end
      typpfrom='out'
    elseif (typo==2 & k>size(op,'*')) then //implicit  input port
      k=k-size(op,'*')
      port_number=k,//out port
      if impi(port_number)<>0 then
	message('selected port is already connected'),
	xset('color',dash)
	return
      end
      typpfrom='in'
    else
      port_number=k-prod(size(find(typout==1)))
      if cop(port_number)<>0 then
	message('selected port is already connected'),
	xset('color',dash)
	return
      end
      typpfrom='evtout'
    end
    fromsplit=%f
    clr=default_color(typo)
    szout=getportsiz(o1,port_number,typpfrom)
    from=[kfrom,port_number,b2m(typpfrom=='in'|typpfrom=='evtin')]
    xl=xo
    yl=yo
  end

  //----------- get link path ----------------------------------------
  //------------------------------------------------------------------
  // Make a nex polyline
  xcursor(GDK.PENCIL);
  F=get_current_figure();
  F.start_compound[];
  xpoly(xo,yo);
  C=F.end_compound[];
  C.children(1).color=clr
  P=C.children(1);
  pt=[];
  while %t do ; //loop on link segments
    rep(3)=-1
    n=size(P.x,'*');
    while rep(3)==-1 do 
      // since the previously acquired point can have been 
      // changed to fit projection we have to check that next 
      // acquisition initial draw is correct. 
      if ~isempty(pt) then 
	if ~pt.equal[[P.x(n),P.y(n)]]
	  P.x(n+1)=pt(1);
	  P.y(n+1)=pt(2);
	end
      end
      // get a new point waiting for click
      F.draw_now[];
      rep=xgetmouse(clearq=%f,cursor=%f)
      F.draw_latter[];
      P.x(n+1)=rep(1);
      P.y(n+1)=rep(2);
      pt=[rep(1),rep(2)];
      if rep(3)==2 then 
	xset('color',dash)
	// abort 
	F.remove[C];
	F.draw_now[];
	return
      end
      //plot new position of last link segment
      xe=rep(1);ye=rep(2)
    end
    // here the last point of P or [xe,ye] is the point 
    // at which a click has occured
    kto=getblock(scs_m,[xe;ye])
    if ~isempty(kto) then 
      //-- new point designs the "to block"
      o2=scs_m.objs(kto);
      graphics2=o2.graphics;
      orig  = graphics2.orig
      sz    = graphics2.sz
      ip    = graphics2.pin
      impo  = graphics2.pout
      cip   = graphics2.pein
      [xin,yin,typin]=getinputports(o2)
      //-- check connection
      if isempty(xin) then
	message('This block has no input port'),
	F.remove[C];
	F.draw_now[];
	xset('color',dash)
	return
      end
      [m,kp2]=min((ye-yin).^2+(xe-xin).^2)
      k=kp2
      xc2=xin(k);yc2=yin(k);typi=typin(k)
      if typo<>typi
	message(['selected ports don''t have the same type'
		 'The port at the origin of the link has type '+string(typo);
		 'the port at the end has type '+string(typin(k))])
	F.remove[C];
	F.draw_now[];
	xset('color',dash)
	return
      end
      if typi==1 then
	port_number=k
	if ip(port_number)<>0 then
	  message('selected port is already connected'),
	  F.remove[C];
	  F.draw_now[];
	  xset('color',dash)
	  return
	end
	typpto='in'
	szin=getportsiz(o2,port_number,'in')
	if szin<>szout & min([szin szout])>0 then
	  message(['Warning';
		   'selected ports don''t have the same  size';
		   'The port at the origin of the link has size '+string(szout);
		   'the port at the end has size '+string(szin)])
	end
      elseif (typi==2 & k<=size(ip,'*')) then //implicit "input" port
	port_number=k
	if ip(port_number)<>0 then
	  message('selected port is already connected'),
	  F.remove[C];
	  F.draw_now[];
	  xset('color',dash)
	  return
	end
	typpto='in'
	szin=getportsiz(o2,port_number,'in')
	if szin<>szout & min([szin szout])>0 then
	  message(['Warning';
		   'selected ports don''t have the same  size';
		   'The port at the origin of the link has size '+string(szout);
		   'the port at the end has size '+string(szin)])
	end
      elseif (typi==2 & k>size(ip,'*')) then //implicit "output" port
	k=k-size(ip,'*')
	typpto='out'
	port_number=k
	if impo(port_number)<>0 then
	  message('selected port is already connected'),
	  F.remove[C];
	  F.draw_now[];
	  xset('color',dash)
	  return
	end
	typpto='out'
	szin=getportsiz(o2,port_number,'out')
	if szin<>szout & min([szin szout])>0 then
	  message(['Warning';
		   'selected ports don''t have the same  size';
		   'The port at the origin of the link has size '+string(szout);
		   'the port at the end has size '+string(szin)])
	end
      else
	port_number=k-prod(size(find(typin==1)))
	if cip(port_number)<>0 then
	  message('selected port is already connected'),
	  F.remove[C];
	  F.draw_now[];
	  xset('color',dash)
	  return
	end
	typpto='evtin'
	szin=getportsiz(o2,port_number,'evtin')
	if szin<>szout & min([szin szout])>0 then
	  message(['Warning';
		   'selected ports don''t have the same  size'
		   'The port at the origin of the link has size '+string(szout);
		   'the port at the end has size '+string(szin)])
	end
      end
      F.draw_latter[];
      P.x(n+1)=xc2;
      P.y(n+1)=yc2;
      // F.draw_now[];
      xo=xc2;yo=yc2;
      break;
    else
      // -- new point ends current line segment
      if xe<>xo | ye<>yo then //to avoid null length segments
	xc2=xe;yc2=ye
	if abs(xo-xc2)<abs(yo-yc2) then
	  xc2=xo
	else
	  yc2=yo
	end
	F.draw_latter[];
	P.x(n+1)=xc2;
	P.y(n+1)=yc2;
	// avoid that new point is in previous segment 
	if n>=2 && P.x(n) == P.x(n-1) && P.x(n+1)== P.x(n) then 
	    P.y(n)= [];
	    P.x(n)= [];
	end
	if n>=2 && P.y(n) == P.y(n-1) && P.y(n+1)== P.y(n) then 
	    P.x(n)= [];
	    P.y(n)= [];
	end
	// F.draw_now[];
	xo=xc2;yo=yc2;
      end
    end
  end ; //loop on link segments
  
  // now we try to improve the path-link 
  xl=P.x';
  yl=P.y';

  //make last segment horizontal or vertical
  typ=typo;
  to=[kto,port_number,b2m(typpto=='in'|typpto=='evtin')]
  nx=prod(size(xl))
  if nx==2 then 
    // link is one segment since [xc2,yc2] is already stored
    if fromsplit&(xl<>xc2|yl<>yc2) then
      //try to move split point
      if xx(wh)==xx(wh+1) then //split is on a vertical link
	if (yy(wh)-yc2)*(yy(wh+1)-yc2)<0 then
	  //erase last segment
	  yl($)=yc2;
	end
      elseif yy(wh)==yy(wh+1) then //split is on a horizontal link
	if (xx(wh)-xc2)*(xx(wh+1)-xc2)<0 then
	  //erase last segment
	  xl($)=xc2;
	  //draw last segment
	end
      end
      d=[xl,yl]
    end
  else
    if xl(nx-1)==xl(nx-2) then 
      //previous segment is vertical 
      //form link datas
      yl($-1)=yl($);
    elseif yl(nx-1)==yl(nx-2) then 
      //previous segment is horizontal 
      //form link datas
      xl($-1)=xl($);
    else //previous segment is oblique
      //nothing particular is done
    end
  end
  
  // remove temporary path 
  F.draw_latter[]
  F.remove[C]
  
  // prepare new link 
  lk=scicos_link(xx=xl,yy=yl,ct=[clr,typ],from=from,to=to)
  
  //----------- update objects structure -----------------------------
  //------------------------------------------------------------------
  if fromsplit then //link comes from a split
    nx=length(scs_m.objs)+1
    //split old link
    from1=o1.from
    to1=o1.to
    link1=o1;
    link1.xx   = [xx(1:wh);d(1)];
    link1.yy   = [yy(1:wh);d(2)];
    link1.to   = [nx,1,1]
    
    link2=o1;
    link2.xx   = [d(1);xx(wh+1:size(xx,1))];
    link2.yy   = [d(2);yy(wh+1:size(yy,1))];
    link2.from = [nx,1,0];
    
    // create split block
    if typo==1 then
      sp=SPLIT_f('define')
      sp.graphics.orig = d;
      sp.graphics.pin  = ks;
      sp.graphics.pout = [nx+1;nx+2];
      SPLIT_f('plot',sp)
    elseif typo==2 then
      sp=IMPSPLIT_f('define')
      sp.graphics.orig = d;
      sp.graphics.pin  = ks;
      sp.graphics.pout = [nx+1;nx+2];
      inoutfrom='out'
      IMPSPLIT_f('plot',sp)
    else
      sp=CLKSPLIT_f('define')
      sp.graphics.orig  = d;
      sp.graphics.pein  = ks;
      sp.graphics.peout = [nx+1;nx+2];
      CLKSPLIT_f('plot',sp)
    end
    
    // update the graphic parts 
    // 1 remove the o1 graphics 
    F.remove[o1.gr];
    // register the 3 new graphic objects 
    F.start_compound[];
    drawobj(link1);
    link1.gr = F.end_compound[];
    scs_m.objs(ks)=link1;

    F.start_compound[];
    drawobj(sp);
    sp.gr = F.end_compound[];
    scs_m.objs(nx)=sp;
    
    F.start_compound[];
    drawobj(link2);
    link2.gr = F.end_compound[];
    scs_m.objs(nx+1)=link2;
    scs_m.objs(to1(1))=mark_prt(scs_m.objs(to1(1)),to1(2),outin(to1(3)+1),typ,nx+1)
  end
  
  //add new link in objects structure
  nx=length(scs_m.objs)+1

  F.start_compound[];
  drawobj(lk)
  C=F.end_compound[];
  lk.gr = C;
  scs_m.objs($+1)=lk
  //update connected blocks
  scs_m.objs(kfrom)=mark_prt(scs_m.objs(kfrom),from(2),outin(from(3)+1),typ,nx)
  scs_m.objs(kto)=mark_prt(scs_m.objs(kto),to(2),outin(to(3)+1),typ,nx)
  
  F.draw_now[];
  xset('color',dash)
  needcompile=4
  
  resume(scs_m_save,nc_save,enable_undo=%t,edited=%t);
endfunction
