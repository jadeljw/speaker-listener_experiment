% mTRF_Audio_plot_forward
% 2018.3.26
% reserved from mTRF_speakerEEG_plot_foward

%% band name
band_name = {'delta','theta','alpha','beta'};
% band_name = {'narrow_theta'};


%% lambda index
lambda_index = 0:5:40;
lambda_select = find(lambda_index ==10);

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
    %     timelag_plot = -250:500/32:500;
    timelag_plot = -1000 :1000/Fs:1000;
    %     timelag = -250:(1000/Fs):500;
    % timelag = timelag(33:49);
    %     timelag = 0;
    timelag_select = timelag_plot(1:end);
    timelag_index = 1:length(timelag_select);
    
    
    
    
    %% load plot SpeakerA data
    %     data_name =  strcat('mTRF_sound_SpeakerB_EEG_forward_result_',band_name{band_select},'-lambda1024.mat');
    data_name = strcat('mTRF_sound_SpeakerA_EEG_forward_result_',band_name{band_select});
    data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Forward model\Audio-speakerEEG\-1s-1s\SpeakerA');
    load(strcat(data_path,'\',data_name));
    
    model_attend_mean_speakerA = squeeze(model_reshape(:,lambda_select,:,timelag_index,:));
    model_attend_GFP_speakerA = zeros(length(timelag_select));
    
    %% load plot SpeakerB data
    %     data_name =  strcat('mTRF_sound_SpeakerB_EEG_forward_result_',band_name{band_select},'-lambda1024.mat');
    data_name = strcat('mTRF_sound_SpeakerB_EEG_forward_result_',band_name{band_select});
    data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Forward model\Audio-speakerEEG\-1s-1s\SpeakerB');
    load(strcat(data_path,'\',data_name));
    
    model_attend_mean_speakerB = squeeze(model_reshape(:,lambda_select,:,timelag_index,:));
    model_attend_GFP_speakerB = zeros(length(timelag_select));
    %     model_unattend_GFP= zeros(length(timelag_select));
    
    %% calculating GFP
    disp('Calculating GFP...')
    
    for time_point = 1 : length(timelag_select)
        
        temp_speakerA = squeeze(mean(model_attend_mean_speakerA(:,time_point,:)));
        model_attend_GFP_speakerA(time_point) = sum(temp_speakerA.^2)/length(listener_chn);
        % attend
        temp_speakerB = squeeze(mean(model_attend_mean_speakerB(:,time_point,:)));
        model_attend_GFP_speakerB(time_point) = sum(temp_speakerB.^2)/length(listener_chn);
    end
    
    %% plot
    set(gcf,'outerposition',get(0,'screensize'));
    plot(timelag_select,model_attend_GFP_speakerA(timelag_index)','LineWidth',2);
    hold on;plot(timelag_select,model_attend_GFP_speakerB(timelag_index)','LineWidth',2);
    %             ylim([0,1.2*1e-5]);
    %     hold on;
    %     plot(timelag_select,model_unattend_GFP(timelag_index)','LineWidth',2);
    legend('SpeakerA','SpeakerB');
    ylim([0,max(max([model_attend_GFP_speakerB;model_attend_GFP_speakerA]))]);
    %     title(label66{listener_chn(chn_speaker)});
    %         close;
    
    save_name = strcat('mTRF Audio-Speaker GFP-',band_name{band_select},'.jpg');
    title(save_name(1:end-4));
    saveas(gcf,save_name);
    close
    
    save_name = strcat('mTRF Audio-Speaker GFP-',band_name{band_select},'.mat');
    save(save_name,'model_attend_mean_speakerA','model_attend_mean_speakerB',...
        'model_attend_GFP_speakerA','model_attend_mean_speakerB');
    
end
