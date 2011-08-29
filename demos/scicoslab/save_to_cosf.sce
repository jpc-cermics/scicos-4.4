
exec('SCI/toolboxes/scicos-4.4/loader.sce');

// import cos file from scilab 

function save_to_nsp(fname)
// make an import and save to nsp 
  ext = file('extension',fname);
  if ext<>'.cos' then 
    error('Expecting a cos file !\n");
    return;
  end
  message('convert file '+fname);
  [ok,scs_m,%cpr,edited]=do_scicoslab_import(fname,'diagram');
  [sc,cpr,needcompile,ok]=do_eval(scs_m,%cpr);
  if ok then scs_m=sc;end
  [%cpr,ok]=do_compile(scs_m);
  fname1 = file('tail',fname);
  scicos_save_in_file(scs_m,%cpr,fname1,scs_m.version);
endfunction
