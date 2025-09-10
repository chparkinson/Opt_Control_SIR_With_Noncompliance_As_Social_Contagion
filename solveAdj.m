function [p,q] = solveAdj(t,x,d,B,g,MU,a,n,m,v,c1,c2)
%INPUT:
% t  - time interval
% x  - soln of state equation
% d  - death rate
% B  - infection rate
% g  - recovery rate
% MU - baseline infectivity rate of noncompliance
% a  - reduction in disease infectivity (control variable)
% n  - increase in disease recovery rate (control variable)
% m  - decrease in noncompliance infectivity (control variable)
% v  - recovery rate from noncompliance (control variable)
% c1 - cost of infections
% c2 - cost of noncompliance
%
%OUTPUT:
% p  - solution of adjoint equation 

dt = t(2)-t(1);

y = zeros(6,length(t));
y(1,:) = x.S;  y(2,:) = x.I;  y(3,:) = x.R;
y(4,:) = x.Ss; y(5,:) = x.Is; y(6,:) = x.Rs;
q = zeros(6,length(t));

% we hard code in the x-gradient of the hamiltonian
dHdx = @(x,p,al,et,mu,nu) ...
      [B*(1-al)*(x(2)+x(5))*(p(2)-p(1))+(MU-mu)*(x(4)+x(5)+x(6))*(p(4)-p(1))-d*p(1);
       B*((1-al)*x(1)*(p(2)-p(1))+x(4)*(p(5)-p(4)))+(MU-mu)*(x(4)+x(5)+x(6))*(p(5)-p(2))+(g+et)*(p(3)-p(2))-d*p(2)+c1;
       -d*p(3)+(MU-mu)*(x(4)+x(5)+x(6))*(p(6)-p(3));
       B*(x(2)+x(5))*(p(5)-p(4))-d*p(4)+(MU-mu)*(x(1)*(p(4)-p(1))+x(2)*(p(5)-p(2))+x(3)*(p(6)-p(3)))+nu*(p(1)-p(4))+c2;
       B*((1-al)*x(1)*(p(2)-p(1))+x(4)*(p(5)-p(4)))+g*(p(6)-p(5))-d*p(5)+(MU-mu)*(x(1)*(p(4)-p(1))+x(2)*(p(5)-p(2))+x(3)*(p(6)-p(3)))+nu*(p(2)-p(5))+c1+c2;
       (MU-mu)*(x(1)*(p(4)-p(1))+x(2)*(p(5)-p(2))+x(3)*(p(6)-p(3)))+nu*(p(3)-p(6))-d*p(6) + c2];

% run explicit euler to solve the adjoint equation
% NOTE: this equation is backward-in-time, so "explicit" euler is backward
% euler in this case. 
for j = (length(t)-1):-1:1
    q(:,j) = q(:,j+1)+dt*dHdx(y(:,j+1),q(:,j+1),a(j+1),n(j+1),m(j+1),v(j+1));
end

% store results in p
p.S  = q(1,:); p.I  = q(2,:); p.R  = q(3,:); 
p.Ss = q(4,:); p.Is = q(5,:); p.Rs = q(6,:);
end

