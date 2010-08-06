function scs_m_new = update_scs_m(scs_m,version)
// Copyright INRIA
// update_scs_m : function to do certification of
//                main data structure of
//                a scicos diagram (scs_m)
//                for current version of scicos
//
//   certification is done through initial value of fields in :
//      scicos_diagram()
//         scicos_params()
//         scicos_block()
//            scicos_graphics()
//            scicos_model()
//         scicos_link()
  if nargin < 2 then
    version=get_scicos_version();
  end
  scs_m_new = scicos_diagram();
  F = scs_m.__keys // getfield(1,scs_m);
  for i=1:size(F,'*')
    select F(i)
     case 'props' then
      //******************* props *******************//
      // sprops = scs_m.props;
      // be sure that the field title is 'title' 
      props =  scs_m.props;
      if props.iskey['Title'] && ~props.iskey['title'] then 
	props.title = props.Title;
	props.remove['Title'];
      end
      // call scicos_params to eventually update the hash table.
      // we use the props(:) operator to explode the hash into 
      // a sequence of names arguments
      scs_m_new.props=scicos_params(props(:));
     case 'objs' then  
      //******************** objs *******************//
      for j=1:length(scs_m.objs) //loop on objects
	o=scs_m.objs(j);
	select o.type 
	 case 'Block' then
	  //************** Block ***************//
	  o_new=scicos_block();
	  T = o.__keys ;
	  for k=1:size(T,'*')
	    select T(k)
	     case 'graphics' then
	      //*********** graphics **********//
	      ogra  = o.graphics;
	      o_new.graphics = scicos_graphics(ogra(:));
	     case 'model' then
	      //************* model ***********//
	      omod  = o.model;
	      o_new.model =scicos_model(omod(:));
	      //******** super block case ********//
	      //if omod.sim=='super'|omod.sim=='csuper' then
	      //  rpar=update_scs_m(omod.rpar,version)
	      //  omod.rpar=rpar
	      //end
	    else
	      //************* other ***********//
	      // just copy the field 
	      o_new(T(k)) = o(T(k));
	    end  //end of select T(k)
	  end  //end of for k=
	  scs_m_new.objs(j) = o_new;
	 case 'Link' then
	  //************** Link ****************//
	  scs_m_new.objs(j) =scicos_link(o(:));
	 case 'Text' then
	  //************** Text ****************//
	  o_new = mlist(['Text','graphics','model','void','gui'],...
			scicos_graphics(),scicos_model(),' ','TEXT_f')
	  T= o.__keys;
	  for k=1:size(T,'*')
	    select T(k)
	     case 'graphics' then
	      //*********** graphics **********//
	      ogra  = o.graphics;
	      o_new.graphics = scicos_graphics(ogra(:));
	     case 'model' then
	      //************* model ***********//
	      omod  = o.model;
	      o_new.model =scicos_model(omod(:));
	      //******** super block case ********//
	      //if omod.sim=='super'|omod.sim=='csuper' then
	      //  rpar=update_scs_m(omod.rpar,version)
	      //  omod.rpar=rpar
	      //end
	      o_new.model = omod;
	    else
	      //************* other ***********//
	      // just copy the field 
	      o_new(T(k)) = o(T(k));
	    end  //end of select T(k)
	  end  //end of for k=
	  scs_m_new.objs(j) = o_new;
	  //************* other ***********//
	else  // JESAISPASIYADAUTRESOBJS
	  // QUEDESBLOCKSDESLINKETDUTEXTESDANSSCICOS
	  // ALORSICIJEFAISRIEN
	  scs_m_new.objs(j) = o;
	  //************************************//
	end //end of select typeof(o)
      end //end of for j=
      //*********************************************//
      //** version **//
     case 'version' then
      //do nothing here, this should be done later
    end  //end of select  F(i)
  end //end of for i=
  //**update version **//
  //scs_m_new.version = version;
endfunction
