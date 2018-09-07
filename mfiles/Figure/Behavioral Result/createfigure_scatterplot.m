function createfigure(X1, Y1)
%CREATEFIGURE(X1, Y1)
%  X1:  scatter x
%  Y1:  scatter y

%  由 MATLAB 于 18-Aug-2018 22:33:11 自动生成

% 创建 figure
figure1 = figure;

% 创建 axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% 创建 scatter
scatter(X1,Y1,'MarkerFaceColor',[0 0 0],'MarkerEdgeColor','none');

% 创建 xlabel
xlabel('R^2 value','FontSize',17.6);

% 创建 title
title({'Speaker-listener EEG Fz delta'},'FontSize',17.6);

% 创建 ylabel
ylabel('latency','FontSize',17.6);

% 设置其余坐标轴属性
set(axes1,'FontSize',16,'LineWidth',2);
