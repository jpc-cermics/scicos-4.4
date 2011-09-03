function [x,y,typ]=BUSCREATOR(job,arg1,arg2)
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
    if ~exists('needcompile') then
      needcompile=0;
    else 
      needcompile = needcompile;
    end
    x=arg1;
    graphics=x.graphics;model=x.model;
    exprs=graphics.exprs
    old_exprs=exprs(2)(1)
    ok=%f;okk=%t
    non_interactive = exists('getvalue') && getvalue.get_fname[]=='setvalue';
    gv_titles=['Signals Name';'Buses Number';'Names inheritance (0=yes 1=no)']
    gv_types= list('string',1,'vec',1,'vec',1);
    while %t do
      if ~non_interactive then
	label=[exprs(2)(1);exprs(3);exprs(4)]  //just for test
	[ok,Signals,inputbus,InheritSignal,label]=getvalue('This is just for test',..
						  gv_titles,gv_types, ...
						  label);
	
	if ~ok then return;end // a cancel in gui
	Signals=evstr(Signals);
	inputnb=size(Signals,'*');
      else
	inputnb=size(find(graphics.in_implicit=='E'),'*');
	inputbus=size(find(graphics.in_implicit=='B'),'*');
	Signals=evstr(exprs(2)(1))
	InheritSignal=evstr(exprs(4))
      end
      if inputnb+inputbus<2 then 
	message('Input number must be greater than 2');
	continue;
      end
      SS=unique(Signals)
      if size(SS,'*')<inputnb then 
	message('Two or more Signals have same name');
	continue;
      end
      in=[-[1:inputnb+inputbus]',-(inputnb+inputbus+[1:inputnb+inputbus]')];
      it=-[1:inputnb+inputbus]';
      model.in=in(:,1)
      model.in2=in(:,2)
      model.intyp=it
      old_inputnb=size(find(graphics.in_implicit=='E'),'*');
      old_inputbus=size(find(graphics.in_implicit=='B'),'*');
      if inputnb > old_inputnb then
	graphics.pin=[graphics.pin(1:old_inputnb,1);zeros(inputnb-old_inputnb,1);graphics.pin(old_inputnb+1:$,1)];
      else
	graphics.pin=[graphics.pin(1:inputnb,1);graphics.pin(old_inputnb+1:$,1)];
      end
      if inputbus>old_inputbus then
	graphics.pin=[graphics.pin;zeros(inputbus-old_inputbus,1)];
      elseif inputbus<old_inputbus then
	graphics.pin(inputnb+inputbus+1:$,:)=[];
      end
      //graphics.signal_propagated=[exprs(2)(1)(:);exprs(2)(2)(:)]
      graphics.in_implicit=[smat_create(1,inputnb,'E'),...
		    smat_create(1,inputbus,'E')];
      if and(graphics.pin(inputnb+1:inputnb+inputbus)==0) then
	//[BS,ok]=FindSignalsInBus(x,scs_m,graphics.pin(port))
	exprs(2)(2)=list()
      end
      L=exprs(2)(2);
      BS=[];for i=1:length(L); BS=[BS;L(i)(:)];end
      SS=[Signals(:);BS(:)];
      [SS1,ind]=unique(SS);
      indx=setdiff([1:size(SS,'*')]',ind(:))
      if ~isempty(indx) then
	message('The input signal ""'+SS(indx(:))+'"" is already a signal in the input bus');
	continue;
      end
      exprs(1)=sci2exp(inputnb)
      exprs(2)(1)=sci2exp(Signals(:))
      exprs(3)=sci2exp(inputbus)
      exprs(4)=sci2exp(InheritSignal)
      if old_exprs<>exprs(2)(1) then needcompile=4;y=needcompile;end
      graphics.exprs=exprs;
      if inputnb+inputbus>3 then 
	graphics.sz=[10 40+(inputnb+inputbus-3)*10];
      end
      x.model=model;x.graphics=graphics;
      break
    end
    resume(needcompile);
   case 'define' then
    in=2
    model=scicos_model()
    model.sim='buscreator'
    model.in=-[1:in]'
    model.in2=-(in+[1:in]')
    model.intyp=-[1:in]'
    model.out=0
    model.outtyp=-1
    model.opar=list()
    model.blocktype='c'
    model.dep_ut=[%t %f]
    // exprs contains 
    //exprs(1)=nbre of input port
    //exprs(2)= it is a list
    //exprs(2)(1) --> the input signals
    //exprs(2)(2) --> the input buses
    //exprs(3) --> number of input buses
    //exprs(4) --> option (0 or 1)
    //exprs=list(string(in),mlist(['Type','SignalName','Bus'],['Signal1','Signal2'],mlist(['Type','BusName','SignalName','Bus'],[],[],list())),string(0),string(0))
    exprs=list(string(in),list(sci2exp(['Signal1';'Signal2']),[]),'0','0') // just for test
    //exprs(5) contient la matrice de correspondance entre les bus et les signaux (a voir).
    gr_i=' ' //'xstringb(orig(1),orig(2),''BUS'',sz(1),sz(2),''fill'')'
    x=standard_define([.5 2],model,exprs,gr_i,'BUSCREATOR');
    x.graphics.id="BUS"
    x.graphics.in_implicit=["E","E"]
    x.graphics.out_implicit="B"
  end
endfunction

function [ok,inputnb,inputbusnb,Signals,InheritSignal]=BusCreatorProperties(exprs)
  inputnb=evstr(exprs(1))
  SigVal=[]
  M=exprs(2)
  signalsinput=M.SignalName
  for i=1:size(signalsinput,'*')
    ind=strindex(signalsinput(i),' ');
    if ~isempty(ind) then 
      SigVal=[SigVal;strcat(['{',signalsinput(i),'}'])]
    else 
      SigVal=[SigVal;signalsinput(i)];
    end
  end
  BusInput=exprs(2)(2)
  options=['Inherit bus signals names from input port';
	   'Require input signals names to match signals below']
  origopt=options(evstr(exprs(4))+1)
  //inputbusnb=eval(exprs(3))
  inputbusnb=evstr(exprs(3))
  txt=['set BWpath [file dirname '"$env(SCIPATH)/tcl/BWidget-1.7.0'"]'
       'if {[lsearch $auto_path $BWpath]==-1} {'+..
       'set auto_path [linsert $auto_path 0 $BWpath]'+..
       '}'
       'package require BWidget 1.7.0'
       'namespace inscope :: package require BWidget'
       'set www .buscreatorxx'
       'catch {destroy $www}'
       'toplevel $www'
       'set numx [winfo pointerx .]'
       'set numy [winfo pointery .]'
       'wm geometry $www +$numx+$numy'
       'wm title $www '"Parameters'"'
       'wm iconname $www '"buscreator'"'
       '#positionWindow $www'
       'frame $www.buttons'
       'pack $www.buttons -side bottom -fill x -pady 2m'
       'button $www.buttons.dismiss -text Dismiss -command {set done 2}'
       'button $www.buttons.code -text OK -command {set done 1}'
       'pack $www.buttons.dismiss $www.buttons.code -side left -expand 1'
       'frame $www.rename'
       'pack $www.rename -side bottom -fill x -pady 2m'
       'label $www.rename.lab -text ""Rename Selected Signal""'
       'entry $www.rename.entry -relief sunken -width 15 '
       '$www.rename.entry configure -state disabled'
       'pack $www.rename.lab $www.rename.entry -side left -expand 1'   
       'frame $www.signal'
       'global SignalNumber;set SignalNumber '+sci2exp(inputnb)
       'global BusNumber;set BusNumber '+sci2exp(inputbus)
       'pack $www.signal -side bottom -fill x -pady 2m'
       'lappend SignalsList '+strcat([SigVal' BusInput'],' '); 
       'listbox $www.signal.lst'
       '$www.signal.lst configure -listvariable SignalsList'
       'Tree $www.signal.tr'
       '$www.signal.lst delete 0 end']
  for i=1:size(SigVal,'*')
    txt=[txt;['$www.signal.tr insert end root Signal'+sci2exp(i)+' -text '+SigVal(i);
	      '$www.signal.lst insert end '+SigVal(i) ]];
  end
  j=i;
  for i=1:size(BusInput,'*')
    txt=[txt;['$www.signal.lst insert end '+BusInput(i);
	      '$www.signal.tr insert end root Bus'+sci2exp(i)+' -text '+BusInput(i) ]];
    execstr('for k=1:size(SigBus'+BusInput(i)+',''*'') '+..
            'txt=[txt;[''$www.signal.tr insert end Bus'+sci2exp(i)+' Bus'+sci2exp(i)+'Sig''+sci2exp(k)+'' -text ''+SigBus'+BusInput(i)+'(k)]];end')
  end
  txt=[txt;
       'button $www.signal.refresh -text Refresh '
       'pack $www.signal.refresh -side right -expand 1' 
       'pack $www.signal.tr -side left -expand 1'
       'pack forget $www.signal.lst'];
  txt=[txt;
       ['frame $www.inputbus'
	'pack $www.inputbus -side bottom -fill x -pady 2m'
	'label $www.inputbus.lab -text ""Number of input Buses""'
	'entry $www.inputbus.entry -relief sunken -width 15'
	'$www.inputbus.entry insert 0 ""'+sci2exp(size(BusInput,'*'))+'""'
	'pack $www.inputbus.lab $www.inputbus.entry -side left -expand 1']];
  txt=[txt;
       ['frame $www.input'
	'pack $www.input -side bottom -fill x -pady 2m'
	'label $www.input.lab -text ""Number of input Signals""'
	'entry $www.input.entry -relief sunken -width 15'
	'$www.input.entry insert 0 ""'+sci2exp(inputnb)+'""'
	'pack $www.input.lab $www.input.entry -side left -expand 1'
	'frame $www.inherit'
	'pack $www.inherit -side bottom -fill x -pady 2m'
	'set opt ""'+origopt+'""'
	'tk_optionMenu $www.inherit.menu opt ""'+options(1)+'"" ""'+options(2)+'""'
	'pack $www.inherit.menu -side left -expand 1'
	'frame $www.def'
	'pack $www.def -side bottom -fill x -pady 2m'
	'label $www.def.lab -text ""This block creates a bus signal from its inputs""'
	'pack $www.def.lab -side left -expand 1']];
  tt= 'global opt;'+..
      'pack forget $www.signal.tr;'+..
      'pack forget $www.signal.lst;'+..
      'if {$opt == ""'+options(2)+'""} {'+..
      'pack $www.signal.lst -side left -expand 1;'+..
      '} '+..
      'else {'+..
      'pack $www.signal.tr -side left -expand 1;'+..
      '}'
  txt=[txt;
       ['proc updatelist {www} {'+tt+'}']]; 
  tt= 'global opt;'+..
      'if {$opt == ""'+options(2)+'""} {'+..
      '$www.rename.entry configure -state normal;'+..
      'global SelectedSignal;set SelectedSignal [$www.signal.lst curselection];'+..
      '$www.signal.lst configure -state disabled;'+..
      '$www.input.entry configure -state disabled;'+..
      '$www.inputbus.entry configure -state disabled;}'
  txt=[txt;
       ['proc doubleclick {www} {'+tt+'}']];
  tt='global SignalNumber;global BusNumber;'+..
     'set SignalState [$www.signal.lst cget -state];'+..
     'if {$SignalState!=""disabled""} {'+..
     'set InputNumber [$www.input.entry get];'+..
     'set InputBusNumber [$www.inputbus.entry get];'+..
     'if {$InputNumber > $SignalNumber} {'+..
     'incr SignalNumber;'+..
     'for {set i $SignalNumber} {$i <= $InputNumber} {incr i} {'+..
     'set SignalPosition [expr $i-1];'+..
     '$www.signal.lst insert $SignalPosition ""Signal$i"";'+..
     '$www.signal.tr insert $SignalPosition root Signal$i -text ""Signal$i"";};'+..
     '} '+..
     'elseif {$InputNumber < $SignalNumber} {'+..
     '$www.signal.lst delete $InputNumber [expr $SignalNumber-1];'+..
     'for {set i $InputNumber} {$i <=$SignalNumber} {incr i} {'+..
     '$www.signal.tr delete Signal[expr $i+1];}};'+..
     'set SignalNumber $InputNumber;'+..
     'if {$InputBusNumber > $BusNumber} {'+..
     'incr BusNumber;'+..
     'for {set i $BusNumber} {$i <= $InputBusNumber} {incr i} {'+..
     'set SignalPosition [expr $i+$SignalNumber-1];'+..
     '$www.signal.lst insert $SignalPosition ""Bus$i"";'+..
     '$www.signal.tr insert $SignalPosition root Bus$i -text ""Bus$i"";};'+..
     '} '+..
     'elseif {$InputBusNumber < $BusNumber} {'+..
     '$www.signal.lst delete [expr $InputBusNumber+$SignalNumber] [expr $BusNumber+$SignalNumber];'+..
     'for {set i $InputBusNumber} {$i <=$BusNumber} {incr i} {'+..
     '$www.signal.tr delete Bus[expr $i+1];}};'+..
     'set BusNumber $InputBusNumber;'+..
     '} '+..
     'else {'+..
     'global SelectedSignal;'+..
     'set RenamedSignal [$www.rename.entry get];'+..
     '$www.signal.lst configure -state normal;'+..
     'if {$RenamedSignal != """"} {'+..
     '$www.signal.lst insert $SelectedSignal ""$RenamedSignal"";'+..
     'incr SelectedSignal;'+..
     '$www.signal.lst delete $SelectedSignal;'+..
     '};'+..
     '$www.rename.entry configure -state disabled;'+..
     '$www.input.entry configure -state normal;'+..
     '$www.inputbus.entry configure -state normal;'+..
     '}'
  txt=[txt;
       ['proc refresh {www} {'+tt+'}']]; 
  tt='global inpnb;set inpnb [$www.input.entry get];'+..
     'global inpbus;set inpbus [$www.inputbus.entry get];'
  txt=[txt;
       ['proc done1 {www} {'+tt+'}']];
  txt=[txt;
       ['bind $www.inherit.menu <Expose> {refresh $www;updatelist $www}'
	'bind $www.signal.lst <Double-1> {refresh $www;doubleclick $www}'
	'bind $www.signal.refresh <ButtonRelease> {refresh $www}'
	'set done 0'
	'bind $www <Return> {set done 1}'
	'bind $www <Destroy> {set done 2}'
	'tkwait variable done'
	'if {$done==1} {refresh $www;done1 $www}']]
  TCL_EvalStr(txt);
  done=TCL_GetVar('done')
  if done==string(1) then
    inputnb=TCL_GetVar('inpnb');
    inputbusnb=TCL_GetVar('inpbus');
    Signals=TCL_GetVar('SignalsList');
    InheritSignal=find(options==TCL_GetVar('opt'))-1
    ok=%t
    //  inputnb=eval(inputnb);
    inputnb=evstr(inputnb);
    //  inputbusnb=eval(inputbusnb);
    inputbusnb=evstr(inputbusnb);
    indxstart=strindex(Signals,'{')
    indxend=strindex(Signals,'}')
    if ~isempty(indxstart) then
      SignalVect=part(Signals,[1:indxstart(1)-1])
      SignalVect=tokens(SignalVect)
      SignalVect=[SignalVect;part(Signals,[indxstart(1)+1:indxend(1)-1])]
      for i=2:size(indxstart,'*')
	SVect=part(Signals,[indxend(i-1)+1:indxstart(i)-1])
	SVect=tokens(SVect)
	SignalVect=[SignalVect;SVect;part(Signals,[indxstart(i)+1:indxend(i)-1])]
      end
      SVect=part(Signals,[indxend($)+1:length(Signals)])
      SVect=tokens(SVect)
      SignalVect=[SignalVect;SVect]
    else
      SignalVect=tokens(Signals);
    end
    Signals=SignalVect
  else
    ok=%f;inputnb=exprs(1);Signals=exprs(2);inputbusnb=exprs(3);InheritSignal=evstr(exprs(4));
  end
  TCL_EvalStr('destroy $www')
endfunction




