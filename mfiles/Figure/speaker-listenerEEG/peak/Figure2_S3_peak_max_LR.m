%% logistic Regression plot
band_name = {'delta','theta','alpha'};
% band_name = {'theta'};
%% timelag

Fs = 64;
timelag = -500 : 1000/Fs : 500;
label_select = 1 : round(length(timelag)/8) :length(timelag);
listener_num = 20;
sig_thr = 0.05;


%% new order
load('E:\DataProcessing\Label_and_area.mat');

select_area = 'Small_area';
chn_area_labels = fieldnames(eval(select_area));

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    
    %% load data
    load(strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Speaker-listenerEEG\5-logistic regression\area\individual result\',...
        band_file_name,'\Speaker ListenerEEG Logstic Regresssion r^2 Result-total-',band_file_name,'-total-Small_area.mat'));
    
    
    for chn_area_select = 1 : length(chn_area_labels)
        disp(chn_area_labels{chn_area_select});
        speaker_chn = eval(strcat(select_area,'.',chn_area_labels{chn_area_select}));
        mkdir(chn_area_labels{chn_area_select});
        cd(chn_area_labels{chn_area_select});
        
        
        %% total std
        R_squared_mat = squeeze(R_squared_mat_speaker(chn_area_select,:,:));
        
        temp_std = std(R_squared_mat');
        
        data_Rsquared_peak_index = R_squared_mat> mean(R_squared_mat,2) + 1 * temp_std';
        data_Rsqueared_peak_data =  data_Rsquared_peak_index .* R_squared_mat;
        
        %% create figure
        
        createfigure_timelag_new(data_Rsqueared_peak_data);
        title_name = strcat('Speaker ListenerEEG Logstic Regresssion r^2 Result-',band_file_name,'-',chn_area_labels{chn_area_select});
        title(title_name);
        
        saveas(gcf,strcat(title_name,'.fig'));
        saveas(gcf,strcat(title_name,'.jpg'));
        close
        %
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
                file_name = strcat('listener10',num2str(listener_select));
            else
                file_name = strcat('listener1',num2str(listener_select));
            end
            
            %         mkdir(file_name);
            %         cd(file_name);
            disp(file_name);
            
            %% before 0 ms
            if data_max_value_precede(listener_select,1) ~=0
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
                
                %% after 0 ms
                
                if data_max_value_follow(listener_select,1) ~=0
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
        
        % file
        p = pwd;
        cd(p(1:end-(length(chn_area_labels{chn_area_select})+1)));
        
    end
    %% file
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end