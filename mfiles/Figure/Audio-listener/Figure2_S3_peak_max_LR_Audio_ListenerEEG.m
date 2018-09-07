%% logistic Regression plot
band_name = {'delta','theta','alpha'};
% band_name = {'theta'};
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
    
    %% total std
    temp_std = std(R_squared_mat');
    
    data_Rsquared_peak_index = R_squared_mat> mean(R_squared_mat,2) + temp_std';
    data_Rsqueared_peak_data =  data_Rsquared_peak_index .* R_squared_mat;
    
    %% create figure
    
    createfigure_timelag_new(data_Rsqueared_peak_data);
    title_name = strcat('Speaker ListenerEEG Logstic Regresssion r^2 Result-',band_file_name);
    title(title_name);
    
    saveas(gcf,strcat(title_name,'.fig'));
    saveas(gcf,strcat(title_name,'.jpg'));
    close
    
    %% split data
    %     split_index = round(length(timelag)/2);
    split_index = 41;
    data_listener_precede_Rsquared = data_Rsqueared_peak_data(:,1:split_index);
    data_listener_follow_Rsquared = data_Rsqueared_peak_data(:,split_index+1:end);
    
    %% max
    [data_max_value_precede, data_max_index_precede] = sort(data_listener_precede_Rsquared,2,'descend');
    [data_max_value_follow, data_max_index_follow] = sort(data_listener_follow_Rsquared,2,'descend');
    
    %% initial
    Rsquared_peak = zeros(listener_num,3); % before/after/all
    p_value_peak = zeros(listener_num,3);
    
    for listener_select = 1 : listener_num
        
        if listener_select < 10
            file_name = strcat(' listener10',num2str(listener_select));
        else
            file_name = strcat(' listener1',num2str(listener_select));
        end
        
        %         mkdir(file_name);
        %         cd(file_name);
        disp(file_name);
        
        %% before 0 ms
        if data_max_value_precede(listener_select,1) ~=0
            % load r value data
            data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Audio-listener\zscore\0-raw r value\',...
                band_name{band_select},'\',file_name(2:end),'\');
            
            
            data_name = strcat('mTRF_Audio_listenerEEG_result-timelag',num2str(timelag(data_max_index_precede(listener_select,1))),'ms-',band_name{band_select},'.mat');
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
            
            %% after 0 ms
            if data_max_value_follow(listener_select,1) ~=0
                
                % load r value data
                data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Audio-listener\zscore\0-raw r value\',...
                    band_name{band_select},'\',file_name(2:end),'\');
                
                
                data_name = strcat('mTRF_Audio_listenerEEG_result-timelag',num2str(timelag(data_max_index_follow(listener_select,1)+split_index)),'ms-',band_name{band_select},'.mat');
                load(strcat(data_path,data_name));
                
                % combine r value
                r_value_mat_after = [recon_AttendDecoder_AudioA_corr recon_AttendDecoder_AudioB_corr recon_UnattendDecoder_AudioA_corr recon_UnattendDecoder_AudioB_corr];
                
                
                glm = fitglm(r_value_mat_after,attend_target_mat,'distr','binomial');
                Rsquared_peak(listener_select,2) = glm.Rsquared.Adjusted;
                d = devianceTest(glm);
                p_value_peak(listener_select,2) =  d.pValue(2);
                
                
                %% combine before and after
                r_value_mat_total = [r_value_mat_before r_value_mat_after];
                
                glm = fitglm(r_value_mat_total,attend_target_mat,'distr','binomial');
                Rsquared_peak(listener_select,3) = glm.Rsquared.Adjusted;
                d = devianceTest(glm);
                p_value_peak(listener_select,3) =  d.pValue(2);
                
                
            else
                Rsquared_peak(listener_select,2) = NaN;
                Rsquared_peak(listener_select,3) = NaN;
            end
        else
            Rsquared_peak(listener_select,1) = NaN;
            Rsquared_peak(listener_select,3) = NaN;
        end
    end
    %% plot
    plot(Rsquared_peak','*--','lineWidth',1,'Color',[.3 .3 .3]);
    hold on; plot(nanmean(Rsquared_peak),'o-','lineWidth',3);
    ylim([0 1]);
    title_name = strcat('Rsquared peak-',band_file_name);
    title(title_name);
    ylabel('R^2 value');
    xticks(1:3)
    xticklabels({strcat('<',num2str(timelag(split_index)),'ms'),strcat('>',num2str(timelag(split_index)),'ms'),'Combine'});
    saveas(gcf,strcat(title_name,'.fig'));
    saveas(gcf,strcat(title_name,'.jpg'));
    close
    
    
    plot(-log10(p_value_peak)','*--','lineWidth',1,'Color',[.3 .3 .3]);
    title_name = strcat('p value of Rsquared peak-',band_file_name);
    title(title_name);
    ylabel('-log10(p)');
    xticks(1:3)
    xticklabels({strcat('<',num2str(timelag(split_index)),'ms'),strcat('>',num2str(timelag(split_index)),'ms'),'Combine'});
    saveas(gcf,strcat(title_name,'.fig'));
    saveas(gcf,strcat(title_name,'.jpg'));
    close
    
    %% file
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end