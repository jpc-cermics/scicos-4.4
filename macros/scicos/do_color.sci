function [%pt,scs_m]=do_color(%pt,scs_m)
// do_color: changes the color of a link or a block.
// Copyright INRIA
  if isempty(Select) || isempty(find(Select(:,2)==curwin)) then
    xinfo('make a selection first');
    return;
  end
  sel=Select(find(Select(:,2)==curwin),1);
  kl=[];bl=[];
  for k=sel'
    o=scs_m.objs(k);
    if o.type == 'Link' then 
      kl = [kl,k];
    elseif o.type == 'Block' then 
      bl = [bl,k];
    end
  end
  if ~isempty(kl) then 
    // we have some links, change the link colors 
    o = scs_m.objs(kl(1));
    [nam,pos,ct]=(o.id,o.thick,o.ct)
    colors=m2s(1:xget("lastpattern")+2,"%1.0f");
    col_l=list('colors','Link color',ct(1),colors);
    [lrep,lres,c]=x_choices('Choose link color',list(col_l));
    if ~isempty(c) then 
      F=get_current_figure();
      F.draw_latter[];
      for k=kl 
	connected=connected_links(scs_m,k)
	// new nsp graphics 
	for kc=connected
	  o=scs_m.objs(kc);
	  o.ct(1)=c;
	  o.gr.children(1).color=c;
	  scs_m.objs(kc)=o
	end
      end
      F.draw_now[];
    end
  end
  if ~isempty(bl) then 
    // we have some blocks, change the blocks colors 
    o = scs_m.objs(bl(1));
    // change a block color 
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
    if ~isempty(coln) then
      F=get_current_figure();
      F.draw_latter[];
      for k=bl do
	o = scs_m.objs(k);
	if type(o.graphics.gr_i,'short')=='s' then,
	  o.graphics.gr_i=list(o.graphics.gr_i,[]),
	end
	o.graphics.gr_i(2)=coln
	F.remove[o.gr];
	o=drawobj(o,F);
	scs_m.objs(k)=o
      end
      F.draw_now[];
    end
  end
endfunction


