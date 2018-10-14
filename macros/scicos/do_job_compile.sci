function [bllsti,ok]=do_job_compile(o,bllsti,i)
 bllst_old=bllsti
 x=[]
 isok=execstr('bllsti=' + o.gui + '(""compile"",bllsti,i);' , errcatch=%t);
 if ~isok then 
   // ignore errors for some guis
   ignore = o.gui.equal['INPUTPORT'] || o.gui.equal['OUTPUTPORT'] ||...
	   o.gui.equal['INPUTPORTEVTS'] || o.gui.equal['OUTPUTPORTEVTS'];
   if ignore then  lasterror(); ok=%t;  return;  end
   // report error
   ok=%f,
   obj = scs_m(scs_full_path(corinv(i)));
   hilite_obj(obj);
   str = lasterror();str = str(1:$-4);
   message(["Compilation of block "+o.gui+" failed:";
	    catenate(str)]);
   unhilite_obj(obj);
   return;
 end
 // empty case  
 if isempty(bllsti) then 
   bllsti=bllst_old; ok=%t;
   return;
 end
 //##check input/output size/type
 if ~isequal(bllst_old.in,bllsti.in) |...
       ~isequal(bllst_old.in2,bllsti.in2) |...
       ~isequal(bllst_old.out,bllsti.out) |...
       ~isequal(bllst_old.out2,bllsti.out2) |...
       ~isequal(bllst_old.intyp,bllsti.intyp) |...
       ~isequal(bllst_old.outtyp,bllsti.outtyp) then
   obj =  scs_m(scs_full_path(corinv(i)));
   hilite_obj(obj);
   message(["Size or type of regular port(s) have changed";
	    "during job=compile. Compilation aborted."]);        
   unhilite_obj(obj);
   ok=%f;
 elseif ~isequal((isempty(bllst_old.state)&~isequal(bllst_old.blocktype,'x')),..
		 (isempty(bllsti.state)&~isequal(bllsti.blocktype,'x'))) |...
       ~isequal(bllst_old.nzcross==0,bllsti.nzcross==0) |...
       ~isequal(bllst_old.nmode==0,bllsti.nmode==0)|...
       ~isequal((size(bllst_old.dstate,"*")+size(bllst_old.odstate))==0,..
		(size(bllsti.dstate,"*")+size(bllsti.odstate))==0) then
   obj =  scs_m(scs_full_path(corinv(i)));
   hilite_obj(obj);
   message(["States, zero-crossing or modes have changed in job=compile.";
	    "Compilation aborted."]);        
   unhilite_obj(obj);
   ok=%f;
 else
   ok=%t
 end
endfunction
