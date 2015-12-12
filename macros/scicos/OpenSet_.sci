function OpenSet_()
  //global inactive_windows
  if or(curwin==winsid()) then xset('window',curwin); end

  if ~%diagram_open then
    // we can arrive here if we click on an opened super block 
    %kk=Select(1);
    // test if %kk is valid i.e the selection is 
    // in scs_m and is a super block or a palette
    [%ok,%H] = execstr(['o=scs_m.objs(%kk)';
                        'rep= o.model.sim == ""super"" | o.gui == ""PAL_f""' ],...
                        errcatch=%t);
    // get rid of the error message;
    if ~%ok then lasterror();end
    // we are happy if execstr succeeded and answer in rep is %t 
    %ok = %ok && %H.rep
    if ~%ok then
      // stop 
      message(['This window is not active anymore or';
	       'the browser is not up-to-date.'])
      %scicos_navig=[]  // stop navigation
      Scicos_commands=[]
      Cmenu='';%pt=[]    
    else
      inactive_windows(1)($+1)=super_path;inactive_windows(2)($+1)=curwin
      super_path=[super_path,%kk]
      [o,modified,newparametersb,needcompileb,editedb]=clickin( scs_m.objs(%kk));
      indx=find(curwin==inactive_windows(2))
      if ~isempty(indx) then
        inactive_windows(1)(indx)=null();inactive_windows(2)(indx)=[]
      end
      edited=edited|editedb
      super_path($-size(%kk,2)+1:$)=[]
      if editedb then
        enable_undo = %f
        needcompile = max(needcompile, needcompileb)
        %Path = list('objs',%kk)
        if or(curwin==winsid()) then xset('window',curwin);end
        scs_m = update_redraw_obj(scs_m, %Path,o)
      end
      if modified then
        newparameters = mark_newpars(%kk,newparametersb,newparameters)
      end
    end

  else
  
    %xc=%pt(1);%yc=%pt(2);
    %kk=getobj(scs_m,[%xc;%yc]);
    %Path=list('objs',%kk);
  
    if ~isempty(%kk) then
      Select_back=Select; 
      selecthilite(Select_back,%f); //  unHilite previous objects
      Select=[%kk %win];            //  select the double clicked block 
      selecthilite(Select,%t) ;     
      inactive_windows(1)($+1)=super_path;inactive_windows(2)($+1)=curwin
      super_path=[super_path,%kk] ; 
      [o,modified,newparametersb,needcompileb,editedb]=clickin(scs_m(%Path));
      indx=find(curwin==inactive_windows(2))
      if ~isempty(indx) then
        inactive_windows(1)(indx)=null();inactive_windows(2)(indx)=[]
      end
    
      if Cmenu=="Link" then
        %pt=[%xc, %yc]
        super_path($)=[]
        return
      else
        edited = edited | editedb
        super_path($-size(%kk,2)+1:$)=[]
        if editedb then
          scs_m_save = scs_m
          nc_save    = needcompile

          if o.type=="Block" & isequal(o.model.sim,"super") then
            enable_undo = 2  //special code in case the content of SB has been changed
          else
            enable_undo = %t
          end
	  needcompile = max(needcompile, needcompileb)
	  if or(curwin==winsid()) then xset('window',curwin);end
          scs_m = update_redraw_obj(scs_m, %Path,o)
        end
        // note if block parameters have been modified
        if modified  then
          newparameters = mark_newpars(%kk,newparametersb,newparameters);
        end
      end
    end
    Cmenu='';%pt=[];
  end
endfunction

