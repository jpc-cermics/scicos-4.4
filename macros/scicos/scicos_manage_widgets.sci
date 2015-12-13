function scicos_manage_widgets(action, wingtkid=0, wintype='')
// 
  global(scicos_widgets=list());
  select action 
   case 'close' then 
    // set the open tag to %f 
    for i=1:length(scicos_widgets)
      if wingtkid.equal[scicos_widgets(i).id] then
        scicos_widgets(i).open=%f;break
      end
    end
   case 'destroy_all' then 
    // delete all opened widgets 
    for i=1:length(scicos_widgets)
      if scicos_widgets(i).open then
        scicos_widgets(i).id.destroy[];
      end
    end
    scicos_widgets=list();
   case 'destroy_what' then 
    // delete all opened widgets of type wintype 
    for i=1:length(scicos_widgets)
      if scicos_widgets(i).what.equal[wintype] then
        if scicos_widgets(i).open==%t then
          scicos_widgets(i).id.destroy[];
        end
      end
    end
   case 'register' then 
    // add a new widget 
    scicos_widgets($+1)=hash(id=wingtkid,open=%t,what=wintype);
  end
endfunction


