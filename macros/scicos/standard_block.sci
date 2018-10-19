function [x,y,typ]=standard_block(job,block,arg2=[])
//--------------------------------------------------
//%Description
// job=='plot' :      block drawing
//                    block is block data structure
//                    arg2 :unused
// job=='getinputs' : return position and type of inputs ports
//                    block is block data structure
//                    x  : x coordinates of ports
//                    x  : y coordinates of ports
//                    typ: type of ports
// job=='getoutputs' : return position and type of outputs ports
//                    block is block data structure
//                    x  : x coordinates of ports
//                    x  : y coordinates of ports
//                    typ: type of ports
// job=='getorigin'  : return block origin coordinates
//                    x  : x coordinates of block origin
//                    x  : y coordinates of block origin
// job=='set'        : block parameters acquisition
//                    block is block data structure
//                    x is returned block data structure
// job=='define'     : corresponding block data structure initialisation
//                    block: name of block parameters acquisition macro (init)
//                    x   : block data structure
//%Block data-structure definition
// bl=list('Block',graphics,model,init,'standard_block')
//  graphics=list([xo,yo],[l,h],orient,label)
//          xo          - x coordinate of block origin
//          yo          - y coordinate of block origin
//          l           - block width
//          h           - block height
//          orient      - boolean, specifies if block is tilded
//          label       - string block label
//  model=list(eqns,#input,#output,#clk_input,#clk_output,state,rpar,ipar,
//            typ,firing,input_time_dep)
//          eqns        - function name (in string form if fortran routine)
//          #input      - number of inputs
//          #output     - number of ouputs
//          #clk_input  - number of clock inputs
//          #clk_output - number of clock outputs
//          state       - vector (column) of initial condition
//          rpar        - vector (column) of real parameters
//          ipar        - vector (column) of integer parameters
//          typ         - string: 'c' if block is continuous, 'd' if discrete
//                        'z' if zero-crossing.
//
// Copyright INRIA
  x=[];y=[];typ=[];
  select job
   case 'plot' then
     standard_draw(block)
   case 'getinputs' then
    [x,y,typ]=standard_inputs(block)
   case 'getoutputs' then
    [x,y,typ]=standard_outputs(block)
   case 'getorigin' then
    [x,y]=standard_origin(block)
   case 'set' then
    execstr('[model,label,ok]='+block(5)+'()')
    if ok then
      graphics=block(2);graphics(4)=label;
      x=list('Block',graphics,model,block(4),block(5))
    end
   case 'define' then
    model=list(block,1,1,[],[],[],[],[],[],%f,[%f %f],' ',list())
    x=standard_define([2 2],model,[])
  end
endfunction

function o=standard_define(sz,model,label,gr_i,gui)
//--------------------------------------------------
//initialize graphic part of the block data structure
// Copyright INRIA
  if nargin <= 3 then gr_i = [] ; end
  if nargin <= 4 then gui = "" ;
    if %f then
      error("gui should be defined for nsp blocks");
      return;
    else
      // we can recover the name of the calling function
      // by getting the calling frame name
      S=exists();// matrix
      if size(S,'*') >= 2 then
	gui=S(2);
      else
	error("gui should be defined for nsp blocks");
      end
    end
  end
  if model.sim(1)=='super' then gui= 'SUPER_f';end
  
  graphics=standard_graphics(sz,model,label,gr_i=gr_i)
  o=scicos_block(graphics=graphics,model=model,gui=gui);
endfunction

function graphics=standard_graphics(sz,model,label,gr_i=[])
  // initialize a graphics structure from model, label and gr_i
  // Copyright INRIA
  nin=size(model.in,1);
  H=hash(10);H.sz=sz;H.exprs = label;
  H.pin=[];H.pout=[];H.pein=[];H.peout=[];H.in_implicit=[]; H.out_implicit=[];
  if nin>0 then pin(nin,1)=0; H.pin = pin;end 
  nout=size(model.out,1);
  if nout>0 then pout(nout,1)=0; H.pout = pout;end;
  ncin=size(model.evtin,1);
  if ncin>0 then pein(ncin,1)=0; H.pein = pein;end 
  ncout=size(model.evtout,1);
  if ncout>0 then peout(ncout,1)=0; H.peout= peout;end
  if model.iskey['intype'] then  H.in_implicit = model.intype(:);end
  if model.iskey['outtype'] then  H.out_implicit = model.outtype(:);end
  
  if type(gr_i,'string')<>'List' then
    gr_i=list(gr_i,8)
  else
    if length( gr_i) < 2 || isempty(gr_i(2)) then gr_i(2)=8;end 
    if gr_i(2)==0 then gr_i(2)=[],end;
  end
  H.gr_i = gr_i;
  graphics=scicos_graphics(H(:));
endfunction

function standard_etiquette(bloc, legende, job)
//--------------------------------------------------
// standard_etiquette - Draw legends on scicos blocks
//
//%Syntaxe
// standart_etiquette(bloc, legende, 'in')
// standart_etiquette(bloc, legende, 'out')
// standart_etiquette(bloc, legende, 'clkin')
// standart_etiquette(bloc, legende, 'clkout')
// standart_etiquette(bloc, legende, 'centre')
// standart_etiquette(bloc, couleur, 'croix')
//
//%Inputs
// bloc    : Scicos bloc data structure
// legende : vector of character strings to draw or color code for job='croix'
// job     : Character string specifies where legend has to be drawn
//           'in'     : input ports
//           'out'    : output ports
//           'clkin'  : event input ports
//           'clkout' : event output ports
//           'centre' : in the block shape
//           'croix'  : draw a cross in the block shape
//%Origine
// E. Demay E.D.F 97
//
// Copyright INRIA
//= Initialisations ==
//GRAPHIQUE = 2;ORIGINE = 1;TAILLE = 2
//macro = bloc(5)
  macro = bloc.gui
  fz= 2*acquire("%zoom",def=1)*4;
  fnt=xget('font');
  is_flip=bloc.graphics.flip

  select job

   case 'in' then //= Ports d'entree ==
    execstr('[x, y, typ] = '+macro+'(''getinputs'', bloc)')
    x = x(find(typ == 1))
    y = y(find(typ == 1))
    xset('font', options.ID(1)(1), options.ID(1)(2));
    if is_flip then posx='right' else posx='left', end
    for i = 1:size(legende,'*')
      xstring(x(i),y(i),legende(i),posx=posx,posy='bottom',size=fz)
    end
    xset('font', fnt(1), fnt(2));

   case 'out' then //= Ports de sortie ==
    execstr('[x, y, typ] = '+macro+'(''getoutputs'', bloc)')
    x = x(find(typ == 1))
    y = y(find(typ == 1))
    xset('font', options.ID(1)(1), options.ID(1)(2));
    if is_flip then posx='left' else posx='right', end
    for i = 1:size(legende,'*')
      xstring(x(i),y(i),legende(i),posx=posx,posy='bottom',size=fz)
    end
    xset('font', fnt(1), fnt(2));

   case 'clkin' then //= Port d'entree evenement ==
    execstr('[x, y, typ] = '+macro+'(''getinputs'', bloc)')
    x = x(find(typ == -1))
    y = y(find(typ == -1))
    xset('font', options.ID(1)(1), options.ID(1)(2));
    for i = 1:size(legende,'*')
      xstring(x(i),y(i),legende(i),posx='left',posy='bottom',size=fz)
    end
    xset('font', fnt(1), fnt(2));

   case 'clkout' then //= Ports de sortie evenement ==
    execstr('[x, y, typ] = '+macro+'(''getoutputs'', bloc)')
    x = x(find(typ == -1))
    y = y(find(typ == -1))
    xset('font', options.ID(1)(1), options.ID(1)(2));
    for i = 1:size(legende,'*')
      xstring(x(i),y(i),legende(i),posx='left',posy='up',size=fz)
    end
    xset('font', fnt(1), fnt(2));

   case 'centre' then //= Centre du bloc ==
		      //origine = bloc(GRAPHIQUE)(ORIGINE)
		      // taille = bloc(GRAPHIQUE)(TAILLE)
		      origine = bloc.graphics.orig
		      taille = bloc.graphics.sz
		      xstringb(origine(1), origine(2), legende, taille(1), taille(2), 'fill')

   case 'croix' then //= Identification des bases de donnees ==
		     // origine = bloc(GRAPHIQUE)(ORIGINE)
		     //taille = bloc(GRAPHIQUE)(TAILLE)
		     origine = bloc.graphics.orig
		     taille = bloc.graphics.sz
		     nx = [origine(1), origine(1)+taille(1); origine(1), origine(1)+taille(1)]
		     ny = [origine(2), origine(2)+taille(2); origine(2)+taille(2), origine(2)]
		     color = xget('color')
		     xsegs(nx', ny', legende)
		     xset('color', color)
  end
endfunction


function [x,y,typ]=standard_inputs(o)
//--------------------------------------------------
// get position of inputs ports and clock inputs port for a standard block
//  the input ports are located on the left (or rigth if tilded) vertical
//    side of the block, regularly located from top to bottom
//  the clock input ports are located on the top horizontal side
//    side of the block, regularly located from left to right
// Copyright INRIA
  xf=60
  yf=40
  typ=[]
  graphics=o.graphics
  model=o.model
  orig=graphics.orig;sz=graphics.sz;orient=graphics.flip;
  inp=size(model.in,1);clkinp=size(model.evtin,1);
  if orient then
    xo=orig(1)
    dx=-xf/7
  else
    xo=orig(1)+sz(1)
    dx=xf/7
  end
  if inp==0 then
    x=[];y=[],typ=[]
  else
    y=orig(2)+sz(2)-(sz(2)/(inp+1))*(1:inp)
    x=(xo+dx)*ones(size(y))
    for k=1:inp
      if isempty(o.graphics.in_implicit) then
        typ=ones(size(x))
      else
        if o.graphics.in_implicit(k)=='E' then
          typ=[typ ones(size(x(k)))]
        elseif  o.graphics.in_implicit(k)=='I' then
          typ=[typ 2*ones(size(x(k)))]
	elseif  o.graphics.in_implicit(k)=='B' then //buses
	  typ=[typ 3*ones(size(x(k)))]
        end
      end
    end
  end
  if clkinp<>0 then
    x=[x,orig(1)+(sz(1)/(clkinp+1))*(1:clkinp)]
    y=[y,(orig(2)+yf/7+sz(2))*ones_new(1,clkinp)]
    typ=[typ,-ones_new(1,clkinp)]
  end
endfunction

function [x,y]=standard_origin(o)
//--------------------------------------------------
// Copyright INRIA
  orig=o.graphics.orig
  x=orig(1);y=orig(2);
endfunction

function [x,y,typ]=standard_outputs(o)
//--------------------------------------------------
// get position of inputs ports and clock inputs port for a standard block
//  the output ports are located on the right (or left if tilded) vertical
//    side of the block, regularly located from bottom to top
//  the clock output ports are located on the bottom horizontal side
//     of the block, regularly located from left to right
// Copyright INRIA
  xf=60
  yf=40
  typ=[]
  graphics=o.graphics
  model=o.model
  orig=graphics.orig;sz=graphics.sz;orient=graphics.flip;

  out=size(model.out,1);clkout=size(model.evtout,1);

  if orient then
    xo=orig(1)+sz(1)
    dx=xf/7
  else
    xo=orig(1)
    dx=-xf/7
  end


  // output port location
  if out==0 then
    x=[];y=[],typ=[]
  else
    y=orig(2)+sz(2)-(sz(2)/(out+1))*(1:out)
    x=(xo+dx)*ones(size(y))
    for k=1:out
      if isempty(o.graphics.out_implicit) then
        typ=ones(size(x))
       else
         if o.graphics.out_implicit(k)=='E' then
           typ=[typ ones(size(x(k)))]
         elseif  o.graphics.out_implicit(k)=='I' then
           typ=[typ 2*ones(size(x(k)))]
	 elseif  o.graphics.out_implicit(k)=='B' then
	   typ=[typ 3*ones(size(x(k)))]
         end
       end
    end
  end
  // clock output  port location
  if clkout<>0 then
    x=[x,orig(1)+(sz(1)/(clkout+1))*(1:clkout)]
    y=[y,(orig(2)-yf/7)*ones_new(1,clkout)]
    typ=[typ,-ones_new(1,clkout)]
  end
endfunction


function [texte,L_out] = standard_document(objet, k)
//--------------------------------------------------
// standard_document - documentation d'un bloc Scicos
// Copyright INRIA
  txt=m2s([]);
  L_out=list();
  type_objet = objet.type
  //
  select type_objet
   case 'Block' then
    //- Block informations
    //- Initialisations
    modele = objet.model
    graphique = objet.graphics
    macro = objet.gui
    //
    fonction = modele.sim
    if prod(size(fonction)) > 1 then
      if fonction(2) == 0 then
	language = '0 (Scilab function type Scicos 2.2)'
      elseif fonction(2) == 1  then
	language = '1 (Fortran or C code)'
      elseif fonction(2) == 2 then
	language = '2 (C code)'
      elseif fonction(2) == 3 then
	language = '3 (Scilab function)'
      elseif fonction(2) < 0  then
	language = '<0 (synchro block)'
      elseif fonction(2) <10000 then
	language = string(fonction(2))+'  (dynamic link or)'
      else
	language = string(fonction(2))+'  (implicit bloc)'
      end
    else
      language = '0 (Scilab function type Scicos 2.2)'
    end
    //

    if modele.blocktype == 'l' then
      typ= 'synchro'
    elseif modele.blocktype == 'z'
      typ= 'zero-crossing'
    elseif modele.blocktype == 'm'
      typ = 'memory'
    else
      typ = 'regular'
    end
    //
    if modele.dep_ut(1) then
      dependance_u = 'yes'
    else
      dependance_u = 'no'

    end

    if modele.dep_ut(2) then
      dependance_t = 'yes'
    else
      dependance_t = 'no'
    end
    //
    identification = graphique.id

    //- general informations
    //-----------------------

    if modele.sim(1)=='super'|modele.sim(1)=='csuper' then
      texte = ['object type                ','Super Block';
	       'Identification             ',identification;
	       'Object number in diagram   ',string(k);
	       'Drawing function           ',macro]
    else
      simul_fun = fonction(1);
      if type(simul_fun,'short')=='pl' then
	// fonction(1) is a macro then get its name.
	simul_fun = simul_fun.get_name[];
      end
      texte = ['object type                ','standard block';
	       'Identification             ',identification;
	       'Object number in diagram   ',string(k);
	       'Drawing function           ',macro;
	       'Simulation function        ',simul_fun;
	       'Simulation Function type   ',language;
	       'Bloc type                  ',typ;
	       'Direct feed through        ',dependance_u;
	       'Permanently active         ',dependance_t]
      if ~%cpr.equal[list()] &needcompile<>4 then
	cor = %cpr.cor
	corinv = %cpr.corinv
	path=list()
	for kp=1:size(super_path,'*'),path(kp)=super_path(kp);end
	path($+1)=k
	ind=cor(path)
	if ind>0&ind<=size(corinv) then
	  txt = ['Compiled structure Index   ',string(cor(path))]
	else
	  txt = ['Compiled structure Index   ','suppressed']
	end
      else
	txt = ['Compiled structure Index   ',' Not available']
      end
      texte=[texte;txt]
    end


    L_out=list()
    L_out(1)= list('General',['',''],texte)

    texte=catenate(texte,col=':')

    //- gather Input-Output informations
    //-----------------------------------
    title_tableau = ['Port type', 'Number', 'Size', 'Link']
    tableau=m2s([]);
    //- Entrees standard
    for i = 1 : min(size(modele.in,'*'),size(graphique.pin,'*'))
      tableau = [tableau; 'Regular input', string(i),
		 string(modele.in(i)), string(graphique.pin(i))]
    end
    //- Sorties standard
    for i = 1 : min(size(modele.out,'*'),size(graphique.pout,'*'))
      tableau = [tableau; 'Regular output', string(i),
		 string(modele.out(i)), string(graphique.pout(i))]
    end
    //- Entrees evenements
    for i = 1 : min(size(modele.evtin,'*'),size(graphique.pein,'*'))
      tableau = [tableau; 'Event input', string(i),
		 string(modele.evtin(i)), string(graphique.pein(i))]
    end
    //- Sorties evenements
    for i = 1 : min(size(modele.evtout,'*'),size(graphique.peout,'*'))
      tableau = [tableau; 'Event output', string(i),
		 string(modele.evtout(i)), string(graphique.peout(i))]
    end
    //
    L_out(2)= list('Input/Output',title_tableau,tableau);

    function res = tabule(tab)
    // All the strings in the same column are changed 
    // so as to be of the same length (white padding on left). 
    // string of type '-' are to be expanded. 
    // Then the columns of tab are concatenated with separator '|' 
    // FIXME: this option should be added to catenate 
      [n_lignes, n_colonnes] = size(tab)
      res = smat_create(n_lignes,1,val="|");
      for i = 1 : n_colonnes
	largeur = max(length(tab(:, i)))
	col = sprintf('%*s',largeur*ones_new(n_lignes,1),tab(:,i));
	col=strsubst(col,sprintf('%*s',largeur,'-'),catenate(smat_create(largeur,1,val='-')));
	res = res + col + "|";
      end
    endfunction
    
    texte = [texte; 'Input / output';
	     '--------------';
	     ' '
	     tabule(tableau); ' ']

    //- Documentation
    //--------------------------------------
    documentation=objet.doc
    if type(documentation,'short')=='l' then
      if size(documentation,'*')>=2 then
	funname=documentation(1);doc=documentation(2)
	if type(funname,'short')=='s' then
	  ierr=execstr('docfun='+funname,errcatch=%t)
	  if ierr==%f then
	    x_message('function '+funname+' not found')
	    return
	  end
	else
	  docfun=funname
	end
	ierr=execstr('doc=docfun(''get'',doc)',errcatch=%t)
	if ierr==%t & ~isempty(doc) then
	  texte = [texte; 'Documentation';
		   '-------------';
		   ' '
		   doc; ' ']
	  L_out(3)= list('Documentation',"",doc);
	end
      end
    end

   case 'Link' then
    //- Link informations
    //- Initialisation
    identification = objet.id
    if objet.ct(2) == 1 then
      sous_type = 'Regular Link'
    else
      sous_type = 'Event link'
    end
    //- Informations generales
    texte = ['Object type                ',sous_type;
	     'Object Identification      ',identification';
	     'Object number in diagram   ',string(k)];
    // XXX: faire la meme chose avec to si from n'abouti pas 
    // jpc 2017. 
    
    from=objet.from
    if ~%cpr.equal[list()] then
      if sous_type == 'Regular Link' then
	while %t
	  if scs_m.objs(from(1)).model.sim(1)=='lsplit' then
	    __link=scs_m.objs(from(1)).graphics.pin
	    from=scs_m.objs(__link).from
	  else
	    break
	  end
	end
	
	cor = %cpr.cor
	path=list()
	for kp=1:size(super_path,'*'),path(kp)=super_path(kp);end
	path($+1)=from(1)
	ind=cor(path)
	if type(ind,'short')=='m'& ~isequal(ind,0) then
          kl=%cpr.sim('outlnk')(%cpr.sim('outptr')(ind)+(from(2)-1));
          kmin=[];kmax=[];count=1;
          for j=1:size(%cpr.state('outtb'))
            if j==kl then
              kmin=count;
              kmax=count+size(%cpr.state.outtb(j),'*')-1;
              break
            else
              count=count+size(%cpr.state.outtb(j),'*');
            end
          end
          txt = ['Compiled link memory zone  ','outtb('+string(kl)+')']
          txt = [txt;
                 'Area                       ','['+string(kmin)+':'+string(kmax)+']']
          txt = [txt;
                 'Type                       ',typeof(%cpr.state.outtb(kl))']
          txt = [txt;
                 'Size                       ',sci2exp(size(%cpr.state.outtb(kl)))']
	else
	  txt = ['Compiled link memory zone  ','Not available']
	end
      end
    else
      txt = ['Compiled link memory zone  ','Not available']
    end

    texte=[texte;txt]

    L_out=list()
    L_out(1)= list('General',['',''],texte)
    texte=catenate(texte,col=':')

    //- Connexions

    tit_tableau = ['','Block', 'Port' ];
    tableau=['From',string(objet.from(1:2));
	     'to', string(objet.to(1:2))];
    L_out(2)=list('Connections',tit_tableau,tableau);
    texte = [texte;
	     'Connections';
	     '-----------';' ';
	     catenate(tit_tableau,col=' ');
	     catenate(tableau,col=' ');' ']
  else
    texte=[]
  end
endfunction

function win=scicos_show_info_notebook(L)
// Copyright Chancelier/Enpc
// show L values in a notebook
  win = gtkwindow_new()
  win.set_title["Block information"];
  win.set_size_request[400,400];

  if exists('gtk_get_major_version','function') then
    box1 = gtk_box_new(GTK.ORIENTATION_VERTICAL,spacing=10);
  else
    box1 = gtkvbox_new(homogeneous=%f,spacing=10);
  end
  win.add[box1]
  box1.show[]

  if exists('gtk_get_major_version','function') then
    box2 = gtk_box_new(GTK.ORIENTATION_VERTICAL,spacing=10);
  else
    box2 = gtkvbox_new(homogeneous=%f,spacing=10);
  end

  box2.set_border_width[10]
  box1.pack_start[box2]
  box2.show[]
  notebook = gtknotebook_new()
  notebook.set_tab_pos[GTK.POS_TOP];

  box2.pack_start[notebook]
  notebook.show[]
  for i = 1:length(L)
    page=L(i);
    vbox=scicos_show_table(page(2),page(3))
    label = gtklabel_new(str=page(1));
    notebook.append_page[vbox,label];
  end

  function remove_scicos_widget(wingtkid)
    // register that the window wingtkid was closed 
    scicos_manage_widgets('close', wingtkid=wingtkid);
  endfunction
  
  win.connect["destroy", remove_scicos_widget, list(win)];
  win.set_type_hint[GDK.WINDOW_TYPE_HINT_MENU]
  win.show[]
  win.present[];
  scicos_manage_widgets('register', wingtkid=win, wintype='GetInfo');
endfunction

function  vbox=scicos_show_table(cols,table)
// Copyright Chancelier/Enpc
// show input-outputs in a GtkListStore

  if exists('gtk_get_major_version','function') then
    vbox = gtk_box_new(GTK.ORIENTATION_VERTICAL,spacing=8);
  else
    vbox = gtkvbox_new(homogeneous=%f,spacing=8);
  end
  sw = gtkscrolledwindow_new();
  sw.set_shadow_type[GTK.SHADOW_ETCHED_IN]
  sw.set_policy[GTK.POLICY_NEVER,GTK.POLICY_AUTOMATIC]
  vbox.pack_start[ sw,expand=%t,fill=%t,padding=0]
  if ~isempty(table) then
    model = gtkliststore_new(table);
    // create tree view */
    treeview = gtktreeview_new(model);
    // treeview.set_rules_hint[%t];
    treeview.set_search_column[3];
    sw.add[treeview]
    renderer = gtkcellrenderertext_new ();
    for i=1:size(table,'c')
      col = gtktreeviewcolumn_new(title=cols(1,i),renderer=renderer,attrs=hash(text=i-1));
      col.set_sort_column_id[i-1];
      treeview.append_column[col];
    end
  end
  vbox.show_all[];
endfunction

function [texte] = mini_standard_document(objet)

  function [texte] = modele_texte(modele)
    //dep_ut
    du = sci2exp(modele.dep_ut(1));
    dt = sci2exp(modele.dep_ut(2));
    texte=[sprintf("<tt><small><small>dep_ut [%s;%s]</small></small></tt>",du,dt)];
    //regular input ports
    sz_in=size(modele.in,'*');
    sz_in2=size(modele.in2,'*');
    sz_intyp=size(modele.intyp,'*');
    //adjust dimension of in2
    if sz_in2 < sz_in then
      modele.in2=[modele.in2;ones(sz_in-sz_in2,1)]
    end
    //adjust dimension of intyp
    if sz_intyp<sz_in then
      modele.intyp=[modele.intyp;ones(sz_in-sz_intyp,1)]
    end
    for i = 1 : min(size(modele.in,'*'),size(graphique.pin,'*'))
      texte=[texte
             "<tt><small><small>in"+string(i)+"    ["+...
             string(modele.in(i))+";"+string(modele.in2(i))+"]"+...
             "("+string(modele.intyp(i))+")</small></small></tt>"]
    end
    //regular output ports
    sz_out=size(modele.out,'*');
    sz_out2=size(modele.out2,'*');
    sz_outtyp=size(modele.outtyp,'*');
    //adjust dimension of out2
    if sz_out2 < sz_out then
      modele.out2=[modele.out2;ones(sz_out-sz_out2,1)]
    end
    //adjust dimension of outtyp
    if sz_outtyp<sz_out then
      modele.outtyp=[modele.outtyp;ones(sz_out-sz_outtyp,1)]
    end
    for i = 1 : min(size(modele.out,'*'),size(graphique.pout,'*'))
      texte=[texte
             "<tt><small><small>out"+string(i)+"   ["+...
             string(modele.out(i))+";"+string(modele.out2(i))+"]"+...
             "("+string(modele.outtyp(i))+")</small></small></tt>"]
    end
  endfunction
  
  type_objet = objet.type
  
  select type_objet
   //blk
   case 'Block' then
    modele = objet.model
    graphique = objet.graphics
    macro = objet.gui
    fonction = modele.sim
    if prod(size(fonction)) == 1 then
      fonction=list(fonction,0)
    end

    //gui
    texte=[macro]

    //simulation function
    if %f && modele.sim(1)=='super' then
      texte=[texte;
             "<tt><small><small>Superblock</small></small></tt>";
	     modele_texte(modele)];
    elseif modele.sim(1)=='csuper' then
      texte=[texte;
             "<tt><small><small>Compiled Superblock</small></small></tt>";
	     modele_texte(modele)];
    else
      if is_modelica_block(objet) then
        texte=[texte;
               "<tt><small><small>Modelica block</small></small></tt>"]
        simul_fun = fonction(1);
        texte=[texte
               "<tt><small><small>sim    "+simul_fun+"</small></small></tt>"];
	texte=[texte;modele_texte(modele)];

      else
        if prod(size(fonction)) == 1 then
          fonction=list(fonction,0)
        end
        simul_fun = fonction(1);
        if type(simul_fun,'short')=='pl' then
          // fonction(1) is a macro then get its name.
          simul_fun = simul_fun.get_name[];
        end
        texte=[texte
               "<tt><small><small>sim    "+simul_fun+"("+...
               string(fonction(2))+")"+"</small></small></tt>"]
	texte=[texte;modele_texte(modele)];
        //that's all
      end
    end
    //lnk
   case 'Link' then
     //TODO
     texte=[]
   else
     texte=[]
  end
endfunction
