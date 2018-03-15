% mTRF_speakerEEG_plot_backward

mkdir('delta reverse');
cd('delta reverse');
%% initial
load('E:\DataProcessing\chn_re_index.mat');
chn_re_index = chn_re_index(1:64);

listener_chn= [1:32 34:42 44:59 61:63];
speaker_chn = 63;
% speaker_chn = [28 31 48];
% speaker_chn = [1:32 34:42 44:59 61:63];
% speaker_chn = [17:21 26:30 36:40];
% speaker_chn = [9:11 18:20 27:29];
load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';


%% timelag
Fs = 64;
timelag = -250:500/32:500;
%     timelag = -250:(1000/Fs):500;
% timelag = timelag(33:49);
% timelag = 0;

%% lambda index
lambda_index = -10 : 20;


for i = 1 : 20
    
    %% listener name
    if i < 10
        file_name = strcat('listener10',num2str(i));
    else
        file_name = strcat('listener1',num2str(i));
    end
    mkdir(file_name);
    cd(file_name);
    
    for chn = 1 : length(speaker_chn)
        chn_file_name = strcat(num2str(chn),'-',label66{speaker_chn(chn)});
        mkdir(chn_file_name);
        cd(chn_file_name);
        
        for j = 1 : length(timelag)
            %% load plot data
            data_name =  strcat('mTRF_speakerEEG_listenerEEG_backward_result+',label66{speaker_chn(chn)},'-timelag',num2str(timelag(j)),'ms.mat');
            data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Backward model\mTRF_speakerEEG\delta reverse\',file_name,'\',chn_file_name);
            load(strcat(data_path,'\',data_name));
            
            %% plot
            set(gcf,'outerposition',get(0,'screensize'));
            % R
            subplot(131);
            plot(lambda_index,mean(R_attend),'LineWidth',2);hold on;plot(lambda_index,mean(R_unattend),'LineWidth',2);
            title('R value');xlabel('lambda 2^');ylabel('r');
            legend('Attended','Unattended');
            % MSE
            subplot(132);
            plot(lambda_index ,mean(MSE_attend),'LineWidth',2);hold on;plot(lambda_index,mean(MSE_unattend),'LineWidth',2);
            title('MSE');xlabel('lambda 2^');ylabel('MSE');
            legend('Attended','Unattended');
            % P
            subplot(133);
            plot(lambda_index,mean(P_attend),'LineWidth',2);hold on;plot(lambda_index,mean(P_unattend),'LineWidth',2);
            title('P value');xlabel('lambda 2^');ylabel('P');
            legend('Attended','Unattended');
            
            save_name = strcat('mTRFspeakerEEG-listenerEEG backward result+',label66{speaker_chn(chn)},'-timelag',num2str(timelag(j)),'ms.jpg');
            suptitle(save_name(1:end-4));
            saveas(gcf,save_name);
            
            close;
            
        end
        
        p = pwd;
        cd(p(1:end-(length(chn_file_name)+1)));
    end
    
    p = pwd;
    cd(p(1:end-(length(file_name)+1)));
    
end