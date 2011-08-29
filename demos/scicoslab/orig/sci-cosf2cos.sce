load('SCI/macros/scicos/lib');
alreadyran=%f;
needcompile=4;
super_block=%f;
pal_mode=%f;
if exists('name') then 
  [ok,scs_m]=do_load(name);
  ok=do_save(scs_m);
end

