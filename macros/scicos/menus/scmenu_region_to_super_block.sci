function scmenu_region_to_super_block()
  Cmenu=''
  if isempty(Select) then
    if ~isequal(%win,curwin) then
      return
    end
    [%pt,scs_m,Select]=do_region2block(%pt,scs_m,SUPER_f)
  else
    if ~isequal(Select(1,2),curwin) then
      return
    end
    [%pt,scs_m]=do_select2block(%pt,scs_m,SUPER_f);
  end
  Cmenu='';%pt=[];
endfunction

function [%pt,scs_m,Select]=do_region2block(%pt,scs_m,fun)
  win=%win;
  xc=%pt(1);yc=%pt(2);
  %pt=[]
  scs_m_save=scs_m,nc_save=needcompile

  // delete_2 is called during this part

  [scs_mb,rect,prt,is_flip,Select]=get_region2(xc,yc,win,fun)

  if isempty(rect) then return,end
  if length(scs_mb.objs)==0 then return, end
  //superblock should not inherit the context nor the name
  scs_mb.props.context=' '
  if fun.get_fname[]=='SUPER_f' then 
    scs_mb.props.title(1)='Untitled'
  elseif fun.get_fname[]=='PAL_f' then
    scs_mb.props.title(1)='Palette'
    [scs_mb,edited] = do_rename(scs_mb,%t,%t)
  end
  ox=rect(1);oy=rect(2)+rect(4);w=rect(3),h=rect(4)

  n=0
  W=max(600,rect(3))
  H=max(400,rect(4))

  // do not keep the recorded graphics 
  // in the super  block.
  for k=1:length(scs_mb.objs) 
    scs_mb.objs(k).delete['gr'];
  end

  sup = fun('define')
  sup.graphics.orig   = [rect(1)+rect(3)/2-20,rect(2)+rect(4)/2-20]
  sup.graphics.sz     = [40 40]
  if isempty(is_flip) then
    sup.graphics.flip = %f
  else
    sup.graphics.flip = or(is_flip)
  end
  sup.model.rpar      = scs_mb
  sup.model.blocktype = 'h'
  sup.model.dep_ut    = [%f %f]


  if fun.get_fname[]=='SUPER_f' then 
    sup.model.in        = 1
    sup.model.out       = 1
    [ok,sup]=adjust_s_ports(sup)
  elseif fun.get_fname[]=='PAL_f' then
    sup.graphics.id     = scs_mb.props.title(1)
  end

  // detruire la region
  del=[]
  for k=1:length(scs_m.objs)
    o=scs_m.objs(k)
    if o.type =='Block'| o.type =='Text' then
      // check if block is outside rectangle
      orig=o.graphics.orig
      sz=o.graphics.sz
      x=[0 1 1 0]*sz(1)+orig(1)
      y=[0 0 1 1]*sz(2)+orig(2)
      ok=%f
      for kk=1:4
        data=[(ox-x(kk))'*(ox+w-x(kk)),(oy-h-y(kk))'*(oy-y(kk))];
        if data(1)<0&data(2)<0 then ok=%t;del=[del k];break;end
      end
    end
  end

  // scs_m now have some deleted blocks
  [scs_m,DEL]=do_delete2(scs_m,del,%t)

  // add super block
  F=get_current_figure();
  sup=drawobj(sup,F);
  scs_m.objs($+1)=sup

  // connect it
  if fun.get_fname[]=='SUPER_f' then 
    nn=length(scs_m.objs)
    nnk=nn
    for k=1:size(prt,1)
      k1=prt(k,6);tp1=prt(k,8);
      ksup=prt(k,1);tpsup=prt(k,3)
      typ=prt(k,5)
      o1=scs_m.objs(k1) // block origin of the link outside the superblock
      if typ>0 then //regular link
        if tp1==0 then  //link connected to an output port of o1
	  if typ==2 then //implicit regular link
            [x,y,vtyp]=getoutputports(o1)
	  else //explicit regular link
	    [x,y,vtyp]=getoutputs(o1)
	  end
          if ~isempty(x) & ~isempty(y) then
            xxx=rotate([x;y],...
                       o1.graphics.theta*%pi/180,...
                       [o1.graphics.orig(1)+o1.graphics.sz(1)/2;...
                        o1.graphics.orig(2)+o1.graphics.sz(2)/2]);
            x=xxx(1,:);
            y=xxx(2,:);
          end
	  if tpsup==1 then //link connected to an input port of the superblock 
	    if typ==2 then //implicit regular link
	      [xn,yn,vtypn]=getinputports(sup)
	    else	    //explicit regular link
	      [xn,yn,vtypn]=getinputs(sup),
	    end
	    Psup='pin'
	  else //link connected to an output port of the superblock 
	    if typ==2 then //implicit regular link
	      [xn,yn,vtypn]=getoutputports(sup)
	    else //explicit regular link
	      [xn,yn,vtypn]=getoutputs(sup)
	    end
	    Psup='pout'
	  end
	  p=prt(k,7)
	  pn=prt(k,2)
	  xl=[x(p);xn(pn)]
	  yl=[y(p);yn(pn)]
	  from=prt(k,6:8)
	  to=[nn,prt(k,2:3)]
	  o1.graphics.pout(prt(k,7))=nnk+1
	  scs_m.objs(nn).graphics(Psup)(prt(k,2))=nnk+1
        else //link connected to an input port of o1
	  if typ==2 then //implicit regular link
	    [x,y,vtyp]=getinputports(o1)
	  else
	    [x,y,vtyp]=getinputs(o1)
	  end
          if ~isempty(x) & ~isempty(y) then
            xxx=rotate([x;y],...
                       o1.graphics.theta*%pi/180,...
                       [o1.graphics.orig(1)+o1.graphics.sz(1)/2;...
                        o1.graphics.orig(2)+o1.graphics.sz(2)/2]);
            x=xxx(1,:);
            y=xxx(2,:);
          end
	  if tpsup==1 then //link connected to an input port of the superblock 
	    if typ==2 then //implicit regular link
	      [xn,yn,vtypn]=getinputports(sup)
	    else //explicit regular link
	      [xn,yn,vtypn]=getinputs(sup)
	    end
	    Psup='pin'
	  else  //link connected to an output port of the superblock 
	    if typ>1 then //implicit regular link
	      [xn,yn,vtypn]=getoutputports(sup)
	    else //explicit regular link
	      [xn,yn,vtypn]=getoutputs(sup),
	    end
	    Psup='pout'
	  end
	  p=prt(k,7)
	  pn=prt(k,2)
	  xl=[xn(pn);x(p)]
	  yl=[yn(pn);y(p)]
	  from=[nn,prt(k,2:3)]
	  to=prt(k,6:8)
	  o1.graphics.pin(prt(k,7))=nnk+1
	  scs_m.objs(nn).graphics(Psup)(prt(k,2))=nnk+1
        end
      else //event link
        if tpsup==1 then //link connected to an event input port of the superblock 
	  [x,y,vtyp]=getoutputs(o1)
          if ~isempty(x) & ~isempty(y) then
            xxx=rotate([x;y],...
                       o1.graphics.theta*%pi/180,...
                       [o1.graphics.orig(1)+o1.graphics.sz(1)/2;...
                        o1.graphics.orig(2)+o1.graphics.sz(2)/2]);
            x=xxx(1,:);
            y=xxx(2,:);
          end
	  [xn,yn,vtypn]=getinputs(sup),
	  p=prt(k,7)+size(find(vtyp==1),'*')+size(find(vtyp==2),'*')
	  pn=prt(k,2)+size(find(vtypn==1),'*')+size(find(vtypn==2),'*')
	  xl=[x(p);xn(pn)]
	  yl=[y(p);yn(pn)]
	  from=prt(k,6:8)
	  to=[nn,prt(k,2:3)]
	  o1.graphics.peout(prt(k,7))=nnk+1
	  scs_m.objs(nn).graphics.pein(prt(k,2))=nnk+1
        else //link connected to an event output port of the superblock 
	  [x,y,vtyp]=getinputs(o1)
          if ~isempty(x) & ~isempty(y) then
            xxx=rotate([x;y],...
                       o1.graphics.theta*%pi/180,...
                       [o1.graphics.orig(1)+o1.graphics.sz(1)/2;...
                        o1.graphics.orig(2)+o1.graphics.sz(2)/2]);
            x=xxx(1,:);
            y=xxx(2,:);
          end
	  [xn,yn,vtypn]=getoutputs(sup),
	  p=prt(k,7)+size(find(vtyp==1),'*')+size(find(vtyp==2),'*')
	  pn=prt(k,2)+size(find(vtypn==1),'*')+size(find(vtypn==2),'*')
	  xl=[xn(pn);x(p)]
	  yl=[yn(pn);y(p)]
	  from=[nn,prt(k,2:3)]
	  to=prt(k,6:8)
	  o1.graphics.pein(prt(k,7))=nnk+1
	  scs_m.objs(nn).graphics.peout(prt(k,2))=nnk+1
        end
      end
      if xl(1)<>xl(2)&yl(1)<>yl(2) then //oblique link
        if prt(k,4)>0 then //regular port
	  xl=[xl(1);xl(1)+(xl(2)-xl(1))/2;xl(1)+(xl(2)-xl(1))/2;xl(2)]
	  yl=[yl(1);yl(1);yl(2);yl(2)]
        else
	  xl=[xl(1);xl(1);xl(2);xl(2)]
	  yl=[yl(1);yl(1)+(yl(2)-yl(1))/2;yl(1)+(yl(2)-yl(1))/2;yl(2)]
        end
      end
      lk=scicos_link(xx=xl,yy=yl,ct=prt(k,4:5),from=from,to=to)
      if lk.ct(2)==3 then lk.thick=[2 2];end
      lk=drawobj(lk,F);
      scs_m.objs($+1)=lk
      scs_m.objs(k1)=o1
      nnk=nnk+1
    end
  end

  // redraw
  F.draw_now[];
  resume(scs_m_save,nc_save,needreplay,enable_undo=%t,edited=%t,needcompile=4);
endfunction


function [reg,rect,prt,is_flip,Select]=get_region2(xc,yc,win,fun)
// Copyright INRIA
  ok=%t
  wins=curwin
  xset('window',win)
  is_flip=[]
  reg=list();rect=[]
  Select=[]
  kc=find(win==windows(:,2))
  if isempty(kc) then
    message('This window is not an active palette')
    return
  elseif windows(kc,1)<0 then //click dans une palette
    kpal=-windows(kc,1)
    scs_m=palettes(kpal)
  elseif win==curwin then //click dans la fenetre courante
    scs_m=scs_m
  elseif pal_mode&win==lastwin then 
    scs_m=scs_m_s
  elseif slevel>1 then
    execstr('scs_m=scs_m_'+string(windows(kc,1)))
  else
    message('This window is not an active palette')
    return
  end
  [rect,button] = rubberbox([xc; yc; 0; 0],%t);
  if or(button == [2 5 -100]) then
    prt=[]
    rect=[]
    return
  end
  ox=rect(1),oy=rect(2),w=rect(3),h=rect(4);
  [in,out]=getobjs_in_rect(scs_m,ox,oy,w,h)
  if ~isempty(in) then
    Select=[in',win*ones(size(in,2),1)]
  end
  [keep,del]=get_blocks_in_rect(scs_m,ox,oy,w,h);
  if fun.get_fname[]=='SUPER_f' then
    for bkeep=keep
      if scs_m.objs(bkeep).type =='Block' then
        if or(scs_m.objs(bkeep).gui==['IN_f' 
                                      'OUT_f'
                                      'CLKINV_f'
                                      'CLKIN_f'
                                      'CLKOUTV_f'
                                      'CLKOUT_f'
                                      'INIMPL_f'
                                      'OUTIMPL_f']) then
          message('Input/Output ports are not allowed in the region.')
          prt=[];rect=[];return
        end
      end
    end
  end

  //preserve information on splitted links
  prt=splitted_links(scs_m,keep,del)

  [reg,DEL]=do_delete2(scs_m,del,%f)

  rect=[ox,oy-h,w,h]

  xset('window',wins)

  nin=0
  nout=0
  ncin=0
  ncout=0

  if fun.get_fname[]=='SUPER_f' then
    //add input and output ports
    for k=1:size(prt,1)
      nreg=length(reg.objs)
      k1=prt(k,1);typ=prt(k,5);tp=prt(k,3)
      o1=reg.objs(k1)
      orient=o1.graphics.flip
      is_flip=[is_flip,orient]

      if tp==1 then //input port
        // build the link between block and port
        if typ>1 then //implicit regular link
	  [x,y,vtyp]=getinputports(o1)
	  from=[nreg+1,1,0] //added port
	  to=prt(k,1:3)
        else //explicit regular link
	  [x,y,vtyp]=getinputs(o1),
	  from=[nreg+1,1,0] //added port
	  to=prt(k,1:3)
        end
        if ~isempty(x) & ~isempty(y) then
          xxx=rotate([x;y],...
                     o1.graphics.theta*%pi/180,...
                     [o1.graphics.orig(1)+o1.graphics.sz(1)/2;...
                      o1.graphics.orig(2)+o1.graphics.sz(2)/2]);
          x=xxx(1,:);
          y=xxx(2,:);
        end
        if typ>0 then //input regular port
	  x=x(prt(k,2))
	  y=y(prt(k,2))
	  nin=nin+1
	  if typ==1 then sp=IN_f('define'),else sp=INIMPL_f('define'),end
	  sz=20*sp.graphics.sz
	  sp.graphics.sz=sz; //sz
	  sp.graphics.flip=orient; //flip
	  sp.graphics.exprs=string(nin); //expr
	  sp.graphics.pout=nreg+2;//pout
	  sp.model.ipar=nin; //port number
	  o1.graphics.pin(prt(k,2))=nreg+2
	  if orient then  //not flipped
	    sp.graphics.orig=[x-2*sz(1),y-sz(2)/2]; //orig
	    xl=[x-sz(1);x]
	    yl=[y;y]
	  else // flipped
	    sp.graphics.orig=[x+sz(1),y-sz(2)/2]; //orig
	    xl=[x+sz(1);x]
	    yl=[y;y]
	  end
	  prt(k,2)=nin
        else //input event port
	  p=prt(k,2)+size(find(vtyp==1),'*')
	  x=x(p)
	  y=y(p)
	  ncin=ncin+1
	  sp=CLKINV_f('define')
	  sz=20*sp.graphics.sz
	  sp.graphics.orig=[x-sz(1)/2,y+sz(2)]; //orig
	  sp.graphics.sz=sz; //sz
	  sp.graphics.exprs=string(ncin); //expr
	  sp.graphics.peout=nreg+2;//peout
	  sp.model.ipar=ncin; //port number
	  o1.graphics.pein(prt(k,2))=nreg+2
	  xl=[x;x]
	  yl=[y+sz(2);y]
	  prt(k,2)=ncin
        end
      else //output port
        if typ>1 then //implicit regular link
	  [x,y,vtyp]=getoutputports(o1)
	  to=[nreg+1,1,1]
	  from=prt(k,1:3)
        else //explicit regular link
	  [x,y,vtyp]=getoutputs(o1)
	  to=[nreg+1,1,1]
	  from=prt(k,1:3)
        end
        if ~isempty(x) & ~isempty(y) then
          xxx=rotate([x;y],...
                     o1.graphics.theta*%pi/180,...
                     [o1.graphics.orig(1)+o1.graphics.sz(1)/2;...
                      o1.graphics.orig(2)+o1.graphics.sz(2)/2]);
          x=xxx(1,:);
          y=xxx(2,:);
        end
        if typ>0 then //output regular port
	  x=x(prt(k,2))
	  y=y(prt(k,2))
	  nout=nout+1
	  if typ==1 then sp=OUT_f('define'),else sp=OUTIMPL_f('define'),end
	  sz=20*sp.graphics.sz
	  sp.graphics.sz=sz; //sz
	  sp.graphics.flip=orient; //flip
	  sp.graphics.exprs=string(nout); //expr
	  sp.graphics.pin=nreg+2;//pin
	  sp.model.ipar=nout; //port number
	  o1.graphics.pout(prt(k,2))=nreg+2
	  sz=sp.graphics.sz
	  if orient then  //not flipped 
	    sp.graphics.orig=[x+sz(1),y-sz(2)/2]; //orig
	    xl=[x;x+sz(1)]
	    yl=[y;y]
	  else //flipped
	    sp.graphics.orig=[x-2*sz(1),y-sz(2)/2]; //orig
	    xl=[x;x-sz(1)]
	    yl=[y;y]
	  end
	  prt(k,2)=nout
        else //output event port
	  p=prt(k,2)+size(find(vtyp==1),'*')
	  x=x(p)
	  y=y(p)
	  ncout=ncout+1
	  sp=CLKOUTV_f('define')
	  sz=20*sp.graphics.sz
	  sp.graphics.orig=[x-sz(1)/2,y-2*sz(2)]; //orig
	  sp.graphics.sz=sz; //sz
	  sp.graphics.exprs=string(ncout); //expr
	  sp.graphics.pein=nreg+2;//pein
	  sp.model.ipar=ncout; //port number
	  o1.graphics.peout(prt(k,2))=nreg+2
	  xl=[x;x]
	  yl=[y;y-sz(2)]
	  prt(k,2)=ncout
        end
      end
      lk=scicos_link(xx=xl,yy=yl,ct=[prt(k,4),typ],from=from,to=to)
      reg.objs(nreg+1)=sp
      reg.objs(nreg+2)=lk
      reg.objs(k1)=o1
    end
  end
  reg=do_purge(reg)
endfunction

function [%pt,scs_m]=do_select2block(%pt,scs_m,fun)
// fun gives the type of superblock to create 
// it can be SUPER_f or PAL_f

  scs_m_save=scs_m
  nc_save=needcompile
  keep=[];del=[];
  sel=Select(:,1)'
  ng=new_graphics();
  nsel=setdiff(1:size(scs_m.objs),sel)

  // all selected objects in keep
  for bl=sel
    if scs_m.objs(bl).type=='Block' | scs_m.objs(bl).type=='Text' then
      if fun.get_fname[]=='SUPER_f' then 
        if or(scs_m.objs(bl).gui==['IN_f' 
                                   'OUT_f'
                                   'CLKINV_f'
                                   'CLKIN_f'
                                   'CLKOUTV_f'
                                   'CLKOUT_f'
                                   'INIMPL_f'
                                   'OUTIMPL_f'
                                   'BUSIN_f'
                                   'BUSOUT_f']) then
          message('Input/Output ports are not allowed in the region.')
          return
        end
      end
      keep=[keep,bl]
    end
  end

  // all the object NOT selected in del
  for bl=nsel
    if scs_m.objs(bl).type=='Block' | scs_m.objs(bl).type=='Text' then
      del=[del bl]
    end
  end
  prt=splitted_links(scs_m,keep,del)

  [reg,DEL]=do_delete2(scs_m,del,%f)

  rect=dig_bound(reg)
  nin=0
  nout=0
  ncin=0
  ncout=0
  is_flip=[]

  if fun.get_fname[]=='SUPER_f' then 
    //add input and output ports
    for k=1:size(prt,1)
      nreg=size(reg.objs)
      k1=prt(k,1); typ=prt(k,5);tp=prt(k,3)
      o1=reg.objs(k1) //block inside the region
      orient=o1.graphics.flip
      is_flip=[is_flip,orient]

      if tp==1 then //input port
	// build the link between block and port
	if typ==2 then //implicit regular link
	  [x,y,vtyp]=getinputports(o1)
	  from=[nreg+1,1,0] //added port
	  to=prt(k,1:3)
	else	    //explicit regular link
	  [x,y,vtyp]=getinputs(o1),
	  from=[nreg+1,1,0] //added port
	  to=prt(k,1:3)
	end
	if ~isempty(x) & ~isempty(y) then
	  xxx=rotate([x;y],...
		     o1.graphics.theta*%pi/180,...
		     [o1.graphics.orig(1)+o1.graphics.sz(1)/2;...
		      o1.graphics.orig(2)+o1.graphics.sz(2)/2]);
	  x=xxx(1,:);
	  y=xxx(2,:);
	end
	if typ>0 then //input regular port
	  x=x(prt(k,2))
	  y=y(prt(k,2))
	  nin=nin+1
	  if typ==1 then sp=IN_f('define')
	  elseif typ==3 then sp=BUSIN_f('define')
	  else sp=INIMPL_f('define')
	  end
	  sz=20*sp.graphics.sz
	  sp.graphics.sz=sz; //sz
	  sp.graphics.flip=orient; //flip
	  sp.graphics.exprs=string(nin); //expr
	  sp.graphics.pout=nreg+2;//pout
	  sp.model.ipar=nin; //port number
	  o1.graphics.pin(prt(k,2))=nreg+2
	  if orient then  //not flipped
	    sp.graphics.orig=[x-2*sz(1),y-sz(2)/2]; //orig
	    xl=[x-sz(1);x]
	    yl=[y;y]
	  else // flipped
	    sp.graphics.orig=[x+sz(1),y-sz(2)/2]; //orig
	    xl=[x+sz(1);x]
	    yl=[y;y]
	  end
	  prt(k,2)=nin
	else //input event port
	  p=prt(k,2)+size(find(vtyp==1),'*')
	  x=x(p)
	  y=y(p)
	  ncin=ncin+1
	  sp=CLKINV_f('define')
	  sz=20*sp.graphics.sz
	  sp.graphics.orig=[x-sz(1)/2,y+sz(2)]; //orig
	  sp.graphics.sz=sz; //sz
	  sp.graphics.exprs=string(ncin); //expr
	  sp.graphics.peout=nreg+2;//peout
	  sp.model.ipar=ncin; //port number
	  
	  o1.graphics.pein(prt(k,2))=nreg+2
	  xl=[x;x]
	  yl=[y+sz(2);y]
	  prt(k,2)=ncin
	end
      else //  output port
	if typ==2 then //implicit regular link
	  [x,y,vtyp]=getoutputports(o1)
	  to=[nreg+1,1,1]
	  from=prt(k,1:3)
	else //explicit regular link
	  [x,y,vtyp]=getoutputs(o1)
	  to=[nreg+1,1,1]
	  from=prt(k,1:3)
	end
	if ~isempty(x) & ~isempty(y) then
	  xxx=rotate([x;y],...
		     o1.graphics.theta*%pi/180,...
		     [o1.graphics.orig(1)+o1.graphics.sz(1)/2;...
		      o1.graphics.orig(2)+o1.graphics.sz(2)/2]);
	  x=xxx(1,:);
	  y=xxx(2,:);
	end
	if typ>0 then //output regular port
	  x=x(prt(k,2))
	  y=y(prt(k,2))
	  nout=nout+1
	  if typ==1 then sp=OUT_f('define')
	  elseif typ==3 then sp=BUSOUT_f('define')
	  else sp=OUTIMPL_f('define')
	  end
	  sz=20*sp.graphics.sz
	  sp.graphics.sz=sz; //sz
	  sp.graphics.flip=orient; //flip
	  sp.graphics.exprs=string(nout); //expr
	  sp.graphics.pin=nreg+2;//pin
	  sp.model.ipar=nout; //port number
	  o1.graphics.pout(prt(k,2))=nreg+2
	  sz=sp.graphics.sz
	  if orient then  //not flipped 
	    sp.graphics.orig=[x+sz(1),y-sz(2)/2]; //orig
	    xl=[x;x+sz(1)]
	    yl=[y;y]
	  else //flipped
	    sp.graphics.orig=[x-2*sz(1),y-sz(2)/2]; //orig
	    xl=[x;x-sz(1)]
	    yl=[y;y]
	  end
	  prt(k,2)=nout
	else //output event port
	  p=prt(k,2)+size(find(vtyp==1),'*')
	  x=x(p)
	  y=y(p)
	  ncout=ncout+1
	  sp=CLKOUTV_f('define')
	  sz=20*sp.graphics.sz
	  sp.graphics.orig=[x-sz(1)/2,y-2*sz(2)]; //orig
	  sp.graphics.sz=sz; //sz
	  sp.graphics.exprs=string(ncout); //expr
	  sp.graphics.pein=nreg+2;//pein
	  sp.model.ipar=ncout; //port number
	  o1.graphics.peout(prt(k,2))=nreg+2
	  xl=[x;x]
	  yl=[y;y-sz(2)]
	  prt(k,2)=ncout
	end
      end
      lk=scicos_link(xx=xl,yy=yl,ct=[prt(k,4),typ],from=from,to=to)
      if lk.ct(2)==3 then lk.thick=[2 2];end
      reg.objs(nreg+1)=sp
      reg.objs(nreg+2)=lk
      reg.objs(k1)=o1
    end
  end
  reg=do_purge(reg)
  
  if length(reg.objs)==0 then return, end

  //superblock should not inherit the context nor the name
  reg.props.context=' ' 
  if fun.get_fname[]=='SUPER_f' then 
    reg.props.title(1)='SuperBlock'
  elseif fun.get_fname[]=='PAL_f' then
    reg.props.title(1)='Palette'
    [reg,edited] = do_rename(reg,%t,%t)
  end

  sup = fun('define')
  sup.graphics.orig   = [(rect(1)+rect(3))/2-20,(rect(2)+rect(4))/2-20]
  sup.graphics.sz     = [40 40]
  if isempty(is_flip) then
    sup.graphics.flip   = %f
  else
    sup.graphics.flip   = or(is_flip)
  end
  
  sup.model.rpar      = reg
  sup.model.blocktype = 'h'
  sup.model.dep_ut    = [%f %f]

  if fun.get_fname[]=='SUPER_f' then 
    sup.model.in        = 1
    sup.model.out       = 1
    [ok,sup] = adjust_s_ports(sup)
  elseif fun.get_fname[]=='PAL_f' then
    sup.graphics.id     = reg.props.title(1)
  end

  // scs_m now have some deleted blocks
  [scs_m,DEL]=do_delete2(scs_m,keep,%t)

  // add super block
  F=get_current_figure();
  sup=drawobj(sup,F);
  scs_m.objs($+1)=sup

  // connect the super block 
  if fun.get_fname[]=='SUPER_f' then 
    nn=length(scs_m.objs)  //superblock number
    nnk=nn
    for k=1:size(prt,1)
      k1=prt(k,6);tp1=prt(k,8);
      ksup=prt(k,1);tpsup=prt(k,3)
      typ=prt(k,5)
      o1=scs_m.objs(k1) // block origin of the link outside the superblock
      
      if typ>0 then //regular link
	if tp1==0 then  //link connected to an output port of o1
	  if typ>1 then //implicit regular link
	    [x,y,vtyp]=getoutputports(o1)
	  else //explicit regular link
	    [x,y,vtyp]=getoutputs(o1)
	  end
	  if ~isempty(x) & ~isempty(y) then
	    xxx=rotate([x;y],...
		       o1.graphics.theta*%pi/180,...
		       [o1.graphics.orig(1)+o1.graphics.sz(1)/2;...
			o1.graphics.orig(2)+o1.graphics.sz(2)/2]);
	    x=xxx(1,:);
	    y=xxx(2,:);
	  end
	  if tpsup==1 then //link connected to an input port of the superblock 
	    if typ==2 then //implicit regular link
	      [xn,yn,vtypn]=getinputports(sup)
	    else	    //explicit regular link
	      [xn,yn,vtypn]=getinputs(sup),
	    end
	    Psup='pin'
	  else //link connected to an output port of the superblock 
	    if typ==2 then //implicit regular link
	      [xn,yn,vtypn]=getoutputports(sup)
	    else //explicit regular link
	      [xn,yn,vtypn]=getoutputs(sup),
	    end
	    Psup='pout'
	  end
	  p=prt(k,7)
	  pn=prt(k,2)
	  xl=[x(p);xn(pn)]
	  yl=[y(p);yn(pn)]
	  
	  from=prt(k,6:8)
	  to=[nn,prt(k,2:3)]
	  o1.graphics.pout(prt(k,7))=nnk+1
	  scs_m.objs(nn).graphics(Psup)(prt(k,2))=nnk+1
	else //link connected to an input port of o1
	  if typ==2 then //implicit regular link
	    [x,y,vtyp]=getinputports(o1)
	  else
	    [x,y,vtyp]=getinputs(o1)
	  end
	  if ~isempty(x) & ~isempty(y) then
	    xxx=rotate([x;y],...
		       o1.graphics.theta*%pi/180,...
		       [o1.graphics.orig(1)+o1.graphics.sz(1)/2;...
			o1.graphics.orig(2)+o1.graphics.sz(2)/2]);
	    x=xxx(1,:);
	    y=xxx(2,:);
	  end
	  if tpsup==1 then //link connected to an input port of the superblock 
	    if typ==2 then //implicit regular link
	      [xn,yn,vtypn]=getinputports(sup)
	    else //explicit regular link
	      [xn,yn,vtypn]=getinputs(sup)
	    end
	    Psup='pin'
	  else  //link connected to an output port of the superblock 
	    if typ==2 then //implicit regular link
	      [xn,yn,vtypn]=getoutputports(sup)
	    else //explicit regular link
	      [xn,yn,vtypn]=getoutputs(sup)
	    end
	    Psup='pout'
	  end
	  p=prt(k,7)
	  pn=prt(k,2)
	  
	  xl=[xn(pn);x(p)]
	  yl=[yn(pn);y(p)]
	  from=[nn,prt(k,2:3)]
	  to=prt(k,6:8)
	  o1.graphics.pin(prt(k,7))=nnk+1
	  scs_m.objs(nn).graphics(Psup)(prt(k,2))=nnk+1
	end
      else //event link
	if tpsup==1 then //link connected to an event input port of the superblock 
	  [x,y,vtyp]=getoutputs(o1)
	  if ~isempty(x) & ~isempty(y) then
	    xxx=rotate([x;y],...
		       o1.graphics.theta*%pi/180,...
		       [o1.graphics.orig(1)+o1.graphics.sz(1)/2;...
			o1.graphics.orig(2)+o1.graphics.sz(2)/2]);
	    x=xxx(1,:);
	    y=xxx(2,:);
	  end
	  [xn,yn,vtypn]=getinputs(sup),
	  p=prt(k,7)+size(find(vtyp==1),'*')+size(find(vtyp==2),'*')
	  pn=prt(k,2)+size(find(vtypn==1),'*')+size(find(vtypn==2),'*')
	  xl=[x(p);xn(pn)]
	  yl=[y(p);yn(pn)]
	  from=prt(k,6:8)
	  to=[nn,prt(k,2:3)]
	  o1.graphics.peout(prt(k,7))=nnk+1
	  scs_m.objs(nn).graphics.pein(prt(k,2))=nnk+1
	else //link connected to an event output port of the superblock 
	  [x,y,vtyp]=getinputs(o1)
	  if ~isempty(x) & ~isempty(y) then
	    xxx=rotate([x;y],...
		       o1.graphics.theta*%pi/180,...
		       [o1.graphics.orig(1)+o1.graphics.sz(1)/2;...
			o1.graphics.orig(2)+o1.graphics.sz(2)/2]);
	    x=xxx(1,:);
	    y=xxx(2,:);
	  end

	  [xn,yn,vtypn]=getoutputs(sup),
	  p=prt(k,7)+size(find(vtyp==1),'*')+size(find(vtyp==2),'*')
	  pn=prt(k,2)+size(find(vtypn==1),'*')+size(find(vtypn==2),'*')
	  xl=[xn(pn);x(p)]
	  yl=[yn(pn);y(p)]
	  from=[nn,prt(k,2:3)]
	  to=prt(k,6:8)
	  o1.graphics.pein(prt(k,7))=nnk+1
	  scs_m.objs(nn).graphics.peout(prt(k,2))=nnk+1
	end
      end
      
      
      if xl(1)<>xl(2)&yl(1)<>yl(2) then //oblique link
	if prt(k,4)>0 then //regular port
	  xl=[xl(1);xl(1)+(xl(2)-xl(1))/2;xl(1)+(xl(2)-xl(1))/2;xl(2)]
	  yl=[yl(1);yl(1);yl(2);yl(2)]
	else
	  xl=[xl(1);xl(1);xl(2);xl(2)]
	  yl=[yl(1);yl(1)+(yl(2)-yl(1))/2;yl(1)+(yl(2)-yl(1))/2;yl(2)]
	end
      end

      lk=scicos_link(xx=xl,yy=yl,ct=prt(k,4:5),from=from,to=to)
      if lk.ct(2)==3 then lk.thick=[2 2];end
      lk=drawobj(lk,F);
      scs_m.objs($+1)=lk
      scs_m.objs(k1)=o1
      nnk=nnk+1
    end
  end
  // redraw
  F.draw_now[];
  resume(scs_m_save,nc_save,needreplay,enable_undo=%t,edited=%t,needcompile=4);
endfunction
