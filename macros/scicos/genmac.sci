function mac=genmac(tt,nin,nout)
// Copyright INRIA
// generate a macro from tt description
  [txt1,txt0,txt2,txt3,txt4,txt5,txt6]=tt(1:7)
  //    [y,  x,  z,  tvec,xd]=func(flag,nevprt,t,x,z,rpar,ipar,u)
  blank='  ';
  semi=';';
  // txt can be [] which is not a string thus we have to convert.
  txt1=blank+string(txt1);
  txt2=blank+string(txt2);
  txt3=blank+string(txt3);
  txt4=blank+string(txt4);
  txt5=blank+string(txt4);
  txt6=blank+string(txt6);
  u='u'
  if nin>0 then
    get_u=blank+'['+strcat(u(ones_new(1,nin))+string(1:nin),',')+']=u(:)'
  else
    get_u='';
  end
  y='y'
  set_y=blank+'y=list('+strcat(y(ones_new(1,nout))+string(1:nout),',')+')'
  
  mac_txt=['function [y,x,z,t_evo,xd]=mac(%_flag,n_evi,t,x,z,rpar,ipar,u)';
	   get_u
	   'select %_flag';
	   'case 0 then';
	   txt0
	   '  t_evo=[]';  
	   '  y=list()';
	   'case 1 then';
	   txt1
	   '  t_evo=[]';
	   '  xd=[]';
	   set_y;
	   'case 2 then';
	   txt2
	   '  y=list()';
	   '  t_evo=[]';
	   '  xd=[]';
	   'case 3 then';
	   txt3
	   '  xd=[]';
	   '  y=list()';
	   'case 4 then';
	   txt4
	   '  y=list()';
	   '  t_evo=[]';
	   '  xd=[]';
	   'case 5 then';
	   txt5
	   '  y=list()';
	   '  t_evo=[]';
	   '  xd=[]';
	   'case 6 then';
	   txt6
	   '  t_evo=[]';
	   '  xd=[]';
	   set_y
	   'end'
	   'endfunction']
  execstr(mac_txt);
endfunction
