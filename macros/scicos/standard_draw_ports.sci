function standard_draw_ports(o)
// function used to draw ports 
  nin=size(o.model.in,1);
  nout=size(o.model.out,1);
  inporttype=o.graphics.in_implicit
  outporttype=o.graphics.out_implicit
  clkin=size(o.model.evtin,1);
  clkout=size(o.model.evtout,1);
  [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
  // select face is used to define port orientation 
  select_face=[3,2];
  select_face_out=select_face(orient+1);
  select_face_in=select_face((~orient)+1);
  // position of ports 
  xpos=[orig(1),orig(1)+sz(1)];
  xpos_out=xpos[orient+1];
  xpos_in= xpos[(~orient)+1];
  dy=sz(2)/(nout+1)
  // select the shape to use rectangle or triangle.
  outtype=ones(1,nout);
  if ~isempty(outporttype) then  outtype( outporttype == 'I')=4;end 
  // select the color of ports 
  colors=ones(1,nout);
  if ~isempty(outporttype) then  colors( outporttype == 'B')=default_color(3);end 
  for k=1:nout
    scicos_lock_draw([xpos_out,orig(2)+sz(2)-dy*k],xf,yf,select_face_out,outtype(k),color=colors(k));
  end
  dy=sz(2)/(nin+1)
  outtype= 0*ones_new(1,nin);
  if ~isempty(inporttype) then  outtype( inporttype == 'I')=5;end 
  // select the color of ports 
  colors=ones(1,nin);
  if ~isempty(inporttype) then  colors( inporttype == 'B')=default_color(3);end 
  for k=1:nin
    scicos_lock_draw([xpos_in,orig(2)+sz(2)-dy*k],xf,yf,select_face_in,outtype(k),color=colors(k));
  end
  // draw input/output clock ports
  dx=sz(1)/(clkout+1)
  red = default_color(-1);
  for k=1:clkout
    scicos_lock_draw([orig(1)+k*dx,orig(2)],xf,yf,1,3,color=red)
  end
  dx=sz(1)/(clkin+1)
  for k=1:clkin
    scicos_lock_draw([orig(1)+k*dx,orig(2)+sz(2)],xf,yf,0,2,color=red)
  end
endfunction


