function [a_domaine,b_domaine,discr,signe,choix,type_meth,degre,Nbr_maillage,..
          CI,CI1,CLa_type,CLa_exp,CLb_type,CLb_exp,oper,a1,b1,a2,b2,a3,b3,a4,b4,a5,b5,..
          a6,b6,a7,b7,k,mesures,params_pde]=pde_set(params_pde) 
  // from params_pde (strings) to values using evstr and the context
  //    - a_domaine et b_domaine (Entiers) : sont les bords du domaine [a b]                            
  //    - discr (Entier) : renvoi le type du disciminant (0: consatnt ou 1: non constant)              
  //    - signe (Entier) : renvoi le signe du discriminant dans les cas non constant                   
  //              (1: positif, 2: négatif, 3: nul )                                                    
  //    - choix (Entier) : renvoi le choix entre le mode manuel et le mode automatique (systeme expert)
  //              (0 : Automatique, 1 : Manuel)                                                        
  //    - type_meth (Entier) : renvoi le type de la methode de discretisation dans le cas manuel       
  //                  (1 : differences finies, 2 : elements finis, 3 : volumes finis)                  
  //    - degre (Entier) : renvoi de l'ordre de la discritisation (1 ou 2 pour EF et DF, 1 pour VF)    
  //    - Nbr_maillage (Entier) : renvoi le nombre de points de maillage                               
  //    - CI et CI1 (String) : renvoient les expressions des conditions initiales                      
  //    - CLa_type, CLb_type (Entiers) : renvoient les types des conditions aux limittes               
  //                         resp en a et en b (0 : Dirichlet, 1 : Neumann)                            
  //    - CLa_exp, CLb_exp (String) : renvoient les expressions des conditions aux                     
  //                         limittes resp en a et en b                                                
  //    - oper (Entier) : vecteur codant les operateurs choisi ( 1 : d2u/dt2, 2 : d2u/dx2,             
  //             3 : du/dt, 4 : d2u/dtdx, 5 : du/dx, 6 : u, 7 : f)                                     
  //    - ai et bi (String) : renvoient les differents coeficients des operateurs (ai(x) et bi(t))     
  //    - k (Entier) : codant le nombre de ports d'entrees du bloc EDP                                 
  //    - mesures (vecteur des entiers) : renvoi la liste des points de
  //    mesures                        
  a_domaine=[];b_domaine=[];choix=0;signe=1;discr=0;type_meth=1;degre=1;Nbr_maillage=10;
  a1=[];b1=[];a2=[];b2=[];a3=[];b3=[];a4=[];b4=[];a5=[];b5=[];a6=[];b6=[];a7=[];b7=[];mesures=[]; 
  CI=[];CI1=[];CLa_type=[];CLa_exp=[];CLb_type=[];CLb_exp=[];oper=[];k=[];
  if ~exists('%scicos_context') then %scicos_context=hash(1);end 
  // mise a jour des differents informations de l'IHM 
  a_domaine = evstr(params_pde.a,%scicos_context);
  b_domaine = evstr(params_pde.b,%scicos_context);
  // Choix (0 : Automatique, 1 : Manuel)
  choix=evstr(params_pde.rad_manuel,%scicos_context);
  signe=evstr(params_pde.signe);
  discr= evstr(params_pde.discr_non_cst,%scicos_context);
  type_meth=evstr(params_pde.methode,%scicos_context);
  degre = evstr(params_pde.degre,%scicos_context);
  Nbr_maillage=evstr(params_pde.nnode,%scicos_context);
  execstr('a1=params_pde.a1'); execstr('b1=params_pde.b1');
  execstr('a2=params_pde.a2'); execstr('b2=params_pde.b2');
  execstr('a3=params_pde.a3'); execstr('b3=params_pde.b3');
  execstr('a4=params_pde.a4'); execstr('b4=params_pde.b4');
  execstr('a5=params_pde.a5'); execstr('b5=params_pde.b5');
  execstr('a6=params_pde.a6'); execstr('b6=params_pde.b6');
  execstr('a7=params_pde.a7'); execstr('b7=params_pde.b7');
  // XXXX 
  mesures = evstr(params_pde.points,%scicos_context);
  execstr('CI=params_pde.CI'); execstr('CI1=params_pde.dCI');
  CLa_type=evstr(params_pde.CLa,%scicos_context); execstr('CLa_exp=params_pde.CLa_exp'); 
  CLb_type=evstr(params_pde.CLb,%scicos_context); execstr('CLb_exp=params_pde.CLb_exp');
  k=0;
  for op=1:7 
    execstr(sprintf('v=params_pde.check_op%d == ''1'' ',op));
    if v then 
      oper=[oper;op];
      b = stripblanks(params_pde('b'+string(op)))
      if ( b == 'IN_EDP1(t)') then
	execstr(sprintf('b%d=''inptr[%d][0]''',op,k));
	k=k+1;
      end
    end
  end
  if (CLa_exp  == 'IN_CL1(t)') then
    CLa_exp ='inptr['+string(k)+'][0]';
    k=k+1;
  end 
  if (CLb_exp  == 'IN_CL2(t)') then
    CLb_exp ='inptr['+string(k)+'][0]';
    k=k+1;
  end 
endfunction

function params_pde = pde_getvalue(params_pde) 
  // boundaries 
  lb=list('matrix','Domain [a,b]',10,[params_pde.a,params_pde.b]);
  // method choice
  mc=evstr(params_pde.rad_manuel)+1;
  lc=list('combo','Method choice',mc,['Automatic','Manual']); 
  // method type 
  //                  (1 : differences finies, 2 : elements finis, 3 :
  //                  volumes finis)                  
  mt= evstr(params_pde.methode);
  lt=list('combo','Type',mt,['Finite Diff','Finite Elts']); 
  // degre (Entier) : renvoi de l'ordre de la discretisation 
  // (1 ou 2 pour EF et DF, 1 pour VF)    
  lde=list('matrix','Discretization order (1 or 2)',100,[params_pde.degre]);
  // number of nodes 
  ln=list('matrix','Number of nodes',100,[params_pde.nnode]);
  // discriminant type
  // 
  dt=evstr(params_pde.discr_non_cst)+1;
  ld=list('combo','Type of discriminant',dt,['Constant','Non constant']);
  // 
  // discriminant sign
  si=evstr(params_pde.signe);
  lsi = list('combo','Sign of discriminant',si,['Positive','Negative','Null']);
  // PDE expression 
  // params_pde.check_op1="0" ou "1" 
  // params_pde.a1 et  params_pde.b1;
  titg=['d2u/dt2','d2u/dx2','du/dt','d2u/dtdx','du/dx','u','t'];
  Ledp=list()
  for i=1:7
    tit=sprintf('term %s: a%d(x) and b%d(t)',titg(i),i,i)
    ai = params_pde(sprintf('a%d',i));
    bi = params_pde(sprintf('b%d',i));
    Ledp(i)=list('matrix',tit,100,[ai,bi]);
  end
  ledp=list('button','Enter Pde expression',0,Ledp); 
  // boundary condition 
  // Conditions aux limites 
  cia= evstr(params_pde.CLa)+1;
  cib= evstr(params_pde.CLb)+1;
  Lbound=list()
  Lbound(1)=list('combo','boundary condition in a',cia,['Dirichlet','Neumann']); 
  Lbound(2)=list('entry','expression in a',1,[params_pde.CLa_exp]); 
  Lbound(3)=list('combo','boundary condition in b',cib,['Dirichlet','Neumann']); 
  Lbound(4)=list('entry','expression in b',1,[params_pde.CLb_exp]); 
  lbound=list('button','Enter boundary conditions',0,Lbound); 
  //
  li1=list('entry','Initial condition u(x,t0)',1,[params_pde.CI]); 
  //
  li2=list('entry','Initial condition du/dt(x,t0)',1,[params_pde.dCI]); 
  //
  liord=list('matrix','Scheduling',100,[  params_pde.ord1, params_pde.ord2, params_pde.ord3]);
  // 
  L=list(lb,lc,lt,lde,ln,ld,lsi,ledp,lbound,li1,li2,liord); 
  // interactive choice 
  [Lres,L]=x_choices('Toggle Menu',L,%t);

  if isempty(Lres) then params_pde=Lres;return;end // abort in gui.
  // fill back 
  // boundaries 
  params_pde.a=Lres(1)(1);
  params_pde.b=Lres(1)(2);
  // method choice
  v=['0','1'];w=['1','0'];
  params_pde.rad_manuel= v(Lres(2));
  params_pde.rad_automatique= w(Lres(2));
  // method type 
  // (1 : differences finies, 2 : elements finis, 3 : volumes finis)
  params_pde.methode=string(Lres(3));
  // degre 
  params_pde.degre=string(Lres(4));
  // number of nodes 
  params_pde.nnode=Lres(5);
  // discriminant type
  v=['0','1'];w=['1','0'];
  params_pde.discr_cst= w(Lres(6));
  params_pde.discr_non_cst=v(Lres(6));
  // discriminant sign
  v=['0','1','2'];
  params_pde.signe=v(Lres(7));
  // PDE expression 
  // params_pde.check_op1="0" ou "1" 
  // params_pde.a1 et  params_pde.b1;
  Le=Lres(8);
  v=['0','1'];
  for i=1:7
    co = stripblanks(Le(i)(1));
    co = b2m(co.equal['']);
    params_pde(sprintf('a%d',i))= Le(i)(1);
    params_pde(sprintf('b%d',i))= Le(i)(2);
    params_pde(sprintf('check_op%d',i))= v(co+1);
  end
  // boundary condition 
  // Conditions aux limites 
  Le=Lres(9);
  v=['0','1'];
  params_pde.CLa=v(Le(1));
  params_pde.CLb=v(Le(3));
  params_pde.CLa_exp=Le(2);
  params_pde.CLb_exp=Le(4);
  //
  params_pde.CI=Lres(10);
  //
  params_pde.dCI=Lres(11);
  //
  params_pde.ord1=Lres(12)(1);
  params_pde.ord2=Lres(12)(2);
  params_pde.ord3=Lres(12)(3);
    
endfunction

function ok=pde_validate(params_pde)
// verification du domaine
  ok=%f;
  if params_pde.a.equal[''] || params_pde.b.equal['']
    x_message('Domain boundaries are missing');
    return;
  end
  if params_pde.rad_manuel.equal['1'] then 
    if params_pde.nnode.equal[''] then 
      x_message(['Give the number of discretization points']);
      return;
    end
  end
  // verification du renseignement des conditions intiales
  if params_pde.check_op1=='1' || params_pde.check_op3=='1' || ...
	params_pde.check_op4=='1' then 
    if params_pde.CI.equal[''] then 
      x_message(['Please give the initial condition u(x,t0)']); 
      return
    end
  end
  if params_pde.check_op1=='1' then 
    if params_pde.dCI.equal[''] then 
      x_message(['Please give the initial condition du/dt(x,t0)']);
      return;
    end
  end
  // verification du renseignement des conditions aux limites
  if (params_pde.CLa_exp.equal[''] ||   params_pde.CLb_exp.equal['']) then
    x_message(['Please give expressions for the boundary conditions']);
  end
  ok=%t;
endfunction
