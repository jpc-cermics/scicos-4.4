function [x,y,typ]=TEXT_f(job,arg1,arg2)
// Copyright INRIA
//** 22-23 Aug 2006: some carefull adjustements for the fonts
//**                 inside the new graphics datastructure  
  x=[]; y=[]; typ=[];
  select job
   case 'plot' then //normal  position
    // C=arg1.graphics.exprs;
    //standard_draw(arg1)
    graphics = arg1.graphics; 
    model    = arg1.model;
    if isempty(model.rpar) then
      //compatibility
      model.rpar=graphics.exprs(1)
    end 
    // Note that here xstringl can be wrong 
    // rect = stringbox(model.rpar, graphics.orig(1), graphics.orig(2));
    // rect=xstringl(graphics.orig(1), graphics.orig(2),model.rpar);
    // compute the requested rectangle
    //w=rect(3) * %zoom;
    //h=rect(4) * %zoom/1.4 * 1.2;
    sf = model.ipar(2)*%zoom*10;
    xstring(graphics.orig(1), graphics.orig(2),model.rpar,size=sf);
    // xrect(graphics.orig(1), graphics.orig(2),w*100,h*100);
   case 'getinputs' then
   case 'getoutputs' then
   case 'getorigin' then
    [x,y] = standard_origin(arg1)
   case 'set' then
    x = arg1 ;
    graphics = arg1.graphics ;
    orig  = graphics.orig  ;
    exprs = graphics.exprs ;
    model = arg1.model ;
    if size(exprs,'*')==1 then
      // compatibility
      exprs = [exprs;'3';'1']
    end 

    non_interactive = exists('getvalue') && getvalue.get_fname[]=='setvalue';
    
    while %t do
      [ok,txt,font,siz,exprs] = getvalue('Set Text block parameters',...
					 ['Text';'Font number';'Font size'],...
					 list('str',-1,'vec',1,'vec',1),exprs)
      if ~ok then break,end 
      if font<=0|font>6 then
	message('Font number must be greater than 0 and less than 7')
	ok=%f
      end
      if siz < 0 then
	message('Font size must be positive')
	ok=%f
      end
      if ok then
	graphics.exprs = exprs
	// 	if o.iskey['gr'] then 
	// 	  T=o.gr.children(1);
	// 	  T.text=exprs(1);
	// 	  o.gr.invalidate[];
	// 	end
	// here xstringl will be correct 
	// or sz could be obtained by getting the 
	// bounds of the compound. 
	if ~non_interactive  then 
	  r = xstringl(0,0,exprs(1))// evstr(exprs(2)),evstr(exprs(3)));
	  sz = r(3:4); 
	  graphics.sz = sz;
	end
	x.graphics  = graphics  ;
	ipar        = [font;siz]
	model.rpar  = txt   ;
	model.ipar  = ipar  ;
	x.model     = model ;
	break
      end
    end // of while 
   case 'define' then
    font = 2 ;
    siz  = 1 ;
    model = scicos_model()
    model.sim = 'text'
    model.rpar= 'Text'
    model.ipar=[font;siz]
    exprs = ['Text';string(font); string(siz)]
    graphics = scicos_graphics();
    graphics.orig = [0,0];
    graphics.sz =[2 1];
    graphics.exprs = exprs
    x = mlist(['Text','graphics','model','void','gui'],graphics,model,' ','TEXT_f')
  end
endfunction
