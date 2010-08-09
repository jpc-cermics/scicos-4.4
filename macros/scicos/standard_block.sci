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
    error("gui should be defined for nsp blocks");
    return;
  end 
  
  nin=size(model.in,1);
  if nin>0 then pin(nin,1)=0,else pin=[],end
  nout=size(model.out,1);
  if nout>0 then pout(nout,1)=0,else pout=[],end
  ncin=size(model.evtin,1);
  if ncin>0 then pein(ncin,1)=0,else pein=[],end
  ncout=size(model.evtout,1);
  if ncout>0 then peout(ncout,1)=0,else peout=[],end
  
  if type(gr_i,'string')<>'List' then gr_i=list(gr_i,8),end
  if isempty(gr_i(2)) then gr_i(2)=8,end
  if gr_i(2)==0 then gr_i(2)=[],end
  
  graphics=scicos_graphics(sz=sz,pin=pin,pout=pout,pein=pein,peout=peout, 
  gr_i=gr_i,exprs=label) 
  
  if model.sim(1)=='super' then
    o=scicos_block(graphics=graphics,model=model,gui='SUPER_f')
  else
    // [ln,mc]=where()
    // XXXX gui=mc(2))
    o=scicos_block(graphics=graphics,model=model,gui=gui);
  end
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

  select job
   case 'in' then //= Ports d'entree ==
    execstr('[x, y, typ] = '+macro+'(''getinputs'', bloc)')
    x = x(find(typ == 1))
    y = y(find(typ == 1))
    for i = 1:size(legende,'*')
      rect = xstringl(0, 0, legende(i))
      xstring(x(i)-rect(3),y(i),legende(i))
    end

   case 'out' then //= Ports de sortie ==
    execstr('[x, y, typ] = '+macro+'(''getoutputs'', bloc)')
    x = x(find(typ == 1))
    y = y(find(typ == 1))
    for i = 1:size(legende,'*'),
      xstring(x(i),y(i),legende(i))
    end
   case 'clkin' then //= Port d'entree evenement ==
    execstr('[x, y, typ] = '+macro+'(''getinputs'', bloc)')
    x = x(find(typ == -1))
    y = y(find(typ == -1))
    for i = 1:size(legende,'*')
      rect = xstringl(0, 0, legende(i))
      xstring(x(i)-rect(3),y(i)+(i-1)*rect(4),legende(i))
    end
   case 'clkout' then //= Ports de sortie evenement ==
    execstr('[x, y, typ] = '+macro+'(''getoutputs'', bloc)')
    x = x(find(typ == -1))
    y = y(find(typ == -1))
    for i = 1:size(legende,'*')
      rect = xstringl(0, 0, legende(i))
      xstring(x(i)-rect(3), y(i)-i*rect(4)*1.2,legende(i))
    end
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
  graphics=o.graphics
  model=o.model
  orig=graphics.orig;sz=graphics.sz;orient=graphics.flip;
  inp=size(model.in,1);clkinp=size(model.evtin,1);
  if orient then
    xo=orig(1)
    dx=-xf/7
  else
    xo=orig(1)+sz(1)
    dx=yf/7
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
      if %cpr<>list()&needcompile<>4 then
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
        
    from=objet.from
    if %cpr<>list() then
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
	if type(ind)==1 then
	  kl=%cpr.sim('outlnk')(%cpr.sim('outptr')(ind)+(from(2)-1))
	  beg=%cpr.sim('lnkptr')(kl)
	  fin=%cpr.sim('lnkptr')(kl+1)-1
	  txt = ['Compiled link memory zone  ','['+ string(beg)+','+string(fin)+']']
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


function scicos_show_info_notebook(L)
// Copyright Chancelier/Enpc 
// show L values in a notebook 
  win = gtkwindow_new()
  win.set_title["Block information"];
  win.set_size_request[400,400];
  
  box1 = gtkvbox_new(homogeneous=%f,spacing=0)
  win.add[box1]
  box1.show[]
  box2 = gtkvbox_new(homogeneous=%f,spacing=10)
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
  win.show[]
endfunction

function  vbox=scicos_show_table(cols,table)
// Copyright Chancelier/Enpc 
// show input-outputs in a GtkListStore 
  vbox = gtkvbox_new(homogeneous=%f,spacing=8);
  sw = gtkscrolledwindow_new();
  sw.set_shadow_type[GTK.SHADOW_ETCHED_IN]
  sw.set_policy[GTK.POLICY_NEVER,GTK.POLICY_AUTOMATIC]
  vbox.pack_start[ sw,expand=%t,fill=%t,padding=0]
  if ~isempty(table) then 
    model = gtkliststore_new(table);
    // create tree view */
    treeview = gtktreeview_new(model);
    treeview.set_rules_hint[%t];
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

