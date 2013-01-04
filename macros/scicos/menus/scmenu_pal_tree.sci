function scmenu_pal_tree()
  Cmenu=''
  scicos_widgets($+1)=hash(id=scicos_palette_treeview(),open=%t,what='PalTree');
endfunction

// simple demo of treestore with pixmap
// the treestore model have two levels 
// and is build with append.

function window=scicos_palette_treeview(L)
  if nargin <= 0 then 
    H=%scicos_pal;
  end
  
  function scicos_palette_tv_model(iter,model,H)
    L=H.structure;
    for i=1:length(L)
      //single blk
      if type(H.contents(L(i)),'short')=='s' then
         blk=H.contents(L(i))
         [pixbuf]=get_gdk_pixbuf(%scicos_gif,blk)
         if type(iter,'short')<>'none' then
           iter1=model.append[iter,list(list(pixbuf),L(i))];
         else
           iter1=model.append[list(list(pixbuf),L(i))];
         end
      //palette of single blk
      elseif type(H.contents(L(i)),'short')=='l' then
        if type(iter,'short')<>'none' then
          iter1=model.append[iter,list(list(pixbuf_dir),L(i))];
        else
          iter1=model.append[list(list(pixbuf_dir),L(i))];
        end
        sub=H.contents(L(i));
        for j=1:size(sub,'*')
          [pixbuf]=get_gdk_pixbuf(%scicos_gif,sub(j))
          // pb = pixbuf.scale_simple[ 64,64, GDK.INTERP_NEAREST];
          // we assume that path is of length 2 (paletteid,blockid).
          model.append[iter1,list(list(pixbuf),sub(j),1,2)];
        end
      //palette
      elseif type(H.contents(L(i)),'short')=='h' then
        if type(iter,'short')<>'none' then
          iter1=model.append[iter,list(list(pixbuf_dir),L(i))];
        else
          iter1=model.append[list(list(pixbuf_dir),L(i))];
        end
        scicos_palette_tv_model(iter1,model,H.contents(L(i)))
      end
    end
  endfunction

  function remove_scicos_widget(wingtkid)
    global scicos_widgets
    for i=1:length(scicos_widgets)
      if wingtkid.equal[scicos_widgets(i).id] then
        scicos_widgets(i).open=%f;break
      end
    end
  endfunction
  
  // a tree store with pixbufs from L 
  // which describes the palettes.
      
  window = gtkwindow_new ()
  window.set_title["Scicos PalTree"]
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

  [pixbuf_dir]=get_gdk_pixbuf(%scicos_gif,'gtk-directory')

  scicos_palette_tv_model(none_create(),model,H)
      
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
  window.connect["destroy", remove_scicos_widget, list(window)];
  window.show_all[];
endfunction

