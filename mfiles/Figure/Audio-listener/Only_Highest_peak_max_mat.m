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
    data_listener_precede_Rsquared = select_data(:,1:split_index);
    data_listener_follow_Rsquared = select_data(:,split_index+1:end);
    
      %% max
    [data_max_value_precede, data_max_index_precede] = sort(data_listener_precede_Rsquared,2,'descend');
    [data_max_value_follow, data_max_index_follow] = sort(data_listener_follow_Rsquared,2,'descend');
    
    %% initial
    Rsquared_peak_zscore = zeros(listener_num,2); % before/after/all
    Rsquared_peak_latency = zeros(listener_num,2); % before/after/all
    

    
    %% latency
    Rsquared_peak_latency(:,1) = data_max_index_precede(:,1);
    Rsquared_peak_latency(:,2) = data_max_index_follow(:,1)+split_index;
    
    
    %% zscore
    Rsquared_peak_zscore(:,1) = data_max_value_precede(:,1);
    Rsquared_peak_zscore(:,2) = data_max_value_follow(:,1);
    
    
    %%  save data
    
    save_name = strcat('Rsquared_peak-',band_file_name);
    save(save_name,'Rsquared_peak_latency','Rsquared_peak_zscore');
    %% file
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end