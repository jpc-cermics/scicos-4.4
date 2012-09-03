function scmenu_modelica_initialize()
// Copyright INRIA

  if super_block then 
    Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
		     'Cmenu='"Modelica initialize'";%scicos_navig=[]';
		     '%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1'];
    return;
  end
  
  Cmenu=''
  name=scs_m.props.title(1);
  if ~validvar(name) then 
    x_message([name;'is not a valid name, please change the title of the diagram.']);
    return
  end
  name=stripblanks(name)+'_im';
  TMPDIR=getenv('NSP_TMPDIR')
  mofile=file('join',[getenv('NSP_TMPDIR');name+'.mo']);
  xmlfile=file('join',[getenv('NSP_TMPDIR');name+'f_init.xml']);
  //========================================
  compile=%f;
  if file("exists",xmlfile) && file("exists",mofile)  then
    if (newest(xmlfile,mofile)==2) then compile=%t;end;
  else 
    compile=%t;
  end
  // be very conservative !
  compile=%t; 

  if (needcompile>=2) then
      compile=%t;// needcompile=2: when context changes  
      // needcompile=4: when model changes & it's not compiled
    end
    ok=%t
    needcompile=4;
    if compile then 
      %Modelica_Init=%t
      // in order to generate *_im.mo -> *_im_f.mo -> *_im.xml 
      [bllst,connectmat,clkconnect,cor,corinv,ok]=c_pass1(scs_m);    
      %Modelica_Init=%f
      if ok then
	if file("exists",xmlfile) then
          //remove oldest modelica initialize window
          for i=1:length(scicos_widgets)
            if scicos_widgets(i).what.equal['ModelicaInitialize'] then
              if scicos_widgets(i).open==%t then
                scicos_widgets(i).id.destroy[]
                break 
              end
            end
          end
	  scicos_widgets($+1)=hash(id=demo_xml(xmlfile),open=%t,what='ModelicaInitialize')
	end  
      end
    end
endfunction

function  Doubleclick(name,last_name)
  %cpr=tlist(['cpr','corinv'],corinv)
  if last_name<>"" then 
    unhilite_modelica_block(modelica_cind_from_name(last_name));
  end
  hilite_modelica_block(modelica_cind_from_name(name))
endfunction
