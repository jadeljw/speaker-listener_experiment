% mTRF_speakerEEG_plot_forward

band_name = {'delta','theta','alpha','beta','broadband','1_8Hz','narrow_theta'};
% band_name = {'narrow_theta'};

for band_select = 1 : length(band_name)
    %% load data
    
    load(strcat('E:\DataProcessing\speaker-listener_experiment\Forward model\FDR\mTRF SpeakerEEG-listenerEEG FDR-',band_name{band_select},'.mat'));
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
    
    P_attend_mat = zeros(length(speaker_chn),length(listener_chn));
    P_unattend_mat= zeros(length(speaker_chn),length(listener_chn));
    
    %% find earliest significant channel
    for chn_speaker = 1 : length(speaker_chn)
        disp(strcat('Speaker chn No.',num2str(chn_speaker)));
        for chn_listener = 1 : length(listener_chn)
            disp(strcat('Listener chn No.',num2str(chn_listener)));
            temp_index_attend = find(P_attend_total(chn_speaker,:,chn_listener)<0.05);
            temp_index_unattend = find(P_unattend_total(chn_speaker,:,chn_listener)<0.05);
            
            % attend
            if temp_index_attend ~= 0
                P_attend_mat(chn_speaker,chn_listener) = temp_index_attend(1);
            else
                P_attend_mat(chn_speaker,chn_listener) = -50;
            end
            
            % unattend
            if temp_index_unattend ~= 0
                P_unattend_mat(chn_speaker,chn_listener) = temp_index_unattend(1);
            else
                P_unattend_mat(chn_speaker,chn_listener) = -50;
            end
        end
        
    end
    
    
    %% plot
    set(gcf,'outerposition',get(0,'screensize'));
    
    % attend
    subplot(121);
    imagesc(round(P_attend_mat./10));colorbar;colormap('jet');
    title('Attend');xlabel('Speaker Channel');ylabel('Listener Channel');
    %             ylim([-0.03 0.03]);
%     xticklabels(round(timelag_plot(5:5:end)));
    
    
    % unattend
    subplot(122);
    imagesc(round(P_unattend_mat./10));colorbar;colormap('jet');
    %     caxis([-5*1e-3, 5*1e-3]);
    title('Unattend');xlabel('Speaker Channel');ylabel('Listener Channel');
    %             ylim([-0.03 0.03]);
    %     xticklabels(round(timelag_plot(5:5:end)));
    
    save_name = strcat('mTRF SpeakerEEG forward earliest timelag-',band_name{band_select},'.jpg');
    suptitle(save_name(1:end-4));
    saveas(gcf,save_name);
    
    %% save data
    save_name = strcat('mTRF SpeakerEEG-listenerEEG p value-',band_name{band_select},'.mat');
    save(save_name,'P_attend_mat','P_unattend_mat');
    
    
end
