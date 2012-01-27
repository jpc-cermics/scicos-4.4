
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
  scicos_save_in_file(fname1,scs_m,%cpr,scs_m.version);
endfunction

function save_to_cosf() 
  
  function save_diag_to_cosf(fname)
    ext = file('extension',fname)
    if ext<>'.cos' then 
      error('Expecting a cos file !\n");
      return;
    end
    printf("saving %s to cosf ...",fname);
    load(fname);
    //if ~exists('%cpr') then [%cpr,ok]=do_compile(scs_m);end 
    [%cpr,ok]=do_compile(scs_m);
    scicos_save_in_file(fname+'f',scs_m,%cpr);
    printf("saved\n");
    ok = exec(fname+'f',errcatch=%t);
    if ~ok then 
      x_message('exec of saved file'+fname+'f fails');
    end
  endfunction

  Files=glob('*.cos');

  for i=1:size(Files,'*')
    save_diag_to_cosf(Files(i))
  end
endfunction

