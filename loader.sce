libname='scicos'
libtitle='scicos toolbox';

// macros. 

add_lib('macros',compile=%t);

// loader for src 

exec('src/loader.sce');

printf(libtitle+' loaded\n');

// path to here 
scicos_path = get_current_exec_dir()
if file('pathtype',scicos_path) == 'relative' then 
  scicos_path= file('join',[getcwd(),scicos_path]);
end

if ~new_graphics() then 
  switch_graphics();
end
