% mTRF_plot_all_listener_average

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


%% load data
load('E:\DataProcessing\speaker-listener_experiment\Plot\timelag plot\mTRF\theta reverse fisher\mTRF_sound_EEG_result across timelags all listener.mat');

%% ttest
[h_attend,p_attend] = ttest(decoding_acc_attended_all_listener,0.5);
[h_unattend,p_unattend] = ttest(decoding_acc_unattended_all_listener,0.5);
[h_all,p_all] = ttest(decoding_acc_allDecoder_all_listener,0.5);

decoding_acc_attended = mean(decoding_acc_attended_all_listener);
decoding_acc_unattended = mean(decoding_acc_unattended_all_listener);
decoding_acc_all = mean(decoding_acc_allDecoder_all_listener);

figure; plot(timelag,decoding_acc_attended*100,'r','LineWidth',2);
hold on;plot(timelag(h_attend>0),decoding_acc_attended(h_attend>0)*100,'r*','LineWidth',2);
hold on; plot(timelag,decoding_acc_unattended*100,'b','LineWidth',2);
hold on;plot(timelag(h_unattend>0),decoding_acc_unattended(h_unattend>0)*100,'b*','LineWidth',2);
hold on; plot(timelag,decoding_acc_all*100,'g','LineWidth',2,'LineWidth',2);
hold on;plot(timelag(h_all>0),decoding_acc_all(h_all>0)*100,'g*','LineWidth',2);

xlabel('Times(ms)');
ylabel('Decoding accuracy(%)')
saveName3 =strcat('All listener Mean Decoding-Acc across timelags using mTRF method.jpg');
title(saveName3(1:end-4));
legend('Attended decoder','significant¡Ù50%','Unattended decoder','significant¡Ù50%','All decoder','significant¡Ù50%','Location','northeast');ylim([30,80]);
saveas(gcf,saveName3);
close
