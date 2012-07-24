//to be ran under calc mode
omod=scs_m.objs(10).model; //scope is the obj(10)
omod.in=1; //update in (because -1)
omod.rpar(4)=15;
omod.ipar(3)=15;
bl=model2blk(omod); //get a computational blk struct
// init
bl=callblk(bl,4,0);
xset('window',1);
F=get_current_figure[];
xpause(1000,%t);
// run
Tfin=100;
for i=0:1:Tfin*100
  t=i/20;
  //update regular input
  bl.inptr(1)=0.55+cos(2*%pi/(15)*t)/10;
  bl=callblk(bl,2,t); //calblk with flag=2
  //F.process_updates[]
  F.draw_now[]
  //xpause(1000,%t);
end
// finish
bl=callblk(bl,5,t);
