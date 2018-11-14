function [x,y,typ]=MB_Prodn(job,arg1,arg2)
  // A Modelica block (following coselica types i.e using RealInput/RealOutput types)
  // used to add vectors in the SUMMATION spirit 

  function blk_draw(o,sz,orig)
    // using summation draw
    // should turn the square to blue triangles.
    blue=xget('color','blue');
    white=xget('color','white');
    gray=xget('color','gray');

    [x,y,typ]=standard_inputs(o)
    dd=sz(1)/8,de=0;
    if ~o.graphics.flip then dd=6*sz(1)/8,de=-sz(1)/8,end
    xrect(orig(1),orig(2)+sz(2),sz(1),sz(2),color=gray,background=white);
    
    if ~exists("%zoom") then %zoom=1, end;
    fz=2*%zoom*4;
    for k=1:size(x,'*');
      if size(signs,'*') >= k then
	if signs(k) > 0 then;
	  xstring(orig(1)+dd,y(k)-4,'*',size=fz,color=blue);
	else;
	  xstring(orig(1)+dd,y(k)-4,'/',size=fz,color=blue);
	end;
      end;
    end;
    xx=sz(1)*[.8 .8 .4  .4]+orig(1)+de;
    yy=sz(2)*[.2 .8 .8  .2]+orig(2);
    xpoly(xx,yy,type='lines',color=blue);
  endfunction

  function txt = MB_Prodn_funtxt(H, dim_r, signs)
    // n : signal dimensions
    // signs : the signs to be used for each of them
    txt=VMBLOCK_classhead(H.nameF,H.in,H.intype,[H.in_r,H.in_c],H.out,H.outtype,
			  [H.out_r,H.out_c],H.param,H.paramv,H.pprop)
    txt.concatd["  equation"];
    nsigns= size(signs,'*');
    // format for instruction 
    txt_signs = strsubst(string(signs(:)),["-1","1"," "],["/","*",""]);
    txt_u = "u"+string(1:nsigns)'+"[%d].signal";
    fmt = "    y[%d].signal= 1.0"+ catenate(txt_signs+txt_u,sep=" ")+";";
    if dim_r ==1 then
      txt.concatd[strsubst(fmt,"[%d]","")];
    elseif dim_r > 1 then 
      txt.concatd[sprintf(fmt, (1:dim_r)'*ones(1,nsigns+1))];
    else
      // in fact this code should be ok when n != 1 
      txt.concatd[strsubst(fmt,"%d",":")];
    end
    txt.concatd[sprintf("end %s;", H.nameF)];
  endfunction
  
  function blk= MB_Prodn_define(dim_r, signs,old)
    if nargin <= 2 then 
      global(modelica_count=0);
      nameF='prodn'+string(modelica_count);
      modelica_count =       modelica_count +1;
    else
      nameF=old.graphics.exprs.nameF;
    end
    
    nsigns = size(signs,'*');
    H=hash(in=["u"+string(1:nsigns)'], intype=smat_create(nsigns,1,"I"),
	   in_r= dim_r*ones(nsigns,1), in_c=ones(nsigns,1),
	   out=["y"], outtype=["I"], out_r= dim_r, out_c=1,
	   param=[], paramv=list(), pprop=[], nameF=nameF);
    
    H.funtxt = MB_Prodn_funtxt(H, dim_r, signs);

    if nargin == 3 then
      blk = old;
      it =ones(nsigns,1); ot=1;
      in_imp= 1:nsigns; out_imp=1;
      [model,graphics,ok]=set_io(old.model,old.graphics,...
				 list([H.in_r,H.in_c],it),...
				 list([H.out_r,H.out_c],ot),[],[],
				 in_imp,out_imp);
      blk.model = model;
      blk.graphics=graphics;
      blk.graphics.exprs.funtxt = H.funtxt;
      blk.graphics.exprs.signs = signs;
      blk.model.sim(1) = H.nameF;
      blk.model.equations.model = H.nameF;
    else
      blk = VMBLOCK_define(H);
      blk.graphics.exprs.funtxt = H.funtxt;
      blk.graphics.exprs.signs = signs;
      blk.model.sim(1) = H.nameF;
      blk.model.equations.model = H.nameF;
      blk.graphics.exprs.nameF = H.nameF;
      blk.graphics('3D') = %f; // coselica options 
      blk.graphics.gr_i=list("blk_draw(o,sz,orig)",xget('color','blue'))
      blk.gui = "MB_Prodn";
      blk.model.in = dim_r*ones(nsigns,1);
      blk.model.out = dim_r;
    end
  endfunction
  
  x=[];y=[];typ=[];
  select job
    case 'plot' then
      signs=arg1.graphics.exprs.signs;
      standard_coselica_draw(arg1);
    case 'getinputs' then
      [x,y,typ]=standard_inputs(arg1)
    case 'getoutputs' then
      [x,y,typ]=standard_outputs(arg1)
    case 'getorigin' then
      [x,y]=standard_origin(arg1)
    case 'set' then
      x=arg1;
      signs= x.graphics.exprs.signs;
      value= list(sci2exp(signs));
      gv_titles='Set sum block parameters';
      gv_names=['sign vector (of +1, -1)'];
      gv_types = list('vec',-1);
      [ok,signs_n, value_n]=getvalue(gv_titles,gv_names,gv_types,value);
      if ~ok then return;end; // cancel in getvalue;
      x= MB_Prodn_define(max(x.model.in),signs_n,x);
    case 'define' then
      signs=[1;-1];
      x= MB_Prodn_define(-1,signs);
  end
endfunction
