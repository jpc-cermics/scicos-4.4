function [scs_m,corinv,cor,sco_mat,links_table,ok,flgcdgen,freof]=...
    treat_sample_clk(scs_m,corinv,cor,sco_mat,links_table,flgcdgen,path)

  // copyright: INRIA
  // Anthor: Fady NASSIF
  // Date: 23-1-2009
  // we can put here a test for the method to use in the future 
  // The Code generator will use the method with the fixed step
  // Scicos Simulator will use the method of variable step
  ok=%t;freof=[];
  index=find(sco_mat(:,5)==string(4)) //index of SampleCLK blocks
  if ~isempty(index) then
    sco_mat1=sco_mat(index,:);
    sco_mat(index,:)=[];
    if flgcdgen<>-1 then  // Code Generator or Scicos Simulator with fixed step
      [scs_m,corinv,cor,links_table,ok,flgcdgen,freof]=FixedStepMethod(scs_m,corinv,cor,sco_mat1,links_table,path)
    else // Scicos Simulator with variable step
      [scs_m,corinv,cor,links_table,ok]=VariableStepMethod(scs_m,corinv,cor,sco_mat1,links_table,path)
    end
  end
endfunction

function [scs_m,corinv,cor,Ts,ok,flgcdgen,freof]=FixedStepMethod(scs_m,corinv,cor,MAT,Ts,path)
  [frequ,offset,freqdiv,flg,ok]=ComputeClockFreqOff(MAT)
  if ok then 
    [scs_m,corinv,cor,Ts,flgcdgen,freof]=update_changes(scs_m,corinv,cor,MAT,Ts,path,frequ,offset,freqdiv,flg);
  end
endfunction

function [frequ,offset,freqdiv,flg,ok]=ComputeClockFreqOff(MAT)
  ok=%t;
  flg=1;
  freq1=evstr(MAT(:,3));
  offset1=evstr(MAT(:,4));
  [m,k]=ts_uni(freq1,offset1);
  if size(m,'*')==1 then flg=0;end  // case of one offset and one frequency.
  freqdiv=freq1(k)
  if size(unique(offset1),'*')==1 then  // case of one offset
    v=freqdiv;
    offset=offset1(1);
  else   // multiple offsets
    offset=offset1(k);
    v=[freqdiv;offset];
    offset=0;
  end
  v=v(find(v<>0));
  min_v=min(v);max_v=max(v);
  if (max_v/min_v)>1e5 then message(['The difference between the frequencies is very large';..
		    'the clocks could not be synchronized']);
    ok=%f;Ts=[];bllst=[];corinv=list();indout=[];
    return; 
  end
  [freqdiv,den]=GetDenNum(v,max_v,scs_m.props.tol(3));
  frequ=double(den);
  if isempty(frequ) then frequ=0;end
  if isempty(offset) then offset=0; end
  if (offset > frequ) then
    offset=modulo(offset,frequ)
    if (offset~=0) then ok=%f; end
  end
endfunction

function [scs_m,corinv,cor,Ts,flgcdgen,freof]=update_changes(scs_m,corinv,cor,MAT,Ts,path,frequ,offset,freqdiv,flg)
//modification to support double
// when the function is called by the code generator we add an input event to the diagram
// the major clock will be put outside the superblock. it will be explicitly drawn.
// In the other case the major clock will be implicitly used in the diagram.
// Adding the first block 
  new_blk=scicos_block();
  if flgcdgen<>-1 then // when the function is called by the codegeneration.
    flgcdgen=flgcdgen+1 	// the flgcdgen contains the number of event input.
    // we incremented to be able to add the sampleclk to the diagram at the end
    // Adding the event input block.
    new_blk.model=scicos_model(sim=list("bidon",0),in=[],in2=[],intyp=1,out=[],out2=[],..
			       outtyp=1,evtin=[],evtout=1,state=[],dstate=[],odstate=list(),..
			       rpar=[],ipar=flgcdgen,opar=list(),blocktype="d",firing=-1,..
			       dep_ut=[%f,%f],label="",nzcross=0,nmode=0,equations=list());
    freof=[frequ;offset];
  else
    new_blk.model=scicos_model(sim=list("evtdly4",4),in=[],in2=[],intyp=1,out=[],out2=[],..
			       outtyp=1,evtin=1,evtout=1,state=[],dstate=[],odstate=list(),..
			       rpar=[frequ;offset],ipar=[],opar=list(),blocktype="d",firing=offset,..
			       dep_ut=[%f,%f],label="",nzcross=0,nmode=0,equations=list());
    freof=[frequ;offset];
  end
  scs_m.objs($+1)=new_blk;
  n_scs_m=length(scs_m.objs);
  // Adjusting cor and corinv
  [corinv,cor]=AdjustingCorCorinv(corinv,cor,path,MAT,n_scs_m)
  nb=size(corinv)
  if flgcdgen==-1 then
    // linking the output of the evtdly to its input.
    Ts($+1:$+2,:)=[nb 1 -1 -1;..
		   nb 1 1  -1]
  end
  if flg then //more then one frequency or offset   
    nn=lcm(freqdiv);
    //Adding the counter to the block list.
    new_blk=scicos_block();
    new_blk.model=scicos_model(sim=list("counter",4),in=[],in2=[],intyp=1,out=1,out2=1,..
			       outtyp=1,evtin=1,evtout=[],state=[],dstate=0,odstate=list(),..
			       rpar=[],ipar=[1;double(nn);1],opar=list(),blocktype="c",firing=[],..
			       dep_ut=[%f,%f],label="",nzcross=0,nmode=0,equations=list());
    scs_m.objs($+1)=new_blk;
    n_scs_m=length(scs_m.objs);
    // Adjusting cor and corinv
    [corinv,cor]=AdjustingCorCorinv(corinv,cor,path,MAT,n_scs_m)
    
    // Adding the event select to the block list.
    new_blk=scicos_block();
    new_blk.model=scicos_model(sim=list("eselect",-2),in=1,in2=1,intyp=-1,out=[],out2=[],..
			       outtyp=1,evtin=[],evtout=ones(nn,1),state=[],dstate=[],odstate=list(),..
			       rpar=[],ipar=[],opar=list(),blocktype="l",firing=-ones(nn,1),..
			       dep_ut=[%t,%f],label="",nzcross=0,nmode=0,equations=list());
    scs_m.objs($+1)=new_blk;
    n_scs_m=length(scs_m.objs);
    // Adjusting cor and corinv
    [corinv,cor]=AdjustingCorCorinv(corinv,cor,path,MAT,n_scs_m)
    nb=size(corinv)
    
    // linking the event output of the evntdly or the bidon to the counter.
    // and linking the regular output of the counter to the event select.
    Ts($+1:$+4,:)=[nb-2 1 -1 -1;..
		   nb-1,1,1,-1;..
		   nb-1,1,-1,1;..
		   nb,1,1,1]
    // replacing the SampleClk by the output of the event select
    index=find(MAT(:,5)==string(4))
    for i=1:size(MAT,1)
      num=-evstr(MAT(i,1))
      Ts(find(Ts(:,1)==num),1)=-num
      K=0:nn-1;
      M=find(modulo(int(K),int(round(evstr(MAT(i,3))/frequ)))==0)';
      ON=ones(size(M,'*'),1)
      Ts($+1:2:$+2*size(M,'*'),:)=[nb*ON round(M+ON*(evstr(MAT(i,4))/frequ-offset)) -ON -ON]
      N=[1:size(M,'*')]';
      Ts($+1-(2*size(M,'*')-2):2:$+1,:)=[-num*ON N ON -ON]
    end
  else
    nb=size(corinv)
    ON=ones(size(MAT,1),1)
    Ts($+1:2:$+2*size(MAT,1),:)=[nb*ON ON -ON -ON]
    num=-evstr(MAT(:,1))
    Ts($+1-(2*size(MAT,1)-2):2:$+1,:)=[-num ON ON -ON]
    for i=1:size(MAT,1)
      Ts(find(Ts(:,1)==num(i)),1)=-num(i)
    end
  end
endfunction

function [scs_m,corinv,cor,Ts,ok]=VariableStepMethod(scs_m,corinv,cor,MAT,Ts,path)
  ok=%t  // removing the computed sample clk from the sco_mat.
  frequ=evstr(MAT(:,3));  // frequencies of the sampleCLK
  offset=evstr(MAT(:,4)); // offsets of the SampleCLK
  offset=offset(:);frequ=frequ(:); 
  [m,den,off,count,m1,fir,frequ,offset,ok]=mfrequ_clk(frequ,offset);
  if ~ok then return;end
  mn=(2**size(m1,'*'))-1;//number of event outputs.
  new_blk=scicos_block();
  new_blk.model=scicos_model(sim=list("m_frequ",4),in=[],in2=[],intyp=1,out=[],out2=[],outtyp=1,..
			     evtin=1,evtout=ones(mn,1),state=[],dstate=[],odstate=list(),rpar=[],ipar=[],..
			     opar=list(m,double(den),off,count),blocktype="d",firing=fir,dep_ut=[%f,%f],..
			     label="",nzcross=0,nmode=0,equations=list());
  scs_m.objs($+1)=new_blk;
  n_scs_m=length(scs_m.objs);
  [corinv,cor]=AdjustingCorCorinv(corinv,cor,path,MAT,n_scs_m)
  nb=size(corinv);
  k=1:mn;
  //connecting all the event outputs to the event input of the M_Frequ block
  Ts($+1:2:$+2*mn,:)=[nb*ones(mn,1) k' -ones(mn,2)]
  Ts($+1-(2*mn-2):2:$+1,:)=[nb*ones(mn,1) ones(mn,2) -ones(mn,1)]
  //replacing the SampleCLK by the outputs of the M_frequ
  for i=1:size(frequ,'*')
    num=evstr(MAT(find((evstr(MAT(:,3))==frequ(i))&(evstr(MAT(:,4))==offset(i))),1))
    for ii=num'
      Ts(find(Ts(:,1)==-ii),1)=ii;
      j=2**(i-1):2**i:mn;
      v=j;
      for k=1:2**(i-1)-1;
	v=[v,j+k]
      end
      v=(unique(v))
      ON=ones(size(v,'*'),1)
      N=[1:size(v,'*')]';
      Ts($+1:2:$+2*size(v,'*'),:)=[nb*ON v' -ON -ON]
      Ts($+1-(2*size(v,'*')-2):2:$+1,:)=[ii*ON N ON -ON]
    end
  end
endfunction

function [m,k]=ts_uni(fr,of)
// jpc: version plus courte nsp 
//  [m,k]= unique([fr(:),of(:)],which ="rows");
//  m=m(:,1);
//
  k=[];
  m=[];
  ot=[];
  for i=1:size(fr,'*')
    istreated=%f;
    ind=find(m==fr(i));
    if isempty(ind) then
      m=[m;fr(i)];
      ot=[ot;of(i)];
      k=[k;i];
    else
      for j=ind
	if of(i)==ot(j) then
	  istreated=%t
	end
      end
      if ~istreated then
	m=[m;fr(i)];
	ot=[ot;of(i)]
	k=[k;i];
      end
    end
  end
endfunction 

function [corinv,cor]=AdjustingCorCorinv(corinv,cor,path,MAT,n_scs_m)
  corinv($+1)=list();
  for i=1:size(MAT,1)
    cor_point=evstr(MAT(i,2))
    n_path=size(path,'*')
    cor_point=cor_point([n_path+1:$]);
    corinv($)(i)=cor_point;
    tt='cor'
    for j=1:size(cor_point,'*')
      tt=tt+'('+string(cor_point(j))+')'
    end
    tt=tt+'='+string(size(corinv));
    execstr(tt);
  end
  corinv($)($+1)=[n_scs_m]  // we will not put it in the cor because this block will be removed from corinv in c_pass1.
  // we just put it here to be compatible with the algorithm of c_pass1.
endfunction

function [m,den,off,count,m1,fir,frequ,offset,ok]=mfrequ_clk(frequ,offset)
// copyright: INRIA
// Anthor: Fady NASSIF
// Date: 2007-2008
// Last Update 15 Dec 2008
  ok=%t;
  m=[];den=[];off=[];count=[];m1=[];fir=[];x=treat_sample_clk;
  // m1 is a vector of different frequencies or same frequencies with different offsets
  [m1,k]=ts_uni(frequ,offset);
  // k is the index.
  frequ=frequ(k);  // delete the dupplicated frequencies.
  offset=offset(k); // delete the dupplicated offset.
  v=[frequ;offset];
  vv=v(find(v<>0));
  min_v=min(vv);max_v=max(vv);
  if (max_v/min_v)>1e5 then 
    message(['The difference between the frequencies is very large';..
	     'the clocks could not be synchronized']);
    ok=%f;
    return; 
  end
  [frd1,den]=GetDenNum(v,max_v,scs_m.props.tol(3));
  ppcm=lcm(frd1(1:size(frequ,'*')));
  frd1=double(frd1);
  if size(frequ,'*')>1 then   // more than one frequency
    mat=[];
    for i=1:size(frequ,'*')
      mat1=[frd1(i+size(frequ,'*')):frd1(i):double(ppcm)]';// for each frequency
      mat=[mat;[mat1 2^(i-1)*ones(size(mat1,'*'),1)]]; // contains the frequency and the corresponding output.
    end
    [n,k]=gsort(mat(:,1),'g','i'); 
    mat=mat(k,:);  // sorting the mat matrix (increasingly).
    // if two outputs are called at the same time they are replaced by an other output; the intersection of the two.
    if size(mat,1)>10000 then
      num=message(['Warning: Your system is too hard to synchronize it will take some time';
		   'Do You want me to continue?'],['No','Yes'])
      if num==1 then 
	ok=%f;
	return
      end
    end 
    vv=mat(2:$,1)-mat(1:$-1,1);
    vv=[1;vv;1];
    kkk=find(vv(:)==0);
    kk=find(vv);
    for i=1:size(kk,2)-1
      mat(kk(i),2)=sum(mat(kk(i):kk(i+1)-1,2));
    end
    mat(kkk(:),:)=[];

    //constructing the first element of opar
    m=[mat(1,1);mat(2:$,1)-mat(1:$-1,1)]; //contains the first element of the chain and the delay.
    last_delay=double(ppcm)-mat($,1)+mat(1,1)  // finding the last delay. 
    // In other world finding the delay between the last element
    // and the first element of mat. So we can have a cycle.
    if last_delay<>0 then   // all the offset are different from 0.
      m($+1)=last_delay  // we add the last delay to m.
      m=[m,[mat(:,2);mat(1,2)],[mat(:,1);double(ppcm)+mat(1,1)]]  // the event output for the last element
      // will be equal to the first one.
      // the time will be the lcm+the delay of the first element
    else     // there is at least one offset that is equal to 0.
      m=[m,mat(:,2),mat(:,1)];  // we don't have to add the last delay because in this case it will be equal to 0.
    end
    count=int32(m(1,1));   // we put the first element of the matrix in a variable that will initialise the counter.
    m(1,:)=[];    // we delete the first row of the matrix. the delay is conserv in the variable count.
    mn=(2**size(m1,'*'))-1;  // find the number of event output.
    fir=-ones(1,mn);  // put all the element of the firing to -1
    fir(mat(1,2))=mat(1,1)*double(den);// programming the corresponding event output
    // by the first element of the matrix mat.(first delay).
    off=0;  // the offset in this case will be equal to 0 because it is implemented in the calculation
    // of the delay.
  else
    // case of one frequency
    m=[frd1(1) 1 frd1(1)];  // put the delay in the matrix. the delay will be equal to the one frequency.
    count=int32(0);   //  the counter will begin by 0.
    mat=m;         
    off=offset;       // the offset is put in the variable off. used by the simulator.
    fir=off;          // program the event output of the block by the corresponding offset.
  end
endfunction

function [N,denom_com]=GetDenNum(v,max_v,dt)
//x=log10(v);
//f=round((min(x)+max(x))/2);
//v=v./10^(f);
//Fady: 15 Dec 2008
  v=v/max_v;
  [N,D]=rat(v,dt);
  denom_com=lcm(uint32(D));
  N=uint32(N)*denom_com./uint32(D);
  denom_com=max_v/double(denom_com);
  //value=gcd(N);
  //if f>0 then value=value*10^f;
  //else denom_com=double(denom_com)*10^(-f);
  //end
  //denom_com=(double(denom_com))/max_v;
endfunction
