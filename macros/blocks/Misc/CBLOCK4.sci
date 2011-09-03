function [x,y,typ]=CBLOCK4(job,arg1,arg2)
//
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
    x=arg1
    model=arg1.model;
    graphics=arg1.graphics;
    label_1=graphics.exprs(1)(1:19);
    label_2=graphics.exprs(2);

    gv_types=list('str',1,'str',1,'mat',[-1 2],'vec',-1,...
		  'mat',[-1 2],'vec',-1,'vec',-1,'vec',-1,...
		  'vec',-1,'vec',-1,'lis',-1,'vec',-1,...
		  'vec',-1,'lis',-1,'vec',1,'vec',1,'vec','sum(%8)',..
		  'str',1,'str',1);
    while %t do
      [ok,junction_name,impli,in,it,out,ot,ci,co,xx,z,oz,...
       rpar,ipar,opar,nmode,nzcr,auto0,depu,dept,lab]=..
	  getvalue('Set C-Block4 block parameters',..
		   ['Simulation function';
		    'Is block implicit? (y,n)';
		    'Input ports sizes';
		    'Input ports type';
		    'Output port sizes';
		    'Output ports type';
		    'Input event ports sizes';
		    'Output events ports sizes';
		    'Initial continuous state';
		    'Initial discrete state';
		    'Initial object state';
		    'Real parameters vector';
		    'Integer parameters vector';
		    'Object parameters list';
		    'Number of modes';
		    'Number of zero crossings';
		    'Initial firing vector (<0 for no firing)';
		    'Direct feedthrough (y or n)';
		    'Time dependence (y or n)'],...
		   gv_types,label_1);
      if ~ok then
        break
      end
      label_1=lab
      funam=stripblanks(junction_name)
      xx=xx(:);
      z=z(:);
      rpar=rpar(:);
      ipar=int(ipar(:));
      nx=size(xx,1);
      nz=size(z,1);

      ci=int(ci(:));
      nevin=size(ci,1);
      co=int(co(:));
      nevout=size(co,1);
      if part(impli,1)=='y' then
        if ~isempty(xx) then
          if int(nx/2)*2<>nx then
            message(['Warning for implicit block initial derivative state should also be defined.';
                     'Please check number of Initial continuous state.']);
            ok=%f;
          end
        end
	funtyp=12004
      else
	funtyp=2004
      end
      if ~isempty([ci;co]) then
        if max([ci;co])>1 then
          message('vector event links not supported');
          ok=%f;
        end
      end

      if ok then
        depu=stripblanks(depu);
        if part(depu,1)=='y' then
          depu=%t;
        else
          depu=%f;
        end
        dept=stripblanks(dept);
        if part(dept,1)=='y' then
          dept=%t;
        else
          dept=%f;
        end
        dep_ut=[depu dept];

        if funam==' ' then
          break
        end

        //cross checking
        if model.sim(1)<>funam|sign(size(model.state,'*'))<>sign(nx)|..
	      sign(size(model.dstate,'*'))<>sign(nz)|model.nzcross<>nzcr|..
	      sign(size(model.evtout,'*'))<>sign(nevout) then
	  tt=[]
        end

        tt=label_2;

        [model,graphics,ok]=set_io(model,graphics,list(in,it),list(out,ot),ci,co)
      end

      if ok then

        libss  = graphics.exprs(1)(20)
        cflags = graphics.exprs(1)(21)
        while %t
          [ok,tt,cancel,libss,cflags]=CC4(funam,tt,libss,cflags)
          if ~ok then
            if cancel then break,end
          else
            model.sim=list(funam,funtyp)
            model.state=xx
            model.dstate=z
            model.odstate=oz
            model.rpar=rpar
            model.ipar=ipar
            model.opar=opar
            model.firing=auto0
            model.nzcross=nzcr
            model.nmode=nmode
            model.dep_ut=dep_ut
            if isempty(libss) then libss='', end
            if isempty(cflags) then cflags='', end
            label=list([label_1;libss;cflags],tt)
            x.model=model
            graphics.exprs=label
            x.graphics=graphics
            break
          end
        end

        if ok|cancel then
          break
        end
      end
    end

   case 'define' then

    funam='toto'
    model=scicos_model()
    model.sim=list(' ',2004)

    model.in=1
    model.in2=1
    model.intyp=1
    model.out=1
    model.out2=1
    model.outtyp=1
    model.dep_ut=[%t %f]
    label=list([funam;                          //1
                'n';                            //2
                sci2exp([model.in model.in2]);  //3
                sci2exp(model.intyp);           //4
                sci2exp([model.out model.out2]) //5
                sci2exp(model.outtyp);          //6
                sci2exp(model.evtin);           //7
                sci2exp(model.evtout);          //8
                sci2exp(model.state);           //9
                sci2exp(model.dstate);          //10
                sci2exp(model.odstate);         //11
                sci2exp(model.rpar);            //12
                sci2exp(model.ipar);            //13
                sci2exp(model.opar);            //14
                sci2exp(model.nmode);           //15
                sci2exp(model.nzcross);         //16
                sci2exp(model.firing);          //17
                'y';                            //18
                'n';                            //19
                '';                             //20
                ''],...                         //21
	       []);

    gr_i=['xstringb(orig(1),orig(2),''C block4'',sz(1),sz(2),''fill'');']
    x=standard_define([2 2],model,label,gr_i,'CBLOCK4');
  end
endfunction


