exec ../../loader.sce 

function upgrade(fname)
  ext = file('extension',fname)
  [ok, scs_m, %cpr, edited] = do_load(fname);
  if ~ok then return;end 
  scs_m=do_upgrade_gri(scs_m);
  //[%cpr,ok]=do_compile(scs_m);
  //if ~ok then %cpr=list();end 
  scicos_save_in_file(fname,scs_m,%cpr);
endfunction

//Files=[glob('*.cos');glob('*.cosf')];
Files=[glob('*.cosf')];

for i=1:size(Files,'*')
  upgrade(Files(i))
end


