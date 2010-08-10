function [corners] = stringbox(str,x,y,angle,font_id, font_size)
  rect=xstringl(x,y,str);
  w=rect(3);
  corners=[x,x,x+w,x+w;y,rect(2),rect(2),y];
endfunction

