function DeleteRegion_()
  Cmenu='Open/Set'
  xinfo('Delete Region: Click, drag region and click (left to delete, right to cancel)')
  [scs_m,needcompile]=do_delete_region(scs_m,needcompile);
  xinfo(' ')
  %pt=[]
endfunction

function [scs_m,needcompile]=do_delete_region(scs_m,needcompile)
// Copyright INRIA
  xinfo('Click, drag to select region and click to fix the selection')

  [btn,%pt,win,Cmenu]=cosclick()
  if Cmenu<>"" then
    resume(Cmenu);
    return;
  end
  xc=%pt(1);yc=%pt(2);
  disablemenus()
  [ox,oy,w,h,ok]=get_rectangle(xc,yc)
  if ~ok then  enablemenus();return;end
  [del,keep]=get_blocks_in_rect(scs_m,ox,oy,w,h)

  modified= ~isempty(del)
  if modified then
    needreplay=replayifnecessary()
    scs_m_save=scs_m,nc_save=needcompile
    if new_graphics() then 
      [scs_m,DEL,DELL]=do_delete1(scs_m,del,%t);
    else
      [scs_m,DEL,DELL]=do_delete1(scs_m,del,%f);
    end
    
    if new_graphics() then 
      while scs_m.objs($).iskey['Deleted'] then
	scs_m.objs($)=null();
	if length(scs_m.objs)==0 then break,end
      end
    else
      // redraw 
      xtape_status=xget('recording')
      [echa,echb]=xgetech();
      xclear(curwin,%t);
      xset("recording",1);
      xsetech(echa,echb);
      drawobjs(scs_m);
      xset('recording',xtape_status);
    end
    needcompile=4
    enablemenus()
    resume(scs_m_save,nc_save,needreplay,enable_undo=%t,edited=%t);
    return ;
  else
    if new_graphics() then 
      F=get_current_figure();
      F.draw_now[];
    end
  end

  enablemenus()
endfunction
