function scmenu_smart_move()
// performs a smart move of an object
  Cmenu=''
  if ~isempty(Select) && ~isempty(find(Select(:,2)<>curwin)) then
    // XXX why this part ?
    Select=[]; Cmenu='Smart Move';
    return
  end
  // performs the move
  [scs_m]=do_smart_move(%pt,scs_m,Select)
  %pt=[];
endfunction

function [scs_m]=do_smart_move(%pt,scs_m,Select)
  if ~isempty(Select) && size(Select,1) == 1 &&
    scs_m.objs(Select(1)).type=="Link" then
    [%pt,scs_m,have_moved]=do_stupidsmartmove(%pt,Select,scs_m)
  else
    [scs_m,have_moved]=do_stupidMultimove(%pt,Select,scs_m,smart=%t)
  end
  if have_moved then
    resume(scs_m_save,needreplay,enable_undo=%t,edited=%t,nc_save=needcompile);
  else
    if size(Select,1)>1 then
      if %win == curwin then
        k=getobj(scs_m,%pt)
        if ~isempty(k) then
	  Select=[k,%win];
          resume(Select)
        end
      end
    end
  end
endfunction

function [%pt,scs_m,have_moved]=do_stupidsmartmove(%pt,Select,scs_m)
  rela=15/100;
  have_moved=%f;
  win=%win;
  xc=%pt(1);yc=%pt(2);
  [k,wh,on_pt,scs_m]=stupid_getobj(scs_m,Select,[xc;yc],smart=%t);
  if isempty(k) then return, end;
  scs_m_save=scs_m;
  if scs_m.objs(k).type == 'Link' then
    xcursor(52);
    [scs_m,have_moved]=do_smart_move_link(scs_m,k,xc,yc,-wh-1,on_pt)
    xcursor();
  end
  if have_moved then
    resume(scs_m_save,needreplay,enable_undo=%t,edited=%t,nc_save=needcompile);
  end
endfunction

function [scs_m,have_moved]=do_smart_move_link(scs_m,k,xc,yc,wh,on_pt)
// move the  segment wh of the link k and modify the other segments if necessary
//!
  o=scs_m.objs(k)
  nl=size(o.xx,'*')  // number of link points
  xx=o.gr.children(1).x;
  yy=o.gr.children(1).y;

  // we have clicked on pt of a link
  // we use free mode
  if on_pt then
    [scs_m,have_moved]=stupid_movecorner(scs_m,k,xc,yc,-wh-1)
  else
    // we have selected the first segment
    if wh==1 then
      if is_split(scs_m.objs(o.from(1))) && is_split(scs_m.objs(o.to(1))) &&nl<3 then
        [scs_m,have_moved]=do_smart_move_link1(scs_m,k,xc,yc)

      elseif ~is_split(scs_m.objs(o.from(1)))|| nl < 3 then
        p=projaff(xx(1:2),yy(1:2),[xc,yc]);
        if nl==2 then
          // add a point
          o.gr.invalidate[];
          o.gr.children(1).x = [xx(1);p(1); xx(2:$)];
          o.gr.children(1).y = [yy(1);p(2); yy(2:$)];
          o.gr.invalidate[];
          o.xx = o.gr.children(1).x;
          o.yy = o.gr.children(1).y;
          scs_m.objs(k)=o;
          [scs_m,have_moved]=stupid_movecorner(scs_m,k,xc,yc,-wh-1)
        else
          // add a corner
	  o.gr.invalidate[];
          o.gr.children(1).x = [xx(1);p(1);p(1); xx(2:$)];
          o.gr.children(1).y = [yy(1);p(2);p(2); yy(2:$)];
          o.gr.invalidate[]
          o.xx = o.gr.children(1).x;
          o.yy = o.gr.children(1).y;
          scs_m.objs(k)=o;
          [scs_m,have_moved]=do_smart_move_link(scs_m,k,xc,yc,wh+2,on_pt)
        end
      else
        // link comes from a split
        [scs_m,have_moved]=do_smart_move_link2(scs_m,k,xc,yc)
      end

    // we have selected the last segment
    elseif wh >= nl-1 then
//       if is_split(scs_m.objs(o.from(1))) | nl < 3 then
//         [scs_m,have_moved]=do_smart_move_link2(scs_m,k,xc,yc,nl-1)
      if ~is_split(scs_m.objs(o.to(1))) | nl < 3 then
        // add a corner
        p=projaff(xx($-1:$),yy($-1:$),[xc,yc]);
	o.gr.invalidate[];
        o.gr.children(1).x = [xx(1:$-1);p(1);p(1); xx($)];
        o.gr.children(1).y = [yy(1:$-1);p(2);p(2); yy($)];
        o.gr.invalidate[];
        o.xx = o.gr.children(1).x;
        o.yy = o.gr.children(1).y;
        scs_m.objs(k)=o;
        // and force a move of
        [scs_m,have_moved]=do_smart_move_link(scs_m,k,xc,yc,nl-1,on_pt)
      else
        // link goes to a split
        [scs_m,have_moved]=do_smart_move_link3(scs_m,k,xc,yc)
      end
    elseif nl < 4 then
      pause DEBUG
      //-------------
      F=get_current_figure()
      p=projaff(xx(wh:wh+1),yy(wh:wh+1),[xc,yc])
      o.gr.invalidate[];
      o.gr.children(1).x = [xx(1:wh);p(1);xx(wh+1:$)];
      o.gr.children(1).y = [yy(1:wh);p(2);yy(wh+1:$)];
      o.gr.invalidate[]
      pto=[xc,yc];
      rep(3)=-1
      while rep(3)==-1 ,
        F.process_updates[]
        rep=xgetmouse(clearq=%f,getrelease=%t,cursor=%f);
        if rep(3)==3 then
          global scicos_dblclk
          scicos_dblclk=[rep(1),rep(2),curwin]
        end
        pt = rep(1:2);
        tr= pt - pto;
	o.gr.invalidate[]
        o.gr.children(1).x(wh+1) = o.gr.children(1).x(wh+1) + tr(1);
        o.gr.children(1).y(wh+1) = o.gr.children(1).y(wh+1) + tr(2);
        o.gr.invalidate[]
        pto=pt;
      end
      if rep(3)<>2 then
        o.xx = o.gr.children(1).x;
        o.yy = o.gr.children(1).y;
        scs_m.objs(k)=o
      else
        // undo the move
        F.draw_latter[];
        o.gr.children(1).x = o.xx;
        o.gr.children(1).y = o.yy;
        F.draw_now[];
      end
    else
      [scs_m,have_moved]=do_smart_move_link4(scs_m,k,xc,yc)
    end
  end
endfunction

// review : alan,13/09/13
function [scs_m,have_moved]=do_smart_move_link4(scs_m,k,xc,yc)

  have_moved=%f

  o=scs_m.objs(k);
  xx=o.gr.children(1).x;
  yy=o.gr.children(1).y;
  e=[min(yy(wh:wh+1))-max(yy(wh:wh+1)),min(xx(wh:wh+1))-max(xx(wh:wh+1))];
  if and(e==[0 0]) then
    e=[-1 -1]
  else
    e=e/norm(e)
  end

  F=get_current_figure()
  move_xy = [0 0];
  options=scs_m.props.options

  while 1
    F.process_updates[]
    rep=xgetmouse(clearq=%f,getrelease=%t,cursor=%f);
    o.gr.invalidate[]
    if rep(3)==3 then
      global scicos_dblclk
      scicos_dblclk=[rep(1),rep(2),curwin]
    end
    if or(rep(3)==[0,-5, 2, 3, 5]) then
      break
    end
    [delta_x,delta_y,xc,yc]=get_scicos_delta(rep,xc,yc,options('Snap'),options('Wgrid')(1),options('Wgrid')(2))
    tr=[delta_x , delta_y].*e
    move_xy = move_xy +  tr ;

    //main link
    o.gr.invalidate[]
    o.gr.children(1).x(wh:wh+1) = o.gr.children(1).x(wh:wh+1) - tr(1);
    o.gr.children(1).y(wh:wh+1) = o.gr.children(1).y(wh:wh+1) - tr(2);
    o.gr.invalidate[]
  end

  if rep(3)<>2 then
    [xl,yl]=clean_link(o.gr.children(1).x(:),...
                       o.gr.children(1).y)
    if ~xl.equal[o.xx] || ~yl.equal[o.yy] then
      have_moved=%t
      o.xx = xl;
      o.yy = yl;
      scs_m.objs(k)=o
    end
  else
    // undo the move
    //always clean the link here because we have added intermediate pts
    [xl,yl]=clean_link(o.xx,o.yy)
    if ~xl.equal[o.xx] || ~yl.equal[o.yy] then
      o.xx=xl
      o.yy=yl
      scs_m.objs(k)=o
    end
  end
  o.gr.invalidate[]
  o.gr.children(1).x = o.xx;
  o.gr.children(1).y = o.yy;
  o.gr.invalidate[]
endfunction

//a link entre 2 blocks split
// review : alan,13/09/13
function [scs_m,have_moved]=do_smart_move_link1(scs_m,k,xc,yc)

  have_moved=%f

  o=scs_m.objs(k);
  xx=o.gr.children(1).x;
  yy=o.gr.children(1).y;
  e=[max(yy)-min(yy),max(xx)-min(xx)];
  e=e/norm(e)

  from=o.from;to=o.to
  connected=[get_connected(scs_m,from(1)),...
             get_connected(scs_m,to(1))]

  F=get_current_figure()
  move_xy = [0 0];
  options=scs_m.props.options

  while 1
    F.process_updates[]
    rep=xgetmouse(clearq=%f,getrelease=%t,cursor=%f);
    if rep(3)==3 then
      global scicos_dblclk
      scicos_dblclk=[rep(1),rep(2),curwin]
    end
    if or(rep(3)==[0,-5, 2, 3, 5]) then
      break
    end
    [delta_x,delta_y,xc,yc]=get_scicos_delta(rep,xc,yc,options('Snap'),options('Wgrid')(1),options('Wgrid')(2))
    tr=[delta_x , delta_y].*e
    move_xy = move_xy +  tr ;

    //main link
    o=scs_m.objs(k);
    o.gr.invalidate[]
    o.gr.children(1).x = o.gr.children(1).x + tr(1);
    o.gr.children(1).y = o.gr.children(1).y + tr(2);
    o.gr.invalidate[]

    //update connected links coordinates
    if connected(1)<>k then
      oi=scs_m.objs(connected(1));
      xl=oi.gr.children(1).x
      yl=oi.gr.children(1).y
      if size(oi.gr.children(1).x,'*')>2 then
        if oi.gr.children(1).x($)==xl($-1) then
	  oi.gr.invalidate[]
          oi.gr.children(1).x($-1:$)=xl($-1:$)+tr(1);
          oi.gr.children(1).y($)=yl($)+tr(2);
	  oi.gr.invalidate[]
        elseif oi.gr.children(1).y($)==yl($-1) then
	  oi.gr.invalidate[]
          oi.gr.children(1).x($)=xl($)+tr(1);
          oi.gr.children(1).y($-1:$)=yl($-1:$)+tr(2);
	  oi.gr.invalidate[]
	else
	  oi.gr.invalidate[]
	  oi.gr.children(1).x($)=xl($)+tr(1);
          oi.gr.children(1).y($)=yl($)+tr(2);
	  oi.gr.invalidate[]
        end
      else
	oi.gr.invalidate[]
        oi.gr.children(1).x($)=xl($)+tr(1);
        oi.gr.children(1).y($)=yl($)+tr(2);
	oi.gr.invalidate[]
      end
    end

    for kk=2:size(connected,'*')
      if connected(kk)<>k then
        oi=scs_m.objs(connected(kk));
        xl=oi.gr.children(1).x
        yl=oi.gr.children(1).y
        if size(oi.gr.children(1).x,'*')>2 then
          if oi.gr.children(1).x(1)==xl(2) then
	    oi.gr.invalidate[]
            oi.gr.children(1).x(1:2)=xl(1:2)+tr(1)
            oi.gr.children(1).y(1)=yl(1)+tr(2)
	    oi.gr.invalidate[]
          elseif oi.gr.children(1).y(1)==yl(2) then
	    oi.gr.invalidate[]
            oi.gr.children(1).x(1)=xl(1)+tr(1)
            oi.gr.children(1).y(1:2)=yl(1:2)+tr(2)
	    oi.gr.invalidate[]
          else
	    oi.gr.invalidate[]
            oi.gr.children(1).x(1)=xl(1)+tr(1)
            oi.gr.children(1).y(1)=yl(1)+tr(2)
	    oi.gr.invalidate[]
          end
        else
	  oi.gr.invalidate[]
          oi.gr.children(1).x(1)=xl(1)+tr(1)
          oi.gr.children(1).y(1)=yl(1)+tr(2)
	  oi.gr.invalidate[]
        end
      end
    end

    //update split blockS coordinates
    oi=scs_m.objs(from(1))
    oi.gr.translate[tr];
    oi=scs_m.objs(to(1))
    oi.gr.translate[tr];
  end

  if and(rep(3)<>[2 5]) then

    //update moved link
    o=scs_m.objs(k);
    [xl,yl]=clean_link(o.gr.children(1).x(:),...
                       o.gr.children(1).y(:))
    if ~xl.equal[o.xx] || ~yl.equal[o.yy] then
      have_moved=%t
      o.xx=xl;
      o.yy=yl;
      o.gr.invalidate[]
      o.gr.children(1).x = o.xx;
      o.gr.children(1).y = o.yy;
      o.gr.invalidate[]
      scs_m.objs(k)=o;
    end

    //update split blocks
    //and update other connected links
    if connected(1)<>k then
      o=scs_m.objs(connected(1));
      [xl,yl]=clean_link(o.gr.children(1).x(:),...
                         o.gr.children(1).y(:))
      if ~xl.equal[o.xx] || ~yl.equal[o.yy] then
        have_moved=%t
        o.xx=xl;
        o.yy=yl;
	o.gr.invalidate[]
        o.gr.children(1).x = o.xx;
        o.gr.children(1).y = o.yy;
        o.gr.invalidate[]
        scs_m.objs(connected(1))=o;
      end
    end
    for kk=2:size(connected,'*')
      if connected(kk)<>k then
        o=scs_m.objs(connected(kk))
        [xl,yl]=clean_link(o.gr.children(1).x(:),...
                           o.gr.children(1).y(:))
        if ~xl.equal[o.xx] || ~yl.equal[o.yy] then
          have_moved=%t
          o.xx=xl;
          o.yy=yl;
	  o.gr.invalidate[]
          o.gr.children(1).x = o.xx;
          o.gr.children(1).y = o.yy;
          o.gr.invalidate[]
          scs_m.objs(connected(kk))=o;
        end
      end
    end

    o=scs_m.objs(from(1))
    o.graphics.orig.redim[1,-1]; // be sure that we are a row
    orig= o.graphics.orig + move_xy
    if ~orig.equal[o.graphics.orig] then
      have_moved=%t
      o.graphics.orig=orig
      scs_m.objs(from(1))=o
    end
    o=scs_m.objs(to(1))
    o.graphics.orig.redim[1,-1]; // be sure that we are a row
    orig= o.graphics.orig + move_xy
    if ~orig.equal[o.graphics.orig] then
      have_moved=%t
      o.graphics.orig=orig
      scs_m.objs(to(1))=o
    end

  else
    // undo the move
    o=scs_m.objs(k);
    [xl,yl]=clean_link(o.xx,o.yy)
    if ~xl.equal[o.xx] || ~yl.equal[o.yy] then
      o.xx=xl
      o.yy=yl
      scs_m.objs(k)=o
    end
    o.gr.invalidate[]
    o.gr.children(1).x = o.xx;
    o.gr.children(1).y = o.yy;
    o.gr.invalidate[]

    if connected(1)<>k then
      o=scs_m.objs(connected(1));
      [xl,yl]=clean_link(o.xx,o.yy)
      if ~xl.equal[o.xx] || ~yl.equal[o.yy] then
        o.xx=xl
        o.yy=yl
        scs_m.objs(connected(1))=o
      end
      o.gr.invalidate[]
      o.gr.children(1).x = o.xx;
      o.gr.children(1).y = o.yy;
      o.gr.invalidate[]
    end
    for kk=2:size(connected,'*')
      if connected(kk)<>k then
        o=scs_m.objs(connected(kk))
        [xl,yl]=clean_link(o.xx,o.yy)
        if ~xl.equal[o.xx] || ~yl.equal[o.yy] then
          o.xx=xl
          o.yy=yl
          scs_m.objs(connected(kk))=o
        end
	o.gr.invalidate[]
        o.gr.children(1).x=o.xx
        o.gr.children(1).y=o.yy
        o.gr.invalidate[]
      end
    end

    o=scs_m.objs(from(1))
    o.gr.translate[-move_xy];
    o=scs_m.objs(to(1))
    o.gr.translate[-move_xy];
  end
endfunction

// moving the first segment of a link
// connected from a link
// review : alan,13/09/13
function [scs_m,have_moved]=do_smart_move_link2(scs_m,k,xc,yc)

  have_moved=%f

  o=scs_m.objs(k);
  xx=o.gr.children(1).x(1:2);
  yy=o.gr.children(1).y(1:2);
  e=[max(yy)-min(yy),max(xx)-min(xx)];
  e= e ./norm(e)

  from=o.from
  connected=get_connected(scs_m,from(1))

  F=get_current_figure()
  move_xy=[0 0]
  options=scs_m.props.options

  while 1
    F.process_updates[]
    rep=xgetmouse(clearq=%f,getrelease=%t,cursor=%f);
    if rep(3)==3 then
      global scicos_dblclk
      scicos_dblclk=[rep(1),rep(2),curwin]
    end
    if or(rep(3)==[0,-5, 2, 3, 5]) then
      break
    end
    [delta_x,delta_y,xc,yc]=get_scicos_delta(rep,xc,yc,options('Snap'),options('Wgrid')(1),options('Wgrid')(2))
    tr=[delta_x , delta_y].*e
    move_xy = move_xy +  tr ;

    //main link
    o=scs_m.objs(k);
    o.gr.invalidate[]
    o.gr.children(1).x(1:2) = o.gr.children(1).x(1:2) + tr(1);
    o.gr.children(1).y(1:2) = o.gr.children(1).y(1:2) + tr(2);
    o.gr.invalidate[]

    //update connected links coordinates
    if connected(1)<>k then
      oi=scs_m.objs(connected(1));
      xl=oi.gr.children(1).x
      yl=oi.gr.children(1).y
      if size(oi.gr.children(1).x,'*')>2 then
        if oi.gr.children(1).x($)==xl($-1) then
	  oi.gr.invalidate[]
	  oi.gr.children(1).x($-1:$)=xl($-1:$)+ tr(1);
	  oi.gr.children(1).y($)=yl($)+ tr(2);
	  oi.gr.invalidate[]
	elseif oi.gr.children(1).y($)==yl($-1) then
	  oi.gr.invalidate[]
	  oi.gr.children(1).x($)=xl($)+ tr(1);
	  oi.gr.children(1).y($-1:$)=yl($-1:$)+tr(2);
	  oi.gr.invalidate[]
        else
	  oi.gr.invalidate[]
	  oi.gr.children(1).x($)=xl($)+ tr(1);
	  oi.gr.children(1).y($)=yl($)+ tr(2);
	  oi.gr.invalidate[]
        end
      else
	oi.gr.invalidate[]
        oi.gr.children(1).x($)=xl($)+ tr(1);
        oi.gr.children(1).y($)=yl($)+ tr(2);
	oi.gr.invalidate[]
      end
    end
    for kk=2:size(connected,'*')
      if connected(kk)<>k then
        oi=scs_m.objs(connected(kk))
        xl=oi.gr.children(1).x
        yl=oi.gr.children(1).y
        if size(oi.gr.children(1).x,'*')>2 then
          if oi.gr.children(1).x(1)==xl(2) then
	    oi.gr.invalidate[]
            oi.gr.children(1).x(1:2)=xl(1:2)+tr(1);
            oi.gr.children(1).y(1)=yl(1)+ tr(2);
	    oi.gr.invalidate[]
          elseif oi.gr.children(1).y(1)==yl(2) then
	    oi.gr.invalidate[]
            oi.gr.children(1).x(1)=xl(1)+ tr(1);
            oi.gr.children(1).y(1:2)=yl(1:2)+tr(2);
	    oi.gr.invalidate[]
          else
	    oi.gr.invalidate[]
            oi.gr.children(1).x(1)=xl(1)+ tr(1);
            oi.gr.children(1).y(1)=yl(1)+ tr(2);
	    oi.gr.invalidate[]
          end
        else
	  oi.gr.invalidate[]
          oi.gr.children(1).x(1)=xl(1)+ tr(1);
          oi.gr.children(1).y(1)=yl(1)+ tr(2);
	  oi.gr.invalidate[]
        end
      end
    end

    //update split block coordinates
    oi=scs_m.objs(from(1))
    oi.gr.translate[tr];
  end

  if and(rep(3)<>[2 5]) then

    // update moved link
    o=scs_m.objs(k);
    [xl,yl]=clean_link(o.gr.children(1).x(:),...
                       o.gr.children(1).y(:))
    if ~xl.equal[o.xx] || ~yl.equal[o.yy] then
      have_moved=%t
      o.xx=xl;
      o.yy=yl;
      o.gr.invalidate[]
      o.gr.children(1).x = o.xx;
      o.gr.children(1).y = o.yy;
      o.gr.invalidate[]
      scs_m.objs(k)=o;
    end

    //update split block
    //and update other connected links
    if connected(1)<>k then
      o=scs_m.objs(connected(1));
      [xl,yl]=clean_link(o.gr.children(1).x(:),...
                         o.gr.children(1).y(:))
      if ~xl.equal[o.xx] || ~yl.equal[o.yy] then
        have_moved=%t
        o.xx=xl;
        o.yy=yl;
        o.gr.invalidate[]
        o.gr.children(1).x = o.xx;
        o.gr.children(1).y = o.yy;
        o.gr.invalidate[]
        scs_m.objs(connected(1))=o;
      end
    end
    for kk=2:size(connected,'*')
      if connected(kk)<>k then
        o=scs_m.objs(connected(kk))
        [xl,yl]=clean_link(o.gr.children(1).x(:),...
                           o.gr.children(1).y(:))
        if ~xl.equal[o.xx] || ~yl.equal[o.yy] then
          have_moved=%t
          o.xx=xl;
          o.yy=yl;
	  o.gr.invalidate[]
          o.gr.children(1).x = o.xx;
          o.gr.children(1).y = o.yy;
          o.gr.invalidate[]
          scs_m.objs(connected(kk))=o;
        end
      end
    end

    o=scs_m.objs(from(1))
    o.graphics.orig.redim[1,-1]; // be sure that we are a row
    orig= o.graphics.orig + move_xy
    if ~orig.equal[o.graphics.orig] then
      have_moved=%t
      o.graphics.orig=orig
      scs_m.objs(from(1))=o
    end

  else
    // undo the move
    o=scs_m.objs(k);
    [xl,yl]=clean_link(o.xx,o.yy)
    if ~xl.equal[o.xx] || ~yl.equal[o.yy] then
      o.xx=xl
      o.yy=yl
      scs_m.objs(k)=o
    end
    o.gr.invalidate[]
    o.gr.children(1).x = o.xx;
    o.gr.children(1).y = o.yy;
    o.gr.invalidate[]

    if connected(1)<>k then
      o=scs_m.objs(connected(1));
      [xl,yl]=clean_link(o.xx,o.yy)
      if ~xl.equal[o.xx] || ~yl.equal[o.yy] then
        o.xx=xl
        o.yy=yl
        scs_m.objs(connected(1))=o
      end
      o.gr.invalidate[]
      o.gr.children(1).x = o.xx;
      o.gr.children(1).y = o.yy;
      o.gr.invalidate[]
    end
    for kk=2:size(connected,'*')
      if connected(kk)<>k then
        o=scs_m.objs(connected(kk))
        [xl,yl]=clean_link(o.xx,o.yy)
        if ~xl.equal[o.xx] || ~yl.equal[o.yy] then
          o.xx=xl
          o.yy=yl
          scs_m.objs(connected(kk))=o
        end
	o.gr.invalidate[]
        o.gr.children(1).x=o.xx
        o.gr.children(1).y=o.yy
        o.gr.invalidate[]
      end
    end

    o=scs_m.objs(from(1))
    o.gr.translate[-move_xy];
  end
endfunction

// moving the last segment of a link
// connected to a link
// review : alan,13/09/13
function [scs_m,have_moved]=do_smart_move_link3(scs_m,k,xc,yc)

  have_moved=%f

  o=scs_m.objs(k);
  xx=o.gr.children(1).x($-1:$);
  yy=o.gr.children(1).y($-1:$);
  e=[max(yy)-min(yy),max(xx)-min(xx)];
  e=e/norm(e)

  to=o.to
  connected=get_connected(scs_m,to(1))

  F=get_current_figure()
  move_xy=[0 0]
  options=scs_m.props.options

  pto=[xc,yc];
  while 1
    F.process_updates[]
    rep=xgetmouse(clearq=%f,getrelease=%t,cursor=%f);
    if rep(3)==3 then
      global scicos_dblclk
      scicos_dblclk=[rep(1),rep(2),curwin]
    end
    if or(rep(3)==[0,-5, 2, 3, 5]) then
      break
    end
    [delta_x,delta_y,xc,yc]=get_scicos_delta(rep,xc,yc,options('Snap'),options('Wgrid')(1),options('Wgrid')(2))
    tr=[delta_x , delta_y].*e
    move_xy = move_xy +  tr ;

    //main link
    o=scs_m.objs(k);
    o.gr.invalidate[]
    o.gr.children(1).x($-1:$) = o.gr.children(1).x($-1:$) + tr(1);
    o.gr.children(1).y($-1:$) = o.gr.children(1).y($-1:$) + tr(2);
    o.gr.invalidate[]

    //update connected link coordinates
    for kk=2:size(connected,'*')
      oi=scs_m.objs(connected(kk))
      xl=oi.gr.children(1).x;
      yl=oi.gr.children(1).y;
      if size(oi.gr.children(1).x,'*')>2 then
        if oi.gr.children(1).x(1)==xl(2) then
	  oi.gr.invalidate[]
          oi.gr.children(1).x(1:2)=xl(1:2)+ tr(1)
          oi.gr.children(1).y(1)=yl(1)+ tr(2)
	  oi.gr.invalidate[]
        elseif oi.gr.children(1).y(1)==yl(2) then
	  oi.gr.invalidate[]
          oi.gr.children(1).x(1)=xl(1)+ tr(1)
          oi.gr.children(1).y(1:2)=yl(1:2)+tr(2)
	  oi.gr.invalidate[]
        else
	  oi.gr.invalidate[]
          oi.gr.children(1).x(1)=xl(1)+ tr(1)
          oi.gr.children(1).y(1)=yl(1)+ tr(2)
	  oi.gr.invalidate[]
        end
      else
	oi.gr.invalidate[]
        oi.gr.children(1).x(1)=xl(1)+ tr(1);
        oi.gr.children(1).y(1)=yl(1)+ tr(2);
	oi.gr.invalidate[]
      end
    end

    //update split block coordinates
    oi=scs_m.objs(to(1))
    oi.gr.translate[tr];
  end

  if and(rep(3)<>[2 5]) then

    // update moved link
    o=scs_m.objs(k);
    [xl,yl]=clean_link(o.gr.children(1).x(:),...
                       o.gr.children(1).y(:))
    if ~xl.equal[o.xx] || ~yl.equal[o.yy] then
      have_moved=%t
      o.xx=xl;
      o.yy=yl;
      o.gr.invalidate[]
      o.gr.children(1).x = o.xx;
      o.gr.children(1).y = o.yy;
      o.gr.invalidate[]
      scs_m.objs(k)=o;
    end

    //update split block
    //and update other connected links
    for kk=2:size(connected,'*')
      o=scs_m.objs(connected(kk))
      [xl,yl]=clean_link(o.gr.children(1).x(:),...
                         o.gr.children(1).y(:))
      if ~xl.equal[o.xx] || ~yl.equal[o.yy] then
        have_moved=%t
        o.xx=xl;
        o.yy=yl;
	o.gr.invalidate[]
        o.gr.children(1).x = o.xx;
        o.gr.children(1).y = o.yy;
        o.gr.invalidate[]
        scs_m.objs(connected(kk))=o;
      end
    end

    o=scs_m.objs(to(1))
    o.graphics.orig.redim[1,-1]; // be sure that we are a row
    orig= o.graphics.orig + move_xy
    if ~orig.equal[o.graphics.orig] then
      have_moved=%t
      o.graphics.orig=orig
      scs_m.objs(to(1))=o
    end

  else
    // undo the move
    o=scs_m.objs(k)
    [xl,yl]=clean_link(o.xx,o.yy)
    if ~xl.equal[o.xx] || ~yl.equal[o.yy] then
      o.xx=xl
      o.yy=yl
      scs_m.objs(k)=o
    end
    o.gr.invalidate[]
    o.gr.children(1).x = o.xx;
    o.gr.children(1).y = o.yy;
    o.gr.invalidate[]

    for kk=2:size(connected,'*')
      o=scs_m.objs(connected(kk))
      [xl,yl]=clean_link(o.xx,o.yy)
      if ~xl.equal[o.xx] || ~yl.equal[o.yy] then
        o.xx=xl
        o.yy=yl
        scs_m.objs(connected(kk))=o
      end
      o.gr.invalidate[]
      o.gr.children(1).x=o.xx
      o.gr.children(1).y=o.yy
      o.gr.invalidate[]
    end

    o=scs_m.objs(to(1))
    o.gr.translate[-move_xy];
  end
endfunction
