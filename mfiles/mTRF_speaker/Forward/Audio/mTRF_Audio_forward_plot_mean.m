% mTRF_speakerEEG_plot_forward

mkdir('Audio theta reverse');
cd('Audio theta reverse');
%% initial
load('E:\DataProcessing\chn_re_index.mat');
chn_re_index = chn_re_index(1:64);

listener_chn= [1:32 34:42 44:59 61:63];
% speaker_chn = 63;
% speaker_chn = [28 31 48 60];
speaker_chn = 1;
% speaker_chn = [17:21 26:30 36:40];
% speaker_chn = [9:11 18:20 27:29];
load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';


%% timelag
Fs = 64;
timelag = -250:500/32:500;
timelag_gap = timelag(2)-timelag(1);
timelag_interval = 9;
timelag_length = timelag_gap * timelag_interval;
timelag = timelag(1:timelag_interval:end);
%     timelag = -250:(1000/Fs):500;
% timelag = timelag(33:49);
%     timelag = 0;

%% lambda index
lambda_index = 0:5:20;

%% initial
listener_num = 20;
lambda_num = 5;

R_attend_mean = zeros(listener_num,length(timelag),length(speaker_chn),lambda_num,length(listener_chn));
R_unattend_mean = zeros(listener_num,length(timelag),length(speaker_chn),lambda_num,length(listener_chn));
MSE_attend_mean = zeros(listener_num,length(timelag),length(speaker_chn),lambda_num,length(listener_chn));
MSE_unattend_mean = zeros(listener_num,length(timelag),length(speaker_chn),lambda_num,length(listener_chn));
P_attend_mean = zeros(listener_num,length(timelag),length(speaker_chn),lambda_num,length(listener_chn));
P_unattend_mean = zeros(listener_num,length(timelag),length(speaker_chn),lambda_num,length(listener_chn));
model_attend_mean = zeros(listener_num,length(timelag),length(speaker_chn),lambda_num,timelag_interval+2,length(listener_chn));
model_unattend_mean = zeros(listener_num,length(timelag),length(speaker_chn),lambda_num,timelag_interval+2,length(listener_chn));

for i = 1 : 20
    
    %% listener name
    if i < 10
        file_name = strcat('listener10',num2str(i));
    else
        file_name = strcat('listener1',num2str(i));
    end
    
    for j = 1 : length(timelag)
        
        disp(strcat(file_name,'-timelag',num2str(timelag(j)),'ms'));
        %% load plot data
        data_name =  strcat('mTRF_Audio_listenerEEG_forward_result-timelag',num2str(timelag(j)),'ms.mat');
        data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Forward model\Audio-listenerEEG\theta reverse zscore\',file_name);
        load(strcat(data_path,'\',data_name));
        
        %% record into matrix
        R_attend_mean(i,j,1,:,:) = squeeze(mean(R_attend)); % listener * timelag * chn *time point
        R_unattend_mean(i,j,1,:,:) = squeeze(mean(R_unattend));
        MSE_attend_mean(i,j,1,:,:) = squeeze(mean(MSE_attend));
        MSE_unattend_mean(i,j,1,:,:) = squeeze(mean(MSE_unattend));
        P_attend_mean(i,j,1,:,:) = squeeze(mean(P_attend));
        P_unattend_mean(i,j,1,:,:) = squeeze(mean(P_unattend));
        model_attend_mean(i,j,1,:,:,:) = squeeze(mean(model_attend));
        model_unattend_mean(i,j,1,:,:,:) = squeeze(mean(model_unattend));
    end
    
    
    
end


%% plot
for j = 1 : length(timelag)
    timelag_name = strcat('timelag',num2str(timelag(j)),'ms');
    disp(timelag_name);
    mkdir(timelag_name);
    cd(timelag_name);
    
    
    for chn_listener = 1 : length(listener_chn)
        
        %% plot
        
        set(gcf,'outerposition',get(0,'screensize'));
        
        % R
        subplot(221);
        R_attend_for_plot = squeeze(mean(R_attend_mean(:,j,1,:,chn_listener),1));
        R_unattend_for_plot = squeeze(mean(R_unattend_mean(:,j,1,:,chn_listener),1));
        plot(lambda_index,R_attend_for_plot,'LineWidth',2);
        hold on;plot(lambda_index,R_unattend_for_plot,'LineWidth',2);
        title('R value');xlabel('lambda 2^');ylabel('r');
        %             ylim([-0.03 0.03]);
        legend('Attended','Unattended');
        
        % MSE
        subplot(222);
        MSE_attend_for_plot = squeeze(mean(MSE_attend_mean(:,j,1,:,chn_listener),1));
        MSE_unattend_for_plot = squeeze(mean(MSE_unattend_mean(:,j,1,:,chn_listener),1));
        plot(lambda_index,MSE_attend_for_plot,'LineWidth',2);
        hold on;plot(lambda_index,MSE_unattend_for_plot,'LineWidth',2);
        title('MSE');xlabel('lambda 2^');ylabel('MSE');
        legend('Attended','Unattended');
        
        % P
        subplot(223);
        P_attend_for_plot = squeeze(mean(P_attend_mean(:,j,1,:,chn_listener),1));
        P_unattend_for_plot = squeeze(mean(P_unattend_mean(:,j,1,:,chn_listener),1));
        plot(lambda_index,P_attend_for_plot,'LineWidth',2);
        hold on;plot(lambda_index,P_unattend_for_plot,'LineWidth',2);
        title('P value');xlabel('lambda 2^');ylabel('P');
        legend('Attended','Unattended');
        
        % model
        subplot(224);
        model_attend_for_plot = squeeze(squeeze(mean(model_attend_mean(:,j,1,:,:,chn_listener),1)));
        model_unattend_for_plot = squeeze(squeeze(mean(model_unattend_mean(:,j,1,:,:,chn_listener),1)));
        timelag_plot = 0:timelag_gap:timelag_length+timelag_gap;
        timelag_plot = timelag_plot + timelag(j);
        plot(timelag_plot,model_attend_for_plot,'LineWidth',2,'color',[0.2 0.2 0.2]);
        hold on;plot(timelag_plot,model_unattend_for_plot,'--','color',[0.5 0.5 0.5],'LineWidth',2);
        title('TRF');xlabel('timelag(ms)');ylabel('a.u.');
        %             legend('A5','A10','A15','U5','U10','U15');
        
        
        save_name = strcat('mTRF Audio forward result timelag',num2str(timelag(j)),'ms-',label66{listener_chn(chn_listener)},'.jpg');
        suptitle(save_name(1:end-4));
        saveas(gcf,save_name);
        
        close;
        
    end
    
        
    p = pwd;
    cd(p(1:end-(length(timelag_name)+1)));
end



