% mTRF GFP ttest

band_name = {'delta','theta','alpha','beta','broadband','1_8Hz','narrow_theta'};

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
story_num = 28;

p_attend_GFP = zeros(length(speaker_chn),length(timelag_select));
p_unattend_GFP = zeros(length(speaker_chn),length(timelag_select));

h_attend_GFP = zeros(length(speaker_chn),length(timelag_select));
h_unattend_GFP = zeros(length(speaker_chn),length(timelag_select));

for band_select = 1 : length(band_name)
    
    %% load data
    load(strcat('E:\DataProcessing\speaker-listener_experiment\Forward model\GFP\speakerEEG-listenerEEG\total\mTRF SpeakerEEG-listenerEEG GFP-',band_name{band_select},'-total.mat'));
    
    %% ttest
    for chn_speaker = 1 : length(speaker_chn)
        for time_point = 1 : length(timelag_select)
            [h_attend_GFP(chn_speaker,time_point), p_attend_GFP(chn_speaker,time_point)] = ttest(model_attend_GFP_total(:,chn_speaker,time_point));
            [h_unattend_GFP(chn_speaker,time_point), p_unattend_GFP(chn_speaker,time_point)] = ttest(model_unattend_GFP_total(:,chn_speaker,time_point));
        end
    end
    
    %% plot
     %% plot
    set(gcf,'outerposition',get(0,'screensize'));
    
    % attend p value
    subplot(121);
    imagesc(-log10(p_attend_GFP));colorbar;colormap('jet'); 
%     caxis([0, 2]);
    title('Attend -log10(p)');ylabel('Speaker Channel');xlabel('timelag(ms)');
    %             ylim([-0.03 0.03]);
        xticklabels(round(timelag_plot(5:5:end)));
    
    
    % unattend p value
    subplot(122);
    imagesc(-log10(p_unattend_GFP));colorbar;
%     colormap('jet');
%         caxis([0, 2]);
    title('Unattend -log10(p)');ylabel('Speaker Channel');xlabel('timelag(ms)');
    %             ylim([-0.03 0.03]);
        xticklabels(round(timelag_plot(5:5:end)));
    
    
    save_name = strcat('mTRF SpeakerEEG forward GFP ttest-',band_name{band_select},'.jpg');
    suptitle(save_name(1:end-4));
    saveas(gcf,save_name);
    
    close;
    
    %% save data
    save_name = strcat('mTRF SpeakerEEG-listenerEEG GFP ttest-',band_name{band_select},'.mat');
    save(save_name,'p_attend_GFP','p_unattend_GFP',...
       'h_attend_GFP','h_unattend_GFP');
end