//to redraw text and some blocks
//with not filled text
function [scs_m]=redrawifnecessary(scs_m,F)

   function [ko]=shouldberedrawn(ogr)
     ko=%f
     for j=1:length(ogr.children)
       if type(ogr.children(j),'string')=='Grstring' then
         if ogr.children(j).fill==2 then
           ko=%t,break;
         end
       //need test also compound ?
       end
     end
   endfunction

   for i=1:length(scs_m.objs)
     if scs_m.objs(i).type=="Text" then
       o=scs_m.objs(i)
       [o,ok]=drawobj(o,F)
       scs_m.objs(i)=o;
     elseif scs_m.objs(i).type=="Block" then
       if scs_m.objs(i).iskey['gr'] then
         if shouldberedrawn(scs_m.objs(i).gr) then
           o=scs_m.objs(i)
           [o,ok]=drawobj(o,F)
           scs_m.objs(i)=o;
         end
       end
     end
   end

endfunction
