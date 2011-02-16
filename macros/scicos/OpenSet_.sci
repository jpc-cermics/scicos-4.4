function OpenSet_()
 global inactive_windows
 if or(curwin==winsid()) then xset('window',curwin) end

 if ~%diagram_open then
   %kk=Select(1)
   if size(scs_m.objs)<%kk then
     ierr=1
   else
     ierr=execstr('xxx=scs_m.objs(%kk).model.sim',errcatch=%t)
   end
   if isequal(ierr,%t) then
     ierr=0
     if ~isequal(xxx,'super') then
       ierr2=execstr('xxxx=scs_m.objs(%kk).gui',errcatch=%t)
       if ierr2==%t then
         if ~isequal(xxxx,'PAL_f') then
           ierr=1;
         end
       else
         ierr=1;
       end
     end
   else
     ierr=1;
   end
   if ~isequal(ierr,0) then
     message(['This window is not active anymore or';
              'the browser is not up-to-date.'])
     %scicos_navig=[]  // stop navigation
     Scicos_commands=[]
     Cmenu='';%pt=[]
     return
   end
    
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
     if or(curwin==winsid()) then xset('window',curwin) end
     scs_m = update_redraw_obj(scs_m, %Path,o)
   end
    
   if modified then
     newparameters = mark_newpars(%kk,newparametersb,newparameters)
   end
   return
 end

 %xc=%pt(1);%yc=%pt(2);
 %kk=getobj(scs_m,[%xc;%yc]);
 %Path=list('objs',%kk);
  
 if ~isempty(%kk) then
   Select_back=Select; 
   selecthilite(Select_back,%f); //  unHilite previous objects
   Select=[%kk %win];            //** select the double clicked block 
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
     return;
   end

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

     if ~pal_mode then
      needcompile = max(needcompile, needcompileb)
     end
     if or(curwin==winsid()) then xset('window',curwin) end
     scs_m = update_redraw_obj(scs_m, %Path,o)
   end
    
   // note if block parameters have been modified
   if modified  then
     newparameters = mark_newpars(%kk,newparametersb,newparameters);
   end
 end
 Cmenu='';%pt=[];
endfunction

