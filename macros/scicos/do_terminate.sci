function [alreadyran,%cpr]=do_terminate(scs_m,%cpr)
// Copyright INRIA
  if exists('alreadyran','all');alreadyran=alreadyran ;else alreadyran=%f;end;
  if ~exists('%cpr','function') then %cpr=%cpr, end;
  if prod(size(%cpr))<2 then alreadyran=%f,return,end
  par=scs_m.props;

  if alreadyran then
    alreadyran=%f
    //terminate current simulation
    win=xget('window')
    disablemenus()
    execok=execstr('[state,t,kfun]=scicosim(%cpr.state,par.tf,par.tf,'+
                   '%cpr.sim,''finish'',par.tol)',errcatch=%t)
    enablemenus()
    xset('window',win)
    //TODO Alan
    //%cpr; //not always called with second arg
    %cpr.state=state
    if ~execok then
      kfun=curblock()
      corinv=%cpr.corinv
      if kfun<>0 then
	path=corinv(kfun)
	xset('window',curwin)
	bad_connection(path,..
		       ['End problem with hilited block';lasterror()],0,0,-1,0)
      else
	message(['End problem:';lasterror()])
      end
    end
    //TODO Alan
    //xset('window',curwin)
  end
endfunction
