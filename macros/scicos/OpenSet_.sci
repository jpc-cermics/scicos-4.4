function OpenSet_()
  xinfo('Click to open block or make a link')
  %kk=[]
  while %t 
    if isempty(%pt) then
      [btn,%pt,%win,Cmenu]=cosclick()
      if Cmenu<>"" then
	break
      end
    end
    %xc=%pt(1);%yc=%pt(2);%pt=[]
  
    if windows(find(%win==windows(:,2)),1)==100000 then
      //click in navigator
      [%Path,%kk,ok]=whereintree(%Tree,%xc,%yc)
      if ok & ~isempty(%kk) then %Path($)=null();%Path($)=null();end
      if ~ok then %kk=[],end
      //pause in openset navigator 
    else
      %kk=getobj(scs_m,[%xc;%yc])
      %Path=list('objs',%kk)
    end
    if ~isempty(%kk) then
      super_path=[super_path,%kk] 
      [o,modified,newparametersb,needcompileb,editedb]= clickin(scs_m(%Path))
      if Cmenu=='Link' then
	%pt=[%xc,%yc];
	super_path($)=[]
	break
      end
      // in case previous window has been destroyed

      if ~or(curwin==winsid()) then
	if new_graphics() then 
	  xset('window',curwin);
	  xset('default')
	  xclear();// XX xbasc();
	  xset('pattern',1)
	  xset('color',1)
	  if ~set_cmap(scs_m.props.options('Cmap')) then 
	    // add colors if required
	    scs_m.props.options('3D')(1)=%f //disable 3D block shape
	  end
	  xclear();//xbasc();
	  xselect()
	  set_background()
	  rect=dig_bound(scs_m);
	  if ~isempty(rect) then 
	    %wsiz=[rect(3)-rect(1),rect(4)-rect(2)];
	  else
	    %wsiz=[600/%zoom,400/%zoom]
	  end
	  // 1.3 to correct for X version
	  xset('wpdim',min(1000,%zoom*%wsiz(1)),min(800,%zoom*%wsiz(2)))
	  window_set_size()
	  //xset('alufunction',6)
	  scs_m=drawobjs(scs_m)
	  // pause OpenSet_
	else
	  xset('window',curwin);
	  xset('default')
	  xclear();// XX xbasc();
	  if pixmap then xset('pixmap',1); end
	  xset('pattern',1)
	  xset('color',1)
	  if ~set_cmap(scs_m.props.options('Cmap')) then // add colors if required
	    scs_m.props.options('3D')(1)=%f //disable 3D block shape
	  end
	  if pixmap then xset('wwpc');end
	  xclear();//xbasc();
	  xselect()
	  xtape_status=xget('recording');
	  xset('recording',1);
	  set_background()

          pwindow_set_size()
	  window_set_size()
	
	  //xset('alufunction',6)
	  scs_m=drawobjs(scs_m)
	  // pause OpenSet_
	  if pixmap then xset('wshow'),end
	end
	menu_stuff(curwin,menus)
	
	if ~super_block then
	  delmenu(curwin,'stop')
	  addmenu(curwin,'stop||$scicos_stop')
	  unsetmenu(curwin,'stop')
	else
	  unsetmenu(curwin,'Simulate')
	end
	//
      end
      //end of redrawing deleted parent  
      
      if needcompileb==4 then
	%kw=find(windows(:,1)==100000)
	if ~isempty(%kw) then
	  xdel(windows(%kw,2))
	  %Tree=list()
	end
      end
      
      edited=edited|editedb
      super_path($-size(%kk,2)+1:$)=[]
      
      if editedb then
	scs_m_save=scs_m;nc_save=needcompile
	if ~pal_mode then
	  needcompile=max(needcompile,needcompileb)
	end
	scs_m=update_redraw_obj(scs_m,%Path,o)
      end

      //note if block parameters have been modified
      if modified&~pal_mode  then
	newparameters=mark_newpars(%kk,newparametersb,newparameters)
      end
    end
  end
  
  xinfo(' ')
endfunction

