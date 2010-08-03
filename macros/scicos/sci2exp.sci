function y=sci2exp(exp,nam)
// convert a matrix to a string 
// that can be parsed again (used in getvalue)
// when exp is a vector it is assumed that 
// sci2exp must return a 1x1 value 
  flag = type(exp,'short')=='m' & size(exp,2)==1
  // when exp is a column vector we want to get 
  // result as a one line string 
  if flag then exp = exp';  end
  y=sprint(exp,as_read=%t);
  // remove header
  y=y(2:$);
  if size(y,'*')==0 then y="[]";end 
  if flag then ;  y=strsubst(y,',',';');end 
  if nargin>=2 && type(nam,'short')== 's' then 
    y(1) = nam +'='+y(1);
  end
endfunction

  
