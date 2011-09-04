function [ok,mac,txt]=genfunc(txt)
// Copyright INRIA
  if nargin < 1 then txt=m2s([]) ,end
  if isempty(txt) then txt=['//ex: y=sin(u)'];end 
  mac=[]
  cm=catenate(['Enter Scilab instructions defining'
	       'y as a function of u'],sep='\n');
  while %t do
    txt=scicos_editsmat('Set Function Block',txt,comment=cm);
    if isempty(txt) then ok=%f,return,end
    // check if txt defines y from u
    cmd=['function []=mac()';txt;'endfunction'];
    ok=execstr(cmd,errcatch=%t);
    if ~ok then 
      lasterror();
      return;
    end
    vars=macrovar(mac);
    if ~vars.lhs.iskey['y'] then 
      continue;
    end
    if ~vars.called.iskey['u'] then 
      continue;
    end
    break;
  end
  ok=%t
  cmd=['function [%_1,%_2]=mac(%_model,%_x,%_z,u,%_clock,%_flag,%_rpar,%_ipar)',
       '%_1=[];%_2=[];';
       'select %_flag';
       'case 1 then';
       txt
       '%_1=y';
       'case -1 then ';
       '  %_model=list(%_model(1),1,1,[],[],[],[],[],[],''c'',%f,[%t %f])';
       '  %_1=list(%_model,'' '')';
       'case -2 then ';
       '  txt=%_model.ipar';
       '  [ok,mac,txt]=genfunc(txt)';
       '  if ok then '
       '    %_model.sim=mac'
       '    %_model.ipar=txt'
       '    %_1=list(model,%_x)'
       '  end'
       'end'
       'endfunction'];
  ok=execstr(cmd,errcatch=%t);
  if ~ok then 
      lasterror();
      return;
  end
endfunction
