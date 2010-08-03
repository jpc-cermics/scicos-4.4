function graphics=scicos_graphics(orig=[0 0], sz=[20 20], flip=%t,  exprs=[],
  pin=[], pout=[], pein=[], peout=[], gr_i=[], id='',in_implicit=[],out_implicit=[] )  
  if isempty(in_implicit) then 
    I='E';
    in_implicit=I(ones(size(pin(:))));
  end
  if isempty(out_implicit) then 
    I='E';
    out_implicit=I(ones(size(pout(:))));
  end
  graphics=tlist(['graphics','orig','sz','flip','exprs','pin',...
		  'pout','pein','peout','gr_i','id','in_implicit','out_implicit'],...
		 orig,sz,flip,exprs,pin,pout,pein,peout,gr_i,id,in_implicit,out_implicit)
endfunction
