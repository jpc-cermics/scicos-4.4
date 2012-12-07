function scmenu_getlink()
// interactively acquire a link 
// standard method 
  Cmenu=''
  xinfo('Click link origin, drag, click left for final or intermediate points or right to cancel')
  [scs_m,needcompile]=do_getlink(%pt,scs_m,needcompile,%t);
  %pt=[];Select=[];
  xinfo(' ')
endfunction
//alan reversed link and smartlink sept/2012
function scmenu_smart_getlink()
// interactively acquire a link 
// smart method
  [scs_m, needcompile]=do_getlink(%pt,scs_m,needcompile,%f);
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

  scs_m_save=scs_m;
  nc_save=needcompile;

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

    //new feature, alan xx/11/2012 :hilite split
    F=get_current_figure();
    w=7;h=7;
    xrect(xo-w/2,yo+h/2,w,h,color=10);
    gr_out=F.children(1).children($);

  else //connection comes from a block
    [connected,port_number,xyo,typo,typpfrom]=get_port(o1,'from',%pt)

    if connected then return, end

    if isempty(xyo) then
      hilite_obj(kfrom)
      message('This block has no output port')
      unhilite_obj(kfrom)
      xset('color',dash)
      return
    end

    xo=xyo(1);yo=xyo(2);
    szout=getportsiz(o1,port_number,typpfrom)
    if typpfrom=='out'|typpfrom=='in' then
      szouttyp=getporttyp(o1,port_number,typpfrom)
    end
    from=[kfrom,port_number,b2m(typpfrom=='in'|typpfrom=='evtin')]

    fromsplit=%f
    clr=default_color(typo)

    //new feature, alan xx/11/2012 : hilite port
    F=get_current_figure();
    gr_out=hilite_port(xo,yo,o1)

    orig  = o1.graphics.orig
    sz    = o1.graphics.sz
    theta = o1.graphics.theta
    xxx=rotate([xo;yo],...
               theta*%pi/180,...
               [orig(1)+sz(1)/2;orig(2)+sz(2)/2]);
    xo=xxx(1,:);
    yo=xxx(2,:);
    xl=xo
    yl=yo

  end

  //----------- get link path ----------------------------------------
  //------------------------------------------------------------------
  // Make a new polyline
  xcursor(GDK.PENCIL);
  F.start_compound[];
  xpoly(xo,yo);
  C=F.end_compound[];
  C.children(1).color=clr
  P=C.children(1);
  pt=[];
  first=%t;nb=0;

  while %t do ; //loop on link segments
    rep(3)=-1
    n=size(P.x,'*');
    kto=[]
    while rep(3)==-1 do 
      nb=nb+1
      // since the previously acquired point can have been 
      // changed to fit projection we have to check that next 
      // acquisition initial draw is correct. 
      if ~isempty(pt) then 
	if ~pt.equal[[P.x(n),P.y(n)]]
	  P.x(n+1)=pt(1);
	  P.y(n+1)=pt(2);
	end
      end
      P.invalidate[];
      F.process_updates[];
      // get a new point waiting for click
      rep=xgetmouse(clearq=%t,getrelease=%t,cursor=%f)
      P.invalidate[];
      if rep(3)==2 then
        F.remove[gr_out];
        F.remove[C];
        F.invalidate[];
        xset('color',dash)
        return
      elseif rep(3)==-5 then
         if nb<=4 then
           rep(3)=-1
         elseif ~first || nb>10 then
           kto=getblock(scs_m,[rep(1);rep(2)])
           if isempty(kto) then rep(3)=-1, end
         else
           first=%f,rep(3)=-1
         end
      elseif rep(3)~=0 then
        rep(3)=-1
      elseif rep(3)==0 && nb <= 3 then
        rep(3)=-1
      end

      //a=tic();
      kto=getblock(scs_m,[rep(1);rep(2)]);
      if ~isempty(kto) then
        printf("getblock : find a block (%s)\n",scs_m.objs(kto).gui);
      end

      //plot new position of last link segment
      P.x(n+1)=rep(1);
      P.y(n+1)=rep(2);
      pt=[rep(1),rep(2)];
      P.invalidate[];
    end

    // here the last point of P or [xe,ye] is the point 
    // at which a click has occured
    xe=rep(1);ye=rep(2)
    kto=getblock(scs_m,[xe;ye])
    if ~isempty(kto) then 
      //-- new point designs the "to block"
      o2=scs_m.objs(kto);
      [connected,port_number,xyi,typi,typpto]=get_port(o2,'to',[xe;ye])

      if connected then
        F.remove[gr_out];
        F.remove[C];
        F.invalidate[];
        xset('color',dash)
        return
      end

      xin=xyi(1);yin=xyi(2);
      szin=getportsiz(o2,port_number,typpto)
      if typpto=='out'|typpto=='in' then
        szintyp=getporttyp(o2,port_number,typpto)
      end
      to=[kto,port_number,b2m(typpto=='in'|typpto=='evtin')]

      orig  = o2.graphics.orig
      sz    = o2.graphics.sz
      theta = o2.graphics.theta
      xxx=rotate([xin;yin],...
                 theta*%pi/180,...
                 [orig(1)+sz(1)/2;orig(2)+sz(2)/2]);
      xc2=xxx(1,:);
      yc2=xxx(2,:);

      //remove link connected from/to the same port
      if from==to then
        F.remove[gr_out];
        F.remove[C];
        F.invalidate[];
        xset('color',dash)
        return
      end

      //cross size/type checking
      if typo<>typi
        hilite_obj(kto)
        message(['selected ports don''t have the same type'
                 'The port at the origin of the link has type '+string(typo);
                 'the port at the end has type '+string(typi)])
        unhilite_obj(kto)
        F.remove[gr_out];
        F.remove[C];
        F.invalidate[];
        xset('color',dash)
        return
      end

      if typi==1|typi==3 then
        if or(szin<>szout && min([szin;szout],'r')>0) then
          hilite_obj(kto)
          message(['Warning :';
                   'Selected ports don''t have the same size';
                   'The port at the origin of the link has size '+sci2exp(szout);
                   'the port at the end has size '+sci2exp(szin)+'.'])
          unhilite_obj(kto)
        end

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

      elseif typi==2 then
        if or(szin<>szout && min([szin;szout],'r')>0) then
          hilite_obj(kto)
          message(['Warning';
                   'selected ports don''t have the same  size';
                   'The port at the origin of the link has size '+sci2exp(szout);
                   'the port at the end has size '+sci2exp(szin)])
          unhilite_obj(kto)
        end

      else
        if szin<>szout & min([szin szout])>0 then
          hilite_obj(kto)
          message(['Warning';
                   'selected ports don''t have the same  size'
                   'The port at the origin of the link has size '+string(szout);
                   'the port at the end has size '+string(szin)])
          unhilite_obj(kto)
        end
      end
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
	P.x(n+1)=xc2;
	P.y(n+1)=yc2;
        P.invalidate[]
	F.process_updates[]
        xl=[xl;xc2]
        yl=[yl;yc2]
	xo=xc2;yo=yc2;
      end
    end
  end ; //loop on link segments

  selecthilite(Select, %f)

  typ=typo;

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
  //F.draw_latter[]
  F.remove[gr_out];
  F.remove[C]
  F.invalidate[];
    
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
    F.invalidate[];

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
    //improve link routing
    lk=scicos_route(lk,scs_m),
  end
  lk=drawobj(lk,F)
  scs_m.objs($+1)=lk
  //update connected blocks
  scs_m.objs(kfrom)=mark_prt(scs_m.objs(kfrom),from(2),outin(from(3)+1),typ,nx)
  scs_m.objs(kto)=mark_prt(scs_m.objs(kto),to(2),outin(to(3)+1),typ,nx)
  F.invalidate[];
  xset('color',dash)
  needcompile=4
  resume(scs_m_save,nc_save,enable_undo=%t,edited=%t);
endfunction

// hilite port, compute area where
// one can click to link a port
// of a blk and draw a rectangle
// xport,yport port location
// o blk st
function gr=hilite_port(xport,yport,o)

  [x1,y1,sz_x,sz_y]=get_port_bounds(xport,yport,o)

  orig  = o.graphics.orig(:)
  sz    = o.graphics.sz(:)
  theta = o.graphics.theta

  xxx = rotate([x1,x1,x1+sz_x,x1+sz_x;...
                y1,y1-sz_y,y1-sz_y,y1],...
                theta*%pi/180,...
                [orig(1)+sz(1)/2;orig(2)+sz(2)/2])

   xpoly(xxx(1,:),xxx(2,:),type="lines",close=%t,color=10);

   F=get_current_figure();
   gr=F.children(1).children($);
   gr.invalidate[]
endfunction

function [connected,port_number,xyio,typio,typtofrom]=get_port(o,typ,pt)

  connected   = %f
  port_number = []
  xyio        = []
  typio       = []
  typtofrom   = ''

  graphics  = o.graphics
  orig      = graphics.orig
  sz        = graphics.sz
  theta     = graphics.theta

  ip        = graphics.pin
  op        = graphics.pout
  cip       = graphics.pein
  cop       = graphics.peout

  if typ=='to' then
    if isempty(graphics.out_implicit) then
      graphics.out_implicit=m2s([]);
    end
    io_ImplIndx=find(graphics.out_implicit=='I')
    [xinout,yinout,typinout]=getinputports(o)
  elseif typ=='from' then
    if isempty(graphics.in_implicit) then
      graphics.in_implicit=m2s([]);
    end
    io_ImplIndx=find(graphics.in_implicit=='I')
    [xinout,yinout,typinout]=getoutputports(o);
  end

  if isempty(xinout) then return, end

  xxx=rotate([pt(1);pt(2)],...
             -theta*%pi/180,...
             [orig(1)+sz(1)/2;orig(2)+sz(2)/2]);
  xc1=xxx(1,:);
  yc1=xxx(2,:);

  [m,k]=min((yc1-yinout).^2+(xc1-xinout).^2)

  xyio=[xinout(k) yinout(k)]//without rotation
  typio=typinout(k);

  if typio==1|typio==3 then //regular and buses input/output port
    port_number=k
    if typ=='to' then
      if ip(port_number)<>0 then
        connected=%t
      end
      typtofrom='in'

    elseif typ=='from' then
      if op(port_number)<>0 then
        connected=%t
      end
      typtofrom='out'
    end

  elseif (typio==2) then //implicit input/output port
    if typ=='to' then
      if k<=size(ip,'*') then
        port_number=k
        if ip(port_number)<>0 then
          connected=%t
        end
        typtofrom='in'
      elseif (k>size(ip,'*')+size(cip,'*')) then
        port_number=k-size(ip,'*')-size(cip,'*')
        if isempty(io_ImplIndx) then
          port_number=[];
        else
          port_number=io_ImplIndx(port_number)
        end
        if isempty(port_number) || op(port_number)<>0 then
          connected=%t
        end
        typtofrom='out'
      end

    elseif typ=='from' then
      if k<=size(op,'*') then
        port_number=k
        if op(port_number)<>0 then
          connected=%t
        end
        typtofrom='out'
      elseif (k>size(op,'*')+size(cop,'*')) then
        port_number=k-size(op,'*')-size(cop,'*')
        if isempty(io_ImplIndx) then
          port_number=[];
        else
          port_number=io_ImplIndx(port_number)
        end
        if isempty(port_number) || ip(port_number)<>0 then
          connected=%t
        end
        typtofrom='in'
      end
    end

  else //event input/output port
    if typ=='to' then
      port_number=k-size(ip,'*')  //port_number=k-prod(size(find(typin==1)))
      if cip(port_number)<>0 then
        connected=%t
      end
      typtofrom='evtin'

    elseif typ=='from' then
      port_number=k-size(op,'*') //k-prod(size(find(typout==1)))
      if cop(port_number)<>0 then
        connected=%t
      end
      typtofrom='evtout'
    end
  end
endfunction
