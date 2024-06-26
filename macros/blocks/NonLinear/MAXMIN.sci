function [x,y,typ]=MAXMIN(job,arg1,arg2)
  x=[];y=[];typ=[]
  select job
   case 'plot' then
    if arg1.model.ipar==1 then 
      CCC='MIN'
    elseif arg1.model.ipar==2
      CCC='MAX'
    else
      CCC='Min/Max'
    end
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
      [ok,mm,nin,zcr,exprs]=..
	  getvalue('Set Max/Min block parameters',..
		   ['Min (1) or Max (2) ';'Number of input vectors (1 or 2)';'Zero-crossing (1: yes, 0;no)'],..
		   list('vec',1,'vec',1,'vec',1),exprs)
      if ~ok then break,end
      if zcr<>0 then zcr=-1, end
      if mm<>1 then mm=2,end
      if nin<>1 & nin<>2 then 
	message('Wrong number of inputs, only 1 and 2 allowed')
	ok=%f
      end
      if ok then
	if nin==1 then
	  [model,graphics,ok]=check_io(model,graphics,-1,1,[],[])
	else
	  [model,graphics,ok]=check_io(model,graphics,[-1,-1],-1,[],[])
	end
      end 
      if ok then
	model.nzcross=zcr;
	if nin==1 then
	  model.nmode=abs(zcr);
	else
	  model.nmode=zcr
	end
	model.ipar=mm;
	graphics.exprs=exprs;
	x.graphics=graphics;x.model=model;
	break
      end
    end
   case 'define' then
    model=scicos_model()
    model.sim=list('minmax',4)
    model.out=1
    model.in=-1
    model.blocktype='c'
    model.dep_ut=[%t %f]
    model.ipar=0;
    exprs=[string([2,1,1]')]
    gr_i=['txt=[CCC];';
	  'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'')']
    
    x=standard_define([2 2],model,exprs,gr_i,'MAXMIN');
  end
endfunction
