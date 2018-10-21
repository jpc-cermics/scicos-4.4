function standard_draw_ports(o, coselica=%f)
  // function used to draw ports
  // lock_types SL_IN=0  ,SL_OUT=1 ,SL_EVIN=2,SL_EVOUT=3 , SL_SQP=4, SL_SQM=5

  function [in_colors,out_colors]=scicos_port_colors(inporttype,outporttype)
    // see default_color = {-1: event link, 1 || 2 regular links, 3 bus }
    // select the color of ports depending on Regular or Bus ports 
    in_colors=ones(1,nin);
    if ~isempty(inporttype) then  out_colors( inporttype == 'B')=default_color(3);end 
    out_colors=ones(1,nout); // black is the default color. It should be a default_color
    if ~isempty(outporttype) then  in_colors( outporttype == 'B')=default_color(3);end 
    // select the color of ports 
  endfunction

  function [in_colors,out_colors]=scicos_coselica_port_colors(inporttype,outporttype)
    // see default_color = {-1: event link, 1 || 2 regular links, 3 bus }
    // select the color of ports depending on Regular or Bus ports 
    in_colors=default_color(3)*ones(1,nin); // black is the default color. It should be a default_color
    if ~isempty(inporttype) then in_colors( inporttype == 'E')=1;end
    // select the color of ports 
    out_colors=default_color(3)*ones(1,nout);
    if ~isempty(outporttype) then  out_colors( outporttype == 'E')=1;end
  endfunction
  
  function [in_shapes, out_shapes]=scicos_port_shapes(nin, nout, inporttype,outporttype)
    in_shapes= 0*ones(1,nin);
    if ~isempty(inporttype) then  in_shapes( inporttype == 'I')=5;end
    out_shapes= ones(1,nout);
    if ~isempty(outporttype) then  out_shapes( outporttype == 'I')=4;end
  endfunction
  
  function [in_shapes, out_shapes]=scicos_coselica_port_shapes(nin, nout, inporttype,outporttype)
    in_shapes= 0*ones(1,nin);
    if ~isempty(inporttype) then  in_shapes( inporttype == 'I')=2;end
    out_shapes= ones(1,nout);
    if ~isempty(outporttype) then  out_shapes( outporttype == 'I')=3;end
  endfunction
  
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
  if coselica then
    // select the shape to use rectangle or triangle.
    [in_shapes, out_shapes]=scicos_coselica_port_shapes(nin, nout, inporttype,outporttype);
    // select the color of ports 
    [in_colors,out_colors]=scicos_coselica_port_colors(inporttype,outporttype);
  else
    // select the shape to use rectangle or triangle.
    [in_shapes, out_shapes]=scicos_port_shapes(nin, nout, inporttype,outporttype);
    // select the color of ports 
    [in_colors,out_colors]=scicos_port_colors(inporttype,outporttype);
  end
  for k=1:nout
    scicos_lock_draw([xpos_out,orig(2)+sz(2)-dy*k],xf,yf,select_face_out,out_shapes(k),
		     color=out_colors(k));
  end
  dy=sz(2)/(nin+1)
  for k=1:nin
    scicos_lock_draw([xpos_in,orig(2)+sz(2)-dy*k],xf,yf,select_face_in,in_shapes(k),
		     color=in_colors(k));
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

function standard_coselica_draw_ports(o)
  standard_draw_ports(o, coselica=%t);
endfunction
