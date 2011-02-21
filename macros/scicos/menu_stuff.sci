function menu_stuff(win,menus)
// updates menus of a graphic window 
// 
  delmenu(win,'3D Rot.')
  delmenu(win,'UnZoom')
  delmenu(win,'Zoom')
  delmenu(win,'File')
  if ~(type(menus,'short')== 'h') then return;end 
  for i=1:size(menus.items,'*')
    sname = menus.items(i);
    submenu=menus(sname);
    delmenu(win,sname);
    addmenu(win,sname,submenu(1),list(0,sname));    
  end
  if ~super_block then
    delmenu(win,'stop')
    addmenu(win,'stop||$scicos_stop');
    unsetmenu(win,'stop')
  else
    unsetmenu(win,'Simulate')
  end
endfunction

function [menus]=scicos_menu_prepare(menu_descr)
// from scicos menu description to a description 
// for addmenu.
  men_items=[];
  menus=hash_create(2*length(menu_descr));
  // build function names associated to menus 
  for i=1:length(menu_descr)
    submenu=menu_descr(i)
    // submenu=['title','item1',...]
    items=submenu(2:$)';
    men_items=[men_items;submenu(1)];
    I=strstr(items,'|');
    // version of items without extra data, accelarators etc....
    %R1 = items; 
    for ii=1:size(items,'*'); 
      if I(ii)<> 0 then %R1(ii)=part(%R1(ii),1:I(ii)-1);end 
    end
    // generate a functio name to call from item name 
    // 
    %R2= stripblanks(%R1)+'_';
    %R2=strsubst(%R2,'/','');
    %R2=strsubst(%R2,'\','');
    %R2=strsubst(%R2,' ','');
    %R2=strsubst(%R2,'.','');
    %R2=strsubst(%R2,'-','');
    // list(menu_name, full_submenu_names , submenu_short_names , submenu_fname)
    // Ex: [ "_Open|<Control>P||gtk-open", "_Open" , "Open_"];
    menus(submenu(1))=list(items,%R1,%R2);
  end
  menus.items = men_items;
endfunction
