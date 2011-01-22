function Paleditor_()
  Cmenu=''
  scicos_palnew=do_edit_pal(scicos_pal)
  if ~isempty(scicos_palnew) & or(scicos_palnew<>scicos_pal) then 
    scicos_pal=scicos_palnew
    if ~execstr('save(''.scicos_pal'',scicos_pal)',errcatch=%t) then
      message('Cannot save .scicos_pal in current directory')
    end
  end
endfunction

function [scicos_palnew]=do_edit_pal(scicos_pal)
// Copyright INRIA
  scicos_palnew=[]
  txt=scicos_pal(:,2);
  txtnew=txt
  ld=%f
  while ld==%f
    ld=%t
    txtnew=x_dialog('Edit the list of palettes below',txtnew)
    if isempty(txtnew)|txt==txtnew then scicos_palnew=[];return;end
    scicos_palnew=[]
    for i=1:size(txtnew,1)
      txtnew(i)=stripblanks(txtnew(i))
      l=length(txtnew(i))
      if l<>0 then
	k=strindex(txtnew(i),'/');if isempty(k) then k=0;end
	h=strindex(txtnew(i),'\');if isempty(h) then h=0;end
	m=max([k,h]); 
	n=strindex(txtnew(i),'.cosf')
	if isempty(n) then n=strindex(txtnew(i),'.cos');end
	if isempty(n) then 
	  message('All files must end with .cos or .cosf')
	  scicos_palnew=[]
	  ld=%f;break
	end
	a=part(txtnew(i),m+1:n-1);
	scicos_palnew=[scicos_palnew;[a,txtnew(i)]];
      end
    end
  end
endfunction
