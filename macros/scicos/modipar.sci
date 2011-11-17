function [%state0,state,sim,ok]=modipar(newparameters,%state0,state,sim,scs_m,cor,job)

  function [ot,typ]=do_get_type(x)
  // returns types used internally in scicos 
  // for matrix and imatrix 
  // this function is used in some blocks definition 
  // 
    if (type(x,'string')=='Mat') then
      ot = 1 + b2m(~isreal(x,%t));
      typ='scalar';
    elseif (type(x,'string')=='IMat') then
      // take care that we have more int types in nsp
      typ= x.itype[];
      str=["","","int32","int16","int8","uint32","uint16","uint8"];
      ot= find(typ==str);
      if isempty(ot) then ot=9;end 
    else 
      typ=type(x,'string');
      ot=9
    end
  endfunction
  
  ok=%t
  if nargin<7 then job="default",end
  // store modified parameters in compiled structure state,sim
  // newparameters gives modified blocks numbers in original structure scs_m
  // cor is the correspondance table from original structure to compiled one
  // Copyright INRIA
  xptr=sim.xptr
  zptr=sim.zptr
  ozptr=sim.ozptr
  rpptr=sim.rpptr
  ipptr=sim.ipptr
  opptr=sim.opptr
  ipar=sim.ipar
  rpar=sim.rpar
  opar=sim.opar
  ztyp=sim.ztyp
  labels=sim.labels
  st=state.x
  dst=state.z
  odst=state.oz
  st0=%state0.x
  dst0=%state0.z
  odst0=%state0.oz

  Impl=%f
  if xptr($)-1 < size(st,'*') then
    std=st($/2+1:$)
    st=st(1:$/2)
    std0=st0($/2+1:$)
    st0=st0(1:$/2)
    Impl=%t
  end

  nb=prod(size(rpptr))-1
  for k=newparameters
    if prod(size(k))==1 then //parameter of a sImple block
      kc=cor(k) //index of modified block in compiled structure
      o=scs_m.objs(k)
    else
      kc=get_tree_elt(cor,k); 
      o=scs_m(get_subobj_path(k))
    end
    // o can be a deleted block which is strange ?
    if o.type == 'Deleted' then continue;end 
    if is_modelica_block(o) then
      parameters=o.model.equations.parameters
      //      rpark=[];for p=parameters(2),rpark=[rpark;p(:)];end
      opark=list();
      np=size(parameters(1),'*');
      for jop=1:np
        Parjv=parameters(2)(jop)
        Parjv_plat=Parjv(:);
        for jjop=1:size(Parjv_plat,'*')
	  opark($+1)=Parjv_plat(jjop)
        end
      end
      ipark=ipar(ipptr(kc):ipptr(kc+1)-1)
      corinvm=%cpr.corinv(kc);
      J=[];
      //if %cpr.corinv(kc-1)>size(cor) then ok=%f;return;end
      for jj=1:size(corinvm)
	if and(corinvm(jj)==k)  then J=jj;break,end
      end
      nek=size(opark)-(ipark(J+1)-ipark(J))
      if nek<>0 then
	warning('variying number of parameter for modelica block is not yet implemented')
      end
      //      rpar(rpptr(kc)+ipark(J)-1:rpptr(kc)+ipark(J+1)-2)=rpark
      for jop=1:ipark(J+1)-ipark(J)   
        opar(opptr(kc)+ipark(J)-2+jop)=opark(jop)
      end
    else
      // not a modelica block
      statekd=[]
      om=o.model
      if job=="compile" then
        omin=min(size(om.in,'*'),sim.inpptr(kc+1)-sim.inpptr(kc))
        // in case of sum size of om.in may be 3 but only 2 used
        for ix=1:omin
          io=state.outtb(sim.inplnk(sim.inpptr(kc)+ix-1))
          om.in(ix)=size(io,1)
          om.in2(ix)=size(io,2)
          om.intyp(ix)=do_get_type(io)
        end
        for ix=1:size(om.out,'*')
          io=state.outtb(sim.outlnk(sim.outptr(kc)+ix-1))
          om.out(ix)=size(io,1)
          om.out2(ix)=size(io,2)
          om.outtyp(ix)=do_get_type(io)
        end
        [om,ok]=do_job_compile(o,om,kc)
        if ~ok then
          message("Error in job compile of Block "+string(kc)),return,
        end
      end

      [fun,statek,dstatek,odstatek,rpark,ipark,opark]=...
          (om.sim,om.state,om.dstate,om.odstate,om.rpar,om.ipar,om.opar);
      if type(fun,'short')=='l' then
	if (fun(2)==3 | fun(2)==5 | fun(2)==10005) then
	  if ~isempty(rpark) then rpark=serialize(rpark,'m'); end
	  if ~isempty(dstatek) then dstatek=serialize(dstatek,'m'),end
	end
	if fun(2)>10000 then
	  statekd=statek($/2+1:$)
	  statek=statek(1:$/2)
	end
      end
      
      if kc>0 then
        //Change continuous state
        nek=prod(size(statek))-(xptr(kc+1)-xptr(kc))
        sel=xptr(kc+1):xptr($)-1
        if nek<>0 & ~isempty(sel) then
	  st(nek+sel)=st(sel)
	  st0(nek+sel)=st0(sel)
	  if Impl then
	    std(nek+sel)=std(sel)
	    std0(nek+sel)=std0(sel)
	  end
        end

        if nek<0 then
	  st($+nek+1:$)=[],st0($+nek+1:$)=[],
	  if Impl then std($+nek+1:$)=[],std0($+nek+1:$)=[],end
        end

        xptr(kc+1:$)=xptr(kc+1:$)+nek
        st(xptr(kc):xptr(kc+1)-1)=statek(:),
        st0(xptr(kc):xptr(kc+1)-1)=statek(:),
        if Impl then
	  if isempty(statekd) then statekd=0*statek,end
	  std(xptr(kc):xptr(kc+1)-1)=statekd(:),
	  std0(xptr(kc):xptr(kc+1)-1)=statekd(:),
        end

        //Change discrete  state
        nek=prod(size(dstatek))-(zptr(kc+1)-zptr(kc))
        sel=zptr(kc+1):zptr($)-1
        if nek<>0 & ~isempty(sel) then
	  dst(nek+sel)=dst(sel)
	  dst0(nek+sel)=dst0(sel)
        end

        if nek<0 then 
	  dst($+nek+1:$)=[],dst0($+nek+1:$)=[],
        end    

        zptr(kc+1:$)=zptr(kc+1:$)+nek
        dst(zptr(kc):zptr(kc+1)-1)=dstatek(:)
        dst0(zptr(kc):zptr(kc+1)-1)=dstatek(:)

        //Change objects discrete state
        if ((type(odstatek,'short')<>'l') | ...
	    (type(fun,'short')<>'l')) then //old sci blocks or odstatek not a list
          nek=-(ozptr(kc+1)-ozptr(kc))
        elseif ((fun(2)==5) | (fun(2)==10005)) then // sciblocks type 5 | 10005
          if size(odstatek)>0 then
            nek=1-(ozptr(kc+1)-ozptr(kc)) //nombre d'�tats suppl�mentaires
          else
            nek=-(ozptr(kc+1)-ozptr(kc))
          end
        elseif ((fun(2)==4) | (fun(2)==10004) | (fun(2)==2004)) then // C blocks type 4 | 10004
          nek=size(odstatek)-(ozptr(kc+1)-ozptr(kc))
        else // other C and sci blocks
          nek=-(ozptr(kc+1)-ozptr(kc))
        end
        sel=ozptr(kc+1):ozptr($)-1

        if nek<>0 & ~isempty(sel) then
          while size(odst)<max(nek+sel), odst($+1)=[], end
          while size(odst0)<max(nek+sel), odst0($+1)=[], end
          if nek>0 then sel=gsort(sel), end
          for j=sel
            odst(j+nek)=odst(j)
            odst0(j+nek)=odst0(j)
          end
        end
        ozptr(kc+1:$)=ozptr(kc+1:$)+nek;

        if ((type(odstatek,'short')=='l') & (type(fun,'short')=='l')) then
          if ((fun(2)==5) | (fun(2)==10005)) then // sciblocks
            if size(odstatek)>0 then
              odst(ozptr(kc))=odstatek;
              odst0(ozptr(kc))=odstatek;
            end
          elseif ((fun(2)==4) | (fun(2)==10004) | (fun(2)==2004)) then  // C blocks
            for j=1:size(odstatek)
              odst(ozptr(kc)+j-1)=odstatek(j);
              odst0(ozptr(kc)+j-1)=odstatek(j);
            end
          end
        end

        //## rebuild odst list if nek < 0
        if nek < 0 then
          n_odst = list(); n_odst0 = list();
          for j=1:max(ozptr)-1
            n_odst(j)=odst(j);
            n_odst0(j)=odst0(j);
          end
          odst = n_odst; odst0 = n_odst0;
          clear n_odst; clear n_odst0;
        end

        //Change real parameters
        nek=prod(size(rpark))-(rpptr(kc+1)-rpptr(kc))
        sel=rpptr(kc+1):rpptr($)-1
        if nek<>0 & ~isempty(sel) then
	  rpar(nek+sel)=rpar(sel)
        end

        if nek<0 then 
	  rpar($+nek+1:$)=[]
        end

        rpptr(kc+1:$)=rpptr(kc+1:$)+nek
        rpar(rpptr(kc):rpptr(kc+1)-1)=rpark(:),

        //Change integer parameters
        if type(ipark,'short')=='m' then   //scifunc
	  nek=prod(size(ipark))-(ipptr(kc+1)-ipptr(kc))
	  sel=ipptr(kc+1):ipptr($)-1
	  if nek<>0 & ~isempty(sel) then
	    ipar(nek+sel)=ipar(sel)
	  end

          if nek<0 then 
	    ipar($+nek+1:$)=[]
          end

	  ipptr(kc+1:$)=ipptr(kc+1:$)+nek
	  ipar(ipptr(kc):ipptr(kc+1)-1)=ipark(:), // ipar is column
        end
        //Change objects parameters
        if ((type(opark,'short')<>'l') | ...
	    (type(fun,'short')<>'l')) then //old sci blocks or odstatek not a list
          nek=-(opptr(kc+1)-opptr(kc))
        elseif ((fun(2)==5) | (fun(2)==10005)) then // sciblocks
          if size(opark)>0 then
            nek=1-(opptr(kc+1)-opptr(kc)) //nombre de parametres supplementaires
          else
            nek=-(opptr(kc+1)-opptr(kc))
          end
        elseif ((fun(2)==4) | (fun(2)==10004) | (fun(2)==2004)) then //C blocks
          nek=size(opark)-(opptr(kc+1)-opptr(kc))
        else // other C and sci blocks
          nek=-(opptr(kc+1)-opptr(kc))
        end
        sel=opptr(kc+1):opptr($)-1
        if nek<>0 & ~isempty(sel) then
          while size(opar)<max(nek+sel), opar($+1)=[], end
	  if nek>0 then sel=gsort(sel), end
          for j=sel, opar(j+nek)=opar(j); end
        end
        opptr(kc+1:$)=opptr(kc+1:$)+nek;
        if ((type(opark,'short')=='l') & (type(fun,'short')=='l')) then
          if ((fun(2)==5) | (fun(2)==10005)) then // sciblocks
	    if size(opark)>0 then
	      opar(opptr(kc))=opark;
	    end
          elseif ((fun(2)==4) | (fun(2)==10004) | (fun(2)==2004)) then //C blocks
            for j=1:size(opark), opar(opptr(kc)+j-1)=opark(j), end
          end
        end
        //## rebuild opar list if nek < 0
        if nek < 0 then
          n_opar = list();
          for j=1:max(opptr)-1
            n_opar(j)=opar(j);
          end
          opar = n_opar;
          clear n_opar;
        end


        //Change simulation routine
        if type(sim('funs')(kc),'short')<>'pl' then   //scifunc
	  sim('funs')(kc)=fun(1);
	  if prod(size(fun))> 1 then
	    sim('funtyp')(kc)=fun(2);
	  else
	    sim('funtyp')(kc)==0;
	  end
        end

	//Change label
	labels(kc)=o.model.label
      end
    end
  end

  sim.xptr=xptr
  sim.zptr=zptr
  sim.ozptr=ozptr
  sim.rpar=rpar
  sim.rpptr=rpptr
  sim.ipar=ipar
  sim.ipptr=ipptr
  sim.opar=opar
  sim.opptr=opptr
  sim.labels=labels

  if Impl then
    state.x=[st;std]
  else
    state.x=st
  end

  state.z=dst
  state.oz=odst
  if Impl then
    %state0.x=[st0;std0]
  else
    %state0.x=st0
  end
  %state0.z=dst0
  %state0.oz=odst0

endfunction

