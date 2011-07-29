// resave all the cos file in cosf format 
// --------------------------------------

exec('SCI/toolboxes/scicos-4.4/loader.sce');

// import cos file from scilab 

function save_to_nsp(fname)
// make an import and save to nsp 
  ext = file('extension',fname);
  if ext<>'.cos' then 
    error('Expecting a cos file !\n");
    return;
  end
  [ok,scs_m,%cpr,edited]=do_scilab_import(fname,'diagram');
  [scs_m,%cpr,needcompile,ok]=do_eval(scs_m,%cpr);
  [%cpr,ok]=do_compile(scs_m);
  fname1 = file('root',fname)+'_nsp.cos';
  scicos_save_in_file(scs_m,%cpr,fname1,scs_m.version);
endfunction

function save_to_cosf(fname)
// load a cos file and save to cosf 
  ext = file('extension',fname)
  if ext<>'.cos' then 
    error('Expecting a cos file !\n");
    return;
  end
  [ok,scs_m,%cpr,edited]=do_load(fname,'diagram');
  [scs_m,%cpr,needcompile,ok]=do_eval(scs_m,%cpr);
  [%cpr,ok]=do_compile(scs_m);
  scicos_save_in_file(scs_m,%cpr,fname+'f',scs_m.version);
  ok = exec(fname+'f',errcatch=%t);
  if ~ok then 
    x_message('exec of saved file'+fname+'f fails');
  end
endfunction

Files=glob('*.cos');

for i=1:size(Files,'*')
  save_to_cosf(Files(i))
end

