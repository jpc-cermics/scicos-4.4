function [ok,tt,dep_ut]=genfunc1(tt,inp,out,nci,nco,nx,nz,nrp,type_)
// Copyright INRIA
// manages dialog to get  definition of a new scicos 
// block defined by nsp code.
// [ok,tt,dep_ut]=genfunc1(m2s([]),[6,7],[1:3],2,2,2,3,4)
  
  ni=size(inp,'*')
  no=size(out,'*')

  mac=[];ok=%f,dep_ut=[]
  if size(tt)<>7 then
    [txt1,txt0,txt2,txt3,txt4,txt5,txt6]=(' ',' ',' ',' ',' ',' ',' ')
  else
    [txt1,txt0,txt2,txt3,txt4,txt5,txt6]=tt(1:7)
  end
  dep_u=%f;dep_t=%f
  depp='t';deqq='t';

  u=emptystr(),
  for k=1:ni,u=u+'u'+string(k)+',',end
  dep=['t,','x,','z,',u,'n_evi,','rpar']

  if nx==0 then dep(2)=emptystr(),end
  if nz==0 then dep(3)=emptystr(),end
  //if nci==0 then dep(5)=emptystr(),end
  if nrp==0 then dep(6)=emptystr(),end

  //----------  block output
  if no > 0 then
    // block output instructions 
    depp=strcat(dep([1:5,6]))
    ind=(1:no)';
    w='y'+string(ind)+' (size: '+string(out(ind))+')';
    comment=['In order to define the function which computes';
	     'the block output, give nsp instructions which '
	     'calculates';
	     w;
	     'as a functions of '+depp];
    vars='y'+string(ind);
    lcheckdep=list(['u'+string(1:ni)],'t');
    [ok,txt1,mvars,ldep]=genfunc_edit(comment,txt1,vars,lcheckdep);
    if isempty(txt1) then return;end // abort in edition 
    if ok then 
      dep_u=ldep(1);dep_t=ldep(2);
    end
  else
    txt1=[]
  end

  //----------  xdot 
  if nx > 0 then
    // xdot
    depp=strcat(dep([1:4,6]))
    comment=['Define continuous states evolution';
	     ' '
	     'Enter Scilab instructions defining:';
	     'derivative of continuous state xd (size:'+string(nx)+')'
	     'as  function(s) of '+depp];
    [ok,txt0,mvars,ldep]=genfunc_edit(comment,txt0,'xd',list());
    if isempty(txt0) then return;end // abort in edition 
  else
    txt0='xd=[]'
  end
  
  //----------  x et z 
  
  if (nci>0&(nx>0|nz>0))|nz>0 then 
    // x+ z+
    depp=strcat(dep([1:5,6]))
    if isempty(txt2) then txt2=' ',end
    comment='You may define:';
    if nx>0 then
      comment.concatd['-new continuous state x (size:'+string(nx)+')'];
    end
    if nz>0 then
      comment.concatd['-new discrete state z (size:'+string(nz)+')'];
    end
    comment.concatd['at event time, as functions of '+depp];
    [ok,txt2,mvars,ldep]=genfunc_edit(comment,txt2,m2s([]),list());
    if isempty(txt2) then return;end // abort in edition 
    if ok then 
      if ~mvars.lhs.iskey['x'] then txt2=[txt2;'x=[]'];end 
      if ~mvars.lhs.iskey['z'] then txt2=[txt2;'z=[]'];end 
    end
  else
    txt2=' '
  end 

  //----------  t_evo 
    
  if nci > 0 & nco > 0 then

    depp=strcat(dep)
    if isempty(txt3) then txt3=' ',end
    comment=['Using '+depp+',you may set '
	     'vector of output time events t_evo (size:'+string(nco)+')'
	     'at event time. '];
    [ok,txt3,mvars,ldep]=genfunc_edit(comment,txt3,m2s([]),list());
    if isempty(txt3) then return;end // abort in edition 
    if ok then 
      if ~mvars.lhs.iskey['t_evo'] then txt3=[txt3;'t_evo=[]'];end 
    end
  else
    txt3=' '
  end
  
  //----------- initialization 
  
  if isempty(txt4) then txt4=' ',end
  depp=strcat(dep([2 3 6]));
  comment= ['You may do whatever needed for initialization :'
	    'File or graphic opening,'];
  if nx > 0 || nz > 0 then
    comment.concatd[['You may also re-initialize:']];
    if nx > 0 then 
      comment.concatd['- continuous state x (size:'+string(nx)+')'];
    end
    if nz>0 then
      comment.concatd['- discrete state z (size:'+string(nz)+')'];
    end
  end
  [ok,txt4,mvars,ldep]=genfunc_edit(comment,txt4,m2s([]),list());
  if isempty(txt4) then return;end // abort in edition 

  //----------- ending 
  
  if isempty(txt5) then txt5=' ',end
  depp=strcat(dep([2 3 6]))
  comment = ['You may do whatever needed to finish :'
	     'File or graphic closing,'];
  if nx > 0 || nz > 0 then
    comment.concatd[['You may also change final value of:']];
    if nx > 0 then
      comment.concatd['- continuous state x (size:'+string(nx)+')']
    end
    if nz > 0 then
      comment.concatd['- discrete state z (size:'+string(nz)+')']
    end
  end
  comment.concatd[ 'as  function(s) of '+depp];
  
  [ok,txt5,mvars,ldep]=genfunc_edit(comment,txt5,m2s([]),list());
  if isempty(txt5) then return;end // abort in edition 
  
  //----------- 
    
  if nx>0|nz>0|no>0 then
  
    depp=strcat(dep([2:4,6]));
    comment= ['You may define here functions imposing contraints';
	      'on initial inputs, states and outputs';
	      'Note: these functions may be called more than once';
	      ' ';
	      'Enter Scilab instructions defining:'];
    if nx > 0 then
      comment.concatd[  '- state x (size:'+string(nx)+')']
    end
    if nz > 0 then
      comment.concatd[ '- state z (size:'+string(nz)+')']
    end
    if no > 0 then 
      comment.concatd['- output y'+string((1:no)')+' (size : '+string(out((1:no)'))+')'];
    end    
    comment.concatd['as a function of '+depp];
    [ok,txt6,mvars,ldep]=genfunc_edit(comment,txt6,m2s([]),list());
    if isempty(txt6) then return;end // abort in edition 
    if ok then 
      yy='y'+string((1:no)');
      w=mvars.lhs.iskey[yy];
      bad=yy(~w);
      if ~isempty(bad) then txt6=[txt6;bad+'=[]'];end;
    end
  else
    txt6=[]
  end

  ok=%t
  tt=list(txt1,txt0,txt2,txt3,txt4,txt5,txt6)
  dep_ut=[dep_u dep_t]

endfunction

function [ok,txt,mvars,ldep]=genfunc_edit(comment,txt,vars,lcheckdep)
// a kind of generic function to acquire data in an editor.
// The behaviour depends on the fact that this function is 
// interactive or not.
// 1/ when interactive editsmat will enter an editor and loop
//   until a correct code is entered or a cancel is performed 
//   on cancel: ok=%t and txt is empty.
//   on correct exit: ok=%t and txt is not empty.
// 2/ when non-interactive mode is used then the entry txt 
//   is returned in txt. ok is set to %t if txt satisfy the 
//   constraint that it computes the variables in vars and 
//   set to %f on the contrary.
//
// mvars contains the result of a macrovar evaluation of txt;
// lcheck can be used to check dependencies. It is a list of string 
// matrices. For each l(i) we check if instructions in txt use variables 
// for l(i) the result is returned in ldep. 
// For example if lcheckdep=list(['u'+string(1:ni)],'t') then the
// returned value ldep=list(dep_u,dep_t) where dep_u is true is txt
// depends on one ui value and dep_t is true if txt depend on t.
  
  ok=%t; mvars=hash(0); ldep=list();
  non_interactive = exists('getvalue') && getvalue.get_fname[]=='setvalue';
  // block output instructions 
  while %t do
    // new version with editsmat 
    txt= editsmat('Genfunc1 Edition',txt,comment=catenate(comment,sep='\n'));
    if isempty(txt) then  // aborting edition
      return 
    end	
    ok=execstr(['function []=mac()';txt;'endfunction'],errcatch=%t);
    if ~ok then 
      message(['Incorrect syntax: ';
	       lasterror()]);
      if non_interactive then 
	message(['Error: set failed for genfunc1 but we are in a non ";
		 '  interactive function and thus we abort the set !']);
	ok=%f;
	return;
      end
      continue; // loop in while 
    end
    // check variables 
    mvars=macrovar(mac);
    // compute ldep 
    ldep=list();
    for i=1:length(lcheckdep)
      ldep(i)=%f;
      if or(mvars.called.iskey[lcheckdep(i)]) then ldep(i)=%t,end;
    end
    // check if the requested vars are computed 
    if ~isempty(vars) then 
      w = mvars.lhs.iskey[vars];
      if ~and(w) then 
	message('You did not define '+strcat(vars(~w),',')+' !');
	if non_interactive then 
	  message(['Error: set failed for genfunc1 but we are in a non ";
		   '  interactive function and thus we abort the set !']);
	  ok=%f;
	  return;
	end
	continue; // loop in while 
      end
    end
    // here we can quit 
    break;
  end
endfunction



