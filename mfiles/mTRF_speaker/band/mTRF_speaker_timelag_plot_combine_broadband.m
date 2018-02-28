%% mTRF - speaker listener timelag plot
% mTRF timelog plot for speaker-listener-new-experiment data
% Experiment date : 2017.7.5
% purpose: mTRF validation
% by:LJW

%% initial
listener_chn= [1:32 34:42 44:59 61:63];
speaker_chn = [1:32 34:42 44:59 61:63];
% speaker_chn = [17:21 26:30 36:40];
% speaker_chn = 9:12;
% speaker_chn = [9:11 18:20 27:29];
load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';



%% listener
listener_num = 20;
lambda = 2^5;


%% timelag

% timelag = -200:25:500;
Fs = 64;
timelag = -250:(1000/Fs):500;


Attend_topoplot_listener_mean_all_listener = zeros(listener_num,length(speaker_chn),length(timelag),length(listener_chn));
Unattend_topoplot_listener_mean_all_listener  = zeros(listener_num,length(speaker_chn),length(timelag),length(listener_chn));

recon_AttendDecoder_attend_total_all_listener  = zeros(listener_num,length(speaker_chn),length(timelag));
recon_AttendDecoder_unattend_total_all_listener  = zeros(listener_num,length(speaker_chn),length(timelag));
recon_UnattendDecoder_attend_total_all_listener  = zeros(listener_num,length(speaker_chn),length(timelag));
recon_UnattendDecoder_unattend_total_all_listener  = zeros(listener_num,length(speaker_chn),length(timelag));
decoding_acc_attended_all_listener  = zeros(listener_num,length(speaker_chn),length(timelag));
decoding_acc_unattended_all_listener  = zeros(listener_num,length(speaker_chn),length(timelag));
decoding_acc_attended_abs_all_listener  = zeros(listener_num,length(speaker_chn),length(timelag));
decoding_acc_unattended_abs_all_listener  = zeros(listener_num,length(speaker_chn),length(timelag));
Decoding_acc_attend_ttest_result_all_listener  = zeros(listener_num,length(speaker_chn),length(timelag));
Decoding_acc_unattend_ttest_result_all_listener  = zeros(listener_num,length(speaker_chn),length(timelag));


mkdir('broadband');
cd('broadband');

for i = 1 : listener_num
    
    %% data name
    if i < 10
        file_name = strcat('listener10',num2str(i));
    else
        file_name = strcat('listener1',num2str(i));
    end
    
    mkdir(file_name);
    cd(file_name);
    
    band_name = strcat(' 64Hz 2-8Hz speakerEEG mTRF Listener',file_name(end-2:end),' lambda',num2str(lambda),' 10-55s');
    
    
    for chn = 1:length(speaker_chn)
        chn_file_name = strcat(num2str(chn),'-',label66{speaker_chn(chn)});
        mkdir(chn_file_name);
        cd(chn_file_name);
        
        %%  CCA speaker listener plot
        % p = pwd;
        p =strcat('E:\DataProcessing\speaker-listener_experiment\Decoding Result\mTRF_speaker\Listener-Speaker\broadband\',file_name);
        % category = 'mTRF';
        category = chn_file_name;
        
        
        recon_AttendDecoder_attend_total = zeros(1,length(timelag));
        recon_AttendDecoder_unattend_total = zeros(1,length(timelag));
        recon_UnattendDecoder_attend_total = zeros(1,length(timelag));
        recon_UnattendDecoder_unattend_total = zeros(1,length(timelag));
        decoding_acc_attended = zeros(1,length(timelag));
        decoding_acc_unattended = zeros(1,length(timelag));
        Decoding_acc_attend_ttest_result = zeros(1,length(timelag));
        Decoding_acc_unattend_ttest_result = zeros(1,length(timelag));
        timelag_attend_topoplot_listener_mean = zeros(length(timelag),length(listener_chn));
        timelag_unattend_topoplot_listener_mean = zeros(length(timelag),length(listener_chn));
        
        
%         mkdir('topoplot');
%         cd('topoplot');
        for  j = 1 : length(timelag)
            datapath = strcat(p,'\',category);
            dataName = strcat('mTRF_speakerEEG_listenerEEG_result+',label66{speaker_chn(chn)},'-timelag',num2str(timelag(j)),'ms',band_name,'.mat');
            load(strcat(datapath,'\',dataName));
            
            %reconstruction accuracy
            recon_AttendDecoder_attend_total(j) =  mean(recon_AttendDecoder_attend_corr);
            recon_AttendDecoder_unattend_total(j) =  mean(recon_AttendDecoder_unattend_corr);
            recon_UnattendDecoder_attend_total(j) = mean(recon_UnattendDecoder_attend_corr);
            recon_UnattendDecoder_unattend_total(j) = mean(recon_UnattendDecoder_unattend_corr);
            
            %decoding accuracy
            Decoding_result_attend_decoder = recon_AttendDecoder_attend_corr-recon_AttendDecoder_unattend_corr;
            Individual_subjects_result_attend = mean(sum(Decoding_result_attend_decoder>0)/length(Decoding_result_attend_decoder));
            decoding_acc_attended(j)= Individual_subjects_result_attend;
            
            Decoding_result_unattend_decoder = recon_UnattendDecoder_unattend_corr-recon_UnattendDecoder_attend_corr;
            Individual_subjects_result_unattend = mean(sum(Decoding_result_unattend_decoder>0)/length(Decoding_result_unattend_decoder));
            decoding_acc_unattended(j) = Individual_subjects_result_unattend;
            
            % topoplot
            train_mTRF_attend_w_all_story_mean_mat = cell2mat(train_mTRF_attend_w_all_story_mean');
            train_mTRF_unattend_w_all_story_mean_mat = cell2mat(train_mTRF_unattend_w_all_story_mean');
            timelag_attend_topoplot_listener_mean(j,:) = mean(train_mTRF_attend_w_all_story_mean_mat,2);
            timelag_unattend_topoplot_listener_mean(j,:) = mean(train_mTRF_unattend_w_all_story_mean_mat,2);
            
%             
%             subplot(121);
%             U_topoplot(abs(zscore(mean(train_mTRF_attend_w_all_story_mean_mat,2))),layout,label66(listener_chn));%plot(w_A(:,1));
%             title('Attended decoder');
%             subplot(122);
%             U_topoplot(abs(zscore(mean(train_mTRF_unattend_w_all_story_mean_mat,2))),layout,label66(listener_chn));%plot(v_B(:,1));
%             title('Unattended decoder');
%             save_name = strcat(file_name,'-Mean Topoplot timelag ',num2str(timelag(j)),'ms-',label66{speaker_chn(chn)},'.jpg');
%             suptitle(save_name(1:end-4));
%             saveas(gcf,save_name)
%             close;
            
        end
%         p = pwd;
%         cd(p(1:end-(length('topoplot')+1)));
        
        % Attended decoder
        figure; plot(timelag,recon_AttendDecoder_attend_total,'r');
        hold on; plot(timelag,recon_AttendDecoder_unattend_total,'b');
        xlabel('Times(ms)');
        ylabel('r-value')
        saveName1 = strcat( 'Attended decoder mTRF-speakerEEG-listenerEEG-result-',label66{speaker_chn(chn)},'.jpg');
        title(saveName1(1:end-4));
        legend('r Attended ','r unAttended','Location','northeast');
        saveas(gcf,saveName1);
        close
        
        
        % Unattended decoder
        figure; plot(timelag,recon_UnattendDecoder_attend_total,'r');
        hold on; plot(timelag,recon_UnattendDecoder_unattend_total,'b');
        xlabel('Times(ms)');
        ylabel('r-value')
        saveName2 = strcat( 'Unattended decoder mTRF-speakerEEG-listenerEEG-result-',label66{speaker_chn(chn)},'.jpg');
        title(saveName2(1:end-4));
        legend('r Attended ','r unAttended','Location','northeast');
        % ylim([-0.03,0.03]);
        saveas(gcf,saveName2);
        close
        
        % decoding Acc
        figure;plot(timelag,decoding_acc_attended*100,'r');
        hold on; plot(timelag,decoding_acc_unattended*100,'b');
        xlabel('Times(ms)');
        ylabel('Decoding accuracy(%)')
        saveName3 =strcat('Decoding-Accuracy mTRF_speakerEEG_listenerEEG_result-',label66{speaker_chn(chn)},'.jpg');
        title(saveName3(1:end-4));
        legend('Attended decoder','Unattended decoder','Location','northeast');ylim([30,100]);
        saveas(gcf,saveName3);
        close
        
        
        recon_AttendDecoder_attend_total_all_listener(i,chn,:) = recon_AttendDecoder_attend_total;
        recon_AttendDecoder_unattend_total_all_listener(i,chn,:)  = recon_AttendDecoder_unattend_total;
        recon_UnattendDecoder_attend_total_all_listener(i,chn,:)  = recon_UnattendDecoder_attend_total;
        recon_UnattendDecoder_unattend_total_all_listener(i,chn,:)  = recon_UnattendDecoder_unattend_total;
        decoding_acc_attended_all_listener(i,chn,:) = decoding_acc_attended;
        decoding_acc_unattended_all_listener(i,chn,:) = decoding_acc_unattended;
        Attend_topoplot_listener_mean_all_listener(i,chn,:,:) = timelag_attend_topoplot_listener_mean;
        Unattend_topoplot_listener_mean_all_listener(i,chn,:,:) = timelag_unattend_topoplot_listener_mean;
        
        % save data
        saveName = strcat('mTRF_sound_EEG_result across timelags-',file_name,'-',label66{speaker_chn(chn)},'.mat');
        %     saveName = strcat('mTRF_sound_EEG_result.mat');
        save(saveName,'decoding_acc_attended','decoding_acc_unattended',...
            'recon_UnattendDecoder_attend_total','recon_UnattendDecoder_unattend_total',...
            'recon_AttendDecoder_attend_total','recon_AttendDecoder_unattend_total',...
            'timelag_attend_topoplot_listener_mean','timelag_unattend_topoplot_listener_mean');
        
        p = pwd;
        cd(p(1:end-(length(chn_file_name)+1)));
    end
    
    p = pwd;
    cd(p(1:end-(length(file_name)+1)));
end

%% all listener
% save data
saveName ='mTRF_sound_EEG_result across timelags all listener.mat';
%     saveName = strcat('mTRF_sound_EEG_result.mat');
save(saveName,'recon_AttendDecoder_attend_total_all_listener',...
    'recon_AttendDecoder_unattend_total_all_listener',...
    'recon_UnattendDecoder_attend_total_all_listener',...
    'recon_UnattendDecoder_unattend_total_all_listener',...
    'decoding_acc_attended_all_listener',...
    'decoding_acc_unattended_all_listener',...
    'Attend_topoplot_listener_mean_all_listener',...
    'Unattend_topoplot_listener_mean_all_listener');
