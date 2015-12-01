
function scicos_test_anim1(N=100,opengl=%f,poly_d=%t);
  xinit(opengl=opengl);
  xclear();
  xsetech(frect=[0,0,10,10]);
  //  xset('wresize',0);
  //  xset('wdim',1000,1000)
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


function scicos_test_anim2(N=100,opengl=%f,poly_d=%t);
  // load('NSP/macros/scicos_no_xor/scicos_test_anim.cos');
  xclear();
  xinit(opengl=opengl);
  //xsetech(frect=[0,0,1000,1000]);
  xset('wresize',0);
  xset('wdim',1000,1000)
  others=1:length(scs_m.objs);
  options=scs_m.props.options

  // this will create a figure 
  window_set_size()
  F=get_current_figure();
  F.draw_latter[];
  Co=list();
  for i=1:length(scs_m.objs);
    F.start_compound[];
    drawobj(scs_m.objs(i),F)
    C=F.end_compound[];
    Co(i)=C;
    C.show=%t
  end
  Ob = Co(1);
  Ob.show=%t;
  F.draw_now[];
  while %t then
    rep=xclick(clearq=%t,getrelease=%t);
    pto=[rep(2:3)];
    pt = pto;
    //printf("rep = %d\n",rep(3));
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
      F.draw_latter[];
      Ob.translate[tr];
      F.draw_now[];
      pto=pt;
    end
  end 
endfunction

function scicos_test_draw1(opengl=%f)
  load('NSP/macros/scicos_no_xor/scicos_test_anim.cos');
  others=1:length(scs_m.objs);
  xinit(opengl=opengl)
  //xselect();
  set_background()
  // this will create a figure 
  window_set_size();
  F=get_current_figure();
  F.draw_latter[];
  drawobjs(scs_m,F),
  F.draw_now[]; 
endfunction 

function fps=scicos_test_anim3(runtime,opengl=%f)
// record each object then move them 
  load('NSP/macros/scicos_no_xor/scicos_test_anim.cos');
  others=1:length(scs_m.objs);
  options=scs_m.props.options
  xinit(opengl=opengl)
  //xselect();
  set_background()
  // this will create a figure 
  window_set_size()
  F=get_current_figure();
  F.draw_latter[];
  Co=list();
  for i=1:length(scs_m.objs);
    F.start_compound[];
    drawobj(scs_m.objs(i),F)
    C=F.end_compound[];
    Co(i)=C;
  end
  F.draw_now[]; 
  xpause(0,%t);
  tic();
  T=0;
  i=1;
  while %t
    F.draw_latter[];
    for j=1:length(scs_m.objs);
      t=2*modulo(i,2)-1;
      Co(j).translate[10*[t,t]];
    end
    F.draw_now[];
    xpause(0,%t);
    xinfo(sprintf("iterations %d",i));
    T.add[toc()];tic();
    if T > runtime then break;end
    i=i+1;
  end
  fps =i;
endfunction 


 

