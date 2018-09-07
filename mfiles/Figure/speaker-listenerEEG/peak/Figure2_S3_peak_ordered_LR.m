%% logistic Regression plot
band_name = {'delta','theta','alpha'};
% band_name = {'theta'};
%% timelag

Fs = 64;
timelag = -500 : 1000/Fs : 500;
label_select = 1 : round(length(timelag)/8) :length(timelag);
listener_num = 20;
sig_thr = 0.05;
STD_para = 1;

%% new order
load('E:\DataProcessing\Label_and_area.mat');

select_area = 'Small_area';
chn_area_labels = fieldnames(eval(select_area));


for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    
    
    %% load data
    load(strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Speaker-listenerEEG\5-logistic regression\individual result\',...
        band_file_name,'\Speaker ListenerEEG Logstic Regresssion r^2 Result-total-',band_file_name,'-total-Small_area.mat'));
    
    for chn_area_select = 1 : length(chn_area_labels)
        disp(chn_area_labels{chn_area_select});
        speaker_chn = eval(strcat(select_area,'.',chn_area_labels{chn_area_select}));
        mkdir(chn_area_labels{chn_area_select});
        cd(chn_area_labels{chn_area_select});
        
        %% total std
        R_squared_mat = squeeze(R_squared_mat_speaker(chn_area_select,:,:));
        temp_std = std(R_squared_mat');
        
        data_Rsquared_std_index = R_squared_mat> mean(R_squared_mat,2) + STD_para * temp_std';
        
        
        %% zscore
        zscore_data_temp = zscore(R_squared_mat');
        zscore_data = zscore_data_temp';
        
        %     %% create figure
        %
        %     createfigure_timelag_new(data_Rsqueared_peak_data);
        %     title_name = strcat('Speaker ListenerEEG Logstic Regresssion r^2 Result-',band_file_name);
        %     title(title_name);
        %
        %     saveas(gcf,strcat(title_name,'.fig'));
        %     saveas(gcf,strcat(title_name,'.jpg'));
        %     close
        
        
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
        select_index = peak_index .* data_Rsquared_std_index;
        select_data = select_index .* zscore_data;
        select_orginal_data = select_index .* R_squared_mat;
        
        %% earliest selected peak index
        earliest_peak_index = zeros(listener_num,1);
        
        for listener_select  = 1 : listener_num
            for timepoint = 2 : size(R_squared_mat,2)-1
                
                if select_index(listener_select,timepoint) == 1
                    earliest_peak_index(listener_select,1) = timepoint;
                    break;
                end
            end
        end
        
        [~,sort_earliest_peak] = sort(earliest_peak_index);
        
        
        %% imagesc
        set(gcf,'outerposition',get(0,'screensize'));
        imagesc(select_data(sort_earliest_peak,:));colormap(copper);colorbar;
        save_name = strcat('Imagesc Speaker Listener after zscore R^2 Peak-',band_file_name,'-',chn_area_labels{chn_area_select});
        ylabel('Listener No.');
        xlabel('timelag(ms)');
        xticks(label_select);
        xticklabels(timelag(label_select));
        title(save_name);
        
        
        saveas(gcf,strcat(save_name,'.jpg'));
        saveas(gcf,strcat(save_name,'.fig'));
        close
        
        
        
        %% peak timelag plot
        set(gcf,'outerposition',get(0,'screensize'));
        bar(sum(select_index));
        xticks(label_select);
        xticklabels(timelag(label_select));
        %         ylim([0 15]);
        ylabel('Count');
        xlabel('timelag(ms)');
        save_name = strcat('peak value distribution-',band_file_name,'-',chn_area_labels{chn_area_select});
        title(save_name);
        
        saveas(gcf,strcat(save_name,'.jpg'));
        saveas(gcf,strcat(save_name,'.fig'));
        close
        
        
        %% histogram of the orginital r value
        set(gcf,'outerposition',get(0,'screensize'));
        histogram(select_orginal_data(select_orginal_data~=0),'BinWidth',0.1);
        %         ylim([0 80]);
        save_name = strcat('Histogram Speaker Listener R^2 Peak-',band_file_name,'-',chn_area_labels{chn_area_select});
        ylabel('Count');
        xlabel('R^2 value');
        title(save_name);
        
        saveas(gcf,strcat(save_name,'.jpg'));
        saveas(gcf,strcat(save_name,'.fig'));
        
        close
        
        
        %% boxplot
        set(gcf,'outerposition',get(0,'screensize'));
        boxplot(select_orginal_data(select_orginal_data~=0));
        
        save_name = strcat('boxplot Speaker Listener R^2 Peak-',band_file_name,'-',chn_area_labels{chn_area_select});
        ylabel('R^2 value');
        xticklabels(band_file_name);
        title(save_name);
        
        saveas(gcf,strcat(save_name,'.jpg'));
        saveas(gcf,strcat(save_name,'.fig'));
        
        close
        %% plot
        %     figure1 = figure;
        %     set(gcf,'outerposition',get(0,'screensize'));
        %     set(gcf,'color','white');
        %
        %     for listener_select = 1 : listener_num
        %
        %
        %         subplot(listener_num,1,listener_select);
        %         plot(timelag,select_data(listener_select,:),'k','lineWidth',2);
        %         set(gca,'XColor',[1 1 1],'YColor',[1 1 1]);
        %
        %     end
        %
        %
        %
        %     % 创建 xlabel
        %     xlabel({'timelag(ms)'});
        %
        %     % 创建 ylabel
        %     ylabel({'a.u.'});
        %
        %     save_name = strcat('Speaker Listener R^2 Peak-',band_file_name);
        %     suptitle(save_name);
        %     pause
        %     saveas(gcf,strcat(save_name,'.jpg'));
        %     saveas(gcf,strcat(save_name,'.fig'));
        
        % file
        p = pwd;
        cd(p(1:end-(length(chn_area_labels{chn_area_select})+1)));
    end
    
    %% file
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end