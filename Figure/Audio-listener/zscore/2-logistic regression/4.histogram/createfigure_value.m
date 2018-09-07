function createfigure_value(data1, data2)
%CREATEFIGURE(DATA1, DATA2)
%  DATA1:  histogram data
%  DATA2:  histogram data

%  由 MATLAB 于 03-Aug-2018 14:09:32 自动生成

% 创建 figure
figure1 = figure;

% 创建 axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% 创建 histogram
histogram(data1,'DisplayName','<0ms','Parent',axes1,'BinWidth',0.1);

% 创建 histogram
histogram(data2,'DisplayName','>0ms','Parent',axes1,'BinWidth',0.1);

% 创建 xlabel
xlabel({'R^2 value'});

% 创建 title
title('Histogram Audio-listener R^2 value');

% 创建 ylabel
ylabel({'count'});

box(axes1,'on');
% 创建 legend
legend(axes1,'show');

