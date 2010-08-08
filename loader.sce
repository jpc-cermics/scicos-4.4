libname='scicos'
libtitle='scicos toolbox';

// macros. 

add_lib('macros',compile=%t);

// loader for src 

exec('src/loader.sce');

printf(libtitle+' loaded\n');

// path to here 
scicos_path = get_current_exec_dir()

