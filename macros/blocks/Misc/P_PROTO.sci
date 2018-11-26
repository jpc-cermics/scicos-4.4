function [x,y,typ]=P_PROTO(job,arg1,arg2)
  //
  x=[];y=[];typ=[];
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
      non_interactive = scicos_non_interactive();
      x=arg1;
      titles=['NSP function name';'Parameters';'input ports sizes';
	      'output port sizes';'input event ports sizes';'initial discrete state';
	      'direct feedthrough (vector of 0 and 1)'];
      types=list('str',1,'gen', -1, 'vec',-1,'vec',-1,'vec',-1,'vec',-1,'vec',-1);
      model=arg1.model;graphics=arg1.graphics;label=graphics.exprs;
      while %t do
	[ok,nsp_func_name,params,i,o,ci,z,depu,lab]=..
	getvalue('Set P block parameters',titles,types,label);
	if ~ok then break,end
	label=lab
	nsp_func_name=stripblanks(nsp_func_name)
	i=int(i(:));
	o=int(o(:));
	ci=int(ci(:));
	co=[];
	dep_ut=[depu(:); 0];
	[model,graphics,ok]=check_io(model,graphics,i,o,ci,co)
	if ok then
          opar=list()
          params_names=params(1)
          params_values=params(2)
          for i=1:length(params_names)
            opar(params_names(i))=params_values(i)
          end
	  y = 4;
	  function ff(); endfunction
	  fun = acquire(nsp_func_name,def=ff);
	  S = sprint(fun,as_read=%t);
	  model.ipar=ascii(catenate(S,sep=" "));
	  model.dstate=z
	  model.dep_ut=dep_ut
	  arg1.model=model
	  graphics.exprs=label
	  arg1.graphics=graphics
	  x=arg1
	  break
	end
      end
    case 'define' then
      model=scicos_model()
      nsp_func_name=""
      parameters=list(list(),list())
      model.sim=list('pnspblock',4)
      model.in=1
      model.out=1
      model.evtin=[]
      model.evtout=[]
      model.dstate=[]
      model.ipar=[]
      model.blocktype='c' 
      model.dep_ut=[%t %f]
      label=[nsp_func_name;sci2exp(parameters);
	     sci2exp(model.in);sci2exp(model.out);
	     sci2exp(model.evtin);sci2exp(model.dstate);'1'];
      gr_i=['xstringb(orig(1),orig(2),''P NSP Block'',sz(1),sz(2),''fill'');']
      x=standard_define([2 3],model,label,gr_i,'P_PROTO');
  end
endfunction
