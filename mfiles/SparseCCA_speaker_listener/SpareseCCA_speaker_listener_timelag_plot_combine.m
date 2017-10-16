%% mTRF - speaker listener timelag plot
% mTRF timelog plot for speaker-listener-new-experiment data
% Experiment date : 2017.7.5
% purpose: mTRF validation
% by:LJW


%% timelag

% timelag = -200:25:500;
Fs = 64;
timelag = -250:(1000/Fs):500;
timelag = timelag(1:42);

% timelag = (-3000:500/32:3000)/(1000/Fs);
% timelag = (-250:500/32:500)/(1000/Fs);
% timelag= timelag(33:40);
% timelag = (0:500/32:500)/(1000/Fs);
recon_AttendDecoder_attend_total = zeros(1,length(timelag));
recon_AttendDecoder_unattend_total = zeros(1,length(timelag));
recon_UnattendDecoder_attend_total = zeros(1,length(timelag));
recon_UnattendDecoder_unattend_total = zeros(1,length(timelag));
decoding_acc_attended = zeros(1,length(timelag));
decoding_acc_unattended = zeros(1,length(timelag));
Decoding_acc_attend_ttest_result = zeros(1,length(timelag));
Decoding_acc_unattend_ttest_result = zeros(1,length(timelag));

for r_rank = 1:5
    bandName = strcat(' 0.5Hz-40Hz 64Hz r rank',num2str(r_rank));
    
    %%  mTRF plot
    % p = pwd;
    p = 'E:\DataProcessing\speaker-listener_experiment\Decoding Result\SparseCCA-speaker-listener\listener0';
    % category = 'mTRF';
    category = bandName(2:end);
    
    for  j = 1 : length(timelag)
        % load data
        %     datapath = strcat(p,'\',category);
        %     dataName = strcat('mTRF_sound_EEG_result+',num2str(timelag(j)),'ms.mat');
        %     datapath = strcat(p,'\',category,'\-200ms_500ms_64Hz');
        datapath = strcat(p,'\',category);
        %     dataName = strcat('mTRF_sound_EEG_result+',num2str((1000/Fs)*timelag(j)),'ms.mat');
        %     dataName = strcat('mTRF_sound_EEG_result+',num2str((1000/Fs)*timelag(j)),'ms',bandName,'.mat');
        dataName = strcat('cca_S-L_EEG_result+',num2str(timelag(j)),'ms',bandName,'.mat');
        %     band_name = strcat(' broadband 0.1-40Hz lambda',num2str(lambda(j)));
        %     dataName = strcat('mTRF_sound_EEG_result -200~500 ms',band_name,'.mat');
        load(strcat(datapath,'\',dataName));
        
        %reconstruction accuracy
        recon_AttendDecoder_attend_total(j) =  mean(recon_AttendDecoder_attend_cca);
        recon_AttendDecoder_unattend_total(j) =  mean(recon_AttendDecoder_unattend_cca);
        recon_UnattendDecoder_attend_total(j) = mean(recon_UnattendDecoder_attend_cca);
        recon_UnattendDecoder_unattend_total(j) = mean(recon_UnattendDecoder_unattend_cca);
        
        %decoding accuracy
        Decoding_result_attend_decoder = recon_AttendDecoder_attend_cca-recon_AttendDecoder_unattend_cca;
        Individual_subjects_result_attend = mean(sum(Decoding_result_attend_decoder>0)/length(Decoding_result_attend_decoder));
        % ttest
        %     Decoding_acc_attend_ttest_result(j) = ttest(Individual_subjects_result_attend,0.5);
        decoding_acc_attended(j)= Individual_subjects_result_attend;
        
        Decoding_result_unattend_decoder = recon_UnattendDecoder_unattend_cca-recon_UnattendDecoder_attend_cca;
        Individual_subjects_result_unattend = mean(sum(Decoding_result_unattend_decoder>0)/length(Decoding_result_unattend_decoder));
        % ttest
        %     Decoding_acc_unattend_ttest_result(j) = ttest(Individual_subjects_result_unattend,0.5);
        decoding_acc_unattended(j) = Individual_subjects_result_unattend;
        
    end
    
    % figure; plot((1000/Fs)*timelag,recon_AttendDecoder_attend_total,'r');
    % hold on; plot((1000/Fs)*timelag,recon_AttendDecoder_unattend_total,'b');
    figure; plot(timelag,recon_AttendDecoder_attend_total,'r');
    hold on; plot(timelag,recon_AttendDecoder_unattend_total,'b');
    xlabel('Times(ms)');
    ylabel('r-value')
    saveName1 = strcat( 'Attended decoder Reconstruction-Acc across all time-lags using SparseCCA speaker-listener method',bandName,'.jpg');
    % saveName1 = strcat( 'Attended decoder Reconstruction-Acc across all time-lags using mTRF method',band_name,'.jpg');
    title(saveName1(1:end-4));
    legend('r Attended ','r unAttended','Location','northeast');
    % ylim([-0.03,0.03]);
    saveas(gcf,saveName1);
    close
    
    % figure; plot((1000/Fs)*timelag,recon_UnattendDecoder_attend_total,'r');
    % hold on; plot((1000/Fs)*timelag,recon_UnattendDecoder_unattend_total,'b');
    figure; plot(timelag,recon_UnattendDecoder_attend_total,'r');
    hold on; plot(timelag,recon_UnattendDecoder_unattend_total,'b');
    xlabel('Times(ms)');
    ylabel('r-value')
    saveName2 = strcat('Unattended decoder Reconstruction-Acc across all time-lags using SparseCCA speaker-listener method',bandName,'.jpg');
    % saveName2 = strcat('Unattended decoder Reconstruction-Acc across all time-lags using mTRF method',band_name,'.jpg');
    title(saveName2(1:end-4));
    legend('r Attended ','r unAttended','Location','northeast');
    % ylim([-0.03,0.03]);
    saveas(gcf,saveName2);
    close
    
    % figure; plot((1000/Fs)*timelag,decoding_acc_attended*100,'r');
    % hold on;plot((1000/Fs)*timelag(Decoding_acc_attend_ttest_result>0),decoding_acc_attended(Decoding_acc_attend_ttest_result>0)*100,'r*');
    % hold on; plot((1000/Fs)*timelag,decoding_acc_unattended*100,'b');
    % hold on;plot((1000/Fs)*timelag(Decoding_acc_unattend_ttest_result>0),decoding_acc_unattended(Decoding_acc_unattend_ttest_result>0)*100,'b*');
    figure; plot(timelag,decoding_acc_attended*100,'r');
    % hold on;plot(timelag(Decoding_acc_attend_ttest_result>0),decoding_acc_attended(Decoding_acc_attend_ttest_result>0)*100,'r*');
    hold on; plot(timelag,decoding_acc_unattended*100,'b');
    % hold on;plot(timelag(Decoding_acc_unattend_ttest_result>0),decoding_acc_unattended(Decoding_acc_unattend_ttest_result>0)*100,'b*');
    xlabel('Times(ms)');
    ylabel('Decoding accuracy(%)')
    saveName3 =strcat('Decoding-Accuracy across all time-lags using SparseCCA speaker-listener method',bandName,'.jpg');
    % saveName3 =strcat('Decoding-Accuracy across all time-lags using mTRF method',band_name,'.jpg');
    title(saveName3(1:end-4));
    % legend('Attended decoder','significant ¡Ù 50%','Unattended decoder','significant ¡Ù 50%','Location','northeast');ylim([30,100]);
    legend('Attended decoder','Unattended decoder','Location','northeast');ylim([30,100]);
    saveas(gcf,saveName3);
    close
    
end
