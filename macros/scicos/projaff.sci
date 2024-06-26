function d=projaff(x,y,pt)
// projaff - projection d'un point sur une droite
//%Syntaxe
// d=projaff(x,y,pt)
//%Parametres
// x: vecteur des abscisses des 2 points definissant la droite
// y: vecteur des ordonnes des 2 points definissant la droite
// pt: coordonnes du point a projeter [abscisses ordonnees]
//%Methode
//l'equation de la droite est :
//(y2-y1)*(x-x1)-(x2-x1)*(y-y1)=0
//celle de la normale passant par le point:
//(x2-x1)*(x-xp)+(y2-y1)*(y-yp)=0
//
//%origine
// S Steer INRIA 91
//!
// Copyright INRIA
  dx=x(2)-x(1);dy=y(2)-y(1)
  m=[dy,-dx;dx,dy]
  //  d=m \ [-x(2)*y(1)+x(1)*y(2);m(2,:)*[pt(1);pt(2)]]
  mi= [m(4),-m(3);-m(2),m(1)]/(m(1)*m(4)-m(2)*m(3))
  bb= [-x(2)*y(1)+x(1)*y(2);m(2,:)*[pt(1);pt(2)]];
  d = mi*bb;  
  // jpc 18 april 2009: keep horizontals and verticals
  if x(1)==x(2) then d(1)=x(1);end
  if y(1)==y(2) then d(2)=y(1);end
endfunction



