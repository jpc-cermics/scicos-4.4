function Info=scicos_simulate(scs_m,Info,%scicos_context,flag,Ignb)
// Function for running scicos simulation in batch mode
// Info=scicos_simulate(scs_m[,Info][,%scicos_context][,flag]...
//                      [,Ignb])
//
// scs_m: scicos diagram (obtained by "load file.cos"). Note that
// the version of file.cos must be the current version. If not, load
// into scicos and save.
//
// %scicos_context: a scilab struct containing values of
// symbolic variables used in the context and Scicos blocks. This
// is often used to change a parameter in the diagram context. In that
// case, make sure that in the diagram context the variable is defined such
// that it can be modified. Say a variable "a" is to be defined in the
// context having value 1, and later in batch mode, we want to change
// the value of "a". In that case, in the context of the diagram place: 
//  if ~exists('a','all') then a=1,end
// If you want then to run the simulation in batch mode using the value
// a=2, set:
// %scicos_context.a=2
//
// Info: a list. It must be list() at the first call, then use output
// Info as input Info for the next calls. Info contains compilation and
// simulation information and is used to avoid recompilation when not
// needed.
//
// flag: string. If it equals 'nw' (no window), then blocks using
// graphical windows are not executed. Note that the list of such
// blocks must be updated as new blocks are added.
//
// Ignb : matrix of string : The name of blocks to ignore.
// If flag is set and equal to 'nw' then Ignb contains
// name of blocks that are added to the list
// of blocks to ignore.
//

  //TODO
  //noguimode=find(sciargs()=="-nogui");
  //if (noguimode <>[]) then
  //   clear noguimode
  //   flag='nw'
  //    warning(" Scilab in no gui mode : Scicos unavailable");
  //    abort;
  //end;
  //clear noguimode

  //** define Scicos data tables
  scicos_library_initialize()

  //** initialize a "scicos_debug_gr" variable
  %scicos_debug_gr = %f;

  //** list of scopes to ignore
  Ignoreb=['bouncexy',...
           'cscope',...
           'cmscope',...
           'canimxy',...
           'canimxy3d',...
           'cevscpe',...
           'cfscope',...
           'cscopexy',...
           'cscopexy3d',...
	   'cscopxy',..
	   'cscopxy3d',..
           'cmatview',...
           'cmat3d',...
           'affich',...
           'affich2']

  //** redefine some gui functions
  function disablemenus()
    return
  endfunction
  function enablemenus()
    return
  endfunction
  do_terminate=do_terminate1

  //** check/set rhs parameters
  if nargin==1 then
    Info=list()
    %scicos_context=hash(1)
    flag=[]
    Ignb=[]
  elseif nargin==2 then
    if isequal(type(Info,'short'),'s') then
      if (stripblanks(Info)=='nw') then
        Info=list()
        flag='nw'
      else
        Info=list()
        flag=[]
      end
    elseif ~isequal(type(Info,'short'),'l') then
      Info=list()
      flag=[]
    else
      flag=[]
    end
    %scicos_context=hash(1)
    Ignb=[]
  elseif nargin==3 then
    if ~isequal(type(Info,'short'),'l') then
      Info=list()
    end
    if isequal(type(%scicos_context,'short'),'s') then
      if (stripblanks(%scicos_context)=='nw') then
        %scicos_context=hash(1)
        flag='nw'
      else
        %scicos_context=hash(1)
        flag=[]
      end
    elseif ~isequal(type(%scicos_context,'short'),'h') then
      %scicos_context=hash(1)
      flag=[]
    else
      flag=[]
    end
    Ignb=[]
  elseif nargin==4 then
    if ~isequal(type(Info,'short'),'l') then
      Info=list()
    end
    if ~isequal(type(%scicos_context,'short'),'h') then
      %scicos_context=hash(1)
    end
    if ~isequal(type(flag,'short'),'s') then
     flag=[]
    elseif ~isequal(stripblanks(flag),'nw') then
       flag=[]
    end
    Ignb=[]
  elseif nargin==5 then
    if ~isequal(type(Info,'short'),'l') then
      Info=list()
    end
    if ~isequal(type(%scicos_context,'short'),'h') then
      %scicos_context=hash(1)
    end
    if ~isequal(type(flag,'short'),'s') then
      flag=[]
    elseif ~isequal(stripblanks(flag),'nw')
      flag=[]
    end
    if ~isequal(type(Ignb,'short'),'s') then
      Ignb=[]
    else
      Ignb=(Ignb(:))'
    end
  else
     error('scicos_simulate : wrong number of parameters.')
  end

  [ierr,scicos_ver,scs_m]=update_version(scs_m)
  if ~ierr then
    message("Can''t convert old diagram (problem in version)")
    return
  end

  //prepare from and to workspace stuff
  //curdir=getcwd()
  //chdir(TMPDIR)
  //mkdir('Workspace')
  //chdir('Workspace')
  //%a=who('get');
  //%a=%a(1:$-predef()+1);  // exclude protected variables
  //for %ij=1:size(%a,1) 
  //  var=%a(%ij)
  //  if var<>'ans' & typeof(evstr(var))=='st' then
  //    ierr=execstr('x='+var+'.values','errcatch')
  //    if ierr==0 then
  //      ierr=execstr('t='+var+'.time','errcatch')
  //    end
  //    if ierr==0 then
  //      execstr('save('"'+var+''",x,t)')
  //    end
  //  end
  //end
  //chdir(curdir)
  // end of /prepare from and to workspace stuff

  Ignore=['affich',...
          'affich2']

  if isequal(flag,'nw') then
    Ignore=Ignoreb
  end

  if ~isempty(Ignb) then
    Ignore=[Ignore,Ignb]
  end

  //** retrieve Info list
  if ~isempty(Info) then
    [%tcur,%cpr,alreadyran,needstart,needcompile,%state0]=Info(:)
  else
    %tcur=0;%cpr=list();alreadyran=%f;needstart=%t;needcompile=4;%state0=list();
  end
  //** set solver
  tolerances=scs_m.props.tol
  solver=tolerances(6)
  %scicos_solver=solver

  //** set variables of context
  [%scicos_context,ierr]=script2var(scs_m.props.context, ...
				    %scicos_context);
  if isequal(ierr,0) then 
    [scs_m,%cpr,needcompile,ok]=do_eval(scs_m,%cpr,%scicos_context);
    if needcompile<>4&size(%cpr)>0 then %state0=%cpr.state,end
    alreadyran=%f
  else
      error(['Incorrect context definition'+catenate(lasterror())] )
  end

  if isempty(%cpr)|needcompile>1 then need_suppress=%t, else need_suppress=%f,end
  [%cpr,%state0_n,needcompile,alreadyran,ok]=..
      do_update(%cpr,%state0,needcompile)
  if ~ok then error('Error updating parameters.'),end

  if ~%state0_n.equal[%state0] then //initial state has been changed
    %state0=%state0_n
    [alreadyran,%cpr]=do_terminate1(scs_m,%cpr)
    choix=[]
  end
  if %cpr.sim.xptr($)-1<size(%cpr.state.x,'*') & solver<100 then
    printf("\n\r Diagram has been compiled for implicit solver, switching to implicit Solver!\n\r")
    solver=100
    tolerances(6)=solver
  elseif (%cpr.sim.xptr($)-1==size(%cpr.state.x,'*')) & ..
	( solver==100 & size(%cpr.state.x,'*')<>0) then
    printf("\n\r Diagram has been compiled for explicit solver, switching to explicit Solver!\n\r")
    solver=0
    tolerances(6)=solver
  end

  if need_suppress then //this is done only once
    for i=1:length(%cpr.sim.funs)
      if ~isequal(type(%cpr.sim.funs(i),'short'),'pl') then
        if ~isempty(find(%cpr.sim.funs(i)(1)==Ignore)) then
          %cpr.sim.funs(i)(1)='trash';
        end
      end
    end
  end

  if needstart then //scicos initialisation
    if alreadyran then
      [alreadyran,%cpr]=do_terminate1(scs_m,%cpr);
      alreadyran=%f;
    end
    %tcur=0;
    %cpr.state=%state0;
    tf=scs_m.props.tf;
    if isempty(tf*tolerances) then 
      error(['Simulation parameters not set']);
    end

    TMPDIR=getenv('NSP_TMPDIR')
    XML=file('join',[TMPDIR,stripblanks(scs_m.props.title(1))+'_imf_init.xml']);
    XMLTMP=file('join',[TMPDIR,stripblanks(scs_m.props.title(1))+'_imSim.xml']);
    
    if file("exists",XML) then
      isok=execstr("file(""copy"",[XML,XMLTMP])",errcatch=%t)
      if ~isok then
        message(['Unable to copy XML files']);
        return
      end
      
      //x_message(['Scicos cannot find the XML data file required for the simulation';..
      //	 'please either compile the diagram, in this case Sccios uses'; 
      //	 'parameters defined in Scicos blocks and the Scicos context';
      //	 'or you can save the XML file defined in the initialization GUI']);
      //return;
    end

    ierr=execstr('[state,t]=scicosim(%cpr.state,%tcur,tf,%cpr.sim,'+..
                 '''start'',tolerances)',errcatch=%t)
    if ~ierr then
      error(['Initialisation problem:'])
    end
    %cpr.state=state
  end

  ierr=execstr('[state,t]=scicosim(%cpr.state,%tcur,tf,%cpr.sim,'+..
               '''run'',tolerances)',errcatch=%t)

  if ierr then
    %cpr.state=state;
    alreadyran=%t;
    if tf-t<tolerances(3) then
      needstart=%t;
      [alreadyran,%cpr]=do_terminate1(scs_m,%cpr);
    else
      %tcur=t;
    end
  else
    error(['Simulation problem:';lasterror()])
  end

  Info=list(%tcur,%cpr,alreadyran,needstart,needcompile,%state0)

  //[txt,files]=returntoscilab()
  //n=size(files,1)
  //for i=1:n
  //  load(TMPDIR+'/Workspace/'+files(i))
  //  execstr(files(i)+'=struct('"values'",x,'"time'",t)')
  //end
  //execstr(txt)
endfunction

function [alreadyran,%cpr]=do_terminate1(scs_m,%cpr)
  if exists('alreadyran','all');alreadyran=alreadyran ;else alreadyran=%f;end;
  if prod(size(%cpr))<2 then alreadyran=%f,return,end
  par=scs_m.props;

  if alreadyran then
    alreadyran=%f
    //terminate current simulation
    ierr=execstr('[state,t]=scicosim(%cpr.state,par.tf,par.tf,'+..
                 '%cpr.sim,''finish'',par.tol)',errcatch=%t)

    %cpr.state=state
    if ~ierr then
      error(['End problem:';lasterror()])
    end
  end
endfunction
