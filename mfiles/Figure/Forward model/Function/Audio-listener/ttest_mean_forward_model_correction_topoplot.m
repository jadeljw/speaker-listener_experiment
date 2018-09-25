% plot individual forward model

%% band name
band_name = {'delta','theta','alpha','beta'};


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
    
    %% plot
    for chn_select = 1 :length(listener_chn)
        
        for time_point = 1 : length(timelag)
            [h,p] = ttest(train_mTRF_attend_w_mean(:,chn_select,time_point),train_mTRF_unattend_w_mean(:,chn_select,time_point),...
                'alpha',Bonferroni_threshold);
            h_total(chn_select,time_point) = h;
            p_total(chn_select,time_point) = p;
            
            if p < Bonferroni_threshold
                disp(label66{listener_chn(chn_select)});
                disp(strcat(num2str(timelag(time_point)),'ms'));
                listener_chn_sig(chn_select) = listener_chn_sig(chn_select)+1;
                
            end
        end
    end
    
    %% topoplot
    U_topoplot(listener_chn_sig',layout,label66(listener_chn));colorbar('SouthOutside');
    title(strcat(band_file_name,'-significant Channels'));
    saveas(gcf,strcat(band_file_name,'-significant Channels.jpg'));
    saveas(gcf,strcat(band_file_name,'-significant Channels.fig'));
    close;
    
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end