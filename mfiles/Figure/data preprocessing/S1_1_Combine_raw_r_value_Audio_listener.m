%% LR_Audio_ListenerEEG
% purpose: use logistic regression
% to find the relation between r value and attend target
% Attend A ->1
% Attend
% LJW
% 2018.3.11

% band_name = {'alpha',  'beta', 'beta_hilbert', 'broadband', 'broadband_hilbert',...
%     'delta', 'delta_hilbert', 'gamma', 'gamma_hilbert', 'theta', 'theta_hilbert'};
% band_name = {'alpha', 'alpha_hilbert', 'beta', 'beta_hilbert', 'broadband',...
%     'delta', 'delta_hilbert', 'theta', 'theta_hilbert'};

band_name = {'delta','theta','alpha'};

listener_num = 20;
story_num = 28;


%% new order
load('E:\DataProcessing\Label_and_area.mat');

select_area = 'Small_area';
chn_area_labels = fieldnames(eval(select_area));


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
Correlation_mat.attendDecoder_attend = zeros(listener_num,story_num,length(timelag)); % speaker area * listener * story * time-lag
Correlation_mat.unattendDecoder_unattend = zeros(listener_num,story_num,length(timelag));
Correlation_mat.attendDecoder_unattend = zeros(listener_num,story_num,length(timelag));
Correlation_mat.unattendDecoder_attend = zeros(listener_num,story_num,length(timelag));

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    
    
    for time_point = 1 : length(timelag)
        
        for listener_select = 1 : listener_num
            
            %% listener name
            if listener_select < 10
                file_name = strcat('listener10',num2str(listener_select));
            else
                file_name = strcat('listener1',num2str(listener_select));
            end
            
            %% load r value data
            
            data_name = strcat('mTRF_Audio_listenerEEG_result-timelag',num2str(timelag(time_point)),'ms-',band_file_name,'.mat');
            
            data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Audio-listener\no zscore\0-raw r value\',...
                band_file_name,'\',file_name,'\');
            %
            %                 data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Surrogate\Speaker ListenerEEG zscore surrogate10\',...
            %                     band_file_name,'\',file_name,'\',chn_area_labels{chn_area_select},'\');
            
            load(strcat(data_path,data_name));
            
            %% combine r value
            for story_select = 1:length(attend_target_num)
                if attend_target_num(story_select) == 1
                    Correlation_mat.attendDecoder_attend(listener_select,story_select,time_point) = recon_AttendDecoder_AudioA_corr(story_select);
                    Correlation_mat.attendDecoder_unattend(listener_select,story_select,time_point) = recon_AttendDecoder_AudioB_corr(story_select);
                    Correlation_mat.unattendDecoder_attend(listener_select,story_select,time_point) = recon_UnattendDecoder_AudioA_corr(story_select);
                    Correlation_mat.unattendDecoder_unattend(listener_select,story_select,time_point) = recon_UnattendDecoder_AudioB_corr(story_select);
                else
                    Correlation_mat.attendDecoder_attend(listener_select,story_select,time_point) = recon_AttendDecoder_AudioB_corr(story_select);
                    Correlation_mat.attendDecoder_unattend(listener_select,story_select,time_point) = recon_AttendDecoder_AudioA_corr(story_select);
                    Correlation_mat.unattendDecoder_attend(listener_select,story_select,time_point) = recon_UnattendDecoder_AudioB_corr(story_select);
                    Correlation_mat.unattendDecoder_unattend(listener_select,story_select,time_point) = recon_UnattendDecoder_AudioA_corr(story_select);
                    
                end
            end
        end
    end
    
    %% save data
    save('Correlation_mat.mat','Correlation_mat');
    
%     %% plot
%     plot_name = fieldnames(Correlation_mat);
%     for plot_select = 1 : length(plot_name)
%         data_name = strcat('Correlation_mat.',plot_name{plot_select});
%         data_for_imagesc = eval(strcat('squeeze(mean(mean(',data_name,',3),2));'));
%         % imagesc
%         set(gcf,'outerposition',get(0,'screensize'));
%         imagesc(data_for_imagesc);colorbar;
%         %         caxis([-0.04 0.1]);
%         %     colormap('jet');
%         xticks(label_select);
%         xticklabels(timelag(label_select));
%         yticks(1:length(chn_area_labels));
%         yticklabels(chn_area_labels);
%         xlabel('timelag(ms)');
%         ylabel('Speaker Channels');
%         save_name = strcat('Raw r value-',band_name{band_select},'-imagesc-',plot_name{plot_select},'-',select_area,'.jpg');
%         title(save_name(1:end-4));
%         saveas(gcf,save_name);
%         close
%     end
%     
    % file
    
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end