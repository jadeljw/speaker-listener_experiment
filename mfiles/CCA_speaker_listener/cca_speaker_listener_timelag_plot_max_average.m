%% mTRF - speaker listener timelag plot
% mTRF timelog plot for speaker-listener-new-experiment data
% Experiment date : 2017.7.5
% purpose: mTRF validation
% by:LJW


%% timelag

% timelag = -200:25:500;
Fs = 64;
timelag = -250:(1000/Fs):500;
cca_comp = 15;
listener_number = 20;

decoding_acc_attended_mean = zeros(listener_number,length(timelag));
decoding_acc_unattended_mean = zeros(listener_number,length(timelag));

%% initial topoplot
% listener_chn= [6:32 34:42 44:59 61:63];
% speaker_chn = [1:32 34:42 44:59 61:63];

% listener_chn= [7:13 16:22 25:31 35:41 45:51];
% speaker_chn = [7:13 16:22 25:31 35:41 45:51];


listener_chn= [1:32 34:42 44:59 61:63];
speaker_chn = [6:32 34:42 44:59 61:63];

load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';
%% data type
% data_type = {'read';'retell'};
%
% for jj = 1 : length(data_type)
%     data_type_select = data_type{jj};
%     mkdir(data_type_select);
%     cd(data_type_select);

for i = 1 : 20
    
    %% data name
    if i < 10
        file_name = strcat('listener10',num2str(i));
    else
        file_name = strcat('listener1',num2str(i));
    end
    
    
    r_rank_max_attend_acc_topoplot_speaker_mean = cell(1,length(timelag));
    r_rank_max_attend_acc_topoplot_listener_mean = cell(1,length(timelag));
    r_rank_max_unattend_acc_topoplot_speaker_mean = cell(1,length(timelag));
    r_rank_max_unattend_acc_topoplot_listener_mean = cell(1,length(timelag));
    
    
%     bandName = strcat(' 0.5Hz-40Hz 64Hz r rank15');
    
    r_rank_max_attend_acc = 0;
    r_rank_max_unattend_acc = 0;
    
    %%  CCA speaker listener plot
    p =strcat('E:\DataProcessing\speaker-listener_experiment\timelag plot\CCA-speaker-listener\max acc timelag\theta\',file_name);
    datapath = p;
    dataName = strcat('Max Acc-r rank across time-lags using CCA S-L method-',file_name,'.mat');
    load(strcat(datapath,'\',dataName));
    
    
    %decoding accuracy
    decoding_acc_attended_mean(i,:)= decoding_acc_attended;
    decoding_acc_unattended_mean(i,:) = decoding_acc_unattended;
    
    
    % weights
    for j = 1 : length(timelag)
        r_rank_max_attend_acc_topoplot_speaker_mean{j}(:,i) = abs(zscore(r_rank_max_attend_acc_topoplot_speaker{j}));
        r_rank_max_attend_acc_topoplot_listener_mean{j}(:,i) = abs(zscore(r_rank_max_attend_acc_topoplot_listener{j}));
        r_rank_max_unattend_acc_topoplot_speaker_mean{j}(:,i) = abs(zscore(r_rank_max_unattend_acc_topoplot_speaker{j}));
        r_rank_max_unattend_acc_topoplot_listener_mean{j}(:,i) = abs(zscore(r_rank_max_unattend_acc_topoplot_listener{j}));
    end
    
end

%% topoplot
for j = 1 : length(timelag)
    figure;
    subplot(121);
    U_topoplot(mean(r_rank_max_attend_acc_topoplot_listener_mean{j},2),layout,label66(listener_chn));%plot(w_A(:,1));
    title('Listener');
    subplot(122);
    U_topoplot(mean(r_rank_max_attend_acc_topoplot_speaker_mean{j},2),layout,label66(speaker_chn));%plot(v_B(:,1));
    title('Speaker');
%     save_name = strcat('Average-',data_type_select,'-Topoplot for attended decoder-highest acc in timelag',num2str(timelag(j)),'ms.jpg');
    save_name = strcat('Average-Topoplot for attended decoder-highest acc in timelag',num2str(timelag(j)),'ms.jpg');
    suptitle(save_name(1:end-4));
    saveas(gcf,save_name)
    close;
    
    figure;
    subplot(121);
    U_topoplot(mean(r_rank_max_unattend_acc_topoplot_listener_mean{j},2),layout,label66(listener_chn));%plot(w_A(:,1));
    title('Listener');
    subplot(122);
    U_topoplot(mean(r_rank_max_unattend_acc_topoplot_speaker_mean{j},2),layout,label66(speaker_chn));%plot(v_B(:,1));
    title('Speaker');
%     save_name = strcat('Average-',data_type_select,'-Topoplot for unattended decoder-highest acc in timelag',num2str(timelag(j)),'ms.jpg');   
    save_name = strcat('Average-Topoplot for unattended decoder-highest acc in timelag',num2str(timelag(j)),'ms.jpg');
    suptitle(save_name(1:end-4));
    saveas(gcf,save_name)
    close;
    
    
end

%% time plot
figure;
plot(timelag,mean(decoding_acc_attended_mean)*100,'r');
% hold on;plot(timelag(Decoding_acc_attend_ttest_result>0),decoding_acc_attended(Decoding_acc_attend_ttest_result>0)*100,'r*');
hold on; plot(timelag,mean(decoding_acc_unattended_mean)*100,'b');
% hold on;plot(timelag(Decoding_acc_unattend_ttest_result>0),decoding_acc_unattended(Decoding_acc_unattend_ttest_result>0)*100,'b*');
xlabel('Times(ms)');
ylabel('Decoding accuracy(%)')
saveName3 =strcat('Average Max Acc-r rank acrcoss time-lags using CCA S-L method.jpg');
% saveName3 =strcat('Decoding-Accuracy across all time-lags using mTRF method',data_type_select,'.jpg');
title(saveName3(1:end-4));
% legend('Attended decoder','significant ¡Ù 50%','Unattended decoder','significant ¡Ù 50%','Location','northeast');ylim([30,100]);
legend('Attended decoder','Unattended decoder','Location','northeast');ylim([30,100]);
saveas(gcf,saveName3);
close


saveName =strcat('Max Acc-r rank across time-lags using CCA S-L method.mat');
save(saveName,'decoding_acc_attended_mean', 'decoding_acc_unattended_mean','r_rank_max_attend_acc_topoplot_listener_mean','r_rank_max_unattend_acc_topoplot_listener_mean',...
    'r_rank_max_attend_acc_topoplot_speaker_mean','r_rank_max_unattend_acc_topoplot_speaker_mean');

% p = pwd;
% cd(p(1:end-(length(data_type_select)+1)));
% end
