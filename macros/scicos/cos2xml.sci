function [ok,t]=cos2xml(scs_m,name,atomic=%f)
  ok=%t;t=[];format(20);
  Bn='OBJ';
  tit=scs_m.props.title(1);
  version=get_scicos_version();
  if exists('supername') then 
    Bn=supername+'_',
    if atomic then flg='yes'; else flg='no';end
    head=['   <Diagram Name=""'+tit+'"">'
	  '   <ScicosVersion Name=""'+version+'"" />'
	  '   <AtomicDiagram Atomic=""'+flg+'"" />']
    tail=['   </Diagram>']
    [%scicos_context,ierr]=script2var(scs_m.props.context,%scicos_context)
  else
    // top 
    head=['<?xml version=""1.0"" encoding=""UTF-8""?>'
	  ' <ScicosModel Name=""'+tit+'"" >'
	  '   <Diagram Name=""'+tit+'"">'
	  '   <ScicosVersion Name=""'+version+'"" />']
    tail=['   </Diagram>'
	  ' </ScicosModel>']
    [%scicos_context,ierr]=script2var(scs_m.props.context,hash(1));
  end
  p=scs_m.props;
  xml_txt=block2xml(p);
  t=[t;
     '<Parameters>';
     '  '+xml_txt;
     '</Parameters>']
  objs=scs_m.objs
  t=[t;
     '<Objects>'];
  for k=1:size(objs)
    name=Bn+string(k)
    o=objs(k)
    x=o.__keys;
    x1 = o.type;
    if x1=='Block' then
      //disp('it is block');//pause	
      if o.model.sim.equal['super'] || ...
	    (o.model.sim.equal['csuper'] & ~o.model.ipar.equal[1]) || ...
	    o.model.sim(1).equal['asuper'] || (o.model.sim.equal['csuper'] & o.gui.equal['DSUPER']) then
	supername=name
	t=[t;
	   '<Block Name=""'+name+'"" >']
	if o.model.sim(1)=='asuper' then
	  atomic=%t;
	  [ok,t1]=cos2xml(o.model.rpar,name,atomic=%t);
	else
	  atomic=%f;
	  [ok,t1]=cos2xml(o.model.rpar,name,atomic=%f);
	end
	if ~ok then t=[];ok=%f;return; end
	xml_txt=block2xml(o,2,t1,atomic=atomic)
	t=[t;
	   xml_txt;
	   '</Block>' ]
      else //standard block
	xml_txt=block2xml(o,1);
      	t=[t;
	   '<Block Name=""'+name+'"" >';
	   xml_txt;
	   '</Block>'];
      end
    elseif x1=='Deleted' then
      t=[t;'   <Deleted Name=""'+name+'""></Deleted>']
    elseif x1=='Text' then
      xml_txt=block2xml(o,3);
      t=[t;
	 '<Text Name=""'+name+'"" >';
	 xml_txt;
	 '</Text>']; 
    else //links
      xml_txt=block2xml(o);
      t=[t;
	 '<Link Name=""'+name+'"" >';
	 xml_txt;
	 '</Link>'];
    end
  end //end of loop on objects
  t=[t;
     '</Objects>'];
  p=scs_m.codegen;
  xml_txt=block2xml(p);
  t=[t;
     '<CodeGeneration>';
     '  '+xml_txt;
     '</CodeGeneration>']
  t=[head;'   '+t;tail]
endfunction

function xml_txt=block2xml(o,flag,t1,atomic=%f)
// hash table 
  if nargin <= 1 then flag=2;end 
  xml_txt=m2s([]);format(20);
  x=o.__keys ; // should eliminate type tlist, mlist 
  x1= o.type; // 
  for i=1:size(x,'*')
    if x(i)=='type' || x(i) == 'mlist' || x(i) == 'tlist' then 
      // ignore 
    elseif x(i)=='context' then
      xml_txt.concatd[['   <'+x1+' id='''+x(i)+''' >';
		       '      '+xml_subst(evstr('sci2exp(o.'+x(i)+',0)'));
		       '   </'+x1+'>']];
    elseif x1=='Link'|| (x1=='params' && x(i)<>'options') || x1=='codegeneration' then
      xml_txt.concatd[['   <'+x1+' id='''+x(i)+''' value='''+evstr('sci2exp(o.'+x(i)+',0)')+''' />']];
    elseif x(i)=='doc'|x(i)=='void'| x(i)=='gui' then
      xml_txt.concatd[[' <'+x(i)+' id='''+x(i)+''' value='''+evstr('sci2exp(o.'+x(i)+',0)')+''' />']];
    else
      if x(i)<>'model' then
	xml_txt.concatd[[' <'+x1+' id='''+x(i)+''' >']];
      end
      // o(x(i)) is also a hash table 
      xx=o(x(i)).__keys;
      for j=2:size(xx,'*')
	if x(i)=='model' & xx(j)<>'rpar'	 
	elseif xx(j)=='gr_i' then
	  xml_txt=[xml_txt;
		   '   <'+x(i)+' id='''+xx(j)+'''>';
		   '      '+xml_subst(evstr('sci2exp(o.'+x(i)+'.'+xx(j)+',0)'));
		   '   </'+x(i)+'>'];
	elseif xx(j)=='exprs' then
	  if flag==2 & atomic then
	    xml_txt=[xml_txt;
		     '   <'+x(i)+' id='''+xx(j)+'''>';
		     '       <p>'+xml_subst(evstr('sci2exp(o.'+x(i)+'.'+xx(j)+'(1),90)'))+'</p>';
		     '   </'+x(i)+'>'];
	  else
	    xml_txt=[xml_txt;
		     '   <'+x(i)+' id='''+xx(j)+'''>';
		     '       <p>'+xml_subst(evstr('sci2exp(o.'+x(i)+'.'+xx(j)+',90)'))+'</p>';
		     '   </'+x(i)+'>'];
	  end
	elseif xx(j)=='rpar' & flag==2 then
	  xml_txt=[xml_txt;
		   ' <Block  id=''diagram'' >';
		   '      '+t1;
		   ' </Block>'];
	elseif xx(j)=='rpar' then
	  xml_txt=[xml_txt;
		   ' <'+x1+' id=''diagram'' >';
		   ' </'+x1+'>'];
	elseif xx(j)=='3D' then
	  xml_txt=[xml_txt;
		   '   <'+x(i)+' id='''+xx(j)+''' value='''+evstr('sci2exp(o.'+x(i)+'('+sci2exp(j)+')'+',0)')+''' />'];
	else
	  xml_txt=[xml_txt;
		   '   <'+x(i)+' id='''+xx(j)+''' value='''+xml_subst(strsubst(evstr('sci2exp(o.'+x(i)+'.'+xx(j)+',0)'),' ',''))+''' />'];
	end
      end
      if x(i)<>'model' then
	xml_txt=[xml_txt;
		 ' </'+x1+'>'];
      end
    end
  end
endfunction

function field=xml_subst(field)
  field=strsubst(field,'&','&amp;');
  field=strsubst(field,'<','&lt;');
  field=strsubst(field,'>','&gt;');
  field=strsubst(field,'""','&quot;');
  field=strsubst(field,'''','&apos;');
endfunction
