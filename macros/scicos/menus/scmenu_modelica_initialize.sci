
function Modelicainitialize_()
// Copyright INRIA
if ~super_block then
  Cmenu=''

  name=scs_m.props.title(1);
  if ~validvar(name) then 
    x_message([name;'is not a valid name, please change the title of the diagram.']);
    return
  end
  
  name=stripblanks(name)+'_im';
  TMPDIR=getenv('NSP_TMPDIR')
  path=TMPDIR+'/';
  //FIXME
  //path=pathconvert(stripblanks(path),%t,%t)
  
  mofile=path+name+'.mo';
  xmlfile=path+name+'f_init.xml';
//========================================
  compile=%f;

  err1=file("exists",xmlfile)
  err2=file("exists",mofile)

  if (err1 & err2) then
    if (newest(xmlfile,mofile)==2) then compile=%t;end;
  else 
    compile=%t;
  end

  compile=%t; // Very conservative

  if (needcompile>=2) then
    compile=%t;// needcompile=2: when context changes  
	       // needcompile=4: when model chanegs & it's not compiled
  end
  ok=%t
  //if (fileinfo(xmlfile)==[]) then 
    needcompile=4;
  //end
  
  if compile then 
    %Modelica_Init=%t
    // in order to generate *_im.mo -> *_im_f.mo -> *_im.xml 
    [bllst,connectmat,clkconnect,cor,corinv,ok]=c_pass1(scs_m);    
    %Modelica_Init=%f
    if ok then
      err1=file("exists",xmlfile)
      if err1 then

// 	scimihm xmlfile
        demo_xml(xmlfile)
      end  
    end
  end
else
    Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
		       'Cmenu='"Modelica initialize'";%scicos_navig=[]';
		       '%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1']
end

endfunction

function  Doubleclick(name,last_name)
 
  %cpr=tlist(['cpr','corinv'],corinv)

  if last_name<>"" then unhilite_modelica_block(modelica_cind_from_name(last_name));end
  hilite_modelica_block(modelica_cind_from_name(name))

endfunction
