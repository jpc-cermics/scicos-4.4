function cmd=get_errorcmd(path,scs_m_in,title_err,mess_err)
// get_errorcmd : return a Scicos_commands strings
// to select/hilite and display error messages for block
// defined by his main scs_m path.
// If the block is included in a super block, the editor
// will open the correspondig windows by the use of the
// scicos global variable %diagram_path_objective and
// %scicos_navig.
//
// exemple of use :
//       path=corinv(kfun);
//       global Scicos_commands;
//       Scicos_commands=get_errorcmd(path,'my Title error','error message');
//
// inputs : path : the path of the object which have
//                 generated an error in a scs_m
//
//          scs_m_in : a scicos diagram data structure
//                 (if any. if not scs_m is semi global)
//
//          title_err : the title of the error box message
//                      (if any)
//
//          mess_err : the message of the error box message
//                      (if any)
//
// nb : the string message will be formated as this :
//      str_err=[title;
//               specific message for type of block;
//               mess_err]
//
// output : cmd  : the Scicos_commands strings
//
//Copyright INRIA
  // first generate an empty cmd
  cmd=m2s([])
  // generte empty spec_err
  spec_err=m2s([])
  // check number of rhs arg
  if (nargin == 1) then
     title_err=m2s([]);
     mess_err=m2s([]);
  elseif (nargin == 2) then
    if type(scs_m_in,'short')=='h' then
      scs_m=scs_m_in
      mess_err=m2s([]);
    elseif type(scs_m_in,'short')=='s' then
      title_err=scs_m_in
      mess_err=m2s([]);
    end
  elseif (nargin == 3) then
    if type(scs_m_in,'short')=='h' then
      scs_m=scs_m_in
    elseif type(scs_m_in,'short')=='s' then
      mess_err=title_err
      title_err=scs_m_in
    end
  end
  
  // convert mess_err to something that can be inserted 
  // in a command
  // remove the last \n
  // pause xxx
  mess1_err=mess_err;
  if ~isempty(mess1_err) then 
    mess1_err($)=strsubst(mess1_err($),'\n','');
  end
  // take care that string must be as_read 
  // XXX: should be improved with a function
  mess1_err=strsubst(mess1_err,'''','''''');
  mess1_err=strsubst(mess1_err,'""','""""');
  mess1_err= catenate(mess1_err);
  mess1_err=''''+strsubst(mess1_err,'\n',''';''')+''';';
  
  if type(path,'short')=='l' then
    // ---- modelica block
    spec_err='The modelica block returns the error :';
    // create cmd
    cmd=sprintf('message([''%s'';''%s'';%s]);',title_err,spec_err,mess1_err);
    return;
  end
  // all other type of blocks
  obj_path=path(1:$-1)
  spec_err='block'
  blk=path($)
  scs_m_n=scs_m;
  // check if we can open a window
  // Note: we can improve that piece of code
  //       to also returns the name of the comput. func.
  for i=1:size(path,'*')
    if scs_m_n.objs(path(i)).model.sim.equal['super'] then
      scs_m_n=scs_m_n.objs(path(i)).model.rpar;
    elseif scs_m_n.objs(path(i)).model.sim.equal['csuper'] then
      obj_path=path(1:i-1);
      blk=path(i);
      spec_err='csuper block'
      break;
    end
  end

  if spec_err=='csuper block' then
    // update spec_err
    spec_err='The hilited '+spec_err+' returns the error :';
    //
    xset('window',curwin)
    // call bad_connection
    bad_connection(path,...
		   [title_err;spec_err;mess_err],0,1,0,-1,0,1)
    // create cmd
    cmd=['%diagram_path_objective='+sci2exp(obj_path)+';%scicos_navig=1;'
	 'hilite_obj('+string(blk)+');'+...
	 'unhilite_obj('+string(blk)+');']
  else
    // update spec_err
    spec_err='The hilited '+spec_err+' returns the error :';
    // create cmd
    cmd1=sprintf('message([''%s'';''%s'';%s]);',title_err,spec_err,mess1_err);
    cmd=['%diagram_path_objective='+sci2exp(obj_path)+';%scicos_navig=1;'
	 'hilite_obj('+string(blk)+');'+cmd1+'unhilite_obj('+string(blk)+');']
  end
endfunction
