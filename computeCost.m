function [C,I_Cost,NC_Cost,Control_Cost] = computeCost(t,x,a,n,m,v,c1,c2,c3,c4,c5,c6)
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
Control_Cost= c3*dt*sum((a(k).^2 + a(k+1).^2)/4 + c4*(n(k).^2 + n(k+1).^2)/4 + ...
                c5*(m(k).^2 + m(k+1).^2)/4 + c6*(v(k).^2 + v(k+1).^2)/4);
C = I_Cost + NC_Cost + Control_Cost;

end

