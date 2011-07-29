
Files=glob('*/*.sci');

bugs=m2s([]);

getvalue=setvalue;
needcompile=%f

for i=1:size(Files,'*')
  fname =Files(i);
  block =file('tail',file('root',fname));
  printf('testing block '+block+'\n');
  ok=execstr('o='+block+'(''define'');',errcatch=%t);
  if ~ok then
    bugs.concatd[fname];
    lasterror();
  end
  ok=execstr('o='+block+'(''set'',o);',errcatch=%t);
  if ~ok then 
    bugs.concatd[fname];
    lasterror();
  end
end

// second pass with bugs 
printf('Second pass: we have encountered %d pbs\n',size(bugs,'*'));

save('buged',bugs);
Files=bugs;

for i=1:size(Files,'*')
  fname =Files(i);
  block =file('tail',file('root',fname));
  ok=execstr('o='+block+'(''define'');',errcatch=%t);
  if ~ok then
    //bugs.concatd[fname];
    message(['Pb with define for '+block+'';catenate(lasterror())]);
  end
  ok=execstr('o='+block+'(''set'',o);',errcatch=%t);
  if ~ok then 
    //bugs.concatd[fname];
    message(['Pb with set for '+block+'';catenate(lasterror())]);
  end
end



