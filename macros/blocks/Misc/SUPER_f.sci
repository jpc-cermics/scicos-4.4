function [x,y,typ]=SUPER_f(job,arg1,arg2)
  // Copyright INRIA
  function blk_draw(sz,orig,orient,label)
    xx=orig(1)+      [2 4 4]*(sz(1)/7);
    yy=orig(2)+sz(2)-[2 2 6]*(sz(2)/10);
    z=ones(1,size(xx,2));
    g=xget('color','gray');
    xrects([xx;yy;[sz(1)/7;sz(2)/5]*ones(1,3)],color=z,background=g*z)// thickness=2*z);
	  xx=orig(1)+      [1 2 3 4 5 6 3.5 3.5 3.5 4 5 5.5 5.5 5.5]*sz(1)/7;
	  yy=orig(2)+sz(2)-[3 3 3 3 3 3 3   7   7   7 7 7   7   3  ]*sz(2)/10;
	  xsegs(xx,yy,style=0);//thickness=2);
  endfunction
  
  x=[];y=[],typ=[]
  select job
    case 'plot' then
      standard_draw(arg1)
      s_port_names(arg1)
    case 'getinputs' then
      [x,y,typ]=standard_inputs(arg1)
    case 'getoutputs' then
      [x,y,typ]=standard_outputs(arg1)
    case 'getorigin' then
      [x,y]=standard_origin(arg1)
    case 'set' then
      [x,y,typ]=SUPER_f_set(job,arg1);
      resume(%exit=%f);
      resume(needcompile=y);
    case 'define' then
      scs=scicos_diagram();
      scs.props.title='Super Block';
      model=scicos_model();
      model.sim='super';
      model.in=1;
      model.out=1;
      model.rpar=scs;
      model.blocktype='h';
      model.dep_ut=[%f %f];
      gr_i="blk_draw(sz,orig,orient,model.label)";
      x=standard_define([2 2],model,[],gr_i,'SUPER_f');
  end
endfunction

function [x,y,typ]=SUPER_f_set(job,arg1)
  x=arg1;
  y=acquire('needcompile',def=0);
  standard = ~(exists('getvalue') && getvalue.get_fname[]== 'getvalue_doc');
  while %t do
    if standard then 
      [rpar_new,newparameters,needcompile,edited]=scicos(arg1.model.rpar)
    else
      [rpar_new,newparameters,needcompile,edited]=(arg1.model.rpar,[],-2,%f)
    end
    arg1.model.rpar= rpar_new;
    [ok,arg1]=adjust_s_ports(arg1);
    if ok then
      x=arg1
      y=max(y,needcompile);
      typ=newparameters
      return;
    else
      %r=message(['SUPER BLOCK needs to be edited;';
		  'Edit or exit by removing all recent changes'],['Edit'; ...
								  'Exit'])
      if %r==2 then 
	xdel(curwin)
	typ=list()
	return;
      else
	global %scicos_navig
	global Scicos_commands 
	global inactive_windows
	%scicos_navig=[];Scicos_commands=[]
	%diagram_open=%t
	//scf(curwin)
        xset('window',curwin)
	indx=find(curwin==inactive_windows(2))
	if size(indx,'*')>=1 then indx= indx(1);
	  inactive_windows(1)(indx)=null();inactive_windows(2)(indx)=[]
	end
      end
    end
  end
endfunction
