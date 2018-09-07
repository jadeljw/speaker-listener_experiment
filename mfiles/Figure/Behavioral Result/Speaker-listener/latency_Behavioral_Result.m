%% behavioral data and R^2 value

%% load behavioral result
load('E:\DataProcessing\speaker-listener_experiment\Behavioral Result\Behavioral_result_new.mat');
Behavioral_result_label = fieldnames(Behavioral_result);

%% initial
band_name = {'alpha','delta','theta'};
listener_num = 20;
story_num = 28;

%% new order
load('E:\DataProcessing\Label_and_area.mat');

select_area = 'Small_area';
chn_area_labels = fieldnames(eval(select_area));


for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    disp(band_file_name);
    mkdir(band_file_name);
    cd(band_file_name);
    
    for chn_area_select = 1 : length(chn_area_labels)
        disp(chn_area_labels{chn_area_select});
        speaker_chn = eval(strcat(select_area,'.',chn_area_labels{chn_area_select}));
        mkdir(chn_area_labels{chn_area_select});
        cd(chn_area_labels{chn_area_select});
        
        
        %% load R^2 data
        load(strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Speaker-listenerEEG\5-logistic regression\latency and zscore\',...
            band_file_name,'\Rsquared_peak-',band_file_name,'-',chn_area_labels{chn_area_select},'.mat'));
        
        
        %% correlation
        for i = 1: length(Behavioral_result_label)
            Behavioral_result_select = eval(strcat('Behavioral_result.',Behavioral_result_label{i}));
            [temp_R, temp_p] = corr(Behavioral_result_select, Rsquared_peak_latency);
            eval(strcat('Behavioral_result_corr_R.',Behavioral_result_label{i},'=temp_R;'));
            eval(strcat('Behavioral_result_corr_p.',Behavioral_result_label{i},'=temp_p;'));
            
            set(gcf,'outerposition',get(0,'screensize'));
            % plot
            subplot(121);
            bar(temp_R);
            title('Corr with latency');
            xticklabels({'precede','follow','combine'});
            ylabel('R value');
            
            
            subplot(122);
            bar(-log10(temp_p));
            title('-log10(p)');
            xticklabels({'precede','follow','combine'});
            ylim([0 3]);
            ylabel('-log10');
            
            save_name = strcat(Behavioral_result_label{i},'-',band_file_name,'-',chn_area_labels{chn_area_select});
            suptitle(save_name);
            saveas(gcf,strcat(save_name,'.jpg'));
            saveas(gcf,strcat(save_name,'.fig'));
            
            close
        end
        
        %% save data
        save_name = strcat('Correlation between latency and behavioral result-',band_file_name,'-',chn_area_labels{chn_area_select},'.mat');
        save(save_name,'Behavioral_result_corr_R','Behavioral_result_corr_p');
        
        
        %% file
        p = pwd;
        cd(p(1:end-(length(chn_area_labels{chn_area_select})+1)));
    end
    
    %         p = pwd;
    %         cd(p(1:end-(length(raw_r_label{raw_r_select})+1)));
    %     end
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end