function scs_m=update_redraw_obj(scs_m,path,o)
// Copyright INRIA
  if new_graphics() then 
    // --------------------------
    F=get_current_figure();
    F.draw_latter[];
    if size(path,'*')==2 then
      if o.type =='Link'| o.type =='Text' then
	F.remove[scs_m(path).gr];
	F.start_compound[];
	drawobj(o)
	C=F.end_compound[];
	o.gr=C;
	scs_m(path)=o;
      else
	scs_m=changeports(scs_m,path,o)
      end
    else // change a block in a sub-level
      F.remove[scs_m(path).gr];
      F.start_compound[];
      o.delete['gr'];
      drawobj(o)
      C=F.end_compound[];
      o.gr=C;
      scs_m(path)=o;
    end
    F.draw_now[];
  else
    // -------------------------- 
    if size(path,'*')==2 then
      if o.type =='Link'| o.type =='Text' then
	drawobj(scs_m(path))
	scs_m(path)=o
	drawobj(scs_m(path))
      else
	scs_m=changeports(scs_m,path,o)
      end
      // we need to redraw the scene in the no_xor_mode
      // the above drawobj could be removed 
      scicos_redraw_scene(scs_m,[],0);
    else // change a block in a sub-level
      scs_m(path)=o
    end
  end
endfunction
