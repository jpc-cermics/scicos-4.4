function [scs_m,atomicflg]=xml2cos(xmlfilename,typ)

  function field=cos_subst(field)
    field=strsubst(field,'&amp;','&');
    field=strsubst(field,'&lt;','<');
    field=strsubst(field,'&gt;','>');
    field=strsubst(field,'&quot;','""');
    field=strsubst(field,'&apos;','''');
    field=strsubst(field,'<p>','');
    field=strsubst(field,'</p>','');
  endfunction

  function scs_m=load_par(symbol,id1,id2)
    scs_m=scs_m;global txtline
    //t=readc_(unit);
    t=read_new_line(txt);
    typ=split(t,msep=%t);
    while typ(1)<>symbol do
      //disp(typ(1))
      if typ(1)=='<Diagram' then
	//disp('here')
	[scs_m1,atomicflg]=xml2cos(xmlfilename,typ)
	execstr('scs_m.'+id2+'.model.rpar=scs_m1');
	if atomicflg then execstr('scs_m.'+id2+'.model.sim=list(""asuper"",2004)');end
	t=read_new_line(txt);
	typ=split(t,msep=%t);
      else
	ttyp=split(typ(2),msep=%t,sep='''')
	//disp(ttyp(2));
	if ttyp(2)=='rpar' & size(typ,'*')==2 then  // is kept for compatibility
	  if symbol=='</Block>' then
	    scs_m1=xml2cos(xmlfilename,typ)
	    execstr('scs_m.'+id2+'.'+id1+'('''+ttyp(2)+''')='+sci2exp(scs_m1,0));
	  else
	    //t=readc_(unit);
	    t=read_new_line(txt);
	    execstr('scs_m.'+id2+'.'+id1+'('''+ttyp(2)+''')='+cos_subst(t));
	  end
	elseif ttyp(2)=='gr_i' then
	  //t=readc_(unit);
	  t=read_new_line(txt);
	  execstr('scs_m.'+id2+'.'+id1+'('''+ttyp(2)+''')='+cos_subst(t));
	elseif ttyp(2)=='exprs' then
	  exprstxt=[];
	  t=read_new_line(txt);
	  typ=split(t,msep=%t);
	  // indx_end=grep(txt,'</graphics>');
	  xx=strstr(txt,'</graphics>');
	  indx_end=find(xx<>0);
	  ind=find(indx_end>txtline);ind=ind(1);
	  indx_end=indx_end(ind);
	  exprstxt=cos_subst(txt(txtline:indx_end-1))
	  txtline=indx_end;
	  if size(exprstxt,'*')>1 then
	    pw=getcwd()
	    TMPDIR=getenv('NSP_TMPDIR')
	    chdir(TMPDIR)
	    file('delete','exprstxt.sce');
	    fd = fopen('exprstxt.sce',mode='w');
	    exprstxt=['scs_m.'+id2+'.'+id1+'('''+ttyp(2)+''')=..';exprstxt]
	    fd.put_smatrix[exprstxt];
	    fd.close[];
	    exec("exprstxt.sce");
	    chdir(pw);
	  else
	    execstr('scs_m.'+id2+'.'+id1+'('''+ttyp(2)+''')='+exprstxt);
	  end 
	else
	  indx1=strindex(t,'value=''');indx1=indx1+6;
	  indx2=length(t)-4;
	  tttyp=part(t,indx1+1:indx2);
	  execstr('scs_m.'+id2+'.'+id1+'('''+ttyp(2)+''')='+cos_subst(tttyp));
	end
	//t=readc_(unit);
	t=read_new_line(txt);
	typ=split(t,msep=%t);
	if or(typ==['</graphics>','</model>']) then
	  //t=readc_(unit);
	  t=read_new_line(txt);
	  typ=split(t,msep=%t);
	end
      end
    end
  endfunction

  function numb=get_numb(typ)
    ttyp=split(typ(2),msep=%t,sep='''')
    ttyp=split(ttyp(1),msep=%t,sep='""')
    ind=strindex(ttyp(2),'_');
    if isempty(ind) then
      numb=part(ttyp(2),4:length(ttyp(2)));
    else
      numb=part(ttyp(2),ind($)+1:length(ttyp(2)));  
    end
  endfunction

  function scs_m=treat_blocks(symbol,typ)
    scs_m=scs_m;global txtline
    numb=get_numb(typ);
    //disp(numb);
    if symbol=='</Block>' then
      execstr('scs_m.objs('+numb+')=scicos_block();');
    else
      execstr('scs_m.objs('+numb+')=scicos_text();');
    end
    //t=readc_(unit);
    t=read_new_line(txt);
    typ=split(t,msep=%t);
    while typ(1)<>symbol do
      ttyp=split(typ(2),msep=%t,sep='''')
      //disp(ttyp(2))
      //disp(symbol)
      if or(ttyp(2)==['graphics','model','diagram']) then
	//if ttyp(2)=='diagram' then pause;end
	scs_m=load_par(symbol,ttyp(2),'objs('+numb+')');
	//elseif ttyp(2)=='void' then
      else
	//aboif ttyp(2)=='gui' then pause;end
	indx1=strindex(t,'value=''');indx1=indx1+6;
	indx2=length(t)-4;
	tttyp=part(t,indx1+1:indx2);
	execstr('scs_m.objs('+numb+').'+ttyp(2)+'='+cos_subst(tttyp));
      end
      //t=readc_(unit);
      t=read_new_line(txt);
      typ=split(t,msep=%t);
    end
  endfunction


  function t=read_new_line(txt)
    global txtline
    txtline=txtline+1;
    t=txt(txtline)
  endfunction

  
  
  
  atomicflg=%f;
  // if exists('scicoslib')==0 then load('SCI/macros/scicos/lib'),end
  //exec(loadpallibs,-1) //to load the palettes libraries
  if nargin <2 then
    typ=[""];
    global txtline
    txtline=1
    flag=%f;
    txt=getfile(xmlfilename)
    // unit=file('open',xmlfilename,'unknown')
  end
  while and(typ<>'</Diagram>') do
    //t=read_new_line(txt)
    //t=readc_(unit);
    //typ=split);
    //disp(typ(1))
    if typ(1)=='<Diagram' then
      scs_m=scicos_diagram();
    elseif typ(1)=='<ScicosVersion' then
      ttyp=split(typ(2),msep=%t,sep='""')
      if size(ttyp,'*')>1 then scs_m.version=ttyp(2);else scs_m.version='';end
    elseif typ(1)=='<AtomicDiagram' then
      ttyp=split(typ(2),msep=%t,sep='""');
      if ttyp(2)=='yes' then atomicflg=%t; else atomicflg=%f;end
    elseif typ(1)=='<Parameters>' then
      scs_m.props=scicos_params();
      //t=readc_(unit);
      t=read_new_line(txt);
      typ=split(t,msep=%t);
      while typ(1)<>'</Parameters>' do
	ttyp=split(typ(2),msep=%t,sep='''')
	//disp(ttyp(2));
	if ttyp(2)=='context' then
	  //t=readc_(unit);
	  t=read_new_line(txt);
	  cntxt=cos_subst(t);
	  scs_m.props.context=evstr(cntxt);
	elseif ttyp(2)=='options' then
	  scs_m=load_par('</params>','options','props')
	else
	  indx1=strindex(t,'value=''');indx1=indx1+6;
	  indx2=length(t)-4;
	  tttyp=part(t,[indx1+1:indx2]);
	  execstr('scs_m.props.'+ttyp(2)+'='+tttyp)
	end
	//t=readc_(unit);
	t=read_new_line(txt);
	typ=split(t,msep=%t);
	if typ(1)=='</params>' then
	  //t=readc_(unit);
	  t=read_new_line(txt);
	  typ=split(t,msep=%t);         
	end
      end
    elseif typ(1)=='<CodeGeneration>' then
      scs_m.codegen=scicos_codegen();
      //t=readc_(unit);
      t=read_new_line(txt);
      typ=split(t,msep=%t);
      while typ(1)<>'</CodeGeneration>' do
	ttyp=split(typ(2),msep=%t,sep='''')
	indx1=strindex(t,'value=''');indx1=indx1+6;
	indx2=length(t)-4;
	tttyp=part(t,indx1+1:indx2);
	execstr('scs_m.codegen.'+ttyp(2)+'='+tttyp);
	//t=readc_(unit);
	t=read_new_line(txt);
	typ=split(t,msep=%t);
      end
    elseif typ(1)=='<Objects>' then
      //t=readc_(unit);
      t=read_new_line(txt);
      typ=split(t,msep=%t);
      while typ(1)<>'</Objects>' do
	if typ(1)=='<Block' then
	  scs_m=treat_blocks('</Block>',typ)
	elseif typ(1)=='<Text' then
	  scs_m=treat_blocks('</Text>',typ)
	elseif typ(1)=='<Link' then
	  numb=get_numb(typ);
	  execstr('scs_m.objs('+numb+')=scicos_link()');
	  //t=readc_(unit);
	  t=read_new_line(txt);
	  typ=split(t,msep=%t);
	  while typ(1)<>'</Link>' do
	    ttyp=split(typ(2),msep=%t,sep='''')
	    //disp(ttyp(2))
	    indx1=strindex(t,'value=''');indx1=indx1+6;
	    indx2=length(t)-4;
	    tttyp=part(t,indx1+1:indx2);
	    //tttyp=split(typ(3),'''')
	    execstr('scs_m.objs('+numb+').'+ttyp(2)+'='+tttyp);
	    //t=readc_(unit);
	    t=read_new_line(txt);
	    typ=split(t,msep=%t);
	  end    
	elseif typ(1)=='<Deleted' then
	  numb=get_numb(typ);
	  execstr('scs_m.objs('+numb+')=mlist(''Deleted'')');
	end
	//t=readc_(unit);
	t=read_new_line(txt);
	typ=split(t,msep=%t);
      end
    end
    t=read_new_line(txt);
    typ=split(t,msep=%t);   
    //disp('end')
  end
  //scs_m.version='scicos4.2'
  if nargin < 2 then
    clearglobal txtline;
    //file('close',unit);
  end
endfunction

