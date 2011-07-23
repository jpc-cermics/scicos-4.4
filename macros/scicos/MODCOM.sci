function [ok,tt]=MODCOM(funam,tt,vinp,vout,vparam,vparamv,vpprop)
// Copyright INRIA
//
  ok = %t;
  //[dirF,nameF,extF]=fileparts(funam);
  [dirF,nameF,extF]=splitfilepath(funam);

  //the new head
  class_txt_new=build_classhead(funam,vinp,vout,vparam,vparamv,vpprop)

  if isempty(tt) then
    tete4= ['';' //     Real x(start=1), y(start=2);']
    tete5='equation';

    tete6=['      // exemple'];
    tete7='      //der(x)=x-x*y;';
    tete8='      //der(y)+2*y=x*y;';
    tete9='end '+nameF+';';
    textmp=[class_txt_new;tete4;tete5;tete6;tete7;tete8;tete9];
  else
    modif=%f;
    for i=1:size(tt,'*')
      I = strindex(stripblanks(tt(i)),'////do not modif above this line ////')
      if ~isempty(I) then 
        //tt(1:i-1) : the current head
        textmp=[class_txt_new;tt(i+1:$)]
        modif=%t
        break
      end
    end
    if ~modif then textmp=tt, end;
  end

  editblk=%f
  //## set param of scstxtedit
  ptxtedit = scicos_txtedit(clos = 0,...
			    typ  = "ModelicaClass",...
			    head = ['Function definition in Modelica';
                    'Here is a skeleton of the functions'+...
		    ' which you should edit'])
  while %t
    if (extF=='' | (extF=='.mo' & ~file('exists',funam))) then
      editblk=%t;
      //[txt,Quit] = scstxtedit(textmp,ptxtedit);
      cm = catenate(ptxtedit.head,sep='\n');
      txt = editsmat('Cfunc edition',textmp,comment=cm);
      Quit = %t;
    elseif (extF=='.mo' && file('exists',funam)) then
      txt=tt;
    end
    
    if ptxtedit.clos==1 then
      break;
    end

    if ~isempty(txt) then
      ok=%t;
      if ok then
	// create Modelica dir if it does not exists 
	md =file('join',[getenv('NSP_TMPDIR');'Modelica'])
	if ~file('exists',md) then file('mkdir',md);end 
	// saving in a file
	if (extF=='')  then
	  funam=file('join',[getenv('NSP_TMPDIR'),'Modelica',nameF+'.mo']);
	  scicos_mputl(txt,funam);
	elseif ~file('exists',funam) then
	  scicos_mputl(txt,funam);
	end
	ptxtedit.clos = 1;
	tt   = txt;
      end
      textmp    = txt;
    end

    if editblk then
      if Quit then
	ok=%f;
	break;
      end
    elseif isempty(txt) then
      ok=%f; // cancel bouton
      break
    end
  end
endfunction


function class_txt=build_classhead(funam,vinp,vout,vparam,vparamv,vpprop)
//build_classhead : build the head of the modelica function
//
  
//[dirF,nameF,extF]=fileparts(funam);
  [dirF,nameF,extF]=splitfilepath(funam);
  
  ni=size(vinp,'r');   //** number of inputs
  no=size(vout,'r');   //** number of outputs
  np=size(vparam,'r'); //** number of params

  tete1=['model '+nameF]

  //** parameters head
  if np<>0 then
    tete1b= '      //parameters';
    for i=1:np
      //** param
      if vpprop(i)==0 then
	head='      parameter Real '
	if size(vparamv(i),'*')==1 then
	  head=head+ sprintf('%s = %e;', vparam(i), vparamv(i));
	else
	  head=head+vparam(i)+'['+string(size(vparamv(i),'*'))+']={';
	  for j=1:size(vparamv(i),'*')
	    head=head+sprintf('%e', vparamv(i)(j));
	    if j<>size(vparamv(i),'*') then
	      head=head+','
	    end
	  end
	  head=head+'};'
	end
	//** state
      elseif vpprop(i)==1 then
	head='      Real           '
	if size(vparamv(i),'*')==1 then
	  head=head+ sprintf('%s (start=%e);', vparam(i), vparamv(i));
	else
	  head=head+vparam(i)+'['+string(size(vparamv(i),'*'))+'](start={';
	  for j=1:size(vparamv(i),'*')
	    head=head+sprintf('%e', vparamv(i)(j));
	    if j<>size(vparamv(i),'*') then
	      head=head+','
	    end
	  end
	  head=head+'});'
	end
	//** fixed state
      elseif vpprop(i)==2 then
	head='      Real           '
	if size(vparamv(i),'*')==1 then
	  head=head+sprintf('%s (fixed=true,start=%e);', vparam(i), vparamv(i));
	else
	  head=head+vparam(i)+'['+string(size(vparamv(i),'*'))+'](start={';
	  P_fix='fixed={'
	  for j=1:size(vparamv(i),'*')
	    head=head+sprintf('%e', vparamv(i)(j));
	    P_fix=P_fix+'true'
	    if j<>size(vparamv(i),'*') then
	      head=head+','
	      P_fix=P_fix+','
	    end
	  end
	  head=head+'},'+P_fix+'});'
	end
      end
      tete1b=[tete1b
              head]
    end
  else
    tete1b=[];
  end

  //** inputs head
  if ni<>0 then
    tete2= '      Real ';
    for i=1:ni
      tete2=tete2+vinp(i);
      if (i==ni) then  tete2=tete2+';';else  tete2=tete2+',';end
    end
    tete2=['      //input variables';
           tete2];
  else
    tete2=[];
  end

  //** outputs head
  if no<>0 then
    tete3= '      Real '
    for i=1:no
      tete3=tete3+vout(i);
      if (i==no) then  tete3=tete3+';';else  tete3=tete3+',';end
    end
    tete3=['      //output variables';
           tete3];
  else
    tete3=[];
  end

  tete4='  ////do not modif above this line ////'
  //-----------------------------------------

  class_txt=[tete1;
             '  ////automatically generated ////';
             tete1b;tete2;tete3;tete4]
endfunction

function [ok,tt]=MODCOM_NI(funam,tt,vinp,vout,vparam,vparamv,vpprop)
// This is the non interactive version used in eval or load 
  printf('In non interactive MODCOM \n');
  ok = %t;
  // create Modelica dir if it does not exists 
  md =file('join',[getenv('NSP_TMPDIR');'Modelica'])
  if ~file('exists',md) then file('mkdir',md);end 
  // fill the funam file 
  nameF=file('root',file('tail',funam));
  extF =file('extension',funam);
  if extF=='' then 
    funam1=file('join',[getenv('NSP_TMPDIR');'Modelica';nameF+'.mo']);
    scicos_mputl(tt,funam1);
  elseif ~file('exists',funam) then
    funam1=funam;
    scicos_mputl(tt,funam1);
  end
endfunction

