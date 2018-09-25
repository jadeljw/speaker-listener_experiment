% adapted from mTRF_decoding_sound_from_wav_keep_order_all_listener.m date:
% 2018.4.17 author: LJW purpose: to calculate r value using attend decoder
% and unattend decoder Attend target A ->1 Attend target B ->0

band_name = {'delta','theta','alpha'};
% band_name = {'theta'};
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
xticks_num = 8;

%% mTRF intitial

% start_time_total = [-500 -500 -250 0 250 -150 -500 0];
% end_time_total = [500 -250 0  250 500 450 0 500];

start_time_total = -2000;
end_time_total = 2000;
lambda_select = 6;

lambda_index = 0:2:20;
lambda = 2.^lambda_index;

timelag_length = 258;
%% load high r channels
load('E:\DataProcessing\speaker-listener_experiment\Figure\Audio-listener\zscore\8-forward model\6-EEG estimate\1-raw result\high_r_channels.mat');


for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    
    channel_select_total = eval(strcat('high_r_channels.',band_file_name));
    
    %% mTRF matrix intial
    
    
    for time_select = 1 : length(start_time_total)
        time_file_name = strcat(num2str(start_time_total(time_select)),'ms~',num2str(end_time_total(time_select)),'ms');
        disp(time_file_name);
        mkdir(time_file_name);
        cd(time_file_name);
        
        mean_TRF_attend= zeros(listener_num,timelag_length);
        mean_TRF_unattend = zeros(listener_num,timelag_length);
        
        
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
            
            %% data for analysis
            data_att_select = zscore(squeeze(mean(MODEL_att(:,lambda_select,:,channel_select_total))));
            data_att_select_mean = mean(data_att_select,2);
            data_unatt_select = zscore(squeeze(mean(MODEL_unatt(:,lambda_select,:,channel_select_total))));
            data_unatt_select_mean = mean(data_unatt_select,2);
            
            %% GFP
            
            mean_TRF_attend(listener_select,:) = data_att_select_mean;
            mean_TRF_unattend(listener_select,:) =  data_unatt_select_mean;
            
            %% plot
            set(gcf,'outerposition',get(0,'screensize'));
            plot(mean_TRF_attend(listener_select,:),'k','lineWidth',2);
            hold on;plot(mean_TRF_unattend(listener_select,:),'k--','lineWidth',2);
            legend('attend','unattend','Location','best');
            xticks(1:(length(mean_TRF_attend)-1)/xticks_num:length(mean_TRF_attend));
            xticklabels(start_time_total(time_select):(end_time_total(time_select)-start_time_total(time_select))/xticks_num:end_time_total(time_select));
            xlabel('timelag(ms)');
            ylabel('a.u.');
            title(strcat('Mean plot start-time:',num2str(start_time_total(time_select)),'ms~end-time:',num2str(end_time_total(time_select)),'ms-',band_file_name,'-',listener_file_name));
            save_name = strcat('Mean plotstart-time ',num2str(start_time_total(time_select)),'ms~end-time ',num2str(end_time_total(time_select)),'ms-',band_file_name,'-',listener_file_name);
            saveas(gcf,strcat(save_name,'.jpg'));
            saveas(gcf,strcat(save_name,'.fig'));
            close
            
        end
        
        %% plot
        set(gcf,'outerposition',get(0,'screensize'));
        plot(mean(mean_TRF_attend,1),'k','lineWidth',2);
        hold on;plot(mean(mean_TRF_unattend,1),'k--','lineWidth',2);
        legend('attend','unattend','Location','best');
        xticks(1:(length(mean_TRF_attend)-1)/xticks_num:length(mean_TRF_attend));
        xticklabels(start_time_total(time_select):(end_time_total(time_select)-start_time_total(time_select))/xticks_num:end_time_total(time_select));
        xlabel('timelag(ms)');
        ylabel('a.u.');
        title(strcat('Mean plot Zscore start-time:',num2str(start_time_total(time_select)),'ms~end-time:',num2str(end_time_total(time_select)),'ms-',band_file_name));
        save_name = strcat('Mean plot Zscore start-time ',num2str(start_time_total(time_select)),'ms~end-time ',num2str(end_time_total(time_select)),'ms-',band_file_name);
        saveas(gcf,strcat(save_name,'.jpg'));
        saveas(gcf,strcat(save_name,'.fig'));
        close
        
        %% save
        save(strcat(save_name,'.mat'),'mean_TRF_attend','mean_TRF_unattend')
        
        
        % file
        p = pwd;
        cd(p(1:end-(length(time_file_name)+1)));
    end
    
    
    
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end