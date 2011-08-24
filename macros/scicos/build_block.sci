function [model,ok]=build_block(o)
// build the simulation function associated with the block if necessary
  ok=%t;
  model=o.model
  graphics=o.graphics
  if model.sim(1)=='scifunc' then
    // take care that model.ipar is not always a scalar.
    if model.ipar.equal[0] then
      message('A scifunc block has not been defined')
      ok=%f; return
    end
    model.sim=list(genmac(model.ipar,size(model.in,'*'),size(model.out,'*')),3)
  elseif type(model.sim,'short')=='l' then
    modsim=modulo(model.sim(2),10000)
    if int(modsim/1000)==1 then   //fortran block
      funam=model.sim(1)
      if ~c_link(funam) then
        tt=graphics.exprs(2);
        ok=scicos_block_link(funam,tt,'f')
      end
    elseif int(modsim/1000)==2 then   //C block
      [model,ok]=recur_scicos_block_link(o,'c')
//       funam=model.sim(1)
//       if ~c_link(funam) then
//         tt=graphics.exprs(2);
//         ok=scicos_block_link(funam,tt,'c')
//       end
    elseif model.sim(2)==30004 then //modelica generic file type 30004
      //funam=model.sim(1);tt=graphics.exprs(2);
      if type(graphics.exprs,'short')=='l' then //compatibility
        funam=model.sim(1);
        tt=graphics.exprs(2);
      else
        funam=model.equations.model
        tt=graphics.exprs.funtxt;
      end
      //[dirF,nameF,extF]=fileparts(funam);
      nameF=file("tail",file("rootname",funam))
      extF=file("extension",funam)
      //tarpath=pathconvert(TMPDIR+'/Modelica/',%f,%t);
      tarpath=TMPDIR+'/Modelica/'
      if (extF=='') then
	//funam=tarpath+nameF+'.mo';
	//mputl(tt,funam);
        scicos_mputl(tt,file('join',[file('split',tarpath);nameF+'.mo']));
      end
    end
  end
endfunction

function [model,ok]=recur_scicos_block_link(o,flag)
// Copyright INRIA
model=o.model;ok=%t;
if or(o.model.sim(1)==['super','csuper','asuper']) then
  obj=o.model.rpar;
  for i=1:size(obj.objs)
    o1=obj.objs(i);
    if o1.type=='Block'
      if (or(o1.model.sim(1)==['super','csuper','asuper'])) then
        [model,ok]=recur_scicos_block_link(o1,flag)
        if ~ok then return; end
      elseif type(o1.model.sim,'short')=='l' then
        if or(int(o1.model.sim(2)/1000)==[1,2]) then
          model=o1.model
          funam=o1.model.sim(1)
          if ~c_link(funam) then
            tt=o1.graphics.exprs(2)
            //mputl(tt,TMPDIR+'/'+funam+'.c')
            scicos_mputl(tt,file('join',[file('split',TMPDIR);funam+'.c']));
            ok=buildnewblock(funam,funam,'','',%scicos_libs,TMPDIR,'',%scicos_cflags)
            if ~ok then return; end
          end
        end
      end
    end
  end
  if o.model.sim(1)=='asuper' then
    model=o.graphics.exprs(3)
    funam=model.sim(1)
    if ~c_link(funam) then
      tt=o.graphics.exprs(2)
      //mputl(tt,TMPDIR+'/'+funam+'.c')
      scicos_mputl(tt,file('join',[file('split',TMPDIR);funam+'.c']));
      ok=buildnewblock(funam,funam,'','',%scicos_libs,TMPDIR,'',%scicos_cflags)
      if ~ok then return; end
    end
  end 
elseif or(int(o.model.sim(2)/1000)==[1,2]) then
  model=o.model
  funam=o.model.sim(1)
  if ~c_link(funam) then
    tt=o.graphics.exprs(2)
    //mputl(tt,TMPDIR+'/'+funam+'.c')
    scicos_mputl(tt,file('join',[file('split',TMPDIR);funam+'.c']));
    ok=buildnewblock(funam,funam,'','',%scicos_libs,TMPDIR,'',%scicos_cflags)
    if ~ok then return; end
  end
end
endfunction
