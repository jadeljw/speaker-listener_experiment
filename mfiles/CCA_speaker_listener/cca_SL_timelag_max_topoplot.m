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

% timelag = (-3000:500/32:3000)/(1000/Fs);
% timelag = (-250:500/32:500)/(1000/Fs);
% timelag= timelag(33:40);
% timelag = (0:500/32:500)/(1000/Fs);

decoding_acc_attended = zeros(1,length(timelag));
decoding_acc_unattended = zeros(1,length(timelag));

%% initial topoplot
% listener_chn= [7:13 16:22 25:31 35:41 45:51];
% speaker_chn = [7:13 16:22 25:31 35:41 45:51];

listener_chn= [1:32 34:42 44:59 61:63];
speaker_chn = [6:32 34:42 44:59 61:63];


load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';


for i = 1 : 20
    
    %% data name
    if i < 10
        file_name = strcat('listener10',num2str(i));
    else
        file_name = strcat('listener1',num2str(i));
    end
    
    mkdir(file_name);
    cd(file_name);
    
    %% Acc
    p =strcat('E:\DataProcessing\speaker-listener_experiment\Decoding Result\CCA-speaker-listener\theta\',file_name);
    Acc_data_name = strcat(strcat(file_name,'_Accuracy.mat'));
    load(strcat(p,'\',Acc_data_name));
    [decoding_acc_attended, Max_attend_index] = max(Acc_attend);
    [decoding_acc_unattended, Max_unattend_index] = max(Acc_unattend);
    
    r_rank_max_attend_acc_topoplot_speaker = cell(1,length(timelag));
    r_rank_max_attend_acc_topoplot_listener = cell(1,length(timelag));
    r_rank_max_unattend_acc_topoplot_speaker = cell(1,length(timelag));
    r_rank_max_unattend_acc_topoplot_listener = cell(1,length(timelag));
    
    for  j = 1 : length(timelag)
        
        r_rank_max_attend_acc = 0;
        r_rank_max_unattend_acc = 0;
        
        
        %%  CCA speaker listener plot
        datapath = p;
        dataName = strcat('cca_S-L_EEG_result+',num2str(timelag(j)),'ms.mat');
        load(strcat(datapath,'\',dataName));
        
        r_rank_max_attend_acc_topoplot_speaker{j} = mean(train_cca_attend_speaker_w_mean{Max_attend_index(j)},2);
        r_rank_max_attend_acc_topoplot_listener{j} = mean(train_cca_attend_listener_w_mean{Max_attend_index(j)},2);
        r_rank_max_unattend_acc_topoplot_speaker{j} = mean(train_cca_unattend_speaker_w_mean{Max_unattend_index(j)},2);
        r_rank_max_unattend_acc_topoplot_listener{j} = mean(train_cca_unattend_listener_w_mean{Max_unattend_index(j)},2);
        
        
        %% topoplot
        figure;
        subplot(121);
        U_topoplot(abs(zscore(r_rank_max_attend_acc_topoplot_listener{j})),layout,label66(listener_chn));%plot(w_A(:,1));
        title('Listener');
        subplot(122);
        U_topoplot(abs(zscore(r_rank_max_attend_acc_topoplot_speaker{j})),layout,label66(speaker_chn));%plot(v_B(:,1));
        title('Speaker');
        save_name = strcat(file_name,'-Topoplot for attend decoder-highest acc in timelag',num2str(timelag(j)),'ms.jpg');
        suptitle(save_name(1:end-4));
        saveas(gcf,save_name)
        close;
        
        figure;
        subplot(121);
        U_topoplot(abs(zscore(r_rank_max_unattend_acc_topoplot_listener{j})),layout,label66(listener_chn));%plot(w_A(:,1));
        title('Listener');
        subplot(122);
        U_topoplot(abs(zscore(r_rank_max_unattend_acc_topoplot_speaker{j})),layout,label66(speaker_chn));%plot(v_B(:,1));
        title('Speaker');
        save_name = strcat(file_name,'-Topoplot for unattend decoder-highest acc in timelag',num2str(timelag(j)),'ms.jpg');
        suptitle(save_name(1:end-4));
        saveas(gcf,save_name)
        close;
    end
    
    figure;
    plot(timelag,decoding_acc_attended*100,'r');
    % hold on;plot(timelag(Decoding_acc_attend_ttest_result>0),decoding_acc_attended(Decoding_acc_attend_ttest_result>0)*100,'r*');
    hold on; plot(timelag,decoding_acc_unattended*100,'b');
    % hold on;plot(timelag(Decoding_acc_unattend_ttest_result>0),decoding_acc_unattended(Decoding_acc_unattend_ttest_result>0)*100,'b*');
    xlabel('Times(ms)');
    ylabel('Decoding accuracy(%)')
    saveName3 =strcat('Max Acc-r rank acrcoss time-lags using CCA S-L method-',file_name,'.jpg');
    % saveName3 =strcat('Decoding-Accuracy across all time-lags using mTRF method',band_name,'.jpg');
    title(saveName3(1:end-4));
    % legend('Attended decoder','significant �� 50%','Unattended decoder','significant �� 50%','Location','northeast');ylim([30,100]);
    legend('Attended decoder','Unattended decoder','Location','northeast');ylim([30,100]);
    saveas(gcf,saveName3);
    close
    
    saveName =strcat('Max Acc-r rank across time-lags using CCA S-L method-',file_name,'.mat');
    save(saveName,'decoding_acc_attended', 'decoding_acc_unattended','r_rank_max_attend_acc_topoplot_listener','r_rank_max_unattend_acc_topoplot_listener',...
        'r_rank_max_attend_acc_topoplot_speaker','r_rank_max_unattend_acc_topoplot_speaker');
    
    
    p = pwd;
    cd(p(1:end-(length(file_name)+1)));
end
