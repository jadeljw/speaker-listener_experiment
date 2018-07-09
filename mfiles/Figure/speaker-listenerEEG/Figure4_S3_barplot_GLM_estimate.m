%% LR_Audio_ListenerEEG
% purpose: use logistic regression
% to find the relation between r value and attend target
% Attend A ->1
% Attend
% LJW

mkdir('GLM estimate');
cd('GLM estimate')


band_name = {'alpha', 'alpha_hilbert', 'beta', 'beta_hilbert', 'broadband',...
    'delta', 'delta_hilbert', 'theta', 'theta_hilbert'};

listener_num = 20;
story_num = 28;
% bin_num = 40;
surrogate_set = 1:10;
plot_num = 4;

range_total  = [0.4988	0.4653	0.485	0.5168	0.47	0.4566	0.5054	0.482	0.5005];

variable_name = {'intercept';'attendDecoder-attend';'unattendDecoder-unattend';'attendDecoder-unattend';'unattendDecoder-attend'};
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
Correlation_mat_total.AttendAcc = zeros(length(surrogate_set),length(chn_area_labels),length(timelag)); % speaker area * listener * story * time-lag
Correlation_mat_total.Concentration = zeros(length(surrogate_set),length(chn_area_labels),length(timelag));
Correlation_mat_total.Difficulty = zeros(length(surrogate_set),length(chn_area_labels),length(timelag));
Correlation_mat_total.Familiar = zeros(length(surrogate_set),length(chn_area_labels),length(timelag));

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    disp(band_file_name);
    
    range_select = range_total(band_select);
    %% load raw data
    data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\6-GLM\original imagesc\',band_file_name);
    %     data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Surrogate\0-raw r value\surrogate10\',band_file_name);
    data_name_raw = strcat('Correlation between R^2-',band_file_name,'-unattendDecoder_attend.mat');
    load(strcat(data_path,'\',data_name_raw));
    data_raw = GLM_Rsquared_mat;
    data_raw_estimate = GLM_Rsquared_mat_estimate;
    
    %% plot
    plot_name = fieldnames(GLM_Rsquared_mat);
    
    for plot_select = 1 : plot_num
        disp(plot_name{plot_select});
        
        % raw data
        data_name_raw = strcat('data_raw.',plot_name{plot_select});
        data_for_imagesc = eval(data_name_raw);
        
        data_name_raw_estimate = strcat('data_raw_estimate.',plot_name{plot_select});
        data_for_imagesc_estimate = eval(data_name_raw_estimate);
        
        [x_ind,y_ind] = find(data_for_imagesc> range_select);
        
        for plot_ind = 1 : length(x_ind)
            % imagesc
            set(gcf,'outerposition',get(0,'screensize'));
            
            bar(squeeze(data_for_imagesc_estimate(x_ind(plot_ind),y_ind(plot_ind),:)));
            xticklabels(variable_name);colormap(winter);
%             yticks(1:length(chn_area_labels));
            xlabel('labels');
            ylabel('coefficient');
            save_name = strcat('Raw r value-',band_name{band_select},'-barplot-',plot_name{plot_select},'-timelag',num2str(timelag(y_ind(plot_ind))),'ms.jpg');
            title(save_name(1:end-4));
            saveas(gcf,save_name);
            
            save_name = strcat('Raw r value-',band_name{band_select},'-barplot-',plot_name{plot_select},'-timelag',num2str(timelag(y_ind(plot_ind))),'ms.fig');
            saveas(gcf,save_name);
            close
        end
    end
    % file
    
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end