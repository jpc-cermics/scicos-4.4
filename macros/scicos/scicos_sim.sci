function sim=scicos_sim(funs=[], xptr=[], zptr=[], ozptr=[],zcptr=[],inpptr=[],...
			outptr=[], inplnk=[],outlnk=[], rpar=[],...
			rpptr=[],ipar=[], ipptr=[],opar=list(), opptr=[], clkptr=[],ordptr=[],...
			execlk=[], ordclk=[], cord=[], oord=[], zord=[],...
			critev=[],nb=[], ztyp=[], nblk=[], ndcblk=[],...
			subscr=[], funtyp=[], iord=[], labels=[],modptr=[])
  
  sim=tlist(['scs','funs','xptr','zptr','ozptr',..
             'zcptr','inpptr','outptr','inplnk','outlnk','rpar',..
             'rpptr','ipar','ipptr','opar','opptr',..
	     'clkptr','ordptr','execlk','ordclk','cord','oord','zord',..
	     'critev','nb','ztyp','nblk','ndcblk','subscr','funtyp',..
             'iord','labels','modptr'],..
	    funs,xptr,zptr,ozptr,zcptr,inpptr,..
             outptr,inplnk,outlnk,rpar,rpptr,ipar,ipptr,..
             opar,opptr,clkptr,ordptr,..
             execlk,ordclk,cord,oord,zord,..
             critev,nb,ztyp,nblk,ndcblk,..
             subscr,funtyp,iord,labels,modptr)
endfunction
