function [F] = plotSIR(t,x,POSITION)
%PLOTSIR Summary of this function goes here
%   Detailed explanation goes here
if nargin < 3
    POSITION = [];
end
T = max(t);
F=figure(100+randi(99));clf;
subplot(1,2,1); hold on;
plot(t,x.S,'linewidth',2,'color',[0 0.7 0]);
plot(t,x.I,'linewidth',2,'color','r');
plot(t,x.R,'linewidth',2,'color','b');
legend({'$S$','$I$','$R$'},'Interpreter','latex','FontSize',15);
axis([0 T -0.1 1.1]);
ax = gca; 
ax.TickLabelInterpreter = 'latex';
ax.FontSize = 15;
% XX = xlabel("Time $\longrightarrow$"); XX.Interpreter = 'latex';
YY = ylabel("Compliant Pop."); YY.Interpreter = 'latex';
subplot(1,2,2); hold on;
plot(t,x.Ss,'linewidth',2,'color',[0 0.7 0]);
plot(t,x.Is,'linewidth',2,'color','r');
plot(t,x.Rs,'linewidth',2,'color','b');
legend({'$S^*$','$I^*$','$R^*$'},'Interpreter','latex','FontSize',15);
axis([0 T -0.1 1.1]);
ax = gca; 
ax.TickLabelInterpreter = 'latex';
ax.FontSize = 15;
% XX = xlabel("Time $\longrightarrow$"); XX.Interpreter = 'latex';
YY = ylabel("Noncompliant Pop."); YY.Interpreter = 'latex';
%YY = ylabel("Pop. Density"); YY.Interpreter = 'latex';

if nargin >= 3
F.Units = "inches";
F.Position = POSITION;
end

end

