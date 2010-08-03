function prt=splitted_links(scs_m,keep,del)
// given a vectors of indexes of "kept" blocks and "deleted" blocks 
// forms at table prt. Each line of prt is relative to a link beetween 
// a kept and a deleted block as follow:
// [io,keep_block_# port_# link_type link_color del_block_# port_#]
// io = 1 : link goes to a kept block, 0:link comes from a kept block
// Copyright INRIA
prt=[]
for kkeep=1:size(keep,'*')
  kk=keep(kkeep)
  o=scs_m.objs(kk) //one block into the future super block

  if o.type=='Block' then

    //regular and implicit links connected to this "internal"  block
    connected=unique([get_connected(scs_m,kk,typ='in'),get_connected(scs_m,kk,typ='out')])

    for kc=1:size(connected,'*') //loop on these links
      //lk: one link connected to this "internal"  block
      lk=scs_m.objs(connected(kc)); 

      //find those connected to a del block
      if or(lk.from(1)==del) then // link from del to keep
	prt=[prt;
	     lk.to(1:3),lk.ct(1:2),lk.from(1:3)]
      elseif or(lk.to(1)==del) then //link from keep to del
	prt=[prt;
	     lk.from(1:3),lk.ct(1:2),lk.to(1:3)]
      end //
    end

    //event links going to this "internal"  block
    connected=get_connected(scs_m,kk,typ='clkin') 
    for kc=1:size(connected,'*') //loop on event input links
      lk=scs_m.objs(connected(kc))
      if or(lk.from(1)==del) then // link between keep and del
	prt=[prt;
	     [lk.to(1:2),1,lk.ct(1:2),lk.from(1:2),0]]
      end
    end

    //event linkS coming from this "internal"  block
    connected=get_connected(scs_m,kk,typ='clkout')
    for kc=1:size(connected,'*') //loop on event output links
      lk=scs_m.objs(connected(kc))
      if or(lk.to(1)==del) then // link between keep and del
	prt=[prt;
	     [lk.from(1:2),0,lk.ct(1:2),lk.to(1:2),1]]
      end
    end

  end   //if typeof(o)=='Block' then
end    //for kkeep=1:size(keep,'*')
endfunction
