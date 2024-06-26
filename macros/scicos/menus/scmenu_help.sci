function scmenu_help()
  xinfo('Click on object or menu to get help')
  //xcursor(93)
  Select=do_help(Select)
  //xcursor()
  xinfo(' ')
  Cmenu=''
  %pt=[]
endfunction

function Select=do_help(Select)
  cwin=%win
  sel_items=size(Select)
  obj_selected=sel_items(1)
  if obj_selected==0 then
    while %t
      [btn,%pt,cwin,Cmenu]=cosclick()
      if (Cmenu<>"SelectLink") & (Cmenu<>"CheckMove") then
        name=Cmenu
        nm=1
        break
      end
      if cwin==curwin then
        xc=%pt(1);yc=%pt(2);%pt=[]
        k=getblock(scs_m,[xc;yc])
        if ~isempty(k) then
          o=scs_m.objs(k)
          if o.type=="Block" then 
            name=o.gui
            nm=0
            Select=[k %win];
          else
            return
          end
          break
        end
      else
        return
      end
    end
  else
    cwin=Select(1,2)
    if cwin==curwin then
      k=Select(1,1)
      o=scs_m.objs(k)
      if o.type=="Block" then 
        name=o.gui
        nm=0
      else
        return
      end
    else
      return
    end
  end
  if nm==0 then
    cos_help(name)
  else
    if ~execstr('mess=%scicos_help.menu(name)',errcatch=%t) then
      if ~execstr('mess=%scicos_help(name)',errcatch=%t) then
        mess=sprintf('No help available for %s !',name);
      end
    end
    message(mess);
  end
endfunction

function [ok]=cos_help(topic)
  ok=%t
  if %scicos_topics.iskey[topic] then
    help(%scicos_topics(topic));
  else
    help("http://www.scicos.org/HELP/eng/scicos/'+topic+'.htm');
  end
endfunction
