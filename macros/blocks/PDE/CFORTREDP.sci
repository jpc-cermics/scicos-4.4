function [ok]=CFORTREDP(funam,tt)
// Copyright INRIA
// d�velopp� par EADS-CCR
// cette fonction est pour la complation et 
// le link dynamique du bloc EDP avec Scilab
// voir CFORTR2.sci pour le bloc Scicos c_block2 
 if ~isempty(tt) then
   [ok]=scicos_block_link(funam,tt,'c');
 else
   ok=%f;break;
 end  
endfunction
