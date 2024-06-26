function [x,y,typ]=PDE(job,arg1,arg2)
// Copyright INRIA
// code developed by EADS-CCR
// Reference: "Scicos user guid", http://www.scicos.org     

  x=[];y=[];typ=[]; 
  select job
   case 'plot' then
    if arg1.model.sim(2)==2004 then 
      CCC=[strsubst(arg1.model.sim(1),'_explicite','');'Explicite']
    elseif arg1.model.sim(2)==12004
      CCC=[strsubst(arg1.model.sim(1),'_implicite','');'implicite']
    else
      CCC='  PDE'
    end
    standard_draw(arg1)
   case 'getinputs' then
    [x,y,typ]=standard_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=standard_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;  
    graphics=arg1.graphics;label=graphics.exprs;
    model=arg1.model;  
    params_pde=label(1);
    
    non_interactive = scicos_non_interactive();
    
    while %t do
      if ~non_interactive then 
	params_pde = pde_getvalue(params_pde);
	if isempty(params_pde) then ok=%f; return;end // abort selected in GUI.
      end
      if ~pde_validate(params_pde) then
	if non_interactive then 
	  message(['Error: set failed for PDE but we are in a non ";
		   '  interactive function and thus we abort the set !']);
	  return;
	else
	  continue;
	end
      end
      break;
    end
    [a_domaine,b_domaine,discr,signe,choix,type_meth,degre,Nbr_maillage,..
     CI,CI1,CLa_type,CLa_exp,CLb_type,CLb_exp,oper,a1,b1,a2,b2,a3,b3,a4,b4,a5,b5,..
     a6,b6,a7,b7,k,mesures,params_pde]=pde_set(params_pde);
    // Get the name of the file
    rdnom='PDE';
    if non_interactive then 
      rdnom=label(3);
      if rdnom==emptystr() then rdnom='pde';end
    else
      while %t do
	[ok,rdnom,lab]=getvalue('Please give the block''s name.',...
				'New block''s name :',list('str',1),label(3));
	if ~ok then return;end// cancel in menu 
	rdnom=stripblanks(rdnom);
	if rdnom.equal[''] then 
	  message('Blocks name should not be an empty string');
	  continue;
	else
	  break;
	end
      end
      label(3)=lab;
    end
    // arbre de decision
    if (choix == 0) then
      // Choix automatique 
      ind4=strindex(a4,'x');
      ind1=strindex(a1,'x');
      ind2=strindex(a2,'x');
      if (~isempty(ind4) | ~isempty(ind1) |~isempty(ind2)) then 
	if (signe == 1) then,
	  delta=1;
	elseif (signe == 2) then,
	  delta=-1;
	elseif (signe == 0) then,
	  delta=0;
	else
	  message(['Dicriminant is not constant';
		     'You must select a sign in gui']);
	  return;
	end
      else
	delta=evstr(a4)^2-4*evstr(a1)*evstr(a2);
      end
      if (isempty(delta)) then, delta=0; end        
      if delta > 0 then	type_meth = 1;
      elseif delta < 0 then type_meth = 3;
      else 
	type_meth = 2;
      end
    end
    // a voir si c'est � rajouter pour ne pas regenerer dans le cas d'eval
    //if ~ok then
    [flag_type,rdnom,DF_type,tt]=translate(CI,CI1,CLa_type,CLa_exp,CLb_type,CLb_exp,...
					   oper,type_meth,degre,a_domaine,..
					   b_domaine,Nbr_maillage,a1,b1,a2,b2,a3,...
					   b3,a4,b4,a5,b5,a6,b6,a7,b7,rdnom,mesures);
    // augmentation du systeme avec les noeuds fictifs
    Nbr=Nbr_maillage;
    if ((CLa_type == 1) & (DF_type == 0 | DF_type == 1)) || ...
	  ((CLb_type == 1) & (DF_type == 0 | DF_type == 2)) then
      Nbr=Nbr+1;
    end 
    if ( isempty(mesures )) then
      out=Nbr_maillage;
    else
      out=[Nbr_maillage;size(mesures,'*')];
    end
    if (flag_type == 1) then 
      // explicite
      model.sim=list(rdnom,2004);
      if ~isempty(find(oper == 1)) then
	model.state=zeros(2*Nbr_maillage,1);  
      else
	model.state=zeros(Nbr_maillage,1);
      end
    elseif (flag_type == 2) then 
      model.sim=list(rdnom,12004);
      if ~isempty(find(oper == 1)) then
	if (type_meth ==3 & ( ~isempty(find(oper == 2)) | ~isempty(find(oper == 4)))) then
	  model.state=zeros(6*Nbr_maillage,1);
	elseif (type_meth == 1) then
	  model.state=zeros(4*Nbr,1);
	else 
	  model.state=zeros(4*Nbr_maillage,1);
	end
      else
	if (type_meth == 3 & (~isempty(find(oper == 2)) | ~isempty(find(oper == 4)))) then
	  model.state=zeros(4*Nbr_maillage,1);
	elseif (type_meth == 1) then
	  model.state=zeros(2*Nbr,1);
	else
	  model.state=zeros(2*Nbr_maillage,1);
	end
      end
    end
    // compile and link the code
    if ~isempty(tt) then
      [ok]=scicos_block_link(rdnom,tt,'c');
    else
      ok=%f;
    end  
    if ~ok then return;end
    //end
    [model,graphics,ok]=check_io(model,graphics,ones(k,1),out(:),[],[])
    if ~ok then return;end
    label(1)=params_pde;
    label(2)=tt;
    graphics.exprs=label;
    x.graphics=graphics;
    x.model=model;
   case 'define' then
    model=scicos_model()
    model.state=zeros(10,1)
    model.sim=list('PDE',0)
    model.in=[1;1;1;1;1]
    model.out=[10;0]
    model.blocktype='c'
    model.dep_ut=[%f %t]

    //initialisation de l'ihm
    
    params_pde=tlist(['paramspde']);
    params_pde.a="0";
    params_pde.b="1";
    params_pde.txt_exp="(1)*b2(t)*d2u/dx2=0";
    params_pde.check_op1="0";
    params_pde.a1="";
    params_pde.b1="IN_EDP1(t)";
    params_pde.check_op2="1";
    params_pde.a2="1";
    params_pde.b2="IN_EDP2(t)";
    params_pde.check_op3="0";
    params_pde.a3="";
    params_pde.b3="IN_EDP3(t)";
    params_pde.check_op4="0";
    params_pde.a4="";
    params_pde.b4="IN_EDP4(t)";
    params_pde.check_op5="0";
    params_pde.a5="";
    params_pde.b5="IN_EDP5(t)";
    params_pde.check_op6="0";
    params_pde.a6="";
    params_pde.b6="IN_EDP6(t)";
    params_pde.check_op7="0";
    params_pde.a7="";
    params_pde.b7="IN_EDP7(t)";
    params_pde.discr_cst="0";
    params_pde.discr_non_cst="0";
    params_pde.signe="1";
    params_pde.rad_automatique="1";
    params_pde.rad_manuel="0";
    params_pde.methode="1";
    params_pde.ord1="";
    params_pde.ord2="";
    params_pde.ord3="";
    params_pde.degre="1";
    params_pde.nnode="10"; // maillage 
    params_pde.txt_pas="";
    params_pde.CI="0";
    params_pde.dCI="0";
    params_pde.CLa="0";
    params_pde.CLa_exp="IN_CL1(t)";
    params_pde.CLb="0";
    params_pde.CLb_exp="IN_CL2(t)";
    params_pde.points="";
    // dans label on mis infos de getvalue, infos ihm et le code C
    label=list(params_pde,[],'pde');
    gr_i=['txt=CCC;';
	  'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'');']
    x=standard_define([4 4],model,label,gr_i,'PDE');
  end
endfunction


