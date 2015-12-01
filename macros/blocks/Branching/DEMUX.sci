function [x,y,typ]=DEMUX(job,arg1,arg2)
// Copyright INRIA
  function blk_draw(sz,orig,orient,label)  
    txt="Demux";
    fz=2*acquire("%zoom",def=1)*4;
    xstring(orig(1)+sz(1)/2,orig(2)+sz(2),txt,posx="center",posy="bottom",size=fz);
  endfunction
  
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
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    while %t do
      [ok,out,exprs]=getvalue('Set DEMUX block parameters',..
			      ['Number of output ports or vector of sizes'],list('vec',-1),exprs)
      if ~ok then break,end

      if size(out,'*')==1 then
	if out<1|out>31 then
	  message('Block must have at least 1 and at most 31 output ports')
	  ok=%f
	else

          it=-1
          ot=-ones(out,1)
          oup=[-[1:out]',ones(out,1)]
          inp=[0,1]
          [model,graphics,ok]=set_io(model,graphics,...
				     list(inp,it),...
				     list(oup,ot),[],[])
	end
      else
        if size(out,'*')==0| or(out==0)|size(out,'*')>31 then
	  message(['Block must have at least 1 and at most 31 output ports';
		   'size 0 is not allowed'])
	  ok=%f
	else
	  if min(out)<0 then nin=0,else nin=sum(out),end

          it=-1
          ot=-ones(size(out,'*'),1)
          oup=[out(:),ones(size(out,'*'),1)]
          inp=[nin,1]
	  
          [model,graphics,ok]=set_io(model,graphics,...
				     list(inp,it),...
				     list(oup,ot),[],[])
	end
      end

      if ok then
	graphics.exprs=exprs;
	x.graphics=graphics;x.model=model
	break
      end
    end
   case 'define' then
    out=2
    model=scicos_model()
    model.sim=list('multiplex',4)
    model.in=0 //means equal to the sum of the outputs
    model.out=-[1:out]'
    model.intyp=-1
    model.outtyp=-ones(out,1)
    model.blocktype='c'
    model.firing=[]
    model.dep_ut=[%t %f]
    exprs=string(out)
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([.5 2],model,exprs,gr_i,'DEMUX')
  end
endfunction
