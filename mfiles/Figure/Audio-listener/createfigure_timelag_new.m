function createfigure_timelag_new(cdata1)
%CREATEFIGURE(CDATA1)
%  CDATA1:  image cdata

%  �� MATLAB �� 04-Aug-2018 11:54:30 �Զ�����

% ���� figure
figure1 = figure('OuterPosition',get(0,'screensize'));
colormap(copper);

% ���� axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% ���� image
image(cdata1,'Parent',axes1,'CDataMapping','scaled');

% ���� xlabel
xlabel('timelag(ms)');

% ���� ylabel
ylabel('Listener No.');

% ȡ�������е�ע���Ա���������� X ��Χ
xlim(axes1,[0.5 65.5]);
% ȡ�������е�ע���Ա���������� Y ��Χ
ylim(axes1,[0.5 20.5]);
box(axes1,'on');
axis(axes1,'ij');
% ������������������
set(axes1,'CLim',[-0.1693 1],'Layer','top','XTick',...
    [0.5 8.5 16.5 24.5 32.5 40.5 48.5 56.5 64.5],'XTickLabel',...
    {'-500','-375','-250','-125','0','125','250','375','500'});
% ���� colorbar
colorbar('peer',axes1);

% ���� line
annotation(figure1,'line',[0.6 0.6],[0.1 0.1],'Color',[1 1 1],'LineWidth',4);

% ���� line
annotation(figure1,'line',[0.577083333333333 0.5765625],...
    [0.931095406360424 0.106007067137809],'Color',[1 1 1],'LineWidth',4);

