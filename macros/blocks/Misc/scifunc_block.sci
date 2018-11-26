function [x,y,typ]=scifunc_block(job,arg1,arg2)
//%Description
// job=='plot' :      block drawing
//                    arg1 is block data structure
//                    arg2 :unused
// job=='getinputs' : return position and type of inputs ports
//                    arg1 is block data structure
//                    x  : x coordinates of ports
//                    x  : y coordinates of ports
//                    typ: type of ports
// job=='getoutputs' : return position and type of outputs ports
//                    arg1 is block data structure
//                    x  : x coordinates of ports
//                    x  : y coordinates of ports
//                    typ: type of ports
// job=='getorigin'  : return block origin coordinates
//                    x  : x coordinates of block origin
//                    x  : y coordinates of block origin
// job=='set'        : block parameters acquisition 
//                    arg1 is block data structure
//                    x is returned block data structure
// job=='define'     : corresponding block data structure initialisation
//                    arg1: name of block parameters acquisition macro
//                    x   : block data structure
//%Block data-structure definition
// bl=list('Block',graphics,model,init,'standard_block')
//  graphics=list([xo,yo],[l,h],orient,label)
//          xo          - x coordinate of block origin
//          yo          - y coordinate of block origin
//          l           - block width
//          h           - block height
//          orient      - boolean, specifies if block is tilded
//          label       - string block label
//  model=list(eqns,#input,#output,#clk_input,#clk_output,state,..
//             rpar,ipar,typ [,firing])
//          eqns        - function name (in string form if fortran routine)
//          #input      - vector of input port sizes
//          #output     - vector of ouput port sizes
//          #clk_input  - vector  of clock inputs port sizes
//          #clk_output - vector  of clock output port sizes
//          state       - vector (column) of initial condition
//          rpar        - vector (column) of real parameters
//          ipar        - vector (column) of integer parameters
//          typ         - string: 'c' if block is continuous, 'd' if discrete
//                        'z' if zero-crossing.
//          firing      - vector of initial ouput event firing times
//
// Copyright INRIA
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
    x=arg1
    model=arg1.model;graphics=arg1.graphics;
    exprs=graphics.exprs

    if size(exprs(1),'*')==8 then exprs(1)(9)='0';end

    non_interactive = scicos_non_interactive();
    
    gv_title = ['Set scifunc_block parameters';'only regular blocks supported'];
    gv_entries = ['input ports sizes';
		  'output port sizes';
		  'input event ports sizes';
		  'output events ports sizes';
		  'initial continuous state';
		  'initial discrete state';
		  'System parameters vector';
		  'initial firing vector (<0 for no firing)';
		  'is block always active (0:no, 1:yes)'  ];
    gv_types = list('vec',-1,'vec',-1,'vec',-1,'vec',-1,'vec',-1,'vec',-1,
		    'vec',-1,'vec','sum(%4)','vec',1);
    while %t do
      [ok,i,o,ci,co,xx,z,rpar,auto0,deptime,lab]=getvalue(gv_title,gv_entries,gv_types,exprs(1));
      if ~ok then break,end
      exprs(1)=lab
      xx=xx(:);z=z(:);rpar=rpar(:)
      nrp=prod(size(rpar))
      // create simulator
      i=int(i(:));ni=size(i,1);
      o=int(o(:));no=size(o,1);
      ci=int(ci(:));nci=size(ci,1);
      co=int(co(:));nco=size(co,1);
      
      if non_interactive then 
	ok=%t;dep_ut=[%t,%f];tt=exprs(2);
      else
	[ok,tt,dep_ut]=genfunc1(exprs(2),i,o,nci,nco,size(xx,1),size(z,1), nrp,'c')
      end
      dep_ut(2)=(1==deptime)
      if ~ok then break,end
      [model,graphics,ok]=check_io(model,graphics,i,o,ci,co)
      if ok then
	auto=auto0
	model.state=xx
	model.dstate=z
	model.rpar=rpar
	if ~model.ipar.equal[tt] then y=4,end
	model.ipar=tt
	model.firing=auto
	model.dep_ut=dep_ut
	x.model=model
	exprs(2)=tt
	graphics.exprs=exprs
	x.graphics=graphics
	break
      end
    end
   case 'define' then
     model=scicos_model(sim=list('scifunc',3),in = 1, out=1, dep_ut=[%t %f], ipar=0);
     exprs=list([sci2exp(model.in);sci2exp(model.out);
		 sci2exp(model.evtin);sci2exp(model.evtout);
		 strcat(sci2exp(model.state));strcat(sci2exp(model.dstate));
		 strcat(sci2exp(model.rpar));sci2exp(model.firing)],
		list("y1=sin(u1)"," "," ","y1=sin(u1)"," "," "," "))
     gr_i=["xstringb(orig(1),orig(2),""Scifunc"",sz(1),sz(2),""fill"");"]
     x=standard_define([2 2],model,exprs,gr_i,"scifunc_block");
  end
endfunction
