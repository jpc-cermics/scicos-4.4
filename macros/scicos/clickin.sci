function [o,modified,newparameters,needcompile,edited]=clickin(o)
//  o             : structure of clicked object, may be modified
//  modified      : boolean, indicates if simulation time parameters
//                  have been changed
//  newparameters : only defined for super blocks, gives pointers to
//                  sub-blocks for which parameters or states have been changed
//  needcompile   : indicates if modification implies a new compilation
//
//
  // for standard_document to work
  if needcompile==4 then %cpr=list() end

  edited=%f;
  modified=%f;newparameters=list();needcompile=0;
  if %diagram_open then
    Cmenu=check_edge(o, Cmenu, %pt); 
    if Cmenu==("Link") then
      resume(Cmenu='Link')
      return
    end
  end

  if o.type =='Block' then
    if o.model.sim(1)=='super' | o.gui=='PAL_f' then
      lastwin=curwin
      global inactive_windows
      jkk=[]
      for jk=1:size(inactive_windows(2),'*')
        if isequal(inactive_windows(1)(jk),super_path) then 
          jkk=[jkk,jk]
        end
      end
      curwinc=-1
      for jk=jkk 
        curwinc=inactive_windows(2)(jk)
        inactive_windows(1)(jk)=null();inactive_windows(2)(jk)=[]
        curwin=curwinc           
      end
      if curwinc<0 then
        curwin=get_new_window(windows); //** need a brand new window where open the 
      end
      if %diagram_open then xset('window',curwin), end
      if o.model.sim(1)=="super" then //## superblock
        ierr=execstr('[o_n,needcompile,newparameters]='+o.gui+'(''set'',o)',errcatch=%t)
      else //## palette block
        ierr=execstr('[o_n,y,typ]='+o.gui+'(''set'',o)',errcatch=%t);
      end
      if ~ierr then
        printf('Error in GUI of block %s\n',o.gui);
        printf("%s\n",lasterror());
        return
      end
      if ~%exit then
        edited=~and(o==o_n);
        if edited then
          o=o_n
          modified=prod(size(newparameters))>0
        end
      else
        //Alan : AVERIFER
        global Scicos_commands
        Scicos_commands=['Cmenu='''';%win=curwin;%pt=[];xselect();%scicos_navig=[]']
      end
      curwin=lastwin
      if(~(or(curwin==winsid()))) then
       resume(Cmenu='Open/Set')
       return
      end
      xset('window',curwin)
      //xselect()
    
    elseif o.model.sim(1)=='csuper' && o.model.ipar.equal[1] then
      // this is a masked superblock 
      %scs_help=o.gui
      ierr=execstr('[o_n,needcompile,newparameters]='+o.gui+'(''set'',o)',errcatch=%t)
      if ~ierr then
        printf('Error in GUI of block %s\n',o.gui);
	printf("%s\n",lasterror());
	return
      end
      modified=prod(size(newparameters))>0
      edited=~and(o==o_n);
      if edited then
        o=o_n
      end

    elseif o.model.sim(1)=='csuper' then
      // ?
      %scs_help=o.gui
      ierr=execstr('[o_n,needcompile,newparameters]='+o.gui+'(''set'',o)',errcatch=%t)
      if ~ierr then
        printf('Error in GUI of block %s\n',o.gui);
	printf("%s\n",lasterror());
        return
      end
      modified=prod(size(newparameters))>0
      edited=~and(o==o_n);
      if edited then
        o=o_n
      end

    elseif o.model.sim(1)=='asuper' then
      message(['This is an atomic superblock';..
               'To edit the block, you must first remove atomicity']);

    else
      // standard block
      %scs_help=o.gui
      ierr=execstr('o_n='+o.gui+'(''set'',o)',errcatch=%t)
      if ~ierr then
        printf('Error in GUI of block %s\n',o.gui);
	printf("%s\n",lasterror());
        return
      end
      edited=or(o<>o_n)

      if edited then
        model=o.model
        model_n=o_n.model
        if ~is_modelica_block(o) then
          modified=~model.equal[model_n]
          if or(model.in<>model_n.in)|or(model.out<>model_n.out)|..
             or(model.in2<>model_n.in2)|or(model.out2<>model_n.out2)|..
             or(model.outtyp<>model_n.outtyp)|or(model.intyp<>model_n.intyp) then
            // input or output port sizes changed
            needcompile=1
          end
          if or(model.firing<>model_n.firing) then
            // initexe changed
            needcompile=2
          end
          if (size(model.in,'*')<>size(model_n.in,'*'))|..
                (size(model.out,'*')<>size(model_n.out,'*'))|..
                 (size(model.evtin,'*')<>size(model_n.evtin,'*'))|..
                  (size(model.evtout,'*')<>size(model_n.evtout,'*')) then
            // number of input or output changed
            needcompile=4
          end
          if model.sim(1)=='input'|model.sim(1)=='output' then
            if model.ipar<>model_n.ipar then
              needcompile=4
            end
          end
          if or(model.blocktype<>model_n.blocktype)|
            or(model.dep_ut<>model_n.dep_ut)  then
            // type 'c','d','z','l' or dep_ut changed
            needcompile=4
          end
          if (model.nzcross<>model_n.nzcross)|(model.nmode<>model_n.nmode) then
            // size of zero cross changed
            needcompile=4
          end
          if size(model_n.sim,'*')>1 then
            if model_n.sim(2)>1000 then  // Fortran or C Block
              if model.sim(1)<>model_n.sim(1) then  //function name has changed
                needcompile=4
              end
            end
          end
        else //implicit block
          //force compilation if an implicit block has been edited
          modified=or(model_n<>model)
          eq=model.equations;eqn=model_n.equations;
	  if or(eq.model<>eqn.model)|| ~eq.inputs.equal[eqn.inputs] ||  ...
		~eq.outputs.equal[eqn.outputs] then
            needcompile=4
          end
          //## if a parameters have change in a modelica block then force
          //## the recompilation
          if ~isequal(eq.parameters,eqn.parameters) then
            param_name   = eq.parameters(1);
            param_name_n = eqn.parameters(1);
            if ~isequal(param_name,param_name_n) then
              needcompile=4
            elseif ~eq.parameters(2).equal[eqn.parameters(2)] then
	      needcompile=0 // BIZARRE !!!!
	      TMPDIR=getenv('NSP_TMPDIR')
	      XML=file('join',[TMPDIR,stripblanks(scs_m.props.title(1))+'_imf_init.xml']);
	      isok=execstr("file(""delete"",XML)",errcatch=%t)
	      if ~isok then
		x_message(['Unable to delete the XML file'])
		lasterror();
		return;
	      end
	      XMLTMP=file('join',[TMPDIR,stripblanks(scs_m.props.title(1))+'_imSim.xml']);
	      isok=execstr("file(""delete"",XMLTMP)",errcatch=%t)
	      if ~isok then
		x_message(['Unable to delete the XML file'])
		lasterror();
		return;
	      end
	    end
	  end
          if size(o.model.sim,'*')>1 then
            if (o.model.sim(2)==30004) then // only if it is the Modelica generic block
              if or(o.graphics.exprs<>o_n.graphics.exprs) then  // if equation in generic Modelica Mblock change
                needcompile=4
                modified=%t; 
              end
            end
          end
        end
        o=o_n;
      end
    end
  elseif o.type  =='Link' then
    // 
    resume(Cmenu='Link');
  elseif o.type  =='Text' then
    //
    eok=execstr('o_n='+o.gui+'(''set'',o)',errcatch=%t)
    if ~eok then
      message('Error in GUI of block %s\n',o.gui);
      printf("%s\n",lasterror());
      return;
    end
    edited=~o.equal[o_n];
    o=o_n
  end
endfunction
