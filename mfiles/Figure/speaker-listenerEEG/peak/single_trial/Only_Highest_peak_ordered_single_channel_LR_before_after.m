%% logistic Regression plot
band_name = {'delta','theta','alpha','beta'};
% band_name = {'theta','alpha'};

%% initial
load('E:\DataProcessing\chn_re_index.mat');
chn_re_index = chn_re_index(1:64);

listener_chn= [1:32 34:42 44:59 61:63];
speaker_chn_original= [1:32 34:42 44:59 61:63];
speaker_chn_select = [1:32 34:42 44:59 61:63];

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
    %     load(strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Speaker-listenerEEG\5-logistic regression\individual result\',...
    %         band_file_name,'\Speaker ListenerEEG Logstic Regresssion r^2 Result-total-',band_file_name,'-total-Small_area.mat'));
    load(strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Speaker-listenerEEG\5-logistic regression\single channel\result\',...
        band_file_name,'\Speaker ListenerEEG Logstic Regresssion r^2 Result-',band_file_name,'.mat'));
    
    %% speaker topoplot initial
    data_precede_topo_speaker = zeros(64,1);
    data_follow_topo_speaker = zeros(64,1);
    
    for chn_select = 1 : length(speaker_chn_original)
        
        speaker_chn_index = find(speaker_chn_select(chn_select)==speaker_chn_original);
        speaker_chn = speaker_chn_original(speaker_chn_index);
        disp(label66{speaker_chn});
        mkdir(label66{speaker_chn});
        cd(label66{speaker_chn});
        
        %% data
        R_squared_mat = squeeze(R_squared_mat_speaker(speaker_chn_index,:,:));
        
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
        select_index = peak_index;
        select_data = select_index .* zscore_data;
        select_orginal_data = select_index .* R_squared_mat;
        
        %% split data
        %     split_index = round(length(timelag)/2);
        data_listener_precede_Rsquared = select_data(:,1:split_index);
        data_listener_follow_Rsquared = select_data(:,split_index+1:end);
        
        
        %% max
        [data_max_value_precede, data_max_index_precede] = sort(data_listener_precede_Rsquared,2,'descend');
        [data_max_value_follow, data_max_index_follow] = sort(data_listener_follow_Rsquared,2,'descend');
        
        data_max_select = zeros(listener_num,length(timelag));
        
        for listener_select = 1 : listener_num
            data_max_select(listener_select,data_max_index_precede(listener_select,1)) = 1;
            data_max_select(listener_select,data_max_index_follow(listener_select,1)+split_index) = 1;
        end
        
        [~,sort_largest_peak] = sort(data_max_index_precede(:,1));
        
        %% latency
        Rsquared_peak_latency(:,1) = data_max_index_precede(:,1);
        Rsquared_peak_latency(:,2) = data_max_index_follow(:,1)+split_index;
        
        
        %% zscore
        Rsquared_peak_zscore(:,1) = data_max_value_precede(:,1);
        Rsquared_peak_zscore(:,2) = data_max_value_follow(:,1);
        
        
        %% select timelag plot
        set(gcf,'outerposition',get(0,'screensize'));
        bar(sum(data_max_select));
        xticks(label_select);
        xticklabels(timelag(label_select));
        %         ylim([0 15]);
        ylabel('Count');
        xlabel('timelag(ms)');
        save_name = strcat('peak value distribution-',band_file_name,'-',label66{speaker_chn});
        title(save_name);
        
        saveas(gcf,strcat(save_name,'.jpg'));
        saveas(gcf,strcat(save_name,'.fig'));
        close
        
        %% imagesc zscore
        set(gcf,'outerposition',get(0,'screensize'));
        imagesc(zscore_data(sort_largest_peak,:));
        %         colormap(copper);
        colorbar;
        save_name = strcat('Imagesc Speaker Listener EEG after zscore R^2 Peak-',band_file_name,'-',label66{speaker_chn});
        ylabel('Listener No.');
        xlabel('timelag(ms)');
        xticks(label_select);
        xticklabels(timelag(label_select));
        title(save_name);
        
        
        saveas(gcf,strcat(save_name,'.jpg'));
        saveas(gcf,strcat(save_name,'.fig'));
        close
        
        
        %% imagesc select max data
        set(gcf,'outerposition',get(0,'screensize'));
        imagesc(data_max_select(sort_largest_peak,:));
        colormap(copper);
        colorbar;
        save_name = strcat('Selected data-',band_file_name,'-',label66{speaker_chn});
        ylabel('Listener No.');
        xlabel('timelag(ms)');
        xticks(label_select);
        xticklabels(timelag(label_select));
        title(save_name);
        
        saveas(gcf,strcat(save_name,'.jpg'));
        saveas(gcf,strcat(save_name,'.fig'));
        
        close
        
        %%  save data
        
        save_name = strcat('Rsquared_peak-',band_file_name,'-',label66{speaker_chn});
        save(save_name,'Rsquared_peak_latency','Rsquared_peak_zscore');
        %
        % file
        p = pwd;
        cd(p(1:end-(length(label66{speaker_chn})+1)));
    end
    
    %% file
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end