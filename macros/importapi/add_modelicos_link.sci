function [scs_m,obj_num] = add_modelicos_link(scs_m,lfrom,lto,points)
  // This routine is called when modelicos is in use and add_explicit_link is called
  // In that case some blocks have been replaced by their coselica counterpart.
  // And we have to replace explicit links by implicit ones when the two
  // connected blocks are implicit
  // If the two connected blocks are a mix of explicit and implicit we need
  // to add a converter.

  obj_num=length(scs_m.objs)
  
  if nargin<4 || isempty(points) then points=zeros(0,2),end
  
  [from,nok1]=evstr(lfrom)
  [to,nok2]=evstr(lto)
  
  if nok1+nok2>0 then
    obj_num=length(scs_m.objs)
    printf('Warning: Link %s->%s not supported.\n',sci2exp(lfrom,0),sci2exp(lto,0));
    return
  end
  
  o1 = scs_m.objs(from(1))
  [xout,yout,type_out]=getoutputs(o1)
  
  kfrom =from(2)
  if length(xout) < kfrom then 
    printf("output port %d does not exists in block %d\n",kfrom,from(1)),
    return;
  end
  
  type_out=type_out(kfrom);
  
  o2 = scs_m.objs(to(1));
  [xin,yin,type_in] = getinputs(o2)
  
  kto = to(2)
  if length(xin) < kto then 
    printf("inout port %d does not exists in block %d\n",kto,to(1)),
    return;
  end
  type_in = type_in(kto);

  if type_in == type_out then
    // the two ports share the same type we need to generate an implicit link
    [scs_m,obj_num]= add_implicit_link(scs_m,lfrom,lto,points);
  else
    if or(type_out==[1,3]) then
      //printf("The output port is regular. must add a CBI_RealInput converter\n");
      modelica_insize= o2.model.in(to(2));
      if %f &&  modelica_insize == 1  then 
	blk = instantiate_block ('CBI_RealInput');
      else
	blk=  add_scicos_to_modelicos(modelica_insize);
	blk.graphics.sz=[20,20];
      end
      blk = set_block_origin (blk,o1.graphics.orig+[o1.graphics.sz(1),0]+[40,0]);
      // blk = set_block_size(blk,[20,20]);
      obj_num = obj_num+1;
      scs_m.objs(obj_num) = blk;
      [scs_m,obj_num_t]=add_implicit_link(scs_m,string([obj_num,1]),lto);
      [scs_m,obj_num]=add_implicit_link(scs_m,lfrom,string([obj_num,1]));
    end
    if or(type_in==[1,3]) then
      // printf("The input port is regular. must add a CBI_RealOutput converter\n"),
      modelica_outsize= o1.model.out(from(2));
      if %f && modelica_outsize == 1 then 
	blk = instantiate_block ('CBI_RealOutput');
      else
	blk=  add_modelicos_to_scicos( modelica_outsize);
	blk.graphics.sz=[20,20];
      end
      blk = set_block_origin (blk,o2.graphics.orig-[40,0]);
      // blk = set_block_size(blk,[20,20]);
      obj_num = obj_num+1;
      scs_m.objs(obj_num) = blk;
      [scs_m,obj_num_t]=add_implicit_link(scs_m,string([obj_num,1]),lto);
      [scs_m,obj_num]=add_implicit_link(scs_m,lfrom,string([obj_num,1]));
    end
  end
endfunction
