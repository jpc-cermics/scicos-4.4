      subroutine sum3(flag,nevprt,t,xd,x,nx,z,nz,tvec,ntvec,
     &     rpar,nrpar,ipar,nipar,u1,nu1,u2,nu2,u3,nu3,y,ny)
c     Copyright INRIA

c     Scicos block simulator
c     adds the inputs weighed by rpar
c
      double precision t,xd(*),x(*),z(*),tvec(*),rpar(*)
      double precision u1(*),u2(*),u3(*),y(*)
      integer flag,nevprt,nx,nz,ntvec,nrpar,ipar(*)
      integer nipar,nu1,ny

c
      do 1 i=1,nu1
         y(i)=u1(i)*rpar(1)+u2(i)*rpar(2)+u3(i)*rpar(3)
 1    continue
      return
      end
