%% logistic Regression plot
band_name = {'delta','theta','alpha'};
% band_name = {'theta'};
%% timelag

Fs = 64;
timelag = -500 : 1000/Fs : 500;
label_select = 1 : round(length(timelag)/8) :length(timelag);
listener_num = 20;

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    %     mkdir(band_file_name);
    %     cd(band_file_name);
    
    
    %% load data
    load(strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Audio-listener\zscore\2-logistic regression\1.individual\',band_file_name,...
        '\Audio ListenerEEG Logstic Regresssion r^2 Result-',band_file_name,'.mat'));
    
    
    %% split data
    %     split_index = round(length(timelag)/2);
    split_index = 39;
    data_listener_precede_Rsquared = R_squared_mat(:,1:split_index);
    data_listener_follow_Rsquared = R_squared_mat(:,split_index+1:end);
    
    %% max
    [data_max_value_precede, data_max_index_precede] = sort(data_listener_precede_Rsquared,2,'descend');
    [data_max_value_follow, data_max_index_follow] = sort(data_listener_follow_Rsquared,2,'descend');
    
    
    %% frequency
    nComp = 1;
    data_value_freq_precede = zeros(size(data_max_index_precede,2),nComp);
    data_value_freq_follow = zeros(size(data_max_index_follow,2),nComp);
    
    for comp = 1 : nComp
        precede_temp = tabulate(data_max_index_precede(:,comp));
        data_value_freq_precede(1:size(precede_temp,1),comp) = precede_temp(:,3);
        follow_temp = tabulate(data_max_index_follow(:,comp));
        data_value_freq_follow(1:size(follow_temp,1),comp)  =  follow_temp(:,3);
    end
    
    %% plot
    label_select = 1 : round(length(data_listener_follow_Rsquared)/5) :length(data_listener_follow_Rsquared);
    
    
    bar_width = 1.1;
    line_width = 2;
    set(gcf,'outerposition',get(0,'screensize'));
    colormap(cool);
    subplot(121);
    bar(data_value_freq_precede/100,1.1);
    for listener_select = 1 : listener_num
        hold on;plot(data_max_index_precede(listener_select,nComp),data_max_value_precede(listener_select,nComp),'k*','lineWidth',line_width);
    end
    
    %     plot(mean(data_listener_precede_Rsquared),'k','lineWidth',line_width);
    xlabel('timelag(ms)');
    ylabel('percetage / R^2');
    ylim([-0.05 1]);
%     xticks(label_select);
%     xticklabels(timelag(label_select));
    title('listener precede');
%     legend('Max 1','Max 2','Max 3','R^2','Location','best');
    
    subplot(122);
    bar(data_value_freq_follow/100,1.1);
    for listener_select = 1 : listener_num
        hold on;plot(data_max_index_follow(listener_select,nComp),data_max_value_follow(listener_select,nComp),'k*','lineWidth',line_width);
    end
    %     plot(mean(data_listener_follow_Rsquared),'k','lineWidth',line_width);
    xlabel('timelag(ms)');
    ylabel('percetage / R^2');
    ylim([-0.05 1]);
%     xticks(label_select);
%     xticklabels(timelag(label_select+length(data_value_freq_precede)));
    title('listener precede');
%     legend('Max 1','Max 2','Max 3','R^2','Location','best');
    
    saveName = strcat('Audio Listener-',band_file_name);
    suptitle(band_file_name);
    saveas(gcf,strcat(saveName,'.fig'));
    saveas(gcf,strcat(saveName,'.jpg'));
    
    close
    
    
    
    % file
    %     p = pwd;
    %     cd(p(1:end-(length(band_file_name)+1)));
end