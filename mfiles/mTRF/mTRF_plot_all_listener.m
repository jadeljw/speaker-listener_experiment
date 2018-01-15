%% mTRF - speaker listener timelag plot
% mTRF timelog plot for speaker-listener-new-experiment data
% Experiment date : 2017.7.5
% purpose: mTRF validation
% by:LJW
%% initial topoplot
listener_chn= [1:32 34:42 44:59 61:63];

load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';

%% listener
listener_num = 20;

%% timelag

% timelag = -200:25:500;
Fs = 64;
timelag = -250:(1000/Fs):500;

% timelag = (-3000:500/32:3000)/(1000/Fs);
% timelag = (-250:500/32:500)/(1000/Fs);
% timelag= timelag(33:40);
% timelag = (0:500/32:500)/(1000/Fs);

lambda = 2^5;
% bandName = strcat(' 64Hz 2-8Hz sound from EEG lambda',num2str(lambda),' 10-65s unattend only');
% bandName = strcat(' 64Hz 2-8Hz lambda',num2str(lambda),' 10-55s');

Attend_topoplot_listener_mean_all_listener = cell(listener_num,length(timelag));
Unattend_topoplot_listener_mean_all_listener  = cell(listener_num,length(timelag));

recon_AttendDecoder_attend_total_all_listener  = zeros(listener_num,length(timelag));
recon_AttendDecoder_unattend_total_all_listener  = zeros(listener_num,length(timelag));
recon_UnattendDecoder_attend_total_all_listener  = zeros(listener_num,length(timelag));
recon_UnattendDecoder_unattend_total_all_listener  = zeros(listener_num,length(timelag));
decoding_acc_attended_all_listener  = zeros(listener_num,length(timelag));
decoding_acc_unattended_all_listener  = zeros(listener_num,length(timelag));
Decoding_acc_attend_ttest_result_all_listener  = zeros(listener_num,length(timelag));
Decoding_acc_unattend_ttest_result_all_listener  = zeros(listener_num,length(timelag));

for i = 1 : listener_num
    
    
    %% initial
    timelag_attend_topoplot_listener_mean = cell(1,length(timelag));
    timelag_unattend_topoplot_listener_mean = cell(1,length(timelag));
    
    recon_AttendDecoder_attend_total = zeros(1,length(timelag));
    recon_AttendDecoder_unattend_total = zeros(1,length(timelag));
    recon_UnattendDecoder_attend_total = zeros(1,length(timelag));
    recon_UnattendDecoder_unattend_total = zeros(1,length(timelag));
    decoding_acc_attended = zeros(1,length(timelag));
    decoding_acc_unattended = zeros(1,length(timelag));
    Decoding_acc_attend_ttest_result = zeros(1,length(timelag));
    Decoding_acc_unattend_ttest_result = zeros(1,length(timelag));
    
    %% data name
    if i < 10
        file_name = strcat('listener10',num2str(i));
    else
        file_name = strcat('listener1',num2str(i));
    end
    
    bandName = strcat(' 64Hz 2-8Hz sound from wav l', file_name(2:end),' lambda',num2str(lambda),' 10-55s');
    
    mkdir(file_name);
    cd(file_name);
    
    
    %%  mTRF plot
    % p = pwd;
    p = 'E:\DataProcessing\speaker-listener_experiment\Decoding Result\mTRF';
    % category = 'mTRF';
    %     category = '64Hz 2-8Hz lambda32 10-55s';
    category =file_name;
    
    
    mkdir('topoplot');
    cd('topoplot');
    for  j = 1 : length(timelag)
        % load data
        datapath = strcat(p,'\',category);
        dataName = strcat('mTRF_sound_EEG_result+',num2str(timelag(j)),'ms',bandName,'.mat');
        load(strcat(datapath,'\',dataName));
        
        %reconstruction accuracy
        recon_AttendDecoder_attend_total(j) =  mean(mean(recon_AttendDecoder_attend_corr));
        recon_AttendDecoder_unattend_total(j) =  mean(mean(recon_AttendDecoder_unattend_corr));
        recon_UnattendDecoder_attend_total(j) = mean(mean(recon_UnattendDecoder_attend_corr));
        recon_UnattendDecoder_unattend_total(j) = mean(mean(recon_UnattendDecoder_unattend_corr));
        
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
        timelag_attend_topoplot_listener_mean{j} = mean(train_mTRF_attend_w_all_story_mean_mat,2);
        timelag_unattend_topoplot_listener_mean{j} = mean(train_mTRF_unattend_w_all_story_mean_mat,2);
        
        
        subplot(121);
        U_topoplot(abs(zscore(mean(train_mTRF_attend_w_all_story_mean_mat,2))),layout,label66(listener_chn));%plot(w_A(:,1));
        title('Attended decoder');
        subplot(122);
        U_topoplot(abs(zscore(mean(train_mTRF_unattend_w_all_story_mean_mat,2))),layout,label66(listener_chn));%plot(v_B(:,1));
        title('Unattended decoder');
        save_name = strcat(file_name,'-Mean Topoplot timelag ',num2str(timelag(j)),'ms.jpg');
        suptitle(save_name(1:end-4));
        saveas(gcf,save_name)
        close;
        
    end
    
    p = pwd;
    cd(p(1:end-(length('topoplot')+1)));
    
    %% timelag plot
    figure; plot(timelag,recon_AttendDecoder_attend_total,'r');
    hold on; plot(timelag,recon_AttendDecoder_unattend_total,'b');
    xlabel('Times(ms)');
    ylabel('r-value')
    saveName1 = strcat( 'Attended decoder Reconstruction-Acc across all time-lags using mTRF method',bandName,'.jpg');
    title(saveName1(1:end-4));
    legend('r Attended ','r unAttended','Location','northeast');
    % ylim([-0.03,0.03]);
    saveas(gcf,saveName1);
    close
    
    figure; plot(timelag,recon_UnattendDecoder_attend_total,'r');
    hold on; plot(timelag,recon_UnattendDecoder_unattend_total,'b');
    xlabel('Times(ms)');
    ylabel('r-value')
    saveName2 = strcat('Unattended decoder Reconstruction-Acc across timelags using mTRF method',bandName,'.jpg');
    title(saveName2(1:end-4));
    legend('r Attended ','r unAttended','Location','northeast');
    % ylim([-0.03,0.03]);
    saveas(gcf,saveName2);
    close
    
    figure; plot(timelag,decoding_acc_attended*100,'r');
    hold on; plot(timelag,decoding_acc_unattended*100,'b');
    xlabel('Times(ms)');
    ylabel('Decoding accuracy(%)')
    saveName3 =strcat('Decoding-Accuracy across timelags using mTRF method',bandName,'.jpg');
    title(saveName3(1:end-4));
    legend('Attended decoder','Unattended decoder','Location','northeast');ylim([30,100]);
    saveas(gcf,saveName3);
    close
    
    recon_AttendDecoder_attend_total_all_listener(i,:) = recon_AttendDecoder_attend_total;
    recon_AttendDecoder_unattend_total_all_listener(i,:)  = recon_AttendDecoder_unattend_total;
    recon_UnattendDecoder_attend_total_all_listener(i,:)  = recon_UnattendDecoder_attend_total;
    recon_UnattendDecoder_unattend_total_all_listener(i,:)  = recon_UnattendDecoder_unattend_total;
    decoding_acc_attended_all_listener(i,:) = decoding_acc_attended;
    decoding_acc_unattended_all_listener(i,:) = decoding_acc_unattended;
    Attend_topoplot_listener_mean_all_listener(i,:) = timelag_attend_topoplot_listener_mean;
    Unattend_topoplot_listener_mean_all_listener(i,:) = timelag_unattend_topoplot_listener_mean;
    
    
    % save data
    saveName = strcat('mTRF_sound_EEG_result across timelags-',file_name,'.mat');
    %     saveName = strcat('mTRF_sound_EEG_result.mat');
    save(saveName,'decoding_acc_attended','decoding_acc_unattended',...
        'recon_UnattendDecoder_attend_total','recon_UnattendDecoder_unattend_total',...
        'recon_AttendDecoder_attend_total','recon_AttendDecoder_unattend_total',...
        'timelag_attend_topoplot_listener_mean','timelag_unattend_topoplot_listener_mean');
    
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