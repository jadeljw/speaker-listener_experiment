%% behavioral data and R^2 value

%% load behavioral result
load('E:\DataProcessing\speaker-listener_experiment\Behavioral Result\Behavioral_result_new.mat');
Behavioral_result_label = fieldnames(Behavioral_result);

%% initial
band_name = {'alpha'};
listener_num = 20;
story_num = 28;

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    disp(band_file_name);
    mkdir(band_file_name);
    cd(band_file_name);
    
    %% load R^2 data
    load(strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Audio-listener\zscore\2-logistic regression\6.new peak\',...
        band_file_name,'\Rsquared_peak-',band_file_name,'.mat'));
    
    
    %% correlation
    for i = 1: length(Behavioral_result_label)
        Behavioral_result_select = eval(strcat('Behavioral_result.',Behavioral_result_label{i}));
        [temp_R, temp_p] = corr(Behavioral_result_select,Rsquared_peak);
        eval(strcat('Behavioral_result_corr_R.',Behavioral_result_label{i},'=temp_R;'));
        eval(strcat('Behavioral_result_corr_p.',Behavioral_result_label{i},'=temp_p;'));
        
        set(gcf,'outerposition',get(0,'screensize'));
        % plot
        subplot(121);
        bar(temp_R);
        title('Corr with R^2');
        xticklabels({'precede','follow','combine'});
        ylabel('R value');

        
        subplot(122);
        bar(-log10(temp_p));
        title('-log10(p)');
        xticklabels({'precede','follow','combine'});
        ylim([0 3]);
        ylabel('-log10');
        
        save_name = strcat(Behavioral_result_label{i},'-',band_file_name);
        suptitle(save_name);
        saveas(gcf,strcat(save_name,'.jpg'));
        saveas(gcf,strcat(save_name,'.fig'));
        
        close
    end
    
    %% save data
    save_name = strcat('Correlation between R^2 and behavioral result-',band_file_name,'.mat');
    save(save_name,'Behavioral_result_corr_R','Behavioral_result_corr_p');
    
    
    
    
    %         p = pwd;
    %         cd(p(1:end-(length(raw_r_label{raw_r_select})+1)));
    %     end
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end