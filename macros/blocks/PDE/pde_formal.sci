function y=pde_formal()
  y='formal'
endfunction

function x=mulfstring(a,b)
// Copyright INRIA
// développé par EADS-CCR
// multiply two matrices 
// 
  if isempty(a) | isempty(b) then
     x=m2s([]);
     return;
  end
  [l,m]=size(a);[m,n]=size(b);x=[];
  for j=1:n,
    y=[];
    for i=1:l,
      t=' ';
      for k=1:m,
        if (k > 1) then
          t=addfv(t,mulfv(a(i,k),b(k,j)));
        else
          t=mulfv(a(i,k),b(k,j));
        end
      end
      y=[y;t];
    end
    x=[x y];
  end
endfunction

function vect=mulf_string(M,vec)
// Copyright INRIA
// développé par EADS-CCR
// fonction pour la multiplication matrice     //
// (string) * vecteur(string)                  //
// sortie :                                    //
//    - vect (String) : Vecteur de taille de M //
// entrées :                                   //
//    - M (String) : Matrice                   //
//    - N (String) : Vecteur                   //
//---------------------------------------------//
  vect=m2s([]);
  N=size(vec,'*');
  for i=1:N
    line=m2s([]);
    for j=1:N
      line=[line,mulf(M(i,j),vec(j))];
    end
    som='';
    for i=1:N
      som=addf(som,line(i));
    end
    vect=[vect;som];
  end
endfunction

function x=mulfv(x1,x2)
// Copyright INRIA
// développé par EADS-CCR
  if (isempty(x1) | isempty(x2) | x1 == '' | x2 == '') then
    x='0';
  else
    x=mulf(x1,x2);
  end
endfunction

function x=mulf3(x1,x2,x3)
// Copyright INRIA
// développé par EADS-CCR
// mulf avec 3 entrée : x=mulf(x1,x2,x3)
  xx=mulf(x1,x2);
  x=mulf(xx,x3);
endfunction

function x=mulf3v(x1,x2,x3)
// Copyright INRIA
// développé par EADS-CCR
  if isempty(x1) | isempty(x2) | isempty(x3) then
    x='0';
  else
    x=mulf3(x1,x2,x3);
  end
endfunction

if %f then 
  // small test 
  namea='a'+string(1:4);
  nameb='b'+string(1:4);
  A=namea;A.redim[2,2];
  B=nameb;B.redim[2,2];
  H=hash(8);
  for i=1:4,
    H('a'+string(i))=rand(1,1);
    H('b'+string(i))=rand(1,1);
  end
  C=mulfstring(A,B);
  Ce=evstr(C,H);
  Ce1=evstr(A,H)*evstr(B,H);
  if norm(Ce-Ce1) > 1.e-6 then pause;end 
end

function vect=addf_mat(M,N)
// Copyright INRIA
// développé par EADS-CCR
// fonction pour l'addition ele/ele matrice    //
// (string) .+ matrice(string)                 //
// sortie :                                    //
//    - vect (String) : Matrice de taille de M //
// entrées :                                   //
//    - M (String) : Matrice                   //
//    - N (String) : Matrice                   //
//---------------------------------------------//
  if (isempty(N)) then
    vect=M;
    return;
  elseif (isempty(M)) then
    vect=N;
    return;
  end
  vect=M;
  [n,m]=size(M);
  for i=1:n
    for j=1:m
      vect(i,j)=addf(M(i,j),N(i,j));
    end
  end
endfunction

function str=addf(a,b)
// Il y a ici une grosse difficulté 
// Il faut pouvoir évaluer a et b 
// sans aller chercher dans les environement 
// appellant.
  
  an=a;bn=b;
  ea=evstr(a);
  if ~isempty(ea) then an= m2s(ea,'%15.9f");end 
  eb=evstr(b);
  if ~isempty(eb) then bn= m2s(eb,'%15.9f");end 
  if ea.equal[0] then str=bn;return;end
  if eb.equal[0] then str=an;return;end
  if ~validvar(an,id='NAME') && ~validvar(an,id='NUMBER') then 
    an='('+an+')';
  end
  if ~validvar(bn,id='NAME') && ~validvar(bn,id='NUMBER') then 
    bn='('+bn+')';
  end
  str=an+"+"+bn
  estr= evstr(str);
  if ~isempty(estr) && type(estr,"short')=='m' then 
    if estr == int(estr) then 
      str=string(estr);
    end
  end
endfunction

function x=addfv(x1,x2)
// Copyright INRIA
// développé par EADS-CCR
  if isempty(x1) then
    x=x2;
  elseif isempty(x2) then
    x=x1;
  else
    x=addf(x1,x2);
  end
endfunction

function str=mulf(a,b)
  ea=evstr(a);
  if ~isempty(ea) && ea.equal[1] then str=b;return;end
  if ~isempty(ea) && ea.equal[0] then str="0";return;end
  eb=evstr(b);
  if ~isempty(eb) && eb.equal[1] then str=a;return;end
  if ~isempty(eb) && eb.equal[0] then str="0";return;end
  str=a+"*"+b
  estr= evstr(str);
  if ~isempty(estr) && type(estr,"short')=='m' then 
    if estr == int(estr) then 
      str=string(estr);
    end
  end
endfunction

function str=subf(a,b)
  ea=evstr(a);
  if ~isempty(ea) && ea.equal[0] then str="(-"+b+")";return;end
  eb=evstr(b);
  if ~isempty(eb) && eb.equal[0] then str="a";return;end
  str=a+"-"+b
  estr= evstr(str);
  if ~isempty(estr) && type(estr,"short')=='m' then 
    if estr == int(estr) then 
      str=string(estr);
    end
  end
endfunction

function x=subfv(x1,x2)
// Copyright INRIA
// développé par EADS-CCR
  if isempty(x1) then
    x='-'+x2;
  elseif isempty(x2) then
    x=x1;
  else
    x=subf(x1,x2);
  end
endfunction



function str=rdivf(a,b)
  eb=evstr(b);
  if ~isempty(eb) && eb.equal[1] then str="a";return;end
  str=a+"/"+b
  estr= evstr(str);
  if ~isempty(estr) && type(estr,"short')=='m' then 
    if estr == int(estr) then 
      str=string(estr);
    end
  end
endfunction

function str=ldivf(a,b)
  ea=evstr(a);
  if ~isempty(ea) && ea.equal[1] then str="b";return;end
  str=a+"\"+b
  estr= evstr(str);
  if ~isempty(estr) && type(estr,"short')=='m' then 
    if estr == int(estr) then 
      str=string(estr);
    end
  end
endfunction

function vect=subf_mat(M,N)
// Copyright INRIA
// développé par EADS-CCR
// fonction pour la soustraction ele/ele matrice //
// (string) M .- N matrice(string)               //
// sortie :                                      //
//    - vect (String) : Matrice de taille de M   //
// entrées :                                     //
//    - M (String) : Matrice                     //
//    - N (String) : Matrice                     //
//-----------------------------------------------//
  if (isempty(N )) then
    vect=M;
    return;
  elseif (isempty(M)) then
    vect='-1'.*N; // undefined ? 
    return;
  end
  vect=M;
  [n,m]=size(M);
  for i=1:n
    for j=1:m
      vect(i,j)=subf(M(i,j),N(i,j));
    end
  end
endfunction

function y = multMatVect(M, x)
// Copyright INRIA
// développé par EADS-CCR
// Function that multiply a sparse nxp matrix of double by
// a nx1 vector of string, resulting in a px1 vector of string
// Input:
// - M a nxp sparse matrix of double
// - x a nx1 vector of string
// Ouput:
// - y a px1 vector of string

// Check the syntax
  if(argn(1) <> 1) then
    error('Usage: y = multMatVect(M, x)');
  end
  if isempty(M) then
    y=[];
    return;
  end
  // Check the dimensions
  [ij,v,mn_M]=spget(M);
  mn_x = size(x);
  if(mn_x(1) <> mn_M(2)) then
    error('Incompatible dimensions');
  end
  // Perform the multiplication
  y = emptystr(mn_M(1), 1);
  for n=1:length(v)
    y(ij(n, 1)) = addfv(y(ij(n, 1)) , mulfv(msprintfv(v(n)), x(ij(n, 2))));
  end
  if (y == '') then
    y=[];
  end
endfunction

function y = multVectStr(M, x)
// Copyright INRIA
// développé par EADS-CCR
// Function that multiply a sparse 1xn of double by
// a 1x1 string, resulting in a nx1 vector of string
// Input:
// - M a 1xn sparse vector of double
// - x a string
// Ouput:
// - y a nx1 vector of string

// Check the syntax
  if(argn(1) <> 1) then
    error('Usage: y = multMatVect(M, x)');
  end
  if isempty(M) then
    y=[];
    return;
  end
  // Check the dimensions
  [ij,v,mn_M]=spget(M);
  // Perform the multiplication
  y = emptystr(1, mn_M(2));
  for n=1:length(v)
    y(ij(n, 2)) = mulfv(msprintfv(v(n)) ,x);
  end
  if (y == '') then
    y=[];
  end
endfunction

