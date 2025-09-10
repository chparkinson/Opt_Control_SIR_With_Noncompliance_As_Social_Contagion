function [x,y] = solveSIR(x0,t,b,d,XI,B,g,MU,a,n,m,v)
%INPUT:
% x0 - initial condition for SIR with Noncomp simulation
% t  - time interval
% b  - birth rate
% d  - death rate
% XI - portion of nwly introduced pop that is noncompliant
% B  - disease infection rate
% g  - disease recovery rate
% MU - noncompliance infection rate
% a  - reduction in infectivity of disease (control variable)
% n  - increase in recovery rate (control variable)
% m  - reduction in infectivity of noncompliance (control variable)
% v  - recovery rate from noncompliance (control variable)
%
%OUTPUT: 
% x  - struct with fields S,I,R,Ss,Is,Rs (solution to SIR with noncomp system)

dt = t(2)-t(1);
y = zeros(6,length(t));
y(:,1) = x0;

% we hard code the right-hand side of our system
F = @(y,alp,eta,mu,nu) [(1-XI)*b - B*(1-alp)*y(1)*(y(2)+y(5)) - d*y(1) - (MU-mu)*y(1)*(y(4)+y(5)+y(6)) + nu*y(4) ;
                  B*(1-alp)*y(1)*(y(2)+y(5)) - (g+eta+d)*y(2) - (MU-mu)*y(2)*(y(4)+y(5)+y(6)) + nu*y(5);
                  (g+eta)*y(2) - d*y(3) - (MU-mu)*y(3)*(y(4)+y(5)+y(6)) + nu*y(6); 
                  XI*b - B*y(4)*(y(2)+y(5)) - d*y(4) + (MU-mu)*y(1)*(y(4)+y(5)+y(6)) - nu*y(4);
                  B*y(4)*(y(2)+y(5)) - (g+d)*y(5) + (MU-mu)*y(2)*(y(4)+y(5)+y(6)) - nu*y(5);
                  g*y(5) - d*y(6) + (MU-mu)*y(3)*(y(4)+y(5)+y(6)) - nu*y(6) ];

for j = 1:length(t)-1
    y(:,j+1) = y(:,j) + dt*F(y(:,j),a(j),n(j),m(j),v(j));
end

x.S = y(1,:); x.I = y(2,:); x.R = y(3,:);
x.Ss= y(4,:); x.Is= y(5,:); x.Rs= y(6,:);

end

