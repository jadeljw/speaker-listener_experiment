function createfigure_timlag(data1, data2)
%CREATEFIGURE(DATA1, DATA2)
%  DATA1:  histogram data
%  DATA2:  histogram data

%  由 MATLAB 于 03-Aug-2018 14:14:35 自动生成

% 创建 figure
figure1 = figure;

% 创建 axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% 创建 histogram
histogram(data1,'DisplayName','<0ms','Parent',axes1,'BinWidth',50);

% 创建 histogram
histogram(data2,'DisplayName','>0ms','Parent',axes1,'BinWidth',50);

% 创建 xlabel
xlabel('timelag(ms)');

% 创建 title
title('Histogram timelag');

% 创建 ylabel
ylabel('Count');

% 取消以下行的注释以保留坐标轴的 Y 范围
% ylim(axes1,[0 10]);
box(axes1,'on');
% 创建 legend
legend(axes1,'show');

