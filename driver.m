clear;
close all;

%%%% time interval
T = 100;
dt = 0.1;
t = 0:dt:T;

%% %%%% parameters (you can set them manually or load them from the files
%%%%             to get the figures from the manuscript)

%%%% use these lines to manually set parameters
% b = 0.01; XI = 0; d = 0.01;      %birth/death related parameters
% B = 0.4; g = 0.2; ETA = 0.1;       %disease related parameters
% MU = 0.1; NU = 0.1;                %noncompliance related parameters
% MU_cap = MU; % used to turn off mu if desired (eta and nu can be turned off
%              % by setting ETA = 0 or NU = 0, but doing this for MU will
%              % change the model by eliminating spread of noncompliance)
% % cost weights
% c1 = 1; c2 = 0.1; c3 = 1; c4 = 1;  c5 = 1; c6 = 1;

%%%% use the ensuing line
%%%% NOTE: if  you load Figure6params.mat it will have c1=9 which will give
%%%%       you the bottom plots from Figure 6; it can be manually changed  
%%%%       to get the others
%%%%       Likewise, the Figure7params.mat has XI=1, which gives the bottom
%%%%       bottom plots from Figure 7; it can be manually changed to get 
%%%%       the others        
load Figure3params.mat;

%%%% initialize state and costate solutions.
x.S  = zeros(1,length(t)); x.I  = zeros(1,length(t)); x.R  = zeros(1,length(t));
x.Ss = zeros(1,length(t)); x.Is = zeros(1,length(t)); x.Rs = zeros(1,length(t));
p.S  = zeros(1,length(t)); p.I  = zeros(1,length(t)); p.R  = zeros(1,length(t));
p.Ss = zeros(1,length(t)); p.Is = zeros(1,length(t)); p.Rs = zeros(1,length(t));

%%%% initialize control vectors
a = zeros(1,length(t));  % alpha
n = zeros(1,length(t));  % eta
m = zeros(1,length(t));  % mu
v = zeros(1,length(t));  % nu

%%%% initial condition
x0 = [0.69,0.01,0,0.29,0.01,0]';

%%%% iterate to resolve soln to optimal State-Adjoint-Control syetem
tol = 1e-3; max_iter = 5000; W = 0.8;
for k = 1:max_iter
    xold = x; aold = a; nold = n; mold = m; vold = v;

    %%%% solve state equation
    x = solveSIR(x0,t,b,d,XI,B,g,MU,a,n,m,v);

    %%%% compute cost with no controls used (so that we can observe savings)
    if k == 1
        [Cost_U,Icost_U,NCcost_U,Ccost_U] = computeCost(t,x,a,n,m,v,c1,c2,c3,c4,c5,c6);
        xU = x; % save uncontrolled simulation
    end


    %%%% solve adjoint equation
    p = solveAdj(t,x,d,B,g,MU,a,n,m,v,c1,c2);

    %%%% recompute controls
    a = B*x.S.*(x.I+x.Is).*(p.I-p.S)/c3; a = min(max(a,0),1);
    a = (1-W)*a+W*aold;
    n = x.I.*(p.I-p.R)/c4; n = min(max(n,0),ETA);
    n = (1-W)*n+W*nold;
    m = (x.Ss+x.Is+x.Rs).*(x.S.*(p.Ss-p.S)+x.I.*(p.Is-p.I)+x.R.*(p.Rs-p.R))/c5; m = min(max(m,0),MU_cap);
    m = (1-W)*m+W*mold;
    v = (x.Ss.*(p.Ss-p.S)+x.Is.*(p.Is-p.I)+x.Rs.*(p.Rs-p.R))/c6; v = min(max(v,0),NU);
    v = (1-W)*v+W*vold;

    %%%% check for convergence
    chA = tol*max(abs(a))-max(abs(a-aold)); chN = tol*max(abs(n))-max(abs(n-nold)); chM = tol*max(abs(m))-max(abs(m-mold)); chV = tol*max(abs(v))-max(abs(v-vold));
    change = min([chA,chN,chM,chV]);
    if change >= 0
        fprintf("Iteration converged after %i steps. Final change = %.4e\n",k,change);
        break;
    end

    %%%% print progress
    if mod(k,100)==0
        fprintf("Completed iteration %i. Change = %.4e\n",k,change)
        if k >= 2500
            fprintf("Unconverged by iteration %i. Increasing W.\n",k);
            W =  min(0.99,1.1*W);
        end
    end
end
%%%% report if convergence failed
if k == max_iter
    fprintf("Failed to converge to tolerance %.2e in %i iterations\n",tol,max_iter);
end
%%%% compute costs
[Cost,Icost,NCcost,Ccost] = computeCost(t,x,a,n,m,v,c1,c2,c3,c4,c5,c6);

%%%% compute R0 corresponding to theorem 2.5(i),(ii)
%%%% NOTE: this is only relevant when XI = 0
s = b/d; ss = 0;
R01 = B*((1-a).*(1-n./(g+n+v+d+(MU-m).*ss)).*s + ss)./(g+d+v.*n./(g+n+v+d+ss.*(MU-m)));
s = min((d+v)./(MU-m),2); ss = b/d - s;
R02 = B*((1-a).*(1-n./(g+n+v+d+(MU-m).*ss)).*s + ss)./(g+d+v.*n./(g+n+v+d+ss.*(MU-m)));
%R0 = B*((1-a).*(1-n./(g+n+v+d+(MU-m).*x.Ss)).*x.S + x.Ss)./(g+d+v.*n./(g+n+v+d+x.Ss.*(MU-m)));
R0 = (ss<0).*R01 + (ss>=0).*R02;

%%%% report costs and savings
fprintf("====================================================\n");
fprintf("Total cost of uncontrolled simulation : %.4e\n",Cost_U);
fprintf("Total cost of controlled simulation   : %.4e\n",Cost);
fprintf("Relative cost savings                 : %.2f%%\n",100*(Cost_U-Cost)/Cost_U);
fprintf("====================================================\n");

%% %%%%% plot results %%%%%
if XI==0
    %%%% TO PLOT THE DISEASE DYNAMICS IN ONE 2x1 PLOT
    %%%% AND THE CONTROL AND R0 DYNAMICS IN ANOTHER
    %%%% USE THESE LINES... THESE WERE USED FOR FIG. 2-5
    F_SIR = plotSIR(t,x,[1,3,10,5]);
    T = sgtitle('Disease Dynamics'); T.FontSize = 22; T.Interpreter = 'latex';
    F_Control = plotControlandR0(t,a,n,m,v,R0,ss,[1,3,10,5]);
    T = sgtitle('Control and $\mathcal R_0$'); T.FontSize = 22; T.Interpreter = 'latex';
   
else
    %%%% TO PLOT DISEASE AND CONTROL DYNAMICS IN ONE
    %%%% 3x1 PLOT USE THESE LINES (THESE ARE THE ONES IN FIG. 6)
    F_SIR = plotSIRandControls(t,x,a,n,m,v,[1,1,15,4]);
    T = sgtitle("Disease Dynamics and Controls"); T.FontSize = 22; T.Interpreter = 'latex';
end

% NOTE: To plot uncontrolled case in figure 2, load Figure3params.mat and
% change 'x' in line 116 to 'xU'