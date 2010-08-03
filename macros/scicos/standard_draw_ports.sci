function standard_draw_ports(o)
  
  nin=size(o.model.in,1);
  nout=size(o.model.out,1);
  inporttype=o.graphics.in_implicit
  outporttype=o.graphics.out_implicit
  clkin=size(o.model.evtin,1);
  clkout=size(o.model.evtout,1);

  [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
  xset('pattern',default_color(0));
  //draw input/output ports
  //------------------------
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
  outtype= ones_new(1,nout);
  outtype(outporttype.equal['I'])=5;
  for k=1:nout
    scicos_lock_draw([xpos_out,orig(2)+sz(2)-dy*k],xf,yf,select_face_out,outtype(k));
  end
  dy=sz(2)/(nin+1)
  outtype= zeros_new(1,nin);
  outtype(inporttype.equal['I'])=4;
  for k=1:nin
    scicos_lock_draw([xpos_in,orig(2)+sz(2)-dy*k],xf,yf,select_face_in,outtype(k));
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
