function Link_()
// interactively acquire a link 
// standard method 
  Cmenu=''
  xinfo('Click link origin, drag, click left for final or intermediate points or right to cancel')
  [scs_m,needcompile]=do_getlink(%pt,scs_m,needcompile);
  %pt=[];Select=[];
  xinfo(' ')
endfunction

function SmartLink_()
// interactively acquire a link 
// smart method 
  [scs_m, needcompile]=do_getlink(%pt,scs_m,needcompile,%t);
  Cmenu='';%pt=[];Select=[];
endfunction

function [scs_m,needcompile]=do_getlink(%pt,scs_m,needcompile,smart)
// edition of a link from an output block to an input  block
// Copyright INRIA
  dash=xget('color')
  if nargin<4 then smart=%t,end
  rel=15/100
  outin=['out','in']
  //----------- get link origin --------------------------------------
  //------------------------------------------------------------------
  win=%win;
  xc1=%pt(1);yc1=%pt(2);
  [kfrom,wh]=getblocklink(scs_m,[xc1;yc1])
  if ~isempty(kfrom) then
    o1=scs_m.objs(kfrom)
  else
    return
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
    if typp=='out'|typp=='in' then
     szouttyp=getporttyp(scs_m.objs(from(1)),from(2),typp)
    end

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
    orig  = graphics1.orig
    sz    = graphics1.sz
    theta = graphics1.theta
    io    = graphics1.flip
    op    = graphics1.pout
    impi  = graphics1.pin
    cop   = graphics1.peout
    [xout,yout,typout]=getoutputports(o1);
    // compatibility with imported schemas
    // in_implicit must be string
    if isempty(graphics1.in_implicit) then 
      graphics1.in_implicit=m2s([]);
    end
    i_ImplIndx=find(graphics1.in_implicit=='I')
    if isempty(xout) then
      hilite_obj(kfrom)
      message('This block has no output port')
      unhilite_obj(kfrom)
      xset('color',dash)
      return
    end
    xxx=rotate([xout;yout],...
               theta*%pi/180,...
               [orig(1)+sz(1)/2;orig(2)+sz(2)/2]);
    xout=xxx(1,:);
    yout=xxx(2,:);
    [m,kp1]=min((yc1-yout).^2+(xc1-xout).^2)
    k=kp1
    xo=xout(k);yo=yout(k);typo=typout(k)
    if typo==1|typo==3 then
      port_number=k
      if op(port_number)<>0 then
        hilite_obj(kfrom)
	message('selected port is already connected')
        unhilite_obj(kfrom)
	xset('color',dash)
	return
      end
      typpfrom='out'
    elseif (typo==2 & k<=size(op,'*')) then //implicit  output port
      port_number=k
      if op(port_number)<>0 then
        hilite_obj(kfrom)
	message('selected port is already connected')
        unhilite_obj(kfrom)
	xset('color',dash)
	return
      end
      typpfrom='out'
    elseif (typo==2 & k>size(op,'*')+size(cop,'*')) then //implicit  input port
      typpfrom='in' 
      k=k-size(op,'*')-size(cop,'*')
//      port_number=k,//out port
      port_number=i_ImplIndx(k)
      if impi(port_number)<>0 then
        hilite_obj(kfrom)
	message('selected port is already connected'),
        unhilite_obj(kfrom)
	xset('color',dash)
	return
      end
      typpfrom='in'
    else
      port_number=k-size(op,'*') //k-prod(size(find(typout==1)))
      if cop(port_number)<>0 then
        hilite_obj(kfrom)
	message('selected port is already connected'),
        unhilite_obj(kfrom)
	xset('color',dash)
	return
      end
      typpfrom='evtout'
    end
    fromsplit=%f
    clr=default_color(typo)
    szout=getportsiz(o1,port_number,typpfrom)
    if typpfrom=='out'|typpfrom=='in' then
      szouttyp=getporttyp(o1,port_number,typpfrom)
    end
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
      rep=xgetmouse(clearq=%t,getrelease=%f,cursor=%f)
      F.draw_latter[];
      if rep(3)==2 then 
	xset('color',dash)
	// abort 
	F.remove[C];
	F.draw_now[];
	return
      elseif rep(3)==-5 then
         kto=getblock(scs_m,[rep(1);rep(2)])
         if isempty(kto) then rep(3)=-1, end
      end
      //plot new position of last link segment
      xe=rep(1);ye=rep(2)
      P.x(n+1)=rep(1);
      P.y(n+1)=rep(2);
      pt=[rep(1),rep(2)];
      F.draw_now[];
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
      theta = graphics2.theta
      ip    = graphics2.pin
      impo  = graphics2.pout
      cip   = graphics2.pein
      [xin,yin,typin]=getinputports(o2)
      if isempty(graphics2.out_implicit) then 
	graphics2.out_implicit=m2s([]);
      end
      o_ImplIndx=find(graphics2.out_implicit=='I')
      //-- check connection
      if isempty(xin) then
        hilite_obj(kto)
	message('This block has no input port'),
        unhilite_obj(kto)
        F.draw_latter[];
	F.remove[C];
	F.draw_now[];
	xset('color',dash)
	return
      end
      xxx=rotate([xin;yin],...
                 theta*%pi/180,...
                 [orig(1)+sz(1)/2;orig(2)+sz(2)/2]);
      xin=xxx(1,:);
      yin=xxx(2,:);
      [m,kp2]=min((ye-yin).^2+(xe-xin).^2)
      k=kp2
      xc2=xin(k);yc2=yin(k);typi=typin(k)
      if typo<>typi
        hilite_obj(kto)
	message(['selected ports don''t have the same type'
		 'The port at the origin of the link has type '+string(typo);
		 'the port at the end has type '+string(typin(k))])
        unhilite_obj(kto)
        F.draw_latter[];
	F.remove[C];
	F.draw_now[];
	xset('color',dash)
	return
      end
      if typi==1|typi==3 then
	port_number=k
	if ip(port_number)<>0 then
          hilite_obj(kto)
	  message('selected port is already connected'),
          unhilite_obj(kto)
          F.draw_latter[];
	  F.remove[C];
	  F.draw_now[];
	  xset('color',dash)
	  return
	end
	typpto='in'
	szin=getportsiz(o2,port_number,'in')
        need_warning = %f;
        if (szin(1)<>szout(1)) & min([szin(1) szout(1)])>0 then
          need_warning=%t
        end
        szout2=[];szin2=[];
        if size(szout,'*')==1 then
           szout2=1;
        else
           szout2=szout(2);
        end

        if size(szin,'*')==1 then
           szin2=1;
        else
           szin2=szin(2);
        end
        if (szin2<>szout2) & min([szin2 szout2])>0 then
          need_warning=%t
        end
        if need_warning then
            hilite_obj(kto)
            message(['Warning :';
                     'Selected ports don''t have the same size';
                     'The port at the origin of the link has size '+sci2exp(szout);
                     'the port at the end has size '+sci2exp(szin)+'.'])
            unhilite_obj(kto)
        end
// 	if szin<>szout & min([szin szout])>0 then
// 	  message(['Warning';
// 		   'selected ports don''t have the same  size';
// 		   'The port at the origin of the link has size '+string(szout);
// 		   'the port at the end has size '+string(szin)])
// 	end        szintyp=getporttyp(o2,port_number,'in')
        szintyp=getporttyp(o2,port_number,'in')
        if (szintyp>0 & szouttyp>0) then //if-then-else, event-select blocks case and all the -1 intyp/outtyp
          if szintyp<>szouttyp then
            tt_typ=['double';'complex';'int32';'int16';
                    'int8';'uint32';'uint16';'uint8';'boolean']

            hilite_obj(kto)
            message(['Warning :';
                     'Selected ports don''t have the same data type';
                     'The port at the origin of the link has datatype '+...
                      tt_typ(szouttyp)+' ('+sci2exp(szouttyp)+')';
                     'the port at the end has datatype '+...
                      tt_typ(szintyp)+' ('+sci2exp(szintyp)+')'+'.'])
            unhilite_obj(kto)
          end
        end
      elseif (typi==2 & k<=size(ip,'*')) then //implicit "input" port
	port_number=k
	if ip(port_number)<>0 then
          hilite_obj(kto)
	  message('selected port is already connected')
          unhilite_obj(kto)
          F.draw_latter[];
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
      elseif (typi==2 & k>size(ip,'*')+size(cip,'*')) then //implicit "output" port
	k=k-size(ip,'*')-size(cip,'*')
	typpto='out'
	//port_number=k
        port_number=o_ImplIndx(k)
	if impo(port_number)<>0 then
          hilite_obj(kto)
	  message('selected port is already connected')
          unhilite_obj(kto)
          F.draw_latter[];
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
	port_number=k-size(ip,'*')  //port_number=k-prod(size(find(typin==1)))
	if cip(port_number)<>0 then
          hilite_obj(kto)
	  message('selected port is already connected'),
          unhilite_obj(kto)
          F.draw_latter[];
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
      //P.x(n+1)=xc2;
      //P.y(n+1)=yc2;
      // F.draw_now[];
      //xo=xc2;yo=yc2;
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
	F.draw_now[];
        xl=[xl;xc2]
        yl=[yl;yc2]
	xo=xc2;yo=yc2;
      end
    end
  end ; //loop on link segments
  
  // now we try to improve the path-link 
  //xl=P.x';
  //yl=P.y';

  //make last segment horizontal or vertical
  typ=typo;
  to=[kto,port_number,b2m(typpto=='in'|typpto=='evtin')]
  nx=prod(size(xl))
  
  if nx==1 then
    if fromsplit&(xl<>xc2|yl<>yc2) then
      if xx(wh)==xx(wh+1) then
        if (yy(wh)-yc2)*(yy(wh+1)-yc2)<0 then yl=yc2, end
      elseif yy(wh)==yy(wh+1) then
        if (xx(wh)-xc2)*(xx(wh+1)-xc2)<0 then xl=xc2, end
      end
      d=[xl,yl]
    elseif kto==kfrom then
      // XXX here we should change the path to 
      // avoid crossing the block 
      xl=[xl;(xl+xc2)/2]
      yl=[yl;(yl+yc2)/2]
    end
    xl=[xl;xc2];yl=[yl;yc2]
  else
    if xl(nx)==xl(nx-1) then
      nx=prod(size(xl))
      xl=[xl;xc2];yl=[yl(1:nx-1);yc2;yc2]
    elseif yl(nx)==yl(nx-1) then
      nx=prod(size(xl))
      xl=[xl(1:nx-1);xc2;xc2];yl=[yl;yc2]
    else 
      xl=[xl;xc2];yl=[yl;yc2]
    end
  end  
  // remove temporary path 
  F.draw_latter[]
  F.remove[C]
    
  // prepare new link 
  lk=scicos_link(xx=xl,yy=yl,ct=[clr,typ],from=from,to=to)
  if typ==3 then
    lk.thick=[2 2]
  end
  
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
      //SPLIT_f('plot',sp)
    elseif typo==2 then
      sp=IMPSPLIT_f('define')
      sp.graphics.orig = d;
      sp.graphics.pin  = ks;
      sp.graphics.pout = [nx+1;nx+2];
      inoutfrom='out'
      //IMPSPLIT_f('plot',sp)
    elseif typo==3 then
      sp=BUSSPLIT('define')
      sp.graphics.orig = d;
      sp.graphics.pin  = ks;
      sp.graphics.pout = [nx+1;nx+2];
      //BUSSPLIT('plot',sp)
    else
      sp=CLKSPLIT_f('define')
      sp.graphics.orig  = d;
      sp.graphics.pein  = ks;
      sp.graphics.peout = [nx+1;nx+2];
      // CLKSPLIT_f('plot',sp)
    end

    // update the graphic parts 
    // 1 remove the o1 graphics 
    F.remove[o1.gr];
    // register the 3 new graphic objects 
    link1=drawobj(link1,F);
    scs_m.objs(ks)=link1;

    sp=drawobj(sp,F);
    scs_m.objs(nx)=sp;
    
    link2=drawobj(link2,F);
    scs_m.objs(nx+1)=link2;
    scs_m.objs(to1(1))=mark_prt(scs_m.objs(to1(1)),to1(2),outin(to1(3)+1),typ,nx+1)
  end
  
  //add new link in objects structure
  nx=length(scs_m.objs)+1
  //pause
  movedblock=[];moving=0
  if size(lk.xx,'*')==2 then
   //if scs_m.objs(kfrom).graphics.theta==0&scs_m.objs(kto).graphics.theta==0 then
    dx=lk.xx(1)-lk.xx(2);dy=lk.yy(1)-lk.yy(2);
    if abs(dx)<rel*abs(dy) then
      dy=0;moving=1
    elseif abs(dy)<rel*abs(dx) then
      dx=0;moving=1
    end
    if moving then
      if isempty(get_connected(scs_m,kto)) then
        scs_m.objs(kto).graphics.orig=scs_m.objs(kto).graphics.orig+[dx,dy]
        lk.xx(2)=lk.xx(2)+dx;lk.yy(2)=lk.yy(2)+dy
        movedblock=kto
      elseif isempty(get_connected(scs_m,kfrom)) then
        scs_m.objs(kfrom).graphics.orig=scs_m.objs(kfrom).graphics.orig-[dx,dy]
        lk.xx(1)=lk.xx(1)-dx;lk.yy(1)=lk.yy(1)-dy
        dx=-dx;dy=-dy
        movedblock=kfrom
      end
    end
  end
  if ~isempty(movedblock) then
    o=scs_m.objs(movedblock)
    o.gr.translate[[dx dy]];
  end
  if smart then 
    // improve link routing 
    lk=scicos_route(lk,scs_m),
  end
  lk=drawobj(lk,F)
  scs_m.objs($+1)=lk
  //update connected blocks
  scs_m.objs(kfrom)=mark_prt(scs_m.objs(kfrom),from(2),outin(from(3)+1),typ,nx)
  scs_m.objs(kto)=mark_prt(scs_m.objs(kto),to(2),outin(to(3)+1),typ,nx)
  F.draw_now[];
  xset('color',dash)
  needcompile=4
  resume(scs_m_save,nc_save,enable_undo=%t,edited=%t);
endfunction
