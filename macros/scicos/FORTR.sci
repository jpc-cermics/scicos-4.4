function [ok,tt]=FORTR(funam,tt,inp,out)
//
  ok=%t;
  ni=size(inp,'*')
  no=size(out,'*')
  if isempty(tt) then
    ud=catenate(sprintf('u%d,nu%d',(1:ni)',(1:ni)'),sep=',');
    u1d=catenate(sprintf('u%d(*)',(1:ni)'),sep=',');
    yd=catenate(sprintf('y%d,ny%d',(1:no)',(1:no)'),sep=',');
    y1d=catenate(sprintf('y%d(*)',(1:no)'),sep=',');
    
    textmp=['      subroutine '+funam+'(flag,nevprt,t,xd,x,nx,z,nz,tvec,';
	    '     $        ntvec,rpar,nrpar,ipar,nipar,';
	    '     $        ' + ud + ',';
	    '     $        ' + yd + ')'
	    '      double precision t,xd(*),x(*),z(*),tvec(*)';
	    '      integer flag,nevprt,nx,nz,ntvec,nrpar,ipar(*)';
	    '      double precision rpar(*)';
	    '      double precision '+ u1d;
	    '      double precision '+ y1d;
	    'c      ';
	    ''
	    ''
	    'c      ';
	    '      end'];
  else
    textmp=tt;
  end
  cm=catenate(['Function definition in fortran';
	       'Here is a skeleton of the functions which you should edit'],sep='\n');
  non_interactive = exists('getvalue') && getvalue.get_fname[]== 'setvalue';
  
  while %t
    // edit the code 
    [txt]=scicos_editsmat('Edit fortran function',textmp,comment=cm);
    if isempty(txt) then return;end // abort in gui
    [ok]=scicos_block_link(funam,txt,'f');
    if ~ok then
      if non_interactive then 
	// even if link failed we have to quit not to enter infinite
        // loop.
	message(['Error: failed for link in FORTR but we are in a non ";
		 '  interactive function and thus we abort the set !']);
	return;
      end
      textmp=txt;
      continue;
    else
      break;
    end
  end
  ok=%t;tt=txt;  
endfunction
