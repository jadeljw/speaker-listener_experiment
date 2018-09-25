% adapted from mTRF_decoding_sound_from_wav_keep_order_all_listener.m date:
% 2018.4.17 author: LJW purpose: to calculate r value using attend decoder
% and unattend decoder Attend target A ->1 Attend target B ->0

band_name = {'delta','theta','alpha'};
% band_name = {'delta'};
% band_name = {'alpha', 'alpha_hilbert', 'beta', 'beta_hilbert', 'broadband',...
%     'delta', 'delta_hilbert', 'theta', 'theta_hilbert'};


%% initial
load('E:\DataProcessing\chn_re_index.mat');
chn_re_index = chn_re_index(1:64);

listener_chn= [1:32 34:42 44:59 61:63];
load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';

listener_num = 20;
story_num  = 28;


%% mTRF intitial
%
% start_time_total = [-500 -500 -250 0 250 -150 -500 0];
% end_time_total = [500 -250 0  250 500 450 0 500];

start_time_total = [-500 -500  0];
end_time_total = [500  0  500];
lambda_select = 6;

lambda_index = 0:2:20;
lambda = 2.^lambda_index;


for time_select = 1 : length(start_time_total)
    time_file_name = strcat(num2str(start_time_total(time_select)),'ms~',num2str(end_time_total(time_select)),'ms');
    disp(time_file_name);
    mkdir(time_file_name);
    cd(time_file_name);
    
    
    % initial bar plot
    bar_plot_att = zeros(listener_num,length(band_name));
    bar_plot_unatt = zeros(listener_num,length(band_name));
    
    for band_select = 1 : length(band_name)
        band_file_name = strcat(band_name{band_select});
        
        %% load high r channels
        load('E:\DataProcessing\speaker-listener_experiment\Figure\Audio-listener\zscore\8-forward model\6-EEG estimate\1-raw result\high_r_channels.mat');
        channel_select_total = eval(strcat('high_r_channels.',band_file_name));
        
        
        %% mTRF matrix intial
        
        
        for listener_select = 1 : 20
            
            %% listener name
            if listener_select < 10
                listener_file_name = strcat('listener10',num2str(listener_select));
            else
                listener_file_name = strcat('listener1',num2str(listener_select));
            end
            
            
            %% load data
            load(strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Audio-listener\zscore\8-forward model\6-EEG estimate\1-raw result\',...
                band_file_name,'\',listener_file_name,'\mTRF Audio-listener start_time',num2str(start_time_total(time_select)),'ms end_time',num2str(end_time_total(time_select)),'ms.mat'));
            
            %% mean data
            bar_plot_att(listener_select,band_select) = squeeze(mean(mean(R_att(:,lambda_select,channel_select_total),3)));
            bar_plot_unatt(listener_select,band_select) = squeeze(mean(mean(R_unatt(:,lambda_select,channel_select_total),3)));
        end
        
        
        
    end
    
    set(gcf,'outerposition',get(0,'screensize'));
    %     color_max = max(max([mean(bar_plot_att) mean(bar_plot_unatt)]))+0.0001;
    color_max = 0.035;
    
    subplot(121);
    bar(mean(bar_plot_att));
    title('Attend Decoder');
    xticks(1:length(band_name));
    xticklabels(band_name);
    ylabel('mean R value');
    xlabel('Frequency band');
    ylim([0 color_max]);
    
    subplot(122);
    bar(mean(bar_plot_unatt));
    title('Unattend Decoder');
    xticks(1:length(band_name));
    xticklabels(band_name);
    ylabel('mean R value');
    xlabel('Frequency band');
    ylim([0 color_max]);
    
    save_name = strcat('barplot-time ',num2str(start_time_total(time_select)),'ms~',num2str(end_time_total(time_select)),'ms');
    suptitle(save_name);
    saveas(gcf,strcat(save_name,'.jpg'));
    saveas(gcf,strcat(save_name,'.fig'));
    close
    
    p = pwd;
    cd(p(1:end-(length(time_file_name)+1)));
end