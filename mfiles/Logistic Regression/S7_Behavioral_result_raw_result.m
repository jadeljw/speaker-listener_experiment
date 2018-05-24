%% Behavioral Result

% LJW
% 2018.5.16
% calculating the correlation between R^2 and behavioral result

%% load behavioral result
load('E:\DataProcessing\speaker-listener_experiment\Behavioral Result\Behavioral_result_new.mat');
Behavioral_result_label = fieldnames(Behavioral_result);

%% initial
band_name = {'delta','theta','alpha'};
listener_num = 20;

%% range
% range_for_band = [0.1 0.11 0.11 0.13]; % 99%
range_for_band = [0.09 0.08 0.09 0.09]; % 95%
% range_for_band = [0.08 0.07 0.08 0.08]; % 90%

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
    
    %% load data
    load(strcat('E:\DataProcessing\speaker-listener_experiment\Logistic Regression\1-large r value\zscore\95%\',...
        band_file_name,'\total\Audio ListenerEEG Logstic Regresssion r^2 Result-total-',...
        band_file_name,'-total-Small_area.mat'));
    
    %% load raw r value
    load(strcat('E:\DataProcessing\speaker-listener_experiment\Logistic Regression\Speaker ListenerEEG zscore attend\',band_file_name,'\Correlation_mat.mat'));
    raw_r_label = fieldnames(Correlation_mat);
    
    %% get index
    [x_index_total,y_index_total]=find(R_squared_mat_speaker>range_for_band(band_select));
    
    
    %% raw value circle
    for raw_r_select  = 1 : length(raw_r_label)
        disp(raw_r_label{raw_r_select});
        mkdir(raw_r_label{raw_r_select});
        cd(raw_r_label{raw_r_select});
        
        %% intial mat
        for i = 1: length(Behavioral_result_label)
            temp_name_R = strcat('Correlation_r_mat.',Behavioral_result_label{i});
            eval(strcat(temp_name_R,'=zeros(length(chn_area_labels),length(timelag));'));
            
            temp_name_p = strcat('Correlation_p_mat.',Behavioral_result_label{i});
            eval(strcat(temp_name_p,'=ones(length(chn_area_labels),length(timelag));'));
        end
        
        
        %% corrlation
        mkdir('Scatter plot');
        cd('Scatter plot')
        
        for jj = 1 : length(x_index_total)
            
            
            for i = 1: length(Behavioral_result_label)
                % file
                mkdir(Behavioral_result_label{i});
                cd(Behavioral_result_label{i});
                
                % initial
                r_mat_temp_name = strcat('Correlation_r_mat.',Behavioral_result_label{i});
                p_mat_temp_name = strcat('Correlation_p_mat.',Behavioral_result_label{i});
                data_temp_name = strcat('Behavioral_result.',Behavioral_result_label{i});
                
                raw_r_value_temp = strcat('mean(Correlation_mat.',raw_r_label{raw_r_select},'(x_index_total(jj),:,:,y_index_total(jj)),3)');
                
                formula_left = strcat('[',r_mat_temp_name,'(x_index_total(jj),y_index_total(jj))',',',p_mat_temp_name,'(x_index_total(jj),y_index_total(jj))]');
                formula_right = strcat('corr(permute(',raw_r_value_temp,',[2 1]),',data_temp_name,');');
                
                eval(strcat(formula_left,'=',formula_right));
                
                % scatter plot
                p_temp_name = strcat(p_mat_temp_name,'(x_index_total(jj),y_index_total(jj))');
                if eval(p_temp_name)<0.05
                    scatter(R_squared_mat_speaker_total(:,x_index_total(jj),y_index_total(jj)),eval(data_temp_name),'r','linewidth',2);
                    xlabel('R squared');
                    ylabel(Behavioral_result_label{i});
                    
                    correlation_r_value =  eval(strcat(r_mat_temp_name,'(x_index_total(jj),y_index_total(jj))'));
                    
                    correlation_p_value =  eval(strcat(p_mat_temp_name,'(x_index_total(jj),y_index_total(jj))'));
                    
                    
                    title(strcat(chn_area_labels{x_index_total(jj)},num2str(timelag(y_index_total(jj))),'ms r=',num2str(correlation_r_value),' p=',num2str(correlation_p_value)));
                    
                    save_name = strcat(chn_area_labels{x_index_total(jj)},num2str(timelag(y_index_total(jj))),'ms.jpg');
                    saveas(gcf,save_name);
                    close
                end
                
                p = pwd;
                cd(p(1:end-(length(Behavioral_result_label{i})+1)));
            end
            
        end
        
        p = pwd;
        cd(p(1:end-(length('Scatter plot')+1)));
        
        %% plot
        for i = 1: length(Behavioral_result_label)
            mat_temp_name = strcat('Correlation_r_mat.',Behavioral_result_label{i});
            % imagesc
            set(gcf,'outerposition',get(0,'screensize'));
            %         imagesc(R_squared_mat_speaker>range_for_band(band_select));colorbar;
            imagesc(eval(mat_temp_name));colorbar;
            caxis([-0.5 0.5]);
            %         colormap('jet');
            xticks(label_select);
            xticklabels(timelag(label_select));
            yticks(1:length(chn_area_labels));
            yticklabels(chn_area_labels);
            xlabel('timelag(ms)');
            ylabel('Speaker Channels');
            save_name = strcat('R value between R^2-',Behavioral_result_label{i},'-',band_name{band_select},'-',raw_r_label{raw_r_select},'.jpg');
            title(save_name(1:end-4));
            saveas(gcf,save_name);
            close
            
            mat_temp_name = strcat('Correlation_p_mat.',Behavioral_result_label{i});
            
            % imagesc
            set(gcf,'outerposition',get(0,'screensize'));
            %         imagesc(R_squared_mat_speaker>range_for_band(band_select));colorbar;
            imagesc(-log10(eval(mat_temp_name)));colorbar;
            caxis([0 1.2]);
            %         colormap('jet');
            xticks(label_select);
            xticklabels(timelag(label_select));
            yticks(1:length(chn_area_labels));
            yticklabels(chn_area_labels);
            xlabel('timelag(ms)');
            ylabel('Speaker Channels');
            save_name = strcat('P value between R^2-',Behavioral_result_label{i},'-',band_name{band_select},'-',raw_r_label{raw_r_select},'.jpg');
            title(save_name(1:end-4));
            saveas(gcf,save_name);
            close
            
        end
        
        % save data
        save_name = strcat('Correlation between R^2-',band_name{band_select},'-',raw_r_label{raw_r_select},'.mat');
        save(save_name,'Correlation_r_mat','Correlation_p_mat');
        
        
        p = pwd;
        cd(p(1:end-(length(raw_r_label{raw_r_select})+1)));
    end
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
    
end
