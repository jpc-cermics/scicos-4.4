function [x,y,ok,gc]=edit_curv(x,y,job,tit,gc)
//   mod_curv  - Edition  de courbe interactive
//%Syntaxe
//  [x,y,ok]=mod_curv(xd,yd,job,tit)
//%Parametres
//  xd    :  vecteur des abscisses donnees (eventuellement [])
//  yd    :  vecteur des ordonnees donnees (eventuellement [])
//  job   :  chaine de 3 caracteres  specifiant les operations
//           permises:
//            - Si la chaine contient le caractere 'a', il est 
//              possible d'ajouter des points aux donnees, sinon
//              il est seulement possible de les deplacer
//            - Si la chaine contient le caractere 'x', il est 
//              possible de deplacer les points horizontalement
//            - Si la chaine contient le caractere 'y', il est 
//              possible de deplacer les points verticalement
//  tit   : liste de trois chaines de caracteres
//          tit(1) : titre de la courbe (peut etre un vecteur colonne)
//          tit(2) : label de l'axe des abscisses
//          tit(3) : label de l'axe des ordonnees
//  x     : vecteur des abscisses resultat
//  y     : vecteur des ordonnees resultat
//  ok    : vaut %t si la sortie as ete demandee par le menu Ok
//           et  %f si la sortie as ete demandee par le menu Abort
//%menus
//  Ok    : sortie de l'editeur et retour de la courbe editee
//  Abort : sortie de l'editeur et retour au donnes initiales 
//  Undo  : annulation de la derniere modification
//  Size  : changement des bornes du graphique
//  Grids : changement des graduations du graphique
//  Clear : effacement de la courbe (x=[] et y=[]) (sans quitter l'editeur)
//  Read  : lecture de la courbe a partir d'un fichier d'extension .xy
//  Save  : sauvegarde binaire (sur un fichier d'extension .xy) de 
//          la courbe
//!
//origine: serge Steer, Habib Jreij INRIA 1993
//Copyright INRIA
//adapted to nsp and xor removed (jpc)
//
  xset('default')
  //in line definition of get_click
  
  function [btn,xc,yc,win,Cmenu]=get_click(curwin,flag)
    if ~or(winsid() == curwin) then   Cmenu = 'Quit';return,end;
    if nargout == 1 then;
      [btn, xc, yc, win, str] = xclick(flag);;
    else;
      [btn, xc, yc, win, str] = xclick();;
    end;
    if btn == -100 then;
      if win == curwin then;
	Cmenu = 'Quit';
      else;
	Cmenu = 'Open/Set';
      end;
      return;
    end;
    if btn == -2 then;
      // click in a dynamic menu
      xc=0;yc=0
      if ~isempty(strindex(str,'_'+string(curwin)+'(')) then
	// click in a scicos dynamic menu
	// note that this would not be valid if multiple scicos 
	execstr('Cmenu='+part(str,9:length(str)-1))
	execstr('Cmenu='+Cmenu);
	return;
      else
	execstr(str,errcatch=%t);
	Cmenu='Ignore';
	return;
      end
    end;
    Cmenu="";
  endfunction
  // 
  ok=%t
  if nargin==0 then x=[];y=[],end;
  if nargin==1 then y=x;x=(1:size(y,'*'))',end
  if nargin<3  then job='axy',end
  if nargin<4 then tit=[' ',' ',' '],end
  if size(tit,'*')<3 then tit(3)=' ',end
  //
  [mx,nx]=size(x);x.redim[1,-1];
  [my,ny]=size(y);y.redim[1,-1];
  xsav=x;ysav=y;xs=x;ys=y;
  //
  lj=length(job)
  add=0;modx=0;mody=0
  for k=1:lj
    jk=part(job,k)
    select jk
     case 'a' then add=1,
     case 'x' then modx=1
     case 'y' then mody=1
    else error('parametre job incorrect')
    end
  end
  eps=0.03
  symbsiz=0.2
  // bornes initiales du graphique
  if nargin<5 then
    if mx<>0 then
      xmx=max(x);xmn=min(x)
      ymx=max(y);ymn=min(y)
      dx=xmx-xmn;dy=ymx-ymn
      if dx==0 then dx=max(xmx/2,1),end
      xmn=xmn-dx/10;xmx=xmx+dx/10
      if dy==0 then dy=max(ymx/2,1),end;
      ymn=ymn-dy/10;ymx=ymx+dy/10;
    else
      xmn=0;ymn=0;xmx=1;ymx=1;dx=1;dy=1
    end
    rect=[xmn,ymn,xmx,ymx];
    axisdata=[2 10 2 10]
    gc=list(rect,axisdata)
  else
    [rect,axisdata]=gc(1:2)
    xmn=rect(1);ymn=rect(2);xmx=rect(3);ymx=rect(4)
    dx=xmx-xmn;dy=ymx-ymn
  end
  xbasc()
  auto=%t

  // Set menus and callbacks
  menu_d=['Read','Save','Clear']
  menu_e=['Undo','Size','Grids','Replot','Ok','Abort']
  menus=list(['Edit','Data'],menu_e,menu_d)
  w='menus(2)(';rpar=')'
  Edit=w(ones(size(menu_e)))+string(1:size(menu_e,'*'))+rpar(ones(size(menu_e)))
  w='menus(3)(';rpar=')'
  Data=w(ones(size(menu_d)))+string(1:size(menu_d,'*'))+rpar(ones(size(menu_d)))

  xselect()
  curwin=xget('window')
  unsetmenu(curwin,'File',1) //clear
  unsetmenu(curwin,'File',2) //select
  unsetmenu(curwin,'File',6) //load
  unsetmenu(curwin,'File',7) //close
  unsetmenu(curwin,'3D Rot.')
  //
  execstr('Edit_'+string(curwin)+'=Edit')
  execstr('Data_'+string(curwin)+'=Data')
  menubar(curwin,menus)
  //
  xset('dashes',1)
  xset('pattern',1)
  // -- trace du cadre
  edit_curv_redraw()

  // -- boucle principale
  while %t then
    [n1,n2]=size(x);npt=n1*n2
    [btn,xc,yc,win,Cmenu]=get_click(curwin)
    c1=[xc,yc]
    if Cmenu=='Quit' then Cmenu='Abort',end
    if Cmenu=='Exit' then Cmenu='Ok',end
    if Cmenu=="" then Cmenu='edit',end
    //printf("Menu %s\n",Cmenu);
    select Cmenu
     case 'Ignore' then 
      //   --
     case 'Ok' then 
      //    -- ok menu
      xset('default')
      gc=list(rect,axisdata)
      xdel()
      return
     case 'Abort' then 
      //    -- abort menu
      x=xsav
      y=ysav
      //    xset('default')
      if or(curwin==winsid()) then xdel(curwin);end
      ok=%f
      return
     case 'Undo' then
      //    -- undo 
      x=xs;y=ys
      edit_curv_redraw()
     case 'Size' then
      //    -- size
      while %t
	[ok,xmn,xmx,ymn,ymx]=getvalue('Enter boundaries',..
				      ['xmin';'xmax';'ymin';'ymax'],..
				      list('vec',1,'vec',1,'vec',1,'vec',1),..
				      string([xmn;xmx;ymn;ymx]))
	if ~ok then break,end
	if xmn>xmx|ymn>ymx then
	  x_message('Incorrect boundaries')
	else
	  break
	end
      end
      if ok then
	dx=xmx-xmn;dy=ymx-ymn
	if dx==0 then dx=max(xmx/2,1),xmn=xmn-dx/10;xmx=xmx+dx/10;end
	if dy==0 then dy=max(ymx/2,1),ymn=ymn-dy/5;ymx=ymx+dy/10;end
	rect=[xmn,ymn,xmx,ymx];
	auto=%f
	edit_curv_redraw();
      end
     case 'Grids' then 
      //    -- grids 
      rep=x_mdialog('Enter number of grid intervals',..
		    ['x-axis';'y-axis'],..
		    string([axisdata(2);axisdata(4)]))
      if ~isempty(rep) then
	rep=evstr(rep)
	axisdata(2)=rep(1);axisdata(4)=rep(2);
	rect=[xmn,ymn,xmx,ymx];
	auto=%f;
	edit_curv_redraw();
      end
     case 'Clear' then
      //    -- 
      x=[];y=[];
      edit_curv_redraw();
      
     case 'Read' then
      //    -- 
      [x,y]=edit_curv_readxy()
      mx=min(prod(size(x)),prod(size(y)))
      if mx<>0 then
	xmx=max(x);xmn=min(x)
	ymx=max(y);ymn=min(y)
	dx=xmx-xmn;dy=ymx-ymn
	if dx==0 then dx=max(xmx/2,1),xmn=xmn-dx/10;xmx=xmx+dx/10;end
	if dy==0 then dy=max(ymx/2,1),ymn=ymn-dy/5;ymx=ymx+dy/10;end
      else
	xmn=0;ymn=0;xmx=1;ymx=1;dx=1;dy=1
      end
      rect=[xmn,ymn,xmx,ymx];
      edit_curv_redraw();
     case 'Save' then
      //    -- 
      edit_curv_savexy(x,y)
     case 'Replot' then
      //    -- 
      edit_curv_redraw();
      
     case 'edit' then
      //    -- 
      npt=prod(size(x))
      if npt<>0 then
	dist=((x-ones_new(1,npt)*c1(1))/dx).^2+((y-ones_new(1,npt)*c1(2))/dy).^2
	[m,k]=min(dist);m=sqrt(m)
      else
	m=3*eps
      end
      if m<eps then                 //on deplace le point
	xs=x;ys=y
	[x,y]=edit_curv_movept(x,y)         
      else                          
	if add==1 then 
	  xs=x;ys=y                  //on rajoute un point de cassure
	  [x,y]=edit_curv_addpt(c1,x,y)
	end
      end
    else 
      break;
    end
  end
endfunction

function [x,y]=edit_curv_addpt(c1,x,y)
//permet de rajouter un point de cassure
  npt=prod(size(x))
  c1=c1'
  if npt==0 then
    x=c1(1);y=c1(2);
    edit_curv_redraw();
    // plot2d(x,y,style=-1,strf='000')
    return
  end
  //recherche des intervalles en x contenant l'abscisse designee
  kk=[]
  if npt>1 then
    kk=find((x(1:npt-1)-c1(1)*ones(size(x(1:npt-1))))..
	    .*(x(2:npt)-c1(1)*ones(size(x(2:npt))))<=0)
  end
  if  ~isempty(kk) then
    //    recherche du segment sur le quel on a designe un point
    pp=[];d=[];i=0
    for k=kk
      i=i+1
      pr=projaff(x(k:k+1),y(k:k+1),c1)
      if (x(k)-pr(1))*(x(k+1)-pr(1))<=0 then
        pp=[pp pr]
        d1=rect(3)-rect(1)
        d2=rect(4)-rect(2)
        d=[d norm([d1;d2].\(pr-c1))]
      end
    end
    if ~isempty(d) then
      [m,i]=min(d)
      if m<eps
        k=kk(i)
        pp=pp(:,i)
	//  -- trace du point designe
        plot2d(pp(1),pp(2),style=-1,strf='000')
	//  acquisition du nouveau point
	//        [btn,xc,yc]=xclick();c2=[xc;yc]
	c2=pp
	//  -- effacage de l'ancien segment
        plot2d(pp(1),pp(2),style=-1,strf='000')
        plot2d(x(k:k+1),y(k:k+1),style=1,strf='000')
	//  -- mise a jour de x et y
        x=x([1:k k:npt]);x(k+1)=c2(1);
        y=y([1:k k:npt]);y(k+1)=c2(2);
	//  -- dessin des 2 nouveaux segments
	plot2d(x(k:k+2),y(k:k+2),style=1,strf='000')
	plot2d(x(k+1),y(k+1),style=-1,strf='000')
	return
      end
    end
  end
  d1=rect(3)-rect(1)
  d2=rect(4)-rect(2)
  if norm([d1;d2].\([x(1);y(1)]-c1))<norm([d1;d2].\([x(npt);y(npt)]-c1)) then
    //  -- mise a jour de x et y
    x(2:npt+1)=x;x(1)=c1(1)
    y(2:npt+1)=y;y(1)=c1(2)
    //  -- dessin du nouveau segment
    edit_curv_redraw();
  else
    //  -- mise a jour de x et y
    x(npt+1)=c1(1)
    y(npt+1)=c1(2)
    //  -- dessin du nouveau segment
    edit_curv_redraw();
  end
endfunction

function [x,y]=edit_curv_movept(x,y)
//on bouge un point existant
  rep(3)=-1
  while rep(3)==-1 do
    rep=xgetmouse()
    xc=rep(1);yc=rep(2);c2=[xc;yc]
    //[btn,xc,yc]=xclick();c2=[xc;yc]
    if modx==0 then c2(1)=x(k);end
    if mody==0 then c2(2)=y(k);end
    pts=max(k-1,1):min(k+1,npt)
    x(k)=c2(1);y(k)=c2(2)
    xclear();
    plot2d(rect(1),rect(2),style=-1,strf='011',rect=rect,nax=axisdata);
    xgrid(4)
    if ~isempty(x)& ~isempty(y) then 
      plot2d(x,y,style=1,strf='000');plot2d(x,y,style=-1,strf='000');
    end
  end
endfunction

function [x,y]=edit_curv_readxy()
  xy=[];x=[];y=[];
  fn=xgetfile(masks=['edit_curve';'*.xy'],open=%t)
  if fn==emptystr() then return;end 
  if ~execstr('load(fn)',errcatch=%t) then
    x_message(['Cannot load given file']);
  end
  if isempty(xy) then 
    x_message(['The given file does not seams to contain xy matrix']);
  end
  x=xy(1,:);
  y=xy(2,:);
endfunction

function edit_curv_savexy(x,y)
  while %t then 
    fn=xgetfile(masks='*.xy',save=%t)
    if fn=="" then return;end;
    if file('extension',fn) == '.xy' then break;end 
    x_message(['Give a filename with .xy extension']);
  end
  xy=[x;y];
  if ~execstr('save(fn,xy);',errcatch=%t) then
    x_message(['Impossible to save in the selected file';
	       'Check file and directory access'])
    
  end
endfunction


function edit_curv_redraw()
  xclear();
  plot2d(rect(1),rect(2),style=-1,strf='011',rect=rect,nax=axisdata);
  xtitle(tit(1),tit(2),tit(3));
  xgrid(4)
  if ~isempty(x) & ~isempty(y) then 
    plot2d(x,y,style=1,strf='000');
    plot2d(x,y,style=-1,strf='000');
  end
endfunction
