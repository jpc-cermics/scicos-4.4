function scs_m = changeports(scs_m, path, o_n)
// Copyright INRIA
// Last Update Fady: 15 Dec 2008
//
// This function is able to replace any block with any other block. 
// We made a reasonable effort to reutilize the information associated 
// at the ports with the aim to mantain the connections.
// When the connection are incompatible, the links are removed.
// The existing links are moved in order to match the port's positions.
// ToDo : adjust the links in square angle (horizontal and vertical links only).
// some observations:
//  a) utilise a forced, fixed, two pass approach it is a bit redundant for "trivial
//     operation" (e.g. replace a block not connected) ...
//  b) we do not exclude the possibility of the necessity of a multiple pass approach,
//     e.g. implement a "while(LinkToDel<>[])" loop. 
//  This code can be validate by visual inspection only : look at the
//  results !  
//
  k = path($) ; //** the scs_m index of the target
  curwin = acquire('curwin',def=-1);
  if or(curwin==winsid()) then
    F=get_figure(curwin);
    F.draw_latter[];
    o_n=drawobj(o_n,F);
    o_n.gr.invalidate[]; // maybe useless 
    F.draw_now[];
  end
  
  // The very first time the this routine try to match the ports of the new blocks over the ports
  // of the old one.
  // "LinkToDel" is a vector of "scs_m" index of connected links of the old blocks that cannot be
  // relocated on the new one and must be deleted  
  // A second pass is indispensable because...
  // a) the deletion of some links can create new unconnected ports on the original block;
  // b) do_delete1() can create some brand new links that need to be deleted again (this is
  //    a side effect of the deletion in sequence); 

  for pass=1:2 
    
    [scs_m, o_n, LinkToDel] = match_ports(scs_m, path, o_n);
    // Delete the links relative at the unconnected (non allocated) ports 
    for i=1:size(LinkToDel,'*')
      Link_index = LinkToDel(i) ; //** the Link to be deleted
      gr = %t                   ; //** update the screen
      [scs_m, DEL, DELL] = do_delete1(scs_m, Link_index, gr) ; //** delete the links
    end 
  end
    
  // update scs_m 
  
  scs_m.objs(k) = o_n ;
endfunction

function [scs_m, o_n, LinkToDel] = match_ports(scs_m, path, o_n)
  //** ---- INITIALIZATION ----
  //** isolate the object that will be substituited
  curwin = acquire('curwin',def=-1);
  o = scs_m(path) ;
  options=scs_m.props.options
  smart=options('Action')==%f; //...
			     
  //** extract the proprieties of the OLD object 
  [pin, pout, pein, peout, in_mod, out_mod] = (o.graphics.pin,  o.graphics.pout, ...
                                               o.graphics.pein, o.graphics.peout, ...
                                               o.graphics.in_implicit, o.graphics.out_implicit);
  
  //** "o_n" is the NEW object 
  [pin_n, pout_n, pein_n, peout_n, in_mod_n, out_mod_n] = (o_n.graphics.pin,  o_n.graphics.pout, ...
                                                           o_n.graphics.pein, o_n.graphics.peout, ...
							   o_n.graphics.in_implicit, o_n.graphics.out_implicit);
  //** ---------------------------------------------
  //**
  //** acquire the dimension of the new block input and output ports and
  //** put all the ports of the new block in unconnected [0] state  

  size_pin_n = size(pin_n,'*')  ;
  pin_n = zeros(size_pin_n, 1 ) ;

  size_pout_n = size(pout_n,'*') ;
  pout_n = zeros(size_pout_n, 1) ;

  size_pein_n = size(pein_n,'*') ;
  pein_n = zeros(size_pein_n, 1) ;

  size_peout_n = size(peout_n,'*') ;
  peout_n = zeros(size_peout_n, 1) ;

  //** Acquire the size of the old block
  size_pin   = size(pin,'*')   ;
  size_pout  = size(pout,'*')  ;
  size_pein  = size(pein,'*')  ;
  size_peout = size(peout,'*') ;

  //** ------------ QUICK & DIRTY TRICK -------------
  //** This code "export back" the "E" (explicit, standard) / "I" (implicit, Modelica)
  //** proprieties to the "old" block because very old block/superblock does not have
  //** these proprieties

  //** for the "old blocks" input(s) with not defined proprieties
  if isempty(in_mod_n) then
    I='E'
    in_mod_n=I(ones(size_pin_n,1))
  end

  if isempty(in_mod) then 
    in_mod = in_mod_n ; //** "export back" the "E" / "I"
  end 

  //** for the "old blocks" output(s) with not defined proprieties
  if isempty(out_mod_n) then
    I='E'
    out_mod_n=I(ones(size_pout_n,1))
  end

  if isempty(out_mod) then
    out_mod = out_mod_n ; //** "export back" the "E" / "I"
  end

  //**-----------------------------------------------

  //** New object ports position and type 
  //** x , y : absolute coordinates of the port 
  //** t     : 1 (standard); -1 (event) ; 2 (Modelica) ; 3 (buses)
  execstr('[xin, yin, tin]='+o.gui+'(''getinputs'', o)');
  execstr('[xin_n, yin_n, tin_n]='+o.gui+'(''getinputs'', o_n)');

  execstr('[xout, yout, tout]='+o.gui+'(''getoutputs'',o)');
  execstr('[xout_n, yout_n, tout_n]='+o.gui+'(''getoutputs'',o_n)');

  size_inputs   = size(tin,'*')     ;
  size_inputs_n = size(tin_n,'*')   ;
  size_outputs    = size(tout,'*')   ;
  size_outputs_n  = size(tout_n,'*') ;

  //** Inputs of the OLD block 
  xsmin=[] ; ysmin =[] ; tsmin = []; xein = [] ; yein = []
  for i=1:size_inputs
    if tin(i)==1 | tin(i)==2 | tin(i)==3 then
      // standard,buses OR Modelica input
      xsmin = [ xsmin xin(i) ] ;
      ysmin = [ ysmin yin(i) ] ;
      tsmin = [ tsmin tin(i) ] ;
    elseif tin(i)==-1 then //** event input
      xein  = [ xein xin(i) ] ;
      yein  = [ yein yin(i) ] ;
    else
      printf("InOLD:The input type is unknow\n"); pause
    end
  end
  
  //** Inputs of the NEW block
  xsmin_n=[] ; ysmin_n =[] ; tsmin_n = []; xein_n = [] ; yein_n = []
  for i=1:size_inputs_n
     if tin_n(i)==1 | tin_n(i)==2 | tin_n(i)==3 then
       //** standard,buses OR Modelica input
       xsmin_n = [ xsmin_n xin_n(i) ] ;
       ysmin_n = [ ysmin_n yin_n(i) ] ;
       tsmin_n = [ tsmin_n tin_n(i) ] ;
     elseif tin_n(i)==-1 then //** event input
       xein_n  = [ xein_n xin_n(i) ] ;
       yein_n  = [ yein_n yin_n(i) ] ;
     else
       printf("InNew:The input type is unknow\n"); pause
     end 
  end 
  //** Outputs of the OLD block 
  xsmout=[] ; ysmout =[] ; tsmout = []; xeout = [] ; yeout = []
  for i=1:size_outputs
    if tout(i)==1 | tout(i)==2 |tout(i)==3 then 
       //** standard,buses OR Modelica output
        xsmout = [ xsmout xout(i) ] ;
	ysmout = [ ysmout yout(i) ] ;
	tsmout = [ tsmout tout(i) ] ;
     elseif tout(i)==-1 then //** event input
        xeout  = [ xeout xout(i) ] ;
	yeout  = [ yeout yout(i) ] ;
     else
       printf("OutOLD:The output type is unknow\n"); pause
    end
  end
  //** Outputs of the NEW block
  xsmout_n=[] ; ysmout_n =[] ; tsmout_n = []; xeout_n = [] ; yeout_n = []
  for i=1:size_outputs_n
    if tout_n(i)==1 | tout_n(i)==2 | tout_n(i)==3 then 
      //** standard,buses OR Modelica output
        xsmout_n = [ xsmout_n xout_n(i) ] ;
        ysmout_n = [ ysmout_n yout_n(i) ] ;
        tsmout_n = [ tsmout_n tout_n(i) ] ;
     elseif tout_n(i)==-1 then //** event input
        xeout_n  = [ xeout_n xout_n(i) ] ;
        yeout_n  = [ yeout_n yout_n(i) ] ;
     else
       printf("OutNew:The output type is unknow\n"); pause
     end
  end
  //** variables for input link
  InputLinkToCon = []; xInPortToCon = []; yInPortToCon = []; NumInPortToCon = [];
  //** variables for output link
  OutputLinkToCon = []; xOutPortToCon = []; yOutPortToCon = []; NumOutPortToCon = [];

  LinkToDel = [];

  //** disp("...changeports... : inspect variables"); pause //** DEBUG ONLY

  //**------------------ INPUT PORTS ---------------------------------------------------------------
  if size_pin >0 then

    for i=1:size_pin //** for all the input "pin" of the old block 
       //** if the port is linked AND the new block has enough ports AND the two ports are of the same E/I
       //**                                                    AND the same Standard/Modelica type
       if  pin(i)>0 & i<=size_pin_n then
         if isequal(in_mod(i),in_mod_n(i)) & isequal(tsmin(i),tsmin_n(i)) then
           pin_n(i) = pin(i); //** assign the port to the old Link
           InputLinkToCon = [InputLinkToCon pin(i)] ;   //** add the Link to the "to be reconnected links" vector
           xInPortToCon   = [xInPortToCon xsmin_n(i)] ; //** recover the coordinate of the new equivalent port
           yInPortToCon   = [yInPortToCon ysmin_n(i)] ; //** and pile up in the vector
           NumInPortToCon = [NumInPortToCon i] ;        //** and pile up the input port number
         else
           if pin(i)>0 //** if the old port was connected
	     LinkToDel = [LinkToDel pin(i)]; //** add the Link to the "to be deleted links" vector
	   end
         end
       else
         if pin(i)>0 //** if the old port was connected
	   LinkToDel = [LinkToDel pin(i)]; //** add the Link to the "to be deleted links" vector
	 end
       end

    end //** of the for loop 

    o_n.graphics.pin = pin_n ; //** update the "scs_m" input_port - link association

  end
  //**---------------------------------------------------------------------------------------------

  //**------------------ EVENT INPUT PORTS --------------------------------------------------------
  if size_pein >0 then 

    for i=1:size_pein //** for all the event input of the old block
       //** if the port is linked AND the new block has enough ports
       if  pein(i)>0 & i<=size_pein_n then  
         pein_n(i) = pein(i); //** assign the port to the old Link
         InputLinkToCon = [InputLinkToCon pein(i)] ; //** add the Link to the "to be reconnected links" vector
         xInPortToCon   = [xInPortToCon xein_n(i)] ; //** recover the coordinate of the new equivalent port
         yInPortToCon   = [yInPortToCon yein_n(i)] ; //** and pile up in the vector
         NumInPortToCon = [NumInPortToCon i] ;       //** and pile up the input port number
       else
         if pein(i)>0 //** if the old port was connected
           LinkToDel = [LinkToDel pein(i)]; //** add the Link to the "to be deleted links" vector
         end
       end

    end //** of the for loop

    o_n.graphics.pein = pein_n ; //** update the "scs_m" event_input_port - event_link association

  end
  //**---------------------------------------------------------------------------------------------

  //**------------------ OUTPUT PORTS -------------------------------------------------------------
  if size_pout >0 then 

    for i=1:size_pout //** for all the output "pout" of the old block 
  //** if the port is linked AND the new block has enough ports AND the two ports are of the same E/I
    //**
       if pout(i)>0 & i<=size_pout_n then
         if isequal(out_mod(i),out_mod_n(i)) & isequal(tsmout(i),tsmout_n(i)) then
           pout_n(i) = pout(i); //** assign the port to the old Link
           OutputLinkToCon = [OutputLinkToCon pout(i)] ;   //** add the Link to the "to be reconnected links" vector
           xOutPortToCon   = [xOutPortToCon xsmout_n(i)] ; //** recover the coordinate of the new equivalent port
           yOutPortToCon   = [yOutPortToCon ysmout_n(i)] ; //** and pile up in the vector
           NumOutPortToCon = [NumOutPortToCon i] ;         //** and pile up the output port number
         else
           LinkToDel = [LinkToDel pout(i)]; //** add the Link to the "to be deleted links" vector
         end
       else
         if pout(i)>0 //** if the old port was connected
           LinkToDel = [LinkToDel pout(i)]; //** add the Link to the "to be deleted links" vector
         end
       end

    end //** of the for loop

    o_n.graphics.pout = pout_n ; //** update the "scs_m" ouput_port - link association

  end
  //**---------------------------------------------------------------------------------------------

  //**------------------ EVENT OUTPUT PORTS -------------------------------------------------------
  if size_peout >0 then

    for i=1:size_peout //** for all the event input of the old block
       //** if the port is linked AND the new block has enough ports
       if  peout(i)>0 & i<=size_peout_n then
         peout_n(i) = peout(i); //** assign the port to the old Link
         OutputLinkToCon = [OutputLinkToCon peout(i)] ; //** add the Link to the "to be reconnected links" vector
         xOutPortToCon   = [xOutPortToCon xeout_n(i)] ; //** recover the coordinate of the new equivalent port
         yOutPortToCon   = [yOutPortToCon yeout_n(i)] ; //** and pile up in the vector
         NumOutPortToCon = [NumOutPortToCon i] ;        //** and pile up the output port number
       else
         if peout(i)>0 //** if the old port was connected
           LinkToDel = [LinkToDel peout(i)]; //** add the Link to the "to be deleted links" vector
         end
       end

    end //** of the for loop

    o_n.graphics.peout = peout_n ; //** update the "scs_m" event_ouput_port - event_link association

  end
  //**---------------------------------------------------------------------------------------------
  if  or(curwin==winsid()) then
    //** New graphics section
    gh_link = [];
  end
  
  function [xl,yl]=adj_first(xl,yl,xx,yy)
    nl = size(xl,1)
    if nl > 2 then
      if xl(1)==xl(2) then
        xl(1:2) = xx; yl(1) = yy;
      elseif yl(1)==yl(2) then 
        xl(1) = xx; yl(1:2) = yy;
      else
        xl(1) = xx; yl(1) = yy;
      end
    else
      xl(1) = xx; yl(1) = yy;
    end
  endfunction
  
  function [xl,yl]=adj_last(xl,yl,xx,yy)
    nl = size(xl,1)
    if nl > 2 then
      if xl($-1)==xl($) then
        xl($-1:$) = xx; yl($) = yy;
      elseif yl($-1)==yl($) then 
        xl($) = xx; yl($-1:$) = yy;
      else
        xl($) = xx; yl($) = yy;
      end
    else
      xl($) = xx; yl($) = yy;
    end
  endfunction
  
  
  //** ------------------------ ADJUST THE CONNECTED LINKS ----------------------------------------

  //**-------------------------- Input Links ---------------------------------------
  if size(InputLinkToCon,'*') > 0 then

  //** disp("Adj links"); pause

    for i=1:size(InputLinkToCon,'*')

      Link_index = InputLinkToCon(i) ;
      oi = scs_m.objs(Link_index)

      [xlink, ylink, ct ,from ,to ] = (oi.xx, oi.yy, oi.ct, oi.from, oi.to) ;
      nl = size(xlink,1)
      if smart then
        [xlink,ylink]=clean_link(xlink,ylink);
        nl = size(xlink,1)
        // If the link is of size 2 and is vertical 
        // or horizontal then we add intermediate middle points
        if nl == 2  then
          if abs(xlink(1)-xlink(2)) < 1.e-3 then xlink(1)=xlink(2);end 
          if abs(ylink(1)-ylink(2)) < 1.e-3 then ylink(1)=ylink(2);end 
          if xlink(1)==xlink(2) || ylink(1)==ylink(2) then 
            xm=(xlink(1)+xlink(2))/2;
            ym=(ylink(1)+ylink(2))/2;
            xlink= [xlink(1);xm;xm;xlink(2)];
            ylink= [ylink(1);ym;ym;ylink(2)];
          end
        end
      end
      
      //** Use theta parameters to compute the physical position of the port on the screen
      xxx = rotate([xInPortToCon(i);yInPortToCon(i)],...
                    o_n.graphics.theta*%pi/180,...
                   [o_n.graphics.orig(1)+o_n.graphics.sz(1)/2;o_n.graphics.orig(2)+o_n.graphics.sz(2)/2]);

      //** the link is connected to the same block
      if from(1)==to(1) then
        //we check here inputs : we look for to(3)==1 or from(3)==1
        //to(2) or from(2) are the input port number
        if (to(2)==NumInPortToCon(i) & to(3)==1) then
          if smart then
            [xlink,ylink]=adj_last(xlink,ylink,xxx(1,:),xxx(2,:))
          else
            xlink($) = xxx(1,:); ylink($) = xxx(2,:);
          end
        elseif (from(2)==NumInPortToCon(i) & from(3)==1) then
          if smart then
            [xlink,ylink]=adj_first(xlink,ylink,xxx(1,:),xxx(2,:))
          else
            xlink(1) = xxx(1,:); ylink(2) = xxx(2,:);
          end
        end

      //** the link is connected to different blocks
      else
        if from(1)==path(2) then
          //** if the bloc is connected to a link with a 'from' tag
          //** force the position to the first point of the link
          if smart then
            [xlink,ylink]=adj_first(xlink,ylink,xxx(1,:),xxx(2,:))
          else
            xlink(1) = xxx(1,:); ylink(2) = xxx(2,:);
          end
        else
          //** else if it is connected to a link with a 'to' tag
          //** force the position to the last point of the link
          if smart then
            [xlink,ylink]=adj_last(xlink,ylink,xxx(1,:),xxx(2,:))
          else
            xlink($) = xxx(1,:); ylink($) = xxx(2,:);
          end
        end
      end

      if smart then
        [xlink,ylink]=clean_link(xlink,ylink);
      end
      oi.xx = xlink ; oi.yy = ylink ;                           //** link

      if  or(curwin==winsid()) then
        F=get_current_figure();
        F.draw_latter[];
        oi=drawobj(oi,F);
        oi.gr.invalidate[];
        F.draw_now[];
      end

      scs_m.objs(Link_index) = oi; //** update the scs_m

   end //** for loop

  end

  //**---------------------------------

  //**----------------------- Output Links -------------------------------------------

  if size(OutputLinkToCon,'*') > 0 then

   for i=1:size(OutputLinkToCon,'*')

      Link_index = OutputLinkToCon(i) ;
      oi = scs_m.objs(Link_index)

      [xlink, ylink, ct ,from ,to ] = (oi.xx, oi.yy, oi.ct, oi.from, oi.to) ;
      nl = size(xlink,1)
      if smart then
        [xlink,ylink]=clean_link(xlink,ylink);
        nl = size(xlink,1)
        // If the link is of size 2 and is vertical 
        // or horizontal then we add intermediate middle points
        if nl == 2  then
          if abs(xlink(1)-xlink(2)) < 1.e-3 then xlink(1)=xlink(2);end 
          if abs(ylink(1)-ylink(2)) < 1.e-3 then ylink(1)=ylink(2);end 
          if xlink(1)==xlink(2) || ylink(1)==ylink(2) then 
            xm=(xlink(1)+xlink(2))/2;
            ym=(ylink(1)+ylink(2))/2;
            xlink= [xlink(1);xm;xm;xlink(2)];
            ylink= [ylink(1);ym;ym;ylink(2)];
          end
        end
      end
      
      //** Use theta parameters to compute the physical position of the port on the screen
      xxx = rotate([xOutPortToCon(i);yOutPortToCon(i)],...
                    o_n.graphics.theta*%pi/180,...
                   [o_n.graphics.orig(1)+o_n.graphics.sz(1)/2;o_n.graphics.orig(2)+o_n.graphics.sz(2)/2]);

      //** the link is connected to the same block
      if from(1)==to(1) then
        //we check here inputs : we look for to(3)==1 or from(3)==1
        //to(2) or from(2) are the input port number
        if (to(2)==NumOutPortToCon(i) & to(3)==0) then
          if smart then
            [xlink,ylink]=adj_last(xlink,ylink,xxx(1,:),xxx(2,:))
          else
            xlink($) = xxx(1,:); ylink($) = xxx(2,:);
          end
        elseif (from(2)==NumOutPortToCon(i) & from(3)==0) then
          if smart then
            [xlink,ylink]=adj_first(xlink,ylink,xxx(1,:),xxx(2,:))
          else
            xlink(1) = xxx(1,:); ylink(1) = xxx(2,:);
          end
        end

      //** the link is connected to different blocks
      else
        if from(1)==path(2) then
          //** if the bloc is connected to a link with a 'from' tag
          //** force the position to the first point of the link
          if smart then
            [xlink,ylink]=adj_first(xlink,ylink,xxx(1,:),xxx(2,:))
          else
            xlink(1) = xxx(1,:); ylink(1) = xxx(2,:);
          end
        else
          //** else if it is connected to a link with a 'to' tag
          //** force the position to the last point of the link
          if smart then
            [xlink,ylink]=adj_last(xlink,ylink,xxx(1,:),xxx(2,:))
          else
             xlink($) = xxx(1,:); ylink($) = xxx(2,:);
          end
        end
      end

      if smart then
        [xlink,ylink]=clean_link(xlink,ylink);
      end
      oi.xx = xlink ; oi.yy = ylink ;

      if  or(curwin==winsid()) then
        F=get_current_figure();
        F.draw_latter[];
        oi=drawobj(oi,F);
        oi.gr.invalidate[];
        F.draw_now[];
      end

      scs_m.objs(Link_index) = oi;    //** update the scs_m

  end //** for loop

  end
  //** ------------------------ END OF : ADJUST THE CONNECTED LINKS -------------------------------  

endfunction





