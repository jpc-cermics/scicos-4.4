function Export_()
  do_export(scs_m)
  Cmenu='Replot'
endfunction

function do_export(scs_m,fname) 
  driv='Pos';
  num=1
  wpar=scs_m.props.wpar
  winc=xget('window');
  if nargin==1 then
    num=x_choose(['Postscript file';'Graphics window'],'How do you want to export?');
    if num==0 then return;end
    if num<>2 then fname= xgetfile(save=%t);end
  end
  disablemenus()
  rep=%t;
  select num 
   case 1 then rep= execstr('do_export_ps(scs_m,fname);',errcatch=%t);
   case 2 then rep= execstr('do_export_gwin(scs_m);',errcatch=%t);
  end
  if rep == %f then 
    message(['error while exporting";lasterror()]);
  end
  enablemenus()
endfunction

function do_export_gwin(scs_m)
// export to a graphic window
  if ~exists('pixmap') then pixmap=%f;end;
  ids=winsid();
  if isempty(ids) then 
    I=1;
  else
    I= max(ids)+1;
  end
  xset('window',I);
  options=scs_m.props.options
  set_background()
  xset('wdim',600,400);
  rect=dig_bound(scs_m)
  wa=(rect(3)-rect(1))
  ha=(rect(4)-rect(2))
  aa=wa/ha
  rr=600/400
  if aa<rr then 
    wa2=wa*rr/aa;rect(1)=rect(1)-(wa2-wa)/2;rect(3)=rect(1)+wa2
  else
    ha2=ha*aa/rr;rect(2)=rect(2)-(ha2-ha)/2;rect(4)=rect(2)+ha2
  end
  dxx=(rect(3)-rect(1))/20;
  dyy=(rect(4)-rect(2))/20;
  rect(1)=rect(1)-dxx;rect(3)=rect(3)+dxx;
  rect(2)=rect(2)-dyy;rect(4)=rect(4)+dyy;
  xsetech(wrect=[-1,-1,8,8]/6,frect=rect,fixed=%t)
  pat=xget('pattern')
  xset('pattern',default_color(0));
  width=(rect(3)-rect(1))/3;
  height=(rect(4)-rect(2))/12;
  alu=xget('alufunction')
  xset('alufunction',3);
  xstringb(rect(1)+width,rect(4),scs_m.props.title(1),width,height,'fill')
  xset('pattern',pat);
  scs_m.props.title(1)='Scilab Graphics of '+scs_m.props.title(1)
  drawobjs(scs_m),
  if pixmap then xset('wshow'),end
  xset('alufunction',alu)
  if exists('winc') then xset('window',winc);end
endfunction

function do_export_ps(scs_m,fname) 
  if ~exists('pixmap') then pixmap=%f;end;
  wpar=scs_m.props.wpar
  driver('Pos')
  // using mode="k" (keep aspect)
  xinit(file=fname,dim=[600,400],mode="k");
  options=scs_m.props.options
  set_background()
  rect=dig_bound(scs_m)
  wa=(rect(3)-rect(1))
  ha=(rect(4)-rect(2))
  aa=wa/ha
  rr=600/400
  if aa<rr then 
    wa2=wa*rr/aa;rect(1)=rect(1)-(wa2-wa)/2;rect(3)=rect(1)+wa2
  else
    ha2=ha*aa/rr;rect(2)=rect(2)-(ha2-ha)/2;rect(4)=rect(2)+ha2
  end
  xsetech(wrect=[0 0 1 1],frect=rect,fixed=%t)
  if ~isempty(options('Background')) then 
    ll=6
    wp=rect(3)-rect(1);hp=rect(4)-rect(2);
    rr=[rect(1)-wp/ll;rect(4)+wp/ll;wp+2*wp/ll;hp+2*hp/ll];
    xrects(rr,options('Background')(1));
  end
  pat=xget('pattern')
  xset('pattern',default_color(0));
  width=(rect(3)-rect(1))/3;
  height=(rect(4)-rect(2))/12;
  xstringb(rect(1)+width,rect(4),scs_m.props.title(1),width,height,'fill')
  xset('pattern',pat)
  scs_m.props.title(1)='Scilab Graphics of '+scs_m.props.title(1)
  drawobjs(scs_m),
  if pixmap then xset('wshow'),end
  xend();
  driver('X11');
  if exists('winc') then xset('window',winc);end
endfunction

