function lnk=scicos_link(xx=[],yy=[],id='drawlink',thick=[0,0],ct=[1,1],from=[],to=[])
//initialisation de link mlist
// mlist XXX
  lnk=tlist(['Link','xx','yy','id','thick','ct','from','to'], xx,yy,id,thick,ct,from,to)
endfunction
