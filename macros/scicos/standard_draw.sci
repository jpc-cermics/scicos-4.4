function standard_draw(o,frame,draw_ports,up)
  if nargin==1 then
    frame=%t
  end
  
  if nargin<3 then
    draw_ports=standard_draw_ports;
  elseif nargin==4 then
    draw_ports=standard_draw_ports_up;
  end
  standard_draw_new(o,frame,draw_ports)
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
  // i.e draw boundaries + paint the background 
  
  if frame then
    // offset when using with 3d 
    e = With3D*4; 
    // standard code 
    if With3D then
      // 3D aspect
      color=options(f__3D)(2)
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
  
  // draw ports using the function transmited 
  draw_ports(o)

  // draw Identification
  ident = o.graphics.id;
  fnt=xget('font');
  if ~isempty(ident) & ident <> ''  then
    if ~exists("%zoom") then %zoom=1, end;
    fz= 2*%zoom*4;
    xset('font', options.ID(1)(1), options.ID(1)(2));
    xstring(orig(1)+sz(1)/2, orig(2),ident,posx='center',posy='up',size=fz);
    xset('font', fnt(1), fnt(2));
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
    printf("%s",lasterror());
    message(['Error in Icon defintion';
	     'See error message in nsp window']);
  end
  xset('pattern',pat)
  xset('font',fnt(1),fnt(2))
  xset('thickness',1)
endfunction
