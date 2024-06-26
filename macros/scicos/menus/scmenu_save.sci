function scmenu_save()
  Cmenu=''
  %pt=[]
  if super_block then
    // save a super block or navigate to top 
    r=x_choose(['Diagram';'Super Block'],..
               ['Save content of the Super Block or'
                'the complete diagram?'],'Cancel')
    if r==0 then 
      return
    end
    if r==1 then
      Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
                       'Cmenu='"Save'";%scicos_navig=[]';
                       '%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1']
      return
    end
  end;
  [ok,scs_m_new]=do_save(scs_m)
  scs_m.props=scs_m_new.props
  clear scs_m_new;
  drawtitle(scs_m.props.title(1))  // draw the new title if any
  if ok&~super_block then edited=%f,end
endfunction

function [ok,scs_m]=do_save(scs_m,filenamepath)
  // saves scicos data structures scs_m and %cpr on a binary file
  // Copyright INRIA
  // select extension
  global(%scicos_ext='cos'); //default file extension
  ext=%scicos_ext;
  if ~ext.equal['cos'] && ~ext.equal['cosf'] && ~ext.equal['xml'] then
    ext='cos';
  end

  // we need fname (full name)
  // path and ext;

  if nargin <= 1 then
    name=scs_m.props.title(1);
    if length(file('extension',name))==0 then
      name = name +'.' + ext
    end
    if size(scs_m.props.title,'*') < 2 then
      path=m2s([]);
    else
      path=scs_m.props.title(2);
    end
    fname = path+name;
  else
    fname = filenamepath;
    [path,name,ext]=splitfilepath(fname);
  end

  if ext <> 'cos' && ext <> 'cosf' then
    message(['Error: do_save second argument should have a cos suffix']);
    ok=%f;
    return;
  end

  super_block = acquire("super_block",def=%f);
  needcompile = acquire("needcompile", def=4);
  alreadyran= acquire("alreadyran", def = %f);
  scicos_ver =acquire("scicos_ver", def="")

  if scicos_ver == "" then find_scicos_version(scs_m);end

  // no path found or given
  if isempty(path) then
    [ok,scs_m]=do_SaveAs(scs_m)
    return
  end
  //open file
  if ~super_block then
    //update %cpr data structure to make it coherent with last changes
    if needcompile==4 then
      %cpr=list()
    else
      [%cpr,%state0,needcompile,alreadyran,ok]=do_update(%cpr,%state0,needcompile)
      if ~ok then return,end
      %cpr.state=%state0
    end
  else
    %cpr=list()
  end

  // store dimensions in the diagram 
  if %t then 
    scs_m.props.wpar = get_curwpar();
  end
  // jpc: test if directory is writable
  if file('writable',path) == %f then
    message(['Directory write access denied '''+path+'''']);  // ;lasterror()])
    ok=%f
    return
  end
  if nargin>1 then
    // remove gr fields
    scs_m=scs_m_remove_gr(scs_m);
    // save current diagram
    if ~execstr('save(fname,scicos_ver,scs_m,%cpr);',errcatch=%t) then
      message(['Save error:'; catenate(lasterror())]);
      ok=%f;
      return
    end
  else
    [ok,scs_m]=scicos_save_in_file(fname,scs_m,%cpr,scicos_ver);
  end
  ok=%t
endfunction
