function ScilabExportAs_()
// Export in a scilab binary mode 
// This is a bit dangerous since the extensions
// used by scilab and nsp are the same.
// But we can detect the binary contents.
// 
  Cmenu=''
  [scs_m,editedx]=do_ScilabExportAs()
  if ~super_block then edited=editedx;end
endfunction

function [scs_m,edited]=do_ScilabExportAs()
// Copyright Enpc 
// modifed from SaveAs (Inria).

  function scicos_export_in_file(scs_m,%cpr,fname,scicos_ver)
  // open the selected file
  [path,name,ext]=splitfilepath(fname)
  scs_m.props.title=[name,path]; // Change the title
  scs_m = do_purge(scs_m);
  if ext=='cos' then
    // save in binary mode 
    // I do not export %cpr
    rep = execstr('sci_save('''+fname+''',scicos_ver=scicos_ver,scs_m=scs_m)',errcatch=%t);
    if rep==%f then
      message(['File or directory write access denied';lasterror()])
      return
    else
      message(['Remember to perform Eval in scilab']);
    end
  end
  endfunction
  
  edited=%f;
  scs_m=scs_m;
  tit=['Export in binary code only (*.cos extension)'];
  // FIXME: 
  fname=xgetfile(masks=['Scicos';'*.cos'],title='cos',save=%t)
  if fname=="" then return,end
  [path,name,ext]=splitfilepath(fname)
  select ext
   case 'cos' then
    ok=%t
  else
    message('Only *.cos binary files allowed');
    return
  end

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
  
  // do not change the name when exporting 
  // since the exported schema should not be overwriten 
  // by a save
  scicos_export_in_file(scs_m,%cpr,fname,scicos_ver);
  edited=%f
endfunction

