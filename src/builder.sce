
// we just have to run the makefile 
// since it was hand writen

if %win32 then 
  ilib_compile('libscicos','Makefile',[])
else
  system('make -s -j 8');
end


