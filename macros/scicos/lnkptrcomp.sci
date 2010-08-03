function lnkptr=lnkptrcomp(bllst,inpptr,outptr,inplnk,outlnk)
// Copyright INRIA
  lnkbsz=[]
  for blkout=1:length(bllst)
    for portout=1:outptr(blkout+1)-outptr(blkout)
      ii= outlnk(outptr(blkout)+portout-1);
      val=bllst(blkout).out(portout);
      if  ii > length(lnkbsz) && isempty(val) then 
	// ignore a remove out of range
      else
	lnkbsz(outlnk(outptr(blkout)+portout-1))=bllst(blkout).out(portout)
      end	
    end
  end
  lnkptr=cumsum([1;lnkbsz(:)])
endfunction
