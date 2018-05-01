function [ok,txt]=do_api_save(scs_m) 
// This function save a diagram in API mode 

  function txt = get_block_mask (blk);
    txt = "";
    if blk.type <> 'Block' || blk.model.sim <> "csuper" then
      return;
    end
    if model.ipar<> 1 then
      // printf("get_block_mask: ipar is equal to 1\n");
      return;
    end;
    if type(blk.graphics.exprs,'short')<>'l' then
      // printf("get_block_mask: exprs is not a list \n");
      return;
    end
    params_values = blk.graphics.exprs(1);
    params = blk.graphics.exprs(2);
    params_names = params(1);
    params_prompts = params(2)(2:$);
    title = params(2)(1);
    params_types = params(3);
    txt = "";
    params_tags =list()
    for i=1:size(params_prompts,'*')
      pp= split(params_prompts(i),sep='\n');
      if size(pp,'*')<>1 then
	for j=2:size(pp,'*')
	  k=strindex(pp(j),':');
	  pp(j)=part(pp(j),k+1:length(pp(j)));
	end
	params_tags(i)=['popup',pp(2:$)];
	params_prompts(i)=pp(1);
      else
	params_tags(i)=['edit'];
      end
    end
  endfunction
  
  function txt=do_api_block(o,blk_num,target="nsp")
    // returns text for a spécific block
    // printf("In block api %s\n",o.gui);pause block;
    txt=sprintf('blk = instantiate_block (""%s"");',o.gui);
    if o.gui == "scifunc_block5" then
      // Dans ce cas exprs est une liste XXXXX 
      pause;xxx;
    end
    expp=o.graphics.exprs;
    ne=size(expp,'*');
    if ne > 0 then
      if target == "nsp" then
	txt($+1,1)=sprintf('params = cell(0,2);');
	for i=1:ne 
          txt($+1,1)= sprintf( "params.concatd[{ ""name%0d"",%s}];",i, sci2exp(expp(i)));
	end
	txt($+1,1)= 'blk = set_block_parameters (blk, params);';
      else
	txt($+1,1)=sprintf('params = struct()');
	names= sprintf('name%0d',(1:ne)');
	for i=1:ne 
          txt($+1,1)= 'params.' + names(i) + '= ' +sci2exp(expp(i))
	end
	txt($+1,1)= 'blk = set_block_parameters (blk, params);';
      end
    end
    if %f && type(o.graphics.gr_i)<>10  then
      cmap=get(sdf(),"color_map");
      if isempty(o.graphics.gr_i(2)) then 
        col=[1,1,1]
      else
        col=cmap( o.graphics.gr_i(2),:);
      end
    else
      col=[1,1,1]
    end
    txt($+1,1)=sprintf('blk = set_block_bg_color (blk, %s);',sci2exp(col));
    // txt($+1,1)=sprintf('blk = set_block_fg_color (blk, %s);';
    txt($+1,1)=sprintf('blk = set_block_nin (blk, %d);', size( o.graphics.pin,'*'));
    txt($+1,1)=sprintf('blk = set_block_nout (blk, %d);',size( o.graphics.pout,'*'));
    txt($+1,1)=sprintf('blk = set_block_evtnin (blk, %d);',size( o.graphics.pein,'*'));
    txt($+1,1)=sprintf('blk = set_block_evtnout (blk, %d);',size( o.graphics.peout,'*'));
    txt($+1,1)=sprintf('blk = set_block_flip (blk, %s);', sci2exp(~o.graphics.flip));
    txt($+1,1)='blk = set_block_ident (blk,'+sci2exp(o.graphics.id)+')';
    txt($+1,1)=sprintf('blk = set_block_origin (blk, %s);',sci2exp(o.graphics.orig,0));
    txt($+1,1)=sprintf('blk = set_block_size (blk, %s);',sci2exp(o.graphics.sz,0));
    if o.graphics.iskey['theta'] then 
      txt($+1,1)=sprintf('blk = set_block_theta (blk, %s);',sci2exp(o.graphics.theta));
    end
    txt($+1,1)=sprintf('[scsm, block_tag_%d] = add_block (scsm, blk);',blk_num);
  endfunction
  
  function [txt,count]=do_api_model(scs_m,count)
    // returns text coding internal diagram of a super block.
    // and 
    // printf("In api model ");pause model
    count = count+1;

    if %f then 
      cmap=get(sdf(),"color_map");
      col=scs_m.props.options.Background(1);
      col=cmap( col,:);
    else
      col = [1,1,1];
    end
    txt1=sprintf('function scsm=subsystem_%d () ',count);
    txt1($+1,1)= '  ' +sprintf('scsm = instantiate_diagram ();');
    context=scs_m.props.context
    if ~isempty(context) then
      txt2 = sprint(context,as_read=%t);
      txt1.concatd[txt2];
      txt1($+1,1)= '  '+sprintf('scsm = set_model_workspace(scsm,%s)','context');
    end
    txt1($+1,1)= '  '+sprintf('scsm = set_diagram_bg_color (scsm, %s);',sci2exp(col));
    txt1($+1,1)= '  '+sprintf('scsm = set_diagram_3d (scsm, %s);', sci2exp(scs_m.props.options("3D")(1)));
    if length(scs_m.props.wpar) >= 13 then 
      txt1($+1,1)= '  '+sprintf('scsm = set_diagram_zoom (scsm, %f);',scs_m.props.wpar(13));
    else
      txt1($+1,1)= '  '+sprintf('scsm = set_diagram_zoom (scsm, 1);');
    end
    
    if size(scs_m.props.wpar,"*")>11 then
       sz=scs_m.props.wpar(9:10);pos=scs_m.props.wpar(11:12);loc=[pos,sz+pos]
    else
       sz=scs_m.props.wpar(1:2);pos=scs_m.props.wpar(5:6);loc=[pos,sz+pos]
    end
    txt1($+1,1)= '  ' +sprintf('scsm = set_diagram_location (scsm, %s);',sci2exp(loc,0));
    txt1($+1,1)= '  ' +sprintf('scsm = set_diagram_name (scsm, %s)', sci2exp(scs_m.props.title(1),0));
    [blocks,head]= do_api_save_rec(scs_m,count);
    txt1=[txt1;'  '+blocks];
    txt1($+1,1) = 'endfunction';
    txt=[head;txt1];
  endfunction

  function txt=do_api_super_block(o,count,flag,blk_num)
    //
    // printf("In super block %s\n",o.gui);pause super
    txt = m2s([]);
    txt($+1,1)=sprintf('// New block %s ',o.gui);
    txt($+1,1)=sprintf('blk = instantiate_super_block ();');
    if flag && ~isempty(o.graphics.exprs) then
      val=o.graphics.exprs(1);
      expp=o.graphics.exprs(2)(1)
      ne=size(expp,'*');
      if ne>0 then
	txt($+1,1)=sprintf('params = cell (0, 2)');
	for i=1:ne 
	  txt($+1,1)=sprintf("params.concatd[{ ""%s"", %s}];",expp(i),sci2exp(expp(i)));
	end
	txt($+1,1)= 'blk = set_block_parameters (blk, params);';
      end
    end
    context=scs_m.props.context
    if ~isempty(context) then
      txt1 = sprint(context,as_read=%t);
      txt.concatd[txt1];
      txt($+1,1)= '  '+sprintf('scsm = set_model_workspace(scsm,%s)','context');
    end
    if %f && type(o.graphics.gr_i,'short')<>'s' then
      cmap=get(sdf(),"color_map");
      if isempty(o.graphics.gr_i(2)) then 
	col=[1,1,1]
      else
	col=cmap( o.graphics.gr_i(2),:);
      end
    else
      col=[1,1,1]
    end
    txt($+1,1)=sprintf('blk = set_block_bg_color (blk, %s);',sci2exp(col));
    // txt($+1,1)=sprintf('blk = set_block_fg_color (blk, %s);',;
    txt($+1,1)=sprintf('blk = set_block_nin (blk, %d);',size( o.graphics.pin,'*'));
    txt($+1,1)=sprintf('blk = set_block_nout (blk, %d);',size( o.graphics.pout,'*'));
    txt($+1,1)=sprintf('blk = set_block_evtnin (blk, %d);',size( o.graphics.pein,'*'));
    txt($+1,1)=sprintf('blk = set_block_evtnout (blk, %d);',size( o.graphics.peout,'*'));
    txt($+1,1)=sprintf('blk = set_block_flip (blk, %s);', sci2exp(~o.graphics.flip));
    txt($+1,1)='blk = set_block_ident (blk,'+sci2exp(o.graphics.id)+')';
    txt($+1,1)=sprintf('blk = set_block_origin (blk, %s);',sci2exp(o.graphics.orig,0));
    txt($+1,1)=sprintf('blk = set_block_size (blk, %s);',sci2exp(o.graphics.sz,0));
    if o.graphics.iskey['theta'] then 
      txt($+1,1)=sprintf('blk = set_block_theta (blk, %s);',sci2exp(o.graphics.theta));
    end
    txt($+1,1)=sprintf('tmp_diag = subsystem_%d ()',count);
    if flag then
      txt1 = get_block_mask (o);
      txt.concatd[txt1];
      // txt($+1,1)= 'blk = set_block_mask (blk, params, ""?"");';
    end
    txt($+1,1)= 'blk = fill_super_block (blk, tmp_diag);';
    txt($+1,1)= sprintf('[scsm, block_tag_%d] = add_block (scsm, blk);',blk_num);
    
  endfunction
  
  function [txt,head]= do_api_save_rec(scs_m,count)
    // 
    txt=m2s([]); head=m2s([]);
    ok = %t;
    for %kk=1:length(scs_m.objs)
      o=scs_m.objs(%kk)
      if o.type =='Block' || o.type =='Text' then
	if o.gui<>'PAL_f' then
	  model=o.model
	  if ((model.sim(1)=='csuper'& model.ipar==1) | (o.gui == 'DSUPER' )) then
	    [mtxt,count]=do_api_model(model.rpar,count)
	    head=[head;mtxt];
	    txt=[txt;do_api_super_block(o,count,%t,%kk)];
	  elseif (model.sim(1)=='csuper' | model.sim(1)=='super' | o.model.sim(1)=='asuper')
	    [mtxt,count]=do_api_model(model.rpar,count)
	    head=[head;mtxt];
	    txt=[txt;do_api_super_block(o,count,%f,%kk)];
	  else
	    // a standard block 
	    txt=[txt;do_api_block(o,%kk)];
	  end
	end
      end
    end
    for %kk=1:length(scs_m.objs)
      o=scs_m.objs(%kk)
      if o.type == 'Link' then
	bf=o.from(1);pf=o.from(2);
	bt=o.to(1);pt=o.to(2);
	xx=o.xx;yy=o.yy;nsz=size(xx,"*")
	sxx=xx(2:$)-xx(1:$-1);
	sxx=sxx(1:$-1)
	syy=yy(2:$)-yy(1:$-1);
	syy=syy(1:$-1)
	points=[sxx,syy]
	if o.ct(2)==1 then
	  txt($+1,1)=..
	  sprintf('[scsm,obj_num] = add_explicit_link (scsm, [block_tag_%d, ""%d""], [block_tag_%d, ""%d"" ],%s)',bf,pf,bt,pt,sci2exp(points,0));
	elseif o.ct(2)==-1 then
	  txt($+1,1)=..
	  sprintf('[scsm,obj_num] = add_event_link (scsm, [block_tag_%d, ""%d""], [block_tag_%d, ""%d""],%s)',bf,pf,bt,pt,sci2exp(points,0));
	else
	  printf('Warning:unsupported link type\n');pause
	end
      end
    end
  endfunction
  
  // main job 
  ok=%t;
  
  txt=do_api_model(scs_m,0);

  last=["scsm = subsystem_1();"; 
	"scsm = set_final_time (scsm, ""40"");";
	"tol = [ ""auto""; ""1e-3""; ""auto""; ""40""; ""0""; ""ode45""; ""auto"" ];";
	"scsm = set_solver_parameters (scsm, tol);";
	"scsm = evaluate_model (scsm);"];
  txt=[txt;last];
endfunction

