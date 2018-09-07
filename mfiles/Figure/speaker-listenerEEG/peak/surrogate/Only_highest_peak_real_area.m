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

%% surrogate initial

Rsquared_peak_precede = zeros(length(chn_area_labels),listener_num);
Rsquared_peak_follow = zeros(length(chn_area_labels),listener_num);

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    for chn_area_select = 1 : length(chn_area_labels)
        disp(chn_area_labels{chn_area_select});
        speaker_chn = eval(strcat(select_area,'.',chn_area_labels{chn_area_select}));
        %             mkdir(chn_area_labels{chn_area_select});
        %             cd(chn_area_labels{chn_area_select});
        %% load data
        load(strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Speaker-listenerEEG\5-logistic regression\area\individual result\',...
            band_file_name,'\Speaker ListenerEEG Logstic Regresssion r^2 Result-total-',band_file_name,'-total-Small_area.mat'));
        
        R_squared_mat = squeeze(R_squared_mat_speaker(chn_area_select,:,:));
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
        
        %         [~,sort_earliest_peak] = sort(data_max_value_precede(:,1));
        
        %% logistic Regression
        Rsquared_peak_precede(chn_area_select,:) = data_max_value_precede(:,1); % before/after/all
        Rsquared_peak_follow(chn_area_select,:) = data_max_value_follow(:,1);
        
        %
        % file
        %             p = pwd;
        %             cd(p(1:end-(length(chn_area_labels{chn_area_select})+1)));
        
        
    end
    
    %%  save data
    
    save_name = strcat('Rsquared-peak-',band_file_name);
    save(strcat(save_name,'.mat'),'Rsquared_peak_precede','Rsquared_peak_follow');
    
    %% histogram
    set(gcf,'outerposition',get(0,'screensize'));
    subplot(121);
    histogram(Rsquared_peak_precede,'Normalization','probability');
    title(strcat('precede-',band_file_name));
    xlabel('R^2');
    ylabel('Probability');
    
    
    subplot(122);
    histogram(Rsquared_peak_precede,'Normalization','probability');
    title(strcat('precede-',band_file_name));
    xlabel('R^2');
    ylabel('Probability');
    
    suptitle(save_name);
    
    saveas(gcf,strcat(save_name,'.jpg'));
    saveas(gcf,strcat(save_name,'.fig'));
    
    close
    
    %% file
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end