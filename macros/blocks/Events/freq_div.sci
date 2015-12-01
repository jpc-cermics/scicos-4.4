function [x,y,typ]=freq_div(job,arg1,arg2)
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
    // paths to updatable parameters or states
    newpar=list();
    y=0;
    spath=list()
    spath($+1)='model'
    spath($+1)='rpar'
    spath($+1)='objs'
    spath($+1)=1
    xx=arg1(spath)// get the block
    xxn=xx;
    graphics=xx.graphics;exprs=graphics.exprs
    model=xx.model;
    while %t do
      [ok,%ph,%df,exprs]=getvalue...
	  ('Set frequency division block parameters',...
	   ['Phase (0 to division factor -1)';'Division factor'],...
	   list('vec',1,'vec',1),exprs)
      if ~ok then break,end
      if ok then
	if %df<1 then %df=1,end
	%ph=abs(%ph)
	if %ph>%df-1 then %ph=%df-1,end
	graphics.exprs=exprs
	model.ipar=%df;
	model.dstate=%ph;
	xxn.graphics=graphics;xxn.model=model
	break
      end
    end
    if ~xx.equal[xxn] then 
      [needcompile]=scicos_object_check_needcompile(xx,xxn);
      // parameter or states changed
      arg1(spath)=xxn// Update
      newpar(size(newpar)+1)=1// Notify modification
      y=max(y,needcompile)
    end
    x=arg1
    typ=newpar
   case 'define' then
    scs_m_1=freq_div_diagram();
    model = mlist(..
		  ["model","sim","in","in2","intyp","out","out2","outtyp","evtin","evtout",..
		   "state","dstate","odstate","rpar","ipar","opar","blocktype",..
		   "firing","dep_ut","label","nzcross","nmode","equations"],"csuper",[],[],1,[],[],1,1,1,[],[],list(),..
		  scs_m_1,[],list(),"h",[],[%f,%f],"",0,0,list())
    gr_i='xstringb(orig(1),orig(2),''freq_div'',sz(1),sz(2),''fill'')';
    x=standard_define([2 2],model,[],gr_i,'freq_div');
  end
endfunction

function scs_m=freq_div_diagram()
  // old version 
  scs_m=scicos_diagram()
  scs_m.props=tlist(["params","wpar","title","tol","tf","context","void1","options","void2","void3","doc"],..
		    [600,450,0,0,600,450],"freq_div",[0.0001,1.000E-06,1.000E-10,100001,0,0],100000," ",[],..
		    scicos_options(),[],[], list());
  
  scs_m.objs(1)=mlist(["Block","graphics","model","gui","doc"],..
		      mlist(["graphics","orig","sz","flip","exprs","pin","pout","pein",..
		    "peout","gr_i","id","in_implicit","out_implicit"],..
			    [60.518363,178.33333],[60,40],%t,["0";"3"],[],7,10,[],..
			    list(..
				 "xstringb(orig(1),orig(2),[''  Counter'';''Modulo ''+string(base)],sz(1),sz(2),''fill'');",..
				 8),"",[],"E"),..
		      mlist(..
			    ["model","sim","in","in2","intyp","out","out2","outtyp","evtin","evtout",..
		    "state","dstate","odstate",..
		    "rpar","ipar","opar","blocktype","firing","dep_ut","label","nzcross",..
		    "nmode","equations"],list("modulo_count",4),[],[],1,1,[],1,1,[],[],0,list(),..
			    [],3,list(),..
			    "c",[],[%f,%f],"",0,0,list()),"Modulo_Count",list())
  scs_m.objs(2)=mlist(["Block","graphics","model","gui","doc"],..
		      mlist(..
			    ["graphics","orig","sz","flip","exprs","pin","pout","pein",..
		    "peout","gr_i","id","in_implicit","out_implicit"],..
			    [215.37648,299.81481],[20,30],%t,"1",[],[],[],6,..
			    list(..
				 ["xo=orig(1);yo=orig(2)+sz(2)/3";
		    "xstringb(xo,yo,string(prt),sz(1),sz(2)/1.5)"],8),"",[],[]),..
		      mlist(..
			    ["model","sim","in","in2","intyp","out","out2","outtyp","evtin","evtout",..
		    "state","dstate","odstate",..
		    "rpar","ipar","opar","blocktype","firing","dep_ut","label","nzcross",..
		    "nmode","equations"],"input",[],[],1,[],[],1,[],1,[],[],list(),[],1,..
			    list(),"d",-1,..
			    [%f,%f],"",0,0,list()),"CLKINV_f",list())
  scs_m.objs(3)=mlist(["Block","graphics","model","gui","doc"],..
		      mlist(..
			    ["graphics","orig","sz","flip","exprs","pin","pout","pein",..
		    "peout","gr_i","id","in_implicit","out_implicit"],..
			    [221.30407,86.481481],[20,30],%t,"1",[],[],5,[],list(" ",8),"",..
			    [],[]),..
		      mlist(..
			    ["model","sim","in","in2","intyp","out","out2","outtyp","evtin","evtout",..
		    "state","dstate","odstate",..
		    "rpar","ipar","opar","blocktype","firing","dep_ut","label","nzcross",..
		    "nmode","equations"],"output",[],[],1,[],[],1,1,[],[],[],list(),[],1,list(),"d",[],..
			    [%f,%f],"",0,0,list()),"CLKOUTV_f",list())
  scs_m.objs(4)=mlist(["Block","graphics","model","gui","doc"],..
		      mlist(..
			    ["graphics","orig","sz","flip","exprs","pin","pout","pein",..
		    "peout","gr_i","id","in_implicit","out_implicit"],..
			    [193.14804,168.7037],[60,60],%t,["1";"0"],7,[],9,[0;5],..
			    list(..
				 ["txt=[''If in>0'';'' '';'' then    else''];";
		    "xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'');"],8),"","E",..
			    []),..
		      mlist(..
			    ["model","sim","in","in2","intyp","out","out2","outtyp","evtin","evtout",..
		    "state","dstate","odstate",..
		    "rpar","ipar","opar","blocktype","firing","dep_ut","label","nzcross",..
		    "nmode","equations"],list("ifthel",-1),1,[],1,[],[],1,1,[1;1],[],[],list(),..
			    [],[],list(),..
			    "l",[-1,-1],[%t,%f],"",0,0,list()),"IFTHEL_f",list())
  scs_m.objs(5)=mlist(["Link","xx","yy","id","thick","ct","from","to"],..
		      [233.14804;231.30407],[162.98942;116.48148],"drawlink",[0,0],..
		      [5,-1],[4,2,0],[3,1,1])
  scs_m.objs(6)=mlist(["Link","xx","yy","id","thick","ct","from","to"],..
		      [225.37648;224.29194],[299.81481;267.98739],"drawlink",[0,0],..
		      [5,-1],[2,1,0],[8,1,1])
  scs_m.objs(7)=mlist(["Link","xx","yy","id","thick","ct","from","to"],..
		      [129.08979;184.57662],[198.33333;198.7037],"drawlink",[0,0],..
		      [1,1],[1,1,0],[4,1,1])
  scs_m.objs(8)=mlist(["Block","graphics","model","gui","doc"],..
		      mlist(..
			    ["graphics","orig","sz","flip","exprs","pin","pout","pein",..
		    "peout","gr_i","id","in_implicit","out_implicit"],..
			    [224.29194;267.98739],[0.3333333,0.3333333],%t,[],[],[],6,[9;10],..
			    list([],8),"",[],[]),..
		      mlist(..
			    ["model","sim","in","in2","intyp","out","out2","outtyp","evtin","evtout",..
		    "state","dstate","odstate",..
		    "rpar","ipar","opar","blocktype","firing","dep_ut","label","nzcross",..
		    "nmode","equations"],"split",[],[],1,[],[],1,1,[1;1],[],[],list(),..
			    [],[],list(),"d",..
			    [%f,%f,%f],[%f,%f],"",0,0,list()),"CLKSPLIT_f",list())
  scs_m.objs(9)=mlist(["Link","xx","yy","id","thick","ct","from","to"],..
		      [224.29194;223.14804],[267.98739;234.41799],"drawlink",[0,0],..
		      [5,-1],[8,1,0],[4,1,1])
  scs_m.objs(10)=mlist(["Link","xx","yy","id","thick","ct","from","to"],..
		       [224.29194;90.518363;90.518363],[267.98739;267.98739;224.04762],..
		       "drawlink",[0,0],[5,-1],[8,2,0],[1,1,1])
endfunction

function scs_m=freq_div_diagram_new()
// new version 
// The important point is that the Modulo_Count('define') 
// must be the first object in diagram.
  scicos_ver = [ "scicos4.4.1" ]
  x_0=scicos_diagram();
  x_1=scicos_params();
  x_1.title= [ "freq_div"];
  x_1.wpar= [ 49.4489, 45.1330, 299.8987, 358.2664,  1.4000 ];
  x_1.context= [ " " ];
  x_0.props=x_1;clear('x_1');
  x_1=list();
  
  x_2=Modulo_Count('define');
  x_2.graphics.out_implicit= [ "E" ];
  x_2.graphics.orig= [ 90.5184, 178.3333 ];
  x_2.graphics.sz= [60, 40 ];
  x_2.graphics.in_implicit= [];
  x_2.graphics.pein= [10 ];
  x_2.graphics.pout= [5 ];
  x_1(1)=x_2;clear('x_2');
  
  x_2=CLKINV_f('define');
  x_2.graphics.out_implicit= [];
  x_2.graphics.orig= [213.1480, 269.8148 ];
  x_2.graphics.sz= [20, 30 ];
  x_2.graphics.peout= [7 ];
  x_2.graphics.in_implicit= [];
  x_1(2)=x_2;clear('x_2');
  
  x_2=CLKOUTV_f('define');
  x_2.graphics.pein= [6 ];
  x_2.graphics.orig= [231.3041, 96.4815 ];
  x_2.graphics.sz= [20, 30 ];
  x_2.graphics.in_implicit= [];
  x_2.graphics.out_implicit= [];
  x_1(3)=x_2;clear('x_2');
  
  x_2=IFTHEL_f('define');
  x_2.graphics.pein= [9 ];
  x_2.graphics.orig= [193.1480, 168.7037 ];
  x_2.graphics.pout= [];
  x_2.graphics.sz= [60, 60 ];
  x_2.graphics.peout= [0; 6 ];
  x_2.graphics.pin= [5 ];
  x_2.graphics.in_implicit= [ "E" ];
  x_2.graphics.exprs= [ "1"; "0" ];
  x_1(4)=x_2;clear('x_2');

  x_2=scicos_link();
  x_2.to= [4, 1, 1 ];
  x_2.from= [1, 1, 0 ];
  x_2.xx= [159.0898;  184.5766 ];
  x_2.yy= [198.3333;  198.7037 ];
  x_1(5)=x_2;clear('x_2');
  
  x_2=scicos_link();
  x_2.from= [4, 2, 0 ];
  x_2.xx= [233.1480; 233.1480;241.3041;241.3041 ];
  x_2.yy= [162.9894; 144.7354; 144.7354; 126.4815 ];
  x_2.ct= [ 5, -1 ];
  x_2.to= [3, 1, 1 ];
  x_1(6)=x_2;clear('x_2');
  
  x_2=scicos_link();
  x_2.from= [2, 1, 0 ];
  x_2.xx= [223.1480; 223.1480 ];
  x_2.yy= [269.8148; 264.0984 ];
  x_2.ct= [ 5, -1 ];
  x_2.to= [8, 1, 1 ];
  x_1(7)=x_2;clear('x_2');
  
  x_2=CLKSPLIT_f('define');
  x_2.graphics.pein= [7 ];
  x_2.graphics.orig= [223.1480, 264.0984 ];
  x_2.graphics.peout= [ 9; 10 ];
  x_1(8)=x_2;clear('x_2');
  
  x_2=scicos_link();
  x_2.from= [8, 1, 0 ];
  x_2.xx= [223.1480; 223.1480 ];
  x_2.yy= [264.0984; 234.4180 ];
  x_2.ct= [ 5, -1 ];
  x_2.to= [4, 1, 1 ];
  x_1(9)=x_2;clear('x_2');
  
  x_2=scicos_link();
  x_2.from= [8, 2, 0 ];
  x_2.xx= [223.1480; 223.1480; 120.5184; 120.5184 ];
  x_2.yy= [264.0984; 244.0730; 244.0730; 224.0476 ];
  x_2.ct= [ 5, -1 ];
  x_2.to= [1, 1, 1 ];
  x_1(10)=x_2;clear('x_2');
  
  x_0.objs=x_1;clear('x_1');
  scs_m=x_0;clear('x_0');
  scs_m=do_eval(scs_m);
endfunction


  
  
  
  
