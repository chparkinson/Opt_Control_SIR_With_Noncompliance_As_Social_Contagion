clear;
close all;

%%%% time interval
T = 100;
dt = 0.1;
t = 0:dt:T;

%% Parameters 
%%%% need to manually change these to get the figures from the manuscript

%%%% use these lines to manually set parameters
b = 0.01; XI = 0; d = 0.01;                      %birth/death related parameters
B = 0.4; g = 0.2; ALPHA = 0.5; ETA = 0.1;        %disease related parameters
MU = 0.1; NU = 0.1;                              %noncompliance related parameters

MU_CAP = MU/2; % used to turn off mu if desired (eta and nu can be turned off
             % by setting ETA = 0 or NU = 0, but doing this for MU will
             % change the model by eliminating spread of noncompliance)

% cost weights
c1 = 1; c2 = 0.05; d1 = 0.1; d2 = 0.1;

%%%% initialize state and costate solutions.
x.S  = zeros(1,length(t)); x.I  = zeros(1,length(t)); x.R  = zeros(1,length(t));
x.Ss = zeros(1,length(t)); x.Is = zeros(1,length(t)); x.Rs = zeros(1,length(t));
p.S  = zeros(1,length(t)); p.I  = zeros(1,length(t)); p.R  = zeros(1,length(t));
p.Ss = zeros(1,length(t)); p.Is = zeros(1,length(t)); p.Rs = zeros(1,length(t));

%%%% initial condition
x0 = [0.69,0.01,0,0.29,0.01,0]';

%%%% SQH Method %%%%
%%%% initialize control vectors
a = 0.0*ALPHA*ones(1,length(t));  % alpha
n = 0.0*ETA*ones(1,length(t));  % eta
m = 0.0*MU*ones(1,length(t)); % mu
v = 0.0*NU*ones(1,length(t));  % nu
a_old = a; n_old = n; m_old = m; v_old = v;

KAP = 1e-8;
EPS = 1;
SIG = 1.1;
ZET = 0.9;
ETA_SQH= 1e-9;
max_iter = 10000;
[x,y] = solveSIR(x0,t,b,d,XI,B,g,MU,a,n,m,v);
xUC = x; yUC = y;
[p,q] = solveAdj(t,x,d,B,g,MU,a,n,m,v,c1,c2);
Jf(1) = computeCost(t,x,a,n,m,v,c1,c2,d1,d2);
JUC = Jf(1);
count = 1; %count which control update we are on

timer = tic;
%%% Iteration in the SQH method
for k=1:max_iter
    
    %compute new controls
    a = min(max((B*x.S.*(2*x.I+x.Is).*(p.I-p.S)+B*x.Ss.*x.I.*(p.Is-p.Ss)-d1+2*EPS*a_old)./(2*(d2/2+EPS)+B*x.S.*(2*x.I+x.Is).*(p.I-p.S)),0),ALPHA);
    n = min(max((x.I.*(p.I-p.R)-d1+2*EPS*n_old)/(2*(d2/2+EPS)),0),ETA);
    m = min(max((((p.Ss-p.S).*x.S+(p.Is-p.I).*x.I+(p.Rs-p.R).*x.R).*(x.Ss+x.Is+x.Rs)-d1+2*EPS*m_old)/(2*(d2/2+EPS)),0),MU_CAP);
    v = min(max(((p.Ss-p.S).*x.Ss+(p.Is-p.I).*x.Is+(p.Rs-p.R).*x.Rs-d1+2*EPS*v_old)/(2*(d2/2+EPS)),0),NU);
    
    %%% FOR NO CONTROLS UNCOMMENT THESE LINES
    % a = 0.0*ALPHA*ones(1,length(t));  % alpha
    % n = 0.0*ETA*ones(1,length(t));  % eta   
    % m = 0.0*MU*ones(1,length(t)); % mu
    % v = 0.0*NU*ones(1,length(t));  % nu

    % compute change in controls
    TAU = sum((a-a_old).^2+(n-n_old).^2+(m-m_old).^2+(v-v_old).^2)*dt;

    % recompute SIR solution
    [x,y] = solveSIR(x0,t,b,d,XI,B,g,MU,a,n,m,v);
    
    % compute cost of newest controls and SIR solution
    J = computeCost(t,x,a,n,m,v,c1,c2,d1,d2);

    if (J-Jf(count)) > -ETA_SQH*TAU
        % cost functional was not sufficiently decreased
        % so revert to old controls, increase epsilon and try again
        a = a_old; 
        n = n_old; 
        m = m_old;
        v = v_old;
        EPS = SIG*EPS;
        fprintf("Iteration %i. Control version %i. EPS = %.4e. TAU = %.4e\n",k,count-1,EPS,TAU);
    else
        % cost functional was sufficiently decreased
        % accept new controls, decrease epsilon and recompute costate
        count = count+1;
        EPS = EPS*ZET;
        a_old = a;
        n_old = n;
        m_old = m;
        v_old = v;
        [p,q] = solveAdj(t,x,d,B,g,MU,a,n,m,v,c1,c2);
        Jf(count) = J;
        fprintf("Iteration %i. Control version %i. EPS = %.4e. TAU = %.4e\n",k,count-1,EPS,TAU);
    end

    if TAU<KAP
        a = a_old; 
        n = n_old; 
        m = m_old;
        v = v_old;
        TIME = toc(timer);
        fprintf("Convergence achieved in %.2f seconds CPU time.\n",TIME);
        break;
    end

end
%%%% report if convergence failed
if k == max_iter
    fprintf("Failed to converge to tolerance %.2e in %i iterations\n",KAP,max_iter);
end
%%%% compute costs
[Cost,Icost,NCcost,Ccost] = computeCost(t,x,a,n,m,v,c1,c2,d1,d2);

%%%% compute R0 corresponding to theorem 2.5(i),(ii)
%%%% NOTE: this is only relevant when XI = 0
s = b/d; ss = 0;
R01 = B*((1-a).*(1-n./(g+n+v+d+(MU-m).*ss)).*s + ss)./(g+d+v.*n./(g+n+v+d+ss.*(MU-m)));
s = min((d+v)./(MU-m),2); ss = b/d - s;
R02 = B*((1-a).*(1-n./(g+n+v+d+(MU-m).*ss)).*s + ss)./(g+d+v.*n./(g+n+v+d+ss.*(MU-m)));
%R0 = B*((1-a).*(1-n./(g+n+v+d+(MU-m).*x.Ss)).*x.S + x.Ss)./(g+d+v.*n./(g+n+v+d+x.Ss.*(MU-m)));
R0 = (ss<0).*R01 + (ss>=0).*R02;

%% report costs and savings
fprintf("====================================================\n");
fprintf("Total cost of uncontrolled simulation : %.4e\n",Jf(1));
fprintf("Total cost of controlled simulation   : %.4e\n",Jf(end));
fprintf("Relative cost savings                 : %.2f%%\n",100*(Jf(1)-Jf(end))/Jf(1));
fprintf("====================================================\n");

%% %%%%% plot results %%%%%
if XI==0
    %%%% TO PLOT THE DISEASE DYNAMICS IN ONE 2x1 PLOT
    %%%% AND THE CONTROL AND R0 DYNAMICS IN ANOTHER
    %%%% USE THESE LINES... THESE WERE USED FOR FIG. 3-8
    F_SIR = plotSIR(t,x,[1,3,10,5]);
    T = sgtitle('Dynamics'); T.FontSize = 22; T.Interpreter = 'latex';
    % print('Scenario1_Uncontrolled','-dpng');
    F_Control = plotControl(t,a,n,m,v,R0,ss,[1,1,10,5]);
    T = sgtitle('Control and $\mathcal R_0$'); T.FontSize = 22; T.Interpreter = 'latex';
    % print('Scenario1_balancedControls_L1only','-dpng');
else
    %%%% TO PLOT DISEASE AND CONTROL DYNAMICS IN ONE
    %%%% 3x1 PLOT USE THESE LINES (THESE ARE THE ONES IN FIG. 9, 10)
    F_SIR = plotSIRandControls(t,x,a,n,m,v,[1,3,15,4]);
    T = sgtitle("Disease and Control Dynamics"); T.FontSize = 22; T.Interpreter = 'latex';
    % print('Scenario3_xiOne','-dpng');
end
