function [Cmenu,args]=mpopup(ll)
// creates popup menus this could be changed 
// using the uimanager 
  
  function menuitem_response(w,args) 
  // right button menu activation 
  // 
    printf("menuitem selected %s\n",args(2));
    args(1).user_data=list(args(2),args(3));
    gtk_main_quit();
  endfunction

  function menu_deactivate(w,args) 
  // right button menu deactivated 
  // printf("menu deactivated\n");
    args(1).user_data=list('Aborted',list());
    gtk_main_quit();
  endfunction
  
  function menuitem =mpopup_item(str,flag,args)
    if ~isempty(strindex(str,'|||')) then
      stock_id = part(str,strindex(str,'|||')+3:length(str))
      label    = part(str,1:strindex(str,'|||')-1)
      menuitem = gtkimagemenuitem_new(stock_id=stock_id);
    else
      label    = str
      menuitem = gtkmenuitem_new(label=label);
    end
    if flag then 
      menuitem.connect["activate",menuitem_response,list(topmenu,label,args)];
    end
  endfunction
  
  function w=createmenu(ll,topmenu)
    menu = gtkmenu_new ();
    menu.set_title['Foo'];
    
    if nargin==1 then topmenu=menu;end 
    for l=ll
      if type(l,'short')=='s' then
	menuitem =mpopup_item(l,%t,list());
	menu.append[menuitem]
	menuitem.show[];
      elseif type(l,'short')=='l' then
	menuitem =mpopup_item(l(1),%f, list());
	menu.append[menuitem],
	menuitem.set_submenu[createmenu(list(l(2:$)),topmenu)];
        menuitem.show[];
      elseif type(l,'short')=='h' then 
	menuitem =mpopup_item(l.name,%t,l);
	menu.append[menuitem],
	menuitem.show[];
      end
    end
    w=menu
  endfunction
  
  Cmenu="Aborted"
  if length(ll)==0 then return;end
  menu = createmenu(ll);
  menu.connect["deactivate",menu_deactivate,list(menu)];
  menu.show[]
  menu.popup[button=3,activate_time=0]; //event.time]; 
  gtk_main();
  L=  menu.user_data ;
  Cmenu=L(1);
  args=L(2);
  if type(L(2),'short')=='h' && L(2).iskey['cmenu'] then 
    Cmenu=L(2).cmenu;
  end
  // printf("quit the popup selection=%s\n",Cmenu);
endfunction
