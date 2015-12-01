function scmenu_zoom_in()
  Cmenu=''
  xinfo('Zoom in')
  zoomfactor=1.2
  scs_m.props.zoom = scs_m.props.zoom*zoomfactor;

  for i=1:length(scs_m.objs)
    if scs_m.objs(i).iskey['gr'] then
      scs_m.objs(i).gr.show=%f
    end
  end

  window_set_size(curwin,%f,invalidate=%f,popup_dim=%f);

  // we need redraw text and some blocks
  // with not filled text
  [scs_m]=scmenu_redraw_zoomed_text(scs_m,F);

  for i=1:length(scs_m.objs)
    if scs_m.objs(i).iskey['gr'] then
      scs_m.objs(i).gr.show=%t
    end
  end

  F.invalidate[];
  edited=%t;
  xinfo(' ')
endfunction

function [scs_m]=scmenu_redraw_zoomed_text(scs_m,F)
// used to force a redraw for text and for 
// some blocks containing not-filled text
// 
// Note: This code should be removed !
// making a special case for specific object 
// should be considered as a wrong idea. 
// 
  %zoom = scs_m.props.zoom;
  function [ok]=shouldberedrawn(ogr)
     ok=%f
     for j=1:length(ogr.children)
       if type(ogr.children(j),'string')=='Grstring' then
         if ogr.children(j).fill==2 then
           ok=%t,break;
         end
       //need test also compound ?
       end
     end
   endfunction
   redraw=%f;   
   for i=1:length(scs_m.objs)
     if scs_m.objs(i).type=="Text" then
       o=scs_m.objs(i)
       [o,ok]=drawobj(o,F)
       scs_m.objs(i)=o;
       redraw=%t;
     elseif scs_m.objs(i).type=="Block" then
       if scs_m.objs(i).iskey['gr'] then
         if shouldberedrawn(scs_m.objs(i).gr) then
           o=scs_m.objs(i)
           [o,ok]=drawobj(o,F)
           scs_m.objs(i)=o;
	   redraw=%t;
         end
       end
     end
   end
endfunction

