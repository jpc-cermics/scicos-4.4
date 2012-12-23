function ok=hilite_mult_objs(path,objs,mess)
// this function hilight a block by two different way:
//   -First method: the block is given by its position in the diagram. In this case
//               - path: the super_path
//               - objs: the number of the block in the super_path.
//   -Second method: the block is given by its compiled number. In this case
//               - path is a list of vector (corinv)
//               - objs: the compiled number of the block.
  
  function temp2=check_csuper(temp,scs_m)
    temp2=[temp(1)];
    if scs_m.objs(temp(1)).model.sim.equal['super'] then
      temp2b=check_csuper(temp(2:$),scs_m.objs(temp(1)).model.rpar);
      temp2=[temp2 temp2b];
    end
  endfunction
  
  function append_command(mes,next)
    global Scicos_commands
    if isempty(Scicos_commands) then 
      Scicos_commands =[mes;next];
    else
      Scicos_commands($) =Scicos_commands($) +mes;
      Scicos_commands.concatd[next];
    end
  endfunction
  
  ok=%t;
  global Scicos_commands
  Scicos_commands=[];
  if type(path,'short')=='m' then
    for i=1:size(objs,'*')
      append_command('%diagram_path_objective='+sci2exp(path)+';%scicos_navig=1',...
		     'hilite_obj('+sci2exp(objs(i))+');');
    end
  elseif type(path,'short')=='l' then
    for i=1:size(objs,'*')
      temppath=path(objs(i))
      if type(temppath,'short')=='m' then
	temppath=check_csuper(temppath)
	nbr_obj=temppath($)
	temppath2=temppath(1:$-1);     
	append_command('%diagram_path_objective='+sci2exp(temppath2)+';%scicos_navig=1',...
		       'hilite_obj('+sci2exp(nbr_obj)+');');
      elseif type(temppath,'short')=='l' then
	//modelica and sampleclk
	for j=1:length(temppath)
	  nbr_obj=temppath(j)($)
	  temppath2=temppath(j)(1:$-1);
	  append_command('%diagram_path_objective='+sci2exp(temppath2)+';%scicos_navig=1',...
			 'hilite_obj('+sci2exp(nbr_obj)+');');
	end
      else
	message('The path must be a vector or a list of vectors');
	ok=%f;
	return;
      end
    end
  else
    message('The path must be a vector or a list of vectors');
    ok=%f;
    return;
  end
  append_command('%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1',...
		 'Cmenu="""";');
  if nargin==3 then
    mess1='[""'+catenate(mess,sep='"";""')+'""]';
    append_command('message('+mess1+');','');
  end
endfunction

