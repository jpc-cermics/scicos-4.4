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

function [scs_m]=do_resize(scs_m,setsize=%f)
// resize a block or a link 
// for a block resize its box 
// for a link changes its thickness and type
//
// if no selection return;
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
    scs_m_save=scs_m
    path=list('objs',K)
    o=scs_m.objs(K)
    o_n=scs_m.objs(K)
    graphics=o.graphics
    sz=graphics.sz
    orig=graphics.orig
    %scs_help='Resize_block'
    if ~setsize then
      bot=%t;//set the direction of the resize(bottom right or top left)
      
      if bot then
        xcursor(GDK.BOTTOM_RIGHT_CORNER)
      else
        xcursor(GDK.TOP_LEFT_CORNER)
      end
      rect=[orig(1);orig(2)+sz(2);0;0]
      if size(%pt,'*')==2 then 
	rect(3:4)=%pt(:);
      end
      if bot then
        xc=rect(1);
        yc=rect(2);
      else
        xc=orig(1)+sz(1);
        yc=orig(2);
      end
      
      F=get_current_figure();
      R.x=xc;R.y=yc;R.w=1;R.h=1;
      rep(3)=-1;
      o_nn=o_n
      hilite_size=o_nn.gr.hilite_size
      hilite_type=o_nn.gr.hilite_type
      o_nn.gr.hilite_type=1
      o_nn.gr.hilite_size=-1
      while ~or(rep(3)==[-5 2]) do
        str="Block Sizes [w h] : ["+string(o_nn.graphics.sz(1))+" "+string(o_nn.graphics.sz(2))+"]";
        xinfo(str)
        rep=xgetmouse(clearq=%f,cursor=%f,getrelease=%t,getmotion=%t);
        bbox=o_nn.gr.get_bounds[]
        if bot then
          correction_x=bbox(3)-(o_nn.graphics.orig(1)+o_nn.graphics.sz(1))
          correction_y=bbox(2)-o_nn.graphics.orig(2)
        else
          correction_x=bbox(1)-o_nn.graphics.orig(1)
          correction_y=bbox(4)-(o_nn.graphics.orig(2)+o_nn.graphics.sz(2))
        end
        xc1=rep(1)-correction_x;
        yc1=rep(2)-correction_y;
        
        if %scicos_snap then
          if abs( floor(xc1/%scs_wgrid(1))-(xc1/%scs_wgrid(1)) ) <...
                  abs(  ceil(xc1/%scs_wgrid(1))-(xc1/%scs_wgrid(1)) )
            xc1 = floor(xc1/%scs_wgrid(1))*%scs_wgrid(1) ;
          else
            xc1 = ceil(xc1/%scs_wgrid(1))*%scs_wgrid(1) ;
          end
          if abs( floor(yc1/%scs_wgrid(2))-(yc1/%scs_wgrid(2)) ) <...
                  abs(  ceil(yc1/%scs_wgrid(2))-(yc1/%scs_wgrid(2)) )
            yc1 = floor(yc1/%scs_wgrid(2))*%scs_wgrid(2) ;
          else
            yc1 = ceil(yc1/%scs_wgrid(2))*%scs_wgrid(2) ;
          end
        end
        
        if ~bot then
          if xc1<xc then
            R.x=xc1
            R.w=floor((xc-xc1))
          else
            R.x=xc
            R.w=0
          end
          if yc1>yc then
            R.y=yc1
            R.h=floor((yc1-yc))
          else
            R.y=yc
            R.h=0
          end
        else
          if xc1>xc then
            R.w=floor((xc1-xc))
          else
            R.w=0         
         end
          if yc1<yc then
            R.h=floor((yc-yc1))
          else
            R.h=0         
          end
        end
        
        if %scicos_snap then
          if abs( floor(R.w/%scs_wgrid(1))-(R.w/%scs_wgrid(1)) ) <...
                  abs(  ceil(R.w/%scs_wgrid(1))-(R.w/%scs_wgrid(1)) )
            R.w = floor(R.w/%scs_wgrid(1))*%scs_wgrid(1) ;
          else
            R.w = ceil(R.w/%scs_wgrid(1))*%scs_wgrid(1) ;
          end
          if abs( floor(R.h/%scs_wgrid(2))-(R.h/%scs_wgrid(2)) ) <...
                  abs(  ceil(R.h/%scs_wgrid(2))-(R.h/%scs_wgrid(2)) )
            R.h = floor(R.h/%scs_wgrid(2))*%scs_wgrid(2) ;
          else
            R.h = ceil(R.h/%scs_wgrid(2))*%scs_wgrid(2) ;
          end
        end
        
        rect=[R.x,R.y,R.w,R.h]
        w=rect(3);h=rect(4);
        graphics.sz=[w;h]
        if bot then
          graphics.orig=[orig(1),orig(2)+sz(2)-h];
        else
          graphics.orig=[R.x,R.y-h];
        end
        o_nn.graphics=graphics
        F.remove[o_nn.gr];
        scs_m=changeports(scs_m, path, o_nn)
        o_nn=scs_m(path)
      end
      xcursor();
      F.remove[o_nn.gr];
    
      w=rect(3);h=rect(4);ok = (rep(3)~=2);
      if ok then 
	graphics.sz=[w;h]
	if bot then
	  graphics.orig=[orig(1),orig(2)+sz(2)-h];
        else
	  graphics.orig=[R.x,R.y-h];
	end
	o_n.graphics=graphics
      end
      
      o_n.gr.hilite_size=hilite_size
      o_n.gr.hilite_type=hilite_type
      scs_m=changeports(scs_m, path, o_n)
    else
      [ok,w,h]=getvalue('Set Block sizes',['width';'height'],..
			list('vec',1,'vec',1),string(sz(:)))
      if ok then
	graphics.sz=[max(w,10);max(h,10)];
	graphics.orig=orig
	o_n.graphics=graphics
	scs_m=changeports(scs_m, path, o_n)
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
