% plot individual forward model

%% band name
band_name = {'delta','theta'};


%% initial
load('E:\DataProcessing\chn_re_index.mat');
chn_re_index = chn_re_index(1:64);

listener_chn= [1:32 34:42 44:59 61:63];
load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';

listener_num = 20;
Fs = 64;
timelag = -500 : 1000/Fs : 500;
label_select = 1 : round(length(timelag)/8) :length(timelag);
alpha_threshold = 0.05;
%% split_point
split_index = 33;

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    disp(band_file_name);
    
    %% initial
    p_total = zeros(length(listener_chn),length(timelag));
    h_total = zeros(length(listener_chn),length(timelag));
    Bonferroni_threshold  = alpha_threshold /  length(listener_chn) / length(timelag);
    listener_chn_sig = zeros(1,length(listener_chn));
    
    %% load data
    load(strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Audio-listener\zscore\8-forward model\0-raw data and GFP\',...
        band_file_name,'\mTRF_Audio_listenerEEG_result-forward_timelag0ms-',band_file_name,'.mat'));
    
    train_mTRF_attend_w_mean = squeeze(mean(train_mTRF_attend_w_total,4));
    train_mTRF_unattend_w_mean = squeeze(mean(train_mTRF_unattend_w_total,4));
    
    %% mean plot
    for chn_select = 1 :length(listener_chn)
        
        for time_point = 1 : length(timelag)
            [h,p] = ttest(train_mTRF_attend_w_mean(chn_select,time_point,:),train_mTRF_unattend_w_mean(chn_select,time_point,:),...
                'alpha',Bonferroni_threshold);
            h_total(chn_select,time_point) = h;
            p_total(chn_select,time_point) = p;
            
            if p < Bonferroni_threshold
                disp(label66{listener_chn(chn_select)});
                disp(strcat(num2str(timelag(time_point)),'ms'));
                listener_chn_sig(chn_select) = 1;
                
            end
        end
    end
    
    
    %% peak index
    peak_index = zeros(listener_num,length(listener_chn),length(timelag));
    for chn_select = 1 :  length(listener_chn)
        if listener_chn_sig > 0
            for listener_select  = 1 : listener_num
                
                for timepoint = 1 : length(timelag)
                    
                    if train_mTRF_attend_w_mean(listener_select,chn_select,timepoint) >= train_mTRF_attend_w_mean(listener_select,chn_select,timepoint-1) ...
                            && train_mTRF_attend_w_mean(listener_select,chn_select,timepoint) >= train_mTRF_attend_w_mean(listener_select,chn_select,timepoint+1)
                        peak_index(listener_select,chn_select,timepoint) = 1;
                    end
                end
            end
        end
    end
    
    %% split data
    %     split_index = round(length(timelag)/2);
    data_listener_precede_Rsquared = select_orginal_data(:,1:split_index);
    data_listener_follow_Rsquared = select_orginal_data(:,split_index+1:end);
    
    %% max
    [data_max_value_precede, data_max_index_precede] = sort(data_listener_precede_Rsquared,2,'descend');
    [data_max_value_follow, data_max_index_follow] = sort(data_listener_follow_Rsquared,2,'descend');
    
    
    %% latency
    Rsquared_peak_latency(:,1) = data_max_index_precede(:,1);
    Rsquared_peak_latency(:,2) = data_max_index_follow(:,1)+split_index;
    
    
    %% file
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end