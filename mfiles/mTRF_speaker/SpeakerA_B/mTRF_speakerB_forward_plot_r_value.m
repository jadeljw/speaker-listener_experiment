% mTRF_SpeakerB_forward_plot_r_value

% reversed 2018.4.9
% author: LJW
% purpose: to plot mTRF crossval r value for SpeakerB
mkdir('SpeakerB');
cd('SpeakerB');

band_name = {'delta','theta','alpha','beta'};
% band_name = {'narrow_theta'};

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
timelag_plot = -1000: 1000/Fs: 1000;
%     timelag = -250:(1000/Fs):500;
% timelag = timelag(33:49);
%     timelag = 0;
timelag_select = timelag_plot(1:end);
timelag_index = 1:length(timelag_select);

%% lambda index
lambda_index = 0 : 5 : 40;
for lambda_select  = find(lambda_index == 10)
    file_name = strcat('lambda 2^',num2str(lambda_index(lambda_select)));
    disp(file_name);
    mkdir(file_name);
    cd(file_name);
    
    for band_select = 1 : length(band_name)
        %% initial
        r_topoplot = zeros(length(listener_chn),1);
        MSE_topoplot = zeros(length(listener_chn),1);
        p_topoplot = zeros(length(listener_chn),1);
        
        %% load data
        load(strcat('E:\DataProcessing\speaker-listener_experiment\Forward model\Audio-speakerEEG\-1s-1s\SpeakerB\mTRF_sound_SpeakerB_EEG_forward_result_',band_name{band_select},'.mat'));
        
        
        %% calculate
        for chn = 1 : length(listener_chn)
            r_topoplot(chn) = mean(R(:,lambda_select,chn),1);
            MSE_topoplot(chn) = mean(MSE(:,lambda_select,chn),1);
            p_topoplot(chn) = mean(P(:,lambda_select,chn),1);
        end
        
        
        %% plot
        set(gcf,'outerposition',get(0,'screensize'));
        
        
        % R
        %         subplot(121);
        U_topoplot(r_topoplot,layout,label66(listener_chn));colorbar('location','SouthOutside');
        title('R value');
        
        % MSE
        %         subplot(122);
        %         U_topoplot(MSE_topoplot,layout,label66(listener_chn));colorbar('location','South');
        %         title('MSE');
        %
        %         % P
        %         subplot(133);
        %         U_topoplot(-log10(p_topoplot),layout,label66(listener_chn));colorbar('location','South');
        %         title('-log10(p) value');
        
        save_name = strcat('mTRF Audio-SpeakerEEG-',band_name{band_select},'-lambda 2^',num2str(lambda_index(lambda_select)),'.jpg');
        %         suptitle(save_name(1:end-4));
        title(save_name(1:end-4));
        saveas(gcf,save_name);
        
        close;
        
    end
    
    p = pwd;
    cd(p(1:end-(length(file_name)+1)));
end
