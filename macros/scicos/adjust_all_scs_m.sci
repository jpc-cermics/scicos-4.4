function all_scs_m=adjust_all_scs_m(scs_m_temporary,k)
// Copyright INRIA
// 
  all_scs_m=scs_m_temporary
  
// overload some functions used
// in modelica block compilation
// disable it for adjust_all_scs_m
  
  function [ok]= buildnewblock(blknam,files,filestan,filesint,libs,rpat, ...
			       ldflags,cflags)
    ok=%t;
  endfunction
  
  // redefine printf ? 
  // XXXX deff('[]   =  mprintf(v1,v2,v3,v4,v5,v6)','return')
  
  [bllst,connectmat,clkconnect,cor,corinv,ok]=c_pass1(scs_m_temporary);
  
  if ~ok then
    message('The pre-compilation has failed; the scs_m will not be adjusted');
    ok=%f;
  end
  
  if ok then
   [ok,bllst]=adjust_inout(bllst,connectmat);
  end

  if ok then
    [ok,bllst]=adjust_typ(bllst,connectmat);
  end

  if ok then
    for i=1:size(corinv)
      //## the value in corinv for m_freq (smplclk)
      //## is the number of objs in scs_m + 1.

      //## disable adjust for smplclk and modelica block
      if  type(corinv(i),'short')== 'l'  then
        break;
      elseif corinv(i) > size(cor) then
        break
      end

      //## corinvtemp is the scs_m.objs index(ices)
      //## of the block(sblock) bllst(i)
      corinvtemp=corinv(i)

      //## scs_m_temporary is the full scs_m
      if corinvtemp(1)==k then
        scs_m_temporary=adjust_scs_m_temp(scs_m_temporary,corinvtemp,i)
      end
    end
  end
  //##return adjusted full scs_m
  all_scs_m=scs_m_temporary
endfunction


//## adjust scs_m.objs.model with bllst
function scs_m_temporary=adjust_scs_m_temp(scs_m_temporary,corinvtemp,ind)

  //## test if we are in a sblock
  corinvtemp1=corinvtemp(1);
  corinvtemp(1)=[];
  if size(corinvtemp,'*')>0 then
   scs_m_temporary1=adjust_scs_m_temp(scs_m_temporary.objs(corinvtemp1).model.rpar,corinvtemp,ind);

   //## adjust models of blocks in sblock
   scs_m_temporary.objs(corinvtemp1).model.rpar=scs_m_temporary1;

  //## test if it's a block
  else
    scs_m_temporary.objs(corinvtemp1).model=bllst(ind);
  end
endfunction
