function createfigure(X1, Y1)
%CREATEFIGURE(X1, Y1)
%  X1:  scatter x
%  Y1:  scatter y

%  �� MATLAB �� 18-Aug-2018 22:33:11 �Զ�����

% ���� figure
figure1 = figure;

% ���� axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% ���� scatter
scatter(X1,Y1,'MarkerFaceColor',[0 0 0],'MarkerEdgeColor','none');

% ���� xlabel
xlabel('R^2 value','FontSize',17.6);

% ���� title
title({'Speaker-listener EEG Fz delta'},'FontSize',17.6);

% ���� ylabel
ylabel('latency','FontSize',17.6);

% ������������������
set(axes1,'FontSize',16,'LineWidth',2);
