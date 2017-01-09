function [sd]=ngr_menu(sd,flag,noframe)
  global('ngr_objects');
  global('ngr_options');
  if ~new_graphics() then
    switch_graphics();
  end
  ngr_options=ngr_do_options([]);// initialize
  scsmode=%f
  dash=['0        continue';
	'1        {2,5,2,5}';
	'2        {5,2,5,2}';
	'3        {5,3,2,3}';
	'4        {8,3,2,3}';
	'5        {11,3,2,3}';
	'6        {11,3,5,3}}'];

  if nargin<=1,flag=0;end;
  if nargin<=2,noframe=0;end;
  if nargin<=0 then
    cdef=[0 0 100 100];
    sd=list('sd',cdef);
    init=1
  else
     select type(sd,'string')
      case 'Mat' then
       cdef=sd;init=1
      case 'List' then
       if sd(1)<>'sd' then
	 error('First argument should be a sd list\n");
	 return;
       end
       cdef=sd(2);init=0
     else
       error('Incorrect input expecting [xmin,ymin,xmax,ymax] or list(''sd'',,,)');
       return;
     end
  end
  ngr_objects=list();
  cdef=[0 0 100 100];
  // window initialize
  xsetech(frect=cdef,fixed=%t);
  xrect([0,100,100,100]);
  //xset('wresize',0)
  curwin=xget('window')
  // menus
  names = ['Edit','Objects'];
  Edit=['redraw','delete all','delete','copy','random','Options','Quit','Poo\/foo'];
  //Objects=['rectangle','frectangle','circle','fcircle','polyline',...
  // 'fpolyline','spline','arrow','points','caption']
  Objects=['rectangle','polyline'];
  menus=tlist(['menus',names,'names'],Edit,Objects);
  Edit='menus(names(1))'+string(1:size(Edit,'*'))+')';
  Objects='menus(names(3))'+string(1:size(Objects,'*'))+')';

  for k=1:size(names,'*') ;
    delmenu(curwin,names(k));
    addmenu(curwin,names(k),menus(names(k)),list(2,'ngr_'+names(k)));
    execstr(names(k)+'_'+string(curwin)+'='+names(k)+';');
  end
  unsetmenu(curwin,'File',7) //close
  unsetmenu(curwin,'3D Rot.')
  // insert objects in the Figure
  // graphics objects are created here
  F=get_current_figure();
  A=F.children(1);
  if init==0 then
    // initialize ngr_objects with sd;
    if length(sd)==3 then
      ngr_objects=sd(3);
      for k=1:size(ngr_objects)
	o=ngr_objects(k);
	execstr('o=ngr_'+o.type+'(''create_gr'',o);');
	ngr_objects(k)=o;
      end
    end
  end
  if flag==1; xclip();return ;end
  resume(menus);
  async=%f;
  if async then
    seteventhandler('ngr_eventhandler');
  else
    while %t then
      [btn,xc,yc,win,Cmenu]=ngr_get_click(curwin);
      if Cmenu=='Quit' then break;end
      ngr_eventhandler(win,xc,yc,btn);
    end
    xdel(curwin);
  end
  sd(3)=ngr_objects;
  sd(3)=ngr_delete_gr(sd(3));
  clearglobal ngr_objects;
  clearglobal ngr_options;
endfunction

//---------------------------------------
// Edit menu
//---------------------------------------

function str=ngr_Edit(ind,win)
  // Activated whith menu Edit
  global('ngr_objects');
  global('ngr_options');
  str=menus.Edit(ind);
  select str
   case 'redraw' then
    F=get_current_figure();
    F.invalidate[];
   case 'delete all' then
    ngr_delete_all();
   case 'delete' then
    ngr_delete();
   case 'copy'   then ngr_copy();
   case 'random' then
    for i=1:10
      ngr_rect('define',[100*rand(1,2),10,10]);
      ngr_poly('define',[100*rand(2,3)]);
    end
    F=get_current_figure();
    F.invalidate[];
   case 'Options' then
    ngr_options=ngr_do_options(ngr_options);
  end
endfunction

//---------------------------------------
// Object menu
//---------------------------------------

function str=ngr_Objects(ind,win)
// Activated whith menu Objects
  str=menus.Objects(ind);
  execstr('ngr_create_'+str+'()');
endfunction

//---------------------------------------
// Rectangles
//---------------------------------------

function [sd1]=ngr_rect(action,sd,pt,pt1)
  global('ngr_objects');
  control_color=10;
  sd1=0;
  select action
   case 'update' then
    // update the graphics associated to rectangle
    // we have 7 rectangles
    // 1: rect 2:3 hilite part 4:6 lock points
    sdo = ngr_objects(sd);
    if sdo.iskey['gr'] then
      sdo.gr.children(1).fill_color  = sdo.color;
      sdo.gr.children(1).hilited = sdo.hilited;
      cp= sdo('locks status');
      for i=1:length(cp) ;
	sdo.gr.children(1+i).show = ~ ( cp(i) == 0 );
      end
    end
    sdo.gr.invalidate[];
   case 'translate' then
    // translate sd with translation vector pt
    ngr_objects(sd)('data')=ngr_objects(sd)('data') + [pt,0,0];
    ngr_rect('locks',sd);
    ngr_objects(sd).gr.translate[pt];
   case 'define' then
    printf('in ngr_rect action define\n');
    // define the object
    sd1= tlist(["rect","show","hilited","data","color","thickness","locks","locks status","pt"],...
               %t,%f,sd,30*rand(1),2,[],[],[0,0]);
    sd1('locks status')=0*ones_new(1,4); // 4 lock points
    ngr_objects($+1)=sd1;
    n=size(ngr_objects,0);
    ngr_rect('locks',n);
    ngr_objects($)= ngr_rect('create_gr',ngr_objects($));
    sd1 = ngr_objects($);
   case 'create_gr' then
    // create the gr field
    sd1 = sd;
    F=get_current_figure();
    F.start_compound[];
    xrect(sd('data'),thickness=sd('thickness'),color=1,background=sd('color'));
    rr= sd('locks');
    cp= sd('locks status');
    for i=1:length(cp);
      xrect([rr(i,1:2)+[-1,1],2,2],color=1);
    end
    sd1.gr = F.end_compound[];
    // sd1.gr.invalidate[];
   case 'move' then
    // used during copy this is to be changed
    ngr_rect('translate',sd,[5,5]);
    ngr_rect('update',sd)
   case 'inside' then
    // check if pt is inside boundaries of the rectangle
    br=ngr_objects(sd)('data');
    sd1 = br(1) < pt(1) & br(2) >= pt(2) & br(1)+br(3) > pt(1) & br(2)-br(4) <= pt(2);
   case 'inside control' then
    // check if we are near a control point
    // here the down-right point
    d= ngr_objects(sd)('data');
    d= max(abs(d(1)+d(3)-pt(1)),abs((d(2)-d(4)-pt(2))));
    if d < 2 then
      sd1=[1,1]
      xinfo('control point '+string(1));
    else
       sd1=[0]
    end
   case 'move draw' then
    // called when we interactively move object
    ngr_rect('translate',sd,pt);
   case 'move point init' then
    // nothing to do
   case 'move point' then
    // move a control point
    xinfo('inside the move point')
    ngr_objects(sd).gr.invalidate[];
    ngr_objects(sd)('data')(3:4)=max(ngr_objects(sd)('data')(3:4)+[pt(1),-pt(2)],0);
    rr= ngr_objects(sd)('data');
    if ngr_objects(sd).iskey['gr'] then
      R=ngr_objects(sd).gr.children(1);
      R.w = rr(3); R.h = rr(4);
    end
    ngr_rect('locks',sd);
    ngr_objects(sd).gr.invalidate[];
   case 'locks' then
    // compute locks points
    rr=ngr_objects(sd)('data');
    sd1=[rr(1)+rr(3)/2,rr(2);
	 rr(1)+rr(3)/2,rr(2)-rr(4);
	 rr(1),rr(2)-rr(4)/2;
	 rr(1)+rr(3),rr(2)-rr(4)/2];
    ngr_objects(sd)('locks')=sd1;
    if ngr_objects(sd).iskey['gr'] then
      for i=1:4
	R=ngr_objects(sd).gr.children(1+i);
	R.x=sd1(i,1);
	R.y=sd1(i,2);
      end
    end
   case 'inside lock' then
    // check if we are near a lock point
    d= ngr_objects(sd)('locks');
    d1= d - ones_new(4,1)*pt;
    [d1]= max(abs(d1),'c');
    [d1,kd]=min(d1);
    if d1 < 5 then
      sd1=[1,kd,d(kd,1:2)]
      xinfo('lock point '+string(kd));
    else
       sd1=[0]
    end
   case 'locks update' then
    // checks if locks point are to be updated
    sd1=[]
    rr=ngr_objects(sd)('locks');
    cp=ngr_objects(sd)('locks status');
    for i=1:size(cp,'*') ;
      if cp(i) > 0 then
	// update a lock last
	sd1=[sd1,cp(i)];
	n= size(ngr_objects(cp(i))('x'),'*');
	ngr_objects(cp(i))('x')(n)= rr(i,1);
	ngr_objects(cp(i))('y')(n)= rr(i,2);
      elseif cp(i) < 0 then
	 sd1=[sd1,-cp(i)];
	 // update a lock first
	 ngr_objects(-cp(i))('x')(1)= rr(i,1);
	 ngr_objects(-cp(i))('y')(1)= rr(i,2);
      end
    end
   case 'unlock all' then
    // check that locks are released
    cp=ngr_objects(sd)('locks status');
    for i=1:size(cp,'*') ;
      if cp(i) > 0 then
	// polyline  lock last
	ngr_objects(cp(i))('lock last')= 0;
      elseif cp(i) < 0 then
	// polyline  lock first
	ngr_objects(-cp(i))('lock first')= 0;
      end
    end
    ngr_objects(sd)('locks status')=0*cp;
   case 'params' then
    colors=m2s(1:xget("lastpattern")+2,"%1.0f");
    lcols_bg=list('colors','Color',sd('color'),colors);
    [lrep,lres,rep]=x_choices('color settings',list(lcols_bg));
    if ~isempty(rep) then
      sd('color')=rep;
    end
    sd1=sd;
  end
endfunction

function ngr_create_rectangle()
// interactive acquisition of a rectangle
  global('ngr_objects');
  ngr_unhilite();
  ngr_rect('define',[0,100,10,10]);
  n=size(ngr_objects,0);
  ngr_objects(n)('hilited')=%t;
  [rep]=ngr_frame_move(n,[0,100],-5,'move draw',0)
  if rep== -100 then  return;end
  //ngr_rect('update',n);
endfunction

// ------------------------------------------
// polyline
// ------------------------------------------

function sd1 =ngr_poly(action,sd,pt,pt1)
  global('ngr_objects');
  control_color=10;
  sd1=0;
  select action
   case 'update' then
    // update the graphics associated to polyline
    sdo = ngr_objects(sd);
    sdo.gr.children(1).x = sdo('x');
    sdo.gr.children(1).y = sdo('y');
    sdo.gr.children(1).hilited = sdo('hilited');
    sdo.gr.children(1).color = sdo('color');
    sdo.gr.children(1).thickness = sdo('thickness');
    sdo.gr.invalidate[];
   case 'translate' then
    // translate sd with translation vector pt
    if ngr_objects(sd)('lock first')(1) <> 0 || ngr_objects(sd)('lock last')(1) <> 0 then
      xinfo("you cannot move a locked polyline");
    else
      ngr_objects(sd)('x')=ngr_objects(sd)('x')+pt(1);
      ngr_objects(sd)('y')=ngr_objects(sd)('y')+pt(2);
      ngr_objects(sd).gr.translate[pt];
    end
   case 'define' then
    ff=["poly","show","hilited","x","y","color","thickness",...
	"lock first","lock last","locks status","pt"];
    sdo= tlist(ff, %t,%f,sd(1,:),sd(2,:),30*rand(1),2,0,0,0,[0,0]);
    sdo =ngr_poly('create_gr',sdo);
    ngr_objects($+1)=sdo;
    // sdo.gr.invalidate[];
   case 'create_gr' then
    // create the gr field
    sd1 = sd;
    F=get_current_figure();
    F.start_compound[];
    xpoly(sd('x'),sd('y'),type='lines',color=sd('color'),thickness=sd('thickness'));
    sd1.gr = F.end_compound[];
   case 'move' then
    ngr_poly('translate',sd,[5,5]);
   case 'inside' then
    // is pointer near object
    sd=ngr_objects(sd);
    [pt,kmin,pmin,d]=ngr_dist2polyline(sd('x'),sd('y'),pt);
    if d < 3 then sd1=%t
    else
       sd1=%f ;
    end
   case 'inside control' then
    // check if we are near a control point
    sd=ngr_objects(sd);
    [d,k]=min( (sd('x')-pt(1)).^2 + (sd('y')-pt(2)).^2 )
    if d < 2 then
      sd1=[1,k]
      xinfo('control point '+string(k));
    else
       sd1=[0]
    end
   case 'move draw' then
    // translate then draw (forcing the show)
    // used when object is moved
    ngr_poly('translate',sd,pt);
   case 'move point init' then
    ngr_objects(sd)('pt')=  [ngr_objects(sd)('x')(pt),ngr_objects(sd)('y')(pt)];
   case 'move point' then
    // move a control point
    xinfo('inside the move point '+string(pt1))
    xinfo('moving control '+string(pt1));
    // force horizontal and vertical line
    // when we are in the vicinity of it
    n = size(ngr_objects(sd)('x'),'*');
    // we keep in pt the current point position
    // since magnetism can move us to a new position
    ptc = ngr_objects(sd)('pt');
    //ptc=[ngr_objects(sd)('x')(pt1),ngr_objects(sd)('y')(pt1)];
    ptnew = ptc+pt;
    ngr_objects(sd)('pt')=ptnew;
    if pt1 >= 2 & pt1 < n then
      // magnetism toward horizontal or vertival lines
      ptb=[ngr_objects(sd)('x')(pt1-1),ngr_objects(sd)('y')(pt1-1)];
      ptn=[ngr_objects(sd)('x')(pt1+1),ngr_objects(sd)('y')(pt1+1)];
      ptmin=min(ptb,ptn);ptmax=max(ptb,ptn);
      pts=[ptmin;ptmax;ptmin(1),ptmax(2);ptmax(1),ptmin(2)]
      dd= abs(pts-ones_new(4,1)*ptnew);
      k=find(max(dd,'c') < 5);
      if ~isempty(k) then
	xinfo('found '+string(pts(k(1),1))+' '+string(pts(k(1),2)));
	ptnew= pts(k(1),:)
      end
    elseif pt1==1 then
       // try to check if we are in the vivinity of
       // a lock point lock points ptl=[lock-number,point]
       [k,ptl]=ngr_lock(ptnew);
       if k<>0 then
	 // we force the point to move to ptl(2:3)
	 // the lock point near ptnew position
	 ptnew=ptl(2:3);
	 rr = ngr_objects(sd)('lock first');
	 if  rr(1) == 1 ;
	   // we were already locked somewhere; unlock
	   ngr_objects(rr(2))('locks status')(rr(3))=0;// set unlock
	 end
	 // lock at new point
	 xinfo('trying to lock '+string(k)+' '+string(ptl(1)));
	 ngr_objects(sd)('lock first')=[1,k,ptl(1)];
	 ngr_objects(k)('locks status')(ptl(1))= - sd ;// set lock (<0)

       else
	  // just test if unlock is necessary
	  rr= ngr_objects(sd)('lock first');
	  if  rr(1) == 1 ;
	    xinfo('trying to unlock '+string(rr(2))+' '+string(rr(3)));
	    ngr_objects(rr(2))('locks status')(rr(3))=0;// set unlock
	    ngr_objects(sd)('lock first')=0;
	  end
       end
    elseif pt1==n then
       // try to check if we are in the vivinity of
       // a lock point lock points ptl=[lock-number,point]
       [k,ptl]=ngr_lock(ptnew);
       if k<>0 then
	 // we force the point to move to ptl(2:3)
	 // the lock point near ptnew position
	 ptnew=ptl(2:3);
	 rr = ngr_objects(sd)('lock last');
	 if  rr(1) == 1 ;
	   // we were already locked somewhere; unlock
	   ngr_objects(rr(2))('locks status')(rr(3))=0;// set unlock
	 end
	 // lock at new point
	 xinfo('trying to lock '+string(k)+' '+string(ptl(1)));
	 ngr_objects(sd)('lock last')=[1,k,ptl(1)];
	 ngr_objects(k)('locks status')(ptl(1))=sd ;// set lock (>0)
       else
	  // just test if unlock is necessary
	  rr= ngr_objects(sd)('lock last');
	  if  rr(1) == 1 ;
	    xinfo('trying to unlock '+string(rr(2))+' '+string(rr(3)));
	    ngr_objects(rr(2))('locks status')(rr(3))=0;// set unlock
	    ngr_objects(sd)('lock last')=0;
	  end
       end
    end
    ngr_objects(sd).gr.invalidate[];
    ngr_objects(sd)('x')(pt1)=ptnew(1);
    ngr_objects(sd)('y')(pt1)=ptnew(2);
    ngr_objects(sd).gr.invalidate[];
   case 'locks' then
    // compute locks points
    sd1=[];
   case 'inside lock' then
    // check if we are near a lock point
    sd1=[0];
   case 'locks update' then
    // nothing to update
    sd1=[];
   case 'unlock all' then
    // check that locks are released
    rr=ngr_objects(sd)('lock first');
    if  rr(1) == 1 ;
      ngr_objects(sd)('lock first')=0;
      ngr_objects(rr(2))('locks status')(rr(3))=0;// set unlock
    end
    rr=ngr_objects(sd)('lock last');
    if  rr(1) == 1 ;
      ngr_objects(sd)('lock last')=0;
      ngr_objects(rr(2))('locks status')(rr(3))=0;// set unlock
    end
   case 'params' then
    colors=m2s(1:xget("lastpattern")+2,"%1.0f");
    lcols_bg=list('colors','Color',sd('color'),colors);
    l_th=list('combo','Thickness',sd('thickness'),string(1:10));
    [lrep,lres,rep]=x_choices('polyline settings',list(lcols_bg,l_th));
    if ~isempty(rep) then
      sd('color')=rep(1);
      sd('thickness')=rep(2);
    end
    sd1=sd;
  end
endfunction

function ngr_create_polyline()
// interactive acquisition of a polyline
//
  global('ngr_objects');
  ngr_unhilite();
  hvfactor=5;// magnetism toward horizontal and vertical line
  xinfo('Enter polyline, Right click to stop');
  rep(3)=%inf;
  wstop = 0;
  kstop = 2;
  count = 2;
  ok=%t;
  // record non moving graphics.
  [i,x,y]=xclick();
  ngr_poly('define',[x,x;y,y]);
  n = size(ngr_objects,0);
  ngr_objects(n)('hilited')=%t;
  if i==2 then ok=%f ; wstop=1; end
  F=get_current_figure();
  while wstop==0 , //move loop
    // draw block shape
    ngr_poly('update',n);
    // get new position
    rep=xgetmouse(clearq=%f,getmotion=%t,getrelease=%f);
    xinfo('rep='+string(rep(3)));
    if rep(3)== -100 then
      rep =rep(3);
      return;
    end ;
    // invalidate the old position before changing
    sdo = ngr_objects(n);
    sdo.gr.invalidate[];
    wstop= size(find(rep(3)== kstop),'*');
    if rep(3) == 0 then   count =count +1;end
    if rep(3) == 0 | rep(3) == -1 then
      // are we near a lock point
      [k,ptl]=ngr_lock(rep(1:2));
      if k<>0 then
	ngr_objects(n)('x')(count)=ptl(2);
	ngr_objects(n)('y')(count)=ptl(3);
	ngr_objects(n)('lock last')=[1,k,ptl(1)];
	if rep(3)==0;wstop=1;end
      else
	 // try to keep horizontal and vertical lines
	 if abs(ngr_objects(n)('x')(count-1)- rep(1)) < hvfactor then
	   rep(1)=ngr_objects(n)('x')(count-1);end
	 if abs(ngr_objects(n)('y')(count-1)- rep(2)) < hvfactor then
	   rep(2)=ngr_objects(n)('y')(count-1);end
	 ngr_objects(n)('x')(count)=rep(1);
	 ngr_objects(n)('y')(count)=rep(2);
	 ngr_objects(n)('lock last')=[0];
      end
    end
  end
  // update and draw block
  if ~ok then return ;end
  // check if the polyline is locked at some rectangles lock point
  [k,ptl]=ngr_lock([ngr_objects(n)('x')(1),ngr_objects(n)('y')(1)]);
  if k<>0 then
    ngr_objects(n)('x')(1)=ptl(2);
    ngr_objects(n)('y')(1)=ptl(3);
    ngr_objects(n)('lock first')=[1,k,ptl(1)];
    ngr_objects(k)('locks status')(ptl(1))= - n;// set lock (<0)
  end
  //Attention ici $ est mal evalue XXXX
  //[k,ptl]=ngr_lock([poly('x')($),poly('y')($)]);
  np=size(ngr_objects(n)('x'),'*');
  [k,ptl]=ngr_lock([ngr_objects(n)('x')(np),ngr_objects(n)('y')(np)]);
  if k<>0 then
    ngr_objects(n)('x')(np)=ptl(2);
    ngr_objects(n)('y')(np)=ptl(3);
    ngr_objects(n)('lock last')=[1,k,ptl(1)];
    ngr_objects(k)('locks status')(ptl(1))=n;// set lock (>0)
  end
endfunction


//-----------------------------------
// filled rectangle
//-----------------------------------

function sd1=ngr_frect(sd,del)
  sd1=[];
  if nargin<=0 then // get
    [x1,y1,x2,y2,but]=xgetm(d_xrect)
    if but==2 then sd1=list();return,end
    sd1=list("frect",x1,x2,y1,y2);
    d_xfrect(x1,y1,x2,y2);
  elseif nargin==1 then //draw
     x1=sd(2);x2=sd(3),y1=sd(4),y2=sd(5)
     d_xfrect(x1,y1,x2,y2);
  elseif del=='del' then //erase
     x1=sd(2);x2=sd(3),y1=sd(4),y2=sd(5)
     d_xfrect(x1,y1,x2,y2);
  elseif del=='mov' then //move
     x1=sd(2);x2=sd(3),y1=sd(4),y2=sd(5)
     x0=xx(1);y0=xx(2);
     [xo,yo]=move_object('d_xfrect(x1-(x0-xo),y1-(y0-yo),x2-(x0-xo),y2-(y0-yo))',x0,y0);
     sd(2)=sd(2)-(x0-xo)
     sd(3)=sd(3)-(y0-yo)
     sd(4)=sd(4)-(x0-xo)
     sd(5)=sd(5)-(y0-yo)
  end
endfunction

// circle

function sd1=ngr_cerc(sd,del)
  sd1=[];
  if nargin<=0 then // get
    [c1,c2,x1,x2,but]=xgetm(d_circle);
    if but==2 then sd1=list();return,end
    x=[x1;x2],c=[c1;c2];r=norm(x-c,2);
    sd1=list("cercle",c,r);
    d_circle(c,r);
  elseif nargin==1 then //draw
     c=sd(2);r=sd(3);
     d_circle(c,r);
  elseif del=='del' then //erase
     c=sd(2);r=sd(3);
     d_circle(c,r);
  elseif del=='mov' then //move
     c=sd(2);r=sd(3)
     x0=xx(1);y0=xx(2);
     [xo,yo]=move_object('d_circle(c-[x0-xo;y0-yo],r)',x0,y0);
     sd(2)=sd(2)-[x0-xo;y0-yo]
  end;
endfunction

// filled circle

function sd1=ngr_fcerc(sd,del)
  sd1=[];
  if nargin<=0 then // get
    [c1,c2,x1,x2,but]=xgetm(d_circle);
    if but==2 then sd1=list();return,end
    x=[x1;x2],c=[c1;c2];r=norm(x-c,2);
    sd1=list("fcercle",c,r);
    d_fcircle(c,r);
  elseif nargin==1 then //draw
     c=sd(2);r=sd(3)
     d_fcircle(c,r);
  elseif del=='del' then //erase
     c=sd(2);r=sd(3)
     d_fcircle(c,r);
  elseif del=='mov' then //move
     c=sd(2);r=sd(3)
     x0=xx(1);y0=xx(2);
     [xo,yo]=move_object('d_fcircle(c-[x0-xo;y0-yo],r)',x0,y0);
     sd(2)=sd(2)-[x0-xo;y0-yo]
  end;
endfunction

// arrow

function [sd1]=ngr_fleche(sd,del)
  sd1=[]
  if nargin<=0 then // get
    [oi1,oi2,of1,of2,but]=xgetm(d_arrow);
    if but==2 then sd1=list();return,end
    o1=[oi1;of1],o2=[oi2;of2];
    [r1,r2]=xgetech()
    sz=1/(40*min(abs(r2(3)-r2(1)),abs(r2(4)-r2(2))))
    sd1=list("fleche",o1,o2,sz);
    d_arrow(o1,o2,sz);
  elseif nargin==1 then //draw
     o1=sd(2),o2=sd(3),
     sz=-1
     if size(sd)>=4 then sz=sd(4),end
     d_arrow(o1,o2,sz);
  elseif del=='del' then //erase
     o1=sd(2),o2=sd(3),
     sz=-1
     if size(sd)>=4 then sz=sd(4),end
     d_arrow(o1,o2,sz);
  elseif del=='mov' then //move
     o1=sd(2),o2=sd(3),
     sz=-1
     if size(sd)>=4 then sz=sd(4),end
     x0=xx(1);y0=xx(2);
     [xo,yo]=move_object('d_arrow(o1-(x0-xo),o2-(y0-yo),sz)',x0,y0);
     sd(2)=sd(2)-(x0-xo)
     sd(3)=sd(3)-(y0-yo)
  end
endfunction

// Text
//-----

function [sd1]=ngr_comment(sd,del)
  sd1=[];
  if nargin<=0 then // get
    [i,z1,z2]=xclick(0);z=[z1;z2];
    com=x_dialog("Enter string"," ");
    if ~isempty(com) then
      sd1=list("comm",z,com),
      xstring(z(1),z(2),com,0,0);
    end
  elseif nargin==1 then //draw
     z=sd(2);com=sd(3);
     xstring(z(1),z(2),com,0,0);
  elseif del=='del' then //erase
     z=sd(2);com=sd(3);
     xstring(z(1),z(2),com,0,0);
  elseif del=='mov' then //move
     z=sd(2);com=sd(3);
     [xo,yo]=move_object('xstring(xo,yo,com,0,0)',z(1),z(2));
     sd1=sd;sd1(2)(1)=xo;sd1(2)(2)=yo;
  end;
endfunction

// ?

function [sd1]=ngr_ligne(sd,del)
// polyline
  sd1=[];
  if nargin<=0 then // get
    z=xgetpoly(d_seg);
    if isempty(z), return;end;
    sd1=list("ligne",z);
    xpoly(z(1,:)',z(2,:)',type="lines")
  elseif nargin==1 then //draw
     z=sd(2);
     xpoly(z(1,:)',z(2,:)',type="lines")
  elseif del=='del' then //erase
     z=sd(2);
     xpoly(z(1,:)',z(2,:)',type="lines")
  elseif del=='mov' then //move
     z=sd(2);
     x0=xx(1);y0=xx(2);
     [xo,yo]=move_object('xpoly(z(1,:)''-(x0-xo),z(2,:)''-(y0-yo),type=""lines"")',x0,y0);
     sd(2)=[z(1,:)-(x0-xo);z(2,:)-(y0-yo)]
  end;
endfunction

function [sd1]=ngr_fligne(sd,del)
// filled polyline
  sd1=[];
  if nargin<=0 then // get
    z=xgetpoly(d_seg);
    if isempty(z), return;end;
    sd1=list("fligne",z);
    xfpoly(z(1,:),z(2,:),1);
  elseif nargin==1 then //draw
     z=sd(2);
     xfpoly(z(1,:),z(2,:),1);
  elseif del=='del' then //erase
     z=sd(2);
     xfpoly(z(1,:),z(2,:),1)
  elseif del=='mov' then //move
     z=sd(2);
     x0=xx(1);y0=xx(2);
     [xo,yo]=move_object('xfpoly(z(1,:)-(x0-xo),z(2,:)-(y0-yo),1)',x0,y0);
     sd(2)=[z(1,:)-(x0-xo);z(2,:)-(y0-yo)]
  end;
endfunction

function [sd1]=ngr_curve(sd,del)
// smoothed curve
  sd1=[];
  if nargin<=0 then ,//get
    z=xgetpoly(d_seg);
    if isempty(z), return;end
    mm=clearmode();xpoly(z(1,:)',z(2,:)',type="lines");modeback(mm)
    [x1,k1]=sort(z(1,:));y1=z(2,k1);z=[x1;y1];
    [n1,n2]=size(z);z=smooth(z(:,n2:-1:1));
    sd1=list("ligne",z);
  else
     z=sd(2);
  end;
  xpoly(z(1,:)',z(2,:)',type="lines");
endfunction

function [sd1]=ngr_points(sd,del)
// polymark
  sd1=[];
  if nargin<=0 then //get
    z=xgetpoly(d_point);
    if isempty(z), return;end;
    sd1=list("point",z);
    xpoly(z(1,:)',z(2,:)',type="marks");
  elseif nargin==1 then //draw
     z=sd(2);
     xpoly(z(1,:)',z(2,:)',type="marks");
  elseif del=='del' then //erase
     z=sd(2);
     xpoly(z(1,:)',z(2,:)',type="marks");
  elseif del=='mov' then //move
     z=sd(2);
     x0=xx(1);y0=xx(2);
     [xo,yo]=move_object('xfpoly(z(1,:)''-(x0-xo),z(2,:)''-(y0-yo),""marks"")',x0,y0);
     sd(2)=[z(1,:)-(x0-xo);z(2,:)-(y0-yo)]
  end;
endfunction

function [sd1]=ngr_clipoff(sd,del)
  sd1=[];
  if nargin<=0 then ,
    sd1=list("clipoff")
  end;
  xclip();
endfunction

function [sd1]=ngr_clipon(sd,del)
  sd1=[];
  if nargin<=0 then ,
    sd1=list("clipon")
  end;
  xclip('clipgrf');
endfunction

function ngr_eventhandler(win,x,y,ibut)
// can be used as synchronous or asynchronous
// event handler. Note that in in asynchronous
// event handler mode (x,y) are to be changed via
// xchange(x,y,'i2f');
  global('ngr_objects');
  global('count');
  //if count == 1 then
  //  printf("event handler aborted =%d\n",count)
  //  return
  //end
  count = 1;
  if ibut == -100 then
    printf('window killed ')
  elseif ibut==-1 then
    //printf('ibut==-1\n')
    //[xc,yc]=xchange(x,y,'i2f')
    [xc,yc]=(x,y)
    xinfo('Mouse position is ('+string(xc)+','+string(yc)+')')
  elseif ibut==0 then
    //printf('ibut==0\n')
    //[xc,yc]=xchange(x,y,'i2f')
    [xc,yc]=(x,y)
    k = ngr_find(xc,yc);
    if k<>0 then
      rep(3)=-1
      o=ngr_objects(k);
      // are we moving the object or a control point
      execstr('ic=ngr_'+o.type+'(''inside control'',k,[xc,yc]);');
      ngr_unhilite();
      ngr_objects(k)('hilited')=%t;
      // interactive move
      if ic(1)==0 then
	// we are moving the object
	[rep]=ngr_frame_move(k,[xc,yc],-5,'move draw',0)
	if rep== -100 then
	  count= 0;
	  return;
	end
      else
	// we are moving a control point of the object
	execstr('ngr_'+o.type+'(''move point init'',k,ic(2));');
	[rep]=ngr_frame_move(k,[xc,yc],-5,'move point',ic(2))
	if rep== -100 then
	  count=0;
	  return;
	end
      end
    else
      xinfo('Click in empty region');
    end
  elseif ibut==2
    //printf('ibut==2\n')
    //[xc,yc]=xchange(x,y,'i2f')
    [xc,yc]=(x,y);
    k = ngr_find(xc,yc);
    if k<>0 then
      rep(3)=-1
      obj=ngr_objects(k);
      execstr('obj1=ngr_'+obj.type+'(''params'',obj,0);');
      ngr_objects(k)=obj1;
      // should check here if redraw is needed
      if ~obj1.equal[obj] then
	execstr('obj1=ngr_'+obj.type+'(''update'',k,0);');
      end
    end
  elseif ibut==100
    //printf('ibut==100\n')
    ngr_delete();
  elseif ibut==99
    printf('ibut==99\n')
    ngr_copy();
  else
    xinfo('Mouse action: ['+string(ibut)+']');
  end
  count=0;
endfunction

function [rep]=ngr_frame_move(ko,pt,kstop,action,pt1)
// move object in frame
  global('ngr_objects');
  rep=[0,0,%inf];
  wstop = 0;
  lcks=[];
  otype = ngr_objects(ko).type;
  of = 'ngr_'+otype;
  F=get_current_figure();
  // record graphics except ko and lcks
  execstr('lcks='+of+'(''locks update'',ko);');
  while wstop==0 , //move loop
    execstr(of+'(''update'',ko);');
    if size(lcks,'*')<>0 then
      // draw connected links
      for lk= lcks
	lo = ngr_objects(lk);
	execstr('ngr_'+lo.type+'(''update'',lk);');
      end
    end
    // get new position
    rep=xgetmouse(clearq=%f,getmotion=%t,getrelease=%t);
    if rep(3)== -100 then
      rep =rep(3);
      return;
    end ;
    wstop= size(find(rep(3)== kstop),'*');
    // move object or point inside object
    execstr(of+'(action,ko,rep(1:2)- pt);');
    // update associated lock;
    execstr('lcks='+of+'(''locks update'',ko);');
    pt=rep(1:2);
  end
  // update and draw block
  rep=rep(3);
endfunction

//---------------------------------
// check if pt is in a lock point
//---------------------------------

function [k,rep]=ngr_lock(pt)
  global('ngr_objects');
  for k=1:size(ngr_objects)
    o=ngr_objects(k);
    execstr('rep=ngr_'+o.type+'(''inside lock'',k,pt);');
    if rep(1)==1 then
      rep=rep(2:4);
      return ;
    end
  end
  k=0;rep=0;
endfunction


//--------------------------------------
// find object k for which [x,y] is inside
//--------------------------------------

function k=ngr_find(x,y)
  global('ngr_objects');
  for k=1:size(ngr_objects)
    o=ngr_objects(k);
    execstr('ok=ngr_'+o.type+'(''inside'',k,[x,y]);');
    if ok then return ; end
  end
  k=0;
endfunction


//--------------------------------------
// unhilite objects and redraw
//--------------------------------------

function ngr_unhilite(win=-1,draw=%t)
  global('ngr_objects');
  ok=%f;
  if win == -1 then win=xget('window');end
  for k=1:size(ngr_objects)
    o=ngr_objects(k);
    if o('hilited') then ok=%t;end
    ngr_objects(k)('hilited')=%f;
    execstr('ngr_'+o.type+'(''update'',k);');
  end
endfunction

function ngr_delete()
  // delete hilited objects
  global('ngr_objects');
  g_rep=%f
  F=get_current_figure();
  for k=size(ngr_objects):-1:1
    o=ngr_objects(k);
    if o('hilited') then
      execstr('rep=ngr_'+o.type+'(''unlock all'',k);');
      ngr_objects(k).gr.invalidate[];
      F.remove[ ngr_objects(k).gr];
      ngr_objects(k)=null();
      // we must update all the numbers contained in lock
      for j=1:size(ngr_objects)
	lkcs=ngr_objects(j)('locks status')
	for i=1:size(lkcs,'*')
	  if lkcs(i) >= k then
	    ngr_objects(j)('locks status')(i)= lkcs(i)-1;
	    ngr_objects(j).gr.invalidate[];
	  end
	end
      end
      g_rep=%t ;
    end
  end
  if g_rep==%f then
    xinfo('No object selected fo deletion');
  end
endfunction

function ngr_delete_all()
  // delete all objects
  global('ngr_objects');
  F=get_current_figure();
  F.draw_latter[];
  for k=size(ngr_objects):-1:1
    F.remove[ ngr_objects(k).gr];
    ngr_objects(k)=null();
  end
  F.draw_now[];
  F.process_events[];
endfunction

function ngr_copy()
  // copy  hilited objects
  global('ngr_objects');
  g_rep=%f
  k1=size(ngr_objects):-1:1;
  F=get_current_figure();
  A=F.children(1);
  for k=k1;
    o=ngr_objects(k);
    if o('hilited') then
      o.gr = o.gr.full_copy[];
      ngr_objects($+1)=o;
      A.children($+1)=o.gr;
      n=size(ngr_objects,0);
      ngr_objects(n)('hilited')=%f;
      execstr('ngr_'+o.type+'(''move'',n);');
      g_rep=%t ;
    end
  end
  if g_rep==%f then
    xinfo('No object selected fo copy');
  end
endfunction

function [pt,kmin,pmin,dmin]=ngr_dist2polyline(xp,yp,pt)
// utility function
// distance from a point to a polyline
// the point is on the segment [kmin,kmin+1] (note that
// kmin is < size(xp,'*'))
// and its projection is at point
// pt = [ xp(kmin)+ pmin*(xp(kmin+1)-xp(kmin)) ;
//        yp(kmin)+ pmin*(yp(kmin+1)-yp(kmin))
// the distance is dmin
// Copyright ENPC
  n=size(xp,'*');
  ux= xp(2:n)-xp(1:n-1);
  uy= yp(2:n)-yp(1:n-1);
  wx= pt(1) - xp(1:n-1);
  wy= pt(2) - yp(1:n-1);
  un= ux.*ux + uy.*uy
  // XXXX %eps
  eps= 1.e-10;
  un=max(un,100*eps); // to avoid pb with empty segments
  p = max(min((ux.*wx+ uy.*wy)./un,1 ),0);
  // the projection of pt on each segment
  gx= wx -  p .* ux;
  gy= wy -  p .* uy;
  [d2min,kmin] = min(gx.*gx + gy.*gy );
  dmin=sqrt(d2min);
  pmin= p(kmin);
  pt = [ xp(kmin)+ pmin*(xp(kmin+1)-xp(kmin));yp(kmin)+ pmin*(yp(kmin+1)-yp(kmin))];
endfunction


function [ngr_options,edited]=ngr_do_options(ngr_options)
// Copyright ENPC/jpc  options for ngr_menus
//
  ngr_def= hash_create(color=4,background=xget('white'),foreground=6,font=2,font_size=1,clip=0);
  if nargin < 1 then   ngr_options=ngr_def;end
  if  type(ngr_options,'short')<>'h' then
    ngr_options=ngr_def;edited=%t;return;
  end
  colors=m2s(1:xget("lastpattern")+2,"%1.0f");
  fontsSiz=['08','10','12','14','18','24'];
  fontsIds=[ 'Courrier','Symbol','Times','Times Italic','Times Bold',
	     'Times B. It.'];
  marksIds=['.','+','x','*','diamond fill.','diamond','triangle up',
	    'triangle down','trefle','circle'];
  DashesIds=['Solid','-2-  -2-','-5-  -5-','-5-  -2-','-8-  -2-',
	     '-11- -2-','-11- -5-'];
  edited=%f
  l_col=list('colors','color',ngr_options.color,colors);
  l_bg=list('colors','Background',ngr_options.background,colors);
  l_fg=list('colors','Foreground',ngr_options.foreground,colors);
  l_fid=list('combo','fontId',ngr_options.font,fontsIds);
  l_fiz=list('combo','fontsize',ngr_options.font_size,fontsSiz);
  l_clip=list('combo','Clip',ngr_options.clip,['No','Yes']);
  Lc = list(l_col,l_bg,l_fg,l_fid,l_fiz,l_clip);
  [lrep,lres,rep]=x_choices('GrMenu options',Lc,%t);
  if ~isempty(rep) then
    ngr_options=hash_create(color=rep(1),...
			   background=rep(2),...
			   foreground=rep(3),...
			   font=rep(4),...
			   font_size=rep(5),...
			   clip=rep(6));
    edited=%t;
  end
endfunction

function [btn,xc,yc,win,Cmenu]=ngr_get_click(curwin,flag)
  if ~or(winsid() == curwin) then
    btn= -100;xc=0;yc=0;win=curwin;Cmenu='Quit';
    return,
  end;
  if nargout == 1 then
    [btn, xc, yc, win, str] = xclick(flag);
  else
    [btn, xc, yc, win, str] = xclick();
  end
  if btn == -100 then
    if win == curwin then
      Cmenu = 'Quit';
    else;
      Cmenu = 'Open/Set';
    end;
    return;
  end;
  if btn == -2 then
    // click in a dynamic menu
    if ~isempty(strindex(str,'_'+string(curwin)+'(')) then
      // click in a scicos dynamic menu
      // note that this would not be valid if multiple scicos
      execstr('Cmenu='+part(str,9:length(str)-1))
      execstr('Cmenu='+Cmenu);
      return
    else
      execstr('str='+str,errcatch=%t);
      Cmenu=str;
      return
    end
  end
  Cmenu="";
endfunction

function sd=ngr_delete_gr(sd)
// converts a sd to list to a string matrix
// giving the same graphics.
  for i=1:length(sd)
    sd(i).delete['gr'];
  end
endfunction


function S=ngr_sd_to_string(sd)
// converts a sd to list to a string matrix
// giving the same graphics.
  S=m2s([]);
  objs=sd(3);
  for i=1:length(objs)
    obj=objs(i);
    select obj.type
     case 'poly'
      tt=sprint(obj('x'),as_read=%t);
      tt=tt(2:$);
      tt(1)='px='+tt(1);
      S.concatd[tt];
      tt=sprint(obj('y'),as_read=%t);
      tt=tt(2:$);
      tt(1)='py='+tt(1);
      S.concatd[tt];
      S.concatd['px=px*sz(1)/100+orig(1);py=py*sz(2)/100+orig(2)'];
      tt=sprintf('xpoly(px,py,type=''lines'',color=%d,thickness=%d)',...
		 obj('color'),obj('thickness'));
      S.concatd[tt];
     case 'rect'
      tt=sprint(obj('data'),as_read=%t);
      S.concatd['r='+tt(2:$)];
      S.concatd['r=r.*[sz(1),sz(2),sz(1),sz(2)]/100;'];
      S.concatd['r=[r(1)+orig(1),r(2)+orig(2),r(3),r(4)]'];
      tt=sprintf('xrect(r,color=%d,background=%d,thickness=%d);',...
		 1,obj('color'),obj('thickness'));
      S.concatd[tt];
    end
  end
endfunction
