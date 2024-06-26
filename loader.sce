libname='scicos'
libtitle='scicos toolbox';

// macros. 
add_lib('macros',compile=%t);

// loader for src 
exec('src/loader.sce');

printf(libtitle+' loaded\n');
// path to here
TMPDIR=getenv('NSP_TMPDIR')
SCI=getenv('NSP');
scicos_path = get_current_exec_dir()
if file('pathtype',scicos_path) == 'relative' then 
  scicos_path= file('join',[getcwd(),scicos_path]);
end
// we want to be able to access to scicospath event after a clear 
setenv('SCICOSPATH',scicos_path);

if ~new_graphics() then 
  switch_graphics();
end

scicos_library_initialize();

clear libname;
clear libtitle;
clear scicos_path;
