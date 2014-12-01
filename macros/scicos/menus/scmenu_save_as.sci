function scmenu_save_as()
  Cmenu=''
  if super_block then
    r = x_choose(['Diagram';'Super Block'],..
                 ['Save content of the Super Block or'
                  'the complete diagram?'],'Cancel')
    if r==0 then 
      return
    end
    if r==1 then
      Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
                       'Cmenu='"Save As'";%scicos_navig=[]';
                       '%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1']
      return
    end
  end
  [ok,scs_m]=do_SaveAs(scs_m)
  if ok&~super_block then edited=%f;end
endfunction

function [ok,scs_m]=do_SaveAs(scs_m)
//
// Copyright INRIA
  global %scicos_open_saveas_path ;
  global %scicos_ext
  
  if size(scs_m.props.title,'*')<2 then
    default_name=''
  else
    if ~%scicos_ext.equal['cos'] && ~%scicos_ext.equal['cosf'] && ~%scicos_ext.equal['xml'] then
      ext='cos' //TODO
    else
      ext=%scicos_ext
    end
    default_name=scs_m.props.title(1)+'.'+ext
  end
  if isempty(%scicos_open_saveas_path) then %scicos_open_saveas_path='', end
  tit=['For saving in binary file use .cos extension,';
       'for saving in ascii file use .cosf extension'];
  if %scicos_ext.equal['xml'] then
    masks=['Scicos xml','Scicos file';'*.xml','*.cos*']
  else
    masks=['Scicos file','Scicos xml';'*.cos*','*.xml']
  end
  // FIXME: 
  while %t
    fname=xgetfile(masks=masks,save=%t,dir=%scicos_open_saveas_path,file=default_name)
    if fname=="" then
      ok=%f
      return
    else
      [path,name,ext]=splitfilepath(fname)
      %scicos_open_saveas_path=path
      select ext
        case 'cos' then
          ok=%t
        case 'cosf' then
          ok=%t
        case 'xml' then
          ok=%t
       else
         ok=%f
         message('Only *.cos binary, cosf ascii, xml files allowed');
      end
      if ok then
        if file('exists',fname) then
          r=x_message(['The file '''+name+'.'+ext+''' already exists.';
                       'Do you really want to overwrite it ?'],...
                      ['gtk-cancel';'gtk-ok']);
          if r==0||r==1 then
            ok=%f
          else
            break
          end
        else
          break
        end
      end
    end
  end
  if ~super_block & ~pal_mode then
    //update %cpr data structure to make it coherent with last changes
    if needcompile==4 then
      %cpr=list()
    else
      [%cpr,%state0,needcompile,alreadyran,ok]=do_update(%cpr,%state0, needcompile)
      if ~ok then 
        message('do_update failed');
        return
      end
      %cpr.state=%state0
    end
  else
    %cpr=list()
  end
  scs_m_rec=scs_m
  [ok,scs_m]=scicos_save_in_file(fname,scs_m,%cpr,scicos_ver);
  scs_m_rec.props=scs_m.props
  scs_m=scs_m_rec
  clear scs_m_rec
  drawtitle(scs_m.props)  // draw the new title
  if pal_mode then 
    scicos_pal=update_scicos_pal(path,scs_m.props.title(1),fname),
    resume(scicos_pal)
    return;
  end
endfunction

function [ok,scs_m]=scicos_save_in_file(fname,scs_m,%cpr,scicos_ver)
// open the selected file
  ok=%t
  if nargin <= 2 then %cpr=list();end
  if nargin <= 3 then scicos_ver=get_scicos_version();end 
  [path,name,ext]=splitfilepath(fname)
  scs_m = scs_m;
  scs_m.props.title=[name,path]; // Change the title
  // do not purge is %cpr is saved 
  if isempty(%cpr) then   scs_m=do_purge(scs_m);end 
  scs_m=scs_m_remove_gr(scs_m);
  if ext=='cos' then
    // save in binary mode
    rep = execstr('save(fname,scicos_ver,scs_m,%cpr)',errcatch=%t);
    if rep==%f then
      message(['File or directory write access denied';lasterror()])
      ok=%f
      return
    end
  elseif ext=='xml' then
    // save in xml syntax mode
    rep=execstr('F=fopen(fname,mode=''w'');',errcatch=%t);
    if rep==%f then
      message('Cannot open file '+fname)
      ok=%f
      return
    end
    [ok,t]=cos2xml(scs_m,'',atomic=%f);
    if ~ok then 
      message('Error in xml format.');
    else
      F.put_smatrix[t];
    end
    F.close[];
  else
    // save in nsp syntax mode
    rep=execstr('F=fopen(fname,mode=''w'');',errcatch=%t);
    if rep==%f then
      message('Cannot open file '+fname)
      return
    end
    fprint(F,scicos_ver,as_read=%t);
    if %t then 
      fprint(F,scs_m,as_read=%t);
    else
      // A much more compact way to save 
      txt=scicos_schema2smat(scs_m,name='scs_m',indent=4);
      F.put_smatrix[txt];
      F.put_smatrix[['scs_m=do_eval(scs_m)']];
    end
    //fprint(F,%cpr,'as_read');
    F.close[];
  end
  //update default file extension
  global %scicos_ext
  %scicos_ext=ext
endfunction
