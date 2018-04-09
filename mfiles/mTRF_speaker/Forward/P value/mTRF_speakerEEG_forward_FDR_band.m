% mTRF_speakerEEG_plot_forward

band_name = {'delta','theta','alpha','beta','broadband','1_8Hz','narrow_theta'};
% band_name = {'narrow_theta'};

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select},' reverse');
    
    
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
    timelag_plot = -250:500/32:500;
    %     timelag = -250:(1000/Fs):500;
    % timelag = timelag(33:49);
    %     timelag = 0;
    timelag_select = timelag_plot(1:end);
    timelag_index = 1:length(timelag_select);
    
    %% lambda index
    lambda = 2 ^ 10;
    
    %% initial
    listener_num = 20;
    
    H_attend_count = zeros(length(timelag_plot),length(listener_chn));
    H_unattend_count = zeros(length(timelag_plot),length(listener_chn));
    
    H_attend_total = zeros(length(timelag_plot),length(listener_chn));
    H_unattend_total = zeros(length(timelag_plot),length(listener_chn));
    P_attend_total = zeros(length(speaker_chn),length(timelag_plot),length(listener_chn));
    P_unattend_total = zeros(length(speaker_chn),length(timelag_plot),length(listener_chn));
    
    model_attend_mean = zeros(listener_num,length(speaker_chn),length(timelag_plot),length(listener_chn));
    model_unattend_mean = zeros(listener_num,length(speaker_chn),length(timelag_plot),length(listener_chn));
    
    for i = 1 : 20
        
        %% listener name
        if i < 10
            file_name = strcat('listener10',num2str(i));
        else
            file_name = strcat('listener1',num2str(i));
        end
        
        for chn_speaker = 1 : length(speaker_chn)
            chn_file_name = strcat(num2str(chn_speaker),'-',label66{speaker_chn(chn_speaker)});
            disp(strcat(file_name,'-',chn_file_name));
            %% load plot data
            data_name =  strcat('mTRF_speakerEEG_listenerEEG_forward_result+',label66{speaker_chn(chn_speaker)},'-lambda',num2str(lambda),'.mat');
            data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Forward model\SpeakerEEG-listenerEEG\',band_name{band_select},' reverse zscore\',file_name);
            load(strcat(data_path,'\',data_name));
            
            %% record into matrix
            %             R_attend_mean(i,chn_speaker,:,:) = squeeze(mean(R_attend)); % listener * timelag * chn *time point
            %             R_unattend_mean(i,chn_speaker,:,:) = squeeze(mean(R_unattend));
            
            model_attend_mean(i,chn_speaker,:,:) = squeeze(mean(model_attend));
            model_unattend_mean(i,chn_speaker,:,:) = squeeze(mean(model_unattend));
            
        end
    end
    
    %% t-test
    for chn_speaker = 1 : length(speaker_chn)
        chn_file_name = strcat(num2str(chn_speaker),'-',label66{speaker_chn(chn_speaker)});
        %     mkdir(chn_file_name);
        %     cd(chn_file_name);
        %
        
        for chn_listener = 1 : length(listener_chn)
            %% ttest all listener
            for time_point = 1 : length(timelag_plot)
                
                [H_attend_total(chn_speaker,time_point,chn_listener),P_attend_total(chn_speaker,time_point,chn_listener)] =ttest(model_attend_mean(:,chn_speaker,time_point,chn_listener));
                [H_unattend_total(chn_speaker,time_point,chn_listener),P_unattend_total(chn_speaker,time_point,chn_listener)] =ttest(model_unattend_mean(:,chn_speaker,time_point,chn_listener));
                
            end
        end
    end
    
    %% calculating FDR
    [p_correct_attend, i_attend]= U_FDR(P_attend_total,0.05);
    [p_correct_unattend, i_unattend]= U_FDR(P_unattend_total,0.05);
    
    save_name = strcat('mTRF SpeakerEEG-listenerEEG FDR-',band_name{band_select},'.mat');
    save(save_name,'p_correct_attend','p_correct_unattend',...
        'i_attend','i_unattend',...
    'P_attend_total','P_unattend_total');
    
    
end
