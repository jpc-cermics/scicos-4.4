function PalTree_()
  Cmenu=''
  scicos_palette_treeview();
endfunction

// simple demo of treestore with pixmap
// the treestore model have two levels 
// and is build with append.

function scicos_palette_treeview(L)
  if nargin <= 0 then 
    L=acquire('%scicos_pal_list');
  end
  // a tree store with pixbufs from L 
  // which describes the palettes.
      
  window = gtkwindow_new ()
  window.set_title["Scicos PalTree"]
  window.set_default_size[-1, 500]
  window.set_border_width[1]
  
  hbox = gtkhbox_new(homogeneous=%f,spacing=8);
  window.add[hbox]
  
  sw = gtkscrolledwindow_new ();
  sw.set_policy[GTK.POLICY_NEVER, GTK.POLICY_AUTOMATIC]
  sw.set_placement[GTK.CORNER_TOP_RIGHT]
  hbox.pack_start[sw,expand=%t,fill=%f,padding=0]
  
  // build an unfiled model 
  
  model = gtktreestore_new(list(list(%types.GdkPixbuf),"name",0,0),%f)

  scicos_icon_path = scicos_path+'/macros/scicos/scicos-images/';
  icons = glob(scicos_icon_path);
  
  dir_logo = scicos_icon_path + 'gtk-directory.png';
  pixbuf_dir = gdk_pixbuf_new_from_file(dir_logo);
  pixbuf_def = gdk_pixbuf_new_from_file(scicos_icon_path + 'VOID.png');
  
  for i=2:size(L);
    sub=L(i);
    iter=model.append[list(list(pixbuf_dir),sub(1))];
    for j=2:length(sub)
      icon = scicos_icon_path + sub(j).name + '.png' ;
      ok = execstr('pixbuf = gdk_pixbuf_new_from_file(icon);',errcatch=  %t);
      if ~ok then 
	pixbuf = pixbuf_def
      end
      // pb = pixbuf.scale_simple[ 64,64, GDK.INTERP_NEAREST];
      path=sub(j).path;
      // we assume that path is of length 2 (paletteid,blockid).
      model.append[iter,list(list(pixbuf),sub(j).name,path(1),path(2))];
    end
  end
    
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

