%% plot histogram and set the threshold
band_name = {'delta','theta','alpha','beta'};
threshold = [0.95 0.99 0.999 0.9999 0.99999];

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    
    %% load real data
    load(strcat('E:\DataProcessing\speaker-listener_experiment\Surrogate\4-peak\real single channel\',band_file_name,'\Rsquared-peak-',band_file_name,'.mat'));
    
    %% load surrogate data
    load(strcat('E:\DataProcessing\speaker-listener_experiment\Surrogate\4-peak\10 times surrogate\',band_file_name,'\Rsquared-peak-',band_file_name,'.mat'));
    
    %% plot histogram
    set(gcf,'outerposition',get(0,'screensize'));
    subplot(121);
    histogram(Rsquared_peak_precede,'Normalization','probability');hold on;histogram(Surrogate_Rsquared_peak_precede,'Normalization','probability');
    title(strcat('precede-',band_file_name));
    xlabel('R^2');
    ylabel('Probability');
    legend('Real','Surrogate');
    
    
    subplot(122);
    histogram(Rsquared_peak_follow,'Normalization','probability');hold on;histogram(Surrogate_Rsquared_peak_follow,'Normalization','probability');
    title(strcat('precede-',band_file_name));
    xlabel('R^2');
    ylabel('Probability');
    legend('Real','Surrogate');
    
    save_name = strcat('Rsquared-peak-',band_file_name,'-Surrogate vs. Real');
    
    suptitle(save_name);
    
    saveas(gcf,strcat(save_name,'.jpg'));
    saveas(gcf,strcat(save_name,'.fig'));
    
    close
    
    %% record surrogate threshold
    temp_mat_precede = sort(Surrogate_Rsquared_peak_precede(:));
    threshold_index_precede = round(length(temp_mat_precede).*threshold);
    threshold_precede_data = temp_mat_precede(threshold_index_precede);
    
    
    temp_mat_follow = sort(Surrogate_Rsquared_peak_precede(:));
    threshold_index_follow  = round(length(temp_mat_follow).*threshold);
    threshold_follow_data = temp_mat_precede(threshold_index_follow);
    
    save(strcat(save_name,'.mat'),'threshold_precede_data','threshold_follow_data');
    
    
    %% file
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end