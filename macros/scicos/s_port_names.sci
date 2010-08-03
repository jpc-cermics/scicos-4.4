function s_port_names(sbloc)
// Copyright INRIA
  scs_m=sbloc.model.rpar;

  etiquettes_in = []
  etiquettes_out = []
  etiquettes_clkin = []
  etiquettes_clkout = []
  font=xget('font')

  xset('font',options.ID(2)(1),options.ID(2)(2))
  inp=[],outp=[],cinp=[],coutp=[]
  for k=1:length(scs_m.objs)
    o=scs_m.objs(k);

    if o.type =='Block' then
      modelb=o.model;
      ident = o.graphics.id
      if ident<>emptystr()&ident<>m2s([]) then
	select o.gui
	 case 'IN_f' then
	  inp=[inp modelb.ipar];
	  etiquettes_in = [etiquettes_in; ident];
	 case 'OUT_f' then
	  outp=[outp modelb.ipar];
	  etiquettes_out = [etiquettes_out; ident];
	 case 'CLKIN_f' then
	  cinp=[cinp modelb.ipar];
	  etiquettes_clkin = [etiquettes_clkin; ident];
	 case 'CLKINV_f' then
	  cinp=[cinp modelb.ipar];
	  etiquettes_clkin = [etiquettes_clkin; ident];
	 case 'CLKOUT_f' then
	  coutp=[coutp modelb.ipar];
	  etiquettes_clkout = [etiquettes_clkout; ident];
	 case 'CLKOUTV_f' then
	  coutp=[coutp modelb.ipar];
	  etiquettes_clkout = [etiquettes_clkout; ident];
	end
      end
    end
  end
  if ~isempty(inp) then
    [tmp,n_in]=sort(-inp)
    standard_etiquette(sbloc, etiquettes_in(n_in), 'in')
  end
  if ~isempty(outp) then
    [tmp,n_out]=sort(-outp)
    standard_etiquette(sbloc, etiquettes_out(n_out), 'out')
  end
  if ~isempty(cinp) then
    [tmp,n_cin]=sort(-cinp)
    standard_etiquette(sbloc, etiquettes_clkin(n_cin), 'clkin')
  end
  if ~isempty(coutp) then
    [tmp,n_cout]=sort(-coutp)
    standard_etiquette(sbloc, etiquettes_clkout(n_cout), 'clkout')
  end
  xset('font',font(1),font(2))
endfunction
