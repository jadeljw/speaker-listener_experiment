%% LR_Audio_ListenerEEG
% purpose: use logistic regression
% to find the relation between r value and attend target
% Attend A ->1
% Attend
% LJW

mkdir('Logistic Regression 99%');
cd('Logistic Regression 99%')


band_name = {'alpha', 'alpha_hilbert', 'beta', 'beta_hilbert', 'broadband',...
    'delta', 'delta_hilbert', 'theta', 'theta_hilbert'};

listener_num = 20;
story_num = 28;
% bin_num = 40;
surrogate_set = 1:10;
range_total  = [0.0574	0.0568	0.0577	0.0625	0.06	0.054	0.0493	0.0584	0.0548];


%% new order
load('E:\DataProcessing\Label_and_area.mat');

select_area = 'Small_area';
chn_area_labels = fieldnames(eval(select_area));
plot_area_order = [4 6 5 2 1 3 7 8 9];

%% colormap
load('E:\DataProcessing\colormap_blue_red.mat');

%% initial
load('E:\DataProcessing\chn_re_index.mat');
chn_re_index = chn_re_index(1:64);

listener_chn= [1:32 34:42 44:59 61:63];
% % speaker_chn = 63;
% speaker_chn = [28 31 48 63];
% speaker_chn = [2 10 19 28 38 48 56 62];% central channels
% speaker_chn = [1:32 34:42 44:59 61:63];
% speaker_chn = [17:21 26:30 36:40];
% speaker_chn = [9:11 18:20 27:29];
load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';

%% timelag
Fs = 64;
timelag = -500 : 1000/Fs : 500;
label_select = 1 : round(length(timelag)/8) :length(timelag);

%% initial
Correlation_mat_total = zeros(listener_num,length(chn_area_labels),length(timelag));

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    %     mkdir(band_file_name);
    %     cd(band_file_name);
    disp(band_file_name);
    
    range_select = range_total(band_select);
    
    %% load raw data
    data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\5-logistic regression\20 listeners\',band_file_name,'\total');
    %     data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Surrogate\0-raw r value\surrogate10\',band_file_name);
    data_name_raw = strcat('Speaker ListenerEEG Logstic Regresssion r^2 Result-total-',band_file_name,'-total-Small_area.mat');
    load(strcat(data_path,'\',data_name_raw));
    data_raw = R_squared_mat_speaker;
    
    data_for_imagesc = data_raw;
    %% plot
    % imagesc
    set(gcf,'outerposition',get(0,'screensize'));
    imagesc((data_for_imagesc> range_select).* data_for_imagesc);colorbar;
%     caxis([-0.01 0.01]);
    %     colormap('jet');
    xticks(label_select);
    xticklabels(timelag(label_select));
    yticks(1:length(chn_area_labels));
    yticklabels(chn_area_labels);
    xlabel('timelag(ms)');
    ylabel('Speaker Channels');

%     title(band_name{band_select});
    
    
    save_name = strcat('Raw r value difference surrogate-',band_name{band_select},'-histogram.jpg');
    title(save_name(1:end-4));
    saveas(gcf,save_name);
    
    save_name = strcat('Raw r value difference surrogate-',band_name{band_select},'-histogram.fig');
    saveas(gcf,save_name);
    close
    
    
    % file
    
    %     p = pwd;
    %     cd(p(1:end-(length(band_file_name)+1)));
end