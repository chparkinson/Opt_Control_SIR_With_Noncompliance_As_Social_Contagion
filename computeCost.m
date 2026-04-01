function [C,I_Cost,NC_Cost,Control_Cost] = computeCost(t,x,a,n,m,v,c1,c2,d1,d2)
% compute the cost functional for a particular simulation
% The function takes in the results of a simulation; i.e.
% the state variables stored in x, the control variables stored in
% a,n,m,v, and the cost weights c1,...,c6.
%
% We return the total cost, as well as the individual costs due to
% infection, noncompliance, and controls. 

dt = t(2)-t(1);
k = 1:length(t)-1;
I_Cost  = c1*dt*sum(x.I(k)+x.Is(k) + x.I(k+1)+x.Is(k+1))/2;
NC_Cost = c2*dt*sum(x.Ss(k)+x.Is(k)+x.Rs(k)+x.Ss(k+1)+x.Is(k+1)+x.Rs(k+1))/2;
Control_Cost= d1*dt*sum(a+n+m+v)+(d2/2)*sum(a.^2+n.^2+m.^2+v.^2);
C = I_Cost + NC_Cost + Control_Cost;

end

