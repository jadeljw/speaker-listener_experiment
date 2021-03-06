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

%% search highest acc in long timelag
step = 4;
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
saveName3 =strcat('All listener Mean Decoding-Acc across timelags using mTRF method.jpg');
title(saveName3(1:end-4));
legend('Attended decoder','significantí┘50%','Unattended decoder','significantí┘50%','Location','northeast');ylim([30,80]);
saveas(gcf,saveName3);
close
