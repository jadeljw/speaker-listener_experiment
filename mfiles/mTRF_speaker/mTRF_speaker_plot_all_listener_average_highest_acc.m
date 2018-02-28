% mTRF_plot_all_listener_average

%% initial topoplot
listener_chn= [1:32 34:42 44:59 61:63];
speaker_chn= 40;
% speaker_chn = [2 5 10 28 40 50];
% speaker_chn= [1:32 34:42 44:59 61:63];
% speaker_chn = [17:21 26:30 36:40];
% speaker_chn = [27:29];
% speaker_chn = [27:30 36 38];
% speaker_chn = [9:11 18:20 27:29];
load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';

%% listener
listener_num = 20;

%% step_index 
step_index  = 1 : 12;

%% timelag

% timelag = -200:25:500;
Fs = 64;
timelag = -250:(1000/Fs):500;


for chn = 1:length(speaker_chn)
    
    % channel name
    chn_file_name = strcat(num2str(chn),'-',label66{speaker_chn(chn)});
    mkdir(chn_file_name);
    cd(chn_file_name);
    
    
    % initial
    Attend_topoplot_listener_mean_all_listener = zeros(listener_num,length(timelag),length(listener_chn));
    Unattend_topoplot_listener_mean_all_listener  = zeros(listener_num,length(timelag),length(listener_chn));
    
    recon_AttendDecoder_attend_total_all_listener  = zeros(listener_num,length(timelag));
    recon_AttendDecoder_unattend_total_all_listener  = zeros(listener_num,length(timelag));
    recon_UnattendDecoder_attend_total_all_listener  = zeros(listener_num,length(timelag));
    recon_UnattendDecoder_unattend_total_all_listener  = zeros(listener_num,length(timelag));
    
    decoding_acc_attended_all_listener  = zeros(listener_num,length(timelag));
    decoding_acc_unattended_all_listener  = zeros(listener_num,length(timelag));
    decoding_acc_attended_abs_all_listener = zeros(listener_num,length(timelag));
    decoding_acc_unattended_abs_all_listener = zeros(listener_num,length(timelag));
    Decoding_acc_attend_ttest_result_all_listener  = zeros(listener_num,length(timelag));
    Decoding_acc_unattend_ttest_result_all_listener  = zeros(listener_num,length(timelag));
    Decoding_acc_attend_ttest_result_abs_all_listener  = zeros(listener_num,length(timelag));
    Decoding_acc_unattend_ttest_result_abs_all_listener  = zeros(listener_num,length(timelag));
    
    for i = 1 : listener_num
        %% data name
        if i < 10
            file_name = strcat('listener10',num2str(i));
        else
            file_name = strcat('listener1',num2str(i));
        end
        
        %         bandName = strcat(' 64Hz 2-8Hz sound from wav l', file_name(2:end),' lambda',num2str(lambda),' 10-55s');
        
        %% load data
        datapath = strcat('E:\DataProcessing\speaker-listener_experiment\Plot\timelag plot\mTRF_speaker\broadband reverse\',file_name,'\',chn_file_name);
        dataName = strcat('mTRF_sound_EEG_result across timelags-',file_name,'-',label66{speaker_chn(chn)},'.mat');
        load(strcat(datapath,'\',dataName));
        
        
        %% record into one matrix
        recon_AttendDecoder_attend_total_all_listener(i,:) = recon_AttendDecoder_attend_total;
        recon_AttendDecoder_unattend_total_all_listener(i,:)  = recon_AttendDecoder_unattend_total;
        recon_UnattendDecoder_attend_total_all_listener(i,:)  = recon_UnattendDecoder_attend_total;
        recon_UnattendDecoder_unattend_total_all_listener(i,:)  = recon_UnattendDecoder_unattend_total;
        decoding_acc_attended_all_listener(i,:) = decoding_acc_attended;
        decoding_acc_unattended_all_listener(i,:) = decoding_acc_unattended;
        %         decoding_acc_attended_abs_all_listener(i,:) = decoding_acc_attended_abs;
        %         decoding_acc_unattended_abs_all_listener(i,:) = decoding_acc_unattended_abs;
        Attend_topoplot_listener_mean_all_listener(i,:,:) = timelag_attend_topoplot_listener_mean;
        Unattend_topoplot_listener_mean_all_listener(i,:,:) = timelag_unattend_topoplot_listener_mean;
        
    end
    
    %     %% topoplot
    %         for  j = 1 : length(timelag)
    %
    %             attend_decoder_mean_weights = squeeze(mean(Attend_topoplot_listener_mean_all_listener,1));
    %             unattend_decoder_mean_weights = squeeze(mean(Unattend_topoplot_listener_mean_all_listener,1));
    %
    %             subplot(121);
    %             U_topoplot(abs(zscore(attend_decoder_mean_weights(j,:)')),layout,label66(listener_chn));%plot(w_A(:,1));
    %             title('Attended decoder');
    %             subplot(122);
    %             U_topoplot(abs(zscore(unattend_decoder_mean_weights(j,:)')),layout,label66(listener_chn));%plot(v_B(:,1));
    %             title('Unattended decoder');
    %             save_name = strcat(chn_file_name,'-All listener-Mean Topoplot timelag ',num2str(timelag(j)),'ms.jpg');
    %             suptitle(save_name(1:end-4));
    %             saveas(gcf,save_name)
    %             close;
    %         end
    
    %     %%  r value
    %     figure; plot(timelag,mean(recon_AttendDecoder_attend_total_all_listener),'r');
    %     hold on; plot(timelag,mean(recon_AttendDecoder_unattend_total_all_listener),'b');
    %     xlabel('Times(ms)');
    %     ylabel('r-value')
    %     saveName1 = strcat( 'Attended decoder Reconstruction-Acc across all time-lags using mTRF method-',chn_file_name,'.jpg');
    %     title(saveName1(1:end-4));
    %     legend('r Attended ','r unAttended','Location','northeast');
    %     % ylim([-0.03,0.03]);
    %     saveas(gcf,saveName1);
    %     close
    %
    %     figure; plot(timelag,mean(recon_UnattendDecoder_attend_total_all_listener),'r');
    %     hold on; plot(timelag,mean(recon_UnattendDecoder_unattend_total_all_listener),'b');
    %     xlabel('Times(ms)');
    %     ylabel('r-value')
    %     saveName2 = strcat('Unattended decoder Reconstruction-Acc across timelags using mTRF method-',chn_file_name,'.jpg');
    %     title(saveName2(1:end-4));
    %     legend('r Attended ','r unAttended','Location','northeast');
    %     % ylim([-0.03,0.03]);
    %     saveas(gcf,saveName2);
    %     close
    
    for step_selcect = 1 : length(step_index)
    %% search highest acc in long timelag
    step = step_index(step_selcect);
    start_timelag_index = 1: step: length(timelag);
    end_timelag_index = start_timelag_index+step-1;
    end_timelag_index(end) = length(timelag);
    
    
    %initial
    decoding_acc_attended_all_listener_timelag = zeros(listener_num,length(start_timelag_index));
    decoding_acc_unattended_all_listener_timelag = zeros(listener_num,length(start_timelag_index));
    for listener = 1 : listener_num
        for ii = 1 : length(start_timelag_index)
            decoding_acc_attended_all_listener_timelag(listener,ii) = max(decoding_acc_attended_all_listener(listener,start_timelag_index(ii):end_timelag_index(ii)));
            decoding_acc_unattended_all_listener_timelag(listener,ii) = max(decoding_acc_unattended_all_listener(listener,start_timelag_index(ii):end_timelag_index(ii)));
            if decoding_acc_attended_all_listener_timelag(listener,ii)< 0.5
                disp(strcat('Attend low acc: listener',num2str(listener),' timelag_index:',num2str(timelag(start_timelag_index(ii))),'ms'));
                disp(num2str((decoding_acc_attended_all_listener_timelag(listener,ii))));
                
            end
            
            if decoding_acc_unattended_all_listener_timelag(listener,ii)< 0.5
                disp(num2str(strcat('Unattend low acc: listener',num2str(listener),' timelag_index:',num2str(timelag(start_timelag_index(ii))),'ms')));
                disp(num2str((decoding_acc_unattended_all_listener_timelag(listener,ii))));
            end
            
        end
    end
    %% ttest
    [h_attend,p_attend] = ttest(decoding_acc_attended_all_listener_timelag,0.5);
    [h_unattend,p_unattend] = ttest(decoding_acc_unattended_all_listener_timelag,0.5);
    
    decoding_acc_attended = mean(decoding_acc_attended_all_listener_timelag);
    decoding_acc_unattended = mean(decoding_acc_unattended_all_listener_timelag);
    
    timelag_plot = timelag(start_timelag_index);
    figure; plot(timelag_plot,decoding_acc_attended*100,'r');
    hold on;plot(timelag_plot(h_attend>0),decoding_acc_attended(h_attend>0)*100,'r*');
    hold on; plot(timelag_plot,decoding_acc_unattended*100,'b');
    hold on;plot(timelag_plot(h_unattend>0),decoding_acc_unattended(h_unattend>0)*100,'b*');
    
    xlabel('Times(ms)');
    ylabel('Decoding accuracy(%)')
    saveName3 =strcat('All listener Mean Decoding-Acc across timelags using mTRF-Speaker method-',chn_file_name,'-step',num2str(step),'.jpg');
    title(saveName3(1:end-4));
    legend('Attended decoder','significant』50%','Unattended decoder','significant』50%','Location','northeast');ylim([30,80]);
    saveas(gcf,saveName3);
    close
    
    end
    
    %% ttest abs
    %     [h_attend,p_attend] = ttest(decoding_acc_attended_abs_all_listener,0.5);
    %     [h_unattend,p_unattend] = ttest(decoding_acc_unattended_abs_all_listener,0.5);
    %
    %     decoding_acc_attended_abs = mean(decoding_acc_attended_abs_all_listener);
    %     decoding_acc_unattended_abs = mean(decoding_acc_unattended_abs_all_listener);
    %
    %     figure; plot(timelag,decoding_acc_attended_abs*100,'r');
    %     hold on;plot(timelag(h_attend>0),decoding_acc_attended_abs(h_attend>0)*100,'r*');
    %     hold on; plot(timelag,decoding_acc_unattended_abs*100,'b');
    %     hold on;plot(timelag(h_unattend>0),decoding_acc_unattended_abs(h_unattend>0)*100,'b*');
    %
    %     xlabel('Times(ms)');
    %     ylabel('Decoding accuracy(%)')
    %     saveName3 =strcat('All listener Mean Decoding-Acc across timelags ABS using mTRF-Speaker method-',chn_file_name,'.jpg');
    %     title(saveName3(1:end-4));
    %     legend('Attended decoder','significant』50%','Unattended decoder','significant』50%','Location','northeast');ylim([30,80]);
    %     saveas(gcf,saveName3);
    %     close
    
    
    %     %% difference with 0.5
    %     [h_attend,p_attend] = ttest((abs(decoding_acc_attended_all_listener)-abs(decoding_acc_attended_all_listener)),0.5);
    %     [h_unattend,p_unattend] = ttest((abs(decoding_acc_attended_all_listener)-abs(decoding_acc_attended_all_listener)),0.5);
    %
    %     decoding_acc_attended = mean(abs(decoding_acc_attended_all_listener-0.5));
    %     decoding_acc_unattended = mean(abs(decoding_acc_unattended_all_listener-0.5));
    %
    %     figure; plot(timelag,decoding_acc_attended*100,'r');
    %     hold on;plot(timelag(h_attend>0),decoding_acc_attended(h_attend>0)*100,'r*');
    %     hold on; plot(timelag,decoding_acc_unattended*100,'b');
    %     hold on;plot(timelag(h_unattend>0),decoding_acc_unattended(h_unattend>0)*100,'b*');
    %
    %     xlabel('Times(ms)');
    %     ylabel('Decoding accuracy(%)')
    %     saveName3 =strcat('All listener decoding Acc ABS from 0.5 across timelags using mTRF-Speaker method-',chn_file_name,'.jpg');
    %     title(saveName3(1:end-4));
    %     legend('Attended decoder','significant』50%','Unattended decoder','significant』50%','Location','northeast');ylim([0,50]);
    %     saveas(gcf,saveName3);
    %     close
    
    p = pwd;
    cd(p(1:end-(length(chn_file_name)+1)));
end