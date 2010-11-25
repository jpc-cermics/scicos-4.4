
global V;
n=20;
V=hash(time=1:n,values=cell(1,n));
I=n:-1:1;
x=%pi*(-1:0.1:1);
for i=1:n
  V.values{i} =sin((I(i)/10)*x)'*cos((I(i)/10)*x);
end

// test 
if ~new_graphics() then switch_graphics();end

ebox=[min(x),max(x),min(x),max(x),-1,1];
i=1;
plot3d1(x,x,V.values{i},alpha=80,theta=62,flag=[2,1,0],ebox=ebox)
F=get_current_figure();
A=F(1);
for i=1:n
  F.children.remove_first[];
  plot3d1(x,x,V.values{i},alpha=80,theta=62,flag=[2,1,0],ebox=ebox)
  A.invalidate[]; // signal that Axis should be redrawn.
  F.draw_now[]; // will activate a process_updates
  xpause(100000,%t)// slow down animaion
end

// dim 1 */

global V1;
V1=hash(time=1:10,values=cell(1,10));
for i=1:10, V1.values{i}= 2*i;end 
