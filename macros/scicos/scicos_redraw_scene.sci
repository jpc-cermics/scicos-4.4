function scicos_redraw_scene(scs_m,excluded,mode)
// redraw scs_m excluding excluded ids 
// and using recording mode given by mode 
  others=1:length(scs_m.objs);
  others(excluded)=[]
  //xtape_status=xget('recording')
  [echa,echb]=xgetech();
  xclear(curwin,%t);
  xset("recording",mode);
  xsetech(wrect=echa,frect=echb,fixed=%t);
  for i=others
    drawobj(scs_m.objs(i))
  end
  drawtitle(scs_m.props)
  show_info(scs_m.props.doc)
  //xset('recording',xtape_status);
endfunction

    

