function scicos_test_anim1(N=10,opengl=%f,poly_d=%t);
// a graphic demo 
// we draw a set of object and a compound containing 
// an other set of objects 
// then we interactively mode the compound 
  xinit(opengl=opengl,dim=[1000,1000]);
  xsetech(frect=[0,0,20,20]);
  F=get_current_figure()
  F.draw_latter[];
  for i=1:N,
    xrect(5+8*rand(1,1),5+8*rand(1,1),3,3,color=2,background=3*rand(1,1));
    xarc(5+8*rand(1,1),5+8*rand(1,1),3,3,0,360*64,color=3);
  end
  if poly_d then 
    for i=1:N
      tx = 8*rand(1,1);
      ty=8*rand(1,1);
      x=sin((1:10)*2*%pi/10);
      y=cos((1:10)*2*%pi/10);
      xfpoly(x+tx,y+ty,color=6,fill_color=32*rand(1,1));
    end
  end
  F.draw_now[];
  // collect a moving collection 
  F.start_compound[];
  F.draw_latter[];
  if poly_d then 
    for i=1:N,
      tx = 8*rand(1,1);
      ty=8*rand(1,1);
      x=sin((1:10)*2*%pi/10);
      y=cos((1:10)*2*%pi/10);
      xfpoly(x+tx,y+ty,color=6,fill_color=32*rand(1,1));
    end
  end
  for i=1:N,
    ptx=5+8*rand(1,1);
    pty=5+8*rand(1,1);
    xrect(ptx,pty,3,3,color=2,background=7*rand(1,1));
    xstringb(ptx,pty-3,'test',3,3,'fill');					
  end
  xstringb(5,2,'test',3,3,'fill');
  C=F.end_compound[];
  P=C.children(1);
  F.draw_now[];
  xinfo("click move, right click to stop");
  while %t then
    rep=xclick(clearq=%t,getrelease=%t);
    pto=[rep(2:3)];
    pt = pto;
    if rep(1) == 2 then break;end 
    rep(3)=-1
    while rep(3)==-1 ,  
      // move loop
      // get new position
      rep=xgetmouse(clearq=%f,getrelease=%t,cursor=%f);
      //printf("xgetmouse: [%f,%f,%f]\n",rep(1),rep(2),rep(3));
      pt = rep(1:2);
      tr= pt - pto;
      // redraw the non moving objects.
      // draw block shape
      F=get_current_figure()
      F.draw_latter[];
      C.translate[tr];
      F.draw_now[];
      pto=pt;
    end
  end 
  xdel();
endfunction

function scicos_test_anim3(opengl=%f)
// record each object then move them 
  [ok,scs_m]=do_load('NSP/toolboxes/scicos-4.4/demos/absvalue.cos');
  scs_m=scicos_diagram_show(scs_m)
  //realtimeinit(0.0001);
  F=get_current_figure();
  for k=1:100
    printf("k=%d\n",k);
    // realtime(k);
    for j=1:length(scs_m.objs);
      tr=(2*rand(1,2)-1);
      scs_m.objs(j).gr.translate[tr];
    end
    F.draw_now[]; // we want the graphic to be updated 
  end
endfunction 


 

