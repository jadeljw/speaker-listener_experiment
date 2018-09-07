% plot bar plot for every area in surrogate data


%% initial
band_name = {'delta','theta','alpha','beta'};

%% area name
load('E:\DataProcessing\Label_and_area.mat');

select_area = 'Small_area';
chn_area_labels = fieldnames(eval(select_area));


for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    
    %% load data
    load(strcat('E:\DataProcessing\speaker-listener_experiment\Surrogate\4-peak\10 times surrogate\',band_file_name,'\Rsquared-peak-',band_file_name,'.mat'));
    
    %% plot
    set(gcf,'outerposition',get(0,'screensize'));
    subplot(121);
    %     bar(squeeze(mean(mean(Surrogate_Rsquared_peak_precede,1),3)));
    %         bar(squeeze(mean(Surrogate_Rsquared_peak_precede,1)));
    boxplot(squeeze(mean(Surrogate_Rsquared_peak_precede,1))');
    title('precede');
    xticklabels(chn_area_labels);
    
    
    subplot(122);
    %     bar(squeeze(mean(mean(Surrogate_Rsquared_peak_follow,1),3)));
    %     bar(squeeze(mean(Surrogate_Rsquared_peak_follow,1)));
    boxplot(squeeze(mean(Surrogate_Rsquared_peak_follow,1))');
    title('follow');
    xticklabels(chn_area_labels);
    
    save_name = strcat('Rsquared-peak-surrogate-trial-',band_file_name);
    suptitle(save_name);
    
    saveas(gcf,strcat(save_name,'.jpg'));
    saveas(gcf,strcat(save_name,'.fig'));
    close
    
    %% file
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
    
end