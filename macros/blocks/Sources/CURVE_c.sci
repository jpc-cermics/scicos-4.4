function [x,y,typ]=CURVE_c(job,arg1,arg2)
// Masoud Najafi 07/2007 --------
// origine: serge Steer, Habib Jreij INRIA 1993
// Copyright INRIA
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1)
   case 'getinputs' then
    [x,y,typ]=standard_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=standard_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then

    x=arg1
    model=arg1.model
    graphics=arg1.graphics
    exprs=graphics.exprs
    ok=%f;
    SaveExit=%f
    while %t do
      Ask_again=%f
      [ok,Method,xx,yy,PeriodicOption,graf,exprs]=getvalue('Spline data',['Spline"+...
		    " Method (0..7)';'x';'y';'Periodic signal(y/n)?';'Launch"+...
		    " graphic window(y/n)?'],list('vec',1,'vec',-1, ...
						  'vec',-1,'str',1,'str',1),exprs)
      if  ~ok then break;end    
      if PeriodicOption=='y' | PeriodicOption=='Y' then,PO=1;else,exprs(4)='n';PO=0;end
      mtd=int(Method); if mtd<0 then mtd=0;end; if mtd>7 then mtd=7;end;    
      METHOD=getmethod(mtd);
      
      if ~Ask_again then 
	xx=xx(:);yy=yy(:);
	[nx,mx]=size(xx); [ny,my]=size(yy);
	if ~((nx==ny)&(mx==my)) then, x_message('incompatible size of x and y');  Ask_again=%t;end
      end
      
      if ~Ask_again then//+++++++++++++++++++++++++++++++++++++++
	xy=[xx,yy];
	[xy]=cleandata(xy);// just for sorting to be able to compare data before and after poke_point(.)
	N= size(xy,'r');
	exprs(5)='n';// exprs.graf='n'
	if graf=='y' | graf=='Y' then //_______Graphic editor___________
	  ipar=[N;mtd;PO];
	  rpar=[];
	  if ~exists('curwin') then
	    gh=gcf();
	    curwin=gh.figure_id
	  end
	  save_curwin=curwin;
	  curwin=max(winsid())+1; 
	  [orpar,oipar,ok]=poke_point(xy,ipar,rpar);   
	  curwin=save_curwin;
	  if ~ok then break;end;//  exit without save
	  
	  // verifying the data change
	  N2=oipar(1);xy2=[orpar(1:N2),orpar(N2+1:2*N2)];
	  New_methhod=oipar(2);
	  DChange=%f;	
	  METHOD=getmethod(New_methhod);
	  if or(xy(:,1)<>xy2(:,1)) then, DChange=%t;end
	  if or(xy(1:N-1,2)<>xy2(1:N2-1,2)) then, DChange=%t;end
	  if (xy(N,2)<>xy2(N2,2) & (METHOD<>'periodic')) then, DChange=%t;end
	  if DChange then 
	    exprs(2)=strcat(sci2exp(xy2(:,1)))
	    exprs(3)=strcat(sci2exp(xy2(:,2)))
	  end

	  exprs(1)=sci2exp(New_methhod);
	  if oipar(3)==1 then,perop='y';else,perop='n';end
	  exprs(4)=perop;
	  SaveExit=%t
	else//_____________________No graphics__________________________
	  [Xdummy,Ydummy,orpar]=Do_Spline(N,mtd,xy(:,1),xy(:,2));
	  if (METHOD=='periodic') then // periodic spline
	    xy(N,2)=xy(1,2);
	  end	
	  if (METHOD=='order 2' | METHOD=='not_a_knot'|METHOD=='periodic' | METHOD=='monotone'| METHOD=='fast' | METHOD=='clamped') then 
	    orpar=[xy(:,1);xy(:,2);orpar];		
	  else
	    if (METHOD=='zero order'|METHOD=='linear')
	      orpar=[xy(:,1);xy(:,2)]
	    end	
	  end
	  exprs(1)=sci2exp(mtd);// pour le cas methode>7 | method<0
	  oipar=[N;mtd;PO]	
	  SaveExit=%t
	end //___________________________________________________________
      end //++++++++++++++++++++++++++++++++++++++++++++++++++++++
      
      if (SaveExit) then            
	xp=find(orpar(1:oipar(1))>=0);
	if ~isempty(xp) then 
	  model.firing=orpar(xp(1)); //first positive event
	else  
	  model.firing=-1;
	end
	model.rpar=orpar
	model.ipar=oipar
	graphics.exprs=exprs;
	x.model=model      
	x.graphics=graphics
	break
      end
    end
   case 'define' then  
    model=scicos_model()
    xx=[0, 1, 2];yy=[10, 20, -30];  N=3;  Method=3;  PeriodicOption='y';  Graf='n'
    model.sim=list('curve_c',4)
    model.in=[]
    model.out=1
    model.rpar=[xx(:);yy(:)]
    model.ipar=[N;Method;1]
    model.blocktype='c'
    model.dep_ut=[%f %t]
    model.evtin=1
    model.evtout=1
    model.firing=0
    exprs=[sci2exp(Method);sci2exp(xx);sci2exp(yy);PeriodicOption;Graf]
    
    gr_i=['rpar=arg1.model.rpar;n=model.ipar(1);order=model.ipar(2);';
	  'xx=rpar(1:n);yy=rpar(n+1:2*n);';
	  '[XX,YY,rpardummy]=Do_Spline(n,order,xx,yy)';
	  'xmx=max(XX);xmn=min(XX);';
	  'ymx=max(YY);ymn=min(YY);';
	  'dx=xmx-xmn;if dx==0 then dx=max(xmx/2,1);end';
	  'xmn=xmn-dx/20;xmx=xmx+dx/20;';
	  'dy=ymx-ymn;if dy==0 then dy=max(ymx/2,1);end;';
	  'ymn=ymn-dy/20;ymx=ymx+dy/20;';
	  'xx2=orig(1)+sz(1)*((XX-xmn)/(xmx-xmn));';
	  'yy2=orig(2)+sz(2)*((YY-ymn)/(ymx-ymn));';
	  'xset(''color'',2)';
	  'xpoly(xx2,yy2,type=''lines'');']
    x=standard_define([2 2],model,exprs,gr_i,'CURVE_c');
  end
endfunction

function [rpar,ipar,ok]=poke_point(ixy,iparin,rparin)
  //in line definition of get_click
  function [btn,xc,yc,win,Cmenu]=get_click(flag)
    if ~or(winsid() == curwin) then   Cmenu = 'Quit';return,end,;
      if argn(2) == 1 then
        [btn, xc, yc, win, str] = xclick(flag);
      else
        [btn, xc, yc, win, str] = xclick();
      end 
      if btn == -100 then
        if win == curwin then
          Cmenu = 'Quit';
        else;
          Cmenu = 'Open/Set';
        end
        return
      end
      if btn == -2 then
        xc = 0;yc = 0;
        try     
	  // added to handle unwanted menu actions in french version
          execstr('Cmenu=' + part(str, 9:length(str) - 1));
          execstr('Cmenu=' + Cmenu);
        catch
          Cmenu=""    
        end     
        return
      end
      Cmenu=""
  endfunction
    
  ok=%f
  if nargin ==0 then ixy=[];end;
  if size(ixy,'c')<2 then 
    xinfo(' No y provided');
    return
  end

  [xy]=cleandata(ixy)
  N=size(xy,'r');

  if nargin <=1 then
    NOrder=1;
    PeridicOption=0;
    ipar=[N;NOrder;PeridicOption]
    rpar=[]
  elseif nargin == 2 then  
      NOrder=iparin(2);
      PeridicOption=iparin(3);
      ipar=iparin;
      rpar=[]
  elseif nargin ==3 then  
      NOrder=iparin(2);
      PeridicOption=iparin(3);
      ipar=iparin;
      rpar=rparin    
  end
  
  Amp=[];wp=[]; phase=[];offset=[];np1=[];
  Sin_exprs=list(string(Amp),string(wp), string(phase),string(offset),string(np1));
  sAmp=[];sTp=[]; sdelay=[];
  Sawt1_exprs=list(string(sAmp),string(sTp),string(sdelay));
  sAmp2=[];sTp2=[];
  Sawt2_exprs=list(string(sAmp2),string(sTp2));

  Amp3=[];Tp3=[];Pw3=[];Pd3=[];Bias3=[];
  Pulse_exprs=list(string(Amp3), string(Tp3),string(Pw3),string(Pd3),string(Bias3))

  mean4=[];var4=[];seed4=[];sample4=[];np4=[];
  random_n_exprs=list(string(mean4),string(var4), string(seed4),string(sample4),string(np4))

  min5=[];max5=[];seed5=[];sample5=[];np5=[];
  random_u_exprs=list(string(min5), string(max5), string(seed5),string(sample5),string(np5))

  // bornes initiales du graphique
  xmx=max(xy(:,1));xmn=min(xy(:,1)),xmn=max(xmn,0);
  ymx=max(xy(:,2));ymn=min(xy(:,2));
  dx=xmx-xmn;dy=ymx-ymn
  if dx==0 then dx=max(xmx/2,1),end;
  xmx=xmx+dx/50;
  if dy==0 then dy=max(ymx/2,1),end;
  ymn=ymn-dy/50;ymx=ymx+dy/50;

  rect=[xmn,ymn;xmx,ymx];
  //===================================================================
  // f=scf();

  delmenu(curwin,'3D Rot.')
  delmenu(curwin,'Edit')
  delmenu(curwin,'File')
  delmenu(curwin,'Insert')
  // French
  delmenu(curwin,'&Fichier')
  delmenu(curwin,'&Editer')
  delmenu(curwin,'&Outils')
  delmenu(curwin,'&Inserer')
  // English
  delmenu(curwin,'&File')
  delmenu(curwin,'&Edit')
  delmenu(curwin,'&Tools')
  delmenu(curwin,'&Insert')
  
  menu_r=[];
  menu_s=[];
  menu_o=['zero order','linear','order 2','not_a_knot','periodic','monotone','fast','clamped']
  menu_d=['Clear','Data Bounds','Load from text f"+...
	  "ile','Save to text file','Load from Excel','Periodic signal']
  menu_t=['sine','sawtooth1','sawtooth2','pulse','random normal','random uniform']
  menu_e=['Help','Exit without save','Save/Exit']
  MENU=['Autoscale','Spline','Data','Standards','Exit'];
  menus=list(MENU,menu_s,menu_o,menu_d,menu_t,menu_e);

  scam='menus(1)(1)'
  w='menus(3)(';r=')';Orderm=w(ones_deprecated(menu_o))+string(1:size(menu_o,'*'))+r(ones_deprecated(menu_o))
  w='menus(4)(';r=')';Datam=w(ones_deprecated(menu_d))+string(1:size(menu_d,'*'))+r(ones_deprecated(menu_d))
  w='menus(5)(';r=')';Standm=w(ones_deprecated(menu_t))+string(1:size(menu_t,'*'))+r(ones_deprecated(menu_t))
  w='menus(6)(';r=')';Exitm=w(ones_deprecated(menu_e))+string(1:size(menu_e,'*'))+r(ones_deprecated(menu_e))

  execstr('Autoscale_'+string(curwin)+'=scam')
  execstr('Spline_'+string(curwin)+'=Orderm')
  execstr('Data_'+string(curwin)+'=Datam')
  execstr('Standards_'+string(curwin)+'=Standm')
  execstr('Exit_'+string(curwin)+'=Exitm')

  addmenu(curwin,MENU(1))
  addmenu(curwin,MENU(2),menu_o)
  addmenu(curwin,MENU(3),menu_d)
  addmenu(curwin,MENU(4),menu_t)
  addmenu(curwin,MENU(5),menu_e)
  //===================================================================
  //initial draw
  f.pixmap='off';
  drawlater();
  a=gca();
  a.data_bounds=rect;
  a.axes_visible='on';
  a.clip_state='on';
  xtitle( '', 'time', 'Output' ) ; 
  a.title.font_size=2;
  a.title.font_style=4;
  a.title.foreground=2;
  a.grid=[2 2];
  xpolys(xy(:,1),xy(:,2),[-1]);   //children(2)
  xpolys(xy(:,1),xy(:,2),[5]);    //children(1)

  splines=a.children(1).children
  points=a.children(2).children
  
  //---------------------------------------
  [rpar,ipar]=AutoScale(a,xy,ipar,rpar) 
  drawnow();
  // -- boucle principale
  lines(0);
  while %t then //=================================================
    N=size(xy,'r');
    [btn,xc,yc,win,Cmenu]=get_click();
    if ((win>0) & (win<>curwin)) then
      Cmenu='Mouse click is Offside!';
    end
    if isempty(Cmenu) then Cmenu='edit',end
    if (Cmenu=='Exit') |(Cmenu=='Quit' ) then, ipar=[];rpar=[];ok=%f;return; end
    //-------------------------------------------------------------------
    if ((Cmenu=='zero order') | (Cmenu=='linear') | (Cmenu=='order 2')| ...
	(Cmenu=='not_a_knot')| (Cmenu=='periodic')| (Cmenu=='monotone')| ...
	(Cmenu=='fast')| (Cmenu=='clamped')) then
      
      select  Cmenu
       case 'zero order' then
	NOrder=0;
       case 'linear' then
	NOrder=1;
       case 'order 2' then
	NOrder=2;
       case 'not_a_knot' then
	NOrder=3;
       case 'periodic' then
	NOrder=4;
       case 'monotone' then
	NOrder=5;
       case 'fast' then
	NOrder=6;
       case 'clamped' then
	NOrder=7;
      end
      ipar(2)=NOrder;
      [rpar,ipar]=AutoScale(a,xy,ipar,rpar)  
    end
    //-------------------------------------------------------------------  
    select Cmenu
     case 'Data Bounds' then
      rectx=findrect(a);
      [mok,xmn1,xmx1,ymn1,ymx1]=getvalue('Enter new bounds',['xmin';'xmax'; ...
		    'ymin';'ymax'],list('vec',1,'vec',1,'vec',1,'vec',1), ...
					 string(rectx))
      //drawlater();
      if mok then 
	if (xmn1>xmx1|ymn1>ymx1) then
	  xinfo('Incorrect bounds')
	  mok=%f;
	end
	if xmn1<0 then
	  xinfo('X soululd be positive')
	  mok=%f;
	end
	if mok then 
	  a.data_bounds=[xmn1,ymn1;xmx1,ymx1];
	end
      end
      //drawnow();//show_pixmap(); 
      //-------------------------------------------------------------------  
     case 'Autoscale' then 
      [rpar,ipar]=AutoScale(a,xy,ipar,rpar) 
      //-------------------------------------------------------------------  
     case 'Periodic signal' then 
      if PeridicOption==1 then, ans0='y',else, ans0='n',end;
      [mok,myans]=getvalue('Generating periodic signal',['y/n'],list('str',1),list(ans0));
      if ((myans=='y')|(myans=='Y')) then,PeridicOption=1,else,PeridicOption=0;end;
      ipar(3)=PeridicOption;
      [rpar,ipar]=AutoScale(a,xy,ipar,rpar) 
      //-------------------------------------------------------------------
     case 'sine' then 
      [mok,Amp,wp,phase,offset,np1,Sin_exprs2]=getvalue(' Sine parameters', ...
							['Amplitude';'Frequency(rad/sec)'; ...
		    'Phase(rad)';'Bias';'number of points'],list('vec',1,'vec',1,'vec',1, ...
						  'vec',1,'vec',1),Sin_exprs)
      if np1< 2 then np1=2;end
      if mok & wp>0  then
	NOrder=3;
	ipar(2)=NOrder;
	phase=atan(tan(phase));
	xt=linspace(0,%pi*2/wp,np1)';
	yt=Amp*sin(wp*xt+phase)+offset;
	xy=[xt,yt];	
	[rpar,ipar]=AutoScale(a,xy,ipar,rpar) 
	Sin_exprs=Sin_exprs2
      end
      //-------------------------------------------------------------------
     case 'sawtooth1' then 
      [mok,sAmp,sTp,sdelay,Sawt1_exprs2]=getvalue('Sawtooth signal parameters', ...
						  ['Amplitude';'Period';'delay'], ...
						  list('vec',1,'vec',1,'vec',1),Sawt1_exprs)   
      if mok & sTp>0 then
	NOrder=1;
	ipar(2)=NOrder;
	if sdelay<sTp then 
	  xt=[0;sdelay;sTp];
	  yt=[0;0;sAmp];
	else
	  xt=[0];
	  yt=[0];
	end	      
	xy=[xt,yt];	
	[rpar,ipar]=AutoScale(a,xy,ipar,rpar);
	Sawt1_exprs=Sawt1_exprs2
      end
      //-------------------------------------------------------------------
     case 'sawtooth2' then     
      [mok,sAmp2,sTp2,Sawt2_exprs2]=getvalue('Sawtooth signal parameters', ...
					     ['Amplitude';'Period'],list('vec',1,'vec',1),Sawt2_exprs)    
      if mok & sTp2>0 then
	NOrder=1;
	ipar(2)=NOrder;
	xt=[0;sTp2];
	yt=[sAmp2;-sAmp2];
	xy=[xt,yt];	
	[rpar,ipar]=AutoScale(a,xy,ipar,rpar);
	Sawt2_exprs=Sawt2_exprs2
      end
      //-------------------------------------------------------------------
     case 'pulse' then
      [mok,Amp3,Tp3,Pw3,Pd3,Bias3,Pulse_exprs2]=getvalue('Square wave pulse signal', ...
						  ['Amplitude';'Period (sec)';'Pulse width(% o"+...
		    "f period)';'Phase delay (sec)';'Bias'],list('vec',1, ...
						  'vec',1,'vec',1,'vec',1,'vec', ...
						  1),Pulse_exprs)        
      if mok & Tp3>0  then
	NOrder=0;
	ipar(2)=NOrder;
	if (Pd3>0) then xt=0;yt=Bias3;else xt=[];yt=[]; end
	//otherwise there	would be double	points at 0
	if Pd3<Tp3 then 
	  if Pw3>0 then 
	    xt=[xt;Pd3; Pw3*Tp3/100+Pd3;Tp3];
	    yt=[yt;Amp3+Bias3;Bias3;Bias3];	
	  else
	    xt=[0;Tp3];yt=[Bias3;Bias3];		  
	  end      
	else
	  xt=[0;Tp3];yt=[Bias3;Bias3];		  
	end
	
	xy=[xt,yt];	
	[rpar,ipar]=AutoScale(a,xy,ipar,rpar);
	Pulse_exprs=Pulse_exprs2;
      end
      //-------------------------------------------------------------------
     case 'random normal' then
      [mok,mean4,var4,seed4,sample4,np4,random_n_exprs2]=getvalue('Normal (Gaussian) random signal', ...
						  ['Mean';'Variance';'Initial seed';'Sample time';'Number of points'],list('vec',1, ...
						  'vec',1,'vec',1,'vec', ...
						  1,'vec',1),random_n_exprs)        
      if mok & sample4>0 then
	NOrder=0;
	ipar(2)=NOrder;      
	rand('normal');  rand('seed',seed4);
	xt=0:sample4:sample4*(np4-1);xt=xt(:);
	yt=mean4+sqrt(var4)*rand(np4,1);
	xy=[xt,yt];	
	[rpar,ipar]=AutoScale(a,xy,ipar,rpar);
	random_n_exprs2=random_n_exprs;
      end
      //-------------------------------------------------------------------
     case 'random uniform' then
      [mok,min5,max5,seed5,sample5,np5,random_u_exprs2]=getvalue('Uniform random signal', ...
						  ['Minimum';'Maximum';'Initial seed';'Sample time';'Number of points'],list('vec',1, ...
						  'vec',1,'vec',1,'vec', ...
						  1,'vec',1),random_u_exprs)        
      if mok & sample5>0 then
	NOrder=0;
	ipar(2)=NOrder;      
	rand('uniform'); rand('seed',seed5);
	xt=0:sample5:sample5*(np5-1);xt=xt(:);
	yt=min5+(max5-min5)*rand(np5,1);
	xy=[xt,yt];	
	[rpar,ipar]=AutoScale(a,xy,ipar,rpar);
	random_u_exprs2=random_u_exprs;

      end   
      //-------------------------------------------------------------------
     case 'Save/Exit' then
      NOrder=ipar(2);
      PeridicOption=ipar(3);

      METHOD=getmethod(NOrder);
      if (METHOD=='periodic') then // periodic spline
	xy(N,2)=xy(1,2);
      end
      
      if (METHOD=='order 2' | METHOD=='not_a_knot'|METHOD=='periodic' | METHOD=='monotone'| METHOD=='fast' | METHOD=='clamped') then 
	rpar=[xy(:,1);xy(:,2);rpar];
      else
	if (METHOD=='zero order'|METHOD=='linear')
	  rpar=[xy(:,1);xy(:,2)]
	end
      end
      
      ok=%t
      delete(f);
      return 
      //-------------------------------------------------------------------
     case 'Exit without save' then 
      ipar=[];
      rpar=[];
      ok=%f
      delete(f);
      return
      //-------------------------------------------------------------------
     case 'Clear' then    
      xy=[0,0];
      NOrder=0;
      ipar(2)=NOrder;
      [rpar,ipar]=AutoScale(a,xy,ipar,rpar) 
      //----------------------------------------------------------------
     case 'Edit text data NOT IN USE' then
      //  editvar xy;
      [mok,xt,yt]=getvalue('Enter x and y data',['x';'y'],list('vec',-1,'vec',-1),list(strcat(sci2exp(xy(:,1))),strcat(sci2exp(xy(:,2)))));
      if mok then,    
	xy=[xt,yt];
	[xy]=cleandata(xy), 
	[rpar,ipar]=AutoScale(a,xy,ipar,rpar) 
      end
      //---------------------------------------------------------------  
     case 'Help' then
      t1='Mouse-left click: adding a new point'
      t2='Mouse-right click: remove a point'
      t3='Mouse-left double click: edit a point''s coordinates'
      t4='Mouse-left button press/drag/release: move a  point'
      t5='Change the window size: ''Data'' menu -> ''Databounds'''
      x_message([t1;t2;t3;t4;t5]);
      //---------------------------------------------------------------  
     case 'Load from Excel' then
      [tok,xytt]=ReadExcel()
      if tok then
	xy=xytt;
	NOrder=1
	ipar(2)=NOrder;
	[rpar,ipar]=AutoScale(a,xy,ipar,rpar) 
      end
      //---------------------------------------------------------------       
     case 'Load from text file' then
      [tok,xytt]=ReadFromFile()
      if tok then
	xy=xytt;
	NOrder=1
	ipar(2)=NOrder;
	[rpar,ipar]=AutoScale(a,xy,ipar,rpar) 
      end
      //---------------------------------------------------------------     
     case 'Save to text file' then    
      [sok]=SaveToFile(xy)
      //---------------------------------------------------------------       
     case 'Replot' then
      if ~isempty( xy) then 
	drawlater();
	points.data=xy;
	[rpar,ipar]=drawSplin(a,xy,ipar,rpar);
	drawnow()
      end
      //----------------------------------------------------------
     case 'edit' then 
      HIT=%f
      if N<>0 then
	xt=xy(:,1);yt=xy(:,2);
	dist=((xt-ones(N,1)*xc)).^2+((yt-ones(N,1)*yc)).^2 // 
	[dca,k]=min(dist);
	rectx=a.data_bounds;
	ex=abs(rectx(2,1)-rectx(1,1))/80;
	ey=abs(rectx(2,2)-rectx(1,2))/80;
	if (abs(xc-xt(k))<ex & abs(yc-yt(k))<ey) then 
	  HIT=%t
	end
    end
    
    //_________________________
  //  if ~((NOrder==-1|NOrder==-2|NOrder==-3|NOrder==-4)) then
      if (~HIT)&(btn==0 | btn==3) then    // add point
	if (xc>=0) then 
	  if (xc==0) then 
	    zz=find(x==0);
	    xy(zz,:)=[];
	  end 
	  xy=[xy;xc,yc];
	  [xtt,k2]=gsort(xy(:,1),'r','i');xy=xy(k2,:)
	  f.pixmap='on';
	  drawlater();
	  points.data=xy;
	  [rpar,ipar]=drawSplin(a,xy,ipar,rpar);  
	  show_pixmap(); 
	  drawnow()
	  f.pixmap='off';
	end	      
      end
      
      if (HIT)&(btn==2 | btn==5) then  //   remove point
	f.pixmap='on';
	if (xy(k,1)>0) |( xy(k,1)==0 & (size(find(xy(:,1)==0),'*')>1)) then 
	  xy(k,:)=[];
	end
	drawlater();
	points.data=xy;
	[rpar,ipar]=drawSplin(a,xy,ipar,rpar);  
	show_pixmap(); 
	drawnow()
	f.pixmap='off';
      end   

      if (HIT)&(btn==0) then             // move point
	f.pixmap='on';
	[xy,rpar,ipar]=movept(a,xy,ipar,rpar,k)   
	f.pixmap='off';
      end
            
      if (HIT)&(btn==10) then             // change data:: double click
	[mok,xt,yt]=getvalue('Enter new x and y',['x';'y'],list('vec', ...
						  1,'vec',1),list(sci2exp(xy(k,1)),sci2exp(xy(k,2))));
	if mok then 
	  xy(k,:)=[xt,yt];
	  [xy]=cleandata(xy)
	  f.pixmap='on';
	  drawlater();
	  points.data=xy;
	  [rpar,ipar]=AutoScale(a,xy,ipar,rpar) 
	  show_pixmap(); 
	  drawnow()
	  f.pixmap='off';
	end
      end

  //  end
    //_________________________________
   
  end
  //----------------------------------------------------------
end
endfunction
//========================================================================
function [orpar,oipar]=drawSplin(a,xy,iipar,irpar)
  N=size(xy,'r');// new size of xy
  x=xy(:,1);  y=xy(:,2);
  points=a.children(2).children
  splines=a.children(1).children
  order=iipar(2);
  periodicoption=iipar(3);
  orpar=irpar;
   
  METHOD=getmethod(order);
  
  if periodicoption==1 then PERIODIC='periodic, T='+string(x(N)-x(1));
  else PERIODIC='aperiodic';end  
  a.title.text=[string(N)+' points,  '+'Method: '+METHOD+',  '+PERIODIC];

  if (N==0) then, return; end
  if (N==1) then, order=0; end
//  NP=50;// number of intermediate points between two data points 
  [X,Y,orpar]=Do_Spline(N,order,x,y);
  if (periodicoption==1) then 
    X=[X;X($)];
    Y=[Y;Y(1)];
  else
    xmx=max(points.data(:,1));  xmn=min(points.data(:,1));
    XMX=max(0,xmx); XMN=max(0,xmn);
    xmx1=max(a.x_ticks.locations)
    XMX=max(XMX,xmx1);    
    X=[X;XMX];
    Y=[Y;Y($)];
  end
  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  splines.data=[X,Y];    
  oipar=[N;iipar(2);periodicoption]
endfunction
//=============================================================
function [xyt,orpar,oipar]=movept(a,xy,iipar,irpar,k)
//on bouge un point existant
  points=a.children(2).children
  splines=a.children(1).children  
  oipar=iipar
  orpar=irpar
  order=iipar(2);
  x=xy(:,1);  y=xy(:,2);  
  
  if (x(k)==0) then 
    zz=find(x==0);
    x(zz)=[];y(zz)=[];
    ZERO_POINT=%t
  else
    x(k)=[];
    y(k)=[]; 
    ZERO_POINT=%f
  end 

  btn=-1

  while ~(btn==3 | btn==0| btn==10| btn==-5)
    rep=xgetmouse([%t %t]); xc=rep(1);yc=rep(2);btn=rep(3);
    if (ZERO_POINT) then 
      xc=0;
    else
      if (xc<=0) then 
	zz=find(x==0);
	x(zz)=[];y(zz)=[];
	ZERO_POINT=%t;
	xc=0;
      end
    end
  
    xt=[x;xc];
    yt=[y;yc];
    [xt,k2]=gsort(xt,'r','i');yt=yt(k2)
    xyt=[xt,yt];
    
    drawlater();
    points.data=xyt;    
    [orpar,oipar]=drawSplin(a,xyt,oipar,orpar); 
    show_pixmap();  
    drawnow()
  end

endfunction

//==========================================================
function   rectx=findrect(a) 
  splines=a.children(1).children  
  points=a.children(2).children

  if isempty(points.data) then 
    rectx=a.data_bounds;
    return;
  end    


  ymx1=max(splines.data(:,2));  ymn1=min(splines.data(:,2))
  
  xmx=max(points.data(:,1));xmn=min(points.data(:,1));
  ymx=max(points.data(:,2));ymn=min(points.data(:,2));

  
  XMX=max(0,xmx);            XMN=max(0,xmn);
  YMX=max(ymx,ymx1);  YMN=min(ymn,ymn1);
  
  dx=XMX-XMN;dy=YMX-YMN
  if dx==0 then dx=max(XMX/2,1),end;
  XMX=XMX+dx/50
  if dy==0 then dy=max(YMX/2,1),end;
  YMN=YMN-dy/50;YMX=YMX+dy/50;  
  rectx=[XMN,YMN;XMX,YMX];
endfunction

//============================================================
function [tok,xyo]=ReadExcel()
  TA=['A';'B';'C';'D';'E';'F';'G';'H';'I';'J';'K';'L';'M';'N';'O';'P'; ...
      'Q';'R';'S';'T';'U';'V';'W';'X';'Y';'Z';'a';'b';'c';'d';'e';'f'; ...
      'g';'h';'i';'j';'k';'l';'m';'n';'o';'p';'q';'r';'s';'t';'u';'v'; ...
      'w';'x';'y';'z'];
  TN=['0','1','2','3','4','5','6','7','8','9'];
  xyo=[];tok=%f;
  while %t
    [zok,filen,sheetN,xa,ya]=getvalue('Excel data file ',['Filename';'Sheet #"+...
		    " ';'X[start:Stop]';'Y[start:stop]'],list('str',1, ...
						  'vec',1,'str',1, ...
						  'str',1), ...
				      list(['Classeur1.xls'],['1'],['C5:C25'],['D5:D25']));   
    if ~zok then break,end

    try
        [fd,SST,Sheetnames,Sheetpos] = xls_open(filen);
    catch
        xinfo('Scicos canot find the excel file:'+filen);
	break;
    end 
    try  
    N=size(Sheetnames,'*');
    if ((sheetN<=N) &(sheetN>0)) then 
      [Value,TextInd] = xls_read(fd,Sheetpos(sheetN))
      mclose(fd)
    end
    xa=strsubst(xa,' ',''); px=strindex(xa,':'); 
    ya=strsubst(ya,' ',''); py=strindex(ya,':');
    x1=part(xa,1:px-1); x2=part(xa,px+1:length(xa));
    y1=part(ya,1:py-1); y2=part(ya,py+1:length(ya));

    x1p=min(strindex(x1,TN));
    if isempty(x1p) then, xinfo('Bad address in X:'+x1); break, end
    x11=part(x1,1:x1p-1);x12=part(x1,x1p:length(x1));
    
    x2p=min(strindex(x2,TN));
    if isempty(x2p) then, xinfo('Bad address in X:'+x2); break, end
    x21=part(x2,1:x2p-1);x22=part(x2,x2p:length(x2));
    
    y1p=min(strindex(y1,TN));
    if isempty(y1p) then, xinfo('Bad address in Y:'+y1); break, end
    y11=part(y1,1:y1p-1);y12=part(y1,y1p:length(y1));

    y2p=min(strindex(y2,TN));
    if isempty(y2p) then, xinfo('Bad address in Y:'+y2); break, end
    y21=part(y2,1:y2p-1);y22=part(y2,y2p:length(y2));
       
    // x11 x12: x21 x22
    
    lx11=length(x11);lx21=length(x21);
    ly11=length(y11);ly21=length(y21)
    xstC=0;for i=1:lx11,xstC=xstC+modulo(find(TA==part(x11,lx11-i+1)),26)*26^(i-1);end
    xenC=0;for i=1:lx21,xenC=xenC+modulo(find(TA==part(x21,lx21-i+1)),26)*26^(i-1);end
    ystC=0;for i=1:ly11,ystC=ystC+modulo(find(TA==part(y11,ly11-i+1)),26)*26^(i-1);end
    yenC=0;for i=1:ly11,yenC=yenC+modulo(find(TA==part(y21,ly21-i+1)),26)*26^(i-1);end
        
    xstR=evstr(x12);
    xenR=evstr(x22);
    ystR=evstr(y12);
    yenR=evstr(y22);
    
    [mv,nv]=size(Value)

    if ~(xstR<=mv & xstR>0 & xenR<=mv & xenR>0&ystR<=mv & ystR>0&yenR<=mv&yenR>0 ) then 
      xinfo('error in Row data addresses'); break
    end
    if ~(xstC<=nv & xstC>0 & xenC<=nv & xenC>0&ystC<=nv & ystC>0&yenC<=nv&yenC>0 ) then 
      xinfo('error in Column data addresses'); break
    end
     
    xo=Value(min(xstR,xenR):max(xstR,xenR),min(xstC,xenC):max(xstC,xenC));
    yo=Value(min(ystR,yenR):max(ystR,yenR),min(ystC,yenC):max(ystC,yenC));
    [nx,mx]=size(xo);// adjusting the x and y size
    [ny,my]=size(yo);
    N=min(nx,ny);
    xo=xo(1:N,:);
    yo=yo(1:N,:);
    
    xyo=[xo,yo];
    [xyo]=cleandata(xyo)
    
    tok=%t;break,
    catch
         xinfo(' Scicos cannot read your Excel file, please verify"+...
		   " the parameters '); 	 
	 break
    end	 
  end
  
endfunction
//---------------------------------------------------------------
function [xyo]=cleandata(xye)
  xe=xye(:,1)
  ye=xye(:,2)
  
  [nx,mx]=size(xe);// adjusting the x and y size
  [ny,my]=size(ye);
  N=min(nx,ny);
  xe=xe(1:N,:);
  ye=ye(1:N,:);

  // checking for NULL data
  for i=1:N
    if (xe(i)<>xe(i)) then 
      xinfo('x contains no data:x('+string(i)+')'); 
      return;
    end
    if (ye(i)<>ye(i)) then 
      xinfo('Y contains no data:y('+string(i)+')'); 
      return;
    end      
  end
  zz=find(xe<0);xe(zz)=[];ye(zz)=[]
  if isempty(find(xe==0)) then // add zero point
    xe($+1)=0;
    ye($+1)=0;
  end
  
  [xo,k2]=gsort(xe,'r','i');
  yo=ye(k2)    
 
  xyo=[xo,yo];
endfunction
//---------------------------------------------------------------
function  [orpar,oipar]=AutoScale(a,xy,inipar,inrpar)   
  drawlater();    
  oipar=inipar
  orpar=inrpar
  points=a.children(2).children
  splines=a.children(1).children
  points.data=xy;
  splines.data=xy;
  [orpar,oipar]=drawSplin(a,xy,oipar,orpar);
  rectx=findrect(a);     
  a.data_bounds=rectx;
  show_pixmap(); 
  drawnow()
endfunction
//============================
function METHOD=getmethod(order)
  select order
   case 0 then, METHOD='zero order'
   case 1 then, METHOD='linear'
   case 2 then, METHOD='order 2'
   case 3 then, METHOD='not_a_knot'
   case 4 then, METHOD='periodic'
   case 5 then, METHOD='monotone'
   case 6 then, METHOD='fast'
   case 7 then, METHOD='clamped'
  end
endfunction
//=======================================
function [sok,xye]=ReadFromFile()
  xye=[];sok=%f;
  while %t
    [sok,filen,Cformat,Cx,Cy]=getvalue('Text data file ',['Filename';'Reading [C] f"+...
		    "ormat';'Abscissa column';'Output"+...
		    " column'],list('str',1,'str',1,'vec',1,'vec',1), ...
				      list(['mydatafile.dat'],['%g %g'],['1'],['2']));       
    if ~sok then break,end
    px=strindex(Cformat,'%');
    NC=size(px,'*');    
    if isempty(NC) then, xinfo('Bad format in reading data file');sok=%f;break;end
    Lx=[];
    try
      fd=mopen(filen,'r');
      Lx=mfscanf(-1,fd,Cformat);
      mclose(fd);
    catch
      xinfo('Scicos canot open the data file:'+filen);
      break;
    end 

    [nD,mD]=size(Lx);
    if ((mD==0) | (nD==0)) then,  xinfo('No data read');sok=%f;break;end
    if (mD<>NC) then, xinfo('Bad format');sok=%f;break;end
    
    xe=Lx(:,Cx);ye=Lx(:,Cy);
    xye=[xe,ye];
    [xye]=cleandata(xye)
    sok=%t;break,
 end 
endfunction
//=======================================
function [sok]=SaveToFile(xye)
  xe=xye(:,1)
  ye=xye(:,2)
  sok=%f;
  while %t
    [sok,filen,Cformat]=getvalue('Text data file ',['Filename';'Writing [C] f"+...
		    "ormat'],list('str',1,'str',1), ...
				      list(['mydatafile.dat'],['%g %g']));       
    if ~sok then break,end
    px=strindex(Cformat,'%');
    NC=size(px,'*');    
    if NC<>2 then, xinfo('Bad format in writing data file');sok=%f;break;end

    Cformat=Cformat+'\n';
    
    try
      fd=mopen(filen,'w');
      mfprintf(fd,Cformat,xe,ye);
      mclose(fd);
    catch
      xinfo('Scicos canot open the data file:'+filen);
      break;
    end 

    sok=%t;break,
 end 
endfunction
//=========================================================
function [X,Y,orpar]=Do_Spline(N,order,x,y)
  X=[];Y=[];orpar=[];

  METHOD=getmethod(order);

  if (METHOD=='zero order') then 
    X=x(1);Y=y(1);
    for i=1:N-1
      X=[X;x(i);x(i+1);x(i+1)];
      Y=[Y;y(i);y(i);y(i+1)];
    end
    return
  end    
  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  if (METHOD=='linear') then
    X=[];
    for i=1:N
      X=[X;x(i)];
      Y=[Y;y(i)];
    end
    return
  end
  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  if (N<25) then NP=10;else
   if (N<50) then NP=5;else
    if (N<100) then NP=2;else
      if (N<200) then NP=1;else
        NP=0;end;end;end;
  end
  for i=1:N-1
    X=[X;linspace(x(i),x(i+1),NP+2)']; // pour tous sauf "linear" et "zero order"
  end
  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  if (N>2) & (METHOD=='order 2') then
    Z=ORDER2(x,y);
    A=Z(1:N-1);
    B=Z(N:2*N-2);
    C=Z(2*N-1:3*N-3);
    
    for j=1:size(X,'*')
      for i=N-1:-1:1
	if X(j)>=x(i) then,break;end
      end
      Y(j)=A(i)*(X(j)-x(i))^2+B(i)*(X(j)-x(i))+C(i);
    end    
    orpar=matrix(Z,-1,1)   
  end  
   //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  if (METHOD=='not_a_knot') then
    try
    d = splin(x, y, METHOD);
    Y = interp(X, x, y, d);    
    orpar=d(:);
    catch
     xinfo('ERROR in SPLINE: '+METHOD)
    end
    
  end
   //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  if (METHOD=='periodic') then
    if y(1)<>y(N) then 
      y(N)=y(1)
    end
    try 
      d = splin(x, y,METHOD);
      Y = interp(X, x, y, d);  
      orpar=d(:);
    catch
    xinfo('ERROR in SPLINE: '+METHOD)
    end
  end
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  if (METHOD=='monotone' ) then
    try
      d = splin(x, y, METHOD);
      Y = interp(X, x, y, d);  
      orpar=d(:);
    catch
    xinfo('ERROR in SPLINE: '+METHOD)
    end
  
  end
   //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  if (METHOD=='fast') then
    try
      d = splin(x, y, METHOD);
      Y = interp(X, x, y, d);    
      orpar=d(:);
    catch
      xinfo('ERROR in SPLINE:  '+METHOD)    
    end  
  end  
   //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  if (METHOD=='clamped') then
    try
      d = splin(x, y, METHOD,[0;0]);
      Y = interp(X, x, y, d);    
      orpar=d(:);
    catch
      xinfo('ERROR in SPLINE: '+METHOD)    
    end
  end  
  
endfunction
//=================================================  
function [Z]=ORDER2(x,y)
N=size(x,'*')-1;
A=zeros(3*N-1,N*3);
B=zeros(3*N-1,1);
for i=1:N
   j=3*(i-1)+1;
   A(j,i+2*N)=1;
   B(j)=y(i);
   A(j+1,i)=(x(i+1)-x(i))^2;
   A(j+1,i+N)=x(i+1)-x(i);
   A(j+1,i+2*N)=1;
   B(j+1)=y(i+1);
end

for i=1:N-1
   j=3*(i-1)+1;
   A(j+2,i)=2*(x(i+1)-x(i));
   A(j+2,i+N)=1;   
   A(j+2,i+N+1)=-1;
end

Q=zeros(3*N,3*N);
for i=1:N
  Q(i,i)=4*(x(i+1)-x(i))^2
  Q(i,i+N)=2*(x(i+1)-x(i))
  Q(i+N,i)=2*(x(i+1)-x(i))
  Q(i+N,i+N)=1;
end

At=[Q,A';A,zeros(3*N-1,3*N-1)]
Bt=[zeros(3*N,1);B]
Zt=At\Bt;
Z=Zt(1:3*N,1)
endfunction
//===================================================
