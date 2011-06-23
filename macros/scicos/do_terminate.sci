function [alreadyran,%cpr]=do_terminate(scs_m,%cpr)
// Copyright INRIA
  if exists('alreadyran','all');alreadyran=alreadyran ;else alreadyran=%f;end;
  if ~exists('%cpr','function') then %cpr=%cpr, end;
  if prod(size(%cpr))<2 then alreadyran=%f,return,end
  par=scs_m.props;

  if alreadyran then
    alreadyran=%f
    state=%cpr.state;
    //terminate current simulation
    win=xget('window')
    execok=execstr('[state,t,kfun]=scicosim(%cpr.state,par.tf,par.tf,'+
                   '%cpr.sim,''finish'',par.tol)',errcatch=%t)
    xset('window',win)
    //TODO Alan
    //%cpr; //not always called with second arg
    %cpr.state=state
    if ~execok then
      title_err='End problem.';
      str_err=catenate(lasterror());
      kfun=curblock()
      corinv=%cpr.corinv
      if kfun<>0 then
	path=corinv(kfun)
	if type(path,'short')=='l' then 
	  // modelica block
          spec_err='The modelica block returns the error :';
          message([title_err;spec_err;str_err]);
	else
	  obj_path=path(1:$-1)
          spec_err='block'
          blk=path($)
          scs_m_n=scs_m;
	  for i=1:size(path,'*')
	    sim = scs_m_n.objs(path(i)).model.sim;
            if sim.equal['super'] then
              scs_m_n=scs_m_n.objs(path(i)).model.rpar;
            elseif sim.equal['csuper'] then
              obj_path=path(1:i-1);
              blk=path(i);
              //spec_err='csuper block (block '+string(path(i+1))+')'
              spec_err='csuper block'
              break;
            end
          end
          spec_err='The hilited '+spec_err+' returns the error :';
	  //xset('window',curwin)
	  bad_connection(path,...
			 [title_err;spec_err;str_err],0,1,0,-1,0,1);
	end
	message(['End problem:';catenate(lasterror())]);
      end
    end
  end
  //TODO Alan
  //xset('window',curwin)
endfunction
