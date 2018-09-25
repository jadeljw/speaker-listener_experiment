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

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    
    %% load data
    load(strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Audio-listener\zscore\8-forward model\',...
        band_file_name,'\mTRF_Audio_listenerEEG_result-forward_timelag0ms-',band_file_name,'.mat'));
    
    
    %% plot
    for listener_select = 1 : listener_num
        listener_file_name = strcat('listener',num2str(listener_select));
        mkdir(listener_file_name);
        cd(listener_file_name);
        disp(listener_file_name);
        
        for chn_select = 1 :length(listener_chn)        
            plot(timelag,squeeze(mean(train_mTRF_attend_w_total(listener_select,chn_select,:,:),4)),'lineWidth',2);
            hold on;plot(timelag,squeeze(mean(train_mTRF_unattend_w_total(listener_select,chn_select,:,:),4)),'lineWidth',2);
            
            save_name = strcat('listener',num2str(listener_select),'-',label66{listener_chn(chn_select)});
            title(save_name);
            legend('attend','unattend');
            saveas(gcf,strcat(save_name,'.jpg'));
            saveas(gcf,strcat(save_name,'.fig'));
            close;
        end
        
         
    p = pwd;
    cd(p(1:end-(length(listener_file_name)+1)));
    end
    
    
    
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end