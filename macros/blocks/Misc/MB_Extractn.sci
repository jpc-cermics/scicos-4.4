function [x,y,typ]=MB_Extractn(job,arg1,arg2)
  // A Modelica block (following coselica types i.e using RealInput/RealOutput types)
  // used to add vectors in the SUMMATION spirit

  function blk_draw(o,sz,orig)
    // using summation draw
    // should turn the square to blue triangles.
    blue=xget('color','blue');
    white=xget('color','white');
    gray=xget('color','gray');
    indices = o.graphics.exprs.indices;
    str = strsubst(sci2exp(indices),' ','');
    str = sprintf("out = %s",str);
    xstringb(orig(1)+0.1*sz(1),orig(2)+0.1*sz(2),["Extractor";str],
	     0.9*sz(1),0.9*sz(2),"fill");
  endfunction

  function txt = MB_Extractn_funtxt(H,indices)
    // n : signal dimensions
    txt=VMBLOCK_classhead(H.nameF,H.in,H.intype,[H.in_r,H.in_c],H.out,H.outtype,
			  [H.out_r,H.out_c],H.param,H.paramv,H.pprop)
    txt.concatd["  equation"];
    // format for instruction
    fmt = "    y[%d].signal= u[%d].signal;"
    n = size(indices,'*');
    if n == 1 then
      fmt ="    y.signal= u[%d].signal;"
      txt.concatd[sprintf(fmt,indices(:))];
    else
      txt.concatd[sprintf(fmt,(1:n)',indices(:))];
    end
    txt.concatd[sprintf("end %s;", H.nameF)];
  endfunction
  
  function blk= MB_Extractn_define(dim_r, indices,old)

    if nargin <= 2 then 
      global(modelica_count=0);
      nameF='extractn'+string(modelica_count);
      modelica_count =       modelica_count +1;
    else
      nameF=old.graphics.exprs.nameF;
    end
    
    nindices = size(indices,'*');
    H=hash(in=["u"], intype="I", in_r= dim_r, in_c=1, 
	   out=["y"], outtype=["I"], out_r= nindices, out_c=1,
	   param=[], paramv=list(), pprop=[], nameF=nameF);
    
    H.funtxt = MB_Extractn_funtxt(H, indices);
    
    if nargin == 3 then
      blk = old;
      it =1; ot=1;
      in_imp= 1; out_imp=1;
      [model,graphics,ok]=set_io(old.model,old.graphics,...
				 list([H.in_r,H.in_c],it),...
				 list([H.out_r,H.out_c],ot),[],[],
				 in_imp,out_imp);
      blk.model = model;
      blk.graphics=graphics;
      blk.graphics.exprs.funtxt = H.funtxt;
      blk.graphics.exprs.indices = indices;
      blk.model.sim(1) = H.nameF;
      blk.model.equations.model = H.nameF;
    else
      blk = VMBLOCK_define(H);
      blk.graphics.exprs.funtxt = H.funtxt;
      blk.graphics.exprs.indices = indices;
      blk.model.sim(1) = H.nameF;
      blk.model.equations.model = H.nameF;
      blk.graphics.exprs.nameF = H.nameF;
      blk.graphics('3D') = %f; // coselica options 
      blk.graphics.gr_i="blk_draw(o,sz,orig)";
      blk.gui = "MB_Extractn";
      blk.model.in =  dim_r
      blk.model.out = size(indices,'*');
    end
  endfunction
  
  x=[];y=[];typ=[];
  select job
    case 'plot' then
      indices=arg1.graphics.exprs.indices;
      standard_coselica_draw(arg1);
    case 'getinputs' then
      [x,y,typ]=standard_inputs(arg1)
    case 'getoutputs' then
      [x,y,typ]=standard_outputs(arg1)
    case 'getorigin' then
      [x,y]=standard_origin(arg1)
    case 'set' then
      x=arg1;
      indices= x.graphics.exprs.indices;
      value= list(sci2exp(indices));
      gv_titles='Set extract block parameters';
      gv_names=['indices to extract '];
      gv_types = list('vec',-1);
      [ok,indices_n, value_n]=getvalue(gv_titles,gv_names,gv_types,value);
      if ~ok then return;end; // cancel in getvalue;
      x= MB_Extractn_define(x.model.in,indices_n,x);
    case 'define' then
      if nargin == 2 then indices = arg1;else indices=[1];end
      x= MB_Extractn_define(-1,indices);
  end
endfunction
