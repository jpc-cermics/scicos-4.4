function Details_()
  Cmenu='Open/Set'
  xinfo('Click on an object to get internal details')
  %pt=do_details(%pt,scs_m);
  xinfo(' ')
endfunction

function [%pt,scs_m]=do_details(%pt,scs_m)
// jpc April 2009
// just call editvar on the selected object.
  while %t
    if isempty(%pt) then
      [btn,%pt,win,Cmenu]=cosclick()
      if Cmenu<>"" then
	resume(%win=win,Cmenu=Cmenu,btn=btn)
        return;
      end
    else
      win=%win;
    end
    xc=%pt(1);yc=%pt(2);%pt=[];
    k=getblock(scs_m,[xc;yc])
    if ~isempty(k) then break,end
  end
  blk= scs_m.objs(k);
  editvar('blk');
  if ~blk.equal[scs_m.objs(k)];
    message('No change accepted');
  end
endfunction
