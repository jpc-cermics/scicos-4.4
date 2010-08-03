function [%pt,scs_m]=do_color(%pt,scs_m)
// do_block - edit a block icon
// Copyright INRIA
  while %t
    if isempty(%pt) then
      [btn,%pt,win,Cmenu]=cosclick()
      if Cmenu<>"" then
	resume(%win=win,Cmenu=Cmenu,btn=btn);
	return;
      end
    else
      win=%win;
    end 
    xc=%pt(1);yc=%pt(2);%pt=[]
    K=getobj(scs_m,[xc;yc])
    if ~isempty(K) then break,end
  end
  o=scs_m.objs(K)
  if o.type =='Link' then
    // change link color 
    [nam,pos,ct]=(o.id,o.thick,o.ct)
    colors=m2s(1:xget("lastpattern")+2,"%1.0f");
    col_l=list('colors','Link color',ct(1),colors);
    [lrep,lres,c]=x_choices('Choose link color',list(col_l));
    if isempty(c) || c == ct(1) then  return; end
    connected=connected_links(scs_m,K)
    if new_graphics() then
      F=get_current_figure();
      F.draw_latter[];
      for kc=connected
	o=scs_m.objs(kc);
	o.ct(1)=c;
	o.gr.children(1).color=c;
      end
      F.draw_now[];
    else
      for kc=connected
	o=scs_m.objs(kc);ct=o.ct
	if ct(1)<>c then
	  drawobj(o)
	  o.ct(1)=rep;
	  drawobj(o)
	  scs_m.objs(kc)=o
	end
      end
    end
  elseif o.type =='Block' then
    if type(o.graphics.gr_i,'short')=='s' then,
      o.graphics.gr_i=list(o.graphics.gr_i,[]),
    end
    if isempty(o.graphics.gr_i(2)) then
      coli=0
    else
      coli=o.graphics.gr_i(2)
    end
    colors=m2s(1:xget("lastpattern")+2,"%1.0f");
    col_l=list('colors','Block color',coli,colors);
    [lrep,lres,coln]=x_choices('Choose Block color',list(col_l));
    if isempty(coln) then
      return;
    end
    if coln<>coli then
      o.graphics.gr_i(2)=coln
      if new_graphics() then 
	F=get_current_figure();
	F.draw_latter[];
	F.remove[scs_m.objs(K).gr];
	F.start_compound[];
	drawobj(o);
	C=F.end_compound[];
	o.gr=C;
	scs_m.objs(K)=o
	F.draw_now[];
      else
	scs_m.objs(K)=o
	// redraw 
	xtape_status=xget('recording')
	[echa,echb]=xgetech();
	xclear(curwin,%t);
	xset("recording",1);
	xsetech(echa,echb);
	drawobjs(scs_m);
	xset('recording',xtape_status);
      end
    end
  elseif o.type =='Text' then
    //not implemented
  end
endfunction


