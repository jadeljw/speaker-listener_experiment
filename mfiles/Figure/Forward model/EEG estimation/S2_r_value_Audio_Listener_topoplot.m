% adapted from mTRF_decoding_sound_from_wav_keep_order_all_listener.m date:
% 2018.4.17 author: LJW purpose: to calculate r value using attend decoder
% and unattend decoder Attend target A ->1 Attend target B ->0

% band_name = {'delta','theta','alpha','beta'};
band_name = {'delta'};
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

% start_time_total = [-500 -500 -250 0 250 -150 -500 0];
% end_time_total = [500 -250 0  250 500 450 0 500];

start_time_total = -2000;
end_time_total = 2000;
lambda_select = 6;

lambda_index = 0:2:20;
lambda = 2.^lambda_index;

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    
    %% mTRF matrix intial
    
    
    for time_select = 1 : length(start_time_total)
        time_file_name = strcat(num2str(start_time_total(time_select)),'ms~',num2str(end_time_total(time_select)),'ms');
        disp(time_file_name);
        mkdir(time_file_name);
        cd(time_file_name);
        
        R_value_attend = zeros(listener_num,length(listener_chn));
        R_value_unattend = zeros(listener_num,length(listener_chn));
        
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
            R_value_attend(listener_select,:) = squeeze(mean(R_att(:,6,:)))';
            R_value_unattend(listener_select,:) = squeeze(mean(R_unatt(:,6,:)))';
        end
        
        % topoplot
        set(gcf,'outerposition',get(0,'screensize'));
        color_max = max(max([mean(R_value_attend) mean(R_value_unattend)]));
        subplot(121);
        U_topoplot(mean(R_value_attend)',layout,label66(listener_chn));colorbar('SouthOutside');
        title('attend decoder');
        caxis([0 color_max]);  
        
        subplot(122);
        U_topoplot(mean(R_value_unattend)',layout,label66(listener_chn));colorbar('SouthOutside');
        title('unattend decoder');
        caxis([0 color_max]);  
        
        save_name = strcat(band_file_name,' start-time',num2str(start_time_total(time_select)),'ms end-time',num2str(end_time_total(time_select)),'ms');
        suptitle(save_name);
        saveas(gcf,strcat(save_name,'.jpg'));
        saveas(gcf,strcat(save_name,'.fig'));
        close
        
        % file
        p = pwd;
        cd(p(1:end-(length(time_file_name)+1)));
    end
    
    
    
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end