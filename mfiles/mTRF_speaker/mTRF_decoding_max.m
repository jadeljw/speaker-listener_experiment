%% mTRF - speaker listener timelag plot
% mTRF timelog plot for speaker-listener-new-experiment data
% Experiment date : 2018.1.24
% purpose: mTRF validation
% by:LJW


%% timelag

% timelag = -200:25:500;
Fs = 64;
timelag = -250:(1000/Fs):500;
cca_comp = 15;

% timelag = (-3000:500/32:3000)/(1000/Fs);
% timelag = (-250:500/32:500)/(1000/Fs);
% timelag= timelag(33:40);
% timelag = (0:500/32:500)/(1000/Fs);

decoding_acc_attended = zeros(1,length(timelag));
decoding_acc_unattended = zeros(1,length(timelag));

%% initial topoplot
listener_chn= [1:32 34:42 44:59 61:63];
speaker_chn = [17:21 26:30 36:40];
load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';

%% listener num
listener_num = 20;

%% initial
Acc_attend_all_max = zeros(listener_num,length(timelag));
Acc_unattend_all_max  = zeros(listener_num,length(timelag));

for i = 1 : listener_num
    if i < 10
        file_name = strcat('listener10',num2str(i));
    else
        file_name = strcat('listener1',num2str(i));
    end
    
    
    %% load data
    load(strcat('E:\DataProcessing\speaker-listener_experiment\Decoding Result\mTRF_speaker\Listener-Speaker\broadband\',file_name,'\',file_name,'_Accuracy.mat'));
    
    %% record into one matrix
    Acc_attend_all_max(i,:) = max(Acc_attend);
    Acc_unattend_all_max(i,:) = max(Acc_unattend);
    
    %% plot
    figure;plot(timelag,max(Acc_attend)*100,'r');
    hold on; plot(timelag,max(Acc_unattend)*100,'b');
    xlabel('Times(ms)');
    ylabel('Decoding accuracy(%)')
    saveName3 =strcat('Max Decoding-Accuracy mTRF_speakerEEG_result-',file_name,'.jpg');
    title(saveName3(1:end-4));
    legend('Attended decoder','Unattended decoder','Location','northeast');ylim([30,100]);
    saveas(gcf,saveName3);
    close
    
end

figure;plot(timelag,mean(Acc_attend_all_max)*100,'r');
hold on; plot(timelag,mean(Acc_unattend_all_max)*100,'b');
xlabel('Times(ms)');
ylabel('Decoding accuracy(%)')
saveName3 =strcat('Mean Max Decoding-Accuracy mTRF_speakerEEG_result-all listener.jpg');
title(saveName3(1:end-4));
legend('Attended decoder','Unattended decoder','Location','northeast');ylim([30,100]);
saveas(gcf,saveName3);
close
