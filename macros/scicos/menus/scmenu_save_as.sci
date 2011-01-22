function SaveAs_()
  Cmenu='Open/Set'
  [scs_m,editedx]=do_SaveAs()
  if ~super_block then edited=editedx;end
endfunction

function [scs_m,edited]=do_SaveAs()
//
// Copyright INRIA
  edited=%f;
  scs_m=scs_m;
  tit=['For saving in binary file use .cos extension,';
       'for saving in ascii file use .cosf extension'];
  // FIXME: 
  fname=xgetfile(masks=['Scicos';'*.cos*'],title='cos or cosf',save=%t)
  if fname=="" then return,end
  [path,name,ext]=splitfilepath(fname)
  select ext
   case 'cos' then
    ok=%t
   case 'cosf' then
    ok=%t
  else
    message('Only *.cos binary or cosf ascii files allowed');
    return
  end
  if ~super_block & ~pal_mode then
    //update %cpr data structure to make it coherent with last changes
    if needcompile==4 then
      %cpr=list()
    else
      [%cpr,%state0,needcompile,alreadyran,ok]=do_update(%cpr,%state0, needcompile)
      if ~ok then 
	message('do_update failed');
	return,
      end
      %cpr.state=%state0
    end
  else
    %cpr=list()
  end
  scs_m=scicos_save_in_file(scs_m,%cpr,fname,scicos_ver);
  drawtitle(scs_m.props)  // draw the new title
  edited=%f
  if pal_mode then 
    scicos_pal=update_scicos_pal(path,scs_m.props.title(1),fname),
    resume(scicos_pal)
    return;
  end
endfunction

function scs_m=scicos_save_in_file(scs_m,%cpr,fname,scicos_ver)
// open the selected file
  [path,name,ext]=splitfilepath(fname)
  
  scs_m;
  scs_m.props.title=[name,path]; // Change the title
  scs_m = do_purge(scs_m);

  if ext=='cos' then
    // save in binary mode 
    rep = execstr('save('''+fname+''',scicos_ver,scs_m,%cpr)',errcatch=%t);
    if rep==%f then
      message(['File or directory write access denied';lasterror()])
      return
    end
  else
    // save in nsp syntax mode 
    rep=execstr('F=fopen('''+ fname+''',mode = ''w'');',errcatch=%t);
    if rep==%f then
      message('Cannot open file '+fname)
      return
    end
    fprint(F,scicos_ver,as_read=%t);
    scs_m = do_purge(scs_m);
    fprint(F,scs_m,as_read=%t);
    //fprint(F,%cpr,'as_read');
    F.close[];
  end
endfunction
