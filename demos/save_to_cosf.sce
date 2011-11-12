// resave all the cos file in cosf format 
// --------------------------------------

exec ../loader.sce 

function save_to_cosf(fname)
  ext = file('extension',fname)
  if ext<>'.cos' then 
    error('Expecting a cos file !\n");
    return;
  end
  load(fname);
  //if ~exists('%cpr') then [%cpr,ok]=do_compile(scs_m);end 
  [%cpr,ok]=do_compile(scs_m);
  scicos_save_in_file(fname+'f',scs_m,%cpr);
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
  scicos_save_in_file(fname,scs_m,%cpr);
endfunction

Files=glob('*.cos');

for i=1:size(Files,'*')
  save_to_cosf(Files(i))
end


