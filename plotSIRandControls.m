function [F] = plotSIRandControls(t,x,a,n,m,v,POSITION)
% This is a helper function used only for plotting the results of a
% simulation in the case that xi >0.
%
% It produces the plots from figures 6,7 that include three panels with
% compliant dynamics, noncompliant dynamics and controls.
%
% Any of the settings for those plots can be changed below. 

if nargin < 3
    POSITION = [];
end
T = max(t);
F=figure(500+randi(99));clf;
subplot(1,3,1); hold on;
plot(t,x.S,'linewidth',2,'color',[0 0.7 0]);
plot(t,x.I,'linewidth',2,'color','r');
plot(t,x.R,'linewidth',2,'color','b');
legend({'$S$','$I$','$R$'},'Interpreter','latex','FontSize',15);
axis([0 T -0.1 1.1]);
ax = gca; 
ax.TickLabelInterpreter = 'latex';
ax.FontSize = 15;
XX = xlabel("Time $\longrightarrow$"); XX.Interpreter = 'latex';
YY = ylabel("Compliant Pop."); YY.Interpreter = 'latex';
subplot(1,3,2); hold on;
plot(t,x.Ss,'linewidth',2,'color',[0 0.7 0]);
plot(t,x.Is,'linewidth',2,'color','r');
plot(t,x.Rs,'linewidth',2,'color','b');
legend({'$S^*$','$I^*$','$R^*$'},'Interpreter','latex','FontSize',15);
axis([0 T -0.1 1.1]);
ax = gca; 
ax.TickLabelInterpreter = 'latex';
ax.FontSize = 15;
XX = xlabel("Time $\longrightarrow$"); XX.Interpreter = 'latex';
YY = ylabel("Noncompliant Pop."); YY.Interpreter = 'latex';
%YY = ylabel("Pop. Density"); YY.Interpreter = 'latex';
subplot(1,3,3); hold on;
plot(t,a,'linewidth',2,'color',[0 0.7 0]);
plot(t,n,'linewidth',2,'color','r');
plot(t,m,'linewidth',2,'color','b');
plot(t,v,'linestyle','--', 'linewidth',2,'color','m');
legend({'$\alpha$','$\eta$','$\mu$','$\nu$'},'Interpreter','latex','FontSize',15);
axis([0 T -0.01 0.85]);
ax = gca; 
ax.TickLabelInterpreter = 'latex';
ax.FontSize = 15;
XX = xlabel('Time $\longrightarrow$'); XX.Interpreter = 'latex';
YY = ylabel('Control value'); YY.Interpreter = 'latex';

if nargin >= 3
F.Units = "inches";
F.Position = POSITION;
end

end

