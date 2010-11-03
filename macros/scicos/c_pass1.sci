function  [blklst,cmat,ccmat,cor,corinv,ok,flgcdgen,freof]=c_pass1(scs_m,flgcdgen)
// Copyright INRIA
//Last Update Fady: 15 Dec 2008
//derived from c_pass1 for implicit diagrams
//%Purpose
// Determine one level blocks and connections matrix
//%Parameters
// scs_m  :   scicos data structure
// ksup   :
// blklst : a list containing the "model" information structure for each block
//
// cmat   : nx6 matrix. Each row contains, in order, the block
//             number and the port number and the port type of an outgoing scicopath,
//             and the block number and the port number and the port type of the target
//             ingoing scicopath. for regular links
//
// ccmat  : nx4 matrix.  Each row contains, in order, the block
//             number and the port number  of an outgoing scicopath,
//             and the block number and the port number  of the target
//             ingoing scicopath for clock connections
  
// cor    : is a list with same recursive structure as scs_m each leaf 
//          contains the index of associated block in blklst 
// corinv : corinv(nb) is the path of nb ith block defined in blklst 
//          in the scs_m structure
//!
// Serge Steer 2003, Copyright INRIA
// flgcdgen: is a flag containing the number of event input of the diagram
//           it is used only in the Codegeneration case.
// freof   : it is a vector containing the frequency and the offset of the major clock.
//           it is used only in the Codegeneration case.
// Fady Nassif 2007. INRIA.
//c_pass1;
if argn(2)<=1 then flgcdgen=-1, end
freof=[];
MaxBlock=countblocks(scs_m);
[cor,corinvt,links_table,cur_fictitious,sco_mat,ok,scs_m1]=scicos_flat(scs_m);
if ok then
  [links_table,sco_mat,ok]=global_case(links_table,sco_mat)
  if ~isempty(find(sco_mat(:,5)==string(4))) then
    [scs_m1,corinvt,cor,sco_mat,links_table,ok,flgcdgen,freof]=treat_sample_clk(scs_m1,corinvt,cor,sco_mat,links_table,flgcdgen,[])
  end
end
if ~ok then 
  blklst=[];cmat=[],ccmat=[],cor=[],corinv=[]
  return;
end
index1=find((sco_mat(:,2)=='-1')& (sco_mat(:,5)<>'10')& (sco_mat(:,5)<>'4'))
if ~isempty(index1) then		// 
  for i=index1
    [path]=findinlist(cor,-evstr(sco_mat(i,1)))
    full_path=path(1)
    if flgcdgen<>-1 then full_path=[numk full_path];scs_m=all_scs_m;end
    hilite_path(full_path,"Error in compilation, There is a FROM ''"+(sco_mat(i,3))+ "'' without a GOTO",%t)
    ok=%f;
    blklst=[];cmat=[],ccmat=[],cor=[],corinv=[]
    return;
  end
end
nb=size(corinvt);
reg=1:nb
//form the block lists
blklst=list();kr=0 ; //regular  block list 
blklstm=list();km=0; //modelica block list
//if ind(i)>0  ith block is a regular  block and stored in blklst(ind(i))
//if ind(i)<0  ith block is a modelica block and stored in blklstm(-ind(i))
ind=[];
for kb=1:nb
  if type(corinvt(kb),'short')=='l' then
    o=scs_m1(scs_full_path(corinvt(kb)($))); // we consider in the case of sample clock that the corinv of the added block is 
                                             // a list that contains the path to the sample clocks that it replaces 
					     // and to that block in the changed scs_m.
    corinvt(kb)($)=null();
  else
    o=scs_m1(scs_full_path(corinvt(kb)));
  end
  if is_modelica_block(o) then
    km=km+1;blklstm(km)=o.model;
    ind(kb)=-km;
    [modelx,okx]=build_block(o); // compile modelica block type 30004
    if ~okx then 
      cmat=[],ccmat=[],cor=[],corinv=[]
      return
    end
  else
    [model,ok]=build_block(o);
    if ~ok then 
      cmat=[],ccmat=[],cor=[],corinv=[]
      return,
    end
    if or(model.sim(1)==['plusblk']) then
      [model,links_table]=adjust_sum(model,links_table,kb);
    end
    if model.sim(1)<>'sampleclk' then
      kr=kr+1;blklst(kr)=model;
      ind(kb)=kr;
    else
      ind(kb)=0;
    end
  end
end
if ~isempty(find(sco_mat(:,5)==string(4))) then
  if flgcdgen ==-1 then
//    [links_table,blklst,corinvt,cor,ind,sco_mat,ok]=sample_clk(sco_mat,links_table,blklst,corinvt,cor,scs_m,ind,flgcdgen)
  else 
//    [links_table,blklst,corinvt,cor,ind,sco_mat,ok,flgcdgen,freof]=sample_clk(sco_mat,links_table,blklst,corinvt,cor,scs_m,ind,flgcdgen)
  end
  if ~ok then
    cmat=[],ccmat=[],cor=[],corinv=[]
    return,
  end
  smplk=find(ind==0);
  ind(smplk)=[]
  reg=1:size(corinvt);
end
//links_table=link_sample0_to_allout(links_table,blklst,MaxBlock);
nb=size(corinvt)
nl=size(links_table,1)/2
links_table=[links_table(:,1:3) matrix([1;1]*(1:nl),-1,1) links_table(:,4) ];

imp=find(ind<0)
reg(imp)=[]
if isempty(imp) then //no modelica block exists
  cmat=matfromT(links_table(find(links_table(:,5)==1),:),nb); //data flow links
  ccmat=cmatfromT(links_table(find(links_table(:,5)==-1),:),nb); //event links
  busmat=matfromT(links_table(find(links_table(:,5)==3),:),nb); // buses
  corinv=corinvt
else // mixed diagram
  nm=size(imp,'*') //number of modelica blocks
  nr=nb-nm //number of regular blocks
  
  cmmat=mmatfromT(links_table(find(links_table(:,5)==2),:),nb); //modelica links
  cmat=matfromT(links_table(find(links_table(:,5)==1),:),nb); //data flow links
  ccmat=cmatfromT(links_table(find(links_table(:,5)==-1),:),nb);//event links
  busmat=matfromT(links_table(find(links_table(:,5)==3),:),nb); // buses
  //build connections between modelica world and regular one. These
  //links should be data flow links
  
  // links from modelica world to regular world
  
  fromM=find(bsearch(cmat(:,1),imp,match='v')>0);NoM=size(fromM,'*');
  if NoM>0 then
    //add modelica Output ports in Modelica world
    mo=modelica();mo.model='OutPutPort';mo.outputs='vo';mo.inputs='vi';
    for k=1:NoM,blklstm($+1)=scicos_model(equations=mo);end
    //add modelica connections to these Output ports, set negative
    //value to port numbers to avoid conflits with other blocks
    cmmat=[cmmat;
	cmat(fromM,1:2) zeros(NoM,1) -(nm+(1:NoM)'),ones(NoM,1),ones(NoM,1)];
    nm=nm+NoM;
    //add regular connection with regular block replacing the modelica world
    cmat(fromM,1:2)=[-(nr+1)*ones(NoM,1),(1:NoM)'];
  end
  // links from regular world to modelica world 
  toM=find(bsearch(cmat(:,3),imp,match='v')>0);NiM=size(toM,'*');
  if NiM>0 then
    //add modelica Input ports in Modelica world
    mo=modelica();mo.model='InPutPort';mo.outputs='vo';mo.inputs='vi';
    for k=1:NiM,blklstm($+1)=scicos_model(equations=mo);end
    //add modelica connections to these Input ports  set negative
    //value to port numbers to avoid conflits with other blocks
    cmmat=[cmmat;
	-(nm+(1:NiM)'), ones(NiM,1),zeros(NiM,1), cmat(toM,3:4), ones(NiM,1) ];
    nm=nm+NiM;
    //add regular connection with regular block replacing the modelica world
    cmat(toM,3:4)=[-(nr+1)*ones(NiM,1),(1:NiM)'];
  end
  // modelica blocks with events ports are not allowed yet
  if size(ccmat,1)>0 then
    if or(bsearch(ccmat(:,[1 3]),imp,match='v')>0) then
      x_message('An implicit block has an event port')
      ok=%f;return
    end
  end
  //renumber blocks according to their types	
  corinv=list();corinvm=list();
  for kb=1:nb
    if ind(kb)<0 then // modelica block
      km=-ind(kb);
      //replace by negative value to avoid conflicts
      cmmat(find(cmmat(:,1)==kb),1)=-km ;
      cmmat(find(cmmat(:,4)==kb),4)=-km;
      corinvm(km)=corinvt(kb);
    elseif ind(kb)>0 then
      kr=ind(kb);
      cmat (find(cmat (:,1)==kb),1)=-kr;
      cmat (find(cmat (:,3)==kb),3)=-kr;
      busmat (find(busmat (:,1)==kb),1)=-kr;
      busmat (find(busmat (:,3)==kb),3)=-kr;
      ccmat(find(ccmat(:,1)==kb),1)=-kr;
      ccmat(find(ccmat(:,3)==kb),3)=-kr;
      corinv(kr)=corinvt(kb);
    end
  end
  //renumbering done, replace negative value by positive ones

  cmat(:,[1 3])=abs(cmat(:,[1 3])) ;
  busmat(:,[1 3])=abs(busmat(:,[1 3])) ;
  ccmat(:,[1 3])=abs(ccmat(:,[1 3])) ;
  cmmat=abs(cmmat) ;
  //create regular block associated to all modelica blocks
  [model,ok]=build_modelica_block(blklstm,corinvm,cmmat,NiM,NoM,scs_m,TMPDIR+'/');

  if ~ok then
   return
  end

  blklst(nr+1)=model;

  //make compiled modelica block refer to the set of corresponding
  //modelica blocks
  corinv(nr+1)=corinvm //it may be useful to adapt function making use
  //of corinv

  //adjust the numbering of regular block in sco_mat
  //if modelica's blocks exist
  //Fady 08/11/2007
  for i=1:size(sco_mat,1)
    // if eval(sco_mat(i,1))<MaxBlock then
    if evstr(sco_mat(i,1))<MaxBlock then
      sco_mat(i,1)=string(ind(evstr(sco_mat(i,1))))
    end
  end
  sco_mat=[sco_mat;[string(size(blklst)) '-1' 'scicostimeclk0' '1' '10']]
end
//the buses must be treated here
if size(busmat,1)>0
  [ok,blklst,cmat,ccmat,cor,corinv,reg,sco_mat]=BusAnalysis(blklst,cmat,ccmat,busmat,cor,corinv,reg,MaxBlock,sco_mat,scs_m);
  if ~ok then 
    blklst=[];cmat=[],ccmat=[],cor=[],corinv=[]
    return;
  end
end
cor=update_cor(cor,reg)

// Taking care of the clk 0; 
//*** this part has been taken from c_pass2 modified and placed here it must be tested ***
//Fady 08/11/2007
nbl=size(blklst)
fff=ones(nbl,1)==1
clkptr=zeros(nbl+1,1);clkptr(1)=1; typ_l=fff;
for i=1:nbl
  ll=blklst(i);
  clkptr(i+1)=clkptr(i)+size(ll.evtout,'*');
  //tblock(i)=ll.dep_ut($);
  typ_l(i)=ll.blocktype=='l';
end
all_out=[]
for k=1:size(clkptr,1)-1
  if ~typ_l(k) then
    kk=[1:(clkptr(k+1)-clkptr(k))]'
    all_out=[all_out;[k*ones(size(kk)),kk]]
  end
end
ccmat=link_sample0_to_allout(all_out,ccmat)
all_out=[all_out;[0,0]]
//add time event if needed
tblock=find((sco_mat(:,2)=='-1')&(sco_mat(:,5)=='10'))
ind=sco_mat(tblock,1);
if ~isempty(ind) then
  //ind=eval(ind(:))
  ind = evstr(ind(:))
  //ind=find(tblock)
  //ind=ind(:)
  for k=ind'
    ccmat=[ccmat;[all_out,ones(size(all_out))*[k,0;0,0]]]
  end
  for Ii=1:length(blklst)
    if type(blklst(Ii).sim(1),'short')=='s' then
      if part(blklst(Ii).sim(1),1:7)=='capteur' then
        ccmat=[ccmat;[0 0 Ii 0]]
      end
    end
  end
end
//*** 
endfunction


function [model,links_table]=adjust_sum(model,links_table,k)
//sum blocks have variable number of input ports, adapt the associated
//model data structure and input connection to take into account the
//actual number of connected ports
// Serge Steer 2003, Copyright INRIA
  in=find(links_table(:,1)==k&links_table(:,3)==1)
  nin=size(in,'*')
  model.in=-ones(nin,1)
  links_table(in,2)=(1:nin)'
endfunction


function mat=mmatfromT(Ts,nb)
//S. Steer, R. Nikoukhah 2003. Copyright INRIA
  Ts(:,1)=abs(Ts(:,1));
  K=unique(Ts(find(Ts(:,1)>nb),1)); // identificator of blocks to be removed
  //remove superblocks port and split connections 
  Ts=remove_fictitious(Ts,K)
  
  // from connection matrix
  Imat=zeros(0,2);
  for u=matrix(unique(Ts(:,4)),1,-1)
    kue=matrix(find(Ts(:,4)==u),-1,1); //identical links
    Imat=[Imat;[kue(2:$)  kue(1).*ones(size(kue(2:$)))]];
  end
  mat=[Ts(Imat(:,1),1:3)  Ts(Imat(:,2),1:3)]
endfunction


function mat=matfromT(Ts,nb)
//S. Steer, R. Nikoukhah 2003. Copyright INRIA

  Ts(:,1)=abs(Ts(:,1))
  K=unique(Ts(find(Ts(:,1)>nb),1)); // identificator of blocks to be removed
  //remove superblocks port and split connections 
  Ts=remove_fictitious(Ts,K)

  // from connection matrix
  Imat=zeros(0,2);
  for u=matrix(unique(Ts(:,4)),1,-1)
    kue=matrix(find(Ts(:,4)==u&Ts(:,3)==-1),-1,1); //look for outputs
    jue=matrix(find(Ts(:,4)==u&Ts(:,3)==1),-1,1); //look for inputs
    Imat=[Imat;[ones(size(jue)).*.kue jue.*.ones(size(kue))]];
  end
  mat=[Ts(Imat(:,1),1:2)  Ts(Imat(:,2),1:2)]
endfunction

function mat=cmatfromT(Ts,nb)
//S. Steer, R. Nikoukhah 2003. Copyright INRIA
//this function has been modified to support 
// CLKGOTO et CLKFROM
// Fady NASSIF: 11/07/2007
  k=find(Ts(:,1)<0) //superblock ports links and CLKGOTO/CLKFROM
  K=unique(Ts(k,1));
  Ts=remove_fictitious(Ts,K)
  
  if isempty(Ts) then mat=[],return,end
//  if size(Ts,1)<>int(size(Ts,1)/2)*2 then disp('PB'),pause,end
  [s,k]=gsort(Ts(:,[4,3]),'lr','i');Ts=Ts(k,:)
  // modified to support the CLKGOTO/CLKFROM
  //mat=[Ts(1:2:$,1:2) Ts(2:2:$,1:2)]
//----------------------------------

  J=find(Ts(:,3)==1); //find the destination block of the link
  v=find([Ts(:,3);-1]==-1) // find the source block of the link
  // many destination blocks can be connected to one source block
  // so we have to find the number of destination blocks for each source block
  // v(2:$)-v(1:$-1)-1
  // then create the vector I that must be compatible with the vector J.
  I=duplicate(v(1:$-1),v(2:$)-v(1:$-1)-1); 
  mat=[Ts(I,1:2),Ts(J,1:2)]

//----------------------------------
  K=unique(Ts(Ts(:,1)>nb))
  Imat=zeros(0,2);
  for u=matrix(K,1,-1)
    jue=matrix(find(mat(:,1)==u),-1,1); //look for outputs
    kue=matrix(find(mat(:,3)==u),-1,1); //look for inputs
    Imat=[ones(size(jue)).*.kue jue.*.ones(size(kue))];
    mat1=[mat(Imat(:,1),1:2), mat(Imat(:,2),3:4)];
    mat([jue;kue],:)=[];
    mat=[mat;mat1];
  end
  
endfunction

function Ts=remove_fictitious(Ts,K)
//removes fictitious blocks connected links are replaced by a single one
//S. Steer, R. Nikoukhah 2003. Copyright INRIA
  count=min(Ts(:,4))
  for i=1:size(K,'*')
    ki=K(i);
    v1=find(Ts(:,1)==ki);
    if ~isempty(v1) then		
      v=unique(Ts(v1,4));
      Ts(v1,:)=[];
      if size(v,'*')==1 then
	ind=find(Ts(:,4)==v);
      else
	ind = find(bsearch(Ts(:,4),gsort(v,'g','i'),match='v')<>0);
      end
      if size(ind,'*')>1 then
	count=count-1;
	Ts(ind,4)=count
      else
	Ts(ind,:)=[]
      end
    end
  end
endfunction

function cor=update_cor(cor,reg)
  n=size(cor)
  for k=1:n
    if type(cor(k),'short')=='l' then
      cor(k)=update_cor(cor(k),reg)
    else
      p=find(cor(k)==reg)
      if ~isempty(p) then 
	cor(k)=p
      elseif cor(k)<0 then  // GOTO FROM cases
	cor(k)=0
      elseif cor(k)<>0 then
	cor(k)=size(reg,'*')+1
      end
    end
  end
endfunction

function clkconnect=link_sample0_to_allout(allout,clkconnect)
  if ~isempty(clkconnect) then 
    blk0=find(clkconnect(:,1)==0)
  else
    blk0=[];
  end
  if ~isempty(blk0) then
    for i = blk0
      clkconnect=[clkconnect;[allout clkconnect(i,3)*ones(size(allout,1),1) clkconnect(i,4)*ones(size(allout,1),1)]];
    end
  end 
endfunction
