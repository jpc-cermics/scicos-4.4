function nobj = update_scs_m(obj)
// updates scicos obj by recalling all the scicos_xx functions
// where they can be called. This function can be called on any 
// scicos objects i.e a diagram or a model or a block ...
// 
// jpc 2011 
//
  H=hash(3, codegeneration='codegen',Block='block',Link='link',Text='text');
  typ = type(obj,'short');
  select typ 
   case 'h' then 
    // Object is a hash table 
    if obj.iskey['type'] && type(obj.type,'short')== 's' then 
      typ=obj.type;
      // if typ is in H then use H value instead.
      if H.iskey[typ] then typ=H(typ);end 
      // check if a function exists
      fun=sprintf('scicos_%s',typ);
      if exists(fun,'nsp-function') then 
	execstr(sprintf('nobj= scicos_%s();',typ));
      else
	nobj= hash(length(obj));
      end
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
    //keys=setdiff(keys,['type','tlist','mlist']);
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
