%% logistic Regression plot
band_name = {'delta','theta','alpha','beta'};
% band_name = {'theta','alpha'};

%% initial
load('E:\DataProcessing\chn_re_index.mat');
chn_re_index = chn_re_index(1:64);

listener_chn= [1:32 34:42 44:59 61:63];
speaker_chn_original = [1:32 34:42 44:59 61:63];
speaker_chn_select = [7:13 16:22 25:31 35:41 45:51 54:58 61:63];
% speaker_chn_select = [1:32 34:42 44:59 61:63];
% speaker_chn_total = [9:11 18:20 27:29];
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
    
    %% load threshold
    threshold_select = 2;
    load(strcat('E:\DataProcessing\speaker-listener_experiment\Surrogate\4-peak\threshold\average\',band_file_name,'\Rsquared-peak-',band_file_name,'-Surrogate vs. Real.mat'));
    threshold_temp_precede = threshold_precede_data(threshold_select);
    threshold_temp_follow = threshold_follow_data(threshold_select);
    
    %% load data
    %     load(strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Speaker-listenerEEG\5-logistic regression\individual result\',...
    %         band_file_name,'\Speaker ListenerEEG Logstic Regresssion r^2 Result-total-',band_file_name,'-total-Small_area.mat'));
    load(strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Speaker-listenerEEG\5-logistic regression\single channel\result\',...
        band_file_name,'\Speaker ListenerEEG Logstic Regresssion r^2 Result-',band_file_name,'.mat'));
    
    %% speaker topoplot initial
    data_precede_topo_speaker = zeros(64,1);
    data_follow_topo_speaker = zeros(64,1);
    
    for chn_select = 1 : length(speaker_chn_select)
        
        speaker_chn_index = find(speaker_chn_select(chn_select)==speaker_chn_original);
        speaker_chn = speaker_chn_original(speaker_chn_index);
%         disp(label66{speaker_chn});
        %         mkdir(label66{speaker_chn});
        %         cd(label66{speaker_chn});
        
        %% data
        R_squared_mat = squeeze(R_squared_mat_speaker(speaker_chn_index,:,:)); % 60 channels only
        
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
        data_listener_precede_Rsquared = select_orginal_data(:,1:split_index);
        data_listener_follow_Rsquared = select_orginal_data(:,split_index+1:end);
        
        
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
        
        
        %         temp_R_squared = mean(Rsquared_peak);
        data_precede_topo_speaker(speaker_chn,:) = mean(data_max_value_precede(:,1));
        data_follow_topo_speaker(speaker_chn,:) = mean(data_max_value_follow(:,1));
        
        %         %%  save data
        %         save_name = strcat('Rsquared_peak-',band_file_name,'-',label66{speaker_chn});
        %         save(save_name,'Rsquared_peak_latency','Rsquared_peak_zscore');
        %         %
        %         % file
        %         p = pwd;
        %         cd(p(1:end-(length(label66{speaker_chn})+1)));
        
    end
    
    %% topoplot
    set(gcf,'outerposition',get(0,'screensize'));
    colormap(jet);
    subplot(121);
    plot_index = data_precede_topo_speaker>threshold_temp_precede;
    disp('precede');
    disp(label66(plot_index));

    U_topoplot(data_precede_topo_speaker.*plot_index,layout,label66(1:64));
    
    title('precede');
    colorbar('South');
    
    subplot(122);
    %     U_topoplot(data_follow_topo_speaker(speaker_chn_total)>threshold_temp_follow,layout,label66(speaker_chn_total));
    plot_index = data_follow_topo_speaker>threshold_temp_precede;
    disp('follow');
    disp(label66(plot_index));
    U_topoplot(data_follow_topo_speaker.*plot_index,layout,label66(1:64));
    title('follow');
    colorbar('South');

    
    
    save_name = strcat('Highest R^2 value-',band_file_name);
    suptitle(save_name);
    saveas(gcf,strcat(save_name,'.jpg'));
    saveas(gcf,strcat(save_name,'.fig'));
    close
    
    %%  save data
    save_name = strcat('Rsquared_peak-',band_file_name);
    save(save_name,'data_precede_topo_speaker','data_follow_topo_speaker');
    %
    
    
    
    %% file
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end