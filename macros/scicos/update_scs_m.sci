function nobj = update_scs_m(obj)
// updates scicos obj by recalling all the scicos_xx functions
// where they can be called. This function can be called on any 
// scicos objects i.e a diagram or a model or a block ...
// jpc 2011 
//
  H=hash(3, codegeneration='codegen',Block='block',Link='link',Text='text');
  typ = type(obj,'short');
  select typ 
   case 'h' then 
    // Object is an hash table 
    if obj.iskey['type'] then 
      typ=obj.type;
      if H.iskey[obj.type] then typ=H(obj.type);end
      execstr(sprintf('nobj= scicos_%s();',typ));
    else
      nobj= hash(length(obj));
    end
    if typ == 'params' then 
      // special case replace Title by title
      if obj.iskey['Title'] && ~obj.iskey['title'] then 
	obj.title = obj.Title;
	obj.remove['Title'];
      end
    end
    keys= obj.__keys;
    keys=setdiff(keys,['type','tlist','mlist']);
    for i=1:size(keys,'*')
      nobj(keys(i))=update_scs_m(obj(keys(i)));
    end
   case 'l' then
    // Object is a list just map the function
    nobj = map(obj,update_scs_m);
  else
    nobj=obj;
  end
endfunction;
