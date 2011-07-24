// resave all the cos file in cosf format 
// --------------------------------------

exec('SCI/toolboxes/scicos-4.4/loader.sce');

function save_to_cosf(fname)
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

function resave_to_cos(fname)
  ext = file('extension',fname)
  if ext<>'.cos' then 
    error('Expecting a cos file !\n");
    return;
  end
  load(fname);
  [%cpr,ok]=do_compile(scs_m);
  scicos_save_in_file(scs_m,%cpr,fname,scicos_ver);
endfunction

Files=glob('*.cos');

for i=1:size(Files,'*')
  save_to_cosf(Files(i))
end


