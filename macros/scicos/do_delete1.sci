function [scs_m,DEL,DELL]=do_delete1(scs_m,K,gr)
// deletes scs_m objects whose index are given in the vector K 
// and all other relevant objects (link, splits,..)
// if gr==%t objects are also graphicaly erased.
//
// deleted objects are replaced by the value : mlist('Deleted') not to 
// change the indexing use do_purge to suppress them and to renumber objects 
//!
// Copyright INRIA
  DEL=[] //table of deleted objects
  DELL=[] //table of redefined links
  outin=['out','in']

  while ~isempty(K) do
    k=K(1);K(1)=[]
    o=scs_m.objs(k);
    if isempty(find(DEL==k)) then typ=o.type ;else typ='Deleted',end

    DEL=[DEL k]
    if typ=='Link' then
      [ct,from,to]=(o.ct,o.from,o.to)
      //  free connected ports
      if ct(2)==2 then //Implicit link
	if or(scs_m.objs(from(1)).graphics.pin==k) & from(3)==1 then
	  scs_m.objs(from(1))=mark_prt(scs_m.objs(from(1)),from(2),'in',ct(2),0)
	else //or(scs_m.objs(from(1)).graphics.pout==k) then
	  scs_m.objs(from(1))=mark_prt(scs_m.objs(from(1)),from(2),'out',ct(2),0)
	end
	if or(scs_m.objs(to(1)).graphics.pin==k) & to(3)==1 then
	  scs_m.objs(to(1))=mark_prt(scs_m.objs(to(1)),to(2),'in',ct(2),0) 
	else // or(scs_m.objs(to(1)).graphics.pout==k) then
	  scs_m.objs(to(1))=mark_prt(scs_m.objs(to(1)),to(2),'out',ct(2),0) 
	end
      else 
        scs_m.objs(from(1))=mark_prt(scs_m.objs(from(1)),from(2),'out',ct(2),0)
        scs_m.objs(to(1))=mark_prt(scs_m.objs(to(1)),to(2),'in',ct(2),0)
      end

      // erase and delete link
      fromblock=scs_m.objs(from(1));
      toblock=scs_m.objs(to(1));
      if or(fromblock.gui==['SPLIT_f' 'CLKSPLIT_f' 'IMPSPLIT_f']) then
	//user kills a split  output link:
	//get links connected to the split block
	connected=get_connected(scs_m,from(1))
	if size(setdiff(connected,K),'*')==2 then
	  //RN: 22-7-2004 setdiff added above
	  //create a unique link with the split input and remaining 
	  //output link and suppress the split block
	  if ~isempty(find(connected(2)==DEL)) then // delete split
	    K=[from(1) K]
	  else
	    ksplit=from(1)
	    DEL=[DEL  ksplit]       //suppress split block
	    o1=scs_m.objs(connected(1));from1=o1.to;
	    o2=scs_m.objs(connected(2));
	    //create a unique link
	    if o1.from(1)==ksplit&o2.from(1)==ksplit then
	      //the two links come from the split: invert o1
	      w=o1.to;o1.to=o1.from;o1.from=w;
	      o1.xx=o1.xx($:-1:1);o1.yy=o1.yy($:-1:1);
	    elseif o1.to(1)==ksplit(1)&o2.to(1)==ksplit then
	       //the two links go from the split: invert o2
	       w=o2.to;o2.to=o2.from;o2.from=w;
	       o2.xx=o2.xx($:-1:1);o2.yy=o2.yy($:-1:1);
	    elseif o1.to(1)<>ksplit then 
	      //o1 comes from the split while o2 goes to the split, 
              //switch o1 and o2
	      [o1,o2]=(o2,o1),
	      connected=connected([2 1]);
	    end
            //now we can assume that o1 goes to the split and o2 comes
            //from the split
	    
	    from1=o1.to;to2=o2.to;ct2=o2.ct
	    //the links comes from connected(1) block and 
	    //goes to connected(2) block
	    x1=o1.xx;y1=o1.yy
	    if x1($-1)==x1($)&o2.xx(1)==o2.xx(2)|.. // both segs are vertical
		       y1($-1)==y1($)&o2.yy(1)==o2.yy(2) then //both segs are horiz
	      o1.xx=[x1(1:$-1);o2.xx(2:$)];
	      o1.yy=[y1(1:$-1);o2.yy(2:$)];
	    else
	      o1.xx=[x1(1:$-1);o2.xx];
	      o1.yy=[y1(1:$-1);o2.yy];
	    end
	    o1.to=o2.to;
            if o1.iskey['gr'] then
	      o1.gr.children(1).x = o1.xx;
	      o1.gr.children(1).y = o1.yy;
            end
	    
	    DEL=[DEL connected(1)] // supress one link
	    DELL=[DELL  connected(1)]
	    scs_m.objs(connected(1))=o2 // this one will be deleted we
	    // must keep it for its gr to be deleted below 
	    scs_m.objs(connected(2))=o1 // this one is a merge 
	    scs_m.objs(to2(1))=mark_prt(scs_m.objs(to2(1)),to2(2),outin(to2(3)+1),ct2(2),..
					connected(2))
	    scs_m.objs(o1.from(1))=mark_prt(scs_m.objs(o1.from(1)),o1.from(2),..
					    outin(o1.from(3)+1),o1.ct(2),connected(2))
	  end
	end
      end
      if toblock.gui=='SPLIT_f'|toblock.gui=='CLKSPLIT_f' then //
	//user kills a split input link
	//ask for split deletion
	K=[K to(1)]
      elseif toblock.gui=='IMPSPLIT_f' then
      	//user kills a IMPsplit  link:
	
	//get links connected to the split block
	connected=get_connected(scs_m,to(1))
	if size(connected,'*')==2 then
	  //create a unique link with the split input and remaining 
	  //output link and suppress the split block
	  if ~isempty(find(connected(2)==DEL)) then // delete split
	    K=[to(1) K]
	  else
	    DEL=[DEL  to(1)]       //suppress split block

	    o1=scs_m.objs(connected(1));
	    o2=scs_m.objs(connected(2));
	    //o1 and o2 are the links that comes from the split
	    
	    //create a unique link
	    to1=o1.to; //number of block at the boundary of link o1
	    to2=o2.to; //number of block at the boundary of link o2
	    if (o1.xx(1)==o1.xx(2)& o2.xx(1)==o2.xx(2))| ..
		  (o1.yy(1)==o1.yy(2)& o2.yy(1)==o2.yy(2)) then
	      o1.xx=o1.xx(2:$);o1.yy=o1.yy(2:$)
	    end
	    o1.xx=[o1.xx($:-1:1);o2.xx]
	    o1.yy=[o1.yy($:-1:1);o2.yy]
	    o1.from=o1.to
	    o1.to=o2.to;
            if o1.iskey['gr'] then
	      o1.gr.children(1).x = o1.xx;
	      o1.gr.children(1).y = o1.yy;
            end

	    DEL=[DEL connected(1)] // supress one link
	    DELL=[DELL  connected(1)]
	    scs_m.objs(connected(2))=o1 //change link
	    scs_m.objs(connected(1))=o2 // this one will be deleted
	    scs_m.objs(to1(1))=mark_prt(scs_m.objs(to1(1)),..
					to1(2),outin(to1(3)+1),o1.ct(2),connected(2)) 
	    scs_m.objs(to2(1))=mark_prt(scs_m.objs(to2(1)),to2(2),..
					outin(to2(3)+1),ct(2), ...
					connected(2))
	    
	  end //if ~isempty(find(connected(2)==DEL)) 
	end //if size(connected,'*')==2 
      end //elseif toblock.gui=='IMPSPLIT_f' 
    elseif typ=='Block' then
      // get connected links
      connected=get_connected(scs_m,k)
      //ask for connected links deletion
      K=[K connected]
      // erase and delete block
    elseif typ=='Text' then
      // 
    elseif typ=='Deleted' then
    else
      message('This object can''t be deleted')
    end 
  end
    
  if ~isempty(DEL) then 
    F=get_current_figure();
    F.draw_latter[];
    for k=DEL,
      // we need here to delete the stored graphic objects;
      if gr && scs_m.objs(k).iskey['gr'] then 
	F.remove[scs_m.objs(k).gr];
      end
      scs_m.objs(k)=mlist('Deleted'),
    end
    F.draw_now[];
  end
endfunction
