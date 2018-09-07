function createfigure_beforeZero(cdata1)
%CREATEFIGURE(CDATA1)
%  CDATA1:  image cdata

%  �� MATLAB �� 02-Aug-2018 15:56:21 �Զ�����

% ���� figure
figure1 = figure;

% ���� axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% ���� image
image(cdata1,'Parent',axes1,'CDataMapping','scaled');

% ���� xlabel
xlabel('timelag(ms)');

% ���� title
title('before 0ms');

% ���� ylabel
ylabel('Listener No.');

% ȡ�������е�ע���Ա���������� X ��Χ
xlim(axes1,[0.5 33.5]);
% ȡ�������е�ע���Ա���������� Y ��Χ
ylim(axes1,[0.5 20.5]);
box(axes1,'on');
axis(axes1,'ij');
% ������������������
set(axes1,'CLim',[0 0.3],'Layer','top','XTick',...
    [0.5 6.7 13.4 20.1 26.8 33.5],'XTickLabel',...
    {'-500','-400','-300','-200','-100','0'});
% ���� colorbar
colorbar('peer',axes1);

