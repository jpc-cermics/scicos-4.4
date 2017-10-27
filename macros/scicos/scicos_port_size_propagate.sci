function [scs_m]=scicos_port_size_propagate(scs_m,%cpr)
//
  bp=zeros(0,4);
  for j=1:size(%cpr.state('outtb')) do
    // loop on links 
    sz = size(%cpr.state.outtb(j));
    // 
    N = find(%cpr.sim.outlnk == j);
    for n = N  do 
      // compute (b,p) such that n = outptr(b)+ p-1 
      b = max(find( %cpr.sim.outptr <= n))
      p = n - %cpr.sim.outptr(b) + 1;
      bp.concatd[[b,n,sz]];
    end
    N = find(%cpr.sim.inplnk == j);
    for n = N  do 
      // compute (b,p) such that n = inpptr(b)+ p-1 
      b = max(find( %cpr.sim.inpptr <= n))
      p = n - %cpr.sim.inpptr(b) + 1;
      bp.concatd[[b,n,sz]];
    end
  end
  for j = 1: size(bp,1)
    bpj = bp(j,:);
    [b,p,sz1,sz2]=bpj{:}
    path = %cpr.corinv(b);
    // get obj from path 
    // obj = scs_m(scs_full_path(path));
    // 
    obj = scs_m(scs_full_path(path)); 
    print(obj.model.in);
    obj.model.in(p)=sz1;
    print(obj.model.in);
    obj.model.in2(p)=sz1;
    scs_m(scs_full_path(path))= obj;
  end 
endfunction


