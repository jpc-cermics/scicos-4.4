function [flag_type,rdnom,DF_type,Code]=translate(CI,CI1,CLa_type,CLa_exp,CLb_type,CLb_exp,oper,..
						  type_meth,degre,a,b,N,a1,b1,a2,b2,a3,b3,a4,b4,a5,b5,a6,b6,a7,b7,nom,mesures)

  // Copyright INRIA
  // Spatial discretization algorithms and code generation for the block 
  // out: 
  // flag_type: type of generated equations (1 for explicit, 2 implicit).
  // rdnom (String): name of the block with "_explicite" or "_implicite"
  //     suffix added.
  // DF_type (Entier): 0 for centred finite differences, 1 for left
  //     decented, 2 for right decentred.
  // Code (String): string vector containing the generated code.
  // Entr�es:                                                                                       
  // CI, CI1(String): expressions des conditions initiales resp u(t0,x) et du/dt|t=0          
  // CLa_type, CLb_type(entiers): types des conditions aux limites (0 : Dirichlet, 1 : Neumann)
  // CLb_exp, CLa_exp (String):  expressions des conditions aux limites resp en a et en b      
  // oper (vecteur des entiers): code les op�rateurs selectionnes de 1 � 7                     
  // type_meth (entier): type de la methode de discretisation (type_meth=1 : DF, 2 : EF, 3 : VF)
  // degre (entier): le degre de la methode de discretisation)                                  
  // a, b (doubles): correspondant resp aux valeurs des bords du domaine a et b                 
  // N (entier): nombre de noeuds ave les noeuds aux limmites                                   
  // ai, bi (String): avec i=1:7 : expressions des coefficients des differents operateurs       
  // nom (String): correspond au nom du bloc a generer choisis par l'utilisateur dans la fen�tre
  //      SCILAB "GIVE US BLOCK's NAME"                                                               
  // mesures (vecteur des doubles) : renvoi la liste des points de mesures                       
  //--------------------------------------------------------------------------------------------------

  function [eq_pts_mes]=eval_pts_df(a,h,N,mesures)     
  // Copyright INRIA
  // d�velopp� par EADS-CCR
  // Cette fonction renvoie les equations de sorties correspondent aux        
  // points de mesures en approchant leus solution au noeud le plus poche     
  // sortie :                                                                 
  //    - eq_pts_mes (String) : vecteur des �quations de sorties choisit      
  // entrees :                                                                
  //    - a (Double) : limite inf�rieur du domaine [a b]                      
  //    - h (Double) : est le pas de discretisation h=(b-a)/N (i.e x(i)= i* h)
  //    - N (Entier) : est le nombre de noeuds                                
  //    - mesures (Double) : vecteur des abcaisses des points de mesures      
    u = 'x['+string((1:N)'-1)+']';
    nmes=size(mesures,'*');
    eq_pts_mes=emptystr(nmes,1);
    for npt=1:nmes
      // num�ro d'element auquel npt appartient  
      nel=int((mesures(npt)-a)/h)+1;
      if (mesures(npt)-(a+h*(nel-1)) <= (a+h*nel)-mesures(npt)) then
	l=nel;
      else
	l=nel+1;
      end
      eq_pts_mes(npt) = u(l);
    end

  endfunction

  function [eq_pts_mes]=eval_pts_EF(a,b,nelem,kind,nint,nodes,x,xi,w,N,mesures)     
  // Copyright INRIA
  // d�velopp� par EADS-CCR
  // Cette fonction renvoie les equations de sorties correspondent aux        //
  // points de mesures en utilisant l'interpolation en polynomme de Lagranges //
  // sortie :                                                                 //
  //    - eq_pts_mes (String) : vecteur des �quations de sorties choisit      //
  // entrees :                                                                //
  //    - a, b (Doubles) : limites du domaine [a b]                           //
  //    - nelem (Entier) : le nombre d'element.                               // 
  //    - kind(i) (Entier) : ordre des fonctions de test                      //
  //    - ninit(i) (Entier) :ordre d'integration Gaussian                     //
  //    - x (Double):  vecteur des cordonn�es des points nodales              //
  //    - xi, w (Doubles) : les points Gausse et leurs poids obtenu           //
  //      de setint()                                                         //
  //    - N (Entier) : est le nombre de noeuds                                //
  //    - mesures (Double) : vecteur des abcaisses des points de mesures      //
    u = 'x['+string((1:N)'-1)+']';
    h=(b-a)/nelem;
    nmes=size(mesures,'*');
    eq_pts_mes=emptystr(nmes,1);
    for npt=1:nmes
      // num�ro d'element auquel npt appartient  
      nel=int((mesures(npt)-a)/h)+1;
      //dernier point de mesure = b ou a =b-%eps
      if (nel > nelem) then, nel=nelem; end 
      // changement de coordon�es dans xi
      n = kind(nel) + 1;
      i1 = nodes(1,nel);
      i2 = nodes(n,nel);
      x1=x(i1); x2=x(i2); 
      dx = (x2-x1)/2;
      xx=(mesures(npt)-x1)/dx-1;
      [psi,dpsi]=shape(xx,n);
      uh='';
      for l=1:n
	l1=nodes(l,nel);
	uh=addf(uh,mulf(msprintfv(psi(l)),u(l1)));
      end
      eq_pts_mes(npt) = uh;
    end
  endfunction

  function [eq_pts_mes]=eval_pts_vf(a,h,N,mesures)     
  // Copyright INRIA
  // d�velopp� par EADS-CCR
  // Cette fonction renvoie les equations de sorties correspondent aux        //
  // points de mesures en approchant leus solution par la moyenne             //
  // sortie :                                                                 //
  //    - eq_pts_mes (String) : vecteur des �quations de sorties choisit      //
  // entrees :                                                                //
  //    - a (Double) : limite inf�rieur du domaine [a b]                      //
  //    - h (Double) : est le pas de discretisation h=(b-a)/N (i.e x(i)= i* h)//
  //    - N (Entier) : est le nombre de noeuds                                //
  //    - mesures (Double) : vecteur des abcaisses des points de mesures      //
    u = 'x['+string((1:N)'-1)+']';
    nmes=size(mesures,'*');
    eq_pts_mes=emptystr(nmes,1);
    for npt=1:nmes
      // num�ro d'element auquel npt appartient  
      nel=int((mesures(npt)-a)/h)+1;
      if (mesures(npt)-(a+h*(nel-1)) <= (a+h*nel)-mesures(npt)) then
	l=nel;
      else
	l=nel+1;
      end
      eq_pts_mes(npt) = u(l);
    end
  endfunction
  
  function [xc,x]=unimesh1D(N,a,b)
  // Copyright INRIA
  // developed by EADS-CCR
  // grid for 1D finite volume including limit nodes 
  // sorties :                                                   
  // x (Double) : vecteur colonne representant les noeuds   
  // xc (Double) : vecteur colonne representant les cellules
  //    (les volumes de contr�le).                             
  // N (Entier) : est le nombre de noeuds                   
  // a, b (Doubles) :correspondent aux deux points limites  
    deltax=(b-a)/(N-1);
    dx2=deltax/2;
    x=(a:deltax:b)';
    xc=[a-dx2;(dx2:deltax:b)';b+dx2];
  endfunction

  function [A,B1,B2,C1,C2,C3,F3]=coef_FEM1d(oper,nelem,kind,nint,nodes,x,xi,w,..
					  nnode,a1,b1,a2,b2,a3,b3,a4,b4,a5,b5,a6,b6,a7,b7,kbc,vbc)
  // Copyright INRIA
  // d�velopp� par EADS-CCR
  // Cette fonction renvoie les matrices d'assemblage                       //
  // sorties :                                                              //
  //    - Ai, Bi (Doubles) : matrices d'assemblage A, B (B1 (oper 3) et     //
  //      B2(oper 4), C (C1 pour oper 2, C2 pour oper 5 et C3 pour oper 6)  //
  //      et F3 pour oper 7) pour le syst�me: A*d2u/dt2 + B*du/dt + C*u = F // 
  //      (diff�rentiels 1 ou alg�brique -1)                                //       
  // entr�es :                                                              //
  //    - oper (Entier) : vecteur des op�rateurs selectionnes de 1 � 7      //  
  //    - nelem (Entier) = (nnode-1)/inf_ele; c'est le nombre d'�l�ment.    //
  //    - kind(i) (Entier), i=1, ..., nelem, = 1, ou 2, ou 3. les fonctions //
  //      de base dans le i-eme element. Pour la triangulation uniforme,    //
  //      kind(i) = inf_ele.                                                //
  //    - nint(i) (Entier), i=1, ..., nelem = 1, ou 2, ou 3, ou 4. Pour     //
  //      l'ordre du Gaussian quadratique dans le i-eme element.            //
  //    - nodes(j,i) (Entier): Matrice de connection des element,           //
  //    - x (Double):  vecteur des cordonn�es des points nodales            //
  //    - xi, w (Doubles) : les points Gausse et leurs poids obtenu         //
  //      de setint()                                                       //
  //    - N (Entier) : est le nombre de noeuds                              //
  //    - nnode (Entier) : nombre de noeuds.                                //
  //    - ai, bi (String) : les differents coeficients des op�rateurs       //
  //      (ai(x) et bi(t))                                                  //
  //    - kbc (Entier) : vecteur types des conditions au limites            //
  //    - vbc (String) : vecteur des conditions aux limites en a et b       //
  //------------------------------------------------------------------------//  

  A=[];B1=[];B2=[];C1=[];C2=[];C3=[];F3=[];
  
  for i=1:size(oper,'*')
    select oper(i)
     case 1 then      
      [A,gf]=formkf(nelem,kind,nint,nodes,x,xi,w,nnode,a1,oper(i),kbc,vbc);
     case 3 then
      [B1,gf]=formkf(nelem,kind,nint,nodes,x,xi,w,nnode,a3,oper(i),kbc,vbc);
     case 4 then
      [B2,gf]=formkf(nelem,kind,nint,nodes,x,xi,w,nnode,a4,oper(i),kbc,vbc);
     case 2 then
      [C1,gf]=formkf(nelem,kind,nint,nodes,x,xi,w,nnode,a2,oper(i),kbc,vbc);
     case 5 then
      [C2,gf]=formkf(nelem,kind,nint,nodes,x,xi,w,nnode,a5,oper(i),kbc,vbc);
     case 6 then
      [C3,gf]=formkf(nelem,kind,nint,nodes,x,xi,w,nnode,a6,oper(i),kbc,vbc);
     case 7 then
      [gk,F3]=formkf(nelem,kind,nint,nodes,x,xi,w,nnode,a7,oper(i),kbc,vbc);
    end  
  end
endfunction


  
  // now the main code 
  // ----------------
  
  DF_type=[];
  // fonction principale
  
  // Conditions aux limites
  // kbc est le vecteur type
  kbc=[CLa_type;CLb_type];
  // vbc est le vecteur des valeurs
  vbc=[CLa_exp;CLb_exp];
  
  //h=(b_domaine-a_domaine)/Nbr_maillage; 
  vh=linspace(a,b,N);
  h=vh(2)-vh(1);
  eq_pts_mes=[];
  Nfictif=N;
  // FEM 
  timer();
  if (type_meth == 2) then
    //dans les �l�ments finis on g�n�re de l'implicite
    flag_type=2; // 1 pour les syst�mes explicites, 2 pour l'implicite
    
    nnode=N;
    [xi,w] = setint(); // Get Gaussian points and weights.

    [x,nelem,nodes,kind,nint]=maillage_FE1D(a,b,degre,nnode,..
					    CLa_type,CLa_exp,CLb_type,CLb_exp); //maillage

    // calcul de A,B,C et F
    [A,B1,B2,C1,C2,C3,F3]=coef_FEM1d(oper,nelem,kind,nint,nodes,x,xi,w,..
				     nnode,a1,b1,a2,b2,a3,b3,a4,b4,a5,b5,a6,b6,a7,b7,kbc,vbc);  
    
    // intepolation de la solution aux points de mesures par le polynomme de Lagrange
    [eq_pts_mes]=eval_pts_EF(a,b,nelem,kind,nint,nodes,x,xi,w,nnode,mesures);
    
    // g�n�ration des �quations
    
    [equations,impl_type]=gen_code_FEM(A,B1,B2,C1,C2,C3,F3,oper,N,a,b,..
				       b1,b2,b3,b4,b5,b6,b7,vbc,kbc);
    printf('Le temps de discr�tisation par �l�ments finis est '+string(timer())+'s\n');
    // FDM
  elseif (type_meth == 1) then
    //dans les diff�rences finies on g�n�re de l'implicite
    flag_type=2; // 1 : explicie, 2 : implicite
    
    //centr� ou decentr� qui viendera du syst�me expert apres
    if (degre == 2) then
      DF_type=0; //centr� 
    elseif (degre == 1)
      DF_type=1; //decentr� 
    end

    // intercalage de la solution aux points de mesures aux points les plus proches
    [eq_pts_mes]=eval_pts_df(a,h,N,mesures);
    
    // g�n�ration des �quations
    [equations,impl_type,Nfictif]=gen_code_FDM(a1,b1,a2,b2,a3,b3,a4,b4,..
					       a5,b5,a6,b6,a7,b7,a,b,N,oper,vbc,kbc,DF_type,h)
    printf('Le temps de discr�tisation par diff�rences finies est '+string(timer())+'s\n');
    // FVM
  else 
    // maillage
    [xc,xn]=unimesh1D(N,a,b);
    
    // intercalage de la solution aux points de mesures aux points les plus proches
    [eq_pts_mes]=eval_pts_vf(a,h,N,mesures);
    
    // g�n�ration des �quations

    [equations,flag_type,impl_type]=gen_code_FVM(a1,b1,a2,b2,a3,b3,a4,b4,a5,b5,a6,b6,..
						 a7,b7,N,oper,vbc,xn,xc);
    printf('Le temps de discr�tisation par volumes finis est '+string(timer())+'s\n');
  end
  // Assemblage de code
  if (flag_type == 1) then
    rdnom = nom+'_explicite';
  else
    rdnom = nom+'_implicite';
  end
  
  Code=code_generation(rdnom,equations,eq_pts_mes,flag_type,h,CI,CI1,a,Nfictif,N,impl_type,type_meth,oper);
  printf('Le temps de la g�n�ration, compilation et linkage du code est '+string(timer())+'s\n');

endfunction

