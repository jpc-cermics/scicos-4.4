function [Tree,windows]=do_navigator(scs_m,windows)
//build the tree representation
  y0=0;x0=0;
  path=[];larg=0;
  [xx,yy,lp]=build_scs_tree(scs_m,'super',larg);
  if (isempty(xx) | isempty(yy)) then
    Tree=[]
    windows=[]
    return
  end
  // open tree window
  kw=find(windows(:,1)==100000)
  if isempty(kw) then
    windows=[windows;[100000,get_new_window(windows)]]
    kw=size(windows,1)
  end
  xset('window',windows(kw,2))
  xclear();//xbasc();
  xset('default');xselect();
  n_node=size(lp)
  mnx=min(xx)-0.1;mxx=max(xx)+0.1
  if n_node<=20 then
    dx=(mxx-mnx)
    mnx=mnx-dx/5
    x0=[mnx,mnx+dx/5]

  else
    dx=(mxx-mnx)
    mnx=mnx-dx/2
    x0=[mnx,mnx+dx/4,mnx+dx/2]
  end
  bnds=[mnx,min(yy)-0.2, mxx,max(yy)+0.2];
  xsetech([-1/6, -1/6, 8/6, 8/6],bnds)

  // draw tree
  xsegs(xx,yy,style=1)
  xx=[xx(1,1);xx(2,:)'];
  yy=[yy(1,1);yy(2,:)'];
  plot2d(xx,yy,style=-9,strf='000')
  xtitle('Navigator window')


  for k=1:size(xx,1)
    xstring(xx(k),yy(k),string(k))
  end

  r=xstringl(x0(1),y0,'X');h=r(4);
  y0=bnds(4)-h;
  kx=1
  xrect(x0(kx),bnds(4),x0(kx+1)-x0(kx),bnds(4)-bnds(2))
  xclip([x0(kx),bnds(4),x0(kx+1)-x0(kx),bnds(4)-bnds(2)])
  for k=1:size(xx,1)
    if k==1 then path=[]; else path=lp(k-1);end
    Path=list();
    for pk=path
      Path=list_concat(Path,'objs',pk,'model','rpar');
    end
    Path=list_concat(Path,'props','title',1);

    xstring(x0(kx),y0,string(k)+': '+scs_m(Path))
    y0=y0-h;
    if k==20 then 
      y0=bnds(4)-h;
      kx=kx+1
      xclip()
      xrect(x0(kx),bnds(4),x0(kx+1)-x0(kx),bnds(4)-bnds(2))
      xclip([x0(kx),bnds(4),x0(kx+1)-x0(kx),bnds(4)-bnds(2)])
    end
  end
  xclip()
  //build data structure
  Tree=tlist(['scs_tree','x','y','paths','orig'],xx,yy,lp,super_path)
  xset('window',curwin)
endfunction

function [xx,yy,lp,larg]=build_scs_tree(scs_m,flag,larg)
// [lhs,rhs]=argn(0) 
  if nargin <2 then  flag='super' end;
  xx=[];yy=[];
  lp=list()
  n=length(scs_m.objs)
  blks=[]
  if flag=='super' then
    for k=1:n
      if scs_m.objs(k).type =='Block' then 
	if scs_m.objs(k).model.sim(1)=='super' then blks=[blks,k],end
      end
    end
  else
    for k=1:n
      if scs_m.objs(k).type =='Block' then blks=[blks,k],end
    end
  end
  //
  nl=size(blks,2)
  xlk=x0
  for k=blks
    path=[path k];
    xx=[xx,[x0;xlk]];yy=[yy,[y0;y0-1]]
    larg=max(xlk,larg)
    lp($+1)=path
    if scs_m.objs(k).model.sim(1)=='super' then
      y0s=y0;x0s=x0;x0=xlk;y0=y0-1
      largs=larg;
      [xxl,yyl,lpl,larg]=build_scs_tree(scs_m.objs(k).model.rpar,'super',,larg)
      xx=[xx,xxl];yy=[yy,yyl]
      lp=list_concat(lp,lpl)

      xlk=xlk+(larg-largs)+1/(nl*(1+abs(y0)))
      y0=y0s;x0=x0s
    end
    path($)=[]
  end
endfunction
