function y=sci2exp(exp,nam)
// convert a matrix to a string 
// that can be parsed again (used in getvalue)
// 
// when exp is a vector it is assumed that 
// sci2exp must return a 1x1 value 
// 
// we have to take carte tha sprint can split the string 
// with continuation and this is not good for getvalue. 
//
// XXXX a sprint(.,as_read=%t) without line breaks 
//      should be usefull
  if (type(exp,'short')=='m' & size(exp,2)==1) then 
    y= sprint(exp,as_read=%t);
    y=y(2:$);
    y=strcat(stripblanks(y));
  elseif (type(exp,'short')=='m' & size(exp,1)==1) then 
    y=sprint(exp',as_read=%t);
    y=y(2:$);
    // transpose to avoid breaks
    y=strcat(stripblanks(y));
    y=strsubst(y,';',',');
  else
    y=sprint(exp,as_read=%t);
    // remove header
    y=y(2:$);
    if size(y,'*')==0 then y="[]";end 
  end
  if nargin>=2 && type(nam,'short')== 's' then 
    y(1) = nam +'='+y(1);
  end
endfunction

  
