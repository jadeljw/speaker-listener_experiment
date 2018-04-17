% mTRF_Audio_plot_forward
% 2018.3.26
% reserved from mTRF_speakerEEG_plot_foward

% reversed 2018.4.11

band_name = {'delta','theta','alpha','beta'};
% band_name = {'narrow_theta'};

%% lambda index 
lambda_index = 0 : 5 : 40;
lambda_select = find(lambda_index == 10);

for band_select = 1 : length(band_name)
    %     band_file_name = strcat(band_name{band_select},' reverse');
    band_file_name = strcat(band_name{band_select});
    
    %% initial
    load('E:\DataProcessing\chn_re_index.mat');
    chn_re_index = chn_re_index(1:64);
    
    listener_chn= [1:32 34:42 44:59 61:63];
    % speaker_chn = 63;
    % speaker_chn = [28 31 48 60];
    speaker_chn = [1:32 34:42 44:59 61:63];
    % speaker_chn = [17:21 26:30 36:40];
    % speaker_chn = [9:11 18:20 27:29];
    load('E:\DataProcessing\label66.mat');
    layout = 'E:\DataProcessing\easycapm1.mat';
    
    
    %% timelag
    Fs = 64;
    timelag_plot = -1000 :1000/Fs: 1000;
    %     timelag = -250:(1000/Fs):500;
    % timelag = timelag(33:49);
    %     timelag = 0;
    timelag_select = timelag_plot(1:end);
    timelag_index = 1:length(timelag_select);
    
    
    %% initial
    listener_num = 20;
    
    model_attend_mean = zeros(listener_num,length(timelag_select),length(listener_chn));
    model_unattend_mean = zeros(listener_num,length(timelag_select),length(listener_chn));
    
    for i = 1 : 20
        
        %% listener name
        if i < 10
            file_name = strcat('listener10',num2str(i));
        else
            file_name = strcat('listener1',num2str(i));
        end
        
        
        
        %% load plot data
        data_name =  strcat('mTRF_Audio_listenerEEG_forward_result_',band_name{band_select},'-',file_name,'.mat');
        data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Forward model\Audio-listenerEEG\-1s_1s\',band_file_name);
        load(strcat(data_path,'\',data_name));
        
        %% record into matrix
        %             R_attend_mean(i,chn_speaker,:,:) = squeeze(mean(R_attend)); % listener * timelag * chn *time point
        %             R_unattend_mean(i,chn_speaker,:,:) = squeeze(mean(R_unattend));
        
        model_attend_mean(i,:,:) = squeeze(mean(model_reshape_attend(:,lambda_select,:,timelag_index,:)));
        model_unattend_mean(i,:,:) = squeeze(mean(model_reshape_unattend(:,lambda_select,:,timelag_index,:)));
        
        
    end
    
    model_attend_GFP = zeros(length(timelag_select));
    model_unattend_GFP= zeros(length(timelag_select));
    
    %% calculating GFP
    disp('Calculating GFP...')
    
    for time_point = 1 : length(timelag_select)
        % attend
        temp_attend = squeeze(mean(model_attend_mean(:,time_point,:)));
        model_attend_GFP(time_point) = sum(temp_attend.^2)/length(listener_chn);
        % unattend
        temp_unattend = squeeze(mean(model_unattend_mean(:,time_point,:)));
        model_unattend_GFP(time_point) = sum(temp_unattend.^2)/length(listener_chn);
    end
    
    
    
    
    %% plot
    set(gcf,'outerposition',get(0,'screensize'));
    plot(timelag_select,model_attend_GFP(timelag_index)','LineWidth',2);
    %             ylim([0,1.2*1e-5]);
    hold on;
    plot(timelag_select,model_unattend_GFP(timelag_index)','LineWidth',2);
    %             legend('attend','unattend');
    ylim([0,max(max([model_attend_GFP model_unattend_GFP]))]);
    %     title(label66{listener_chn(chn_speaker)});
    %         close;
    
    save_name = strcat('mTRF Audio-listenerEEG GFP-',band_name{band_select},'.jpg');
    legend('attend','unattend');
    title(save_name(1:end-4));
    saveas(gcf,save_name);
    close
    
    save_name = strcat('mTRF Audio-listenerEEG GFP-',band_name{band_select},'.mat');
    save(save_name,'model_attend_mean','model_unattend_mean',...
        'model_attend_GFP','model_unattend_GFP');
    
end

