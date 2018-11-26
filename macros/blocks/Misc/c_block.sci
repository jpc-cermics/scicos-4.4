function [x,y,typ]=c_block(job,arg1,arg2)
// Copyright INRIA
  
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
    x=arg1
    model=arg1.model;graphics=arg1.graphics;
    label=graphics.exprs;
    while %t do
      [ok,i,o,rpar,funam,lab]=
      getvalue('Set C_block parameters',
      ['input ports sizes';
       'output port sizes';
       'System parameters vector';
       'function name'],
      list('vec',-1,'vec',-1,'vec',-1,'str',-1),label(1))
      if ~ok then break,end
      if funam==' ' then break,end
      label(1)=lab
      rpar=rpar(:)
      i=int(i(:));ni=size(i,1);
      o=int(o(:));no=size(o,1);
      tt=label(2);
      if model.sim(1)<>funam|size(model.in,'*')<>size(i,'*') |
	size(model.out,'*')<>size(o,'*') then
	tt=[]
      end
      [ok,tt]=CFORTR(funam,tt,i,o)
      if ~ok then break,end
      [model,graphics,ok]=check_io(model,graphics,i,o,[],[])
      if ok then
	model.sim(1)=funam
	model.rpar=rpar
	label(2)=tt
	x.model=model
	graphics.exprs=label
	x.graphics=graphics
	break
      end
    end
   case 'define' then
    funam='toto';
    model=scicos_model(sim=list(' ',2001),in=1,out=1,evtin=[],evtout=[],...
		       state=[],dstate=[], rpar=[], ipar=0,blocktype='c',...
		       firing=[],    dep_ut=[%t %f]);
    label=list([sci2exp(model.in);sci2exp(model.out);strcat(sci2exp(model.rpar));funam],...
	       list([]))
    gr_i=['xstringb(orig(1),orig(2),''C block'',sz(1),sz(2),''fill'');']
    x=standard_define([2 2],model,label,gr_i,'c_block')
  end
endfunction

function [ok,tt]=CFORTR(funam,tt,inp,out)
//
  ni=size(inp,'*')
  no=size(out,'*')
  if isempty(tt) then
    tt=['#include <nsp/nsp.h>';
	'#include <scicos/scicos4.h>';
	'';
	'void '+funam+'(int *flag,int *nevprt,double *t,double *xd,double *x,';
	"     int *nx,double *z,int *nz,double *tvec,';
	'     int *ntvec,double *rpar,int *nrpar,int *ipar,int *nipar']
    if ni<>0 then 
      tt.concatd['     ,'+catenate(sprintf('double *u%d,int *nu%d',(1:ni)',(1:ni)'),sep=',')];
    end
    if no<>0 then 
      tt.concatd['     ,'+catenate(sprintf('double *y%d,int *ny%d',(1:no)',(1:no)'),sep=',')];
    end
    tt($)=tt($)+')';
    tt.concatd[['{';'   /* modify below this line */'; '}']];
  end
  textmp=tt;
  head = ['Function definition in C';
	  'Here is a skeleton of the functions which you should edit'];
  comment = catenate(head,sep='\n');

  non_interactive = scicos_non_interactive();
  while %t
    txt = scicos_editsmat('Nsp code',textmp,comment=comment);
    if isempty(txt) then
      // abort in edition.
      ok = %f;
      break;
    end
    // no use to recompile if already linked and text was not changed.
    recomp= ~txt.equal[textmp] || ~c_link(funam);
    textmp=txt;
    ok=%t;
    if recomp then 
      [ok]=scicos_block_link(funam,txt,'c');
    end
    if ok then
      tt=textmp;
      break;
    elseif non_interactive then 
      // do not loop when non interactive 
      message(['Error: set failed for c_block but we are in a non ";
	       '  interactive function and thus we abort the set !']);
      break;
    end
  end
endfunction
