function xstringb_fix_font(x,y,s,wo,ho,o)
  global %Scicos_Font_cor;   // use instead of persistent
  if isempty(%Scicos_Font_cor) then
    global %Scicos_Font_cor
    fontxx=xget("font")
    for i=0:5
      xset("font size",i)
      xywh=xstringl(0,0,'Logical Op')
      %Scicos_Font_cor(i+1)=xywh(3)
    end
    %Scicos_Font_cor=%Scicos_Font_cor*%zoom/50
  end
  fsz=max(0,-1+max(find(%zoom>%Scicos_Font_cor)))
  //printf("***** fsz=%d\n",fsz);
  xset("font size",fsz)
  rect=xstringl(x,y,s)
  w=rect(3),h=rect(4)
  xstring(x+(wo-w)/2,y+(ho-h)/2,s,posx='center',posy='center')
endfunction 
