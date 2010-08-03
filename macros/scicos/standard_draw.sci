function standard_draw(o,frame,draw_ports,up)
  if nargin==1 then
    frame=%t
  end
  
  if nargin<3 then
    draw_ports=standard_draw_ports;
  elseif nargin==4 then
    draw_ports=standard_draw_ports_up;
  end

  if new_graphics() then 
    standard_draw_new(o,frame,draw_ports)
  else
    standard_draw_old(o,frame,draw_ports)
  end
endfunction

  
function standard_draw_old(o,frame,draw_ports)
// Copyright INRIA
  xf=60
  yf=40

  nin=size(o.model.in,1);
  nout=size(o.model.out,1);
  clkin=size(o.model.evtin,1);
  clkout=size(o.model.evtout,1);
  [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
  //  [orig,sz,orient]=o(2)(1:3)
  thick=xget('thickness');xset('thickness',2)
  
  // draw box
  pat=xget('pattern')
  xset('pattern',default_color(0))
  e=4
  if options.iskey['D3'] then f__3D= 'D3' else f__3D= '3D';end
  With3D=options(f__3D)(1)
  // if the block does not want 3D 
  if o.graphics.iskey['3D'] && o.graphics('3D') == %f then 
    With3D=%f;
  end
    
  if frame then
    if %t then 
      // accelerated code in C.
      scicos_draw3D(orig,sz,e,options(f__3D)(2));
    else
      if With3D then
	_Color3D=options(f__3D)(2)
	//3D aspect
	xset('thickness',2);
	xset('pattern',_Color3D)
	xpoly([orig(1)+e;orig(1)+sz(1);orig(1)+sz(1)],..
	      [orig(2)+sz(2);orig(2)+sz(2);orig(2)+e],type='lines')
	xset('pattern',default_color(0))
	xset('thickness',1)
	eps=0.3
	xx=[orig(1) , orig(1)
	    orig(1) , orig(1)+sz(1)-e
	    orig(1)+e   , orig(1)+sz(1)
	    orig(1)+e   , orig(1)+e];
	
	yy=[orig(2)         , orig(2)
	    orig(2)+sz(2)-e   , orig(2)
	    orig(2)+sz(2) , orig(2)+e
	    orig(2)+e           , orig(2)+e];     
	xfpolys(xx,yy,-[1,1]*_Color3D)
	xset('thickness',2);
      else
	e=0
	xset('thickness',2);
	xrect(orig(1),orig(2)+sz(2),sz(1),sz(2))
      end
    end
  end
  
  draw_ports(o)

  // draw Identification
  //------------------------
  ident = o.graphics.id;
  fnt=xget('font');
  if ~isempty(ident) & ident <> ''  then
    xset('font', options.ID(1)(1), options.ID(1)(2))
    rectangle = xstringl(orig(1), orig(2), ident)
    w = max(rectangle(3), sz(1))
    h = rectangle(4) * 1.3
    xstringb(orig(1) + sz(1) / 2 - w / 2, orig(2) - h ,	..
	     ident , w, h)
    xset('font', fnt(1), fnt(2))
  end
  
  xset('thickness',thick)

  function c=scs_color(c); if flag=='background' then c=coli,end;endfunction;
  flag='foreground'

  gr_i=o.graphics.gr_i;
  if is(gr_i,%types.List) then 
    [gr_i,coli]=gr_i(1:2);
  else 
    coli=[];
  end
  
  if isempty(coli) then
    coli=xget('background')
  end
  
  model=o.model
  if With3D&frame then
    orig=orig+e
    sz=sz-e
  end
  
  if new_graphics() then 
    border=options(f__3D)(2);
    //     gr_i=['xrect(orig(1),orig(2)+sz(2),sz(1),sz(2),background=coli,color=border)';
    // 	  gr_i];
    //gr_i=['xfrect(orig(1),orig(2)+sz(2),sz(1),sz(2),color=coli+6)';
    // gr_i];
  else
    gr_i=['pcoli=xget(''pattern'')';..
	  'xset(''pattern'',coli)'; 
	  'xfrect(orig(1),orig(2)+sz(2),sz(1),sz(2))';
	  'xset(''pattern'',pcoli)'
	  gr_i];
  end
  if  ~execstr(gr_i,errcatch=%t) then
    message(['Error in Icon defintion';
	     'See error message in scilab window']);
    printf("%s",lasterror());
    
  end
  xset('pattern',pat)
  xset('font',fnt(1),fnt(2))
  xset('thickness',1)
endfunction


function standard_draw_new(o,frame,draw_ports)
//
// Copyright INRIA
// modified for nsp new_graphics by jpc 
  
  xf=60
  yf=40

  nin=size(o.model.in,1);
  nout=size(o.model.out,1);
  clkin=size(o.model.evtin,1);
  clkout=size(o.model.evtout,1);
  [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
  //  [orig,sz,orient]=o(2)(1:3)
  
  thick=xget('thickness');xset('thickness',2)
  
  // draw box if needed 
  
  pat=xget('pattern');
  xset('pattern',default_color(0))
  e=4
  if options.iskey['D3'] then f__3D= 'D3' else f__3D= '3D';end
  With3D=options(f__3D)(1)
  // if the block does not want 3D 
  if o.graphics.iskey['3D'] && o.graphics('3D') == %f then 
    With3D=%f;
  end

  // get the background color of the block if 
  // specified 
  
  gr_i=o.graphics.gr_i;
  if is(gr_i,%types.List) then 
    [gr_i,coli]=gr_i(1:2);
  else 
    coli=[];
  end
  if isempty(coli) then
    coli=xget('background')
  end
  
  // Draw the frame of the block if requested 
  // i.e draw boundaries + paint the backaground 
  
  if frame then
    // offset when using with 3d 
    e = With3D*4; 
    // standard code 
    if With3D then
      // 3D aspect
      color=options(f__3D)(2)
      //xrect(orig(1)+e,orig(2)+sz(2),sz(1),sz(2),background=coli,color=color)
      xx= [orig(1)+e;orig(1)+sz(1);orig(1)+sz(1);orig(1)+e];
      yy= [orig(2)+sz(2);orig(2)+sz(2);orig(2)+e;orig(2)+e];
      xfpoly(xx,yy,color =color,fill_color=coli,thickness=0);
      eps=0.3
      xx=[orig(1) , orig(1)
	  orig(1) , orig(1)+sz(1)-e
	  orig(1)+e   , orig(1)+sz(1)
	  orig(1)+e   , orig(1)+e];
      yy=[orig(2)         , orig(2)
	  orig(2)+sz(2)-e   , orig(2)
	  orig(2)+sz(2) , orig(2)+e
	  orig(2)+e           , orig(2)+e];     
      // paint + draw the shadow 
      xfpoly(xx(:,1),yy(:,1),color =color,fill_color=color,thickness=0);
      xfpoly(xx(:,2),yy(:,2),color =color,fill_color=color,thickness=0);
    else
      // paint with coli draw with current figure color
      xrect(orig(1),orig(2)+sz(2),sz(1),sz(2),color=-1,background=coli);
    end
  end
  
  draw_ports(o)

  // draw Identification
  //------------------------
  ident = o.graphics.id;
  fnt=xget('font');
  if ~isempty(ident) & ident <> ''  then
    xset('font', options.ID(1)(1), options.ID(1)(2))
    rectangle = xstringl(orig(1), orig(2), ident)
    w = max(rectangle(3), sz(1))
    h = rectangle(4) * 1.3
    xstringb(orig(1) + sz(1) / 2 - w / 2, orig(2) - h ,	..
	     ident , w, h)
    xset('font', fnt(1), fnt(2))
  end
    
  xset('thickness',thick)

  function c=scs_color(c); if flag=='background' then c=coli,end;endfunction;
  flag='foreground'
  
  model=o.model
  if With3D && frame then
    orig=orig+e
    sz=sz-e
  end
    
  if  ~execstr(gr_i,errcatch=%t) then
    message(['Error in Icon defintion';
	     'See error message in scilab window']);
    printf("%s",lasterror());
    
  end
  xset('pattern',pat)
  xset('font',fnt(1),fnt(2))
  xset('thickness',1)
endfunction
