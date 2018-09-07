%% logistic Regression plot
band_name = {'delta','theta','alpha'};
% band_name = {'theta'};

%% initial
load('E:\DataProcessing\chn_re_index.mat');
chn_re_index = chn_re_index(1:64);

listener_chn= [1:32 34:42 44:59 61:63];
speaker_chn_total= [1:32 34:42 44:59 61:63];

% speaker_chn = [9:11 18:20 27:29];
load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';


%% timelag

Fs = 64;
timelag = -500 : 1000/Fs : 500;
label_select = 1 : round(length(timelag)/8) :length(timelag);
listener_num = 20;
sig_thr = 0.05;

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    
    
    %% load data
    load(strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Audio-listener\zscore\2-logistic regression\1.individual\',band_file_name,...
        '\Audio ListenerEEG Logstic Regresssion r^2 Result-',band_file_name,'.mat'));
    
    %% zscore
    zscore_data_temp = zscore(R_squared_mat');
    zscore_data = zscore_data_temp';
    
    %% peak index
    peak_index = zeros(listener_num,length(timelag));
    
    for listener_select  = 1 : listener_num
        for timepoint = 2 : size(R_squared_mat,2)-1
            
            if R_squared_mat(listener_select,timepoint) >= R_squared_mat(listener_select,timepoint-1) ...
                    && R_squared_mat(listener_select,timepoint) >= R_squared_mat(listener_select,timepoint+1)
                peak_index(listener_select,timepoint) = 1;
            end
        end
    end
    
    
    %% select index
    select_index = peak_index;
    select_data = select_index .* zscore_data;
    select_orginal_data = select_index .* R_squared_mat;
    
    %% split data
    %     split_index = round(length(timelag)/2);
    split_index = 33;
    data_listener_precede_Rsquared = select_orginal_data(:,1:split_index);
    data_listener_follow_Rsquared = select_orginal_data(:,split_index+1:end);
    
    %% max
    [data_max_value_precede, data_max_index_precede] = sort(data_listener_precede_Rsquared,2,'descend');
    [data_max_value_follow, data_max_index_follow] = sort(data_listener_follow_Rsquared,2,'descend');
    
    data_max_select = zeros(listener_num,length(timelag));
    
    for listener_select = 1 : listener_num
        data_max_select(listener_select,data_max_index_follow(listener_select,1)+split_index) = 1;
        data_max_select(listener_select,data_max_index_follow(listener_select,2)+split_index) = 1;
    end
    
    [~,sort_largest_peak] = sort(data_max_index_follow(:,1));
    
    %% select timelag plot
    set(gcf,'outerposition',get(0,'screensize'));
    bar(sum(data_max_select));
    xticks(label_select);
    xticklabels(timelag(label_select));
    %         ylim([0 15]);
    ylabel('Count');
    xlabel('timelag(ms)');
    save_name = strcat('peak value distribution-',band_file_name);
    title(save_name);
    
    saveas(gcf,strcat(save_name,'.jpg'));
    saveas(gcf,strcat(save_name,'.fig'));
    close
    
    
    %% imagesc zscore
    set(gcf,'outerposition',get(0,'screensize'));
    imagesc(zscore_data(sort_largest_peak,:));
    %         colormap(copper);
    colorbar;
    save_name = strcat('Imagesc Audio Listener after zscore R^2 Peak-',band_file_name);
    ylabel('Listener No.');
    xlabel('timelag(ms)');
    xticks(label_select);
    xticklabels(timelag(label_select));
    title(save_name);
    
    
    saveas(gcf,strcat(save_name,'.jpg'));
    saveas(gcf,strcat(save_name,'.fig'));
    close
    
    
    %% select max data
    set(gcf,'outerposition',get(0,'screensize'));
    imagesc(data_max_select(sort_largest_peak,:));
    colormap(copper);
    colorbar;
    save_name = strcat('Selected data-',band_file_name);
    ylabel('Listener No.');
    xlabel('timelag(ms)');
    xticks(label_select);
    xticklabels(timelag(label_select));
    title(save_name);
    
    saveas(gcf,strcat(save_name,'.jpg'));
    saveas(gcf,strcat(save_name,'.fig'));
    
    close
    
    %% initial
    Rsquared_peak = zeros(listener_num,3); % before/after/all
    p_value_peak = zeros(listener_num,3);
    
    w_precede_att = zeros(listener_num,length(listener_chn));
    w_precede_trans_att = zeros(listener_num,length(listener_chn));
    w_follow_att = zeros(listener_num,length(listener_chn));
    w_follow_trans_att = zeros(listener_num,length(listener_chn));
    
    w_precede_unatt = zeros(listener_num,length(listener_chn));
    w_precede_trans_unatt = zeros(listener_num,length(listener_chn));
    w_follow_unatt = zeros(listener_num,length(listener_chn));
    w_follow_trans_unatt = zeros(listener_num,length(listener_chn));
    
    
    for listener_select = 1 : listener_num
        
        if listener_select < 10
            file_name = strcat('listener10',num2str(listener_select));
        else
            file_name = strcat('listener1',num2str(listener_select));
        end
        
        %         mkdir(file_name);
        %         cd(file_name);
        disp(file_name);
        
        %% before 0 ms 1st
        
        % load r value data
        data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Audio-listener\zscore\0-raw r value\',...
            band_name{band_select},'\',file_name,'\');
        
        
        data_name = strcat('mTRF_Audio_listenerEEG_result-timelag',num2str(timelag(data_max_index_follow(listener_select,1))),'ms-',band_name{band_select},'.mat');
        %             data_name = strcat('mTRF_sound_EEG_result+',num2str(timelag(time_point)),'ms 64Hz 2-8Hz sound from wav L',file_name(3:end),' lambda1024 10-55s.mat');
        load(strcat(data_path,data_name));
        
        % attend mat
        attend_target_mat = attend_target_num';
        
        % combine r value
        r_value_mat_before = [recon_AttendDecoder_AudioA_corr recon_AttendDecoder_AudioB_corr recon_UnattendDecoder_AudioA_corr recon_UnattendDecoder_AudioB_corr];
        
        glm = fitglm(r_value_mat_before,attend_target_mat,'distr','binomial');
        Rsquared_peak(listener_select,1) = glm.Rsquared.Adjusted;
        d = devianceTest(glm);
        p_value_peak(listener_select,1) =  d.pValue(2);
        
        w_precede_att(listener_select,:) = zscore(mean(train_mTRF_attend_w_total,3));
        w_precede_trans_att(listener_select,:)  = zscore(mean(train_mTRF_attend_w_trans_total,3));
        
        
        w_precede_unatt(listener_select,:)  =zscore( mean(train_mTRF_unattend_w_total,3));
        w_precede_trans_unatt(listener_select,:)  = zscore(mean(train_mTRF_unattend_w_trans_total,3));
        
        %% before 0ms max nd
        
        
        % load r value data
        data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Audio-listener\zscore\0-raw r value\',...
            band_name{band_select},'\',file_name,'\');
        
        
        data_name = strcat('mTRF_Audio_listenerEEG_result-timelag',num2str(timelag(data_max_index_follow(listener_select,2))),'ms-',band_name{band_select},'.mat');
        load(strcat(data_path,data_name));
        
        % combine r value
        r_value_mat_after = [recon_AttendDecoder_AudioA_corr recon_AttendDecoder_AudioB_corr recon_UnattendDecoder_AudioA_corr recon_UnattendDecoder_AudioB_corr];
        
        
        glm = fitglm(r_value_mat_after,attend_target_mat,'distr','binomial');
        Rsquared_peak(listener_select,2) = glm.Rsquared.Adjusted;
        d = devianceTest(glm);
        p_value_peak(listener_select,2) =  d.pValue(2);
        
        w_follow_att(listener_select,:) = zscore(mean(train_mTRF_attend_w_total,3));
        w_follow_trans_att(listener_select,:)  = zscore(mean(train_mTRF_attend_w_trans_total,3));
        
        
        w_follow_unatt(listener_select,:)  = zscore(mean(train_mTRF_unattend_w_total,3));
        w_follow_trans_unatt(listener_select,:)  = zscore(mean(train_mTRF_unattend_w_trans_total,3));
        
        
        %% combine before and after
        r_value_mat_total = [r_value_mat_before r_value_mat_after];
        
        glm = fitglm(r_value_mat_total,attend_target_mat,'distr','binomial');
        Rsquared_peak(listener_select,3) = glm.Rsquared.Adjusted;
        d = devianceTest(glm);
        p_value_peak(listener_select,3) =  d.pValue(2);
        
        
        
    end
    
    
    %% plot
    plot(Rsquared_peak','*--','lineWidth',1,'Color',[.3 .3 .3]);
    hold on; plot(nanmean(Rsquared_peak),'o-','lineWidth',3);
    ylim([0 1]);
    title_name = strcat('Rsquared peak-',band_file_name);
    title(title_name);
    ylabel('R^2 value');
    xticks(1:3)
    xticklabels({strcat('<',num2str(timelag(split_index)),'ms 1^st'),strcat('<',num2str(timelag(split_index)),'ms 2^nd'),'Combine'});
    saveas(gcf,strcat(title_name,'.fig'));
    saveas(gcf,strcat(title_name,'.jpg'));
    close
    
    
    plot(-log10(p_value_peak)','*--','lineWidth',1,'Color',[.3 .3 .3]);
    title_name = strcat('p value of Rsquared peak-',band_file_name);
    title(title_name);
    ylabel('-log10(p)');
    xticks(1:3)
    xticklabels({strcat('<',num2str(timelag(split_index)),'ms 1^st'),strcat('<',num2str(timelag(split_index)),'ms 2^nd'),'Combine'});
    saveas(gcf,strcat(title_name,'.fig'));
    saveas(gcf,strcat(title_name,'.jpg'));
    close
    
    
    
    %% topoplot
    set(gcf,'outerposition',get(0,'screensize'));
    %         colormap(jet);
    %         caxis([-1 1]);
    subplot(221);
    U_topoplot(nanmean(w_precede_att)',layout,label66(speaker_chn_total));
    title('Listener 1^s^t attend');
    
    subplot(223);
    U_topoplot(nanmean(w_precede_unatt)',layout,label66(speaker_chn_total));
    title('Listener 1^s^t unattend');
    
    subplot(222);
    U_topoplot(nanmean(w_follow_att)',layout,label66(speaker_chn_total));
    title('Listener 2^n^d attend');
    
    subplot(224);
    U_topoplot(nanmean(w_follow_unatt)',layout,label66(speaker_chn_total));
    title('Listener 2^n^d unattend');
    
    save_name = strcat('Highest R^2 value weights follow-',band_file_name);
    suptitle(save_name);
    saveas(gcf,strcat(save_name,'.jpg'));
    saveas(gcf,strcat(save_name,'.fig'));
    close
    
    
    % trans plot
    set(gcf,'outerposition',get(0,'screensize'));
    %         colormap(jet);
    subplot(221);
    U_topoplot(nanmean(w_precede_trans_att)',layout,label66(speaker_chn_total));
    title('Listener 1^s^t attend');
    
    subplot(223);
    U_topoplot(nanmean(w_precede_trans_unatt)',layout,label66(speaker_chn_total));
    title('Listener 1^s^t unattend');
    
    subplot(222);
    U_topoplot(nanmean(w_follow_trans_att)',layout,label66(speaker_chn_total));
    title('Listener 2^n^d attend');
    
    subplot(224);
    U_topoplot(nanmean(w_follow_trans_unatt)',layout,label66(speaker_chn_total));
    title('Listener 2^n^d unattend');
    
    save_name = strcat('Highest R^2 value trans weights follow-',band_file_name);
    suptitle(save_name);
    saveas(gcf,strcat(save_name,'.jpg'));
    saveas(gcf,strcat(save_name,'.fig'));
    
    close
    
    
    %% file
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end