function  [%cpr,ok]=do_compile(scs_m)
// Copyright INRIA
  show_trace=%f
  if show_trace then disp('c_pass0:'+string(timer())),end
  if ~exists('%scicos_solver') then %scicos_solver=0,end
  if ~exists('alreadyran') then alreadyran=%f; end
  par=scs_m.props;
  if alreadyran then 
    //terminate current simulation
    do_terminate()
  end
  timer()
  // XXX: jpc switch to 0xn nx0
  IN=zeros_new(1,0);OUT=zeros_new(1,0);
  for i=1:length(scs_m.objs)
    if scs_m.objs(i).type =='Block' then 
      if scs_m.objs(i).gui=='IN_f' then
        scs_m.objs(i).gui='INPUTPORT';
        scs_m.objs(i).model.sim='bidon'
        IN=[IN scs_m.objs(i).model.ipar]
      elseif scs_m.objs(i).gui=='OUT_f' then
        scs_m.objs(i).gui='OUTPUTPORT';
        scs_m.objs(i).model.sim='bidon'
        OUT=[OUT  scs_m.objs(i).model.ipar]
      end
    end
  end
  IN=sort(IN,'g','i');
  if or(IN<>[1:size(IN,'*')]) then 
    ok=%f;%cpr=list()
    message('Input ports are not numbered properly.');
    return
  end
  OUT=-sort(-OUT);
  if or(OUT<>[1:size(OUT,'*')]) then 
    ok=%f;%cpr=list()
    message('Output ports are not numbered properly.')
    return
  end
  [bllst,connectmat,clkconnect,cor,corinv,ok]=c_pass1(scs_m);

  if show_trace then disp('c_pass1:'+string(timer())),end
  if ~ok then %cpr=list(), return,end
  if size(connectmat,2)==6 then connectmat=connectmat(:,[1 2 4 5]),end
  // remove from local frame 
  clear scs_m;
  //scs_m=null()
  if ~ok then %cpr=list(),return,end
  //newc_pass2 destroys the corinv component associated
  //to the modelica blocks preserve it
  //clast=corinv($)
  //if type(clast)==15 then corinv($)=clast(1),klast=size(corinv),end
  //%cpr=newc_pass2(bllst,connectmat,clkconnect,cor,corinv);
  //newc_pass2 destroys the corinv component associated
  //to the modelica blocks
  //if type(clast)==15 then %cpr.corinv(klast)=clast,end
  %cpr=c_pass2(bllst,connectmat,clkconnect,cor,corinv);
  if %cpr.equal[list()] then ok=%f,end
endfunction
