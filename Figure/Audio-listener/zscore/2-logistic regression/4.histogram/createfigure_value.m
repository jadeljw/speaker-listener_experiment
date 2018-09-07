function createfigure_value(data1, data2)
%CREATEFIGURE(DATA1, DATA2)
%  DATA1:  histogram data
%  DATA2:  histogram data

%  �� MATLAB �� 03-Aug-2018 14:09:32 �Զ�����

% ���� figure
figure1 = figure;

% ���� axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% ���� histogram
histogram(data1,'DisplayName','<0ms','Parent',axes1,'BinWidth',0.1);

% ���� histogram
histogram(data2,'DisplayName','>0ms','Parent',axes1,'BinWidth',0.1);

% ���� xlabel
xlabel({'R^2 value'});

% ���� title
title('Histogram Audio-listener R^2 value');

% ���� ylabel
ylabel({'count'});

box(axes1,'on');
% ���� legend
legend(axes1,'show');

