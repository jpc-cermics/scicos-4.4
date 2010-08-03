function res = tabule(tab)
// All the strings in the same column are changed 
// so as to be of the same length (white padding on left). 
// string of type '-' are to be expanded. 
// Then the columns of tab are concatenated with separator '|' 
// FIXME: this option shoul dbe added to catenate 
  [n_lignes, n_colonnes] = size(tab)
  res = smat_create(n_lignes,1,val="|");
  for i = 1 : n_colonnes
    largeur = max(length(tab(:, i)))
    col = sprintf('%*s',largeur*ones_new(n_lignes,1),tab(:,i));
    col=strsubst(col,sprintf('%*s',largeur,'-'),catenate(smat_create(largeur,1,val='-')));
    res = res + col + "|";
  end
endfunction


