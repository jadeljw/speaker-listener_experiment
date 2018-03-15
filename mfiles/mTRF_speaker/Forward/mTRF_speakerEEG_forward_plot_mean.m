% mTRF_speakerEEG_plot_forward

mkdir('delta reverse');
cd('delta reverse');
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
timelag = -250:500/32:500;
timelag_gap = timelag(2)-timelag(1);
timelag_interval = 9;
timelag_length = timelag_gap * timelag_interval;
timelag = timelag(1:timelag_interval:end);
%     timelag = -250:(1000/Fs):500;
% timelag = timelag(33:49);
%     timelag = 0;

%% lambda index
lambda_index = 5:5:15;

%% initial
listener_num = 20;
lambda_num = 3;

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
    
    for chn_speaker = 1 : length(speaker_chn)
        chn_file_name = strcat(num2str(chn_speaker),'-',label66{speaker_chn(chn_speaker)});
        
        for j = 1 : length(timelag)
            
            disp(strcat(file_name,'-',chn_file_name,'-timelag',num2str(timelag(j)),'ms'));
            %% load plot data
            data_name =  strcat('mTRF_speakerEEG_listenerEEG_forward_result+',label66{speaker_chn(chn_speaker)},'-timelag',num2str(timelag(j)),'ms.mat');
            data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Forward model\broadband reverse\',file_name,'\',chn_file_name);
            load(strcat(data_path,'\',data_name));
            
            %% record into matrix
            R_attend_mean(i,j,chn_speaker,:,:) = squeeze(mean(R_attend)); % listener * timelag * chn *time point
            R_unattend_mean(i,j,chn_speaker,:,:) = squeeze(mean(R_unattend));
            MSE_attend_mean(i,j,chn_speaker,:,:) = squeeze(mean(MSE_attend));
            MSE_unattend_mean(i,j,chn_speaker,:,:) = squeeze(mean(MSE_unattend));
            P_attend_mean(i,j,chn_speaker,:,:) = squeeze(mean(P_attend));
            P_unattend_mean(i,j,chn_speaker,:,:) = squeeze(mean(P_unattend));
            model_attend_mean(i,j,chn_speaker,:,:,:) = squeeze(mean(model_attend));
            model_unattend_mean(i,j,chn_speaker,:,:,:) = squeeze(mean(model_unattend));
        end
        
    end
    
end


%% plot
for chn_speaker = 1 : length(speaker_chn)
    chn_file_name = strcat(num2str(chn_speaker),'-',label66{speaker_chn(chn_speaker)});
    mkdir(chn_file_name);
    cd(chn_file_name);
    
    for j = 1 : length(timelag)
        for chn_listener = 1 : length(listener_chn)
            
            %% plot
            
            set(gcf,'outerposition',get(0,'screensize'));
            
            % R
            subplot(221);
            R_attend_for_plot = squeeze(mean(R_attend_mean(:,j,chn_speaker,:,chn_listener),1));
            R_unattend_for_plot = squeeze(mean(R_unattend_mean(:,j,chn_speaker,:,chn_listener),1));
            plot(lambda_index,R_attend_for_plot,'LineWidth',2);
            hold on;plot(lambda_index,R_unattend_for_plot,'LineWidth',2);
            title('R value');xlabel('lambda 2^');ylabel('r');
            %             ylim([-0.03 0.03]);
            legend('Attended','Unattended');
            
            % MSE
            subplot(222);
            MSE_attend_for_plot = squeeze(mean(MSE_attend_mean(:,j,chn_speaker,:,chn_listener),1));
            MSE_unattend_for_plot = squeeze(mean(MSE_unattend_mean(:,j,chn_speaker,:,chn_listener),1));
            plot(lambda_index,MSE_attend_for_plot,'LineWidth',2);
            hold on;plot(lambda_index,MSE_unattend_for_plot,'LineWidth',2);
            title('MSE');xlabel('lambda 2^');ylabel('MSE');
            legend('Attended','Unattended');
            
            % P
            subplot(223);
            P_attend_for_plot = squeeze(mean(P_attend_mean(:,j,chn_speaker,:,chn_listener),1));
            P_unattend_for_plot = squeeze(mean(P_unattend_mean(:,j,chn_speaker,:,chn_listener),1));
            plot(lambda_index,P_attend_for_plot,'LineWidth',2);
            hold on;plot(lambda_index,P_unattend_for_plot,'LineWidth',2);
            title('P value');xlabel('lambda 2^');ylabel('P');
            legend('Attended','Unattended');
            
            % model
            subplot(224);
            model_attend_for_plot = squeeze(squeeze(mean(model_attend_mean(:,j,chn_speaker,:,:,chn_listener),1)));
            model_unattend_for_plot = squeeze(squeeze(mean(model_unattend_mean(:,j,chn_speaker,:,:,chn_listener),1)));
            timelag_plot = 0:timelag_gap:timelag_length+timelag_gap;
            timelag_plot = timelag_plot + timelag(j);
            plot(timelag_plot,model_attend_for_plot,'LineWidth',2,'color',[0.2 0.2 0.2]);
            hold on;plot(timelag_plot,model_unattend_for_plot,'--','color',[0.5 0.5 0.5],'LineWidth',2);
            title('TRF');xlabel('timelag(ms)');ylabel('a.u.');
            legend('A5','A10','A15','U5','U10','U15');
            
            
            save_name = strcat('mTRF SpeakerEEG forward result timelag',num2str(timelag(j)-150),'ms-',label66{listener_chn(chn_listener)},'.jpg');
            suptitle(save_name(1:end-4));
            saveas(gcf,save_name);
            
            close;
            
        end
    end
    
    p = pwd;
    cd(p(1:end-(length(chn_file_name)+1)));
end


%% topoplot
lambda_num = 2;
mkdir()
for chn_speaker = 1 : length(speaker_chn)
    chn_file_name = strcat(num2str(chn_speaker),'-',label66{speaker_chn(chn_speaker)});
    mkdir(chn_file_name);
    cd(chn_file_name);
    
    for j = 1 : length(timelag)
        R_attend_for_topoplot = zeros(1,length(listener_chn));
        R_unattend_for_topoplot = zeros(1,length(listener_chn));
        P_attend_for_topoplot = zeros(1,length(listener_chn));
        P_unattend_for_topoplot = zeros(1,length(listener_chn));
        
        for chn_listener = 1 : length(listener_chn)
            
            %% plot
            % R
            R_attend_for_topoplot(chn_listener) = squeeze(mean(R_attend_mean(:,j,chn_speaker,lambda_num,chn_listener),1));
            R_unattend_for_topoplot(chn_listener) = squeeze(mean(R_unattend_mean(:,j,chn_speaker,lambda_num,chn_listener),1));
            
            
            % P
            P_attend_for_plot(chn_listener) = squeeze(mean(P_attend_mean(:,j,chn_speaker,lambda_num,chn_listener),1));
            P_unattend_for_plot(chn_listener) = squeeze(mean(P_unattend_mean(:,j,chn_speaker,lambda_num,chn_listener),1));

            
        end
        
        save_name = strcat('mTRF SpeakerEEG forward Topoplot timelag',num2str(timelag(j)-150),'ms-',label66{listener_chn(chn_listener)},'.jpg');
        suptitle(save_name(1:end-4));
        saveas(gcf,save_name);
        
        close;
    end
    
    p = pwd;
    cd(p(1:end-(length(chn_file_name)+1)));
end