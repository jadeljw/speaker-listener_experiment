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
            end
        end
    end
    
    fdr_threshold = fdr(p_total, alpha_threshold);
    disp(strcat('FDR:',num2str(fdr_threshold)));
    
    %% imagesc p value
    set(gcf,'outerposition',get(0,'screensize'));
    imagesc(-log10(p_total));colorbar;
    %         caxis([-0.04 0.1]);
    colormap('jet');
    xticks(label_select);
    xticklabels(timelag(label_select));
    %         yticks(1:length(chn_area_labels));
    %         yticklabels(chn_area_labels);
    xlabel('timelag(ms)');
    ylabel('Speaker Channels');
    save_name = strcat('Imagesc-log10 ttest Result-',band_name{band_select});
    title(save_name);
    saveas(gcf,strcat(save_name,'.jpg'));
    saveas(gcf,strcat(save_name,'.fig'));
    close
    
    %% imagesc Bonferroni
    
    set(gcf,'outerposition',get(0,'screensize'));
    imagesc(-log10(p_total).*h_total);colorbar;
    %         caxis([-0.04 0.1]);
    %         colormap('jet');
    xticks(label_select);
    xticklabels(timelag(label_select));
    %         yticks(1:length(chn_area_labels));
    %         yticklabels(chn_area_labels);
    xlabel('timelag(ms)');
    ylabel('Speaker Channels');
    save_name = strcat('ttest Result-Bonferroni',num2str(Bonferroni_threshold),'-',band_name{band_select});
    title(save_name);
    saveas(gcf,strcat(save_name,'.jpg'));
    saveas(gcf,strcat(save_name,'.fig'));
    close
    
    %% imagesc FDR
    
    set(gcf,'outerposition',get(0,'screensize'));
    imagesc(p_total<fdr_threshold);colorbar;
    %         caxis([-0.04 0.1]);
    %         colormap('jet');
    xticks(label_select);
    xticklabels(timelag(label_select));
    %         yticks(1:length(chn_area_labels));
    %         yticklabels(chn_area_labels);
    xlabel('timelag(ms)');
    ylabel('Speaker Channels');
    save_name = strcat('ttest Mean Result-FDR_',num2str(fdr_threshold),'-',band_name{band_select});
    title(save_name);
    saveas(gcf,strcat(save_name,'.jpg'));
    saveas(gcf,strcat(save_name,'.fig'));
    close
    
    
    
    save(strcat('Result Mean-log10 ttest-',band_name{band_select}),'p_total','h_total','Bonferroni_threshold','fdr_threshold');
    
    
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end