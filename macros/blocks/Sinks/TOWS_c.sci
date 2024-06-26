function [x,y,typ]=TOWS_c(job,arg1,arg2)
//19 sept 2007 - INRIA - Author : A.Layec

  function blk_draw(sz,orig,orient,label)  
    xstringb(orig(1),orig(2),"To workspace",sz(1),sz(2),"fill")
    txt=varnam;
    style=5;
    rectstr=stringbox(txt,orig(1),orig(2),0,style,1);
    fz=2*acquire("%zoom",def=1)*4;
    h=(rectstr(2,2)-rectstr(2,4))*fz;
    fnt=xget('font');
    xset('font', options.ID(1)(1), options.ID(1)(2));
    xstring(orig(1)+sz(1)/2, orig(2)-h-4,txt,posx='center',posy='up', size=fz);
    xset('font', fnt(1), fnt(2));
  endfunction
  
  x=[];y=[];typ=[]
  select job
   case 'plot' then
    varnam=string(arg1.graphics.exprs(2))
    standard_draw(arg1)
   case 'getinputs' then
    [x,y,typ]=standard_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=standard_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;model=arg1.model;
    exprs=graphics.exprs;
    while %t do
      [ok,nz,varnam,herit,exprs]=getvalue('Set Scicos buffer block',...
					  ['Size of buffer';...
		    'Scilab variable name';
		    'Inherit (no:0, yes:1)'],...
					  list('vec',1,'str',1,'vec',1),exprs);

      if ~ok then break,end;

      if ( nz<=0 ) then
        message("Size of buffer must be positive");
        ok=%f
      end
      //check for valid name variable
      r=%f;
      ierr=execstr('r=validvar(varnam)',errcatch=%t)
      if ~r then
        message(["Invalid variable name.";
                 "Please choose another variable name."]);
        ok=%f
      end

      if ok then
        [model,graphics,ok]=set_io(model,graphics,...
                                   list([-1,-2],-1),list(),...
                                   ones(1-herit,1),[])
        if herit == 1 then
          model.blocktype = 'x'
        else
          model.blocktype = 'd';
        end
        model.ipar=[nz;length(varnam);str2code(varnam)]
        graphics.exprs=exprs
        x.graphics=graphics;
        x.model=model;
        break
      end
    end

   case 'define' then
    nu     = -1
    nz     = 128
    varnam = 'A'
    herit  = 0

    model           = scicos_model();
    model.sim       = list('tows_c',4);
    model.in        = [nu];
    model.in2       = -2;
    model.intyp     = -1;
    model.out       = [];
    model.evtin     = [1];
    model.evtout    = [];
    model.rpar      = [];
    model.ipar      = [nz;length(varnam);str2code(varnam)];
    model.blocktype = 'd';
    model.firing    = [];
    model.dep_ut    = [%t %f];
    exprs=[string(nz),string(varnam),string(herit)]
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([3.5 2],model,exprs,gr_i,'TOWS_c');
  end
endfunction

