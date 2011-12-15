function sys=lincos(scs_m,x0,u0,param)
// NAME
// lincos - Constructs by linearization a linear state-space 
// model from a general dynamical system described by a
// scicos diagram

// CALLING SEQUENCE
//
// sys= lincos(scs_m [,x0,u0 [,param] ])
// 
//
// PARAMETERS
//
// scs_m: a Scicos data structure
// x0: column vector. Continuous state around which linearization to be done (default 0)
// u0: column vector. Input around which linearization to be done (default 0)
// param: list with two elements (default list(1.d-6,0))
//   param(1): scalar. Perturbation level for linearization; the following variation is used
//             del([x;u])_i = param(1)+param(1)*1d-4*abs([x;u])_i
//   param(2): scalar. Time t.
//
// sys: state-space system
//
// DESCRIPTION
// Constructs by linearization a linear state-space 
// model from a general dynamical system described by a
// scicos diagram scs_m. Input and output ports, normally
// used inside superblocks, should be used to specify
// inputs and outputs in the scicos diagram. Suppose the
// scicos diagram to be linearized is called mysystem and
// it is saved in mysystem.cos in the current directory. The scicos 
// diagram scs_m can be obtained either by
//             scs_m = scicos('mysystem.cos');
// followed by a quit in the scicos menu, or by 
//             load('mysystem.cos')
// which creates by default a variable called scs_m.

//[lhs,rhs]=argn(0)
IN=[];OUT=[];

[ierr,scicos_ver,scs_m]=update_version(scs_m)
if ~ierr then
  message("Can''t convert old diagram (problem in version)")
  return
end

// //check version
// current_version = get_scicos_version()
// scicos_ver = find_scicos_version(scs_m)
// 
// //do version
// if scicos_ver<>current_version then
//   ierr=execstr('scs_m=do_version(scs_m,scicos_ver)','errcatch')
//   if ierr<>0 then
//     error('Can''t convert old diagram (problem in version)')
//     return
//   end
// end

for i=1:size(scs_m.objs)
  if scs_m.objs(i).type=='Block' then  
    if scs_m.objs(i).gui=='IN_f' then
      scs_m.objs(i).gui='INPUTPORT';
      IN=[IN scs_m.objs(i).model.ipar]
    elseif scs_m.objs(i).gui=='OUT_f' then
      scs_m.objs(i).gui='OUTPUTPORT';
      OUT=[OUT  scs_m.objs(i).model.ipar]
    elseif or(scs_m.objs(i).gui==['CLKIN_f','CLKINV_f']) then
      scs_m.objs(i).gui='INPUTPORTEVTS';
      scs_m.objs(i).model.sim(1)='bidon'
    elseif  or(scs_m.objs(i).gui==['CLKOUT_f','CLKOUTV_f']) then
      scs_m.objs(i).gui='OUTPUTPORTEVTS';
      scs_m.objs(i).model.sim(1)='bidon'
    end
  end
end
IN=-sort(-IN);
if ~isempty(IN) then
  if or(IN<>[1:size(IN,'*')]) then 
    error('Input ports are not numbered properly.')
  end
end
OUT=-sort(-OUT);
if ~isempty(IN) then
  if or(OUT<>[1:size(OUT,'*')]) then 
    error('Output ports are not numbered properly.')
  end
end
//load scicos lib
//load('SCI/macros/scicos/lib')
//compile scs_m
[bllst,connectmat,clkconnect,cor,corinv,ok]=c_pass1(scs_m);
if ~ok then
  error('Diagram does not compile in pass 1');
end
%cpr=c_pass2(bllst,connectmat,clkconnect,cor,corinv,'silent');

if isequal(%cpr,list()) then 
  ok=%f,
end
if ~ok then
  error('Diagram does not compile in pass 2');
end 
sim=%cpr.sim;state=%cpr.state;
//
inplnk=sim.inplnk;inpptr=sim.inpptr;
outlnk=sim.outlnk;outptr=sim.outptr;ipptr=sim.ipptr;

ki=[];ko=[];nyptr=1;
for kfun=1:length(sim.funs)
  if sim.funs(kfun)=='output' then
    sim.funs(kfun)='bidon'
    ko=[ko;[kfun,sim.ipar(ipptr(kfun))]];

  elseif sim.funs(kfun)=='input' then
    sim.funs(kfun)='bidon'
    ki=[ki;[kfun,sim.ipar(ipptr(kfun))]];
    
  end
end
if ~isempty(ko) then
  [junk,ind]=sort(-ko(:,2));ko=ko(ind,1);
end
if ~isempty(ki) then
  [junk,ind]=sort(-ki(:,2));ki=ki(ind,1);
end

pointo=[];
for k=ko' 
  pointo=[pointo;inplnk(inpptr(k))]
end
pointi=[];

for k=ki' 
  pointi=[pointi;outlnk(outptr(k))]
end

nx=size(state.x,'*');
nu=0; for k=pointi', nu=nu+size(state.outtb(k),'*'), end
ny=0; for k=pointo', ny=ny+size(state.outtb(k),'*'), end

if nargin<3 then 
  x0=zeros(nx,1);u0=zeros(nu,1);
else
  if size(x0,'*')<>nx | size(u0,'*')<>nu then
    error('u0 or x0 does not have the correct size')
  end
end
if nargin==4 then 
  del = param(1)+param(1)*1d-4*abs([x0;u0])
  t=param(2)
else
  del=1.d-6*(1+1d-4*abs([x0;u0]))
  t=0
end
  
x0=x0(:);u0=u0(:)
  
state.x=x0;
Uind=1
for k=pointi'
 state.outtb(k)=matrix(u0(Uind:Uind+size(state.outtb(k),'*')-1),size(state.outtb(k)));
 Uind=size(state.outtb(k),'*')+Uind;
end
[state,t]=scicosim(state,t,t,sim,'start',[.1,.1,.1,.1]);
[state,t]=scicosim(state,t,t,sim,'linear',[.1,.1,.1,.1]);
[state_,t_]=scicosim(state,t,t,sim,'finish',[.1,.1,.1,.1]);
Yind=1
y0=[]
for k=pointo'
 y0(Yind:Yind+size(state.outtb(k),'*')-1)=state.outtb(k)(:);
 Yind=size(state.outtb(k),'*')+Yind
end
xp0=state.x;
zo0=[xp0;y0];

F=zeros(nx+ny,nx+nu);
z0=[x0;u0];
zer=zeros(nx+nu,1);

for i=1:nx+nu
  dz=zer;dz(i)=del(i);
  z=z0+dz;
  state.x=z(1:nx);
  Uind=nx+1
  for k=pointi'
   state.outtb(k)=matrix(z(Uind:Uind+size(state.outtb(k),'*')-1),size(state.outtb(k)));
   Uind=size(state.outtb(k),'*')+1;
  end
  [state,t]=scicosim(state,t,t,sim,'start',[.1,.1,.1,.1]);
  [state,t]=scicosim(state,t,t,sim,'linear',[.1,.1,.1,.1]);
  [state_,t_]=scicosim(state,t,t,sim,'finish',[.1,.1,.1,.1]);
  zo=[]
  Yind=1
  for k=pointo'
   zo(Yind:Yind+size(state.outtb(k),'*')-1)=state.outtb(k)(:);
   Yind=size(state.outtb(k),'*')+Yind
  end
  zo=[state.x;zo];
  F(:,i)=(zo-zo0)/del(i);
end
sys=syslin('c',F(1:nx,1:nx),F(1:nx,nx+1:nx+nu),F(nx+1:nx+ny,1:nx),F(nx+1:nx+ny,nx+1:nx+nu));
endfunction

function [sl]=syslin(domain,a,b,c,d,x0)
// check domain 
select type(domain,'short')
case 'm' then  //sampled system
  if size(domain,'*')<=2 then
    tp=domain
  else
    error('domain (1rst argument of syslin) must be a scalar')
  end
  z='z'
case 's' //continuous or discrete
  if size(domain,'*')<>1 then
    error('domain (1rst argument of syslin) must be a single string')
  end
  domain=part(domain,1)
  select domain
  case 'c' then 
    z='s'
  case 'd' then 
    z='z'
  else 
    error(domain+' : unknown time domain')
  end;
else 
  error('1rst argument of syslin should be a string, a scalar or a [] matrix')
end;
//============================================================================
if nargin==2 then //syslin(domaine,sys)

  if type(a,'short')<>'h' then 
    error()
  else
    if a.type=='r'|a.type=='lss' then
      sl=a;
      sl.dt=domain
    else
      error('syslin : H must be a linear state space or a transfer function')
    end
  end
//============================================================================
elseif nargin==3 then // syslin(domaine,num,den)
  num=a;den=b
  if (type(num,'short')<>'p' & type(num,'short')<>'m') |...
     (type(den,'short')<>'p' & type(den,'short')<>'m') then
    error('syslin : N and D must be matrix of numbers or of polynomials')
  end
  if or(size(num)<>size(den)) then
    error('syslin : N and D have inconsistent dimensions')
  end

  if type(num,'short')=='p' & type(den,'short')=='p' then
    if varn(num)<>varn(den) then 
      error('syslin : N and D have inconsistent formal variable names')
     end
  end
  if type(num,'short')=='m' then
    num=num*poly(1,z,name='c')
  end
   if type(den,'short')=='m' then
    den=den*poly(1,z,name='c')
  end
  
  sl=rlist(varn(num,z),varn(den,z),domain)
//============================================================================
elseif nargin>3 then // syslin(domaine,A,B,C [,D [X0]])
  if type(a,'short')<>'m' then
    error('syslin : A must be a square matrix of numbers')
  end
  [ma,na]=size(a);
  if ma<>na then 
    error('syslin : A must be a square matrix of numbers')
  end
  if type(b,'short')<>'m' then
    error('syslin : B must be a  matrix of numbers')
  end
  [mb,nb]=size(b);
  if na<>mb&mb<>0 then 
    error('syslin : row dimension of B do not agree dimensions of A')
  end
  if type(c,'short')<>'m' then
    error('syslin : C must be a  matrix of numbers')
  end
  [mc,nc]=size(c);
  if na<>nc&nc<>0 then 
    error('syslin : column dimension of C do not agree dimensions of A')
  end
  if nargin<6 then
    x0=0*ones(na,1)
  else
    if type(x0,'short')<>'m' then
      error('syslin : X0 must be a vector of numbers')
    end
    [mx,nx]=size(x0);
    if mx<>na|nx<>min(na,1) then 
      error('syslin : dimensions of X0 do not agree')
    end
  end
  if nargin<5  then
    d=0*ones(mc,nb)
  else
    if (type(d,'short')<>'p' & type(d,'short')<>'m') then
      error('syslin : D must be a  matrix of numbers or polynomials')
    end
    [md,nd]=size(d);
    if ~isempty(c*b) then
      if mc<>md|nb<>nd then 
        error('syslin : column dimension of D do not agree dimensions of B or C')
      end
    end
  end
  sl=hash(A=a,B=b,C=c,D=d,X0=x0,dt=domain,type='lss')
end
 
endfunction
