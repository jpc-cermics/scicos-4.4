function M=scicos_get_in_indices(varargin)
  M=zeros(0,2);
  for i=1:length(varargin)
    val = varagin(i);
    if size(val,'*') == 1 then 
      if val == -1 then val = [-2*i+1,-2*i];
      else
	val = [val,1];
      end
    elseif size(val,'*') > 2 then 
      val = [-2*i+1,-2*i];
      printf("Warning: input port %d has dimension %d > 2 which is unsupported\n",i,size(val,'*'));
    end
    M(i,:)=val;
  end
endfunction

function M=scicos_get_out_indices(varargin)
  M=zeros(0,2);
  for i=1:length(varargin)
    val = varagin(i);
    if size(val,'*') == 1 then 
      if val == -1 then val = -100 + [-2*i+1,-2*i];
      else
	val = [val,1];
      end
    elseif size(val,'*') > 2 then 
      val = -100 +  [-2*i+1,-2*i];
      printf("Warning: output port %d has dimension %d > 2 which is unsupported\n",i,size(val,'*'));
    end
    M(i,:)=val;
  end
endfunction
