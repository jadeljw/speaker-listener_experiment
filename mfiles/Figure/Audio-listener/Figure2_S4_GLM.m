%% Behavioral Result

% LJW
% 2018.5.16
% calculating the correlation between R^2 and behavioral result
mkdir('GLM');
cd('GLM');

%% load behavioral result
load('E:\DataProcessing\speaker-listener_experiment\Behavioral Result\Behavioral_result_new.mat');
Behavioral_result_label = fieldnames(Behavioral_result);

%% initial
band_name =  {'alpha', 'alpha_hilbert', 'beta', 'beta_hilbert', 'broadband',...
    'delta', 'delta_hilbert', 'theta', 'theta_hilbert'};

listener_num = 20;
story_num = 28;
r_num = 4;
% listener_select_index  = [1:2 4:9 11:16 18:20];
listener_select_index  = 1:20;
%% range
% range_for_band = [0.1 0.11 0.11 0.13]; % 99%
% range_for_band = [0.09 0.08 0.09 0.09]; % 95%
% range_for_band = [0.08 0.07 0.08 0.08]; % 90%
% range_for_band = [0.07 0.07 0.07 0.07]; % surrogate

%% timelag
Fs = 64;
% timelag = -250:500/32:500;
timelag = -500:(1000/Fs):500;
label_select = 1 : round(length(timelag)/8) :length(timelag);

%% label
load('E:\DataProcessing\Label_and_area.mat');

select_area = 'Small_area';
chn_area_labels = fieldnames(eval(select_area));




for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    disp(band_file_name);
    mkdir(band_file_name);
    cd(band_file_name);
    
    %% load raw r value
    %     load(strcat('E:\DataProcessing\speaker-listener_experiment\Logistic Regression\Speaker ListenerEEG zscore attend\',band_file_name,'\Correlation_mat.mat'));
    
    %   data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\0-original r value\Speaker-listenerEEG\raw r value\',...
%                         band_file_name,'\',file_name,'\',chn_area_labels{chn_area_select},'\');
    load(strcat('E:\DataProcessing\speaker-listener_experiment\Figure\0-raw r value mat\Audio-listenerEEG\',band_file_name,'\Correlation_mat.mat'));
    raw_r_label = fieldnames(Correlation_mat);


    
    %% get index
    %     [x_index_total,y_index_total]=find(R_squared_mat_speaker>range_for_band(band_select));
    x_index_total = chn_area_labels;
    y_index_total = 1:length(timelag);
    
    %% intial mat
    for i = 1: length(Behavioral_result_label)
        temp_name_R = strcat('GLM_Rsquared_mat.',Behavioral_result_label{i});
        eval(strcat(temp_name_R,'=zeros(1,length(timelag));'));
        
        temp_name_p = strcat('GLM_Rsquared_mat_estimate.',Behavioral_result_label{i});
        eval(strcat(temp_name_p,'=zeros(1,length(timelag),length(raw_r_label)+1);'));
    end
    
    
    %% GLM
    
    for i = 1: length(Behavioral_result_label)
%         mkdir(Behavioral_result_label{i});
%         cd(Behavioral_result_label{i});
        disp(Behavioral_result_label{i});
        
%         for x_ind = 1 : length(chn_area_labels)
            % combine r value
            for y_ind = 1:length(timelag)
                
                r_value_mat_GLM = zeros(length(listener_select_index),r_num);
                
                for raw_r_select  = 1 : length(raw_r_label)
                    r_mat_data = eval(strcat('mean(Correlation_mat.',raw_r_label{raw_r_select},'(listener_select_index,:,y_ind),2)'));
                    r_value_mat_GLM(:,raw_r_select) = r_mat_data;
                end
                
                
                % Behavioral Result
                
                
                % temp name
                r_mat_temp_name = strcat('GLM_Rsquared_mat.',Behavioral_result_label{i});
                p_mat_temp_name = strcat('GLM_Rsquared_mat_estimate.',Behavioral_result_label{i});
                data_temp_name = strcat('Behavioral_result.',Behavioral_result_label{i});
                
                % GLM
                glm = fitglm(r_value_mat_GLM,eval(strcat(data_temp_name,'(listener_select_index)')),'distr','Normal');
                
                % record into mat
                % r squared
                formula_left = strcat('GLM_Rsquared_mat.',Behavioral_result_label{i},'(1,y_ind)');
                eval(strcat(formula_left,'= glm.Rsquared.Adjusted;'));
                
%                 if glm.Rsquared.Adjusted > 0.4
%                     
%                     figure;set(gcf,'outerposition',get(0,'screensize'));
%                     % estimate
%                     subplot(211);
%                     imagesc(glm.Coefficients.Estimate(2:end)');colorbar;
%                     title('Estimate');
%                     xticks(1:(length(raw_r_label)));
%                     %                 xticklabels({'Attend-A','Attend-B','Unattend-A','Unattend-B'});
%                     xticklabels(raw_r_label);
%                     ylabel(Behavioral_result_label{i});
%                     
%                     % p value
%                     subplot(212);
%                     imagesc(-log10(glm.Coefficients.pValue(2:end)'));colorbar;
%                     xticks(1:(length(raw_r_label)));
%                     %                 xticklabels({'Attend-A','Attend-B','Unattend-A','Unattend-B'});
%                     xticklabels(raw_r_label);
%                     ylabel(Behavioral_result_label{i});
%                     caxis([0 2]);
%                     title('-log10 pValue');
%                     
%                     suptitle_name = strcat(chn_area_labels{x_ind},' timelag',num2str(timelag(y_ind)),'ms r^2=',num2str(glm.Rsquared.Adjusted));
%                     suptitle(suptitle_name);
%                     data_name = strcat(chn_area_labels{x_ind},' timelag',num2str(timelag(y_ind)),'ms.jpg');
%                     saveas(gcf,data_name);
%                     close
%                 end
                
                % estimate
                formula_left = strcat('GLM_Rsquared_mat_estimate.',Behavioral_result_label{i},'(1,y_ind,:)');
                eval(strcat(formula_left,'= glm.Coefficients.Estimate;'));
                
                
                
                disp('********************');
                disp(strcat('Timelag:',num2str(timelag(y_ind)),'ms'));
                disp(strcat('R squared:',num2str(glm.Rsquared.Adjusted)));
    
            end
            

            
%         end
%         p = pwd;
%         cd(p(1:end-(length(Behavioral_result_label{i})+1)));
    end
    
    
    %% plot
    for i = 1: length(Behavioral_result_label)
        mat_temp_name = strcat('GLM_Rsquared_mat.',Behavioral_result_label{i});
        % imagesc
        set(gcf,'outerposition',get(0,'screensize'));
        %         imagesc(R_squared_mat_speaker>range_for_band(band_select));colorbar;
        plot(timelag,eval(mat_temp_name),'k','lineWidth',2);
%         xlim([-0.5 0.5]);
        %         colormap('jet');
%         xticks(label_select);
%         xticklabels(timelag(label_select));
%         yticks(1:length(chn_area_labels));
%         yticklabels(chn_area_labels);
        xlabel('timelag(ms)');
        ylabel('r^2 value');
        save_name = strcat('GLM Rsquared-',Behavioral_result_label{i},'-',band_name{band_select},'.jpg');
        title(save_name(1:end-4));
        saveas(gcf,save_name);
        close
        
        % histogram
        h = histogram(eval(mat_temp_name));
        %     h.BinLimits = [-0.1 0.18];
        ylabel('count');
        xlabel('R^2 value');
        save_name = strcat('Histogram GLM Rsquared-',Behavioral_result_label{i},'-',band_name{band_select},'.jpg');
        title(save_name(1:end-4));
        saveas(gcf,save_name);
        close;
        
        
    end
    
    % save data
    save_name = strcat('Correlation between R^2-',band_name{band_select},'-',raw_r_label{raw_r_select},'.mat');
    save(save_name,'GLM_Rsquared_mat','GLM_Rsquared_mat_estimate');
    
    
    
    
    %         p = pwd;
    %         cd(p(1:end-(length(raw_r_label{raw_r_select})+1)));
    %     end
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
    
end
