%% plot speaker area


%% load layout
load('E:\DataProcessing\Label_and_area.mat');

select_area = 'Small_area';
chn_area_labels = fieldnames(eval(select_area));


%% initial
load('E:\DataProcessing\chn_re_index.mat');
chn_re_index = chn_re_index(1:64);

listener_chn= [1:32 34:42 44:59 61:63];
speaker_chn_total= [1:32 34:42 44:59 61:63];

% speaker_chn = [9:11 18:20 27:29];
load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';

plot_number = [1 5 10 5 10 1 5 1 10];
%% plot
speaker_plot = zeros(64,1);

for chn_area_select = 1 : length(chn_area_labels)
    disp(chn_area_labels{chn_area_select});
    speaker_chn = eval(strcat(select_area,'.',chn_area_labels{chn_area_select}));
    speaker_plot(speaker_chn) = plot_number(chn_area_select);
end


U_topoplot(speaker_plot(speaker_chn_total),layout,label66(speaker_chn_total));
title('Speaker areas');
