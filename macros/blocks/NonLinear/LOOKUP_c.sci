function [x,y,typ]=LOOKUP_c(job,arg1,arg2)
// Masoud Najafi 01/2008 --------
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
    if or(exprs(5)==['y','Y']) then exprs(5)='yes';end 
    if or(exprs(5)==['n','N']) then exprs(5)='no';end 
    ok=%f;
    SaveExit=%f
    while %t do
      Ask_again=%f
      [ok,Method,xx,yy,extrapo,graf,exprs]=getvalue('Lookup table parameters',..
						    ['Spline Interpolation method (0..9)';..
		    'x';'y';'Extrapolate method (0,1)';'Launch graphic window(y/n)?'],..
						    list('vec',1,'vec',-1,'vec',-1,'vec',1,'combo',['yes','no']),exprs)
      // 9 : nearest
      // 8 : above
      // 0:  below
      // extra: 0:hold; 1: use end values
      //

      if  ~ok then break;end    
      PeriodicOption='n';

      if PeriodicOption=='y' | PeriodicOption=='Y' then,PO=1;else,PO=0;end
      mtd=int(Method); if mtd<0 then mtd=0;end; if mtd>9 then mtd=9;end;    
      METHOD=lookup_getmethod(mtd);
      extrapo=int(extrapo); if extrapo<0 then extrapo=0;end; if extrapo>1 then extrapo=1;end;    


      if ~Ask_again then 
	xx=xx(:);yy=yy(:);
	[nx,mx]=size(xx); [ny,my]=size(yy);
	if ~((nx==ny)&(mx==my)) then, message('incompatible size of x and y');  Ask_again=%t;end
      end
      
      if ~Ask_again then//+++++++++++++++++++++++++++++++++++++++
	xy=[xx,yy];
	[xy]=lookup_cleandata(xy);// just for sorting to be able to compare data before and after poke_point(.)
	N= size(xy,'r');
	exprs(5)='no';// exprs.graf='n'
	if graf=='yes' then //_______Graphic editor___________
	  ipar=[N;mtd;PO;extrapo];
	  rpar=[];
	  if ~exists('curwin') then
            F=get_current_figure()
	    curwin=F.id
	  end
	  save_curwin=curwin;
	  curwin=max(winsid())+1;
	  [orpar,oipar,ok]=lookup_poke_point(xy,ipar,rpar);
	  curwin=save_curwin;
	  if ~ok then break;end;//  exit without save

	  // verifying the data change
	  N2=oipar(1);xy2=[orpar(1:N2),orpar(N2+1:2*N2)];
	  New_methhod=oipar(2);
	  DChange=%f;	
	  METHOD=lookup_getmethod(New_methhod);
	  if or(xy(:,1)<>xy2(:,1)) then, DChange=%t;end
	  if or(xy(1:N-1,2)<>xy2(1:N2-1,2)) then, DChange=%t;end
	  if (xy(N,2)<>xy2(N2,2) & (METHOD<>'periodic')) then, DChange=%t;end
	  if DChange then 
	    exprs(2)=strcat(sci2exp(xy2(:,1)))
	    exprs(3)=strcat(sci2exp(xy2(:,2)))
	  end
	  exprs(1)=sci2exp(New_methhod);
	  exprs(4)=sci2exp(oipar(4));
	  if oipar(3)==1 then,perop='y';else,perop='n';end
	  SaveExit=%t
	else//_____________________No graphics__________________________
	  [Xdummy,Ydummy,orpar]=Lookup_Do_Spline(N,mtd,xy(:,1),xy(:,2),xy($,1),xy(1,1),0);
	  if (METHOD=='periodic') then // periodic spline
	    xy(N,2)=xy(1,2);
	  end	
	  if (METHOD=='order 2' | METHOD=='not_a_knot'|METHOD=='periodic' | METHOD=='monotone'| METHOD=='fast' | METHOD=='clamped') then 
	    orpar=[xy(:,1);xy(:,2);orpar];		
	  else
	    if (METHOD=='zero order-below'|METHOD=='linear'|METHOD=='zero order-above'|METHOD=='zero order-nearest') then
	      orpar=[xy(:,1);xy(:,2)]
	    end	
	  end
	  exprs(1)=sci2exp(mtd);// pour le cas methode>7 | method<0
	  oipar=[N;mtd;PO;extrapo]	
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

    xx=[-1;0.5;1;1.5;2.5]
    yy=[-6;-1;-3;3;-4]
    N=length(xx);  Method=1;Graf='no'
    model.sim=list('lookup_c',4)
    model.in=-1
    model.in2=-2
    model.outtyp=-1
    
    model.out=-1 
    model.out2=-2
    model.outtyp=-1
    
    model.rpar=[xx(:);yy(:)]
    model.ipar=[N;Method;0;0]
    model.blocktype='c'
    model.dep_ut=[%t %f]
    model.evtin=[]
    model.evtout=[]
    model.firing=0
    exprs=[sci2exp(Method);sci2exp(xx);sci2exp(yy);sci2exp(0);Graf]
    
    gr_i=['rpar=arg1.model.rpar;n=model.ipar(1);order=model.ipar(2);';
	  'xx=rpar(1:n);yy=rpar(n+1:2*n);';
	  '[XX,YY,rpardummy]=Lookup_Do_Spline(n,order,xx,yy,xx(n),xx(1),model.ipar(4))';
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
    x=standard_define([2 2],model,exprs,gr_i,'LOOKUP_c');
  end
endfunction

function [rpar,ipar,ok]=lookup_poke_point(ixy,iparin,rparin)
//[lhs,rhs]=argn(0)
//in line definition of get_click
  function [btn,xc,yc,win,Cmenu]=get_click(flag)
    if ~or(winsid() == curwin) then
      Cmenu = 'Quit';
      return
    end;
    [btn, xc, yc, win, str] = xclick();
    if btn == -100 then
      if win == curwin then
        Cmenu = 'Quit'
      else
	Cmenu = 'Open/Set';
      end
      return
    end
    if btn == -2 then
      xc = 0;yc = 0;
      try  // added to handle unwanted menu actions in french version
        execstr('Cmenu=' + part(str, 9:length(str) - 1));
        execstr('Cmenu=' + Cmenu)
      catch
        Cmenu=""
      end  
      return
    end
    Cmenu=""
  endfunction

  //   deff('[btn,xc,yc,win,Cmenu]=get_click(flag)',[
  //       'if ~or(winsid() == curwin) then   Cmenu = ''Quit'';return,end,';
  //       'if argn(2) == 1 then';
  //       '  [btn, xc, yc, win, str] = xclick(flag);';
  //       'else';
  //       '  [btn, xc, yc, win, str] = xclick();';
  //       'end;'; 
  //       'if btn == -100 then';
  //       '  if win == curwin then';
  //       '    Cmenu = ''Quit'';';
  //       '  else';
  //       '    Cmenu = ''Open/Set'';';
  //       '  end,';
  //       '  return,';
  //       'end';
  //       'if btn == -2 then';
  //       '  xc = 0;yc = 0;';
  //       '  try '    // added to handle unwanted menu actions in french version
  //       '    execstr(''Cmenu='' + part(str, 9:length(str) - 1));';
  //       '    execstr(''Cmenu='' + Cmenu);';
  //       '  catch'
  //       '    Cmenu=[]'    
  //       '  end '    
  //       '  return,';
  //       'end';
  //       'Cmenu=[]'])
  
  ok=%f
  if nargin==0 then ixy=[];end;
  if size(xy,'c')<2 then 
    xinfo(' No y provided');
    return
  end

  [xy]=lookup_cleandata(ixy)
  N=size(xy,'r');

  if nargin<=1 then
    NOrder=1;
    PeridicOption=0;
    extrapo=0
    ipar=[N;NOrder;PeridicOption;extrapo]
    rpar=[]
  elseif nargin==2 then  
    NOrder=iparin(2);
    PeridicOption=iparin(3);
    extrapo=iparin(4);
    ipar=iparin;
    rpar=[]
  elseif nargin==3 then  
    NOrder=iparin(2);
    PeridicOption=iparin(3);
    extrapo=iparin(4);
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
  xmx=max(xy(:,1));xmn=min(xy(:,1)),
  ymx=max(xy(:,2));ymn=min(xy(:,2));
  dx=xmx-xmn;dy=ymx-ymn
  if dx==0 then dx=max(xmx/2,1),end;
  xmx=xmx+dx/50;
  if dy==0 then dy=max(ymx/2,1),end;
  ymn=ymn-dy/50;ymx=ymx+dy/50;

  rect=[xmn,ymn;xmx,ymx];
  //===================================================================
  xset('window',curwin)
  delmenu(curwin,'3D Rot.')
  delmenu(curwin,'File')

  menu_r=[];
  menu_s=[];
  menu_o=['zero order-below','linear','order 2','not_a_knot','periodic','monotone','fast','clamped','zero order-above','zero order-nearest']
  menu_d=['Clear','Data Bounds','Load from text file','Save to text file','Load from Excel','Extrapolation']
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
  xsetech(frect=[rect(1),rect(3),rect(2),rect(4)]);
  xtitle('', 'Input', 'Output' );
  xpolys(xy(:,1),xy(:,2),[5]);
  xpolys(xy(:,1),xy(:,2),[-1]);
  F=get_current_figure();
  a=F.children(1);
  splines=F.children(1).children(1);
  points=F.children(1).children(2);
  points.children(1).hilited=%t;
  [rpar,ipar]=lookup_autoscale(a,xy,ipar,rpar)
  F.invalidate[]
  dblclick=%f

  // start of interactive loop 
  while %t then
    N=size(xy,'r');
    [btn,xc,yc,win,Cmenu]=get_click();
    //printf("Lookup_c : Cmenu =%s, btn=%d\n",Cmenu,btn);
    if ((win>0) & (win<>curwin)) then
      Cmenu='Mouse click is Offside!';
    end
    if Cmenu.equal[""] then Cmenu='edit',end
    if (Cmenu=='Exit') |(Cmenu=='Quit' ) then, ipar=[];rpar=[];ok=%f;return; end
    methods=['zero order-below';'linear';'order 2';'not_a_knot';'periodic'; ...
	     'monotone';'fast';'clamped';'zero order-above';'zero order-nearest'];
    
    NOrder = find(Cmenu== methods);
    if ~isempty(NOrder) then 
      //printf("Lookup_c : Norder =%d\n",NOrder);
      ipar(2)= NOrder -1;
      [rpar,ipar]=lookup_autoscale(a,xy,ipar,rpar)  
    end

    select Cmenu
     case 'Data Bounds' then
      rectx=lookup_findrect(a);
      [mok,xmn1,xmx1,ymn1,ymx1]=getvalue('Enter new bounds',['xmin';'xmax'; ...
		    'ymin';'ymax'],list('vec',1,'vec',1,'vec',1,'vec',1), ...
					 string(rectx))
      //drawlater();
      if mok then 
	if (xmn1>xmx1|ymn1>ymx1) then
	  xinfo('Incorrect bounds')
	  mok=%f;
	end
	if mok then 
	  xsetech(frect=[xmn1,ymn1,xmx1,ymx1],fixed=%t);
	end
      end
      a.invalidate[];
      //drawnow();//show_pixmap(); 
      //-------------------------------------------------------------------  
     case 'Autoscale' then 
      [rpar,ipar]=lookup_autoscale(a,xy,ipar,rpar) 
      //-------------------------------------------------------------------  
     case 'Extrapolation' then 
      //extrapo
      if extrapo==1 then, ans0='1',else, ans0='0',end;
      [mok,myans]=getvalue('Extrapolation method (just for Method 1)',['0: hold end values, 1: extrapolation'],list('vec',1),list(ans0));
      if (mok==%t) then
	extrapo=int(myans); if extrapo<0 then extrapo=0;end; if extrapo>1 then extrapo=1;end;    
	ipar(4)=extrapo;
	[rpar,ipar]=lookup_autoscale(a,xy,ipar,rpar) 
      end
      //-------------------------------------------------------------------
     case 'sine' then 
      if ~exists('Sin_exprs') then 
	Sin_exprs=list("1","%pi","0","0","10");
      end
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
	[rpar,ipar]=lookup_autoscale(a,xy,ipar,rpar) 
	Sin_exprs=Sin_exprs2
      end
      //-------------------------------------------------------------------
     case 'sawtooth1' then 
      if ~exists('Sawt1_exprs') then 
	Sawt1_exprs=list("1","3","2");
      end
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
	[rpar,ipar]=lookup_autoscale(a,xy,ipar,rpar);
	Sawt1_exprs=Sawt1_exprs2
      end
      //-------------------------------------------------------------------
     case 'sawtooth2' then     
      if ~exists('Sawt2_exprs') then 
	Sawt2_exprs=list("1","3");
      end
      [mok,sAmp2,sTp2,Sawt2_exprs2]=getvalue('Sawtooth signal parameters', ...
					     ['Amplitude';'Period'],list('vec',1,'vec',1),Sawt2_exprs)    
      if mok & sTp2>0 then
	NOrder=1;
	ipar(2)=NOrder;
	xt=[0;sTp2];
	yt=[sAmp2;-sAmp2];
	xy=[xt,yt];	
	[rpar,ipar]=lookup_autoscale(a,xy,ipar,rpar);
	Sawt2_exprs=Sawt2_exprs2
      end
      //-------------------------------------------------------------------
     case 'pulse' then
      if ~exists('Pulse_exprs') then 
	Pulse_exprs=list("1","3","2","0","0");
      end
      [mok,Amp3,Tp3,Pw3,Pd3,Bias3,Pulse_exprs2]=getvalue('Square wave pulse signal', ...
						  ['Amplitude';'Period (sec)';'Pulse width(% of period)';'Phase delay (sec)';'Bias'],list('vec',1, ...
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
	[rpar,ipar]=lookup_autoscale(a,xy,ipar,rpar);
	Pulse_exprs=Pulse_exprs2;
      end
      //-------------------------------------------------------------------
     case 'random normal' then
      if ~exists('random_n_exprs') then 
	random_n_exprs=list("0","1","0","3","10");
      end
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
	[rpar,ipar]=lookup_autoscale(a,xy,ipar,rpar);
	random_n_exprs2=random_n_exprs;
      end
      //-------------------------------------------------------------------
     case 'random uniform' then
      if ~exists('random_u_exprs') then 
	random_u_exprs=list("-1","1","0","3","10");
      end
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
	[rpar,ipar]=lookup_autoscale(a,xy,ipar,rpar);
	random_u_exprs2=random_u_exprs;

      end   
      //-------------------------------------------------------------------
     case 'Save/Exit' then
      NOrder=ipar(2);
      PeridicOption=ipar(3);

      METHOD=lookup_getmethod(NOrder);
      if (METHOD=='periodic') then // periodic spline
	xy(N,2)=xy(1,2);
      end
      
      if (METHOD=='order 2' | METHOD=='not_a_knot'|METHOD=='periodic' | METHOD=='monotone'| METHOD=='fast' | METHOD=='clamped') then 
	rpar=[xy(:,1);xy(:,2);rpar];
      else
	if (METHOD=='zero order-below'|METHOD=='linear'|METHOD=='zero order-above'|METHOD=='zero order-nearest')
	  rpar=[xy(:,1);xy(:,2)]
	end
      end
      
      ok=%t
      xdel(curwin);
      return 
      //-------------------------------------------------------------------
     case 'Exit without save' then 
      ipar=[];
      rpar=[];
      ok=%f
      xdel(curwin);
      return
      //-------------------------------------------------------------------
     case 'Clear' then    
      xy=[0,0];
      NOrder=0;
      ipar(2)=NOrder;
      [rpar,ipar]=lookup_autoscale(a,xy,ipar,rpar) 
      //----------------------------------------------------------------
     case 'Edit text data NOT IN USE' then
      //  editvar xy;
      [mok,xt,yt]=getvalue('Enter x and y data',['x';'y'],list('vec',-1,'vec',-1),list(strcat(sci2exp(xy(:,1))),strcat(sci2exp(xy(:,2)))));
      if mok then,    
	xy=[xt,yt];
	[xy]=lookup_cleandata(xy), 
	[rpar,ipar]=lookup_autoscale(a,xy,ipar,rpar) 
      end
      //---------------------------------------------------------------  
     case 'Help' then
      t1='Mouse-left click: adding a new point'
      t2='Mouse-right click: remove a point'
      t3='Mouse-left double click: edit a point''s coordinates'
      t4='Mouse-left button press/drag/release: move a  point'
      t5='Change the window size: ''Data'' menu -> ''Databounds'''
      message([t1;t2;t3;t4;t5]);
      //---------------------------------------------------------------  
     case 'Load from Excel' then
      [tok,xytt]=lookup_read_excel()
      if tok then
	xy=xytt;
	NOrder=1
	ipar(2)=NOrder;
	[rpar,ipar]=lookup_autoscale(a,xy,ipar,rpar) 
      end
      //---------------------------------------------------------------       
     case 'Load from text file' then
      [tok,xytt]=lookup_readfromfile()
      if tok then
	xy=xytt;
	NOrder=1
	ipar(2)=NOrder;
	[rpar,ipar]=lookup_autoscale(a,xy,ipar,rpar) 
      end
      //---------------------------------------------------------------     
     case 'Save to text file' then    
      [sok]=lookup_save_to_file(xy)
      //---------------------------------------------------------------       
     case 'Replot' then
      if ~isempty(xy) then 
	points.data=xy;
	[rpar,ipar]=lookup_drawsplin(a,xy,ipar,rpar);
      end
      //----------------------------------------------------------
     case 'edit' then
      HIT=%f
      if N<>0 then
	xt=xy(:,1);yt=xy(:,2);
	dist=((xt-ones(N,1)*xc)).^2+((yt-ones(N,1)*yc)).^2
	[dca,k]=min(dist);
	rectx=a.frect;
	ex=abs(rectx(3)-rectx(1))/80;
	ey=abs(rectx(4)-rectx(2))/80;
	if (abs(xc-xt(k))<ex & abs(yc-yt(k))<ey) then 
	  HIT=%t
	end
      end
      
      //printf("Edit case : HIT=%d, btn=%d\n",HIT,btn);
      //_________________________
      //  if ~((NOrder==-1|NOrder==-2|NOrder==-3|NOrder==-4)) then
      if ~HIT && (btn==2 | btn==5) then    // add point
	xy=[xy;xc,yc];
	[xtt,k2]=gsort(xy(:,1),'r','i');
	xy=xy(k2,:)
	[xy]=lookup_cleandata(xy)
	points.children(1).x=xy(:,1);
	points.children(1).y=xy(:,2);
	[rpar,ipar]=lookup_drawsplin(a,xy,ipar,rpar);  
	F.invalidate[]
      end
      
      if HIT && (btn==2 | btn==5) then  //   remove point
	if (xy(k,1)>0) |( xy(k,1)==0 & (size(find(xy(:,1)==0),'*')>1)) then 
	  xy(k,:)=[];
	end
	points.children(1).x=xy(:,1);
	points.children(1).y=xy(:,2);
	[rpar,ipar]=lookup_drawsplin(a,xy,ipar,rpar);  
	F.invalidate[]
      end   

      if HIT && (btn==0) then             // move point
	[xy,rpar,ipar,dblclick]=lookup_movept(a,xy,ipar,rpar,k)
      end
      
      if (HIT && dblclick) then
        // change data:: double click
        dblclick=%f
	[mok,xt,yt]=getvalue('Enter new x and y',['x';'y'],list('vec', ...
						  1,'vec',1),list(sci2exp(xy(k,1)),sci2exp(xy(k,2))));
	if mok then 
	  xy(k,:)=[xt,yt];
	  [xy]=lookup_cleandata(xy)
	  points.children(1).x=xy(:,1);
	  points.children(1).y=xy(:,2);
	  [rpar,ipar]=lookup_autoscale(a,xy,ipar,rpar) 
	  F.invalidate[]
	end
      end

      //  end
      //_________________________________
      
    end
    //----------------------------------------------------------
  end
endfunction

function [orpar,oipar]=lookup_drawsplin(a,xy,iipar,irpar)
  N=size(xy,'r');// new size of xy
  x=xy(:,1);  y=xy(:,2);
  order=iipar(2);
  periodicoption=iipar(3);
  extrapo=iipar(4);
  orpar=irpar;
  METHOD=lookup_getmethod(order);
  if periodicoption==1 then
    PERIODIC='periodic, T='+string(x(N)-x(1));
  else
    PERIODIC='aperiodic';
  end
  xtitle(string(N)+' points,  '+'Method: '+METHOD+',  '+PERIODIC);
  if (N==0) then, return; end
  if (N==1) then, order=0; end
  //  NP=50;// number of intermediate points between two data points 
  //   points=a.children(2).children
  //   splines=a.children(1).children
  //    a.title.text=[string(N)+' points,  '+'Method: '+METHOD+',  '+PERIODIC];


  a.children(2).children(1).x = xy(:,1);  
  a.children(2).children(1).y = xy(:,2);
  a.children(1).children(1).x = xy(:,1);
  a.children(1).children(1).y = xy(:,2);

  points=[a.children(2).children(1).x a.children(2).children(1).y]
  splines=[a.children(1).children(1).x a.children(1).children(1).y]
  xmx=max(points(:,1));
  xmn=min(points(:,1));
  xmx1=a.frect(3);
  xmn1=a.frect(1);

  [X,Y,orpar]=Lookup_Do_Spline(N,order,x,y,xmx,xmn,extrapo);
  
  if (periodicoption==1) then 
    X=[X;X($)];
    Y=[Y;Y(1)];
  else
    //X=[X;XMX];
    //Y=[Y;Y($)];
  end
  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  //splines.data=[X,Y];    
  a.children(1).children(1).x=X
  a.children(1).children(1).y=Y
  a.invalidate[];
  oipar=[N;iipar(2);periodicoption;extrapo]
endfunction


function [xyt,orpar,oipar,dblclick]=lookup_movept(a,xy,iipar,irpar,k)
//on bouge un point existant
  splines=a.children(1).children(1)
  points=a.children(2).children(1)
  oipar=iipar
  orpar=irpar
  order=iipar(2);
  x=xy(:,1);  y=xy(:,2);  
  x(k)=[];
  y(k)=[]; 
  btn=-1
  while ~(btn==3 | btn==0| btn==10| btn==-5)
    rep=xgetmouse(getmotion=%t,getrelease=%t);
    xc=rep(1);yc=rep(2);btn=rep(3);
    xinfo(sprintf('(%5.2f,%5.2f)',xc,yc));
    xt=[x;xc];
    yt=[y;yc];
    [xt,k2]=gsort(xt,'r','i');
    yt=yt(k2)
    xyt=lookup_cleandata([xt,yt]);
    points.x=xyt(:,1);
    points.y=xyt(:,2);
    [orpar,oipar]=lookup_drawsplin(a,xyt,oipar,orpar); 
    a.invalidate[];
  end
  if btn==3 then
    dblclick=%t
  else
    dblclick=%f
  end
endfunction

function rectx=lookup_findrect(a)
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
  XMX=max(xmx);     XMN=max(xmn);
  YMX=max(ymx,ymx1);  YMN=min(ymn,ymn1);
  dx=XMX-XMN;dy=YMX-YMN
  if dx==0 then dx=max(XMX/2,1),end;
  XMX=XMX+dx/50
  if dy==0 then dy=max(YMX/2,1),end;
  YMN=YMN-dy/50;YMX=YMX+dy/50;  
  rectx=[XMN,YMN;XMX,YMX];
endfunction


function [tok,xyo]=lookup_read_excel()
  TA=['A';'B';'C';'D';'E';'F';'G';'H';'I';'J';'K';'L';'M';'N';'O';'P'; ...
      'Q';'R';'S';'T';'U';'V';'W';'X';'Y';'Z';'a';'b';'c';'d';'e';'f'; ...
      'g';'h';'i';'j';'k';'l';'m';'n';'o';'p';'q';'r';'s';'t';'u';'v'; ...
      'w';'x';'y';'z'];
  TN=['0','1','2','3','4','5','6','7','8','9'];
  xyo=[];tok=%f;
  while %t
    [zok,filen,sheetN,xa,ya]=getvalue('Excel data file ',['Filename';'Sheet # ';'X[start:Stop]';'Y[start:stop]'],list('str',1, ...
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
      [xyo]=lookup_cleandata(xyo)
      
      tok=%t;break,
    catch
      xinfo(' Scicos cannot read your Excel file, please verify the parameters '); 	 
      break
    end	 
  end
  
endfunction

function [xyo]=lookup_cleandata(xye)
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
  
  [xo,k2]=gsort(xe,'r','i');
  yo=ye(k2)    
  
  xyo=[xo,yo];
endfunction

function  [orpar,oipar]=lookup_autoscale(a,xy,inipar,inrpar)
  oipar=inipar
  orpar=inrpar
  if isempty(xy) then return;end
  a.children(2).children(1).x = xy(:,1);  
  a.children(2).children(1).y = xy(:,2);
  a.children(1).children(1).x = xy(:,1);
  a.children(1).children(1).y = xy(:,2);
  [orpar,oipar]=lookup_drawsplin(a,xy,oipar,orpar);
  rectx=lookup_findrect(a); 
  xsetech(frect= [rectx(1),rectx(3),rectx(2),rectx(4)],fixed=%t);
  a.invalidate[];
endfunction

function METHOD=lookup_getmethod(order)
  select order
   case 0 then, METHOD='zero order-below'
   case 1 then, METHOD='linear'
   case 2 then, METHOD='order 2'
   case 3 then, METHOD='not_a_knot'
   case 4 then, METHOD='periodic'
   case 5 then, METHOD='monotone'
   case 6 then, METHOD='fast'
   case 7 then, METHOD='clamped'
   case 8 then, METHOD='zero order-above'
   case 9 then, METHOD='zero order-nearest'
  end
endfunction

function [sok,xye]=lookup_readfromfile()
  xye=[];sok=%f;
  while %t
    [sok,filen,Cformat,Cx,Cy]=getvalue('Text data file ',['Filename';'Reading [C] format';'Abscissa column';'Output column'],list('str',1,'str',1,'vec',1,'vec',1), ...
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
    [xye]=lookup_cleandata(xye)
    sok=%t;break,
  end 
endfunction

function [sok]=lookup_save_to_file(xye)
  xe=xye(:,1)
  ye=xye(:,2)
  sok=%f;
  while %t
    [sok,filen,Cformat]=getvalue('Text data file ',['Filename';'Writing [C] format'],list('str',1,'str',1), ...
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

function [X,Y,orpar]=Lookup_Do_Spline(N,order,x,y,xmx,xmn,extrapo)
  X=[];Y=[];orpar=[];

  METHOD=lookup_getmethod(order);

  if (METHOD=='zero order-below') then 
    X=[xmn;x(1)];
    Y=[y(1);y(1)];
    for i=1:N-1
      X=[X;x(i+1);x(i+1)];
      Y=[Y;y(i);y(i+1)];
    end
    X=[X;xmx];
    Y=[Y;y(N)];
    return
  end    
  if (METHOD=='zero order-above') then 
    X=[xmn;x(1)];
    Y=[y(1);y(1)];
    for i=1:N-1
      X=[X;x(i);x(i+1)];
      Y=[Y;y(i+1);y(i+1)];
    end
    X=[X;xmx];
    Y=[Y;y(N)];
    return
  end    
  if (METHOD=='zero order-nearest') then 
    X=[xmn;x(1)];
    Y=[y(1);y(1)];
    for i=1:N-1
      X=[X;(x(i)+x(i+1))/2;(x(i)+x(i+1))/2];
      Y=[Y;y(i);y(i+1)];
    end
    X=[X;xmx];
    Y=[Y;y(N)];
    return
  end    

  if (METHOD=='linear') then
    if N<=1 then return; end
    if extrapo==0 then 
      X=[xmn];
      Y=[y(1)];
    end
    if extrapo==1 then 
      X=[xmn];    
      Y=y(1)+(xmn-x(1))*(y(1)-y(2))/(x(1)-x(2)); 
    end
    for i=1:N
      X=[X;x(i)];
      Y=[Y;y(i)];
    end
    if extrapo==0 then 
      X=[X;xmx];
      Y=[Y;y(N)];
    end
    if extrapo==1 then 
      X=[X;xmx];    
      Y=[Y;y(N)+(xmx-x(N))*(y(N)-y(N-1))/(x(N)-x(N-1))]; 
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
  if extrapo==1 then 
    X=[linspace(xmn,x(1),NP+2)';X;linspace(x(N),xmx,NP+2)'];
  end
  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  if (N>2) & (METHOD=='order 2') then
    Z=lookup_order2(x,y);
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
  if extrapo==0 then 
    X=[X(:);xmx];
    Y=[Y(:);y(N)];
  end

endfunction


function [Z]=lookup_order2(x,y)
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

