function scmenu_move()
// performs a move of an object 
//
  Cmenu=''
  if ~isempty(Select) && ~isempty(find(Select(:,2)<>curwin)) then
    // XXX why this part ? 
    Select=[]; Cmenu='Move';
    return
  end
  // performs the move 
  [scs_m]=do_move(%pt,scs_m,Select)
  %pt=[];
endfunction
  
function [scs_m]=do_move(%pt,scs_m,Select)
  if ~isempty(Select) && size(Select,1) == 1 && 
    scs_m.objs(Select(1)).type=="Link" then
    [%pt,scs_m,have_moved]=do_stupidmove(%pt,Select,scs_m)
  else
    [scs_m,have_moved]=do_stupidMultimove(%pt,Select,scs_m)
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


function [%pt,scs_m,have_moved]=do_stupidmove(%pt,Select,scs_m)
  rela=15/100;
  have_moved=%f;
  win=%win;
  xc=%pt(1);yc=%pt(2);
  [k,wh,scs_m]=stupid_getobj(scs_m,Select,[xc;yc]);
  if isempty(k) then return, end;
  scs_m_save=scs_m;
  if scs_m.objs(k).type == 'Link' then
    [scs_m,have_moved]=stupid_movecorner(scs_m,k,xc,yc,wh);
    xcursor();
  end
  if Cmenu=='Quit' then
    resume(%win, Cmenu)
  end
  if have_moved then
    resume(scs_m_save,needreplay,enable_undo=%t,edited=%t,nc_save=needcompile);
  end
endfunction

function [scs_m,have_moved]=stupid_movecorner(scs_m,k,xc,yc,wh)
// move a corner of a link  
//
  o=scs_m.objs(k);
  [xx,yy,ct]=(o.xx,o.yy,o.ct);
  o_link=size(xx);
  link_size=o_link(1);
  moving_seg=[-wh-1:-wh+1];
  have_moved=%f;
  
  if (-wh-1)==1 then //** the moving include the starting point  
    start_seg=[];
    X_start=[];
    Y_start=[];
  else                 //** the move need some static point from the beginning 
    start_seg=[1:-wh-1];
    X_start=xx(start_seg);
    Y_start=yy(start_seg);
  end
  
  if (-wh+1)==link_size then //** the moving include the endpoint 
    end_seg=[];
    X_end=[];
    Y_end=[];
  else                //** the moving need some static point to the end 
    end_seg=[-wh+1:link_size];
    X_end=xx(end_seg);
    Y_end=yy(end_seg);
  end

  X1=xx(moving_seg);
  Y1=yy(moving_seg);
  x1=X1;
  y1=Y1;

  ini_data=[o.gr.children(1).x o.gr.children(1).y]
  if size(o.gr.children)>1 then
    ini_data_id=[o.gr.children(2).x o.gr.children(2).y]
  end

  F=get_current_figure()
  rep(3)=-1;
  cursor_changed=%f;
  while 1 do
    if rep(3)==3 then
      global scicos_dblclk
      scicos_dblclk=[rep(1),rep(2),curwin]
    end
    if or(rep(3)==[0,2,3,5,-5,-100]) then
      break
    end
    rect=[min(o.gr.children(1).x)+(max(o.gr.children(1).x)-min(o.gr.children(1).x))/2 ,..
          min(o.gr.children(1).y)+(max(o.gr.children(1).y)-min(o.gr.children(1).y))/2]
    
    o.gr.children(1).x=[X_start;x1;X_end]
    o.gr.children(1).y=[Y_start;y1;Y_end]

    o.gr.invalidate[]
    F.process_updates[];
    rep=xgetmouse(clearq=%t,getrelease=%t,cursor=%f);
    xc1=rep(1)
    yc1=rep(2)
    x1(2)=X1(2)-(xc-xc1);
    y1(2)=Y1(2)-(yc-yc1);
    rect_now=[min(o.gr.children(1).x)+(max(o.gr.children(1).x)-min(o.gr.children(1).x))/2 ,..
              min(o.gr.children(1).y)+(max(o.gr.children(1).y)-min(o.gr.children(1).y))/2]
    if ~cursor_changed then
      if ~isequal(rect,rect_now) then
        cursor_changed=%t
        xcursor(52);
      end
    end
    if size(o.gr.children)>1 then
      data=[o.gr.children(2).x-(rect(1)-rect_now(1)),..
            o.gr.children(2).y-(rect(2)-rect_now(2))]
      o.gr.children(2).x=data(1,1)
      o.gr.children(2).y=data(1,2)
    end
    o.gr.invalidate[]
  end

  if and(rep(3)<>[2 5]) then //** if the link manipulation is OK 
    have_moved=%t
    rect=[min(o.gr.children(1).x)+(max(o.gr.children(1).x)-min(o.gr.children(1).x))/2 ,..
          min(o.gr.children(1).y)+(max(o.gr.children(1).y)-min(o.gr.children(1).y))/2]
    if abs(x1(1)-x1(2))<rela*abs(y1(1)-y1(2)) then
      x1(2)=x1(1)
    elseif abs(x1(2)-x1(3))<rela*abs(y1(2)-y1(3)) then
      x1(2)=x1(3)
    end  
    if abs(y1(1)-y1(2))<rela*abs(x1(1)-x1(2)) then
      y1(2)=y1(1)
    elseif abs(y1(2)-y1(3))<rela*abs(x1(2)-x1(3)) then
      y1(2)=y1(3)
    end  
    d = projaff([x1(1);x1(3)],[y1(1);y1(3)],[x1(2);y1(2)])
    if norm(d(:)-[x1(2);y1(2)])<..
         rela*max(norm(d(:)-[x1(3);y1(3)]),norm(d(:)-[x1(1);y1(1)])) then
      xx(moving_seg)=x1
      yy(moving_seg)=y1
      xx(moving_seg(2))=[]
      yy(moving_seg(2))=[]
      x1(2)=[];y1(2)=[];moving_seg(3)=[]
    else
      xx(moving_seg)=x1
      yy(moving_seg)=y1
    end
    o.xx=xx;o.yy=yy;
    o.gr.children(1).x=o.xx
    o.gr.children(1).y=o.yy
    rect_now=[min(xx)+(max(xx)-min(xx))/2 , min(yy)+(max(yy)-min(yy))/2]
    if size(o.gr.children)>1 then
      data=[o.gr.children(2).x-(rect(1)-rect_now(1)),..
            o.gr.children(2).y-(rect(2)-rect_now(2))]
      o.gr.children(2).x=data(1,1)
      o.gr.children(2).y=data(1,2)
    end
    o.gr.invalidate[]
    scs_m.objs(k)=o
  else
    o.gr.children(1).x=ini_data(:,1)
    o.gr.children(1).y=ini_data(:,2)
    if size(o.gr.children)>1 then
      o.gr.children(2).x=ini_data_id(:,1)
      o.gr.children(2).y=ini_data_id(:,2)
    end
    o.gr.invalidate[]
  end
  F.draw_now[]
endfunction

function [k,wh,scs_m]=stupid_getobj(scs_m,Select,pt)
// get which point of the link which will move 
// or which object 
  
  function [d,pt,ind] = stupid_dist2polyline(xp,yp,pt,pereps)
  // Copyright INRIA
  // computes minimum distance from a point to a polyline
  // d    minimum distance to polyline
  // pt   coordinate of the polyline closest point
  // ind  
  //      if negative polyline closest point is a polyline corner:
  //         pt=[xp(-ind) yp(-ind)]
  //      if positive pt lies on segment [ind ind+1]
  //
    x=pt(1);
    y=pt(2);
    xp=xp(:); yp=yp(:)
    cr=4*sign((xp(1:$-1)-x).*(xp(1:$-1)-xp(2:$))+..
	      (yp(1:$-1)-y).*(yp(1:$-1)-yp(2:$)))+..
       sign((xp(2:$)-x).*(xp(2:$)-xp(1:$-1))+..
	    (yp(2:$)-y).*(yp(2:$)-yp(1:$-1)))
    
    ki = find(cr==5) // index of segments for which projection fall inside
    np = size(xp,'*')
    if ~isempty(ki) then
      //projection on segments
      x = [xp(ki) xp(ki+1)];
      y = [yp(ki) yp(ki+1)];
      dx = x(:,2)-x(:,1);
      dy = y(:,2)-y(:,1);
      d_d = dx.^2 + dy.^2 ;
      d_x = ( dy.*(-x(:,2).*y(:,1)+x(:,1).*y(:,2))+dx.*(dx*pt(1)+dy*pt(2)))./d_d
      d_y = (-dx.*(-x(:,2).*y(:,1)+x(:,1).*y(:,2))+dy.*(dx*pt(1)+dy*pt(2)))./d_d
      xp  = [xp;d_x]
      yp  = [yp;d_y]
    end
    zzz = [ones(np,1) ; zeros(size(ki,'*'),1)] * eps
    zz  = [ones(np,1)*pereps ; ones(size(ki,'*'),1)]
    [d,k] = min(sqrt((xp-pt(1)).^2+(yp-pt(2)).^2).*zz - zzz) 
    pt(1) = xp(k)
    pt(2) = yp(k)
    if k>np then ind=ki(k-np), else ind=-k, end
  endfunction
  
  
  wh=[];
  x=pt(1);y=pt(2)
  data=[]
  k=[]
  i=Select(1) //Link to move
  o=scs_m.objs(i)
  eps=3;
  xx=o.xx;yy=o.yy;
  [d,ptp,ind]=stupid_dist2polyline(xx, yy, pt, 0.85)
  if d < eps then 
    if ind==-1 then 
      k=o.from(1);
    elseif ind==-size(xx,1) then 
      k=o.to(1); //** click near an output
    elseif ind>0 then 
      o.xx=[xx(1:ind);ptp(1);xx(ind+1:$)];
      o.yy=[yy(1:ind);ptp(2);yy(ind+1:$)];
      scs_m.objs(i)=o;
      k=i;
      wh=-ind-1;
    else
      k=i
      wh=ind; //** click in the middle (case 2) of a link
    end
  end
endfunction


function [scs_m,have_moved] = do_stupidMultimove(%pt, Select, scs_m)
  rel=15/100
  have_moved=%f
  xc = %pt(1)
  yc = %pt(2)
  scs_m_save = scs_m
  needreplay = replayifnecessary()
  [scs_m,have_moved] = stupid_MultiMoveObject(scs_m, Select, xc, yc)
  if Cmenu=='Quit' then [%win,Cmenu] = resume(%win,Cmenu), end
  if have_moved then
    resume(scs_m_save,needreplay,enable_undo=%t,edited=%t,nc_save=needcompile);
  end
endfunction


function [scs_m,have_moved] = stupid_MultiMoveObject(scs_m, Select, xc, yc)
// Move Selected Blocks/Texts and Links and modify connected (external) links if any
//** scs_m  : the local level diagram
//** Select : matrix [object_id win_id] of selected object
//** xc ,yc : mouse coodinate of the last valid LEFT BUTTON PRESS
//**
//** Select : matrix of selected object
//**          Each line is:  [object_id win_id] : "object_id" is the same INDEX used in "scs_m.obj"
//**                                          and "win_id"    is the Scilab window id.
//**          Multiple selection is permitted: each object is a line of the matrix.
//**
  have_moved  = %f;
  gh_link_i   = list();
  gh_link_mod = list();
  //**----------------------------------------------------------------------------------
  diagram_links=[]; //** ALL the LINKs of the diagram
  diagram_size=size(scs_m.objs)
  if diagram_size<>0
    for k=1:diagram_size //** scan ALL the diagram and look for 'Link'
      if scs_m.objs(k).type=="Link" then
        diagram_links = [diagram_links k]
      end
    end
  end
  //**----------------------------------------------------------------------------------
  //** Classification of selected object
  sel_block = []; //** blocks selected by the user
  sel_link  = []; //** links
  sel_text  = []; //** text

  if ~isempty(Select) then
    SelectObject_id = Select(:,1)'  ; //** select all the object in the current window
  else
    SelectObject_id=[]
  end

  if isempty(SelectObject_id) then
    k=getblocktext(scs_m,[xc;yc])
    if isempty(k) then return, end
    SelectObject_id = k
  end

  //** scan all the selected object
  for k=SelectObject_id
    if scs_m.objs(k).type=='Block' then
      sel_block = [sel_block k]
    end
    if scs_m.objs(k).type=='Link' then
      sel_link = [sel_link k]
    end
    if scs_m.objs(k).type=='Text' then
      sel_text = [sel_text k]
    end
  end //** end of scan

  //**----------------------------------------------------------------------------------
  int_link = []; //** link(s) involved in the move operation

  for l = diagram_links                   //** scan all links and look for external link
     from_block = scs_m.objs(l).from(1) ; //** link proprieties
       to_block = scs_m.objs(l).to(1)   ;
     //** "from" and "to" are relatives to selected blocks
      if (or(from_block==sel_block)) & (or(to_block==sel_block)) then
           int_link = [int_link l]; //** pile up
      end
  end //** end of the link scan
  //**-----------------------------------------------------------------------------------

  //**----------------------------------------------------------------------------------
  connected = []; //** ALL the Links that from/to the supercompound
  ext_block = []; //** ALL the selected blocks that have a links from/to the supercompound

  for k = sel_block //** Scan ALL the selected block and look for external link

     sig_in = scs_m.objs(k).graphics.pin' ; //** signal input
     for l = sig_in //** scan all the input
          if (~(or(l==int_link ))) & (or(l==diagram_links)) then //** the link is not internal
            connected = [connected l]; //** add to the list of link to move
            ext_block = [ext_block k];
          end
     end

     sig_out = scs_m.objs(k).graphics.pout' ; //** signal output
     for l = sig_out //** scan all the output
         if (~(or(l==int_link ))) & (or(l==diagram_links)) then // ext link
            connected = [connected l]; //** add to the list of link to move
            ext_block = [ext_block k];
         end
     end

     ev_in = scs_m.objs(k).graphics.pein' ;
     for l = ev_in //** scan all the output
          if (~(or(l==int_link ))) & (or(l==diagram_links)) then // ext link
            connected = [connected l]; //** add to the list of link to move
            ext_block = [ext_block k];
          end
     end

     ev_out = scs_m.objs(k).graphics.peout' ;
     for l = ev_out //** scan all the output
          if (~(or(l==int_link ))) & (or(l==diagram_links)) then // ext link
            connected = [connected l]; //** add to the list of link to move
            ext_block = [ext_block k];
          end
     end

  end //** end of scan
  //**-----------------------------------------------------------------------------------

  //** look for all the connected link(s) and build "impiling" the two data structures
  //** [xm , ym] for the links data points
  //** gh_link_i is a vector of the associated graphic handles

  xm = []; //** init
  ym = [];
  if ~isempty(connected) then //** check if external link are present
    for l=1:length(connected) //** scan all the connected links
      i  = connected(l)  ;
      oi = scs_m.objs(i) ;
      gh_link_i($+1)=oi.gr;
      [xl, yl, ct, from, to] = (oi.xx, oi.yy, oi.ct, oi.from, oi.to)
      if from(1)==ext_block(l) then 
        xm = [xm, [xl(2);xl(1)] ];
        ym = [ym, [yl(2);yl(1)] ];
      end

      if to(1)==ext_block(l) then
        xm = [xm, xl($-1:$) ];
        ym = [ym, yl($-1:$) ];
      end
    end
  end
  //** ----------------------------------------------------------------------

  //** Supposing that all the selected object are in the current window
  //** create a new compund that include ALL the selected object
  SuperCompound_id = [sel_block int_link sel_text] ;

  //** -----------------------------------------------------------------------
  xmt = xm ;
  ymt = ym ; //** init ...

  //** --------------------------------- MOVE BLOCK WITH CONNECTED LINKS ------------

  xco = xc;
  yco = yc;

  move_x = 0 ;
  move_y = 0 ;

  //**-------------------------------------------------------------------
  gh_link_mod = []
  tmp_data    = []
  t_xmt       = []
  t_ymt       = []

  //** ------------------------------- INTERACTIVE MOVEMENT LOOP ------------------------------

  moved_dist=0
  cursor_changed=%f;
  nb=0
  options=scs_m.props.options
  while 1 do //** interactive move loop
    F.process_updates[];
    rep=xgetmouse(clearq=%t,getrelease=%t,cursor=%f);
    //** left button release, right button (press, click)
    if rep(3)==3 then
      global scicos_dblclk
      scicos_dblclk=[rep(1),rep(2),curwin]
    end
    if or(rep(3)==[-5, 2, 3, 5]) then
      break
    end
    nb=nb+1

    //** Window change and window closure protection
    //TODO

    if nb>2 then   
      [delta_x,delta_y,xc,yc]=get_scicos_delta(rep,xc,yc,options('Snap'),options('Wgrid')(1),options('Wgrid')(2))

      //** Integrate the movements
      move_x = move_x +  delta_x ;
      move_y = move_y +  delta_y ;

      moved_dist=moved_dist+abs(delta_x)+abs(delta_y)
      // under window clicking on a block in a different window causes a move
      if ~cursor_changed then
        if moved_dist>.001 then
          have_moved=%t
        end
        cursor_changed=%t
        xcursor(52)
      end 
      //** Move the SuperCompound
      for k = SuperCompound_id
        o=scs_m.objs(k)
        o.gr.translate[[delta_x , delta_y]];
        o.gr.invalidate[]
      end

      if ~isempty(connected) then  //** Move the links
        xmt(2,:) = xm(2,:) + move_x ;
        ymt(2,:) = ym(2,:) + move_y ;
        j = 0 ;
        for l=1:length(connected)
          i  = connected(l)
          oi = scs_m.objs(i)
          [xl,from,to] = (oi.xx,oi.from,oi.to);
          gh_link_mod = gh_link_i(l);

          if from(1)==ext_block(l) then
            xx = gh_link_mod.children(1).x(:);
            yy = gh_link_mod.children(1).y(:);
            tmp_data = [xx,yy]

            rect=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
            j = j + 1 ;
            t_xmt = xmt([2,1],j)
            t_ymt = ymt([2,1],j)
            data = [ [t_xmt(1) , t_ymt(1)] ; tmp_data(2:$ , 1:$) ]
            gh_link_mod.children(1).x=data(:,1)
            gh_link_mod.children(1).y=data(:,2)

            if size(gh_link_mod.children)>1 then
              xx = gh_link_mod.children(1).x(:);
              yy = gh_link_mod.children(1).y(:);
              rect_now=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
              xx = gh_link_mod.children(2).x(:);
              yy = gh_link_mod.children(2).y(:);
              gh_link_mod.children(2).x=xx-(rect(1)-rect_now(1))
              gh_link_mod.children(2).y=yy-(rect(2)-rect_now(2))
            end
          end

          if to(1)==ext_block(l) then
            xx = gh_link_mod.children(1).x(:)
            yy = gh_link_mod.children(1).y(:)
            tmp_data = [xx,yy]

            rect=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
            j = j + 1 ;
            data = [ tmp_data(1:$-2 , 1:$) ; [xmt(:,j) , ymt(:,j)] ]
            gh_link_mod.children(1).x=data(:,1)
            gh_link_mod.children(1).y=data(:,2)

            if size(gh_link_mod.children)>1 then
              xx = gh_link_mod.children(1).x(:);
              yy = gh_link_mod.children(1).y(:);
              rect_now=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
              xx = gh_link_mod.children(2).x(:);
              yy = gh_link_mod.children(2).y(:);
              gh_link_mod.children(2).x=xx-(rect(1)-rect_now(1))
              gh_link_mod.children(2).y=yy-(rect(2)-rect_now(2))
            end
          end
          gh_link_mod.invalidate[]
        end
      end
    end
  end //** ... of while Interactive move LOOP --------------------------------------------------------------
  xcursor();
  F.draw_now[];

  //**-----------------------------------------------
  //gh_figure = gcf();
  //if gh_figure.figure_id<>curwin | rep(3)==-100 then
  //     [%win,Cmenu] = resume(curwin,'Quit') ;
  //end
  //**-----------------------------------------------

  //** OK If update and block and links position in scs_m

  //** if the exit condition is NOT a right button press OR click
  if and(rep(3)<>[2 5]) then //** update the data structure
    //** Rigid SuperCompund Elements
    block=[];

    for k = sel_block
      block = scs_m.objs(k)    ;
      xy_block = block.graphics.orig ;
      xy_block(1) = xy_block(1) + move_x ;
      xy_block(2) = xy_block(2) + move_y ;
      block.graphics.orig = xy_block ;
      scs_m.objs(k) = block; //update block coordinates
    end

    text=[]
    for k = sel_text
      text = scs_m.objs(k)
      xy_text = text.graphics.orig ;
      xy_text(1) = xy_text(1) + move_x ;
      xy_text(2) = xy_text(2) + move_y ;
      text.graphics.orig = xy_text;
      scs_m.objs(k) = text; //update block coordinates
    end

    link_=[]
    for l = int_link
      link_= scs_m.objs(l)
      [xl, yl] = (link_.xx, link_.yy)
      xl = xl + move_x ;
      yl = yl + move_y ;
      link_.xx = xl ; link_.yy = yl ;
      scs_m.objs(l) = link_ ; 
    end

    //** Flexible Link elements
    if ~isempty(connected) then
      j = 0 ;
      for l=1:length(connected)
	i  = connected(l)  ;
	oi = scs_m.objs(i) ;
	[xl,from,to] = (oi.xx,oi.from,oi.to);

	if from(1)==ext_block(l) then
	  j = j + 1 ;
	  oi.xx(1:2) = xmt([2,1],j) ;
	  oi.yy(1:2) = ymt([2,1],j) ;
	end

	if to(1)==ext_block(l) then
	  j = j + 1 ;
	  oi.xx($-1:$) = xmt(:,j) ;
	  oi.yy($-1:$) = ymt(:,j) ;
	end
	scs_m.objs(i) = oi ; //** update the datastructure 
      end //... for loop
    end //** of if
    //**---------------------------------------------------
    if size(sel_block,2)==1&length(connected)==1 then
      k = sel_block
      lk = scs_m.objs(connected(1))

      moving=0
      if size(lk.xx,'*')==2 then
	dx=lk.xx(1)-lk.xx(2);dy=lk.yy(1)-lk.yy(2);
	if abs(dx)<rel*abs(dy) then
	  dy=0;moving=1
	elseif abs(dy)<rel*abs(dx) then
	  dx=0;moving=1
	end

	if moving then
	  if lk.to(1)==k then
	    scs_m.objs(k).graphics.orig=scs_m.objs(k).graphics.orig+[dx,dy]
	    lk.xx(2)=lk.xx(2)+dx;lk.yy(2)=lk.yy(2)+dy
	    scs_m.objs(connected(1))=lk
	    gh_link_mod = gh_link_i(1)
	    gh_link_mod.children(1).x(2)=gh_link_mod.children(1).x(2)+dx
	    gh_link_mod.children(1).y(2)=gh_link_mod.children(1).y(2)+dy
	    gh_link_mod.invalidate[]
	  elseif lk.from(1)==k  then
	    scs_m.objs(k).graphics.orig=scs_m.objs(k).graphics.orig-[dx,dy]
	    lk.xx(1)=lk.xx(1)-dx;lk.yy(1)=lk.yy(1)-dy
	    dx=-dx;dy=-dy
	    scs_m.objs(connected(1))=lk
	    gh_link_mod=gh_link_i(1)
	    gh_link_mod.children(1).x(1)=gh_link_mod.children(1).x(1)+dx
	    gh_link_mod.children(1).y(1)=gh_link_mod.children(1).y(1)+dy
	    gh_link_mod.invalidate[]
	  else
	    resume(Cmenu='Replot') // graphics inconsistent with scs_m
	  end
	end
      end

      if moving then
	o=scs_m.objs(k)
	o.gr.translate[[dx,dy]];
	o.gr.invalidate[]
      end
    end

    //**=---> If the user abort the operation
  else //** restore original position of block and links in figure
    //** in this case: [scs_m] is not modified !
    
    have_moved=%f
    //** Move back the SuperCompound
    for k=SuperCompound_id 
      o=scs_m.objs(k)
      o.gr.translate[[-move_x,-move_y]];
    end

    //**-------------------------------------------------------
    if ~isempty(connected) then 
      xmt(2,:) = xm(2,:);  //** original datas of links
      ymt(2,:) = ym(2,:);
      j = 0 ; //** init
      for l=1:length(connected)
	i  = connected(l)  ;
	oi = scs_m.objs(i) ;
	[xl,from,to] = (oi.xx,oi.from,oi.to);
	gh_link_mod = gh_link_i(l) ; // get the link graphics data structure

	if from(1)==ext_block(l) then
	  xx=gh_link_mod.children(1).x(:);
	  yy=gh_link_mod.children(1).y(:);
	  rect=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
	  tmp_data = [xx,yy]
	  j = j + 1 ;
	  t_xmt = xmt([2,1],j) ;  t_ymt = ymt([2,1],j) ;
	  data = [ [t_xmt(1) , t_ymt(1)] ; tmp_data(2:$ , 1:$) ];
	  gh_link_mod.children(1).x=data(:,1)
	  gh_link_mod.children(1).y=data(:,2)
	  if size(gh_link_mod.children)>1 then
	    xx = gh_link_mod.children(1).x(:);
	    yy = gh_link_mod.children(1).y(:);
	    rect_now=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
	    xx=gh_link_mod.children(2).x(:);
	    yy=gh_link_mod.children(2).y(:);
	    gh_link_mod.children(2).x=xx-(rect(1)-rect_now(1))
	    gh_link_mod.children(2).y=yy-(rect(2)-rect_now(2))
	  end
	end

	if to(1)==ext_block(l) then
	  xx = gh_link_mod.children(1).x(:);
	  yy = gh_link_mod.children(1).y(:);
	  rect=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
	  tmp_data = [xx,yy]
	  j = j +  1 ;
	  data = [ tmp_data(1:$-2 , 1:$) ; [xmt(:,j) , ymt(:,j)] ];
	  gh_link_mod.children(1).x=data(:,1)
	  gh_link_mod.children(1).y=data(:,2)
	  if size(gh_link_mod.children)>1 then
	    xx=gh_link_mod.children(1).x(:);
	    yy=gh_link_mod.children(1).y(:);
	    rect_now=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
	    xx = gh_link_mod.children(2).x(:);
	    yy = gh_link_mod.children(2).y(:);
	    gh_link_mod.children(2).x=xx-(rect(1)-rect_now(1))
	    gh_link_mod.children(2).y=yy-(rect(2)-rect_now(2))
	  end
	end
	gh_link_mod.invalidate[]
      end //... for loop
    end //** of if
  end //**----------------------------------------
endfunction

function [dxy]=get_wgrid_alignment(xy,XY_W)
  if abs( floor(xy(1)/XY_W(1))-(xy(1)/XY_W(1)) ) <...
          abs(  ceil(xy(1)/XY_W(1))-(xy(1)/XY_W(1)) )
    dxy(1) = floor(xy(1)/XY_W(1))*XY_W(1) ;
  else
    dxy(1) = ceil(xy(1)/XY_W(1))*XY_W(1) ;
  end
  if abs( floor(xy(2)/XY_W(2))-(xy(2)/XY_W(2)) ) <...
          abs(  ceil(xy(2)/XY_W(2))-(xy(2)/XY_W(2)) )
    dxy(2) = floor(xy(2)/XY_W(2))*XY_W(2) ;
  else
    dxy(2) = ceil(xy(2)/XY_W(2))*XY_W(2) ;
  end
endfunction

function [delta_x,delta_y,xc,yc]=get_scicos_delta(rep,xc,yc,Snap,SnapIncX,SnapIncY)
  if Snap then
    if abs( floor(rep(1)/SnapIncX)-(rep(1)/SnapIncX) ) <...
	    abs(  ceil(rep(1)/SnapIncX)-(rep(1)/SnapIncX) )
      delta_x  = floor((rep(1)-xc)/SnapIncX)*SnapIncX;
      xc = floor(rep(1)/SnapIncX)*SnapIncX ;
    else
      delta_x  = ceil((rep(1)-xc)/SnapIncX)*SnapIncX;
      xc = ceil(rep(1)/SnapIncX)*SnapIncX ;
    end
    if abs( floor(rep(2)/SnapIncY)-(rep(2)/SnapIncY) ) <...
	    abs(  ceil(rep(2)/SnapIncY)-(rep(2)/SnapIncY) )
      delta_y  = floor((rep(2)-yc)/SnapIncY)*SnapIncY;
      yc = floor(rep(2)/SnapIncY)*SnapIncY ;
    else
      delta_y  = ceil((rep(2)-yc)/SnapIncY)*SnapIncY;
      yc = ceil(rep(2)/SnapIncY)*SnapIncY ;
    end
  else
    delta_x = rep(1)-xc;
    xc = rep(1);
    delta_y = rep(2)-yc;
    yc = rep(2);
  end
endfunction
