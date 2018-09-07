%% LR_Audio_ListenerEEG
% purpose: use logistic regression
% to find the relation between r value and attend target
% Attend A ->1
% Attend
% LJW

mkdir('r value');
cd('r value')

%
% band_name = {'alpha', 'alpha_hilbert', 'beta', 'beta_hilbert', 'broadband',...
%     'delta', 'delta_hilbert', 'theta', 'theta_hilbert'};


band_name = {'delta','alpha','theta'};

listener_num = 20;
story_num = 28;


color_style = {[0.3 0.3 0.8];[0.3 0.8 0.3];[0.3 0.3 0.8];[0.3 0.8 0.3]};
line_style = [{'-'};{'-'};{'--'};{'--'}];
line_width = [3 3 2 2];

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
    data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Audio-listener\zscore\1-correlation mat\',band_file_name);
    %     data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Surrogate\0-raw r value\surrogate10\',band_file_name);
    data_name_raw  = 'Correlation_mat.mat';
    load(strcat(data_path,'\',data_name_raw));
    data_raw = Correlation_mat;
    
    
    %% plot
    plot_name = fieldnames(Correlation_mat);
    %     plot_name = {'attendDecoder','unattendDecoder'};
    
    range_for_plot = 0;
    for plot_select = 1 : length(plot_name)
        
        % raw data
        data_name = strcat('data_raw.',plot_name{plot_select});
        data_for_imagesc = eval(strcat('squeeze(mean(',data_name,',2));'));
        data_for_imagesc = mean(data_for_imagesc);
        
        
        %% plot
        set(gcf,'outerposition',get(0,'screensize'));
        
        if plot_select > 1
            hold on;
        end
        plot(timelag,data_for_imagesc,line_style{plot_select},'LineWidth',line_width(plot_select),'Color',color_style{plot_select});
        % plot axis
        temp_max = max(max(abs(data_for_imagesc)));
        if temp_max > range_for_plot
            range_for_plot = temp_max;
        end
        
%         ylim([-range_for_plot  range_for_plot]);
        xlabel('timelag(ms)');
        ylabel('r value');
        %             title(plot_name{plot_select});
        %             ylim([-0.05 0.05]);
        
        ylabel('r value');
        
        legend('AD-a','UD-u','AD-u','UD-a','Location','best');
        %             legend('Real','Surrogate','Location','best');
        
        
    end
    %         title('listener No.',num2str(listener_select));
    save_name = strcat('Audio listenerEEG-',band_name{band_select},'-plot.jpg');
    title(save_name(1:end-4));
    saveas(gcf,save_name);
    
    save_name = strcat('Audio listenerEEG-',band_name{band_select},'-plot.fig');
    saveas(gcf,save_name);
    close
    % file
    
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end