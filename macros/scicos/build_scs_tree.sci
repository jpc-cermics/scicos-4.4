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
      [xxl,yyl,lpl,larg]=build_scs_tree(scs_m.objs(k).model.rpar,'super',larg)
      xx=[xx,xxl];yy=[yy,yyl]
      lp=list_concat(lp,lpl)

      xlk=xlk+(larg-largs)+1/(nl*(1+abs(y0)))
      y0=y0s;x0=x0s
    end
    path($)=[]
  end
endfunction
