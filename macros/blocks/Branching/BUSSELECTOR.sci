function [x,y,typ]=BUSSELECTOR(job,arg1,arg2)
// Copyright INRIA
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1)
   case 'getinputs' then
    [x,y,typ]=standard_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=standard_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
     y=acquire('needcompile',def=0);
    x=arg1;
    graphics=x.graphics;model=x.model;
    exprs=graphics.exprs
    old_SelectedSignals=exprs(2)(1)
    
    non_interactive = scicos_non_interactive();
    gv_titles=['Signal Selected','Output type bus (0=No 1=yes)'];
    gv_types= list('string',-1,'vec',1);
    while %t do
      if ~non_interactive then
	label=list(exprs(2)(1),exprs(1))
	if isempty(label(1)) then label(1)=['Signal1'];end
	[ok,SelectedSignals,outputbus,label]=getvalue('This is just for test',..
						      gv_titles, ...
						      gv_types,label);
	if ~ok then return;end // abort in gui
	outputbus=string(outputbus)
	ok=execstr('SelectedSignals=evstr(SelectedSignals)',errcatch=%t);
	if ~ok then
	  message(['The Format you entered for the ""Signal Selected"" is wrong';
		   'It must be ""[""S1"";""S2""]""']);
	  continue
	end
      else
	SelectedSignals=evstr(exprs(2)(1))
	outputbus=exprs(1)
      end
      SSignals=unique(SelectedSignals);
      if size(SSignals,'*') < size(SelectedSignals,'*') then
	message('Signals must be extracted only one time from the bus');
	continue;
      end
      outnb=size(SelectedSignals,'*');
      //      inpsignals=size(Signals,'*');
      //      onesignalstay=(inpsignals-outnb==1) 
      //      outbus=(inpsignals-outnb>1)
      if outputbus=='0' then
	if outnb>0 then
	  out=[-[1:outnb]', -(outnb+[1:outnb]')];
	  ot=-[1:outnb]'
	else out=[],ot=[]
	end
	[model,graphics,ok]=set_io(model,graphics,list([0 0],-1), ...
				   list(out,ot),[],[],[],[],1,[]);
	// exprs=list(Signals',[])
	exprs=list(outputbus,list(sci2exp(SelectedSignals(:)),[]))
      else
	out=[-1 , -2],ot=-1
	[model,graphics,ok]=set_io(model,graphics,list([0 0],-1),...
				   list(out,ot),[],[],[],[],1,1)
	//exprs=list(Signals',SelectedSignals(:))
	exprs=list(outputbus,list(sci2exp(SelectedSignals(:)),[]))
      end	 
      if ~ok then continue;end
      if ~old_SelectedSignals.equal[SelectedSignals] then y=4;end
      graphics.exprs=exprs;
      //model.opar=list(SelectedSignals);
      if outnb>3 & outputbus=='0' then graphics.sz=[10 40+(outnb-3)*10];
      else graphics.sz=[10 40];
      end
      x.model=model;x.graphics=graphics;
      break;
    end
   case 'define' then
    model=scicos_model()
    model.sim='busselector'
    model.out=-1
    model.out2=-2
    model.outtyp=-1
    model.in=0
    model.intyp=-1
    model.ipar=[]
    model.opar=list()
    model.blocktype='c'
    model.dep_ut=[%t %f]

    exprs=list('1',list([],[],[]))
    gr_i=' ' //'xstringb(orig(1),orig(2),''BUS'',sz(1),sz(2),''fill'')'
    x=standard_define([.5 2],model,exprs,gr_i,'BUSSELECTOR');
    x.graphics.id="DEBUS"
    x.graphics.out_implicit='B'
    x.graphics.in_implicit="B"
  end
endfunction

function [ok,SelSignals,outputbus]=BusSelectorProperties(Signals,opar,outputbus)
  SigVal=[]
  for i=1:size(Signals,'*')
    ind=strindex(Signals(i),' ');
    if ~isempty(ind) then 
      SigVal=[SigVal;strcat(['{',Signals(i),'}'])];
    else 
      SigVal=[SigVal;Signals(i)];
    end
  end
  SSignal=opar(:)
  SelectedSignal=[]
  for i=1:size(SSignal,'*')
    ind=strindex(SSignal(i),' ');
    if ~isempty(ind) then 
      SelectedSignal=[SelectedSignal;strcat(['{',SSignal(i),'}'])];
    else 
      SelectedSignal=[SelectedSignal;SSignal(i)];
    end
  end
  txt=['set www .busselectorxx'
       'catch {destroy $www}'
       'toplevel $www'
       'set numx [winfo pointerx .]'
       'set numy [winfo pointery .]'
       'wm geometry $www +$numx+$numy'
       'wm title $www '"Parameters'"'
       'wm iconname $www '"busselector'"'
       '#positionWindow $www'
       'frame $www.buttons'
       'pack $www.buttons -side bottom -fill x -pady 2m'
       'button $www.buttons.dismiss -text Dismiss -command {set done 2}'
       'button $www.buttons.code -text OK -command {set done 1}'
       'pack $www.buttons.dismiss $www.buttons.code -side left -expand 1'
       'frame $www.chkbox'
       'pack $www.chkbox -side bottom -fill x -pady 2m'
       'checkbutton $www.chkbox.outbus -text ""Output as bus"" -variable outputbus'
       'pack $www.chkbox.outbus -side right'
       'frame $www.signal'
       'pack $www.signal -side bottom -fill x -pady 2m'
       'listbox $www.signal.lst'
       strcat(['lappend SignalsList' SigVal'],' ')
       '$www.signal.lst configure -listvariable SignalsList'
       'pack $www.signal.lst -side left -expand 1' 
       'panedwindow $www.signal.buttons -orient vertical -opaqueresize 0'
       'button $www.signal.buttons.select -text Select>> '
       'button $www.signal.buttons.remove -text Remove '
       '$www.signal.buttons add $www.signal.buttons.select'
       '$www.signal.buttons.select configure -state disabled'
       '$www.signal.buttons add $www.signal.buttons.remove'
       '$www.signal.buttons.remove configure -state disabled'
       'pack $www.signal.buttons -side left -expand 1'
       'listbox $www.signal.lst2'
       strcat(['lappend SelectedSignals' SelectedSignal'],' ')
       '$www.signal.lst2 configure -listvariable SelectedSignals'
       'pack $www.signal.lst2 -side left -expand 1' ];
  txt=[txt;
       ['frame $www.def'
	'pack $www.def -side bottom -fill x -pady 2m'
	'label $www.def.lab -text ""This block selected signals from a bus""'
	'pack $www.def.lab -side left -expand 1']];
  tt='';
  for i=1:size(SigVal,'*')
    SV=strsubst(SigVal(i),'{','');SV=strsubst(SV,'}','');
    tt=tt+'""'+SV+'"" ';
  end
  txt=[txt;
       ['$www.signal.lst delete 0 end'
	'$www.signal.lst insert end '+tt]];
  tt='';
  for i=1:size(SelectedSignal,'*')
    SSG=strsubst(SelectedSignal(i),'{','');SSG=strsubst(SSG,'}','');
    tt=tt+'""'+SSG+'"" ';
  end
  txt=[txt;
       ['$www.signal.lst2 delete 0 end'
	'$www.signal.lst2 insert end '+tt]];
  tt='set Selectindx [$www.signal.lst curselection];'+.. 
     'set ButtonState [$www.signal.buttons.select cget -state];'+..
     'if {$Selectindx != """" & $ButtonState != ""disabled""} {'+..
     'set SelectSignal [$www.signal.lst get $Selectindx];'+..
     '$www.signal.lst2 insert end $SelectSignal;}'
  txt=[txt;
       ['proc Select {www} {'+tt+'}']];
  tt='set Selectindx [$www.signal.lst2 curselection];'+..
     'set ButtonState [$www.signal.buttons.remove cget -state];'+..
     'if {$Selectindx != """" & $ButtonState != ""disabled""} {'+..
     '$www.signal.lst2 delete $Selectindx;}';
  txt=[txt;
       ['proc Remove {www} {'+tt+'}']];   
  tt='global SelectedSignals;global outputbus'
  txt=[txt;
       ['proc done1 {www} {'+tt+'}']];
  tt1='$www.signal.buttons.select configure -state normal;'+..
      '$www.signal.buttons.remove configure -state disabled';
  tt2='$www.signal.buttons.remove configure -state normal;'+..
      '$www.signal.buttons.select configure -state disabled';    
  txt=[txt;
       ['bind $www.signal.lst <1> {'+tt1+'}'
	'bind $www.signal.lst2 <1> {'+tt2+'}'
	'bind $www.signal.buttons.select <ButtonPress> {Select $www}'
	'bind $www.signal.buttons.remove <ButtonPress> {Remove $www}'
	'set done 0'
	'bind $www <Return> {set done 1}'
	'bind $www <Destroy> {set done 2}'
	'tkwait variable done'
	'if {$done==1} {done1 $www}']];
  TCL_EvalStr(txt);
  done=TCL_GetVar('done')
  if done==string(1) then
    outputbus=TCL_GetVar('outputbus');
    SelSignals=TCL_GetVar('SelectedSignals');
    ok=%t
    indxstart=strindex(SelSignals,'{')
    indxend=strindex(SelSignals,'}')
    if ~isempty(indxstart) then
      SignalVect=part(SelSignals,[1:indxstart(1)-1])
      SignalVect=tokens(SignalVect)
      SignalVect=[SignalVect;part(SelSignals,[indxstart(1)+1:indxend(1)-1])]
      for i=2:size(indxstart,'*')
	SVect=part(SelSignals,[indxend(i-1)+1:indxstart(i)-1])
	SVect=tokens(SVect)
	SignalVect=[SignalVect;SVect;part(SelSignals,[indxstart(i)+1:indxend(i)-1])]
      end
      SVect=part(SelSignals,[indxend($)+1:length(SelSignals)])
      SVect=tokens(SVect)
      SignalVect=[SignalVect;SVect]
    else
      SignalVect=tokens(SelSignals);
    end
    SelSignals=SignalVect
  else
    ok=%f;SelSignals=opar(:);outputbus=outputbus
  end
  TCL_EvalStr('destroy $www')
endfunction

