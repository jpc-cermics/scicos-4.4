function [x,y,typ]=CURVE_c(job,arg1,arg2)
// 
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
      METHOD=curve_getmethod(mtd);
      
      if ~Ask_again then 
	xx=xx(:);yy=yy(:);
	[nx,mx]=size(xx); [ny,my]=size(yy);
	if ~((nx==ny)&(mx==my)) then, x_message('incompatible size of x and y');  Ask_again=%t;end
      end
      
      if ~Ask_again then//+++++++++++++++++++++++++++++++++++++++
	xy=[xx,yy];
	[xy]=curve_cleandata(xy);// just for sorting to be able to compare data before and after poke_point(.)
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
	  [orpar,oipar,ok]=edit_spline(xy,ipar,rpar);   
	  curwin=save_curwin;
	  if ~ok then break;end;//  exit without save
	  
	  // verifying the data change
	  N2=oipar(1);xy2=[orpar(1:N2),orpar(N2+1:2*N2)];
	  New_methhod=oipar(2);
	  DChange=%f;	
	  METHOD=curve_getmethod(New_methhod);
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

function test_edit_spline()
// test: 
  ixy=[1:10;sin(1:10)]'; N = size(ixy,1);
  ipar=[N;2;1];
  rpar=[];
  curwin=0;
  if ~new_graphics() then 
    switch_graphics();
  end
  edit_spline(ixy,ipar,rpar);
endfunction

function [rpar,ipar,ok]=edit_spline(ixy,iparin,rparin)

// utility functions 
  
  function [btn,xc,yc,win,Cmenu]=get_click()
    if ~or(winsid() == curwin) then   Cmenu = 'Quit';return,end,;
    [btn, xc, yc, win, str] = xclick();
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
  if size(ixy,'c') < 2 then 
    xinfo(' No y provided');
    return
  end
  
  [xy]=curve_cleandata(ixy)
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
  
  if ~exists('curwin') then
    curwin=max(winsid())+1; 
    if isempty(curwin) then 
      curwin=0;
    end
  end
  xset('window',curwin);  
  // f=scf();
  // menus 
  // 
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
  
  //initial drawings 
  
  xsetech(frect=[rect(1),rect(3),rect(2),rect(4)]);
  xtitle( '', 'time', 'Output' ) ; 
  // xgrid();
  xpolys(xy(:,1),xy(:,2),[5]);
  xpolys(xy(:,1),xy(:,2),[-1]);
  F=get_current_figure();
  a=F.children(1);
  splines=F.children(1).children(1);
  points=F.children(1).children(2);
  points.children(1).hilited=%t;
  [rpar,ipar]=curve_autoscale(a,xy,ipar,rpar) 
  F.invalidate[];  
  while %t then 
    N=size(xy,'r');
    [btn,xc,yc,win,Cmenu]=get_click();
    if ((win>0) & (win<>curwin)) then
      Cmenu='Mouse click is Offside!';
    end
    if Cmenu.equal[""] then Cmenu='edit',end
    if (Cmenu=='Exit') |(Cmenu=='Quit' ) then
      ipar=[];rpar=[];ok=%f;return;
    end
    methods=['zero order';'linear';'order 2';'not_a_knot';'periodic'; ...
	     'monotone';'fast';'clamped'];
    NOrder = find(Cmenu== methods);
    if ~isempty(NOrder) then 
      NOrder = NOrder -1;
      ipar(2)=NOrder;
      [rpar,ipar]=curve_autoscale(a,xy,ipar,rpar)  
    end
    
    select Cmenu
     case 'Data Bounds' then
      // fix data bounds getting new values through getvalue
      //-------------------------------------------------------------------  
      rectx=curve_findrect(a);
      str = ['xmin';'xmax';'ymin';'ymax'];
      typ = list('vec',1,'vec',1,'vec',1,'vec',1);
      [mok,xmn1,xmx1,ymn1,ymx1]=getvalue('Enter new bounds',str,typ,string(rectx));
      if mok then 
	if (xmn1>xmx1|ymn1>ymx1) then
	  xinfo('Incorrect bounds')
	  mok=%f;
	end
	if xmn1<0 then
	  xinfo('x values should be positive')
	  mok=%f;
	end
	if mok then 
	  xsetech(frect=[xmn1,ymn1,xmx1,ymx1],fixed=%t);
	end
      end
      a.invalidate[];
     case 'Autoscale' then 
      // reset the bounds using data
      //-------------------------------------------------------------------  
      [rpar,ipar]=curve_autoscale(a,xy,ipar,rpar) 

     case 'Periodic signal' then 
      // setup periodicity
      //-------------------------------------------------------------------  
      if PeridicOption==1 then, ans0='y',else, ans0='n',end;
      [mok,myans]=getvalue('Generating periodic signal',['y/n'],list('str',1),ans0);
      if ((myans=='y')|(myans=='Y')) then,PeridicOption=1,else,PeridicOption=0;end;
      ipar(3)=PeridicOption;
      [rpar,ipar]=curve_autoscale(a,xy,ipar,rpar) 
      //-------------------------------------------------------------------
     case 'sine' then 
      // a sine signal 
      //-------------------------------------------------------------------  
      values = ['Amplitude';'Frequency(rad/sec)';'Phase(rad)';'Bias';'number of points'];
      typ = list('vec',1,'vec',1,'vec',1,'vec',1,'vec',1);
      [mok,Amp,wp,phase,offset,np1,Sin_exprs2]=getvalue(' Sine parameters',values, typ,...
							Sin_exprs);
      if np1< 2 then np1=2;end
      if mok & wp>0  then
	NOrder=3;
	ipar(2)=NOrder;
	phase=atan(tan(phase));
	xt=linspace(0,%pi*2/wp,np1)';
	yt=Amp*sin(wp*xt+phase)+offset;
	xy=[xt,yt];	
	[rpar,ipar]=curve_autoscale(a,xy,ipar,rpar) 
	Sin_exprs=Sin_exprs2
      end
     case 'sawtooth1' then 
      //-------------------------------------------------------------------
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
	[rpar,ipar]=curve_autoscale(a,xy,ipar,rpar);
	Sawt1_exprs=Sawt1_exprs2
      end
     case 'sawtooth2' then     
      //-------------------------------------------------------------------
      [mok,sAmp2,sTp2,Sawt2_exprs2]=getvalue('Sawtooth signal parameters', ...
					     ['Amplitude';'Period'],...
					     list('vec',1,'vec',1),Sawt2_exprs)    
      if mok & sTp2>0 then
	NOrder=1;
	ipar(2)=NOrder;
	xt=[0;sTp2];
	yt=[sAmp2;-sAmp2];
	xy=[xt,yt];	
	[rpar,ipar]=curve_autoscale(a,xy,ipar,rpar);
	Sawt2_exprs=Sawt2_exprs2
      end
     case 'pulse' then
      //-------------------------------------------------------------------
      values=['Amplitude';'Period (sec)';'Pulse width(% of period)';'Phase delay (sec)';'Bias'];
      typ = list('vec',1, 'vec',1,'vec',1,'vec',1,'vec',1);
      [mok,Amp3,Tp3,Pw3,Pd3,Bias3,Pulse_exprs2]=getvalue('Square wave pulse signal',values, ...
						  typ,Pulse_exprs);
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
	[rpar,ipar]=curve_autoscale(a,xy,ipar,rpar);
	Pulse_exprs=Pulse_exprs2;
      end
     case 'random normal' then
      //-------------------------------------------------------------------
      tit= 'Normal (Gaussian) random signal';
      values=['Mean';'Variance';'Initial seed';'Sample time';'Number of points'];
      typ = list('vec',1,'vec',1,'vec',1,'vec', 1,'vec',1)
      [mok,mean4,var4,seed4,sample4,np4,random_n_exprs2]=getvalue(tit,values,typ,...
						  random_n_exprs);
      if mok & sample4>0 then
	NOrder=0;
	ipar(2)=NOrder;      
	// rand('seed',seed4);
	xt=0:sample4:sample4*(np4-1);xt=xt(:);
	yt=mean4+sqrt(var4)*randn(np4,1);
	xy=[xt,yt];	
	[rpar,ipar]=curve_autoscale(a,xy,ipar,rpar);
	random_n_exprs2=random_n_exprs;
      end
     case 'random uniform' then
      //-------------------------------------------------------------------
      tit= 'Uniform random signal';
      values= ['Minimum';'Maximum';'Initial seed';'Sample time';'Number of points'];
      typ= list('vec',1,  'vec',1,'vec',1,'vec',  1,'vec',1);
      [mok,min5,max5,seed5,sample5,np5,random_u_exprs2]=getvalue(tit,values,typ,...
						  random_u_exprs);
      if mok & sample5>0 then
	NOrder=0;
	ipar(2)=NOrder;      
	// rand('seed',seed5);
	xt=0:sample5:sample5*(np5-1);xt=xt(:);
	yt=min5+(max5-min5)*rand(np5,1);
	xy=[xt,yt];	
	[rpar,ipar]=curve_autoscale(a,xy,ipar,rpar);
	random_u_exprs2=random_u_exprs;
      end   
     case 'Save/Exit' then
      //-------------------------------------------------------------------
      NOrder=ipar(2);
      PeridicOption=ipar(3);
      METHOD=curve_getmethod(NOrder);
      if (METHOD=='periodic') then // periodic spline
	xy(N,2)=xy(1,2);
      end
      if or(METHOD==['order 2','not_a_knot','periodic','monotone','fast','clamped']) then 
	rpar=[xy(:,1);xy(:,2);rpar];
      elseif or(METHOD==['zero order','linear'])
	rpar=[xy(:,1);xy(:,2)]
      end
      ok=%t
      xdel(curwin);
      return 
     case 'Exit without save' then 
      //-------------------------------------------------------------------
      ipar=[];
      rpar=[];
      ok=%f
      xdel(curwin);
      return
     case 'Clear' then    
      //-------------------------------------------------------------------
      xy=[0,0];
      NOrder=0;
      ipar(2)=NOrder;
      [rpar,ipar]=curve_autoscale(a,xy,ipar,rpar) 
     case 'Edit text data NOT IN USE' then
      //----------------------------------------------------------------
      //  editvar xy;
      [mok,xt,yt]=getvalue('Enter x and y data',['x';'y'],...
			   list('vec',-1,'vec',-1),...
			   list(strcat(sci2exp(xy(:,1))),strcat(sci2exp(xy(:,2)))));
      if mok then,    
	xy=[xt,yt];
	[xy]=curve_cleandata(xy), 
	[rpar,ipar]=curve_autoscale(a,xy,ipar,rpar) 
      end
     case 'Help' then
      //---------------------------------------------------------------  
      t1='Mouse-left click: adding a new point'
      t2='Mouse-right click: remove a point'
      t3='Mouse-left double click: edit a point''s coordinates'
      t4='Mouse-left button press/drag/release: move a  point'
      t5='Change the window size: ''Data'' menu -> ''Databounds'''
      x_message([t1;t2;t3;t4;t5]);
     case 'Load from Excel' then
      //---------------------------------------------------------------  
      [tok,xytt]=curve_read_excel()
      if tok then
	xy=xytt;
	NOrder=1
	ipar(2)=NOrder;
	[rpar,ipar]=curve_autoscale(a,xy,ipar,rpar) 
      end
     case 'Load from text file' then
      //---------------------------------------------------------------       
      [tok,xytt]=curve_read_from_file()
      if tok then
	xy=xytt;
	NOrder=1
	ipar(2)=NOrder;
	[rpar,ipar]=curve_autoscale(a,xy,ipar,rpar) 
      end
     case 'Save to text file' then    
      //---------------------------------------------------------------     
      [sok]=curve_save_to_file(xy)
     case 'Replot' then
      //---------------------------------------------------------------       
      if ~isempty( xy) then 
	points.data=xy;
	[rpar,ipar]=curve_update_spline(a,xy,ipar,rpar);
      end
     case 'edit' then 
      //----------------------------------------------------------
      HIT=%f
      if N<>0 then
	xt=xy(:,1);yt=xy(:,2);
	dist=((xt-ones(N,1)*xc)).^2+((yt-ones(N,1)*yc)).^2 // 
	[dca,k]=min(dist);
	rectx=a.frect;
	ex=abs(rectx(3)-rectx(1))/80;
	ey=abs(rectx(4)-rectx(2))/80;
	if (abs(xc-xt(k))<ex & abs(yc-yt(k))<ey) then 
	  HIT=%t
	end
      end
      
      if (~HIT)&(btn==0 | btn==3) then    
	// add point
	if (xc>=0) then 
	  if (xc==0) then 
	    zz=find(x==0);
	    xy(zz,:)=[];
	  end 
	  xy=[xy;xc,yc];
	  [xtt,k2]=gsort(xy(:,1),'r','i');xy=xy(k2,:)
	  points.children(1).x=xy(:,1);
	  points.children(1).y=xy(:,2);
	  [rpar,ipar]=curve_update_spline(a,xy,ipar,rpar);  
	  F.invalidate[]
	end
      end
      
      if (HIT)&(btn==2 | btn==5) then 
	//   remove point
	if (xy(k,1)>0) |( xy(k,1)==0 & (size(find(xy(:,1)==0),'*')>1)) then 
	  xy(k,:)=[];
	end
	points.children(1).x=xy(:,1);
	points.children(1).y=xy(:,2);
	[rpar,ipar]=curve_update_spline(a,xy,ipar,rpar);  
	F.invalidate[]
      end  

      if (HIT)&(btn==0) then 
	// move point
	[xy,rpar,ipar]=curve_movept(a,xy,ipar,rpar,k)   
      end
      
      if (HIT)&(btn==10) then             
	// change data:: double click
	[mok,xt,yt]=getvalue('Enter new x and y',['x';'y'],...
			     list('vec', 1,'vec',1),...
			     list(sci2exp(xy(k,1)),sci2exp(xy(k,2))));
	if mok then 
	  xy(k,:)=[xt,yt];
	  [xy]=curve_cleandata(xy)
	  points.children(1).x=xy(:,1);
	  points.children(1).y=xy(:,2);
	  [rpar,ipar]=curve_autoscale(a,xy,ipar,rpar) 
	  F.invalidate[]
	end
      end
    end
  end
endfunction

function [orpar,oipar]=curve_update_spline(a,xy,iipar,irpar)
// compute spline coordinates and 
// updates the polyline object a.children(1).children(1) 
// with computed data. a in an Axes 
//
  N=size(xy,'r');// new size of xy
  x=xy(:,1);  y=xy(:,2);
  order=iipar(2);
  periodicoption=iipar(3);
  orpar=irpar;
  METHOD=curve_getmethod(order);
  if periodicoption==1 then 
    PERIODIC='periodic, T='+string(x(N)-x(1));
  else 
    PERIODIC='aperiodic';
  end  
  // a.title.text=[string(N)+' points,  '+'Method: '+METHOD+',  '+PERIODIC];
  if (N==0) then, return; end
  if (N==1) then, order=0; end
  //  NP=50;// number of intermediate points between two data points 
  [X,Y,orpar]=Do_Spline(N,order,x,y);
  // XXXX strange X and Y 
  Y=Y(:);
  if (periodicoption==1) then 
    X=[X;X($)];
    Y=[Y;Y(1)];
  else
    points=a.children(2).children(1);
    xmx=max(points.x);  xmn=min(points.x);
    XMX=max(0,xmx); XMN=max(0,xmn);
    // xmx1=max(a.x_ticks.locations)
    // XMX=max(XMX,xmx1);    
    X=[X;XMX];
    Y=[Y;Y($)];
  end
  a.children(1).children(1).x=X;
  a.children(1).children(1).y=Y;
  oipar=[N;iipar(2);periodicoption]
endfunction

function [xyt,orpar,oipar]=curve_movept(a,xy,iipar,irpar,k)
// handler activated when moving a control point 
  splines=a.children(1).children(1)
  points=a.children(2).children(1)
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
    rep=xgetmouse(getmotion=%t,getrelease=%t);
    xc=rep(1);yc=rep(2);btn=rep(3);
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
    points.x=xt;
    points.y=yt;
    [orpar,oipar]=curve_update_spline(a,xyt,oipar,orpar); 
    a.invalidate[];
  end
endfunction

function rectx=curve_findrect(a) 
// recompute data bounds in the a axes 
// This should be remove since a is 
// able to give such informations. 
//
  splines=a.children(1).children(1)
  points=a.children(2).children(1)
  if isempty(points.x) then 
    rectx=a.frect;
    rectx=[rectx(1),rectx(2);rectx(3),rectx(4)];
    return;
  end    
  ymx1=max(splines.y);  ymn1=min(splines.y);
  xmx=max(points.x);xmn=min(points.x);
  ymx=max(points.y);ymn=min(points.y);
  XMX=max(0,xmx);     XMN=max(0,xmn);
  YMX=max(ymx,ymx1);  YMN=min(ymn,ymn1);
  dx=XMX-XMN;dy=YMX-YMN
  if dx==0 then dx=max(XMX/2,1),end;
  XMX=XMX+dx/50
  if dy==0 then dy=max(YMX/2,1),end;
  YMN=YMN-dy/50;YMX=YMX+dy/50;  
  rectx=[XMN,YMN;XMX,YMX];
endfunction


function [tok,xyo]=curve_read_excel()
  TA=['A';'B';'C';'D';'E';'F';'G';'H';'I';'J';'K';'L';'M';'N';'O';'P'; ...
      'Q';'R';'S';'T';'U';'V';'W';'X';'Y';'Z';'a';'b';'c';'d';'e';'f'; ...
      'g';'h';'i';'j';'k';'l';'m';'n';'o';'p';'q';'r';'s';'t';'u';'v'; ...
      'w';'x';'y';'z'];
  TN=['0','1','2','3','4','5','6','7','8','9'];
  xyo=[];tok=%f;
  while %t
    values=['Filename';'Sheet # ';'X[start:Stop]';'Y[start:stop]'];
    [zok,filen,sheetN,xa,ya]=getvalue('Excel data file ',values,...
				      list('str',1, 'vec',1,'str',1, 'str',1), ...
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
      [xyo]=curve_cleandata(xyo)
      tok=%t;break,
    catch
      xinfo(' Scicos cannot read your Excel file, please verify"+...
	    " the parameters '); 	 
      break
    end	 
  end
endfunction

function [xyo]=curve_cleandata(xye,strict=%t)
  xe=xye(:,1)
  ye=xye(:,2)
  [nx,mx]=size(xe);// adjusting the x and y size
  [ny,my]=size(ye);
  N=min(nx,ny);
  xe=xe(1:N,:);
  ye=ye(1:N,:);
  // remove nans 
  I=find(isnan(xe));
  xe(I)=[];
  ye(I)=[];
  // remove negative x values 
  zz=find(xe<0);xe(zz)=[];ye(zz)=[]
  if isempty(find(xe==0)) then // add zero point
    xe($+1)=0;
    ye($+1)=0;
  end
  [xo,k2]=gsort(xe,'r','i');
  yo=ye(k2)    
  if strict then 
    I=find(diff(xo)==0);
    xo(I+1)=xo(I)+1.e-8;
    // yo(I+1)=[];
  end
  xyo=[xo,yo];
endfunction

function  [orpar,oipar]=curve_autoscale(a,xy,inipar,inrpar)   
// pause autoscale
  oipar=inipar
  orpar=inrpar
  a.children(2).children(1).x = xy(:,1);  
  a.children(2).children(1).y = xy(:,2);
  a.children(1).children(1).x = xy(:,1);
  a.children(1).children(1).y = xy(:,2);
  [orpar,oipar]=curve_update_spline(a,xy,oipar,orpar);
  rectx=curve_findrect(a);     
  xsetech(frect= [rectx(1),rectx(3),rectx(2),rectx(4)],fixed=%t);
  a.invalidate[];
endfunction

function METHOD=curve_getmethod(order)
// method id for spline.
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

function [sok,xye]=curve_read_from_file()
// read a nx2 matrix in a file 
// using fscanfMat
  xye=[];sok=%f;
  while %t
    values = ['Filename';'format (C)';'Abscissa column';'Output column'];
    [sok,filen,Cformat,Cx,Cy]=getvalue('Text data file ',values,...
				       list('str',1,'str',1,'vec',1,'vec',1), ...
				       list(['mydatafile.dat'],['%g'],['1'],['2']));       
    if ~sok then break,end
    px=strindex(Cformat,'%');
    NC=size(px,'*');    
    if isempty(NC) then, 
      x_message('Bad format for reading data file (see fscanfMat)');
      continue;
    end
    Lx=[];
    try
      Lx=fscanfMat(filen);
    catch
      x_message('cannot open/read data file:'+filen);
      break;
    end 
    pause 
    [nD,mD]=size(Lx);
    if ((mD==0) | (nD==0)) then, x_message('No data read');sok=%f;break;end
    if (mD < 2 ) then, x_message('unable to read two columns in data file');continue;end
    xe=Lx(:,Cx);ye=Lx(:,Cy);
    xye=[xe,ye];
    [xye]=curve_cleandata(xye)
    sok=%t;break,
  end 
endfunction

function [sok]=curve_save_to_file(xye)
// save the nx2 matrix xye in a file 
// using fprintfMat
  sok=%f;
  while %t
    values=['Filename';'format (C)']
    [sok,filen,Cformat]=getvalue('Text data file ',values,list('str',1,'str',1), ...
				 list(['mydatafile.dat'],['%g']));       
    if ~sok then break,end
    px=strindex(Cformat,'%');
    NC=size(px,'*');    
    if NC<>1 then 
      x_message('Bad format for writing data (see fprintfMat)');
      sok=%f;
      continue;
    end
    try
      fprintfMat(filen,xye,format=Cformat)
    catch
      x_message('Cannot open or write with given format to data file '''+filen+'''');
    finally
      sok=%t;
      break,
    end
  end 
endfunction

function [X,Y,orpar]=Do_Spline(N,order,x,y)

  function [Z]=spline_order2(x,y)
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

  // be sure that x is increasing
  [xyo]=curve_cleandata([x,y],strict=%t)
  x=xyo(:,1);
  y=xyo(:,2);
  // 
  X=[];Y=[];orpar=[];
  METHOD=curve_getmethod(order);
  if (METHOD=='zero order') then 
    X=x(1);Y=y(1);
    for i=1:N-1
      X=[X;x(i);x(i+1);x(i+1)];
      Y=[Y;y(i);y(i);y(i+1)];
    end
    return
  end    
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
    Z=spline_order2(x,y);
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

