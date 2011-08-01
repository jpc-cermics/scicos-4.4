function  scmenu_block_documentation()
  Cmenu='';
  sc=scs_m;
  [scs_m,changed]= do_doc(scs_m);
  if changed then 
    edited=%t;
    scs_m_save=sc;enable_undo=%t;
  end
endfunction

function [scs_m,changed]=do_doc(scs_m)
// Copyright INRIA
  changed=%f;
  if isempty(Select) || isempty(find(Select(:,2)==curwin)) then
    message('Make a selection first');
    return;
  end
  // K contains selected indices restricted to curwin 
  K=Select(find(Select(:,2)==curwin),1);
  if length(K)<> 1 then 
    message('Select only one block or one link for identification !');
    return;
  end
  numero_objet=K;
  
  objet = scs_m.objs(numero_objet)
  type_objet = objet.type
  
  //
  if type_objet == 'Block' then
    documentation = objet.doc
    if size(documentation,'*') == 0 || isempty(documentation) then
      rep=x_message(['No documentation function specified'
		     'would you like to use standard_doc ?'],['gtk-yes','gtk-no'])
      funname='standard_doc'
      if rep==2 then
	[ok, funname] = getvalue('Enter the name of the documentation function',
	'fun name',list('str', 1),'standard_doc')
	if ~ok then return,end
      end
      doc=[]
      ierr=execstr('docfun='+funname,errcatch=%t)
      if ierr==%f then
	x_message('function '+funname+' not found');
	lasterror();
	return
      end
      documentation=list(docfun,doc)
    end
    funname=documentation(1);doc=documentation(2)
    if type(funname,'string')=='SMat' then 
      ierr=execstr('docfun='+funname,errcatch=%t)
      if ierr==%f then
	x_message('function '+funname+' not found')
	lasterror();
	return
      end
    else
      docfun=funname
    end
    
    ok= execstr('doc=docfun(''set'',doc)',errcatch=%t)
    if ok then
      documentation(2)=doc
      objet.doc = documentation
      scs_m.objs(numero_objet) = objet
      changed = %t;
    else
      x_message(documentation(1)+'(''set'',) failed');
      lasterror();
    end
  else
    x_message('It is impossible to set Documentation for this type of object')
  end
endfunction


function doc=standard_doc(job,doc)
  if job=='set' then
    if type(doc,'string')<>'SMat' then doc=' ',end
    text=dialog('You may enter here the document for this block ',doc)
    if size(text,'*')<>0 then doc=text,end
  elseif job=='get' then
    return
  end
endfunction

function doc=complex_doc(job,doc)
  if job=='set' then
    if type(doc,'string')<>'List' then 
      doc=list(' ',' ',' '),
    end
    d3=[]
    t3=doc(3)
    for k=1:size(t3,1)
      d3=[d3 ascii(t3(k)) 48]
    end
    d3=ascii(d3)
    text=x_mdialog('You may enter here the document for this block ',
    ['Author','Date','Comments'],[doc(1);doc(2);d3])
    if ~isempty(text) then 
      doc(1)=text(1)
      doc(2)=text(2)
      t3=[ascii(text(3)) 48]
      k=find(t3==48)
      tt=[]
      k1=1
      for i=1:size(k,'*')-1
	tt=[tt;ascii(t3(k1:k(i)-1))]
	k1=k(i+1)
      end  
      doc(3)=tt
    end
  elseif job=='get' then
    doc=['Author  :'+doc(1)
	 'Date    :'+doc(2)
	 'Comments:'
	 '         '+doc(3) ]
    return
  end
endfunction
