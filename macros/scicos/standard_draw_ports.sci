function standard_draw_ports(o)
// function used to draw ports 
  nin=size(o.model.in,1);
  nout=size(o.model.out,1);
  inporttype=o.graphics.in_implicit
  outporttype=o.graphics.out_implicit
  clkin=size(o.model.evtin,1);
  clkout=size(o.model.evtout,1);
  [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
  xset('pattern',default_color(0));
  //draw input/output ports
  //standard orientation or tilded orientation
  select_face=[3,2];
  select_face_out=select_face(orient+1);
  select_face_in=select_face((~orient)+1);
  xpos=[orig(1),orig(1)+sz(1)];
  xpos_out=xpos[orient+1];
  xpos_in= xpos[(~orient)+1];
  // set port shape
  dy=sz(2)/(nout+1)
  xset('pattern',default_color(1))
  // select the shape to use. 
  outtype=ones_new(1,nout);
  if ~isempty(outporttype) then  outtype( outporttype == 'I')=5;end 
  for k=1:nout
    if ~isempty(outporttype) && outporttype(k)=='B' then xset('pattern',default_color(3));end;
    scicos_lock_draw([xpos_out,orig(2)+sz(2)-dy*k],xf,yf,select_face_out,outtype(k));
    xset('pattern',default_color(1));
  end
  dy=sz(2)/(nin+1)
  outtype= 0*ones_new(1,nin);
  if ~isempty(inporttype) then  outtype( inporttype == 'I')=4;end 
  for k=1:nin
    if ~isempty(inporttype) && inporttype(k)=='B' then xset('pattern',default_color(3));end;
    scicos_lock_draw([xpos_in,orig(2)+sz(2)-dy*k],xf,yf,select_face_in,outtype(k));
    xset('pattern',default_color(1))
  end
  // draw input/output clock ports
  //------------------------
  dx=sz(1)/(clkout+1)
  xset('pattern',default_color(-1))
  for k=1:clkout
    scicos_lock_draw([orig(1)+k*dx,orig(2)],xf,yf,1,3)
  end
  dx=sz(1)/(clkin+1)
  for k=1:clkin
    scicos_lock_draw([orig(1)+k*dx,orig(2)+sz(2)],xf,yf,0,2)
  end
  xset('pattern',default_color(0))
endfunction 
