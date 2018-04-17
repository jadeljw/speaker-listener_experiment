% mTRF_SpeakerB_forward_plot_r_value

% reversed 2018.4.9
% author: LJW
% purpose: to plot mTRF crossval r value for SpeakerB

band_name = {'delta','theta','alpha'};
% band_name = {'alpha'};
% band_name = {'narrow_theta'};


%% new order
load('E:\DataProcessing\Label_and_area.mat');

chn_area_labels = fieldnames(Small_area);

%% initial
load('E:\DataProcessing\chn_re_index.mat');
chn_re_index = chn_re_index(1:64);

% listener
listener_chn = order;
% listener_chn= [1:32 34:42 44:59 61:63];

% speaker
% speaker_chn = order;
% speaker_chn = [1:32 34:42 44:59 61:63];

load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';

%% listener
listener_num = 20;


%% timelag
Fs = 64;
timelag_plot = -1000: 1000/Fs: 1000;
%     timelag = -250:(1000/Fs):500;
% timelag = timelag(33:49);
%     timelag = 0;
% timelag_select = timelag_plot(1:end);
% timelag_index = 1:length(timelag_select);

%% timelag label
% xtick_index = -1000 : 250 : 1000;
% label_select  = xtick_index(2:end);
label_select = 1 : round(length(timelag_plot)/8) :length(timelag_plot);
chn_label = {'Frontal';'Central';'Occipital'};
y_tick = 1 : 15 : 60;


%% initial


for chn_area_select = 1 : length(chn_area_labels)
    disp(chn_area_labels{chn_area_select});
    speaker_chn = eval(strcat('Small_area.',chn_area_labels{chn_area_select}));
    
    
    model_area_model_attend = zeros(listener_num,length(speaker_chn),length(timelag_plot),length(listener_chn));
    model_area_model_unattend = zeros(listener_num,length(speaker_chn),length(timelag_plot),length(listener_chn));
    
    model_attend_GFP = zeros(listener_num,length(timelag_plot));
    model_unattend_GFP  =  zeros(listener_num,length(timelag_plot));
    
    
    for band_select = 1 : length(band_name)
        disp(band_name{band_select});
        mkdir(band_name{band_select});
        cd(band_name{band_select});
        
        for chn_speaker = 1 : length(speaker_chn)
            chn_file_name = strcat(num2str(chn_speaker),'-',label66{speaker_chn(chn_speaker)});
            %         mkdir(chn_file_name);
            %         cd(chn_file_name);
            disp(chn_file_name);
            
            %% lambda index
            lambda_index = 10;
            
            for lambda_select  = 1 : length(lambda_index)
                file_name = strcat('lambda 2^',num2str(lambda_index(lambda_select)));
                disp(file_name);
                %             mkdir(file_name);
                %             cd(file_name);
                
                for i = 1 : listener_num
                    %                 disp(strcat('listener',num2str(i)));
                    
                    %% listener name
                    if i < 10
                        listener_file_name = strcat('listener10',num2str(i));
                    else
                        listener_file_name = strcat('listener1',num2str(i));
                    end
                    
                    %% load data
                    data_name = strcat('mTRF_speakerEEG_listenerEEG_forward_result+',label66{speaker_chn(chn_speaker)},'-',band_name{band_select},'.mat');
                    data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Forward model\SpeakerEEG-listenerEEG\-1s_1s\',band_name{band_select},'\',listener_file_name);
                    load(strcat(data_path,'\',data_name));
                    
                    
                    %% data
                    % attend
                    model_for_GFP_attend_temp = mean(squeeze(model_reshape_attend));
                    % unattend
                    model_for_GFP_unattend_temp = mean(squeeze(model_reshape_unattend));
                    
                    %% data merge
                    model_area_model_attend(i,chn_speaker,:,:) = model_for_GFP_attend_temp;
                    model_area_model_unattend(i,chn_speaker,:,:) = model_for_GFP_unattend_temp;
                    
                end
                
                
                
            end
            
            
        end
        
        %% calculate
        for i = 1 : listener_num
            
            for time_point = 1 : length(timelag_plot)
                % attend
                mean_attend_across_area = squeeze(mean(model_area_model_attend(i,:,time_point,:),2));
                %                 mean_attend_across_listener = squeeze(mean(mean_attend_across_area,1));
                model_attend_GFP(i,time_point) = sum(mean_attend_across_area.^2)/length(listener_chn);
                % unattend
                mean_unattend_across_area = squeeze(mean(model_area_model_unattend(i,:,time_point,:),2));
                %                 mean_unattend_across_listener = squeeze(mean(mean_unattend_across_area,1));
                model_unattend_GFP(i,time_point) = sum(mean_unattend_across_area.^2)/length(listener_chn);
            end
        end
        
        
        %% plot
        
        %         % attend
        set(gcf,'outerposition',get(0,'screensize'));
        %
        %         % attend
        subplot(121);
        plot(timelag_plot,squeeze(mean(model_attend_GFP)),'r','LineWidth',2);
        %         %         xlabel('timelag(ms)');
        %         ylabel('GFP');
        title('Attended and Unattend');
        %
        %         % unattend
        %         subplot(312);
        hold on;
        plot(timelag_plot,squeeze(mean(model_unattend_GFP)),'b','LineWidth',2);
        %         %         xlabel('timelag(ms)');
        %         ylabel('GFP');
        %         title('Unattended');
        %
        legend('Attended','Unattend');
        %         % Diff
        subplot(122);
        %         hold on;
        plot(timelag_plot,squeeze(mean(model_attend_GFP))-squeeze(mean(model_unattend_GFP)),'k','LineWidth',2);
        %         xlabel('timelag(ms)');
        %         ylabel('GFP');
        %         title('Unattended');
        title('Diff');
        
        
        
        save_name = strcat('mTRF SpeakerEEG-ListenerEEG-GFP-',band_name{band_select},'-',chn_area_labels{chn_area_select},'.jpg');
        suptitle(save_name(1:end-4));
        saveas(gcf,save_name);
        
        close;
        
        save_name = strcat('mTRF SpeakerEEG-ListenerEEG-GFP-',band_name{band_select},'-',chn_area_labels{chn_area_select},'.mat');
        save(save_name,'model_attend_GFP','model_unattend_GFP','model_area_model_attend','model_area_model_unattend');
        
        
        p = pwd;
        cd(p(1:end-(length(band_name{band_select})+1)));
    end
    
end