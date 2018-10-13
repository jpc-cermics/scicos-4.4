function [x,y,typ]=freq_div(job,arg1,arg2)
  // contains a diagram inside
  // the diagram have exprs now and upgrade method
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
      // be sure that exprs is now in block
      [x,changed]=freq_div('upgrade',arg1);
      if changed then y = max(y,2);end
      exprs=x.graphics.exprs;
      // paths to updatable parameters or states
      newpar=list();
      blk=x.model.rpar.objs(1);// get the first block
      blk_new=blk;
      while %t do
	[ok,%ph,%df,exprs]=getvalue('Set frequency division block parameters',...
				    ['Phase (0 to division factor -1)';
				     'Division factor'],...
				    list('vec',1,'vec',1),exprs);
	if ~ok then break,end
	%df = max(1,%df); %ph= min(abs(%ph), %df-1);
	blk_new.graphics.exprs=exprs;
	blk_new.model.ipar=%df;
	blk_new.model.dstate=%ph;
	break;
      end
      if ~blk.equal[blk_new] then 
	[needcompile]=scicos_object_check_needcompile(blk,blk_new);
	// parameter or states changed
	x.model.rpar.objs(1)=blk_new;// update the block
	x.graphics.exprs = exprs; 
	newpar(1) =1;// Notify modification
	y=max(y,needcompile); 
      end
      typ=newpar
      resume(needcompile=y);// propagate needcompile
    case 'define' then
      scs_m=freq_div_define()
      model = mlist(["model","sim","in","in2","intyp","out","out2","outtyp","evtin","evtout",...
		     "state","dstate","odstate","rpar","ipar","opar","blocktype",...
		     "firing","dep_ut","label","nzcross","nmode","equations"],...
		    "csuper",[],[],1,[],[],1,1,1,[],[],list(),...
		    scs_m,[],list(),"h",[],[%f,%f],"",0,0,list())
      gr_i='xstringb(orig(1),orig(2),''freq_div'',sz(1),sz(2),''fill'')';
      x=standard_define([2 2],model,[],gr_i,'freq_div');
      x.graphics.exprs = x.model.rpar.objs(1).graphics.exprs;
    case 'upgrade' then
      // upgrade if necessary
      if ~arg1.graphics.iskey['exprs'] || isempty(arg1.graphics.exprs) then
	// arg1 do not have a correct exprs field
	exprs =  arg1.model.rpar.objs(1).graphics.exprs;
	x = freq_div('define');
	x.graphics.exprs = exprs;
	x.model.rpar.objs(1).graphics.exprs = exprs;
	y=%t;
      else
	x=arg1;
	y=%f;
      end
  end
endfunction

function scs_m=freq_div_define()
// new version 
// The important point is that the Modulo_Count('define') 
// must be the first object in diagram.

  scs_m=scicos_diagram();
  
  blk=Modulo_Count('define');
  blk.graphics.out_implicit= [ "E" ];
  blk.graphics.orig= [ 90.5184, 178.3333 ];
  blk.graphics.sz= [60, 40 ];
  blk.graphics.in_implicit= [];
  blk.graphics.pein= [10 ];
  blk.graphics.pout= [5 ];
  scs_m.objs(1)=blk;
  
  blk=CLKINV_f('define');
  blk.graphics.out_implicit= [];
  blk.graphics.orig= [213.1480, 269.8148 ];
  blk.graphics.sz= [20, 30 ];
  blk.graphics.peout= [7 ];
  blk.graphics.in_implicit= [];
  scs_m.objs(2)=blk;
  
  blk=CLKOUTV_f('define');
  blk.graphics.pein= [6 ];
  blk.graphics.orig= [231.3041, 96.4815 ];
  blk.graphics.sz= [20, 30 ];
  blk.graphics.in_implicit= [];
  blk.graphics.out_implicit= [];
  scs_m.objs(3)=blk;
  
  blk=IFTHEL_f('define');
  blk.graphics.pein= [9 ];
  blk.graphics.orig= [193.1480, 168.7037 ];
  blk.graphics.pout= [];
  blk.graphics.sz= [60, 60 ];
  blk.graphics.peout= [0; 6 ];
  blk.graphics.pin= [5 ];
  blk.graphics.in_implicit= [ "E" ];
  blk.graphics.exprs= [ "1"; "0" ];
  scs_m.objs(4)=blk;

  blk=scicos_link();
  blk.to= [4, 1, 1 ];
  blk.from= [1, 1, 0 ];
  blk.xx= [159.0898;  184.5766 ];
  blk.yy= [198.3333;  198.7037 ];
  scs_m.objs(5)=blk;
  
  blk=scicos_link();
  blk.from= [4, 2, 0 ];
  blk.xx= [233.1480; 233.1480;241.3041;241.3041 ];
  blk.yy= [162.9894; 144.7354; 144.7354; 126.4815 ];
  blk.ct= [ 5, -1 ];
  blk.to= [3, 1, 1 ];
  scs_m.objs(6)=blk;
  
  blk=scicos_link();
  blk.from= [2, 1, 0 ];
  blk.xx= [223.1480; 223.1480 ];
  blk.yy= [269.8148; 264.0984 ];
  blk.ct= [ 5, -1 ];
  blk.to= [8, 1, 1 ];
  scs_m.objs(7)=blk;
  
  blk=CLKSPLIT_f('define');
  blk.graphics.pein= [7 ];
  blk.graphics.orig= [223.1480, 264.0984 ];
  blk.graphics.peout= [ 9; 10 ];
  scs_m.objs(8)=blk;
  
  blk=scicos_link();
  blk.from= [8, 1, 0 ];
  blk.xx= [223.1480; 223.1480 ];
  blk.yy= [264.0984; 234.4180 ];
  blk.ct= [ 5, -1 ];
  blk.to= [4, 1, 1 ];
  scs_m.objs(9)=blk;
  
  blk=scicos_link();
  blk.from= [8, 2, 0 ];
  blk.xx= [223.1480; 223.1480; 120.5184; 120.5184 ];
  blk.yy= [264.0984; 244.0730; 244.0730; 224.0476 ];
  blk.ct= [ 5, -1 ];
  blk.to= [1, 1, 1 ];
  scs_m.objs(10)=blk;

  scs_m=do_silent_eval(scs_m);
endfunction


  
  
  
  
