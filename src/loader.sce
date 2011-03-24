// this loader is not generated 
// we have added the global=%t option 
// because some other dynamic libraries 
// may want tu use symbols defined internally here.

libscicos_path=file('join',['.','libscicos.so']);
addinter(libscicos_path,'Scicos',global=%t);
