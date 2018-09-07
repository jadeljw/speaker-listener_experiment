function createfigure_timelag_new(cdata1)
%CREATEFIGURE(CDATA1)
%  CDATA1:  image cdata

%  由 MATLAB 于 04-Aug-2018 11:54:30 自动生成

% 创建 figure
figure1 = figure('OuterPosition',get(0,'screensize'));
colormap(copper);

% 创建 axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% 创建 image
image(cdata1,'Parent',axes1,'CDataMapping','scaled');

% 创建 xlabel
xlabel('timelag(ms)');

% 创建 ylabel
ylabel('Listener No.');

% 取消以下行的注释以保留坐标轴的 X 范围
xlim(axes1,[0.5 65.5]);
% 取消以下行的注释以保留坐标轴的 Y 范围
ylim(axes1,[0.5 20.5]);
box(axes1,'on');
axis(axes1,'ij');
% 设置其余坐标轴属性
set(axes1,'CLim',[-0.1693 1],'Layer','top','XTick',...
    [0.5 8.5 16.5 24.5 32.5 40.5 48.5 56.5 64.5],'XTickLabel',...
    {'-500','-375','-250','-125','0','125','250','375','500'});
% 创建 colorbar
colorbar('peer',axes1);

% 创建 line
annotation(figure1,'line',[0.6 0.6],[0.1 0.1],'Color',[1 1 1],'LineWidth',4);

% 创建 line
annotation(figure1,'line',[0.577083333333333 0.5765625],...
    [0.931095406360424 0.106007067137809],'Color',[1 1 1],'LineWidth',4);

