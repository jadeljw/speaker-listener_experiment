%% LR_Audio_ListenerEEG
% purpose: use logistic regression
% to find the relation between r value and attend target
% Attend A ->1
% Attend
% LJW


% band_name = {'alpha', 'alpha_hilbert', 'beta', 'beta_hilbert', 'broadband',...
%     'delta', 'delta_hilbert', 'theta', 'theta_hilbert'};
band_name = {'delta'};
select_label = 2;

listener_num = 20;
story_num = 28;

%%
mkdir('difference');
cd('difference')


%% new order
load('E:\DataProcessing\Label_and_area.mat');

select_area = 'Small_area';
chn_area_labels = fieldnames(eval(select_area));
plot_area_order = [4 6 5 2 1 3 7 8 9];


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

%% color style
color_style = {[0.3 0.3 0.8];[0.3 0.8 0.3]};

%% initial
Correlation_mat.attendDecoder_attend = zeros(length(chn_area_labels),listener_num,story_num,length(timelag)); % speaker area * listener * story * time-lag
Correlation_mat.unattendDecoder_unattend = zeros(length(chn_area_labels),listener_num,story_num,length(timelag));
Correlation_mat.attendDecoder_unattend = zeros(length(chn_area_labels),listener_num,story_num,length(timelag));
Correlation_mat.unattendDecoder_attend = zeros(length(chn_area_labels),listener_num,story_num,length(timelag));

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    
    
    %% load data
    data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Speaker-listenerEEG\0-raw r value mat\',band_file_name);
    %     data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Surrogate\0-raw r value\surrogate10\',band_file_name);
    data_name = 'Correlation_mat.mat';
    load(strcat(data_path,'\',data_name));
    
    %% plot
    %     plot_name = fieldnames(Correlation_mat);
    plot_name = {'attendDecoder','unattendDecoder'};
    
    for plot_select = 1 : length(plot_name)
        
        if strcmp(plot_name{plot_select},'attendDecoder')
            data_name = strcat('Correlation_mat.',plot_name{plot_select},'_attend-Correlation_mat.',plot_name{plot_select},'_unattend');
            data_for_ttest1 = eval(strcat('squeeze(mean(',data_name,',3));'));
        else
            data_name = strcat('Correlation_mat.',plot_name{plot_select},'_unattend-Correlation_mat.',plot_name{plot_select},'_attend');
            data_for_ttest2 = eval(strcat('squeeze(mean(',data_name,',3));'));
        end
    end
    
    %% ttest
    for area_select = select_label
        for listener_select = 1 : listener_num
            set(gcf,'outerposition',get(0,'screensize'));
            plot(timelag,squeeze(data_for_ttest1(area_select,listener_select,:)),'LineWidth',3,'Color',color_style{1});
            hold on;plot(timelag,squeeze(data_for_ttest2(area_select,listener_select,:)),'LineWidth',3,'Color',color_style{2});
            legend('AttendDecoder','UnattendDecoder');
            xlabel('timelag(ms)');
            ylabel('R^2 value');
            ylim([-0.07 0.07]);
            save_name = strcat('Differencet-',band_name{band_select},'-listener No.',num2str(listener_select),'.jpg');
            title(save_name(1:end-4));
            saveas(gcf,save_name);
            close
        end
    end
    

    % file
    
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end