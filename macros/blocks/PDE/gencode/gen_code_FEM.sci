function [equations,impl_type]=gen_code_FEM(A,B1,B2,C1,C2,C3,F3,oper,N,..
          a,b,b1,b2,b3,b4,b5,b6,b7,vbc,kbc)
  // Copyright INRIA
  // d�velopp� par EADS-CCR
  // Attention a2 et a4 sont obtenus par environement.
  // 
  // Cette fonction est pour la g�n�ration des �quations DAE du bloc       
  // sorties :                                                             
  //    - equations (String) : vecteur qui contient le code C des �quations
  //      d'etat (DAE)                                                     
  //    - impl_type (Entier) : indique si le type des �tats                
  //      (diff�rentiels 1 ou alg�brique -1)                                      
  // entr�es :                                                             
  //    - A,B1,B2,C1,C2,C3,F3,(sparse Doubles):
  //      matrices d'assemblage A, B (B1 (oper 3) et C2(oper 4), 
  //      C (C1 pour oper 2, C2 pour oper 5 et C3 pour oper 6)  
  //      et F3 pour oper 7) pour le syst�me: A*d2u/dt2 + B*du/dt + C*u = F 
  //    - oper (Entier) : vecteur contenant les op�rateurs selectionn�s de 1 � 7        
  //    - N (Entier) : est le nombre de noeuds                             
  //    - a, b (Double) : limites du domaine [a b]                         
  //    - ai, bi (String) : les differents coeficients des op�rateurs      
  //      (ai(x) et bi(t))                                                 
  //    - vbc (String) : vecteur des conditions aux limites en a et b      
  //    - kbc (Entier) : vecteur types des conditions au limites           
  //------------------------------------------------------------------------//  
  Cla2=[];Clb2=[];Cla4=[];Clb4=[];lambda=spzeros(N,N);
  impl_type=1; // 1 pour syst�me d'�tat, -1 pour le syst�me alg�brique 
  sep=[',','*','/'];
 
  // prise en compte des conditions aux limites par dualisation
  if (kbc(1) == 1) then
    x=a;
    if ~isempty(find(oper == 4)) then
      Cla4='-'+mulf3v(b4,msprintfv(evstr(a4)),'xd[0]');
    end
    if ~isempty(find(oper == 2)) then
      Cla2=mulf3v(msprintfv(evstr(a2)),b2,vbc(1));
    end
  end
  if (kbc(2) == 1) then
    x=b;
    if ~isempty(find(oper == 4)) then
      Clb4=mulf3v(b4,msprintfv(evstr(a4)),'xd['+string(N)+']');
    end
    if ~isempty (find(oper == 2)) then
      Clb2=mulf3v(msprintfv(evstr(a2)),b2,vbc(2));
    end
  end    
  //*******************************************************
  
  if ~isempty(find(oper == 1)) then
  // cas d2u/dt2 ==> implicite
    equations=emptystr(2*N,1);
    vec2='x['+string((1:2*N)'-1)+']';
    dvec2='xd['+string((1:2*N)'-1)+']';
    for i=1:N
      equations(i)='   res['+string(i-1)+']='+subf(vec2(i+N),dvec2(i))+';';
      if ~isempty(F3) then
	F=mulfv(msprintfv(F3(i)),b7);
      else
	F='0';
      end
      if (i == 1) then
        // prise en compte des conditions aux limites de type Dirichlet par dualisation en a 
        if (kbc(1) == 0) then 
          F=vbc(1);
          lambda(1,1)=1;
        else
          F=subfv(F,addfv(mulfv(Cla2,b2),mulfv(Cla4,b4)));
        end
      elseif (i == N) then
        // prise en compte des conditions aux limites de type Dirichlet par dualisation en b 
        if (kbc(2) == 0) then 
          F=vbc(2);
          lambda(N,N)=1;
        else
          F=subfv(F,addfv(mulfv(Clb2,b2),mulfv(Clb4,b4)));
        end
      end
      if isempty(B2) then B2i=sparse([]);else B2i=B2(i,:);end
      if isempty(B1) then B1i=sparse([]);else B1i=B1(i,:);end
      B=mulfstring(addf_mat(multVectStr(B1i,b3),multVectStr(-B2i, b4)),vec2(N+1:$));      
      if isempty(C2) then C2i=sparse([]);else C2i=C2(i,:);end
      if isempty(C1) then C1i=sparse([]);else C1i=C1(i,:);end
      if isempty(C3) then C3i=sparse([]);else C3i=C3(i,:);end
      C=mulfstring(addf_mat(multVectStr(-C1i,b2),addf_mat(addf_mat(multVectStr(C2i,b5),..
        multVectStr(C3i,b6)),msprintfv(full(lambda(i,:))')')),vec2(1:N));
      Ai=mulfstring(multVectStr(A(i,:),b1),dvec2(N+1:$));
      equations(i+N)='   res['+string(i+N-1)+']='+subfv(subfv(subfv(F,Ai),B),C)+';';
    end 
    
  elseif ~isempty( find(oper == 3)) | ~isempty(find(oper == 4)) then
    // cas du/dt (oper 3 ou 4) ==> implicite 
    equations=emptystr(N,1);
    vec2='x['+string((1:N)'-1)+']';
    dvec2='xd['+string((1:N)'-1)+']';
    for i=1:N
      if ~isempty(F3) then
	F=mulfv(msprintfv(F3(i)),b7);
      else
	F='0';
      end
      if (i == 1) then
        // prise en compte des conditions aux limites de type Dirichlet par dualisation en a 
        if (kbc(1) == 0) then 
          F=vbc(1);
          lambda(1,1)=1;
        else
          F=subfv(F,addfv(mulfv(Cla2,b2),mulfv(Cla4,b4)));
        end
      elseif (i == N) then
        // prise en compte des conditions aux limites de type Dirichlet par dualisation en b 
        if (kbc(2) == 0) then 
          F=vbc(2);
          lambda(N,N)=1;
        else
          F=subfv(F,addfv(mulfv(Clb2,b2),mulfv(Clb4,b4)));
        end
      end     
      if isempty(B2) then B2i=sparse([]);else B2i=B2(i,:);end
      if isempty(B1) then B1i=sparse([]);else B1i=B1(i,:);end
      B=mulfstring(addf_mat(multVectStr(B1i,b3),multVectStr(-B2i,b4)),dvec2(:));      
      if isempty(C2) then C2i=sparse([]);else C2i=C2(i,:);end
      if isempty(C1) then C1i=sparse([]);else C1i=C1(i,:);end
      if isempty(C3) then C3i=sparse([]);else C3i=C3(i,:);end
      C=mulfstring(addf_mat(multVectStr(-C1i,b2),addf_mat(addf_mat(multVectStr(C2i,b5),..
        multVectStr(C3i,b6)),msprintfv(full(lambda(i,:))')')),vec2(:));
        
      equations(i)='   res['+string(i-1)+']='+subfv(subfv(F,B),C)+';';
     end 
  else
    // cas alg�brique ==> implicite 
    impl_type=-1;
    equations=emptystr(N,1);
    vec2='x['+string((1:N)'-1)+']';
    
    for i=1:N
      if ~isempty(F3) then
	F=mulfv(msprintfv(F3(i)),b7);
      else
	F='0';
      end
      if (i == 1) then
        // prise en compte des conditions aux limites de type Dirichlet par dualisation en a 
        if (kbc(1) == 0) then 
          F=vbc(1);
          lambda(1,1)=1;
        else
          F=subfv(F,addfv(mulfv(Cla2,b2),mulfv(Cla4,b4)));
        end
      elseif (i == N) then
        // prise en compte des conditions aux limites de type Dirichlet par dualisation en b 
        if (kbc(2) == 0) then 
          F=vbc(2);
          lambda(N,N)=1;
        else
          F=subfv(F,addfv(mulfv(Clb2,b2),mulfv(Clb4,b4)));
        end
      end      
      if isempty(C2) then C2i=sparse([]);else C2i=C2(i,:);end
      if isempty(C1) then C1i=sparse([]);else C1i=C1(i,:);end
      if isempty(C3) then C3i=sparse([]);else C3i=C3(i,:);end
      C=mulfstring(addf_mat(multVectStr(-C1i,b2),addf_mat(addf_mat(multVectStr(C2i,b5),..
        multVectStr(C3i,b6)),msprintfv(full(lambda(i,:))')')),vec2(:));
      equations(i)='   res['+string(i-1)+']='+subfv(F,C)+';';
    end    
  end
endfunction


if %f then 
  F3=(1:4);
  A=int(100*sprand(4,4,0.9))./10; A=sparse(int(100*rand(4,4))/10);
  B1=int(100*sprand(4,4,0.9))./10;
  B2=int(100*sprand(4,4,0.9))./10;
  C1=int(100*sprand(4,4,0.9))./10;
  C2=int(100*sprand(4,4,0.9))./10;
  C3=int(100*sprand(4,4,0.9))./10;
  [equations,impl_type]=gen_code_FEM(A,B1,B2,C1,C2,C3,F3,[1:7],4,0,1,"un","deux","trois","quatre","cinq","six","sept",['poo','foo'],[0,0]);
end
