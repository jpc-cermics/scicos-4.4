function codegen_main_p()
// generate code usingthe p code generator 
// 
  D=gdate_create();
  DateCode= D.strftime["%Y%m%d"];

  FunName=file('join',[TMPDIR,'test'+DateCode]);
  [txt,ins,outs]=codegen_p(scs_m,cpr,FunName+'.c');
  file('delete', FunName+'.sci');
  scicos_mputl(txt, FunName+'.sci');
  // convert the code to insert numerics 
  //ast=parse_file(FunName+'.sci');
  //ast1=ast_bvar(ast);
  //txt1=ast1.sprint[];
  //file('delete', FunName+'.sci');
  //scicos_mputl(txt1, FunName+'.sci');  
  // now evaluate the code 
  global("code","declarations","_i","_defs");
  _i=0;
  code=list();
  declarations=list();
  ok = execstr(txt,errcatch=%t);
  if ~ok then pause codegen_main_p1;end 
  // XXXXX suite du debug ici 
    
  funlist=fun_sat_defs( )
  txt_defs=[];
  for fun=_defs'
    txt_defs=[txt_defs;funlist(fun)]
  end
  
  clearglobal("code","declarations","_i","_defs")
  
  ///////////////////////////////////////////////////////////
  txtc = read(FunName+'.c',-1,1,'(a)')  
  Cblock_txt=["#include <scicos/scicos_block4.h>";
	      "#include '"../machine.h'"";
	      "#include <stdint.h>";
	      "";
	      txt_defs;
	      "";
	      txtc;
	      ""]
  Cblock_txt($+1)="void toto"+DateCode+"(scicos_block *block,int flag) {"
  ios=[];insizes=[];intypes=[];
  for i=1:length(ins)
    dt=datatype(ins(i));
    intype=get_scicostype(dt)
    if dt=="double" then dt="Real";end
    decldt="(Get"+dt+"InPortPtrs(block,"+string(i)+"))"
    //    if prod(size(ins(i)))>1 then
    ios=[ios,decldt]
    //    else
    //       ios=[ios,"*"+decldt]
    //    end
    insizes=[insizes;size(ins(i))]
    intypes=[intypes;intype]
  end
  outsizes=[];outtypes=[];
  for i=1:length(outs)
    dt=datatype(outs(i));
    outtype=get_scicostype(dt)
    if dt=="double" then dt="Real";end
    decldt="(Get"+dt+"OutPortPtrs(block,"+string(i)+"))"
    ios=[ios,decldt]
    outsizes=[outsizes;size(outs(i))]
    outtypes=[outtypes;outtype]
  end

  Cblock_txt($+1)="  if (flag == 1) {"
  Cblock_txt($+1)="   updateOutput1("+strcat(ios,',')+");"
  Cblock_txt($+1)="  }"
  Cblock_txt($+1)="  if (flag == 2) {"
  Cblock_txt($+1)="   updateState1("+strcat(ios,',')+");"
  Cblock_txt($+1)="  }"
  Cblock_txt($+1)="}"

  XX   = CBLOCK4('define')
  XX.graphics.sz = 20 *XX.graphics.sz
  //@@ set the graphics exprs
  XX.graphics.exprs(1)(1)  = 'toto'+DateCode     //simulation function
  XX.graphics.exprs(1)(3)  = sci2exp(insizes,0)  //regular input port size
  XX.graphics.exprs(1)(4)  = sci2exp(intypes,0)  //regular input port type
  XX.graphics.exprs(1)(5)  = sci2exp(outsizes,0) //regular output port size
  XX.graphics.exprs(1)(6)  = sci2exp(outtypes,0) //regular output port type
  XX.graphics.exprs(1)(7)  = '1'                   //event input port size
  XX.graphics.exprs(1)(8)  = '[]'                   //event output port size
  XX.graphics.exprs(1)(9)  = '[]'          //continuous state
  XX.graphics.exprs(1)(10) = '0'          //discrete state (to force call with flag 2)
  XX.graphics.exprs(1)(18) = 'y'                   //direct feedthrough
  XX.graphics.exprs(2)=Cblock_txt

  //@@ run 'set' job of the CBLOCK4
  prot=funcprot()
  funcprot(0)
  getvalue=setvalue;
  deff('message(txt)','x_message(''In block ''+XX.gui+'': ''+txt);global %scicos_prob;%scicos_prob=%t')
  deff('[ok,tt,cancel,libss,cflags] = CC4(funam,tt,i,o,libss,cflags)','ok=%t,cancel=%f')
  %scicos_prob = %f
  XX = CBLOCK4('set',XX)

  [a,b]=c_link('toto');
  while a
    ulink(b);
    [a,b]=c_link('toto');
  end
  return
endfunction 

function [txt,ins,outs]=codegen_p(scs_m,cpr,fname)
// code generation for p project 
// 
  function str=nsp2bvarexp(exp,tag)
    str= sci2exp(exp,tag);
    str= sprintf('numerics(%s)',str);
  endfunction
    
  function txtfuns= gencode_for_event(Ev,cpr,txtfuns)
    for i=cpr.sim.ordptr(Ev):cpr.sim.ordptr(Ev+1)-1
      blk=cpr.sim.ordclk(i,1)
      if cpr.sim.funtyp(blk)<0 then
        for Evj=cpr.sim.clkptr(blk):cpr.sim.clkptr(blk+1)-1
	  txtfuns= gencode_for_event(Evj,cpr,txtfuns)
        end
      end
    end
    txtfuns=[txtfuns;gen_outputupdate(m2s([]),Ev)]
    txtfuns=[txtfuns;gen_stateupdate(m2s([]),Ev)]
  endfunction
  
  function txt=gen_outputupdate(txt,Ev)
    txt($+1,1)=""
    txt($+1,1)="StartFunction('"updateOutput"+string(Ev)+"'",_io)"
    valids=_params.defined[];// in out blocks have no params 
    for i=cpr.sim.ordptr(Ev):cpr.sim.ordptr(Ev+1)-1
      blk=cpr.sim.ordclk(i,1);nevprt=cpr.sim.ordclk(i,2);
      if or(blk==valids) then
	if cpr.sim.funtyp(blk)==-1 then
	  EvThen=cpr.sim.clkptr(blk)
	  EvElse=cpr.sim.clkptr(blk)+1
	  ki=cpr.sim.inpptr(blk)
	  kin=cpr.sim.inplnk(ki)
	  kkout=find(kin==outtbout(:,1))
	  kkin=find(kin==outtbin(:,1))
	  if ~isempty(kkin) then
            input_if="_io.inouts"+string(outtbin(kkin,2))
	  elseif ~isempty(kkout) then
            input_if="_io.inouts"+string(outtbout(kkout,2)+nin)
	  else
            input_if="persistent_extract(_links,''link"+string(kin)+"'')";
	  end
	  txt($+1,1)="if_cos("+input_if+",CallFunction('"updateOutput"+string(EvThen)+"'",_io),CallFunction('"updateOutput"+string(EvElse)+"'",_io))"

	elseif cpr.sim.funtyp(blk)==-2 then
	  error("Iselect block not implemented yet")
	else
	  txt($+1,1)="block=hash(10)"
	  txt($+1,1)="params=hash(10)";
	  blkparams=_params(blk)
	  j=1;
	  for par=blkparams
            txt($+1,1)="params.p"+string(j)+"="+nsp2bvarexp(blkparams(j),0)+";";
            j=j+1
	  end
	  txt($+1,1)="block.params=params"

	  txt=set_block_io_text(cpr,blk,outtbout,outtbin,txt)
	  txt($+1,1)="block.io=blkio"
	  txt($+1,1)="bstate=list()"
	  txt($+1,1)="for i=1:length(stateptr("+string(blk)+"))"    
	  txt($+1,1)="  bstate(i)=persistent_extract(_states,stateptr("+string(blk)+")(i));"
	  txt($+1,1)="end"
	  txt($+1,1)="block.state=bstate;"
	  txt($+1,1)="block.nevprt="+string(nevprt)
	  txt($+1,1)="block=P_"+scs_m.objs(cpr.corinv(blk)).gui+"(block,numerics(1))"

	  txt=set_block_io_text_out(cpr,blk,outtbout,outtbin,txt)

        end
      end
    end
    txt($+1,1)="EndFunction()"
  endfunction

  function txt=gen_stateupdate(txt,Ev)
    txt($+1,1)=""
    txt($+1,1)="StartFunction('"updateState"+string(Ev)+"'",_io)"
    valids=_params.defined[];
    for i=cpr.sim.ordptr(Ev):cpr.sim.ordptr(Ev+1)-1
      blk=cpr.sim.ordclk(i,1);nevprt=cpr.sim.ordclk(i,2);

      if or(blk==valids) then
	if cpr.sim.funtyp(blk)==-1 then
	  EvThen=cpr.sim.clkptr(blk)
	  EvElse=cpr.sim.clkptr(blk)+1
	  ki=cpr.sim.inpptr(blk)
	  kin=cpr.sim.inplnk(ki)
	  kkin=find(kin==outtbin(:,1))
	  kkout=find(kin==outtbout(:,1))
	  if ~isempty(kkin) then
            input_if="_io.inouts"+string(outtbin(kkin,2))
	  elseif ~isempty(kkout) then
            input_if="_io.inouts"+string(outtbout(kkout,2)+nin)
	  else
            input_if="persistent_extract(_links,''link"+string(kin)+"'')";
	  end

	  txt($+1,1)="if_cos("+input_if+",CallFunction('"updateState"+string(EvThen)+"'",_io),CallFunction('"updateState"+string(EvElse)+"'",_io))"

	elseif cpr.sim.funtyp(blk)==-2 then
	  error("Iselect block not implemented yet")
	else
	  txt($+1,1)="if length(stateptr("+string(blk)+"))>0 then"
	  txt($+1,1)="  block=hash(10)"
	  txt($+1,1)="  params=hash(10)";
	  blkparams=_params(blk)
	  j=1;
	  for par=blkparams
            txt($+1,1)="  params.p"+string(j)+"="+nsp2bvarexp(blkparams(j),0)+";";
            j=j+1
	  end
	  txt($+1,1)="  block.params=params"

	  txt=set_block_io_text(cpr,blk,outtbout,outtbin,txt)
	  txt($+1,1)="  block.io=blkio"
	  txt($+1,1)="  bstate=list()"
	  txt($+1,1)="  for i=1:length(stateptr("+string(blk)+"))"    
	  txt($+1,1)="    bstate(i)=persistent_extract(_states,stateptr("+string(blk)+")(i));"
	  txt($+1,1)="  end"
	  txt($+1,1)="  block.state=bstate;"
	  txt($+1,1)="  block.nevprt="+string(nevprt)
	  txt($+1,1)="  block=P_"+scs_m.objs(cpr.corinv(blk)).gui+"(block,numerics(2))"
	  txt($+1,1)="  for i=1:length(stateptr("+string(blk)+"))"    
	  txt($+1,1)="    _states=persistent_insert(_states,stateptr("+string(blk)+")(i),block.state(i));"
	  txt($+1,1)="  end"
	  txt($+1,1)="end"
	end
      end
    end
    txt($+1,1)="EndFunction()"
  endfunction


  function %val=EvalinContext(%expr,%ctx)
    execstr(%ctx)
    %val=evstr(%expr)
  endfunction


  function txt=initialize(txt,ord)
    valids=_params.defined[]; // in out blocks have no params 
    for i=1:size(ord,1)
      blk=ord(i,1); nevprt=ord(i,2);
      if or(blk==valids) then
	if cpr.sim.funtyp(blk)==-1 then
	  EvThen=cpr.sim.clkptr(blk)
	  EvElse=cpr.sim.clkptr(blk)+1
	  ki=cpr.sim.inpptr(blk)
	  kin=cpr.sim.inplnk(ki)
	  kkin=find(kin==outtbin(:,1))
	  kkout=find(kin==outtbout(:,1))
	  if ~isempty(kkin) then
            txt($+1,1)="input_if=vio.inouts"+string(outtbin(kkin,2))+";"
	  elseif ~isempty(kkout) then
            txt($+1,1)="input_if=vio.inouts"+string(outtbout(kkout,2)+nin)+";"
	  else
            txt($+1,1)="input_if=vlinks("+string(kin)+")"
	  end
	  txt_then = initialize([],cpr.sim.ordclk(EvThen):cpr.sim.ordclk(EvThen+1)-1)
	  txt_else = initialize([],cpr.sim.ordclk(EvElse):cpr.sim.ordclk(EvElse+1)-1)
	  txt($+1,1)="if input_if>0 then "
	  txt=[txt;txt_then]
	  txt($+1,1)="else"
	  txt=[txt;txt_else]
	  txt($+1,1)="end"

	elseif cpr.sim.funtyp(blk)==-2 then
	  error("Iselect block not implemented yet")
	else
	  txt($+1,1)="block=hash(10)"
	  txt($+1,1)="params=hash(10)";
	  blkparams=_params(blk)
	  j=1;
	  for par=blkparams
            txt($+1,1)="params.p"+string(j)+"="+nsp2bvarexp(blkparams(j),0)+";";
            j=j+1
	  end
	  txt($+1,1)="block.params=params"

	  txt=set_block_vio_text(cpr,blk,outtbout,outtbin,txt)
	  txt($+1,1)="block.io=blkio"
	  //        txt($+1,1)="bstate=list()"
	  //        txt($+1,1)="for i=1:length(stateptr("+string(blk)+"))"    
	  //        txt($+1,1)="  bstate(i)=_states(stateptr("+string(blk)+")(i))"
	  //        txt($+1,1)="end"
	  //        txt($+1,1)="block.state=bstate;"
	  txt($+1,1)="block.state=vstates("+string(blk)+")"
	  txt($+1,1)="block.nevprt="+string(nevprt)
	  txt($+1,1)="block=P_"+scs_m.objs(cpr.corinv(blk)).gui+"(block,numerics(1))"

	  j=cpr.sim.inpptr(blk+1)-cpr.sim.inpptr(blk)+1
	  for ko=[cpr.sim.outptr(blk):cpr.sim.outptr(blk+1)-1]
	    kout=cpr.sim.outlnk(ko)
	    kkin=find(kout==outtbin(:,1))
	    kkout=find(kout==outtbout(:,1))
	    if ~isempty(kkout) then
	      txt($+1,1)="vio = inouts_insert(vio,''inouts"+string(outtbout(kkout,2)+nin)+"'',block.io("+string(j)+"));;"
	    elseif ~isempty(kkin) then
	      txt($+1,1)="vio = inouts_insert(vio,''inouts"+string(outtbin(kkin,2))+"'',block.io("+string(j)+"));"
	    else
	      txt($+1,1)="vlinks("+string(kout)+")=block.io("+string(j)+")"
	    end
	    j=j+1
	  end
	end
      end
    end
  endfunction

  function blkio=set_block_io(cpr,blk,outtbout,outtbin,_io,_links)
  // XXXX unused 
    blkio=list()
    j=1
    for ki=cpr.sim.inpptr(blk):cpr.sim.inpptr(blk+1)-1
      kin=cpr.sim.inplnk(ki)
      kkout=find(kin==outtbout(:,1))
      kkin=find(kin==outtbin(:,1))
      if ~isempty(kkin) then
        execstr("blkio("+string(j)+")=_io.inouts"+string(outtbin(kkin,2)))
      elseif ~isempty(kkout) then
        execstr("blkio("+string(j)+")=_io.inouts"+string(outtbout(kkout,2)+nin))
      else
        execstr("blkio("+string(j)+")=_links.link"+string(kin))
      end
      j=j+1
    end

    for ko=cpr.sim.outptr(blk):cpr.sim.outptr(blk+1)-1
      kout=cpr.sim.outlnk(ko)
      kkin=find(kout==outtbin(:,1))
      kkout=find(kout==outtbout(:,1))
      if ~isempty(kkout) then
        execstr("blkio("+string(j)+")=_io.inouts"+string(outtbout(kkout,2)+nin))
      elseif ~isempty(kkin) then
        execstr("blkio("+string(j)+")=_io.inouts"+string(outtbin(kkin,2)))
      else
        execstr("blkio("+string(j)+")=_links.link"+string(kout))
      end
      j=j+1
    end
  endfunction

  function txt=set_block_io_text(cpr,blk,outtbout,outtbin,txt)
    txt($+1,1)="  blkio=list()"
    j=1
    for ki=cpr.sim.inpptr(blk):cpr.sim.inpptr(blk+1)-1
      kin=cpr.sim.inplnk(ki)
      kkout=find(kin==outtbout(:,1))
      kkin=find(kin==outtbin(:,1))
      if ~isempty(kkin) then
	txt($+1,1)="  blkio("+string(j)+")=_io.inouts"+string(outtbin(kkin,2))
      elseif ~isempty(kkout) then
	txt($+1,1)="  blkio("+string(j)+")=_io.inouts"+string(outtbout(kkout,2)+nin)
      else
	txt($+1,1)="  blkio("+string(j)+")=persistent_extract(_links,''link"+string(kin)+"'');";
      end
      j=j+1
    end

    for ko=cpr.sim.outptr(blk):cpr.sim.outptr(blk+1)-1
      kout=cpr.sim.outlnk(ko)
      kkin=find(kout==outtbin(:,1))
      kkout=find(kout==outtbout(:,1))
      if ~isempty(kkout) then
	txt($+1,1)="  blkio("+string(j)+")=_io.inouts"+string(outtbout(kkout,2)+nin)
      elseif ~isempty(kkin) then
	txt($+1,1)="  blkio("+string(j)+")=_io.inouts"+string(outtbin(kkin,2))
      else
	txt($+1,1)="  blkio("+string(j)+")=persistent_extract(_links,''link"+string(kout)+"'');";
      end
      j=j+1
    end
  endfunction

  function txt=set_block_vio_text(cpr,blk,outtbout,outtbin,txt)
    txt($+1,1)="  blkio=list()"
    j=1
    for ki=cpr.sim.inpptr(blk):cpr.sim.inpptr(blk+1)-1
      kin=cpr.sim.inplnk(ki)
      kkout=find(kin==outtbout(:,1))
      kkin=find(kin==outtbin(:,1))
      if ~isempty(kkin) then
	txt($+1,1)="  blkio("+string(j)+")=vio.inouts"+string(outtbin(kkin,2))+";"
      elseif ~isempty(kkout) then
	txt($+1,1)="  blkio("+string(j)+")=vio.inouts"+string(outtbout(kkout,2)+nin)+";"
      else
	txt($+1,1)="  blkio("+string(j)+")=vlinks("+string(kin)+")"
      end
      j=j+1
    end

    for ko=cpr.sim.outptr(blk):cpr.sim.outptr(blk+1)-1
      kout=cpr.sim.outlnk(ko)
      kkin=find(kout==outtbin(:,1))
      kkout=find(kout==outtbout(:,1))
      if ~isempty(kkout) then
	txt($+1,1)="  blkio("+string(j)+")=vio.inouts"+string(outtbout(kkout,2)+nin)+";"
      elseif ~isempty(kkin) then
	txt($+1,1)="  blkio("+string(j)+")=vio.inouts"+string(outtbin(kkin,2))+";"
      else
	txt($+1,1)="  blkio("+string(j)+")=vlinks("+string(kout)+")"
      end
      j=j+1
    end
  endfunction

  function txt=set_block_io_text_out(cpr,blk,outtbout,outtbin,txt)
    j=cpr.sim.inpptr(blk+1)-cpr.sim.inpptr(blk)+1

    for ko=[cpr.sim.outptr(blk):cpr.sim.outptr(blk+1)-1]
      kout=cpr.sim.outlnk(ko)
      kkin=find(kout==outtbin(:,1))
      kkout=find(kout==outtbout(:,1))
      if ~isempty(kkout) then
	txt($+1,1)="  _io = inouts_insert(_io,''inouts"+string(outtbout(kkout,2)+nin)+"'',block.io("+string(j)+"));"
      elseif ~isempty(kkin) then
	txt($+1,1)="  _io = inouts_insert(_io,''inouts"+string(outtbin(kkin,2))+"'',block.io("+string(j)+")"
      else
	txt($+1,1)="_links=persistent_insert(_links,''link"+string(kout)+"'',block.io("+string(j)+"));";
      end
      j=j+1
    end
  endfunction

  
  ins=list();outs=list();_params=list();outtbin=[],outtbout=[];
  funs=cpr.sim.funs;
  for i=1:length(funs)
    
    if type(funs(i),'short')== 'pl' then  // Support for P_block
      // funs(i) is a nsp function
      exprs3=scs_m.objs(cpr.corinv(i)).graphics.exprs
      if length(exprs3)<3 then error("Unsupported Scilab block.");end
      _params(i)=list()
      exprs=exprs3(1)(7)
      ok=execstr("vexprs=EvalinContext(exprs,scs_m.props.context)",errcatch=%t)
      if ~ok then message(catenate(lasterror())); ok=%f;return; end;
      for j=1:length(vexprs)
	ok =execstr("_params(i)($+1)=vexprs(j)",errcatch=%t);
	if ~ok then  message(catenate(lasterror())); ok=%f;return; end;
      end
      _params(i)($+1)=exprs3(1)(1) //P block name
      _params(i)($+1)=exprs3(3) //P code
      //execstr(exprs3(3)) // define P code
      funs(i)="xxxxxxxxx"  //exprs3(1)(1)
    elseif part(funs(i),1:7)=='capteur' then
      num=cpr.sim.ipar(cpr.sim.ipptr(i):cpr.sim.ipptr(i+1)-1)
      l=cpr.sim.outlnk(cpr.sim.outptr(i))
      ins(num)=cpr.state.outtb(l)
      outtbin=[outtbin;l,num]
    elseif part(funs(i),1:10)=='actionneur' then
      num=cpr.sim.ipar(cpr.sim.ipptr(i):cpr.sim.ipptr(i+1)-1)
      l=cpr.sim.inplnk(cpr.sim.inpptr(i))
      outs(num)=cpr.state.outtb(l)
      outtbout=[outtbout;l,num]
    elseif funs(i)=='bidon' then
      Ev=[cpr.sim.clkptr(i):cpr.sim.clkptr(i+1)-1]
    else
      exprs=scs_m.objs(cpr.corinv(i)).graphics.exprs
      _params(i)=list()
      for j=1:size(exprs,1)
	ok=execstr("_params(i)($+1)=EvalinContext(exprs(j),scs_m.props.context)",...
		   errcatch=%t);
	if ~ok then
	  message(catenate(lasterror()));
	  _params(i)($+1)=exprs(j);
	end
      end
    end
  end
  nin=size(outtbin,1)
  nout=size(outtbout,1)

  txt= m2s([]);
  txt($+1,1)="// z=m2p([0,1]);s=m2p([0,1]);"
  txt($+1,1)="OpenCFile('""+fname+"'");"
  
  txt($+1,1)="vstates=list()"
  for blk=1:length(funs)
    if part(funs(blk),1:7)~='capteur' & part(funs(blk),1:10)~='actionneur' &...
	  funs(blk)~='bidon' & cpr.sim.funtyp(blk)>0 then
      txt($+1,1)="block=hash(10);"
      txt($+1,1)="block.state=list()"
      txt($+1,1)="params=hash(10);";
      if or(blk==_params.defined[]) then
	blkparams=_params(blk)
	j=1;
	for par=blkparams
	  txt($+1,1)="params.p"+string(j)+"="+nsp2bvarexp(blkparams(j),0)+";";
	  j=j+1;
	end
      end
      txt($+1,1)="block.params=params";
      txt($+1,1)="blkio=list()"
      j=1
      for ki=cpr.sim.inpptr(blk):cpr.sim.inpptr(blk+1)-1
	kin=cpr.sim.inplnk(ki)
	txt($+1,1)="blkio("+string(j)+")="+nsp2bvarexp(cpr.state.outtb(kin),0)+";";
	j=j+1	   
      end
      for ko=cpr.sim.outptr(blk):cpr.sim.outptr(blk+1)-1
	kout=cpr.sim.outlnk(ko)
	txt($+1,1)="blkio("+string(j)+")="+nsp2bvarexp(cpr.state.outtb(kout),0)+";";
	j=j+1	   
      end
      txt($+1,1)="block.io=blkio";
      txt($+1,1)="block.nevprt=0";
      txt($+1,1)="block=P_"+scs_m.objs(cpr.corinv(blk)).gui+"(block,numerics(-1))";
      txt($+1,1)="vstates("+string(blk)+")=block.state";
    else
      txt($+1,1)="vstates("+string(blk)+")=list()";
    end
  end
  txt($+1,1)="vlinks=list()"
  outtb=cpr.state.outtb;
  XX=[outtbout;outtbin]
  for i=1:length(outtb)
    if ~or(i==XX(:,1)) then
      txt($+1,1)="vlinks("+string(i)+")="+nsp2bvarexp(outtb(i),0)+";"
    end
  end
  txt($+1,1)="vio=inouts();"
  j=1
  for i=1:length(ins)
    txt($+1,1)="vio = inouts_insert(vio,''inouts"+string(j)+"'',"+nsp2bvarexp(ins(i),0)+");"
    j=j+1
  end
  for i=1:length(outs)
    txt($+1,1)="vio = inouts_insert(vio,''inouts"+string(j)+"'',"+nsp2bvarexp(outs(i),0)+");"
    j=j+1
  end
  
  txt=initialize(txt,cpr.sim.iord)
  
  txt($+1,1)="// collect the states"
  txt($+1,1)="_states=persistent();"
  txt($+1,1)="snum=1;stateptr=list()"
  txt($+1,1)="for i=1:"+string(length(funs))
  txt($+1,1)="  stateptr(i)=list();"
  txt($+1,1)="  for k=1:length(vstates(i))"
  txt($+1,1)="    _states =persistent_insert(_states,snum,vstates(i)(k));"
  txt($+1,1)="    stateptr(i)(k)=snum;snum=snum+1;"
  txt($+1,1)="  end"
  txt($+1,1)="end"

  txt($+1,1)="// collect the links"
  txt($+1,1)="_links=persistent();"
  outtb=cpr.state.outtb;
  for i=1:length(outtb)
    XX=[outtbout;outtbin];
    if ~or(i==XX(:,1)) then
      txt($+1,1)="_links=persistent_insert(_links,''link"+string(i)+"'',vlinks("+string(i)+"));";
    end
  end
  txt($+1,1)="";

  txt($+1,1)="_io=inouts()";

  j=1
  txt($+1,1)="code_insert(''annotation'',''inputs'');"
  for i=1:length(ins)
    txt($+1,1)="_io.inouts"+string(j)+"=vio.inouts"+string(j)+";";
    j=j+1
  end
  txt($+1,1)="code_insert(''annotation'',''outputs'');"
  for i=1:length(outs)
    txt($+1,1)="_io.inouts"+string(j)+"=vio.inouts"+string(j)+";";
    j=j+1
  end

  txt= gencode_for_event(Ev,cpr,txt)

  txt($+1,1)="CloseCFile()"

endfunction


