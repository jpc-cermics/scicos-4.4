
Files=glob('El*/*.sci');

bugs=m2s([]);

getvalue=setvalue;
needcompile=%f
function [ok,tt]=FORTR(funam,tt,i,o) ; ok=%t; endfunction
function [ok,tt,cancel]=CFORTR2(funam,tt,i,o); ok=%t;cancel=%f; endfunction
function [ok,tt]=CFORTR(funam,tt,i,o); ok=%t; endfunction
function [x,y,ok,gc]=edit_curv(x,y,job,tit,gc); ok=%t; endfunction
function [ok,tt,dep_ut]=genfunc1(tt,ni,no,nci,nco,nx,nz,nrp,type_)
  dep_ut=model.dep_ut;ok=%t; 
endfunction
function [ok,tt,cancel,libss,cflags]=CC4(funam,tt,i,o,libss,cflags)
  ok=%t,cancel=%f;
endfunction
function result= dialog(labels,valueini); result=valueini;endfunction
function [result,Quit]  = scstxtedit(valueini,v2);result=valueini,Quit=0;endfunction

global %scicos_prob;     // detect pbs in non interactive blovk evaluation
global %scicos_setvalue; // detect loop in non interactive blovk evaluation


for i=1:size(Files,'*')
  fname =Files(i);
  block =file('tail',file('root',fname));
  if part(block,1)== '_' then continue;end 
  printf('testing block '+block+'\n');
  ok=execstr('o='+block+'(''define'');',errcatch=%t);
  if ~ok then
    bugs.concatd[fname];
    lasterror();
    continue;
  end
  %scicos_prob=%f;
  %scicos_setvalue=[];
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
  if part(block,1)== '_' then continue;end 
  ok=execstr('o='+block+'(''define'');',errcatch=%t);
  if ~ok then
    //bugs.concatd[fname];
    message(['Pb with define for '+block+'';catenate(lasterror())]);
  end	  
  %scicos_prob=%f;
  %scicos_setvalue=[];
  ok=execstr('o='+block+'(''set'',o);',errcatch=%t);
  if ~ok then 
    //bugs.concatd[fname];
    message(['Pb with set for '+block+'';catenate(lasterror())]);
  end
end



