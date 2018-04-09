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
    
    P_attend_index = zeros(length(speaker_chn),length(listener_chn));
    P_unattend_index= zeros(length(speaker_chn),length(listener_chn));
    P_attend_value = zeros(length(speaker_chn),length(listener_chn));
    P_unattend_value = zeros(length(speaker_chn),length(listener_chn));
    
    %% find earliest significant channel
    for chn_speaker = 1 : length(speaker_chn)
        disp(strcat('Speaker chn No.',num2str(chn_speaker)));
        for chn_listener = 1 : length(listener_chn)
            disp(strcat('Listener chn No.',num2str(chn_listener)));
            %             temp_index_attend = find(P_attend_total(chn_speaker,:,chn_listener)<0.05);
            %             temp_index_unattend = find(P_unattend_total(chn_speaker,:,chn_listener)<0.05);
            
            % attend
            [P_attend_value(chn_speaker,chn_listener),P_attend_index(chn_speaker,chn_listener)] = min(P_attend_total(chn_speaker,:,chn_listener));      
            % unattend
            [P_unattend_value(chn_speaker,chn_listener),P_unattend_index(chn_speaker,chn_listener)] = min(P_unattend_total(chn_speaker,:,chn_listener));
        end
        
    end
    
    
    %% plot
    set(gcf,'outerposition',get(0,'screensize'));
    
    % attend p value
    subplot(221);
    imagesc(round(P_attend_index./10));colorbar;colormap('jet');
    title('Attend index');ylabel('Speaker Channel');xlabel('Listener Channel');
    %             ylim([-0.03 0.03]);
    %     xticklabels(round(timelag_plot(5:5:end)));
    
    
    % unattend p value
    subplot(222);
    imagesc(round(P_unattend_index./10));colorbar;
%     colormap('jet');
%         caxis([-5*1e-3, 5*1e-3]);
    title('Unattend index');ylabel('Speaker Channel');xlabel('Listener Channel');
    %             ylim([-0.03 0.03]);
    %     xticklabels(round(timelag_plot(5:5:end)));
    
    
    % attend timelag
    subplot(223);
    imagesc(-log10(P_attend_value));colorbar;
%     colormap('jet');
    caxis([0, 3]);
    title('Attend -log(p) value');ylabel('Speaker Channel');xlabel('Listener Channel');
    %             ylim([-0.03 0.03]);
    %     xticklabels(round(timelag_plot(5:5:end)));
    
    
    % unattend timelag
    subplot(224);
    imagesc(-log10(P_unattend_value));colorbar;
%     colormap('jet');
    caxis([0, 3]);
    %     caxis([-5*1e-3, 5*1e-3]);
    title('Unattend -log(p) value');ylabel('Speaker Channel');xlabel('Listener Channel');
    %             ylim([-0.03 0.03]);
    %     xticklabels(round(timelag_plot(5:5:end)));
    
    save_name = strcat('mTRF SpeakerEEG forward min p value-',band_name{band_select},'.jpg');
    suptitle(save_name(1:end-4));
    saveas(gcf,save_name);
    
    close;
    
    %% save data
    save_name = strcat('mTRF SpeakerEEG-listenerEEG min p value-',band_name{band_select},'.mat');
    save(save_name,'P_attend_index','P_unattend_index',...
       'P_attend_value','P_unattend_value');
    
    
end
