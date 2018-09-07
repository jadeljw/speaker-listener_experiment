%% LR_Audio_ListenerEEG
% purpose: use logistic regression
% to find the relation between r value and attend target
% Attend A ->1
% Attend
% LJW

mkdir('r value');
cd('r value')


band_name = {'alpha', 'alpha_hilbert', 'beta', 'beta_hilbert', 'broadband',...
    'delta', 'delta_hilbert', 'theta', 'theta_hilbert'};

listener_num = 20;
story_num = 28;

surrogate_set = 1:8;


%% new order
load('E:\DataProcessing\Label_and_area.mat');

select_area = 'Small_area';
chn_area_labels = fieldnames(eval(select_area));
plot_area_order = [4 6 5 2 1 3 7 8 9];

%% colormap
load('E:\DataProcessing\colormap_blue_red.mat');

%% initial
load('E:\DataProcessing\chn_re_index.mat');
chn_re_index = chn_re_index(1:64);

listener_chn= [1:32 34:42 44:59 61:63];
% % speaker_chn = 63;
% speaker_chn = [28 31 48 63];
% speaker_chn = [2 10 19 28 38 48 56 62];% central channels
% speaker_chn = [1:32 34:42 44:59 61:63];
% speaker_chn = [17:21 26:30 36:40];
% speaker_chn = [9:11 18:20 27:29];
load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';

%% timelag
Fs = 64;
timelag = -500 : 1000/Fs : 500;
label_select = 1 : round(length(timelag)/8) :length(timelag);

%% initial
Correlation_mat.attendDecoder_attend = zeros(listener_num,story_num,length(timelag)); % speaker area * listener * story * time-lag
Correlation_mat.unattendDecoder_unattend = zeros(listener_num,story_num,length(timelag));
Correlation_mat.attendDecoder_unattend = zeros(listener_num,story_num,length(timelag));
Correlation_mat.unattendDecoder_attend = zeros(listener_num,story_num,length(timelag));

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    
    
    %% load raw data
    data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\0-raw r value mat\Audio-listenerEEG\',band_file_name);
    %     data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Surrogate\0-raw r value\surrogate10\',band_file_name);
    data_name_raw  = 'Correlation_mat.mat';
    load(strcat(data_path,'\',data_name_raw));
    data_raw = Correlation_mat;
    
    %% load surrogate data
    for surrogate_select  = 1 : length(surrogate_set)
        %     data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\0-correlation mat\',band_file_name);
        data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Surrogate\0-raw r value mat\Audio-listenerEEG\surrogate',num2str(surrogate_set(surrogate_select)),'\',band_file_name);
        data_name = 'Correlation_mat.mat';
        load(strcat(data_path,'\',data_name));
        eval(strcat('data_surrogate',num2str(surrogate_set(surrogate_select)),' = Correlation_mat;'));
    end
    
    %% plot
    plot_name = fieldnames(Correlation_mat);
    %     plot_name = {'attendDecoder','unattendDecoder'};
    
    for plot_select = 1 : length(plot_name)
        
        % raw data
        
        data_name_raw = strcat('data_raw.',plot_name{plot_select});
        data_for_imagesc = eval(strcat('squeeze(mean(mean(',data_name_raw,',2),1));'));
        range_for_plot = max(max(abs(data_for_imagesc)));
        
        % surrogate data
        for surrogate_select  = 1 : length(surrogate_set)
            data_name_surrogate = strcat('data_surrogate',num2str(surrogate_set(surrogate_select)),'.',plot_name{plot_select});
            data_for_imagesc_surrogate = eval(strcat('squeeze(mean(mean(',data_name_surrogate,',2),1));'));
            
            
            eval(strcat('data_surrogate_imagesc',num2str(surrogate_set(surrogate_select)),'=data_for_imagesc_surrogate;'));
            
            if max(max(abs(data_for_imagesc_surrogate))) > range_for_plot
                range_for_plot = max(max(abs(data_for_imagesc_surrogate)));
            end
        end
        
        
        %% plot
        set(gcf,'outerposition',get(0,'screensize'));
        eval(strcat('subplot(22',num2str(plot_select),')'));
        plot(timelag,data_for_imagesc,'r','LineWidth',2);
        for surrogate_select  = 1 : length(surrogate_set)
            data_surrogate_temp  = eval(strcat('data_surrogate_imagesc',num2str(surrogate_set(surrogate_select))));
            hold on; plot(timelag,data_surrogate_temp,'k-.','LineWidth',0.5);
        end
        
%         ylim([-range_for_plot  range_for_plot]);
        xlabel('timelag(ms)');
        ylabel('r value');
        title(plot_name{plot_select});
        
        %
        %         for area_select = 1 : length(chn_area_labels)
        %
        %             if plot_area_order(area_select) > 6
        %                 eval(strcat('subplot(33',num2str(plot_area_order(area_select)),');'));
        %                 plot(timelag,data_for_imagesc(area_select,:),'r','LineWidth',2);
        %                 for surrogate_select  = 1 : length(surrogate_set)
        %                     data_surrogate_temp  = eval(strcat('data_surrogate_imagesc',num2str(surrogate_set(surrogate_select))));
        %                     hold on; plot(timelag,data_surrogate_temp(area_select,:),'k-.','LineWidth',0.5);
        %                 end
        %
        %                 ylim([-range_for_plot  range_for_plot]);
        %                 xlabel('timelag(ms)');
        %                 ylabel('r value');
        %                 title(chn_area_labels{area_select});
        %
        %
        %             else
        %
        %                 eval(strcat('subplot(33',num2str(plot_area_order(area_select)),');'));
        %                 plot(timelag,data_for_imagesc(area_select,:),'r','LineWidth',2);
        %                 ylim([-range_for_plot  range_for_plot]);
        %
        %                 for surrogate_select  = 1 : length(surrogate_set)
        %                     data_surrogate_temp  = eval(strcat('data_surrogate_imagesc',num2str(surrogate_set(surrogate_select))));
        %                     hold on; plot(timelag,data_surrogate_temp(area_select,:),'k-.','LineWidth',0.5);
        %                 end
        %
        %                 ylabel('r value');
        %                 title(chn_area_labels{area_select});
        %
        %             end
        %
        %         end
        legend('Real','Surrogate','Location','best');
        
        
        
        
    end
    
    save_name = strcat('Audio listenerEEG-',band_name{band_select},'-plot.jpg');
    suptitle(band_file_name);
    saveas(gcf,save_name);
    
    save_name = strcat('Audio listenerEEG-',band_name{band_select},'-plot.fig');
    saveas(gcf,save_name);
    close
    
    % file
    
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end