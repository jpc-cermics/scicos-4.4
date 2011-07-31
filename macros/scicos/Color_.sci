function Color_()
// XXXX: obsolete see menus/scsmenu_color.sci 
// 
  Cmenu=''
  scs_m_save=scs_m;nc_save=needcompile;enable_undo=%t
  [scs_m]=do_color(scs_m)
  edited=%t
endfunction

function [scs_m]=do_color(scs_m)
// do_color: changes the color of a link or a block.
// Copyright INRIA
  
// if no selection return;
  if isempty(Select) || isempty(find(Select(:,2)==curwin)) then
    message('Make a selection first');
    return;
  end
  // sel contains selection in curwin 
  sel=Select(find(Select(:,2)==curwin),1);
  // detect type of selected objects 
  kl=list([],[],[],[],[]);bl=[];
  for k=sel'
    o=scs_m.objs(k);
    if o.type == 'Link' then 
      // Link types (-1,1,2,3) in oct(2) 
      tag= o.ct(2)+2; // to get a number in [1,3,4,5] 
      kl(tag) = [kl(tag),k];
    elseif o.type == 'Block' then 
      bl = [bl,k];
    end
  end
  // prepare a menu with colors 
  Lt=['Event link','void','Regular link','Implicit link','Bus link','Block'];
  Dc=[scs_m.props.options.Link(2),0,scs_m.props.options.Link(1),...
      scs_m.props.options.Link(1),2,xget("lastpattern")+2];
  L=list()
  // prepare a menu 
  for i=1:length(kl) 
    if ~isempty(kl(i)) then 
      L($+1)=list('colors',Lt(i),Dc(i),"unused"); 
    end
  end
  if ~isempty(bl) then 
    L($+1)=list('colors',Lt($),Dc($),"unused"); 
  end
  if isempty(L) then return;end 
  // get new colors through menu 
  Lr=x_choices('Choose colors',L);
  if isempty(Lr) then return;end 
  // put results in arrays 
  link_colors = zeros(1,5);
  block_color=0;
  for i=1:length(Lr) 
    ind=find(L(i)(2)==Lt);
    if ind==6 then 
      block_color=Lr(i);
    else
      link_colors(ind)=Lr(i)
    end
  end
  // change objects 
  if ~isempty(kl) then 
    // we have some links, change the link colors 
    F=get_current_figure();
    F.draw_latter[];
    for i=1:length(kl) 
      for k=kl(i)
	connected=connected_links(scs_m,k)
	for kc=connected
	  o=scs_m.objs(kc);
	  o.ct(1) = link_colors(o.ct(2)+2); // to get a number in [1,3,4,5]
	  o.gr.children(1).color=o.ct(1) ;
	  scs_m.objs(kc)=o
	end
      end
    end
    F.draw_now[];
  end
  if ~isempty(bl) then 
    // we have some blocks, change the blocks colors 
    // change a block color 
    F=get_current_figure();
    F.draw_latter[];
    for k=bl do
      o = scs_m.objs(k);
      if type(o.graphics.gr_i,'short')=='s' then,
	o.graphics.gr_i=list(o.graphics.gr_i,[]),
      end
      o.graphics.gr_i(2)= block_color;
      F.remove[o.gr];
      o=drawobj(o,F);
      scs_m.objs(k)=o
    end
    F.draw_now[];
  end
endfunction


