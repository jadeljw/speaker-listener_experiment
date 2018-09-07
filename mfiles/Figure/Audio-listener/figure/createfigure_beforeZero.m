function createfigure_beforeZero(cdata1)
%CREATEFIGURE(CDATA1)
%  CDATA1:  image cdata

%  由 MATLAB 于 02-Aug-2018 15:56:21 自动生成

% 创建 figure
figure1 = figure;

% 创建 axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% 创建 image
image(cdata1,'Parent',axes1,'CDataMapping','scaled');

% 创建 xlabel
xlabel('timelag(ms)');

% 创建 title
title('before 0ms');

% 创建 ylabel
ylabel('Listener No.');

% 取消以下行的注释以保留坐标轴的 X 范围
xlim(axes1,[0.5 33.5]);
% 取消以下行的注释以保留坐标轴的 Y 范围
ylim(axes1,[0.5 20.5]);
box(axes1,'on');
axis(axes1,'ij');
% 设置其余坐标轴属性
set(axes1,'CLim',[0 0.3],'Layer','top','XTick',...
    [0.5 6.7 13.4 20.1 26.8 33.5],'XTickLabel',...
    {'-500','-400','-300','-200','-100','0'});
% 创建 colorbar
colorbar('peer',axes1);

