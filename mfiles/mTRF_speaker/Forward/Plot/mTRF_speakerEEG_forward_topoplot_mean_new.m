% mTRF_speakerEEG_plot_forward

mkdir('beta reverse');
cd('beta reverse');
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
lambda = 2 ^ 10;

%% initial
listener_num = 20;

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
        data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Forward model\SpeakerEEG-listenerEEG\beta reverse zscore\',file_name);
        load(strcat(data_path,'\',data_name));
        
        %% record into matrix
        %             R_attend_mean(i,chn_speaker,:,:) = squeeze(mean(R_attend)); % listener * timelag * chn *time point
        %             R_unattend_mean(i,chn_speaker,:,:) = squeeze(mean(R_unattend));
        
        model_attend_mean(i,chn_speaker,:,:) = squeeze(mean(model_attend));
        model_unattend_mean(i,chn_speaker,:,:) = squeeze(mean(model_unattend));
        
    end
end


%% plot
for time_point = 1 : length(timelag_plot)
    mkdir(strcat(num2str(timelag_plot(time_point),'ms')));
    cd(strcat(num2str(timelag_plot(time_point),'ms')));
    
    
    % attend
    for chn_speaker = 1 : length(speaker_chn)
        chn_file_name = strcat(num2str(chn_speaker),'-',label66{speaker_chn(chn_speaker)});
        %% plot
        set(gcf,'outerposition',get(0,'screensize'));
        eval(strcat('subplot(6,10,',num2str(chn_speaker),')'));

        R_attend_for_topoplot = squeeze(mean(model_attend_mean(:,chn_speaker,time_point,:)));
        U_topoplot(R_attend_for_topoplot,layout,label66((listener_chn)));
        title(label66{listener_chn(chn_speaker)});

    end
    save_name = strcat('mTRF Audio forward attend Topoplot timelag',num2str(timelag_plot(time_point)),'ms.jpg');
    suptitle(save_name(1:end-4));
    saveas(gcf,save_name);
    
    close;
    
    % unatttend
    for chn_speaker = 1 : length(speaker_chn)
        chn_file_name = strcat(num2str(chn_speaker),'-',label66{speaker_chn(chn_speaker)});
        %% plot
        set(gcf,'outerposition',get(0,'screensize'));
        eval(strcat('subplot(6,10,',num2str(chn_speaker),')'));

        R_attend_for_topoplot = squeeze(mean(model_unattend_mean(:,chn_speaker,time_point,:)));
        U_topoplot(R_attend_for_topoplot,layout,label66((listener_chn)));
        title(label66{listener_chn(chn_speaker)});

    end
    save_name = strcat('mTRF Audio forward unattend Topoplot timelag',num2str(timelag_plot(time_point)),'ms.jpg');
    suptitle(save_name(1:end-4));
    saveas(gcf,save_name);
    
    close;
    
    p = pwd;
    cd(p(1:end-(length(strcat(num2str(timelag_plot(time_point),'ms')))+1)));
end
