function needreplay=replayifnecessary()
  needreplay = needreplay
  if needreplay & slevel==1 then
    if xget('recording') == 0 then 
      // message('cannot replay: no recording');
    else
      xclear(curwin,%t);
      xtape('replay',curwin);
      needreplay=%f
    end
  end
endfunction
