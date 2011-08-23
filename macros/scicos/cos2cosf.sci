function txt=cos2cosf(scs_m,count)
// write in txt a set of instructions whose evaluation 
// should recreate a scicos data structure like scs_m.
// 
// Note that nsp printf with as_read=%t should provide the 
// same result in an easier way.
// The advantage of using cos2cosf comes from the fact that 
// at re-execution the diagram is updated if some function 
// in scicos have changed. 
  
  function t=catinstr(t,t1,n)
    sep=','
    dots='.'+'.';
    if size(t1,'*')==1&(lmax==0|max(length(t1))+length(t($))<lmax) then
      t($)=t($)+sep+t1
    else
      t($)=t($)+sep+dots
      bl1=' ';bl1=part(bl1,1:n)
      t=[t;bl1(ones_new(size(t1,1),1))+t1]
    end
  endfunction
  
  txt=m2s([]);
  if nargin < 3 then 
    count=0,
    lname='scs_m'
  else
    count=count+1
    lname='scs_m_'+string(count)
  end
  bl=''
  lmax=80;
  t=lname+'=scicos_diagram()'
  t1=sci2exp(scs_m.props,lmax);
  t=[t;lname+'.props='+t1(1);t1(2:$)]
  txt.concatd[t];
  pause xxx
  
  for k=1:length(scs_m.objs)
    
    o=scs_m.objs(k)
    if o.type =='Block' then
      lhs=lname+'.objs('+string(k)+')='
      bl1=' ';bl1=part(bl1,1:length(lhs))
      if o.model.sim(1)=='super'| o.model.sim(1)=='csuper' then  //Super blocks
	
	//generate code for model.rpar
	t=cos2cosf(u,o.model.rpar,count);//model.rpar
	txt.concatd[t];
	//open a block
	tt= lname+'.objs('+string(k)+')=mlist('
	//add the type field
	tt=[tt;
	    bl1+sci2exp(getfield(1,o),lmax-count*2)]
	//add graphics code
	tt=catinstr(tt,sci2exp(o.graphics,lmax-count*2),length(lhs))
	//open the model data structure and write code for type 
	tt=catinstr(tt,'mlist(',length(lhs))
	//add the type field
	fn=getfield(1,o.model)
	tt=[tt;bl1+sci2exp(fn,lmax-count*2)]
	for k=2:size(fn,'*')
	  if fn(k)<>'rpar' then
	    tt=catinstr(tt,sci2exp(o.model(fn(k)),lmax-count*2),length(lhs))
	  else
	    //introduce model.rpar generated above
	    tt=catinstr(tt,'scs_m_'+string(count+1),0) 
	  end
	end
	tt($)=tt($)+')' // close model list
	//generate code for last  entries of block
	fn=getfield(1,o)
	for k=4:size(fn,'*')
	  tt=catinstr(tt,sci2exp(o(fn(k)),lmax-count*2),length(lhs))
	end
	tt($)=tt($)+')' // close block list
	txt.concatd[tt];tt=[];
      else
	t1=sci2exp(o,lmax-length(lhs))
	t=[t;lhs+t1(1);bl1(ones_new(size(t1,1)-1,1))+t1(2:$)]
	txt.concatd[t];t=[];
      end
    else //regular blocks
      lhs=lname+'.objs('+string(k)+')='
      t1=sci2exp(o,lmax-length(lhs))
      n1=size(t1,1)
      bl1=' ';bl1=part(bl1,1:length(lhs))
      t=[t;lhs+t1(1);bl1(ones_new(n1-1,1))+t1(2:$)]
      txt.concatd[t];t=[]
    end
  end
endfunction


  
