function scmenu_browser()
// Copyright INRIA
//
  Cmenu='';
  if isempty(super_path) then 
    do_browser(scs_m);
  else    
    Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
		     'Cmenu='"scmenu_browser'";%scicos_navig=[]';
		     '%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1'];
  end
endfunction

// simple demo of treestore with pixmap
// the treestore model have two levels 
// and is build with append.

function do_browser(scs_m)
  
  function scicos_browser_tv_model(iter,model,L,H)
    if type(iter,'short')<>'none' then 
      iter1=model.append[iter,list(list(pixbuf_dir),L(1))];
    else
      iter1=model.append[list(list(pixbuf_dir),L(1))];
    end
    sub=H.iskey[L(1)];
    if sub then sub=H(L(1));else sub='Empty';end
    for j=1:size(sub,'*')
      icon = scicos_icon_path + sub(j) + '.png' ;
      ok = execstr('pixbuf = gdk_pixbuf_new_from_file(icon);',errcatch=  %t);
      if ~ok then 
	lasterror();
	pixbuf = pixbuf_def
      end
      // pb = pixbuf.scale_simple[ 64,64, GDK.INTERP_NEAREST];
      // we assume that path is of length 2 (browserid,blockid).
      model.append[iter1,list(list(pixbuf),sub(j),1,2)];
    end
    // now the super blocks 
    for i=2:length(L);
      scicos_browser_tv_model(iter1,model,L(i),H);
    end
  endfunction
  
  // a tree store with pixbufs from L 
  // which describes the browsers.
      
  window = gtkwindow_new ()
  window.set_title["Scicos Browser"]
  window.set_default_size[-1, 500]
  window.set_border_width[1]
  
  hbox = gtkhbox_new(homogeneous=%f,spacing=0);
  window.add[hbox]
  
  sw = gtkscrolledwindow_new ();
  sw.set_policy[GTK.POLICY_NEVER, GTK.POLICY_AUTOMATIC]
  sw.set_placement[GTK.CORNER_TOP_RIGHT]
  hbox.pack_start[sw,expand=%t,fill=%t,padding=0];
  
  // build an unfiled model 
  
  model = gtktreestore_new(list(list(%types.GdkPixbuf),"name",0,0),%f)

  scicos_icon_path = scicos_path+'/macros/scicos/scicos-images/';
  icons = glob(scicos_icon_path);
  
  dir_logo = scicos_icon_path + 'gtk-directory.png';
  pixbuf_dir = gdk_pixbuf_new_from_file(dir_logo);
  pixbuf_def = gdk_pixbuf_new_from_file(scicos_icon_path + 'VOID.png');

  // create a model 
  
  [H,L]=scicos_scm_browse(scs_m);
  scicos_browser_tv_model(none_create(),model,L,H);
  treeview=gtktreeview_new();
  treeview.set_model[model=model];
  targets = list( list("GTK_TREE_MODEL_ROW",GTK.TARGET_SAME_APP, 0)  );
  masks= ior(GDK.BUTTON1_MASK,GDK.BUTTON3_MASK);
  treeview.enable_model_drag_source[masks,targets, GDK.ACTION_COPY];
  //treeview.enable_model_drag_dest[targets, GDK.ACTION_COPY];
  // if this is true then we can re-order items by the 
  // above drag and drop. 
  // But it need to be false if we want to be able to drag to 
  // other widgets.
  treeview.set_reorderable[%f];
  
  cell = gtkcellrendererpixbuf_new ();
  col = gtktreeviewcolumn_new (renderer=cell,attrs=hash(pixbuf= 0));
  col.set_title["Icon"];
  treeview.append_column[col]
  
  cell = gtkcellrenderertext_new ();
  col  = gtktreeviewcolumn_new (renderer=cell,attrs=hash(text= 1));
  col.set_title["Texte"];
  treeview.append_column[col]
  
  sw.add[treeview]
  align = gtkalignment_new(xalign=0.5,yalign=0.0,xscale=0.0,yscale=0.0);
  hbox.pack_end[align,expand=%f,fill=%f,padding=0]
  window.show_all[];
endfunction

function H=scicos_diagram_to_list(scs_m)
  H.structure=list('Main');
  for k=1:length(scs_m.objs)
    o=scs_m.objs(k)
    if o.type =='Block' || o.type =='Text' then
      rpar=o.model.rpar;
      model=o.model
      if (model.sim(1)=='super' ..
	    | (model.sim(1)=='csuper'&& ~model.ipar.equal[1]) ..
	    | (model.sim(1)=='asuper'&& flag=='XML') ..
	    | (o.gui == 'DSUPER' && flag == 'XML')) then
	sblock=o.model.rpar;
      end
    end
  end
endfunction

function [H,SB]=scicos_scm_browse(scs_m,name='Main',H=hash(10))
  B=m2s([]);
  SB=list(name);
  for k=1:length(scs_m.objs)
    o=scs_m.objs(k)
    if o.type =='Block' || o.type =='Text' then
      model=o.model
      if (model.sim(1)=='super' ..
	    | (model.sim(1)=='csuper'&& model.ipar.equal[1]) ..
	    | (model.sim(1)=='asuper'&& flag=='XML') ..
	    | (o.gui == 'DSUPER' && flag == 'XML')) then
	sblock=o.model.rpar;
	[H,SB1]=scicos_scm_browse(o.model.rpar,name=o.gui,H=H);
	SB($+1)=SB1;
      elseif and(o.gui<>['SPLIT_f' 'CLKSPLIT_f' 'IMPSPLIT_f']) then 
	B.concatd[o.gui];
      end
    end
  end
  H(name)=B;
endfunction


