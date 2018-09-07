function createfigure_timlag(data1, data2)
%CREATEFIGURE(DATA1, DATA2)
%  DATA1:  histogram data
%  DATA2:  histogram data

%  �� MATLAB �� 03-Aug-2018 14:14:35 �Զ�����

% ���� figure
figure1 = figure;

% ���� axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% ���� histogram
histogram(data1,'DisplayName','<0ms','Parent',axes1,'BinWidth',50);

% ���� histogram
histogram(data2,'DisplayName','>0ms','Parent',axes1,'BinWidth',50);

% ���� xlabel
xlabel('timelag(ms)');

% ���� title
title('Histogram timelag');

% ���� ylabel
ylabel('Count');

% ȡ�������е�ע���Ա���������� Y ��Χ
% ylim(axes1,[0 10]);
box(axes1,'on');
% ���� legend
legend(axes1,'show');

