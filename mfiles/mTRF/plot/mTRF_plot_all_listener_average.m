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
load('E:\DataProcessing\speaker-listener_experiment\Plot\timelag plot\mTRF\theta reverse\mTRF_sound_EEG_result across timelags all listener.mat');


%% topoplot
% for  j = 1 : length(timelag)
%     
%     attend_decoder_mean_weights = mean(cell2mat(Attend_topoplot_listener_mean_all_listener(:,j)'),2);
%     unattend_decoder_mean_weights = mean(cell2mat(Unattend_topoplot_listener_mean_all_listener(:,j)'),2);
%     
%     subplot(121);
%     U_topoplot(abs(zscore(attend_decoder_mean_weights)),layout,label66(listener_chn));%plot(w_A(:,1));
%     title('Attended decoder');
%     subplot(122);
%     U_topoplot(abs(zscore( unattend_decoder_mean_weights)),layout,label66(listener_chn));%plot(v_B(:,1));
%     title('Unattended decoder');
%     save_name = strcat('All listener-Mean Topoplot timelag ',num2str(timelag(j)),'ms.jpg');
%     suptitle(save_name(1:end-4));
%     saveas(gcf,save_name)
%     close;
% end

%%  r value
figure; plot(timelag,mean(recon_AttendDecoder_attend_total_all_listener),'r');
hold on; plot(timelag,mean(recon_AttendDecoder_unattend_total_all_listener),'b');
xlabel('Times(ms)');
ylabel('r-value')
saveName1 = strcat( 'Attended decoder Reconstruction-Acc across all time-lags using mTRF method.jpg');
title(saveName1(1:end-4));
legend('r Attended ','r unAttended','Location','northeast');
% ylim([-0.03,0.03]);
saveas(gcf,saveName1);
close

figure; plot(timelag,mean(recon_UnattendDecoder_attend_total_all_listener),'r');
hold on; plot(timelag,mean(recon_UnattendDecoder_unattend_total_all_listener),'b');
xlabel('Times(ms)');
ylabel('r-value')
saveName2 = strcat('Unattended decoder Reconstruction-Acc across timelags using mTRF method.jpg');
title(saveName2(1:end-4));
legend('r Attended ','r unAttended','Location','northeast');
% ylim([-0.03,0.03]);
saveas(gcf,saveName2);
close
%% ttest
[h_attend,p_attend] = ttest(decoding_acc_attended_all_listener,0.5);
[h_unattend,p_unattend] = ttest(decoding_acc_unattended_all_listener,0.5);

decoding_acc_attended = mean(decoding_acc_attended_all_listener);
decoding_acc_unattended = mean(decoding_acc_unattended_all_listener);

figure; plot(timelag,decoding_acc_attended*100,'r');
hold on;plot(timelag(h_attend>0),decoding_acc_attended(h_attend>0)*100,'r*');
hold on; plot(timelag,decoding_acc_unattended*100,'b');
hold on;plot(timelag(h_unattend>0),decoding_acc_unattended(h_unattend>0)*100,'b*');

xlabel('Times(ms)');
ylabel('Decoding accuracy(%)')
saveName3 =strcat('All listener Mean Decoding-Acc across timelags using mTRF method.jpg');
title(saveName3(1:end-4));
legend('Attended decoder','significantí┘50%','Unattended decoder','significantí┘50%','Location','northeast');ylim([30,80]);
saveas(gcf,saveName3);
close
