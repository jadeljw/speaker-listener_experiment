%% logistic Regression plot
band_name = {'delta','theta','alpha'};
% band_name = {'theta','alpha'};

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
STD_para = 1;

%% split_point
split_index = 33;

%% new order
load('E:\DataProcessing\Label_and_area.mat');

select_area = 'Small_area';
chn_area_labels = fieldnames(eval(select_area));


for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    
    
    %% load data
    load(strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Speaker-listenerEEG\5-logistic regression\individual result\',...
        band_file_name,'\Speaker ListenerEEG Logstic Regresssion r^2 Result-total-',band_file_name,'-total-Small_area.mat'));
    
    %% speaker topoplot initial
    data_precede_topo_speaker = zeros(64,1);
    data_follow_topo_speaker = zeros(64,1);
    data_combine_topo_speaker = zeros(64,1);
    
    for chn_area_select = 1 : length(chn_area_labels)
        disp(chn_area_labels{chn_area_select});
        speaker_chn = eval(strcat(select_area,'.',chn_area_labels{chn_area_select}));
        mkdir(chn_area_labels{chn_area_select});
        cd(chn_area_labels{chn_area_select});
        
        
        R_squared_mat = squeeze(R_squared_mat_speaker(chn_area_select,:,:));
        %% zscore
        zscore_data_temp = zscore(R_squared_mat');
        zscore_data = zscore_data_temp';
        
        %     %% create figure
        %
        %     createfigure_timelag_new(data_Rsqueared_peak_data);
        %     title_name = strcat('Speaker ListenerEEG Logstic Regresssion r^2 Result-',band_file_name);
        %     title(title_name);
        %
        %     saveas(gcf,strcat(title_name,'.fig'));
        %     saveas(gcf,strcat(title_name,'.jpg'));
        %     close
        
        
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
        %         select_index = peak_index .* data_Rsquared_std_index;
        select_index = peak_index;
        select_data = select_index .* zscore_data;
        select_orginal_data = select_index .* R_squared_mat;
        
        %% split data
        %     split_index = round(length(timelag)/2);
        data_listener_precede_Rsquared = select_orginal_data(:,1:split_index);
        data_listener_follow_Rsquared = select_orginal_data(:,split_index+1:end);
        
        %% max
        [data_max_value_precede, data_max_index_precede] = sort(data_listener_precede_Rsquared,2,'descend');
        [data_max_value_follow, data_max_index_follow] = sort(data_listener_follow_Rsquared,2,'descend');
        
        
        data_precede_topo_speaker(speaker_chn,:) = mean(data_max_value_precede(:,1));
        data_follow_topo_speaker(speaker_chn,:) = mean(data_max_value_follow(:,1));
        
        %% earliest selected peak index
        %         earliest_peak_index = zeros(listener_num,1);
        %
        %         for listener_select  = 1 : listener_num
        %             for timepoint = 2 : size(R_squared_mat,2)-1
        %
        %                 if select_index(listener_select,timepoint) == 1
        %                     earliest_peak_index(listener_select,1) = timepoint;
        %                     break;
        %                 end
        %             end
        %         end
        
        [~,sort_earliest_peak] = sort(data_max_value_precede(:,1));
        
        %% logistic Regression
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
        
        
        LR_coeffciets = zeros(listener_num,4,2);
        LR_coeffciets_combine = zeros(listener_num,8);
        
        
        for listener_select = 1 : listener_num
            
            if listener_select < 10
                file_name = strcat('listener10',num2str(listener_select));
            else
                file_name = strcat('listener1',num2str(listener_select));
            end
            
            %         mkdir(file_name);
            %         cd(file_name);
            disp(file_name);
            
            %% before 0 ms
            
            % load r value data
            data_name = strcat('mTRF_speakerEEG_listenerEEG_result-',chn_area_labels{chn_area_select},'-timelag',num2str(timelag(data_max_index_precede(listener_select,1))),'ms-',band_file_name,'.mat');
            
            data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Speaker-listenerEEG\0-original r value\raw r value with trans\',...
                band_file_name,'\',file_name,'\',chn_area_labels{chn_area_select},'\');
            
            load(strcat(data_path,data_name));
            
            % attend mat
            attend_target_mat = attend_target_num';
            
            % combine r value
            r_value_mat_before = [recon_AttendDecoder_SpeakerA_corr recon_AttendDecoder_SpeakerB_corr recon_UnattendDecoder_SpeakerA_corr recon_UnattendDecoder_SpeakerB_corr];
            
            glm = fitglm(r_value_mat_before,attend_target_mat,'distr','binomial');
            Rsquared_peak(listener_select,1) = glm.Rsquared.Adjusted;
            d = devianceTest(glm);
            p_value_peak(listener_select,1) =  d.pValue(2);
            
            
            % weights
            %                 w_precede_att(listener_select,:) = mean(train_mTRF_attend_w_total,3);
            %                 w_precede_trans_att(listener_select,:)  = mean(train_mTRF_attend_w_trans_total,3);
            %
            %
            %                 w_precede_unatt(listener_select,:)  = mean(train_mTRF_unattend_w_total,3);
            %                 w_precede_trans_unatt(listener_select,:)  = mean(train_mTRF_unattend_w_trans_total,3);
            
            
            w_precede_att(listener_select,:) = zscore(mean(train_mTRF_attend_w_total,3));
            w_precede_trans_att(listener_select,:)  = zscore(mean(train_mTRF_attend_w_trans_total,3));
            
            
            w_precede_unatt(listener_select,:)  =zscore( mean(train_mTRF_unattend_w_total,3));
            w_precede_trans_unatt(listener_select,:)  = zscore(mean(train_mTRF_unattend_w_trans_total,3));
            
            
            % coeffciets
            temp_coefficients = table2array(glm.Coefficients);
            LR_coeffciets(listener_select,:,1) = temp_coefficients(2:end,1);
            
            
            %% after 0 ms
            
            
            % load r value data
            data_name = strcat('mTRF_speakerEEG_listenerEEG_result-',chn_area_labels{chn_area_select},'-timelag',num2str(timelag(data_max_index_follow(listener_select,1)+split_index)),'ms-',band_file_name,'.mat');
            
            data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Speaker-listenerEEG\0-original r value\raw r value with trans\',...
                band_file_name,'\',file_name,'\',chn_area_labels{chn_area_select},'\');
            
            load(strcat(data_path,data_name));
            
            % combine r value
            r_value_mat_after = [recon_AttendDecoder_SpeakerA_corr recon_AttendDecoder_SpeakerB_corr recon_UnattendDecoder_SpeakerA_corr recon_UnattendDecoder_SpeakerB_corr];
            
            
            glm = fitglm(r_value_mat_after,attend_target_mat,'distr','binomial');
            Rsquared_peak(listener_select,2) = glm.Rsquared.Adjusted;
            d = devianceTest(glm);
            p_value_peak(listener_select,2) =  d.pValue(2);
            
            % weights
            %                 w_follow_att(listener_select,:) = mean(train_mTRF_attend_w_total,3);
            %                 w_follow_trans_att(listener_select,:)  = mean(train_mTRF_attend_w_trans_total,3);
            %
            %
            %                 w_follow_unatt(listener_select,:)  = mean(train_mTRF_unattend_w_total,3);
            %                 w_follow_trans_unatt(listener_select,:)  = mean(train_mTRF_unattend_w_trans_total,3);
            
            w_follow_att(listener_select,:) = zscore(mean(train_mTRF_attend_w_total,3));
            w_follow_trans_att(listener_select,:)  = zscore(mean(train_mTRF_attend_w_trans_total,3));
            
            
            w_follow_unatt(listener_select,:)  = zscore(mean(train_mTRF_unattend_w_total,3));
            w_follow_trans_unatt(listener_select,:)  = zscore(mean(train_mTRF_unattend_w_trans_total,3));
            
            % coeffciets
            temp_coefficients = table2array(glm.Coefficients);
            LR_coeffciets(listener_select,:,2) = temp_coefficients(2:end,1);
            
            
            %% combine before and after
            
            r_value_mat_total = [r_value_mat_before r_value_mat_after];
            
            glm = fitglm(r_value_mat_total,attend_target_mat,'distr','binomial');
            Rsquared_peak(listener_select,3) = glm.Rsquared.Adjusted;
            d = devianceTest(glm);
            p_value_peak(listener_select,3) =  d.pValue(2);
            
            % coeffciets
            temp_coefficients = table2array(glm.Coefficients);
            LR_coeffciets_combine(listener_select,:) = temp_coefficients(2:end,1);
            
        end
        
        %% plot
        plot(Rsquared_peak','*--','lineWidth',1,'Color',[.3 .3 .3]);
        hold on; plot(nanmean(Rsquared_peak),'o-','lineWidth',3);
        title_name = strcat('Rsquared peak-',band_file_name,'-',chn_area_labels{chn_area_select});
        title(title_name);
        ylim([0 1]);
        ylabel('R^2 value');
        xticks(1:3)
        xticklabels({strcat('<',num2str(timelag(split_index)),'ms'),strcat('>',num2str(timelag(split_index)),'ms'),'Combine'});
        saveas(gcf,strcat(title_name,'.fig'));
        saveas(gcf,strcat(title_name,'.jpg'));
        close
        
        
        plot(-log10(p_value_peak)','*--','lineWidth',1,'Color',[.3 .3 .3]);
        title_name = strcat('p value of Rsquared peak-',band_file_name,'-',chn_area_labels{chn_area_select});
        title(title_name);
        ylabel('-log10(p)');
        xticks(1:3)
        xticklabels({strcat('<',num2str(timelag(split_index)),'ms'),strcat('>',num2str(timelag(split_index)),'ms'),'Combine'});
        saveas(gcf,strcat(title_name,'.fig'));
        saveas(gcf,strcat(title_name,'.jpg'));
        close
        
        temp_R_squared = nanmean(Rsquared_peak);
        data_precede_topo_speaker(speaker_chn,:) = temp_R_squared(1);
        data_follow_topo_speaker(speaker_chn,:) = temp_R_squared(2);
        data_combine_topo_speaker(speaker_chn,:) = temp_R_squared(3);
        
        
        %% topoplot
        set(gcf,'outerposition',get(0,'screensize'));
        %         colormap(jet);
        %         caxis([-1 1]);
        subplot(221);
        U_topoplot(nanmean(w_precede_att)',layout,label66(speaker_chn_total));
        title('Listener precede attend');
        
        subplot(223);
        U_topoplot(nanmean(w_precede_unatt)',layout,label66(speaker_chn_total));
        title('Listener precede unattend');
        
        subplot(222);
        U_topoplot(nanmean(w_follow_att)',layout,label66(speaker_chn_total));
        title('Listener follow attend');
        
        subplot(224);
        U_topoplot(nanmean(w_follow_unatt)',layout,label66(speaker_chn_total));
        title('Listener follow unattend');
        
        save_name = strcat('Highest R^2 value weights-',band_file_name,'-',chn_area_labels{chn_area_select});
        suptitle(save_name);
        saveas(gcf,strcat(save_name,'.jpg'));
        saveas(gcf,strcat(save_name,'.fig'));
        close
        
        
        % trans plot
        set(gcf,'outerposition',get(0,'screensize'));
        %         colormap(jet);
        subplot(221);
        U_topoplot(nanmean(w_precede_trans_att)',layout,label66(speaker_chn_total));
        title('Listener precede attend');
        
        subplot(223);
        U_topoplot(nanmean(w_precede_trans_unatt)',layout,label66(speaker_chn_total));
        title('Listener precede unattend');
        
        subplot(222);
        U_topoplot(nanmean(w_follow_trans_att)',layout,label66(speaker_chn_total));
        title('Listener follow attend');
        
        subplot(224);
        U_topoplot(nanmean(w_follow_trans_unatt)',layout,label66(speaker_chn_total));
        title('Listener follow unattend');
        
        save_name = strcat('Highest R^2 value trans weights-',band_file_name,'-',chn_area_labels{chn_area_select});
        suptitle(save_name);
        saveas(gcf,strcat(save_name,'.jpg'));
        saveas(gcf,strcat(save_name,'.fig'));
        
        close
        
        
        %%  coeffciets bar plot
        set(gcf,'outerposition',get(0,'screensize'));
        subplot(131);
        bar(squeeze(mean(LR_coeffciets(:,:,1),1)));
        xticklabels({'AD-A','AD-B','UD-A','UD-B'});
        title('precede');
        
        subplot(132);
        bar(squeeze(mean(LR_coeffciets(:,:,2),1)));
        xticklabels({'AD-A','AD-B','UD-A','UD-B'});
        title('follow');
        
        
        subplot(133);
        bar(mean(LR_coeffciets_combine,1));
        xticklabels({'AD-A_p','AD-B_p','UD-A_p','UD-B_p','AD-A_f','AD-B_f','UD-A_f','UD-B_f'});
        title('combine');
        
        save_name = strcat('Coeffciets-',band_file_name,'-',chn_area_labels{chn_area_select});
        suptitle(save_name);
        saveas(gcf,strcat(save_name,'.jpg'));
        saveas(gcf,strcat(save_name,'.fig'));
        
        close
        
        %%  save data
        
        save_name = strcat('Rsquared_peak-',band_file_name);
        save(save_name,'Rsquared_peak');
        
        %
        % file
        p = pwd;
        cd(p(1:end-(length(chn_area_labels{chn_area_select})+1)));
    end
    
    
    %% topoplot
    set(gcf,'outerposition',get(0,'screensize'));
    colormap(jet);
    subplot(131);
    U_topoplot(data_precede_topo_speaker(speaker_chn_total),layout,label66(speaker_chn_total));
    title('precede');
    
    subplot(132);
    U_topoplot(data_follow_topo_speaker(speaker_chn_total),layout,label66(speaker_chn_total));
    title('follow');
    
    subplot(133);
    U_topoplot(data_combine_topo_speaker(speaker_chn_total),layout,label66(speaker_chn_total));
    title('combine');
    
    save_name = strcat('Highest R^2 value-',band_file_name,'-',chn_area_labels{chn_area_select});
    suptitle(save_name);
    saveas(gcf,strcat(save_name,'.jpg'));
    saveas(gcf,strcat(save_name,'.fig'));
    close
    
    
    %% file
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end