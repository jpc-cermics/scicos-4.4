function [x,y,typ]=Assignment(job,arg1,arg2)
//
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
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    ok=%f
    gv1 = ['Set Block Parameter';
	   'Index Option can have 5 value:';
	   ' 1- All Assign';
	   ' 2- Index Vector (diagram)';
	   ' 3- Index Vector (port)';
	   ' 4- Starting index (diagram)';
	   ' 5- Starting index (port)';
	   'The size of the Index Option vector must be equal to Number of output dimensions';
	   'Initialize output can be 0 or 1:';
	   ' 0- Initialize using input port (y0)';
	   ' 1- Specify the size for each dimension';
	   'When Initialize using input port is selected the Output Size is not used';
	   'Index is used when Index Option is 2 or 4';
	   'It is a matrix where the number of rows must be equal to Number of output dimensions'];
    gv2 = ['Number of output dimensions (1 or 2)';
	   'Index Base ( 0 or 1)';
	   'Index Option';
	   'Index';
	   'Output Size';
	   'Initialize Output (0 or 1)';
	   'Inherit( 0=no, 1=yes)']
    gv3= list('vec',1,'vec',1,'vec',-1,'lis',-1,'vec',-1,'vec',1,'vec',1);

    while ~ok do
      [ok,nod,indxb,indxopt,indx,otsz,out0,inh,exprs]=getvalue(gv1,gv2,gv3,exprs);
      if ~ok then break,end
      if and(nod<>[1;2]) then message('Number of output dimensions must 1 or 2');ok=%f;
      elseif and(indxb<>[0;1]) then message( 'Index Base must be 0 or 1');ok=%f;
      elseif size(indxopt,'*')<>nod then message(' The size of Index Option must be equal to Number of output dimensions');ok=%f;
      elseif max(max(indxopt))>5 then message(' Values in Index Option must be 1,2,3,4 or 5');ok=%f;
      elseif min(min(indxopt))<1 then message(' Values in Index Option must be 1,2,3,4 or 5');ok=%f;
      elseif length(indx)<>nod then message(' The number of object in Index must be equal to Number of output dimensions');ok=%f;
      elseif size(otsz,'*')<>nod then message(' The size of Output Size must be equal to Number of output dimensions');ok=%f;
      elseif and(out0<>[0;1]) then message( 'Initialize Output must be 0 or 1');ok=%f;
      elseif and(inh<>[0;1]) then message( 'Inherit must be 0 or 1');ok=%f;
      else
	otsz=floor(otsz);
	for i=1:length(indx)
	  indx(i)=floor(indx(i)(:))
	end
	indxopt=floor(indxopt(:));
	ind1=find(indxopt==4);
	for i=ind1
	  if size(indx(i),'*')>1 then message('the object '+string(i)+' of Index must be a scalar');ok=%f;end
	end 
      end
      if ok then
	in=[];it=[];
	if out0==1 then
	  if nod==2 then
	    in=[in;[-1 -2]];
	    out=[-1 -2];
	  else
	    in=[in;[-1 1]];out=[-1 1];
	  end
	  it=[it;-1];ot=-1	
	else
	  if nod==2 then
	    out=otsz(:);out=out';
	  else
	    out=[otsz 1];
	  end
	  ot=-1
	end
	in=[in;[1 1]];it=[it;-1];
	for i=1:nod
	  if or(indxopt(i)==[3,5]) then
	    in=[in;[1 1]];it=[it;-1];
	  end
	end
	[model,graphics,ok]=set_io(model,graphics,list(in,it),list(out,ot),ones(1-inh,1),[])
	if ok then
	  if length(indx)==1 then indx(2)=[];end
	  model.opar=list(indxb,indxopt,indx(1),indx(2),otsz,out0)
	  graphics.exprs=exprs;
	  arg1.graphics=graphics;arg1.model=model;
	  x=arg1
	  break
	end
      end
    end
   case 'define' then
    model=scicos_model()
    junction_name='assignment';
    funtyp=4;
    model.sim=list(junction_name,funtyp)
    model.in=[-1;1;1]
    model.in2=[1;1;1]
    model.intyp=[-1 -1 -1]
    model.out=-1
    model.out2=1
    model.outtyp=-1
    model.evtin=[]
    model.evtout=[]
    model.state=[]
    model.dstate=[]
    model.rpar=[]
    model.ipar=[]
    model.opar=list(1,3,1,[],1,1);
    model.blocktype='c' 
    model.firing=[]
    model.dep_ut=[%t %f]
    exprs=['1';'1';'3';'list(1)';'1';'1';'1']
    gr_i=['Assignment_draw(orig,sz,o);'];
    x=standard_define([3 3],model,exprs,gr_i,'Assignment');
  end
endfunction

function Assignment_draw(orig,sz,o) 
  [x,y,typ]=standard_inputs(o) ;
  if ~arg1.graphics.flip then 
    px='right';xp=orig(1)+sz(1)*(1-1/16);
  else
    px='left';xp=orig(1)+sz(1)/16
  end;
  vv=evstr(arg1.graphics.exprs(3));
  if ~exists("%zoom") then %zoom=1, end;
  fz= 2*%zoom*4;
  for k=1:size(x,"*");
    if typ(k)==1;
      if arg1.graphics.exprs(6)=="1" then;
	if k==1  then
	  xstring(xp,y(k),"y0",posy='center',posx=px,size=fz);
	elseif k==2 then
	  xstring(xp,y(k),"u",posy='center',posx=px,size=fz);
	elseif or(vv(1)==[3;5]) then
	  txt="I"+string(k-2);
	  xstring(xp,y(k),txt,posy='center',posx=px,size=fz);
	else 
	  txt="I"+string(k-1);
	  xstring(xp,y(k),txt,posy='center',posx=px,size=fz);
	end;
      else
	if k==1 then 
	  xstring(xp,y(k),"u",posy='center',posx=px,size=fz);
	elseif or(vv(1)==[3;5]) then  
	  txt="I"+string(k-1);
	  xstring(xp,y(k),txt,posy='center',posx=px,size=fz);
	else 
	  txt="I"+string(k);
	  xstringb(xp,y(k),txt,posy='center',posx=px,size=fz);
	end;
      end;
    end;
  end;
  [x,y,typ]=standard_outputs(o) ;
  if arg1.graphics.flip then 
    px='right';xp=orig(1)+sz(1)*(1-1/16);
  else
    px='left';xp=orig(1)+sz(1)/16
  end;
  xstring(xp,y(1),"y",posy='center',posx=px,size=fz)
  xstring(orig(1)+sz(1)/2,orig(2)+sz(2)/2,"A",posx='center',posy='center',size=fz);
  xstring(orig(1)+sz(1)/2,orig(2),"Assignment",posx='center',posy='up',size=fz);
endfunction

