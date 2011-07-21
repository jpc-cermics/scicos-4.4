function [nipar,nrpar,nopar,nz,nx,nx_der,nx_ns,nin,nout,nm,ng,dep_u]=reading_incidence(incidence)
// this function reads an xml file and creates the matrix dep_u 
// It is used by the modelica compiler.
// number of lines represents the number of input, 
// number of columns represents the number of outputs.
// Fady 02/09/08
//
// FIXME: could be simplified if using the xml reader function
  
  function typ=ri_get_typ(txt)
    global txtline
    txtline=txtline+1;
    t=txt(txtline)
    typ=split(t);
    typ(length(typ)==0)=[];
    typ=split(typ(1),sep='>',msep=%f);
    typ(length(typ)==0)=[];
  endfunction
  
  xmlformat=scicos_mgetl(incidence);
  typ=m2s([]);input_name=[];order=[];depend=[];
  global txtline;
  txtline=0;
  corresp_table=['<number_of_integer_parameters','nipar';
                 '<number_of_real_parameters','nrpar';
		 '<number_of_string_parameters','nopar';
		 '<number_of_discrete_variables','nz';
		 '<number_of_continuous_states','nx_der';
		 '<number_of_continuous_variables','nx_ns';
		 '<number_of_continuous_unknowns','nx';
		 '<number_of_inputs','nin';
		 '<number_of_outputs','nout';
		 '<number_of_modes','nm';
		 '<number_of_zero_crossings','ng']
  while and(typ<>'</model') do
    typ=ri_get_typ(xmlformat);
    if typ(1)=='<model_info' then
      typ=ri_get_typ(xmlformat);
      while typ(1)<>'</model_info' do
	val=corresp_table(find(corresp_table==typ(1)),2)
	ttyp=split(typ(2),sep='<');
	execstr(val+'='+ttyp(1)+';');
	typ=ri_get_typ(xmlformat);
      end
    elseif typ(1)=='<identifiers' then
      while typ(1)<>'</identifiers'
	typ=ri_get_typ(xmlformat);
	if typ(1)=='<input' then
	  ttyp=split(typ(2),sep='<');
	  input_name=[input_name;ttyp(1)];
	end
      end
    elseif typ(1)=='<outputs' then
      while typ(1)<>'</outputs' do
	typ=ri_get_typ(xmlformat);
	if typ(1)=='<output' then
	  while typ(1)<>'</output' do 
	    typ=ri_get_typ(xmlformat);
	    if typ(1)=='<order' then
	      ttyp=split(typ(2),sep='<');
	      ord=evstr(ttyp(1));
	    elseif typ(1)=='<dependencies'
	      dep_flag=%f;
	      while typ(1)<>'</dependencies' then
	        typ=ri_get_typ(xmlformat);
		if typ(1)=='<input' then
		  dep_flag=%t;
		  ttyp=split(typ(2),sep='<');
		  depend=[depend;ttyp(1)];
	          order=[order;ord];
		end
	      end
	      if ~dep_flag then
                order=[order;ord]
	        depend=[depend;'NAN'];
	      end
	    end
	  end
	end
      end       
    end
  end
  clearglobal txtline;
  
  nu=size(input_name,'*');
  dep_u=ones(1,nu)==zeros(1,nu);
  for i=1:nu
    if isempty(find(depend==input_name(i))) then 
      dep_u(1,i)=%f; 
    else
      dep_u(1,i)=%t; 
    end
  end
  // remind that inputs are numbered according to their position in the
  // diagram and not in the Modelica block.InPutPortx.viis the x-th
  // input in the whole diagram!
endfunction


