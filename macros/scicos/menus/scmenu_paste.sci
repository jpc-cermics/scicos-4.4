function scmenu_paste()
  if ~isequal(%win,curwin) then
    message(["Paste operation is not possible in this window"]);
    Cmenu = ''; %pt = []; %ppt = [];
    return
  end        
  
  if isempty(Clipboard) then
   Cmenu = ''; %pt = []; %ppt = [];
   return
  end

  xset('window',curwin);
  xselect();
  F=get_current_figure();
  F.draw_latter[];
  options=scs_m.props.options
  X_W = options('Wgrid')(1)
  Y_W = options('Wgrid')(2)
  if and(size(Select)==[1,2]) then
    if windows(find(windows(:,2)==Select(1,2)),1)>0 then //** only one object selected 
      Sel_obj = scs_m.objs(Select(1,1)) ; 
      if (Clipboard.type=="Block" & Sel_obj.type=="Block")
        if and(Clipboard.graphics.sz==Sel_obj.graphics.sz)  & ...
           and(Clipboard.graphics.orig == Sel_obj.graphics.orig) then
          scs_m_save=scs_m;
          nc_save=needcompile;
          blk=Clipboard;
          blk.graphics.orig=Clipboard.graphics.orig+Clipboard.graphics.sz/2;
          if blk.iskey['gr'] then blk.delete['gr'], end
          blk=drawobj(blk,F); //** draw the single object
          scs_m.objs($+1)=blk //** add the object at the top
          edited=%t
          enable_undo=%t
          Select=[size(scs_m.objs), %win];
        else
          //** the true replace operation is there 
          [scs_m, needcompile]=do_replace(scs_m, needcompile, Clipboard, Select);
        end
      else
        message(["Paste -> Source / Destination incompatible"]);
        Cmenu='';%pt=[];%ppt=[];
        F.draw_now[]
        return;
      end
    end
  else //** no object is selected for "Paste": paste object in the void    
    if Clipboard.type=="Block" | Clipboard.type=="Text" then
      scs_m_save = scs_m;
      nc_save    = needcompile;  
      //** POSITION SHIFT 
      if isempty(%ppt) then
	%ppt=Clipboard.graphics.orig + Clipboard.graphics.sz/2 ; //** automatic position shift       
      end  
      blk=Clipboard;
      //use snap mode
      if options('Snap') then
        [%ppt]=get_wgrid_alignment(%ppt,[X_W Y_W])
      end
      blk.graphics.orig=%ppt;
      if blk.iskey['gr'] then blk.delete['gr'], end
      blk=drawobj(blk,F); //** draw the single object 
      scs_m.objs($+1)=blk
      edited=%t;
      enable_undo=%t;
      Select=[size(scs_m.objs),%win];
      needcompile=4
    elseif Clipboard.type=="diagram" then
      reg = Clipboard;
      if isempty(%ppt) then
	for i=1:size(Clipboard.objs)	  
	  if (Clipboard.objs(i).type)=="Block" then
	    if isempty(%ppt) then
	      %ppt(1)=Clipboard.objs(i).graphics.orig(1);
	      %ppt(2)=Clipboard.objs(i).graphics.orig(2);
	    else
	      %ppt(1)=min(%ppt(1), Clipboard.objs(i).graphics.orig(1));
	      %ppt(2)=min(%ppt(2), Clipboard.objs(i).graphics.orig(2));
	    end
	  end
	end   
      end //** ppt is void 
      //use snap mode
      if options('Snap') then
        [%ppt]=get_wgrid_alignment(%ppt,[X_W Y_W])
      end
      %ppt = %ppt + 10 // (x,y) decalage, a modifier

      if size(reg.objs)>=1 then
	Select=[]; //** clear the data structure
	scs_m_save=scs_m
	nc_save=needcompile;
	n=length(scs_m.objs)
	xc=%ppt(1);
	yc=%ppt(2);
	rect=dig_bound(reg)
        if options('Snap') then
          [rrect]=get_wgrid_alignment([rect(1) rect(2)],[X_W Y_W])
        end
	for k=1:size(reg.objs)
	  o = reg.objs(k)
	  // translate blocks and update connection index 
	  if o.type=="Link" then
	    o.xx=o.xx-rrect(1)+xc
	    o.yy=o.yy-rrect(2)+yc
	    [from,to]=(o.from,o.to)
	    o.from(1)=o.from(1) + n;
	    o.to(1)=o.to(1) + n;
	  elseif o.type=="Block" then
	    o.graphics.orig(1) = o.graphics.orig(1)-rrect(1)+xc
	    o.graphics.orig(2) = o.graphics.orig(2)-rrect(2)+yc
	    k_conn=find(o.graphics.pin>0)
	    o.graphics.pin(k_conn) = o.graphics.pin(k_conn) + n
	    k_conn = find(o.graphics.pout>0)
	    o.graphics.pout(k_conn)=o.graphics.pout(k_conn)+n
	    k_conn=find(o.graphics.pein>0)
	    o.graphics.pein(k_conn)=o.graphics.pein(k_conn)+n
	    k_conn=find(o.graphics.peout>0)
	    o.graphics.peout(k_conn)=o.graphics.peout(k_conn)+n
	  elseif o.type=="Text" then
	    o.graphics.orig(1) = o.graphics.orig(1)-rrect(1)+xc
	    o.graphics.orig(2) = o.graphics.orig(2)-rrect(2)+yc
	  end
          if o.iskey['gr'] then o.delete['gr'], end
	  o=drawobj(o,F); //** draw the object
	  scs_m.objs($+1)=o;
	  Select=[Select;size(scs_m.objs),%win]; //** it's a really dirty trick ;)
	end
	//**------------------------------------------------------
	needcompile=4;
	enable_undo=%t;
	edited=%t;
      end //** a diagram is pasted  
    end //** object type 
  end //** valid Paste as "replace" or "in the void"
  F.draw_now[];
  Cmenu='';
  %pt=[]; 
endfunction
