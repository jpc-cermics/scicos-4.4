function [x,y,ok,gc]=edit_curv(x,y,job,tit,gc)
// Copyright (C) 2011 Jean-Philippe Chancelier Cermics/Enpc
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//
// interactive curve edition 
// Sould be simplified by removing the locks which are
// unsused here
// 
  if nargin <=0 then x=(1:5)',y=x.^2;end
  if nargin <=2 then job='axy';end 
  if nargin <=3 then tit=['','',''];end 
  if nargin <=4 then 
    rect=[min(x),min(y),max(x),max(y)];
    axisdata=[2 10 2 10]
    gc=list(rect,axisdata)
  end
  o=hash(x=x(:)',y=y(:)');
  sd=list('sd',[min(x),min(y),max(x),max(y)],list(o));
  if ~isempty(winsid()) then 
    cwin=xget('window')
    win=max(winsid())+1
  else
    cwin=[];
    win=1;
  end
  xselect(win);
  [sd,ok]=ec_main(sd);
  xdel(win)
  if ~isempty(cwin); xset('window',cwin);end 
  if ok then 
    x= sd(3)(1)('x');
    y= sd(3)(1)('y');
    x=x(:);y=y(:);
    gc(1)=sd(2);
  end
endfunction

function [sd,ok]=ec_main(sd)
  ok=%f;
  global('ec_objects');
  if ~new_graphics() then 
    switch_graphics();
  end
  scsmode=%f
  if nargin<=0 then
    sd=list('sd',[0,0,100,100]);
  end
  if nargin<=1,
    select type(sd,'string')
     case 'Mat' then 
      sd=list('sd',sd);
     case 'List' then
      if sd(1)<>'sd' then
	error('First argument should be a sd list\n");
	return;
      end
    else 
      error('Incorrect input expecting [xmin,ymin,xmax,ymax] or list(''sd'',,,)');
      return;
    end
  end;

  if length(sd) <= 2 then init=0;end
  ec_objects=list();
  // window initialize
  cdef = sd(2);
  xsetech(frect=cdef,fixed=%t);
  //plot2d([],[],rect=cdef,strf='151');
  dx2 = abs(cdef(3)-cdef(1)).^2;
  dy2 = abs(cdef(4)-cdef(2)).^2;
  //xgrid();
  curwin=xget('window')
  // menus 
  names = ['Edit','Objects'];
  Edit=['redraw','delete','change bounds','Abort','Quit'];
  Objects=['new curve';'read from file';'write to file'];
  menus=tlist(['menus',names,'names'],Edit,Objects);
  Edit='menus(names(1))'+string(1:size(Edit,'*'))+')';
  Objects='menus(names(3))'+string(1:size(Objects,'*'))+')';
  
  for k=1:size(names,'*') ;
    delmenu(curwin,names(k));
    addmenu(curwin,names(k),menus(names(k)),list(2,'ec_'+names(k)));
    execstr(names(k)+'_'+string(curwin)+'='+names(k)+';');
  end
  unsetmenu(curwin,'File',7) //close
  unsetmenu(curwin,'File',1) ;
  unsetmenu(curwin,'File',2) ;
  unsetmenu(curwin,'File',6) ;  
  unsetmenu(curwin,'3D Rot.')

  // initialize ec_objects with sd;
  if length(sd)==3 then 
    ec1=sd(3);
    for k=1:size(ec1)
      o = ec1(k);
      ec_poly('define',[o('x');o('y')]);
    end
  end
  // 
  while %t then
    [btn,xc,yc,win,Cmenu]=ec_get_click(curwin);
    if Cmenu=='Quit' then 
      if length(ec_objects)<>1 then 
	x_message(['You should just keep one polyline\n before quiting']);
      else
	ok=%t;
	break;
      end
    elseif  Cmenu=='Abort' then 
      break;
    end
    ec_eventhandler(win,xc,yc,btn);
  end
  [a,rect]=xgetech();
  sd(3)=ec_objects;
  sd(2)=rect;
  clearglobal ec_objects;
  // XXXX Note that here we could remove the gr from
  // sd 
endfunction

//---------------------------------------
// Edit menu 
//---------------------------------------

function str=ec_Edit(ind,win)
  // Activated whith menu Edit 
  global('ec_objects');
  str=menus.Edit(ind);
  select str 
   case 'redraw' then 
    F=get_current_figure();
    F.invalidate[];
   case 'delete' then 
    ec_delete();
   case 'change bounds' then 
    ec_change_bounds();
  end
endfunction

//---------------------------------------
// Object menu 
//---------------------------------------

function str=ec_Objects(ind,win)
// Activated whith menu Objects 
  global('ec_objects');
  str=menus.Objects(ind);
  if str.equal['read from file'] then 
    [x,y]=ec_readxy();
    if ~isempty(x) then 
      ec_poly('define',[x(:),y(:)]');
    end
  elseif str.equal['write to file'] then
    // 
    if length(ec_objects) >= 1 then 
      sd = ec_objects(1)
      ec_savexy(sd('x'),sd('y'))
    else
      xinfo('define a curve first');
    end
  else 
    execstr('ec_create_polyline()');
  end
endfunction

// ------------------------------------------
// polyline 
// ------------------------------------------

function sd1 =ec_poly(action,sd,pt,pt1)
  global('ec_objects');
  control_color=10;
  sd1=0;
  select action 
   case 'update' then 
    // invalidate old position 
    // update the graphics associated to polyline 
    sdo = ec_objects(sd);
    sdo.gr.children(1).x = sdo('x');
    sdo.gr.children(1).y = sdo('y');
    sdo.gr.children(1).hilited = sdo('hilited');
    sdo.gr.children(1).color = sdo('color');
    sdo.gr.children(1).thickness = sdo('thickness');
    sdo.gr.invalidate[];
   case 'translate' then 
    // translate sd with translation vector pt 
    ec_objects(sd)('x')=ec_objects(sd)('x')+pt(1);
    ec_objects(sd)('y')=ec_objects(sd)('y')+pt(2);
    ec_objects(sd).gr.translate[pt];
   case 'define' then 
    ff=["poly","show","hilited","x","y","color","thickness","pt"];
    sdo= tlist(ff, %t,%f,sd(1,:),sd(2,:),1,2,[0,0]);
    F=get_current_figure();
    F.start_compound[];
    xpoly(sdo('x'),sdo('y'),type='lines',color=sdo('color'),thickness=sdo('thickness'));
    sdo.gr = F.end_compound[];
    sdo.gr.children(1).hilited = %t;
    sdo('hilited')=%t;
    ec_objects($+1)=sdo;
    sdo.gr.invalidate[];
   case 'move' then 
    ec_poly('translate',sd,[5,5]);
   case 'inside' then 
    // is pointer near object 
    sd=ec_objects(sd);
    [pt,kmin,pmin,d]=ec_dist2polyline(sd('x'),sd('y'),pt);
    sd1 = d < 0.05 ;  
   case 'inside control' then
    // check if we are near a control point 
    sd=ec_objects(sd);
    [d,k]=min( (sd('x')-pt(1)).^2/dx2 + (sd('y')-pt(2)).^2/dy2 )
    if d < 0.05 then 
      sd1=[1,k]
      xinfo('control point '+string(k));
    else 
       sd1=[0]
    end
   case 'move draw' then 
    // translate then draw (forcing the show)
    // used when object is moved 
    ec_poly('translate',sd,pt);
   case 'move point init' then 
    ec_objects(sd)('pt')=  [ec_objects(sd)('x')(pt),ec_objects(sd)('y')(pt)];
   case 'move point' then 
    // move a control point 
    xinfo('moving control '+string(pt1));
    // force horizontal and vertical line 
    // when we are in the vicinity of it 
    n = size(ec_objects(sd)('x'),'*');
    // we keep in pt the current point position 
    // since magnetism can move us to a new position 
    ptc = ec_objects(sd)('pt');
    //ptc=[ec_objects(sd)('x')(pt1),ec_objects(sd)('y')(pt1)];
    ptnew = ptc+pt;
    ec_objects(sd)('pt')=ptnew;
    if pt1 >= 2 & pt1 < n then 
      // magnetism toward horizontal or vertival lines 
      ptb=[ec_objects(sd)('x')(pt1-1),ec_objects(sd)('y')(pt1-1)];
      ptn=[ec_objects(sd)('x')(pt1+1),ec_objects(sd)('y')(pt1+1)];
      ptmin=min(ptb,ptn);ptmax=max(ptb,ptn);
      pts=[ptmin;ptmax;ptmin(1),ptmax(2);ptmax(1),ptmin(2)]
      dd= abs(pts-ones_new(4,1)*ptnew);
      k=find(max(dd,'c') < 5*min(cdef(3:4))/100);
      if ~isempty(k) then 
	xinfo('found '+string(pts(k(1),1))+' '+string(pts(k(1),2)));
	ptnew= pts(k(1),:)
      end
    end
    ec_objects(sd)('x')(pt1)=ptnew(1);
    ec_objects(sd)('y')(pt1)=ptnew(2);
    ec_objects(sd).gr.invalidate[];
   case 'addpt' then 
    xinfo('adding a point')
    // is pointer near object 
    [pt,kmin,pmin,d]=ec_dist2polyline(sd('x'),sd('y'),pt);
    sd1=sd;
    xx = sd('x'); yy = sd('y');
    sd1('x')=[xx(1:kmin),pt(1),xx(kmin+1:$)];
    sd1('y')=[yy(1:kmin),pt(2),yy(kmin+1:$)];
  end
endfunction

function ec_create_polyline()
// interactive acquisition of a polyline 
  global('ec_objects');
  ec_unhilite();   
  hvfactor=0;// magnetism toward horizontal and vertical line 
  xinfo('Enter polyline, Right click to stop');
  rep(3)=%inf;
  wstop = 0; 
  kstop = 2;
  count = 2;
  ok=%t;
  // record non moving graphics.
  [i,x,y]=xclick();
  ec_poly('define',[x,x;y,y]);
  n = size(ec_objects,0);
  ec_objects(n)('hilited')=%t;
  if i==2 then ok=%f ; wstop=1; end 
  F=get_current_figure();
  while wstop==0 , //move loop
    // draw block shape
    ec_poly('update',n);
    // get new position
    rep=xgetmouse(clearq=%f,getmotion=%t,getrelease=%f);
    xinfo('rep='+string(rep(3)));
    if rep(3)== -100 then
      rep =rep(3);
      return; 
    end ;
    // invalidate old position 
    sd = ec_objects(n);
    sd.gr.invalidate[];
    wstop= size(find(rep(3)== kstop),'*');
    if rep(3) == 0 then   count =count +1;end 
    if rep(3) == 0 | rep(3) == -1 then 
      // try to keep horizontal and vertical lines 
      if abs(ec_objects(n)('x')(count-1) - rep(1)) < hvfactor then 
	rep(1)=ec_objects(n)('x')(count-1);
      end 
      if abs(ec_objects(n)('y')(count-1)- rep(2)) < hvfactor then 
	rep(2)=ec_objects(n)('y')(count-1);
      end 
      ec_objects(n)('x')(count)=rep(1);
      ec_objects(n)('y')(count)=rep(2);
    end
  end
endfunction

function [sd1]=ec_clipoff(sd,del)
  sd1=[];
  if nargin<=0 then ,
    sd1=list("clipoff")
  end;
  xclip();
endfunction

function [sd1]=ec_clipon(sd,del)
  sd1=[];
  if nargin<=0 then ,
    sd1=list("clipon")
  end;
  xclip('clipgrf');
endfunction

function ec_eventhandler(win,x,y,ibut)
// can be used as synchronous or asynchronous 
// event handler. Note that in in asynchronous 
// event handler mode (x,y) are to be changed via 
// xchange(x,y,'i2f');
  global('ec_objects');
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
    k = ec_find(xc,yc);
    if k<>0 then 
      rep(3)=-1
      o=ec_objects(k);
      // are we moving the object or a control point 
      execstr('ic=ec_'+o.type+'(''inside control'',k,[xc,yc]);');
      ec_unhilite();
      ec_objects(k)('hilited')=%t;
      // interactive move 
      if ic(1)==0 then 
	// we are moving the object 
	[rep]=ec_frame_move(k,[xc,yc],-5,'move draw',0)
	if rep== -100 then  
	  count= 0; 
	  return;
	end 
      else 
	// we are moving a control point of the object 
	execstr('ec_'+o.type+'(''move point init'',k,ic(2));');
	[rep]=ec_frame_move(k,[xc,yc],-5,'move point',ic(2))
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
    k = ec_find(xc,yc);
    if k<>0 then 
      rep(3)=-1
      obj=ec_objects(k);
      execstr('obj1=ec_'+obj.type+'(''addpt'',obj,[xc,yc]);');
      ec_objects(k)=obj1;
      // should check here if redraw is needed 
      if ~obj1.equal[obj] then 
	execstr('obj1=ec_'+obj.type+'(''update'',k,0);');
      end
    end
  else
    xinfo('Mouse action: ['+string(ibut)+']');
  end
  count=0;
endfunction

function [rep]=ec_frame_move(ko,pt,kstop,action,pt1)
// move object in frame 
  global('ec_objects');
  rep=[0,0,%inf];
  wstop = 0; 
  otype = ec_objects(ko).type; 
  of = 'ec_'+otype;
  F=get_current_figure();
  while wstop==0 , //move loop
    execstr(of+'(''update'',ko);');
    // get new position
    F.draw_now[];
    rep=xgetmouse(clearq=%f,getmotion=%t,getrelease=%t);
    if rep(3)== -100 then 
      rep =rep(3);
      return; 
    end ;
    wstop= size(find(rep(3)== kstop),'*');
    // move object or point inside object 
    execstr(of+'(action,ko,rep(1:2)- pt);');
    // update associated lock; 
    pt=rep(1:2);
  end
  // update and draw block
  rep=rep(3);
  F.draw_now[];
endfunction

//--------------------------------------
// find object k for which [x,y] is inside 
//--------------------------------------

function k=ec_find(x,y)
  global('ec_objects');
  for k=1:size(ec_objects)
    o=ec_objects(k);
    execstr('ok=ec_'+o.type+'(''inside'',k,[x,y]);');
    if ok then return ; end 
  end
  k=0;
endfunction

//--------------------------------------
// unhilite objects and redraw
//--------------------------------------

function ec_unhilite(win=-1,draw=%t)
  global('ec_objects');
  ok=%f;
  if win == -1 then win=xget('window');end 
  for k=1:size(ec_objects)
    o=ec_objects(k);
    if o('hilited') then ok=%t;end 
    ec_objects(k)('hilited')=%f;
    execstr('ec_'+o.type+'(''update'',k);');
  end
endfunction 

function ec_delete()
  // delete hilited objects 
  global('ec_objects');
  g_rep=%f
  F=get_current_figure();
  F.draw_latter[];
  for k=size(ec_objects):-1:1
    o=ec_objects(k);
    if o('hilited') then 
      ec_objects(k).gr.invalidate[];
      F.remove[ ec_objects(k).gr];
      ec_objects(k)=null();
      g_rep=%t ; 
    end 
  end
  F.draw_now[];
  if g_rep==%f then 
    xinfo('No object selected fo deletion');
  end
endfunction 

function [pt,kmin,pmin,dmin]=ec_dist2polyline(xp,yp,pt)
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
  [d2min,kmin] = min(gx.*gx/dx2 + gy.*gy/dy2);
  dmin=sqrt(d2min);
  pmin= p(kmin);
  pt = [ xp(kmin)+ pmin*(xp(kmin+1)-xp(kmin));yp(kmin)+ pmin*(yp(kmin+1)- ...
						  yp(kmin))];
endfunction

function [btn,xc,yc,win,Cmenu]=ec_get_click(curwin)
  if ~or(winsid() == curwin) then  
    btn= -100;xc=0;yc=0;win=curwin;Cmenu='Abort';
    return,
  end;
  [btn, xc, yc, win, str] = xclick();
  if btn == -100 then
    if win == curwin then
      Cmenu = 'Abort';
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

function ec_savexy(x,y)
  while %t then 
    fn=xgetfile(masks='*.xy',save=%t)
    if fn=="" then return;end;
    if file('extension',fn) == '.xy' then break;end 
    x_message(['Give a filename with .xy extension']);
  end
  xy=[x;y];
  if ~execstr('save(fn,xy);',errcatch=%t) then
    x_message(['Impossible to save in the selected file';
	       'Check file and directory access'])
    
  end
endfunction

function [x,y]=ec_readxy()
  xy=[];x=[];y=[];
  fn=xgetfile(masks=['edit_curve';'*.xy'],open=%t)
  if fn==emptystr() then return;end 
  if ~execstr('load(fn)',errcatch=%t) then
    x_message(['Cannot load given file']);
  end
  if isempty(xy) then 
    x_message(['The given file does not seams to contain xy matrix']);
  end
  x=xy(1,:);
  y=xy(2,:);
endfunction

function rect=ec_change_bounds()
  [a,r]=xgetech();
  xmn=r(1);xmx=r(3);ymn=r(2);ymx=r(4);
  while %t
    [ok,xmn,xmx,ymn,ymx]=getvalue('Enter boundaries',..
				  ['xmin';'xmax';'ymin';'ymax'],..
				  list('vec',1,'vec',1,'vec',1,'vec',1),..
				  string([xmn;xmx;ymn;ymx]))
    if ~ok then break,end
    if xmn>xmx|ymn>ymx then
      x_message('Incorrect boundaries')
    else
      break
    end
  end
  if ok then
    dx=xmx-xmn;dy=ymx-ymn
    if dx==0 then dx=max(xmx/2,1),xmn=xmn-dx/10;xmx=xmx+dx/10;end
    if dy==0 then dy=max(ymx/2,1),ymn=ymn-dy/5;ymx=ymx+dy/10;end
    rect=[xmn,ymn,xmx,ymx];
    xsetech(frect=rect,fixed=%t);
    F=get_current_figure();
    F.invalidate[];    
  end
endfunction

    
