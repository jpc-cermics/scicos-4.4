//interactively resize a block 
//from the bottom right corner
//or display a gui to set
//thickness and type of a link
function scmenu_resize()
  Cmenu='';
  sc=scs_m;
  [scs_m]= do_resize(scs_m);
  if ~scs_m.equal[sc] then 
    edited=%t;
    scs_m_save=sc;
    enable_undo=%t;
    nc_save=needcompile;
  end
endfunction

//interactively resize a block 
//from the top left corner
//or display a gui to set
//thickness and type of a link
function scmenu_resize_top()
  Cmenu='';
  sc=scs_m;
  [scs_m]= do_resize(scs_m,bot=%f);
  if ~scs_m.equal[sc] then 
    edited=%t;
    scs_m_save=sc;
    enable_undo=%t;
    nc_save=needcompile;
  end
endfunction

//display a gui to set the
//width and height of a block
//or display a gui to set
//thickness and type of a link
function scmenu_set_size()
  Cmenu='';
  sc=scs_m;
  [scs_m]= do_resize(scs_m,setsize=%t);
  if ~scs_m.equal[sc] then 
    edited=%t;
    scs_m_save=sc;
    enable_undo=%t;
    nc_save=needcompile;
  end
endfunction

function [scs_m]=do_resize(scs_m,setsize=%f,bot=%t)
// resize a block or a link 
// for a block resize its box 
// for a link changes its thickness and type
//
// if no selection return;
// bot : set the direction of the resize(bottom right or top left)
  if isempty(Select) || isempty(find(Select(:,2)==curwin)) then
    message('Make a selection first');
    return;
  end
  // K contains selected indices restricted to curwin 
  K=Select(find(Select(:,2)==curwin),1);
  
  if length(K)<> 1 then 
    message('Select only one block or one link for resizing !');
    return;
  end
  
  if scs_m.objs(K).type=='Block' then
    path=list('objs',K)
    o=scs_m.objs(K)
    graphics=o.graphics
    sz=graphics.sz
    w=sz(1)
    h=sz(2)
    orig=graphics.orig
    %scs_help='Resize_block'
    
    if ~setsize then
      if bot then
        xcursor(GDK.BOTTOM_RIGHT_CORNER)
      else
        xcursor(GDK.TOP_LEFT_CORNER)
      end

      F=get_current_figure();
      o_n=o
      hilite_size=o_n.gr.hilite_size
      hilite_type=o_n.gr.hilite_type
      o_n.gr.hilite_type=1
      o_n.gr.hilite_size=-1
      options=scs_m.props.options
      X_W = options('Wgrid')(1)
      Y_W = options('Wgrid')(2)
      rep(3)=-1;
      
      while ~or(rep(3)==[-5 2]) do
        xinfo("Block Sizes [w h] : ["+string(o_n.graphics.sz(1))+" "+string(o_n.graphics.sz(2))+"]")        
        rep=xgetmouse(clearq=%f,cursor=%f,getrelease=%t,getmotion=%t);
        
        dx=rep(1)-%pt(1);dy=rep(2)-%pt(2);
        
        //use snap mode
        if options('Snap') then
          [dxy]=get_wgrid_alignment([dx dy],[X_W Y_W]);
          dx=dxy(1);dy=dxy(2);
        end
        
        graphics.sz=[max(w+floor(dx),5);max(h-floor(dy),5)]
        if bot then
          graphics.sz=[max(w+floor(dx),5);max(h-floor(dy),5)]
          graphics.orig=[orig(1),min(orig(2)+h-5,orig(2)+floor(dy))];
        else
          graphics.sz=[max(w-floor(dx),5);max(h+floor(dy),5)]
          graphics.orig=[ min(orig(1)+w-5,orig(1)+floor(dx)) , orig(2)];
        end
        o_n.graphics=graphics
        F.remove[o_n.gr];
        scs_m=changeports(scs_m, path, o_n)
        o_n=scs_m(path);
      end

      xcursor();
      F.remove[o_n.gr];
      if rep(3)~=2 then
        o.graphics=graphics
      end
      o.gr.hilite_size=hilite_size
      o.gr.hilite_type=hilite_type
      scs_m=changeports(scs_m, path, o)
    else
      [ok,w,h]=getvalue('Set Block sizes',['width';'height'],..
                        list('vec',1,'vec',1),string(sz(:)))
      if ok then
        graphics.sz=[max(w,10);max(h,10)];
        graphics.orig=orig
        o.graphics=graphics
        scs_m=changeports(scs_m, path, o)
      end
    end
  elseif scs_m.objs(K).type=='Link' then
    [pos,ct]=(scs_m.objs(K).thick, scs_m.objs(K).ct)
    Thick=pos(1)
    Type=pos(2)
    %scs_help='Resize_link'
    [ok,Thick,Type]=getvalue('Link parameters',['Thickness';'Type'],..
                             list('vec','1','vec',1),[string(Thick);string(Type)])
    if ok then
      edited=or(scs_m.objs(K).thick<>[Thick,Type])
      scs_m.objs(K).thick=[Thick,Type]
      scs_m.objs(K).gr.children(1).thickness=max(scs_m.objs(K).thick(1),1)*..
                                             max(scs_m.objs(K).thick(2),1)
      scs_m.objs(K).gr.invalidate[]
    end
  else
    message("Resize is allowed only for Blocks or Links.")
  end
endfunction
