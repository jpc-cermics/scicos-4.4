function [x,y,typ]=nspexpr(job,arg1,arg2)
  x=[];
  y=[];
  typ=[];
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
    model=arg1.model;
    graphics=arg1.graphics;
    label=graphics.exprs;
    gv_titles= ['Simulation function name';
		'Is block implicit? (y,n)';
		'Input ports sizes';
		'Input ports type';
		'Output port sizes';
		'Output ports type';
		'Input event ports sizes';
		'Output events ports sizes';
		'Initial continuous state';
		'Initial discrete state';
		'Initial object state';
		'Real parameters vector';
		'Integer parameters vector';
		'Object parameters list';
		'Number of modes';
		'Number of zero crossings';
		'Initial firing vector (<0 for no firing)';
		'Direct feedthrough (y or n)';
		'Time dependence (y or n)'];
    gv_types=list('str',1,'str',1,'mat',[-1 2],'vec',-1,'mat',[-1 2],...
		  'vec',-1,'vec',-1,'vec',-1,'vec',-1,'vec',-1,'lis',-1,...
		  'vec',-1,'vec',-1,'lis',-1,'vec',1,'vec',1,'vec','sum(%8)',..
		  'str',1,'str',1);
    
    while %t do
      junction_name='sciblk';
	
	exprs=label(3);
	[ok,%exx,exprs]=getvalue(...
	    ['Give nsp code using inputs u1, u2,...';
	     'The last line must be an expression which will be returned";
	     'by the block';
             'ex: (dd*u1+sin(u2)>0)*u3';
	     'Note that here dd must be defined in context'],...
	    ['nsp expression'],..
	    list('str',1),exprs)
	if ~ok then break;end // we have made a cancel in genfunc5 
	ast = parse(exprs);
	H = ast_collect_vars(ast);
	numax = length(H);
	uvars=m2s([]);
	H1=H;
	for i=1:numax
	  var = 'u'+string(i);
	  if H1.iskey[var] then H1.remove[var]; uvars(1,$+1)=var;end;
	end
	if H1.iskey['u'] then uvars.remove["u"];end
	nu=size(uvars,'*');
	getu="["+catenate(uvars,sep=",")+"]=blk.inptr(:)";
	func_txt=["function [blk] = sciblk(blk,flag)";
		  "  if flag == 1 || flag == 6 then";
		  "    "+ getu;
		  "    u=u1;";
		  "   "+ exprs(1:$-1);
		  "    blk.outptr(1)="+exprs($);
		  "  end";
		  "endfunction"];
	if ~func_txt.equal[label(2)] then y=4, end;
	y = 4; // always compile ?
		
	in = ones(nu,1); 
	in2 = ones(nu,1);
	intyp = ones(1,nu);
	out= 1; 
	out2 = 1;
	outtyp = 1;
	ci=[];co=[];
	
	[model,graphics,ok]=set_io(model,graphics,list([in,in2],intyp),list([out,out2],outtyp),ci,co);
	if ~ok then continue;end 
	
	label=list([junction_name;'n';
		    sci2exp([model.in model.in2]);
		    sci2exp(model.intyp);
		    sci2exp([model.out model.out2])
		    sci2exp(model.outtyp);
		    sci2exp(model.evtin);  // heriter ou pas 0 ou 2
		    sci2exp(model.evtout); // 0
		    sci2exp(model.state);  
		    sci2exp(model.dstate);
		    sci2exp(model.odstate);
		    sci2exp(model.rpar);
		    sci2exp(model.ipar);
		    sci2exp(model.opar);
		    sci2exp(model.nmode);
		    sci2exp(model.nzcross);
		    sci2exp(model.firing);
		    'y';
		    'n'],...
		   []);
		
	model.sim=list('scifunc',5);
	arg1.model=model
	label(2)=func_txt
	label(3)=exprs;
	graphics.exprs=label
	arg1.graphics=graphics
	x=arg1
	break
      end
   case 'define' then
    model=scicos_model()
    junction_name='sciblk';
    funtyp=5;
    model.sim=list('scifunc',funtyp)
    model.in=1
    model.in2=1
    model.intyp=1
    model.out=1
    model.out2=1
    model.outtyp=1
    model.dep_ut=[%t %f]
    label=list([junction_name;'n';
		sci2exp([model.in model.in2]);
		sci2exp(model.intyp);
		sci2exp([model.out model.out2])
		sci2exp(model.outtyp);
		sci2exp(model.evtin);  // heriter ou pas 0 ou 2
		sci2exp(model.evtout); // 0
		sci2exp(model.state);  
		sci2exp(model.dstate);
		sci2exp(model.odstate);
		sci2exp(model.rpar);
		sci2exp(model.ipar);
		sci2exp(model.opar);
		sci2exp(model.nmode);
		sci2exp(model.nzcross);
		sci2exp(model.firing);
		'y';
		'n'],...
	       []);
    txt = '(u1>0)*sin(u2).^2';
    exprs=[string(size(model.in,'*'));txt;'1']
    label(3)=exprs;
    gr_i=['xstringb(orig(1),orig(2),''NspExpr'',sz(1),sz(2),''fill'');']
    x=standard_define([2 2],model,label,gr_i,'nspexpr');
  end
endfunction


