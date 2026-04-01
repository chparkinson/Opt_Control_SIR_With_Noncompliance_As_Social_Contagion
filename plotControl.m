function [F] = plotControl(t,a,n,m,v,R0,ss,POSITION)
if nargin < 6
    POSITION = [];
end
R1 = R0.*(ss<0); R1(R1==0) = NaN;
R2 = R0.*(ss>=0); R2(R2==0) = NaN;
T = max(t);
F = figure(200+randi(99)); clf;

subplot(1,2,1); hold on;
plot(t,a,'linewidth',2,'color',[0 0.7 0]);
plot(t,n,'linewidth',2,'color','b');
plot(t,m,'linewidth',2,'color',[0.6 0 0]);
plot(t,v,'linestyle','--', 'linewidth',2,'color',[0.9 0.4 8/30]);
legend({'$\alpha$','$\eta$','$\mu$','$\nu$'},'Interpreter','latex','FontSize',15);
axis([0 T -0.01 0.75]);
ax = gca; 
ax.TickLabelInterpreter = 'latex';
ax.FontSize = 15;
XX = xlabel('Time $\longrightarrow$'); XX.Interpreter = 'latex';
YY = ylabel('Control values'); YY.Interpreter = 'latex';
subplot(1,2,2); hold on;
plot(t,R1,'-','Color',[0 0.7 0],'linewidth',2);
plot(t,R2,'-','Color','r','linewidth',2);
for k = 1:length(t)-1
    if  (isnan(R2(k)) && isnan(R1(k+1)))
        plot([t(k),t(k+1)],[R1(k),R2(k+1)],'r','LineWidth',2)
    end
    if  (isnan(R1(k)) && isnan(R2(k+1)))
        plot([t(k),t(k+1)],[R2(k),R1(k+1)],'r','LineWidth',2)
    end
end
axis([0 max(t) 0.6 2]);
F.Units = 'inches';
F.Position(3:4) = [5 5];
ax = gca; 
ax.TickLabelInterpreter = 'latex';
ax.FontSize = 15;
XX = xlabel('Time $\longrightarrow$'); XX.Interpreter = 'latex';
YY = ylabel('Reproductive Ratio'); YY.Interpreter = 'latex';
L=legend({'$\mathcal{R}_0(\frac b \delta,0)$','$\mathcal R_0(\frac{\nu+\delta}{\overline \mu-\mu}, \frac b \delta - \frac{\nu+\delta}{\overline \mu-\mu})$'},'Interpreter','latex','FontSize',15,'location','south');
if nargin>=6
    F.Units='inches';
    F.Position = POSITION;
end
end

