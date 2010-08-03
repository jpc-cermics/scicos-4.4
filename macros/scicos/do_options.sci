function [edited,options]=do_options(opt,flag)
//
// Copyright INRIA
//if xget('use color')==1
// colors=string(1:xget("lastpattern")+2);
// XXXXX JPC 
  colors=m2s(1:xget("lastpattern")+2,"%1.0f");
  //else
  //  colors=['black','pat 1','pat 2','pat 3','pat 4','pat 5','pat 6','pat 7',
  //	  'pat 8','pat 9','pat 10','pat 11','pat 12','pat 13','pat 14',
  //	  'pat 15','white'];
  //end
  fontsSiz=['08','10','12','14','18','24'];
  fontsIds=[ 'Courrier','Symbol','Times','Times Italic','Times Bold','Times B. It.'];
  marksIds=['.','+','x','*','diamond fill.','diamond','triangle up',...
	    'triangle down','trefle','circle'];
  DashesIds=['Solid','-2-  -2-','-5-  -5-','-5-  -2-','-8-  -2-',...
	     '-11- -2-','-11- -5-'];
  //
  ok=%f
  edited=%f
  options=opt
  if flag=='D3' || flag == '3D' then
    if options.iskey['D3'] then f__3D= 'D3' else f__3D= '3D';end
    With3D=options(f__3D)(1);
    if type(With3D,'string')=="BMat" then
      with3d=0;with3d(With3D)=1
    else
      with3d=With3D
    end
    Color3D=options(f__3D)(2)
    l3d=list('combo','3D Shape',with3d+1,['No','Yes']);
    lcol_3d=list('colors','3D shape color',Color3D,colors);
    [lrep,lres,rep]=x_choices('3D shape settings',list(l3d,lcol_3d));
    if ~isempty(rep) then
      ok=%t
      options(f__3D)(1)=rep(1)==2
      options(f__3D)(2)=rep(2)
    end
  elseif flag=='Background' then
    bac=options('Background')
    if isempty(bac) then bac=[8 1],end //compatibility
    if size(bac,'*')<2 then bac(2)=1,end //compatibility
    lcols_bg=list('colors','Background',bac(1),colors);
    lcols_fg=list('colors','Foreground',bac(2),colors);
    [lrep,lres,rep]=x_choices('Background/Foreground color settings',list(lcols_bg,lcols_fg));
    if ~isempty(rep) then
      ok=%t
      options('Background')=rep
    end
  elseif flag=='LinkColor' then
    lcols_rl=list('colors','regular links',options('Link')(1),colors);
    lcols_el=list('colors','event links',options('Link')(2),colors);
    [lrep,lres,rep]=x_choices('Default regular and event link colors',list(lcols_rl,lcols_el));
    if ~isempty(rep) then
      ok=%t
      options('Link')=rep
    end
  elseif flag=='ID' then  
    lfid_l=list('combo','Link ID fontId',options('ID')(2)(1)+1,fontsIds);
    lfiz_l=list('combo','Link ID fontsize',options('ID')(2)(2)+1,fontsSiz);
    lfid_b=list('combo','Block ID fontId',options('ID')(1)(1)+1,fontsIds);
    lfiz_b=list('combo','Block ID fontsize',options('ID')(1)(2)+1,fontsSiz);
    [lrep,lres,rep]=x_choices('ID font definitions',list(lfid_l,lfiz_l,lfid_b,lfiz_b))
    if ~isempty(rep) then
      ok=%t
      options('ID')(1)=rep(1:2)-1
      options('ID')(2)=rep(3:4)-1
    end
  elseif flag=='Cmap' then
    cmap=options('Cmap')
    rgb=do_options_color_rgb();
//     [ok,R,G,B]=getvalue(['Enter RGB description of new colors';
// 		    'Each component must be greater or equal to 0';
// 		    'and less or equal to 1'],['R','G','B'],
//     list('vec','1','vec','1','vec','1'),[' ',' ',' '])
    options('Cmap')=[options('Cmap');rgb];
    if options('Background')==xget('lastpattern')+2 then
      options('Background')=options('Background')+size(R,'*')
    end
  end
  if ok then
    edited=or(opt<>options)
  end
endfunction

      


function rgb=do_options_color_rgb()
  window = gtkcolorselectiondialog_new ("Color selection dialog");
  window.help_button.hide[];
  window.set_position[GTK.WIN_POS_MOUSE]
  window.colorsel.set_has_opacity_control[%t];
  window.colorsel.set_has_palette[%t];
  window.help_button.destroy[];// remove help button 
  window.show_all[];
  // a gtkcolorselectiondialog is also a dialog.
  response = window.run[];
  if response == GTK.RESPONSE_ACCEPT || response == GTK.RESPONSE_OK ;
    color = window.colorsel.get_current_color[];
    rgb = [color.red,color.green,color.blue]/65535;
  else
    rgb =[];
  end
  window.destroy[];
endfunction
