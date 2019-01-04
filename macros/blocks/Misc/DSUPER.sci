function [x,y,typ]=DSUPER(job,arg1,arg2)
  // Copyright INRIA
  
  function blk_draw(sz,orig,orient,label)
    xx=orig(1)+      [2 4 4]*(sz(1)/7);
    yy=orig(2)+sz(2)-[2 2 6]*(sz(2)/10);
    z=ones(1,size(xx,2));
    g=xget('color','gray');
    xrects([xx;yy;[sz(1)/7;sz(2)/5]*ones(1,3)],color=z,background=g*z);
    xx=orig(1)+      [1 2 3 4 5 6 3.5 3.5 3.5 4 5 5.5 5.5 5.5]*sz(1)/7;
    yy=orig(2)+sz(2)-[3 3 3 3 3 3 3   7   7   7 7 7   7   3  ]*sz(2)/10;
    xsegs(xx,yy,style=0);
  endfunction
  
  x=[];y=[],typ=[]

  select job
    case 'plot' then
      standard_draw(arg1)
    case 'getinputs' then
      [x,y,typ]=standard_inputs(arg1)
    case 'getoutputs' then
      [x,y,typ]=standard_outputs(arg1)
    case 'getorigin' then
      [x,y]=standard_origin(arg1)
    case 'set' then

      y=acquire('needcompile',def=0);
      typ=list()
      graphics=arg1.graphics;
      if isempty(graphics.exprs) then x=arg1,return,end;
      exprs=graphics.exprs(1)
      exprs0=graphics.exprs(2)(1)
      btitre=graphics.exprs(2)(2)(1)
      bitems=graphics.exprs(2)(2)(2:$)
      if isempty(exprs0) then x=arg1,return,end

      if size(exprs0,'*') > 19 then 
	printf("WIP: DSUPER cannot call getvalue since we have too many parameters\n");
	x=arg1;
	return;
      end
      
      tt="scicos_context."+exprs0(1);
      for i=2:size(exprs0,1)
	tt=tt+",scicos_context."+exprs0(i),
      end
      // we try to recover a multiline title 
      // from a sci2exp
      ok=execstr(sprintf("title=%s",btitre),errcatch=%t);
      if ok then
	if type(title,"short")=="s" then title=title(:);else title= btitre;end
      else
	lasterror();	title= btitre;
      end
      
      ss=graphics.exprs(2)(3)
      scicos_context=hash(10)
      execstr("[ok,"+tt+",exprs]=getvalue(title,bitems,ss,exprs)")
      if ok then
	x=arg1
	%scicos_context=scicos_context;
	context=[x.model.rpar.props.context]
	[%scicos_context,ierr]=script2var(context,%scicos_context)
	if ierr==0 then 
	  sblock=x.model.rpar
	  [sblock,%w,needcompile2,ok]=do_eval(sblock,list(),%scicos_context)
	  y=max(2,y,needcompile2)
	  x.graphics.exprs(1)=exprs
	  x.model.rpar=sblock;
	else
	  message(["Failed to evaluate given values:","",catenate(lasterror())]);
	end
      else
	x=arg1
      end

    case "define" then
      [x,y,typ] = SUPER_f ("define");
      x.gui="DSUPER";
      x.model.sim="csuper";
      x.model.ipar=1;
  end
endfunction
