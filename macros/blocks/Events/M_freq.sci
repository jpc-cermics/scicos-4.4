function [x,y,typ]=M_freq(job,arg1,arg2)
  x=[];y=[];typ=[]
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
    graphics=arg1.graphics;
    model=arg1.model;
    exprs=graphics.exprs
    while %t do
      [ok,frequ,offset,exprs]=getvalue('Set block parameters',..
				       ['Sample time';'Offset'],..
				       list('vec',-1,'vec',-1),exprs)
      if ~ok then break,end
      offset=offset(:);frequ=frequ(:);
      if (size(frequ,'*'))<>(size(offset,'*')) then message("offset and frequency must have the same size");ok=%f;
      elseif or(frequ<0) then message("Frequency must be a positif number");ok=%f;
      elseif or(abs(offset) > frequ) then
	message("The |Offset| must be less than the Frequency");ok=%f
      end
      if ok then
	if ~exists('scs_m') then return;end
	[m,den,off,count,m1,fir,frequ,offset,ok]=mfrequ_clk(frequ,offset);
      end
      if ok then
	model.opar=list(m,double(den),off,count)
	mn=(2**size(m1,'*'))-1;
	[model,graphics,ok]=set_io(model,graphics,list(),list(),1,ones(mn,1))
	if mn>3 then graphics.sz=[40+(mn-3)*10 40]
	else graphics.sz=[50 40]
	end
	model.firing=fir;
	graphics.exprs=exprs
	x.graphics=graphics
	x.model=model
	break
      end
    end
   case 'define' then
    model=scicos_model()
    model.sim=list('m_frequ',4)
    model.evtout=[1;1;1]
    model.evtin=1
    model.rpar=[]
    model.opar=list([1 1 0;1 1 1;1 3 2],1,0,0);
    model.blocktype='d'
    model.firing=[0 -1 -1]
    model.dep_ut=[%f %f]
    exprs=[sci2exp([1;2]);sci2exp([0;0])]
    gr_i=['xstringb(orig(1),orig(2),['' Multiple '';'' Frequency ''],sz(1),sz(2),''fill'');']
    x=standard_define([2.5 2],model,exprs,gr_i,'M_freq');
  end
endfunction

