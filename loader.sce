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
execstr('function [p]=get_scicospath(),p=""'+scicos_path+'"",endfunction');

if ~new_graphics() then 
  switch_graphics();
end

scicos_library_initialize();
