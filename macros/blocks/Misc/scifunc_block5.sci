function [x,y,typ]=scifunc_block5(job,arg1,arg2)
  x=[];
  y=[];
  typ=[];
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
    x=arg1
    model=arg1.model;
    graphics=arg1.graphics;
    label=graphics.exprs;
    gv_titles= ['Simulation function name';
		'Is block implicit? (y,n)';
		'Input ports sizes';
		'Input ports type';
		'Output port sizes';
		'Output ports type';
		'Input event ports sizes';
		'Output events ports sizes';
		'Initial continuous state';
		'Initial discrete state';
		'Initial object state';
		'Real parameters vector';
		'Integer parameters vector';
		'Object parameters list';
		'Number of modes';
		'Number of zero crossings';
		'Initial firing vector (<0 for no firing)';
		'Direct feedthrough (y or n)';
		'Time dependence (y or n)'];
    gv_types=list('str',1,'str',1,'mat',[-1 2],'vec',-1,'mat',[-1 2],...
		  'vec',-1,'vec',-1,'vec',-1,'vec',-1,'vec',-1,'lis',-1,...
		  'vec',-1,'vec',-1,'lis',-1,'vec',1,'vec',1,'vec','sum(%8)',..
		  'str',1,'str',1);
    
    if ~exists('needcompile') then needcompile=0;
    else needcompile=needcompile;end
        
    while %t do
      [ok,junction_name,impli,in,it,out,ot,ci,co,xx,z,oz,...
       rpar,ipar,opar,nmode,nzcr,auto0,depu,dept,lab]=..
	  getvalue('Set Scilab block parameters',..
		   gv_titles,gv_types,label(1));
      if ~ok then break,end
      label(1)=lab
      junction_name=stripblanks(junction_name)
      xx=xx(:);z=z(:);rpar=rpar(:);ipar=int(ipar(:));
      nx=prod(size(xx,'*'))
      ci=int(ci(:));
      co=int(co(:));
      if part(impli,1)=='y' then
	funtyp=10005
        if ~isempty(xx) then
          if int(nx/2)*2<>nx then
            message(['Warning for implicit block initial derivative state should also be defined.';
                     'Please check number of Initial continuous state.']);
            ok=%f;
          end
        end
      else
	funtyp=5
      end
      if ~isempty([ci;co]) then
	if max([ci;co])>1 then message('vector event links not supported');ok=%f;end
      end
      if type(opar,'short')<>'l' then message('object parameter must be a list');ok=%f;end
      if type(oz,'short')<>'l' then message('discrete object state must be a list');ok=%f;end
      if ~ok then continue;end
      depu=stripblanks(depu);if part(depu,1)=='y' then depu=%t; else depu=%f;end
      dept=stripblanks(dept);if part(dept,1)=='y' then dept=%t; else dept=%f;end
      dep_ut=[depu dept];
      [model,graphics,ok]=set_io(model,graphics,list(in,it),list(out,ot),ci,co)
      if ~ok then continue;end 
      nz=prod(size(z,'*'))+length(oz)
      ni=prod(size(in,'*'))
      no=prod(size(out,'*'))
      nie=prod(size(ci,'*'))
      noe=prod(size(co,'*'))
      [ok,func_txt]=genfunc5(junction_name,label(2),ni,no,nie,noe,nx,nz,nzcr)
      if ~ok then break;end // we have made a cancel in genfunc5 
      if ~func_txt.equal[label(2)] then needcompile=4, end
      model.sim=list('scifunc',funtyp);
      model.state=xx
      model.dstate=z
      model.odstate=oz
      model.rpar=rpar
      model.ipar=ipar
      model.opar=opar
      model.firing=auto0
      model.nzcross=nzcr
      model.nmode=nmode
      model.dep_ut=dep_ut
      arg1.model=model
      label(2)=func_txt
      graphics.exprs=label
      arg1.graphics=graphics
      x=arg1
      break
    end
    resume(needcompile)
   case 'define' then
    model=scicos_model()
    junction_name='sciblk';
    funtyp=5;
    model.sim=list('scifunc',funtyp)

    model.in=1
    model.in2=1
    model.intyp=1
    model.out=1
    model.out2=1
    model.outtyp=1
    model.dep_ut=[%t %f]
    label=list([junction_name;'n';
		sci2exp([model.in model.in2]);
		sci2exp(model.intyp);
		sci2exp([model.out model.out2])
		sci2exp(model.outtyp);
		sci2exp(model.evtin);
		sci2exp(model.evtout);
		sci2exp(model.state);
		sci2exp(model.dstate);
		sci2exp(model.odstate);
		sci2exp(model.rpar);
		sci2exp(model.ipar);
		sci2exp(model.opar);
		sci2exp(model.nmode);
		sci2exp(model.nzcross);
		sci2exp(model.firing);
		'y';
		'n'],...
	       []);
    gr_i=['xstringb(orig(1),orig(2),''SciBlk'',sz(1),sz(2),''fill'');']
    x=standard_define([2 2],model,label,gr_i,'scifunc_block5');
  end
endfunction

function [ok,txt_out]=genfunc5(name,txt_in,ni,no,nie,noe,nx,nz,nzcr)
//
  ok=%t
  txt_out=txt_in
  if isempty(txt_in) then
    textmp=['function [blk] = '+name+'(blk,flag)'
            ''
            '  //initialisation'
            '  if flag==4 then'
            '']

    if no<>0 then
      textmp.concatd[
	  ['  //output fixed point'
	   '  elseif flag==6 then'
	   ''
	   '  //output computation'
	   '  elseif flag==1 then'
	   '']];
    end
    if nx<>0 then
      textmp.concatd[
	  ['  //state derivative computation'
	   '  elseif flag==0 then'
	   '']];
    end

    if nz<>0 then
      textmp.concatd[
	  ['  //discrete state computation'
	   '  elseif flag==2 then'
	   '']];
    end
    if noe<>0 then
      textmp.concatd[
	  ['  //out event date computation'
	   '  elseif flag==3 then'
	   '']]
    end
    if nzcr<>0 then
      textmp.concatd[
	  ['  //zero crossing computation'
	   '  elseif flag==9 then'
	   '']]
    end
    textmp.concatd[
	['  //finish'
	 '  elseif flag==5 then'
	 ''
	 '  end'
	 ''
	 'endfunction']]
  else
    textmp=txt_in
  end
  head = ['Function definition in scilab language.';
	  'Here is a skeleton of the function which';
	  ' you should edit.'];
  ptxtedit=scicos_txtedit(clos = 0,...
			  typ  = "Scifunc5",...
			  head = head);
  comment = catenate(head,sep='\n');
  while %t 
    //[txt,Quit] = scstxtedit(textmp,ptxtedit);
    txt = scicos_editsmat('Nsp code',textmp,comment=comment);
    if isempty(txt) then
      ok = %f;
      break;
    end // abort in edition.
//    if Quit then
//      // a cancel in edition
//      ok = %f;
//      break;
//    end
    fname=file('join',[getenv('NSP_TMPDIR');'scifunc5_tmp.sci']);
    scicos_mputl(txt,fname);
    execstr(sprintf('clear(''%s'');',name));
    ok=exec(fname,errcatch=%t);
    if ~ok then 
      message(['Error: Incorrect syntax in your function definition !';
	       catenate(lasterror())]);
      continue;
    end
    mess=['Please check your scilab instructions.';
	  'Function '+name+' should be defined as follows:';
	  '  function [blk_out]='+name+'(blk_in,flag)';
	  '   ...'
	  '  endfunction'];
    if ~exists(name) then
      message([' Undefined function '''+name+'''.';
	       mess])
      continue;
    end
    execstr('f_name='+name);
    if type(f_name,'short')<>'pl' then 
      message([' '''+name+''' is not a nsp coded function.';
	       mess]);
      continue;
    end
    vars= macrovar(f_name);
    if size(vars.in,'*')<>2 
      message([' Number of input arguments is incorrect.';
	       mess]);
      continue;
    end
    if size(vars.out,'*')<>1
      message([' Number of output argument is incorrect.';
	       mess])
      continue;
    end
    // ok we can quit 
    txt_out=txt
    ok = %t;
    break;
  end
endfunction
