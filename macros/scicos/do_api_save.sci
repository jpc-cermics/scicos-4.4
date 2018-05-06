// A Faire :
// unifier le save graphics entre blocks et super block
// terminer les cas particulier de blocks qui sont des
// super block cach�s type clock etc....
// sauver les couleurs qui ont etes sauve�es par add_color
// sauver les liens colores

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

  function txt=do_api_block_graphics(o,blk_num) 
    // export the graphics keys which are different from
    // the one produced by o.gui
    txt1=sprintf("ref_obj=%s(""define"");",o.gui);
    ok= execstr(txt1,errcatch=%t);
    txt=m2s([]);
    if type(o.graphics.gr_i,'short')=='l' && ~isempty(o.graphics.gr_i(2)) then 
      color = o.graphics.gr_i(2);
      txt($+1,1)=sprintf('blk = set_block_bg_color (blk, %s);',sci2exp(color));
    end
    if ~ok || ~o.graphics.pin.equal[ref_obj.graphics.pin] then 
      txt($+1,1)=sprintf('blk = set_block_nin (blk, %d);', size( o.graphics.pin,'*'));
    end
    if ~ok ||~o.graphics.pout.equal[ref_obj.graphics.pout] then 
      txt($+1,1)=sprintf('blk = set_block_nout (blk, %d);',size( o.graphics.pout,'*'));
    end
    if ~ok ||~o.graphics.pein.equal[ref_obj.graphics.pein] then 
      txt($+1,1)=sprintf('blk = set_block_evtnin (blk, %d);',size( o.graphics.pein,'*'));
    end
    if ~ok ||~o.graphics.peout.equal[ref_obj.graphics.peout] then 
      txt($+1,1)=sprintf('blk = set_block_evtnout (blk, %d);',size( o.graphics.peout,'*'));
    end
    if ~ok ||~o.graphics.flip.equal[ref_obj.graphics.flip] then 
      txt($+1,1)=sprintf('blk = set_block_flip (blk, %s);', sci2exp(~o.graphics.flip));
    end
    if ~ok ||~o.graphics.id.equal[ref_obj.graphics.id] then 
      txt($+1,1)=sprintf('blk = set_block_ident (blk, %s);',sci2exp(o.graphics.id));
    end
    if ~ok ||~o.graphics.orig.equal[ref_obj.graphics.orig] then 
      txt($+1,1)=sprintf('blk = set_block_origin (blk, %s);',sci2exp(o.graphics.orig,0));
    end
    if ~ok ||~o.graphics.sz.equal[ref_obj.graphics.sz] then 
      txt($+1,1)=sprintf('blk = set_block_size (blk, %s);',sci2exp(o.graphics.sz,0));
    end
    if o.graphics.iskey['theta'] && (~ok || ~o.graphics.theta.equal[ref_obj.graphics.theta]) then 
      txt($+1,1)=sprintf('blk = set_block_theta (blk, %s);',sci2exp(o.graphics.theta));
    end
  endfunction
  
  function txt=do_api_block(o,blk_num,exprs)
    // returns text for a sp�cific block
    // printf("In block api %s\n",o.gui);pause block;
    txt=sprintf('blk = instantiate_block(""%s"");',o.gui);
    // we use exprs
    if nargin <= 2 then exprs = o.graphics.exprs;end 
    txt1=sprint(exprs, name = "exprs",as_read=%t);
    txt.concatd[txt1];
    txt.concatd["blk=set_block_exprs(blk,exprs);"];
    txt1=do_api_block_graphics(o,blk_num)
    txt.concatd[txt1];
    txt.concatd[sprintf('[scs_m, block_tag_%d] = add_block(scs_m, blk);',blk_num)];
  endfunction
  
  function [txt,count]=do_api_model(scs_m,count)
    // returns text coding internal diagram of a super block.
    // printf("In api model ");pause model
    count = count+1;
    txt1=sprintf('function scs_m=subsystem_%d () ',count);
    txt1($+1,1)= '  ' +sprintf('scs_m = instantiate_diagram ();');
    if ~isempty(scs_m.props.context) then
      // add context if present
      txt2 = sprint(scs_m.props.context,name="context",as_read=%t);
      txt2.concatd["scs_m = set_model_workspace(scs_m,context);"];
      txt1.concatd['  ' + txt2];
    end
    if ~isempty(scs_m.props.options.Cmap) then
      txt2 = sprint[scs_m.props.options.Cmap,name = "colors",as_read=%t];
      txt1.concatd[txt2];
      txt1.concatd["  scs_m = set_diagram_colors(scs_m,colors);"];
    end
    col =scs_m.props.options.Background(1);
    txt1($+1,1)= sprintf('  scs_m = set_diagram_bg_color (scs_m, %s);',sci2exp(col));
    col =scs_m.props.options.Link;
    txt1($+1,1)= sprintf('  scs_m = set_diagram_link_color (scs_m, [%d;%d]);',col(1),col(2));
    txt1($+1,1)= sprintf('  scs_m = set_diagram_3d (scs_m, %s);', sci2exp(scs_m.props.options("3D")(1)));
    if %t then 
      if length(scs_m.props.wpar) >= 13 then 
	txt1($+1,1)= sprintf('  scs_m = set_diagram_zoom (scs_m, %f);',scs_m.props.wpar(13));
      else
	txt1($+1,1)= sprintf('  scs_m = set_diagram_zoom (scs_m, 1);');
      end
      if size(scs_m.props.wpar,"*")>11 then
	sz=scs_m.props.wpar(9:10);pos=scs_m.props.wpar(11:12);loc=[pos,sz+pos]
	txt1($+1,1)= sprintf('  scs_m = set_diagram_location (scs_m, %s);',sci2exp(loc,0));
      elseif size(scs_m.props.wpar,"*")>5
	sz=scs_m.props.wpar(1:2);pos=scs_m.props.wpar(5:6);loc=[pos,sz+pos]
	txt1($+1,1)= sprintf('  scs_m = set_diagram_location (scs_m, %s);',sci2exp(loc,0));
      end
    end
    txt1($+1,1)= sprintf('  scs_m = set_diagram_name (scs_m, %s)', sci2exp(scs_m.props.title(1),0));
    [blocks,head]= do_api_save_rec(scs_m,count);
    txt1.concatd['  '+blocks];
    txt1.concatd['endfunction'];
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
      txt($+1,1)= '  '+sprintf('scs_m = set_model_workspace(scs_m,%s)','context');
    end
    if type(o.graphics.gr_i,'short')=='l' && ~isempty(o.graphics.gr_i(2)) then 
      color = o.graphics.gr_i(2);
      txt($+1,1)=sprintf('blk = set_block_bg_color (blk, %s);',sci2exp(color));
    end
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
    txt($+1,1)= sprintf('[scs_m, block_tag_%d] = add_block (scs_m, blk);',blk_num);
    
  endfunction
  
  function [txt,head]= do_api_save_rec(scs_m,count)
    // 
    txt=m2s([]); head=m2s([]);
    ok = %t;
    for %kk=1:length(scs_m.objs)
      o=scs_m.objs(%kk)
      if o.type == 'Block' || o.type == 'Text' then
	if o.gui<>'PAL_f' then
	  model=o.model
	  if  o.gui == 'CLOCK_f' || o.gui == 'CLOCK_c' then
	    // exprs is to be built for CLOCK_f or CLOCK_c 
	    path = b2m(o.model.rpar.objs(1)==mlist('Deleted'))+2;
	    evtdly=o.model.rpar.objs(path); // get the evtdly block
	    exprs= evtdly.graphics.exprs;
	    txt=[txt;do_api_block(o,%kk,exprs)];
	  elseif or(o.gui == ['ENDBLK', 'STEP_FUNCTION']) then
	    // parameters are in the first internal block 
	    blk=o.model.rpar.objs(1);
	    exprs= blk.graphics.exprs;
	    txt=[txt;do_api_block(o,%kk,exprs)];
	  elseif (model.sim(1)== 'csuper' && model.ipar==1) || o.gui == 'DSUPER' then 
	    [mtxt,count]=do_api_model(model.rpar,count)
	    head=[head;mtxt];
	    txt=[txt;do_api_super_block(o,count,%t,%kk)];
	  elseif model.sim(1)=='csuper' || model.sim(1)=='super' || o.model.sim(1)=='asuper'
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
	if or(o.ct(2)==[1,3]) then
	  txt.concatd[sprintf("%s",sci2exp(points,'points'))];
	  txt_f = sprintf("[block_tag_%d, ""%d""]",bf,pf);
	  txt_t = sprintf("[block_tag_%d, ""%d""]",bt,pt);
	  txt.concatd[sprintf("[scs_m,obj_num] = add_explicit_link(scs_m,%s,%s,points);",txt_f,txt_t)];
	elseif o.ct(2)==-1 then
	  txt.concatd[sprintf("%s",sci2exp(points,'points'))];
	  txt_f = sprintf("[block_tag_%d, ""%d""]",bf,pf);
	  txt_t = sprintf("[block_tag_%d, ""%d""]",bt,pt);
	  txt.concatd[sprintf("[scs_m,obj_num] = add_event_link(scs_m,%s,%s,points);",txt_f,txt_t)];
	else
	  // who is input who is output ?
	  obj_from = scs_m.objs(bf);
	  pout = obj_from.graphics.pout 
	  pin = obj_from.graphics.pin
	  if size(pout,'*') >= pf && pout(pf) == %kk then
	    tf = 'output';
	  else
	    tf = 'input';
	  end
	  obj_to = scs_m.objs(bt);
	  pout = obj_to.graphics.pout 
	  pin = obj_to.graphics.pin
	  if size(pout,'*') >= pt && pout(pt) == %kk then
	    tt = 'output';
	  else
	    tt = 'input';
	  end
	  txt_f = sprintf("[block_tag_%d, ""%d"", ""%s""]",bf,pf,tf);
	  txt_t = sprintf("[block_tag_%d, ""%d"", ""%s""]",bt,pt,tt);
	  txt.concatd[sprintf("%s",sci2exp(points,'points'))];
	  txt.concatd[sprintf('[scs_m,obj_num] = add_implicit_link (scs_m, %s, %s, points);',
			      txt_f,txt_t,sci2exp(points,0))];
	end
      end
    end
  endfunction
  
  // main job
  test=%f;
  if type(scs_m, 'short') == 's' then
    test = %t;
    [ok,scs_m]=do_load(scs_m);
    if ~ok then return;end
  end
  ok=%t;
  
  txt=do_api_model(scs_m,0);

  last=["scs_m = subsystem_1();"; 
	"scs_m = set_final_time (scs_m, ""40"");";
	"tol = [ ""auto""; ""1e-3""; ""auto""; ""40""; ""0""; ""ode45""; ""auto"" ];";
	"scs_m = set_solver_parameters (scs_m, tol);";
	"scs_m = evaluate_model (scs_m);"];
  txt=[txt;last];

  if test then
    scicos_mputl(txt,'/tmp/schema.cosf');
    execstr(txt);
    scicos(scs_m);
  end
endfunction

