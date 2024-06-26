function [model, graphics, ok]=set_io(model, graphics,...
				      in#, out#,...
				      clkin, clkout,...
				      in_implicit, out_implicit,..
				      in_bus, out_bus)
  // Copyright INRIA
  // Upgrade model and graphics according to new values of parameters
  // trying to preserve existing links

  if nargin <= 6 then
    in_implicit=[]
    out_implicit=[],
  end
  if nargin <=8 then
    in_bus=[]
    out_bus=[],
  end
  
  function [str__err]=str__err(err__,str__#)
    str__err="ERROR"
    select err__
     case 1 then
      str__err=str__# + "put port must be alist"
     case 2 then
      str__err=str__# + "put list must have a size of 2"
     case 3 then
      str__err="First entry of "+ str__#+ ...
	       "put list must  be double or integer"
     case 4 then
      str__err="Second entry of " + str__# + ...
	       "put list must  be double or integer"
     case 10 then
      str__err=str__# + ...
	       "put port sizes must have a dimension of nx2"
     case 11 then
      str__err=str__# + "put port sizes and " +  str__#+...
	       "put port type must have the same number of rows"
     case 100 then
      str__err=str__# + ...
	       "put port type must be <=9"
    end
  endfunction
  	
  function [var,vart,ierr,ko]=extract__(var#)
    ko=%f
    ierr=0
    var=[]
    vart=1
    if type(var#,'short')<>'l' then
      ierr=1,
      resume, 
    end
    if ~isempty(var#) then
      if length(var#)<>2 then
	ierr=2,
	resume, 
      end
      for i=1:2
	if ~(type(var#(i),'short')=='m' | type(var#(i),'short')=='i') then
	  ierr=2+i,
	  resume, 
	end
      end
      if ~isempty(var#(1)) then
	if size(var#(1),2)<>2 then
	  ierr=10,
	  resume, 
	end
	if size(var#(1),1)<> size(var#(2)(:),1) then
	  ierr=11,
	  resume, 
	end
	if max(var#(2))>9 then
	  ierr=100,
	  resume, 
	end
	var=int(var#(1))
	vart=int(var#(2)(:))
      end
    end
    ko=%t;
  endfunction
  
  [in, in_t, err__, ko]=extract__(in#)
  if ~ko then
    message('set_io : '+  str__err(err__,'in'));
    ok=%f
    return, 
  end
  
  [out,out_t, err__, ko]=extract__(out#)
  if ~ko then
    message('set_io : '+  str__err(err__,'out'))
    ok=%f
    return, 
  end
  clkin=int(clkin(:))
  nclkin=size(clkin,1)
  if nclkin>0 then
    if min(clkin)<1 then
      message('set_io : '+...
	      'Event input ports sizes must be positive')
      ok=%f
      return, 
    end
  end
  clkout=int(clkout(:))
  nclkout=size(clkout,1)
  if nclkout>0 then
    if min(clkout)<1 then
      message('set_io : '+...
	      'Event output ports sizes must be positive')
      ok=%f
      return, 
    end
  end
  // set_io first check if given numbe
  // of ports agree with block connection
  [label,...
   ip1,...
   op1,...
   cip1,...
   cop1]=(graphics.exprs,...
	  graphics.pin,...
	  graphics.pout,...
	  graphics.pein,...
	  graphics.peout)
  [in1,...
   in2,...
   intyp,...
   out1,...
   out2,...
   outtyp,...
   clkin1,...
   clkout1]=(model.in,...
	     model.in2,...
	     model.intyp,...
	     model.out,...
	     model.out2,...
	     model.outtyp,...
	     model.evtin,...
	     model.evtout)

  n1=size(in1,1) //current number of input port of model
  n=size(in,1) //given number of input port
  if n1>n then
    //    if or(ip1(n+1:$)>0) then
    //      message('set_io : '+...
    //               'Connected ports cannot be suppressed')
    //       ok=%f
    //        return, end
    ip1=ip1(1:n)
  else
    ip1=[ip1(:);zeros(n-n1,1)]
  end
  n1=size(out1,1);// size(:,1),'*')
  n=size(out,1)// size(:,1),'*')
  if n1>n then
    //    if or(op1(n+1:$)>0) then
    //      message('set_io : '+...
    //               'Connected ports cannot be suppressed')
    //       ok=%f
    //        return, end
    op1=op1(1:n)
  else
    op1=[op1(:);zeros(n-n1,1)]
  end

  n1=size(clkin1,'*')
  n=size(clkin,'*')
  if n1>n then
    //    if or(cip1(n+1:$)>0) then
    //      message('set_io : '+...
    //               'Connected ports cannot be suppressed')
    //       ok=%f
    //        return, end
    cip1=cip1(1:n,:)
  else
    cip1=[cip1(:);zeros(n-n1,1)]
  end
  n1=size(clkout1,'*')
  n=size(clkout,'*')
  if n1>n then
    //    if or(cop1(n+1:$)>0) then
    //      message('set_io : '+...
    //               'Connected ports cannot be suppressed')
    //       ok=%f
    //        return, end
    cop1=cop1(1:n,:)
  else
    cop1=[cop1(:);zeros(n-n1,1)]
  end

  I='E'

  if ~isempty(ip1) then
    in_impl=I(ones(size(ip1)))
    in_impl(in_implicit)='I'
    in_impl(in_bus)='B'
    //    kk=size(graphics.in_implicit,'*')
    //     k=find(ip1<>0) //connected links
    //      k=k(find(k<=kk))
    //    if or(graphics.in_implicit(k)<>in_impl(k)) then
    //      message('set_io : '+...
    //               'Connected ports types cannot be changed')
    //       ok=%f
    //        return, end
  else
    in_impl=[]
  end
  if ~isempty(op1) then
    out_impl=I(ones(size(op1)))
    out_impl(out_implicit)='I'
    out_impl(out_bus)='B'
    //    kk=size(graphics.out_implicit,'*')
    //     k=find(op1<>0) //connected links
    //      k=k(find(k<=kk))
    //    if or(graphics.out_implicit(k)<>out_impl(k)) then
    //      message('set_io : '+...
    //               'Connected ports types cannot be changed')
    //       ok=%f
    //        return, end
  else
    out_impl=[]
  end

  // SET
  ok=%t
  graphics.pin=ip1
  graphics.pout=op1
  graphics.pein=cip1
  graphics.peout=cop1
  if type(in_impl,'short')== 'm' then in_impl=m2s(in_impl);end
  graphics.in_implicit=in_impl
  if type(out_impl,'short')== 'm' then out_impl=m2s(out_impl);end
  graphics.out_implicit=out_impl
  if isempty(in) then  in = zeros(0,2);end 
  model.in=in(:,1)
  model.in2=in(:,2)
  model.intyp=in_t
  if isempty(out) then  out = zeros(0,2);end 
  model.out=out(:,1)
  model.out2=out(:,2)
  model.outtyp=out_t
  model.evtin=clkin
  model.evtout=clkout
endfunction

