function [params,ok]=GetLitParam(str,flg)
 // flg=%t when the function is called by FindSBParams
 if nargin <= 1 then flg=%f;end
 ok=%t;
 // we search here the parameters called in function 
 execstr(['function get_lit_param();';str(:);'endfunction']);
 xx=macrovar(get_lit_param);
 params=xx.called;
 if flg then
   // check that we are not using exec or load 
   excl= ['exec','load'];
   tag = xx.funs.iskey[excl];
   if or(tag) then 
     I=find(tag);
     mes = excl(I(1));
     message(['The context of a masked or atomic subsystem';
	      'cannot contains the function ""'+mes+'""']);
     ok = %f;
     return;
   end
 end
 // delete from params symbols starting with %
 p = params.__keys;
 pos=strstr(p,'%')
 ex = p(find(pos == 1))
 params.delete[ex];
 params = params.__keys;
endfunction
