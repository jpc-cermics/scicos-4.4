function y=sci2exp(exp,nam)
// convert a matrix to a string 
// that can be parsed again (used in getvalue)
// 
// when exp is a vector it is assumed that 
// sci2exp must return a 1x1 value 
// 
// we have to take care that sprint can split the string 
// with continuation and this is not good for getvalue. 
//
// XXXX a sprint(.,as_read=%t) without line breaks 
//      should be usefull
  if or(type(exp,'short')==['m','s']) && size(exp,'*')==1 then 
    // scalar 
    y= sprint(exp,as_read=%t);
    y=y(2:$);
    y=strsubst(y,'[','');
    y=strsubst(y,']','');
    y=stripblanks(y);
  elseif or(type(exp,'short')==['m','s']) && size(exp,'*')==0 then 
    // empty
    y= "[]";
  elseif or(type(exp,'short')==['m','s']) & size(exp,2)==1 then 
    // column vector 
    y= sprint(exp,as_read=%t);
    y=y(2:$);
    y=strcat(stripblanks(y));
  elseif or(type(exp,'short')==['m','s']) & size(exp,1)==1 then 
    // row vector 
    y=sprint(exp',as_read=%t);
    y=y(2:$);
    // transpose to avoid breaks
    y=strcat(stripblanks(y));
    y=strsubst(y,';',',');
  elseif type(exp,'short')=='l' then 
    y="";
    if length(exp) >= 1 then 
      y=sci2exp(exp(1));
      for i=2:length(exp) 
	y = y+ ','+ sci2exp(exp(i));
      end
    end
    y = 'list('+y+')';
  else
    // general case 
    y=sprint(exp,as_read=%t);
    // remove header
    y=y(2:$);
    // answer should be on one line 
    y=catenate(y);
    if size(y,'*')==0 then y="[]";end 
  end
  if nargin>=2 && type(nam,'short')== 's' then 
    y(1) = nam +'='+y(1);
  end
endfunction

  
