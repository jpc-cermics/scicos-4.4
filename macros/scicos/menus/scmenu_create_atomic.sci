function scmenu_create_atomic()
// Copyright INRIA
  
  if alreadyran then
    // make a do_terminate and restart Create Atomic 
    Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
		     '[alreadyran,%cpr]=do_terminate();%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1';
		     'Select='+sci2exp(Select)+';Cmenu='"Create Atomic'"']
    return
  end
  Cmenu="";%pt=[];
  if size(Select,1)<>1 | curwin<>Select(1,2) then
    return
  end
  i=Select(1)
  o=scs_m.objs(i)
  if o.type =='Block' && o.model.sim=='super' then
    if size(o.model.evtin,'*')>1 then
      message('Atomic Subsystem cannot have more than one activation port');
      return;
    end
    [o,needcompile,ok]=do_create_atomic(o,i,scs_m)
    if ~ok then return ;end
    scs_m = update_redraw_obj(scs_m,list('objs',i),o)
  else
    message('Create Atomic can only be applied to unmasked Super Blocks.');
  end
endfunction

function [o,needcompile,ok]=do_create_atomic(o,k,scs_m)
// Replace o by an atomic block.
// Last Update Fady: 15 Dec 2008

  function o=RedrawIteratorSB(o,iter_op)
    o.graphics.sz(1)=60;
    o.graphics.gr_i=list(['xstringb(orig(1),orig(2),[''    '+iter_op+''';''SubSystem''],sz(1),sz(2),''fill'')'],8);
  endfunction

  
  ok=%t
  model=o.model
  graphics=o.graphics;
  needcompile=4;
  XX = o;
  [ok,params,param_types]=FindSBParams(model.rpar,[])
  if ~ok then return;end
  if ~isempty(params) then
    message('The parameter ""'+params+'"" must be defined in the context of the atomic super block.')
    return;
  end
  ALL=%f;
  xx=scmenu_code_generation;
  ok=execstr('[ok, XX, gui_path,flgcdgen, szclkINTemp, freof,c_atomic_code,cpr] ='+ ...
	       'do_compile_superblock42(scs_m, k, %t);',errcatch=%t);
  if ~ok then
    message(lasterror());
    return; 
  end
  
  if ~isempty(freof) then 
    message('Create Atomic: an Atomic Superblock cannot contain sample clocks');
    ok=%f
    return
  elseif XX.model.dep_ut($)==%t && ~isempty(XX.model.evtin)  then
    message('Create Atomic: a triggered Atomic Subsystem cannot contain blocks with continuous time');
    ok=%f
    return 
  end
  [ok,for_iterator_flag,init_output,nbre_iter,step,ss_input_nbre,iter_var_datatype,obj_nbre,exist_output,startingstate,iter_op]=treatforiterator(model.rpar)
  if ~ok then return;end
  //**quick fix for sblock that contains scope
  
  funtyp=2004
  ind=find(cpr.sim.funtyp==10004 || cpr.sim.funtyp==12004)
  if ~isempty(ind) then
    funtyp=12004
    for i=ind'
      modelicafunname=cpr.sim.funs(i)
      [a,b]=c_link(modelicafunname)
      while a do
	ulink(b)
	[a,b]=c_link(modelicafunname)
      end
    end
  end
  o.model.sim=list('asuper',funtyp);
  o.model.in=XX.model.in
  o.model.in2=XX.model.in2
  o.model.out=XX.model.out
  o.model.out2=XX.model.out2
  o.model.intyp=XX.model.intyp
  o.model.outtyp=XX.model.outtyp
  XX.model.sim(2)=funtyp;
  //c_atomic_code=strsubst(c_atomic_code,'scicos_block.h','scicos.h')
  o.graphics.exprs=list(XX.graphics.exprs,c_atomic_code,XX.model);

  [a,b]=c_link(XX.model.sim(1))
  while a do
    ulink(b)
    [a,b]=c_link(XX.model.sim(1))
  end
  if for_iterator_flag then
    o=RedrawIteratorSB(o,iter_op);
    if startingstate then
      // concatenation of the initial states
      if size(XX.model.dstate,'*')<>0 then 
	XX.model.dstate($+1:$+size(XX.model.dstate,'*'))=XX.model.dstate;end
      if size(XX.model.state,'*')<>0 then 
	XX.model.state($+1:$+size(XX.model.dstate,'*'))=XX.model.state;end
      if lstsize(XX.model.odstate)<>0 then 
	XX.model.odstate=lstcat(XX.model.odstate,XX.model.odstate);end
    end
    code=generate_iter_ccode(XX.model.sim(1),init_output,nbre_iter,step,iter_var_datatype,ss_input_nbre,model,obj_nbre,exist_output,startingstate,XX.model,iter_op,cpr)
    old_funam=XX.model.sim(1);
    XX.model.sim(1)='iter_'+XX.model.sim(1)
    o.graphics.exprs=list(XX.graphics.exprs,[code;c_atomic_code],XX.model);
    [a,b]=c_link(XX.model.sim(1))
    while a do
      ulink(b)
      [a,b]=c_link(XX.model.sim(1))
    end
  end
endfunction

function code=generate_iter_ccode(funname,init_output,nbre_iter,step,iter_var_datatype,ss_input_nbre,model,obj_nbre,exist_output,startingstate,XXmdl,iter_op,cpr)
//Fady 15 Dec 2008

  function scs_m=changeinout(scs_m)
    port_blocks=['IN_f','INIMPL_f','OUT_f','OUTIMPL_f','CLKIN_f','CLKINV_f','CLKOUT_f','CLKOUTV_f']
    for i=1:lstsize(scs_m.objs)
      o=scs_m.objs(i)
      if typeof(o)=='Block' then
	if or(o.gui==port_blocks) then
	  o.gui='BIDON'
	end
      end
      scs_m.objs(i)=o;
    end
  endfunction
  
  if iter_op=='for' then
    funnam='foriterator'
  else
    funnam='whileiterator'
  end
  iter_pos=findinlistcmd(cpr.sim.funs,funnam,'=')
  noz=cpr.sim.ozptr(iter_pos(1)+1)-1
  blk_nbre=cpr.cor(obj_nbre)-1
  vvv=['Real','','int32','int16','int8'];
  vv=['double','','long','short','char'];
  //*****************Start of code************************************
  Date=gdate_new();
  str= Date.strftime["%d %B %Y"];
  code=['/* This Code is Generated Automatically for the iterator block '
	' * Date: '+str
	''
	'#include <scicos/blockdef.h>'
	'#include <string.h>'
	''
	'void '+funname+'(scicos_block *,int );'
	''
	'void iter_'+funname+'(scicos_block *block, int flag)'
	' {'];
  //*********************Declarations***************************************
  code=[code;
	'  '+vv(iter_var_datatype)+' counter,nbre_iteration,cond;'
	'  '+vv(iter_var_datatype)+' *internalcounter;'];

  if startingstate then
    code=[code;
	  '  int soz,i;'];
  end
  //*********************Number of iterations********************************
  if nbre_iter>=0 then  // the number of iteration is a block parameter
    code=[code;
	  '  nbre_iteration='+sci2exp(nbre_iter)+';']
    stepentry='0'; // is used later when the set next i is an input port.
  elseif nbre_iter==-1 then  // the number of iteration is unlimitted
    code=[code;
	  '  nbre_iteration=2;']
    stepentry='0';
  else  // the number of iteration is an input
    stepentry='1';
    code=[code;
	  '  nbre_iteration=*Get'+vvv(iter_var_datatype)+'InPortPtrs(block,'+sci2exp(ss_input_nbre)+');']
  end
  //*****************Updating the counter***************************************
  if step==1 then  // when set next i is not selected
    if nbre_iter==-1 then
      code1='      counter=counter+0;'
    else
      code1='      counter=counter+'+sci2exp(step)+';'
    end
  else  //set next i is an input 
    blk_nbre=cor(obj_nbre)-1;  // the ForIterator block
    // to get the input of the block for iterator. all the information on the blocks inside the block generated are in the work of the block.
    code1='      counter=*(('+vv(iter_var_datatype)+' *) ((((scicos_block *) *block->work)['+sci2exp(blk_nbre)+']).inptr['+stepentry+']));'
  end
  //****************************Initial and updated condition ******************
  if iter_op=='for' then
    code3=['    cond=1;'];
    code2=[];
  elseif iter_op=='do while' then
    code3=['    cond=1;'];
    code2=['    cond=*(('+vv(iter_var_datatype)+' *) ((((scicos_block *) *block->work)['+sci2exp(blk_nbre)+']).inptr[0]));']; 
  else
    code3=['    cond=*(('+vv(iter_var_datatype)+' *) ((((scicos_block *) *block->work)['+sci2exp(blk_nbre)+']).inptr[1]));'];
    code2=['    cond=*(('+vv(iter_var_datatype)+' *) ((((scicos_block *) *block->work)['+sci2exp(blk_nbre)+']).inptr[0]));'];
  end
  //****************************************************************************
  code=[code;
	'  if ((flag!=1)&&(flag!=2)){']  // case of flag <>1

  //***************************** Case with output******************************
  if exist_output then  // when the block ForIterator has an output. 
    code=[code;
	  '    if (flag==4){';
	  '      '+funname+'(block, flag);'; // calling the block with flag 4.
	  '       internalcounter=('+vv(iter_var_datatype)+'*) GetOzPtrs(block,'+sci2exp(noz)+');';
	  '       *internalcounter='+sci2exp(init_output)+';';
	  '    } else if (flag==5) {';
	  '        '+funname+'(block, flag);';
	  '    } else {';
	  '        '+funname+'(block, flag);}']
    code=[code;
	  '  } else if ((flag==1)) {'] // case flag==1;
    //****************************Case reset states ************************************
    if startingstate then
      code=[code;
	    '    '+funname+'(block, 5);']
      if size(XXmdl.dstate,'*')<>0 then
	code=[code;
	      '    memcpy(block->z,block->z+GetNdstate(block)/2,GetNdstate(block)/2*sizeof(double));']
      end
      if size(XXmdl.state,'*')<>0 then
	code=[code;
	      '    memcpy(block->x,block->x+GetNstate(block)/2,GetNstate(block)/2*sizeof(double));']
      end
      if lstsize(XXmdl.odstate)<>0 then
	code=[code;
	      '    for (i=0;i<GetNoz(block)/2;i++) {'
	      '      soz=(GetOzSize(block,i+1,1)*GetOzSize(block,i+1,2)*GetSizeOfOz(block,i+1));'
	      '      memcpy(*(block->ozptr+i),*(block->ozptr+(GetNoz(block)/2)+i),soz);}']
      end
      code=[code;     
	    '    '+funname+'(block, 4);']
      
      //******************************Initialize the reentryflag see CodeGeneration_ ******* 
      nblk=cpr.sim.nb;
      code=[code;'*((int*) ((scicos_block *)(*block->work)+'+string(nblk)+'))=0;']
      //************************************************************************************
    end
    //************************************************************************************
    code=[code;
	  '    internalcounter=('+vv(iter_var_datatype)+' *) GetOzPtrs(block,'+sci2exp(noz)+');';  // get the initial value of the counter.
	  '    counter=*internalcounter;';
	  code3;
	  '   /* nbre_iteration is get from the foriterator block inside this subsystem */';
	  '    while ((counter<nbre_iteration+'+sci2exp(init_output)+')&&(cond)) {';
	  '      '+funname+'(block, 1);'; // calling the block with flag 1
	  '      '+funname+'(block, 2);';	// calling the block with flag 2
	  '      /* step is get from the foriterator block inside this subsystem */'] 
    code=[code;code1]  // calculating the step value.
    code=[code;code2;
	  '}']
    //************************** Case without output*************************************  
  else // the ForIterator block has no output it is only done to have an optimized code.
    code=[code;
	  '    '+funname+'(block, flag);']
    code=[code;
	  '  } else if (flag==1) {']
    //****************************Case reset states ************************************
    if startingstate then
      code=[code;
	    '    '+funname+'(block, 5);']
      if size(XXmdl.dstate,'*')<>0 then
	code=[code;
	      '    memcpy(block->z,block->z+GetNdstate(block)/2,GetNdstate(block)/2*sizeof(double));']
      end
      if size(XXmdl.state,'*')<>0 then
	code=[code;
	      '    memcpy(block->x,block->x+GetNstate(block)/2,GetNstate(block)/2*sizeof(double));']
      end
      if lstsize(XXmdl.odstate)<>0 then
	code=[code;
	      '    for (i=0;i<GetNoz(block)/2;i++) {'
	      '      soz=(GetOzSize(block,i+1,1)*GetOzSize(block,i+1,2)*GetSizeOfOz(block,i+1));'
	      '      memcpy(*(block->ozptr+i),*(block->ozptr+(GetNoz(block)/2)+i),soz);}']
      end
      code=[code;     
	    '    '+funname+'(block, 4);']
      
      //******************************Initialize the reentryflag see CodeGeneration_ ******* 
      nblk=cpr.sim.nb;
      code=[code;'*((int*) ((scicos_block *)(*block->work)+'+string(nblk)+'))=0;']
      //************************************************************************************
    end
    //************************************************************************************
    code=[code;
	  '  counter='+sci2exp(init_output)+';';
	  code3;
	  ' /* nbre_iteration is get from the foriterator block inside this subsystem */';
	  '    while ((counter<nbre_iteration+'+sci2exp(init_output)+')&&(cond)) {';
	  '     '+funname+'(block, 1);';
	  '     '+funname+'(block, 2);';
	  '     /* step is get from the foriterator block inside this subsystem */']
    
    code=[code;
	  code1;
	  code2;
	  ' }']
    
  end
  //*******************************Initialize the counter ******************************
  if exist_output then
    code=[code;
	  '    *('+vv(iter_var_datatype)+' *) GetOzPtrs(block,'+sci2exp(noz)+')='+sci2exp(init_output)+';'
	  '    *(('+vv(iter_var_datatype)+' *) ((((scicos_block *) *block->work)['+sci2exp(blk_nbre)+']).ozptr[0]))='+sci2exp(init_output)+';']
  end
  //*******************************End of code *****************************************
  code=[code;
	' }'
	'  return;'
	'}']
endfunction

