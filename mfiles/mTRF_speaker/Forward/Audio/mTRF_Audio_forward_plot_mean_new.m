% mTRF_speakerEEG_plot_forward

mkdir('Audio ListenerEEG');
cd('Audio ListenerEEG');


%% band name
band_name = {'delta','theta','alpha','beta'};

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

%% lambda index
lambda = 2^10;

%% initial
listener_num = 20;

H_attend_count = zeros(length(timelag_plot),length(listener_chn));
H_unattend_count = zeros(length(timelag_plot),length(listener_chn));

H_attend_total = zeros(length(timelag_plot),length(listener_chn));
H_unattend_total = zeros(length(timelag_plot),length(listener_chn));
P_attend_total = zeros(length(timelag_plot),length(listener_chn));
P_unattend_total = zeros(length(timelag_plot),length(listener_chn));

model_attend_mean = zeros(listener_num,length(band_name),length(timelag_plot),length(listener_chn));
model_unattend_mean = zeros(listener_num,length(band_name),length(timelag_plot),length(listener_chn));

for i = 1 : 20
    
    %% listener name
    if i < 10
        file_name = strcat('listener10',num2str(i));
    else
        file_name = strcat('listener1',num2str(i));
    end
    
    for band_select = 1 : length(band_name)
        
        %% load plot data
        data_name =  strcat('mTRF_Audio_listenerEEG_forward_result-',band_name{band_select},'.mat');
        data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Forward model\Audio-listenerEEG\',file_name);
        load(strcat(data_path,'\',data_name));
        
        %% record into matrix
        %             R_attend_mean(i,chn_speaker,:,:) = squeeze(mean(R_attend)); % listener * timelag * chn *time point
        %             R_unattend_mean(i,chn_speaker,:,:) = squeeze(mean(R_unattend));
        
        model_attend_mean(i,band_select,:,:) = squeeze(mean(model_attend));
        model_unattend_mean(i,band_select,:,:) = squeeze(mean(model_unattend));
        
    end
    H_attend_count = H_attend_count+h_attend;
    H_unattend_count = H_unattend_count+h_unattend;
end


%% plot
for band_select = 1 : length(band_name)
    
    disp(band_name{band_select});
    
    for chn_listener = 1 : length(listener_chn)
        %% ttest all listener
        for time_point = 1 : length(timelag_plot)
            
            [H_attend_total(time_point,chn_listener),P_attend_total(time_point,chn_listener)] =ttest(model_attend_mean(:,band_select,time_point,chn_listener));
            [H_unattend_total(time_point,chn_listener),P_unattend_total(time_point,chn_listener)] =ttest(model_unattend_mean(:,band_select,time_point,chn_listener));
            
        end
    end
    %% plot
    
    set(gcf,'outerposition',get(0,'screensize'));
    
    % TRF curve attend
    subplot(221);
    imagesc(squeeze(mean(model_attend_mean(:,band_select,:,:)))');colorbar;caxis([-5*1e-3, 5*1e-3]);colormap('jet');
    title('TRF attend');ylabel('channel');xlabel('timelag(ms)');
    %             ylim([-0.03 0.03]);
    xticklabels(round(timelag_plot(5:5:end)));
    
    
    % TRF curve unattend
    subplot(222);
    imagesc(squeeze(mean(model_unattend_mean(:,band_select,:,:)))');colorbar;caxis([-5*1e-3, 5*1e-3]);colormap('jet');
    title('TRF unattend');ylabel('channel');xlabel('timelag(ms)');
    %             ylim([-0.03 0.03]);
    xticklabels(round(timelag_plot(5:5:end)));
    %
    
    %     % H attend count
    %     subplot(221);
    %     imagesc(H_attend_count');colorbar;colormap('jet');
    %     title('Across Story Attend Sig. Channel Count');ylabel('channel');xlabel('timelag(ms)');
    %     %             ylim([-0.03 0.03]);
    %     xticklabels(round(timelag_plot(5:5:end)));
    %
    %
    %     % H unattend count
    %     subplot(222);
    %     imagesc(H_unattend_count');colorbar;colormap('jet');
    %     title('Across Story Unattend Sig. Channel Count');ylabel('channel');xlabel('timelag(ms)');
    %     %             ylim([-0.03 0.03]);
    %     xticklabels(round(timelag_plot(5:5:end)));
    
    
    %         % H attend total
    %         subplot(323);
    %         imagesc(H_attend_total');colorbar;
    %         title('Across Listener Attend Sig. Channel');ylabel('channel');xlabel('timelag(ms)');
    %         %             ylim([-0.03 0.03]);
    %         xticklabels(round(timelag_plot(5:5:end)));
    %
    %
    %         % H unattend total
    %         subplot(324);
    %         imagesc(H_attend_total');colorbar;
    %         title('Across Listener Unattend Sig. Channel');ylabel('channel');xlabel('timelag(ms)');
    %         %             ylim([-0.03 0.03]);
    %         xticklabels(round(timelag_plot(5:5:end)));
    
    % P attend total
    subplot(223);
    imagesc(-log10(P_attend_total'));colorbar;caxis([0, 5]);colormap('jet');
    title('Across Listener Attend -log10(p)');ylabel('channel');xlabel('timelag(ms)');
    %             ylim([-0.03 0.03]);
    xticklabels(round(timelag_plot(5:5:end)));
    
    
    % P unattend total
    subplot(224);
    imagesc(-log10(P_unattend_total'));colorbar;caxis([0, 5]);colormap('jet');
    title('Across Listener Unattend p -log10(p)');ylabel('channel');xlabel('timelag(ms)');
    %             ylim([-0.03 0.03]);
    xticklabels(round(timelag_plot(5:5:end)));
    
    
    save_name = strcat('mTRF SpeakerEEG forward result-',band_name{band_select},'.jpg');
    suptitle(save_name(1:end-4));
    saveas(gcf,save_name);
    
    
    save_name_data = strcat('mTRF SpeakerEEG forward result-',band_name{band_select},'.mat');
    save(save_name_data,'H_attend_count','H_unattend_count',...
        'H_attend_total','H_unattend_total',...
        'P_attend_total','P_unattend_total');
    
    close;
    
    
    %     p = pwd;
    %     cd(p(1:end-(length(chn_file_name)+1)));
end

