function [L,scs_m] = do_pal_tree(scicos_pal)
// Copyright INRIA

  function scs_m=charge(pal)
    [ok,scs_m,cpr,edited]=do_load(pal(2),'palette')
    if ok & size(scs_m.objs)>0 then
      scs_m.props.title(1)=pal(1)
    else
      scs_m = scicos_diagram();
      scs_m.props.title(1)='error loading '+pal(1)
    end
  endfunction

  alreadyran=%f;

  scs_m = scicos_diagram();
  scs_m.props.title(1) = 'Palettes';
  sup = SUPER_f('define');

  for i=1:size(scicos_pal,1)
    o = sup;
    o.model.rpar = charge(scicos_pal(i,:));
    scs_m.objs(i) = o;
  end
  L = crlist(scs_m,[])
endfunction

function tt = pal_TreeView(scs_m)
  tt = [tt; 'wm title $wxx '+scs_m.props.title(1) ];
  %scicos_gif='/usr/local/src/scilab/scicoslab-cvs/macros/scicos/s"+...
      " cicos_doc/man/gif_icons/';
  Pgif = %scicos_gif;
  GIFT = listfiles(Pgif+'*.gif');
  GIFT = strsubst(GIFT,'\','/');
  GIF  = [];
  for i=1:size(GIFT,1)
    [jxpath,Gname,jext] = splitfilepath_cos(GIFT(i));
    GIF = [GIF;Gname];
  end
  Path = 'root'
  tt = crlist(scs_m, Path, tt);
endfunction

function L = crlist(scs_m, ipath)
  // recursive function which fills a list 
  // with informations from palettes. 
  L=list();
  blocks_to_remove=['CLKSPLIT_f','SPLIT_f','IMPSPLIT_f'];
  for i=1:size(scs_m.objs)
    o=scs_m.objs(i);
    if o.type <> 'Link' && o.type <> 'Deleted' then
      // Blocks and Super Blocks
      if (o.model.sim.equal['super'] && (o.model.rpar.props.title(1)<>'Super Block')) || ...
         (o.gui=='PAL_f') then
        // Super Blocks
        titre2 = o.model.rpar.props.title(1);
	L1 = crlist(o.model.rpar,[ipath,i])
	L1.add_first[titre2];
	L.add_last[L1];
      else
        // Standard Blocks
        if isempty(find(o.gui==blocks_to_remove(:))) then
          titre2 = o.gui;
	  if exists('GIG')
	    ind = find(titre2==GIF);
	    if ~isempty(ind) then
	      L.add_last[hash(name='gif : '+ titre2,path=[ipath,i],cmenu='PlaceinDiagram')];
	    else
	      L.add_last[hash(name=titre2,path=[ipath,i],cmenu='PlaceinDiagram')];
	    end
          else
            // NO icon is found: use the block's name
	    L.add_last[hash(name=titre2,path=[ipath,i],cmenu='PlaceinDiagram')];
	  end
        end
      end 
    end 
  end
endfunction

