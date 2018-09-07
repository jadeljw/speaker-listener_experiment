%% LR_Audio_ListenerEEG
% purpose: use logistic regression
% to find the relation between r value and attend target
% Attend A ->1
% Attend
% LJW


% band_name = {'alpha', 'alpha_hilbert', 'beta', 'beta_hilbert', 'broadband', 'broadband_hilbert',...
%     'delta', 'delta_hilbert', 'gamma', 'gamma_hilbert', 'theta', 'theta_hilbert'};
band_name = {'alpha_FL'};
% color_style = {[0.8 0.1 0.3];[0.3 0.1 0.8];[0.8 0.1 0.3];[0.3 0.1 0.8]};% red & blue
color_style = {[.3 0.3 0.8];[0.3 0.8 0.3];[.3 0.3 0.8];[0.3 0.8 0.3]};
line_style = [{'-'};{'-'};{'--'};{'--'}];
line_width = [1.8 1.8 1.2 1.2];

listener_num = 20;
story_num = 28;


%% new order
load('E:\DataProcessing\Label_and_area.mat');

select_area = 'Small_area';
chn_area_labels = fieldnames(eval(select_area));

speaker_chn_total = [1:32 34:42 44:59 61:63];
select_area_label = 'CR';
select_channels = eval(strcat(select_area,'.',select_area_label));
plot_area_order = 1:length(select_channels);

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
Correlation_mat.attendDecoder_attend = zeros(length(select_channels),listener_num,story_num,length(timelag)); % speaker area * listener * story * time-lag
Correlation_mat.unattendDecoder_unattend = zeros(length(select_channels),listener_num,story_num,length(timelag));
Correlation_mat.attendDecoder_unattend = zeros(length(select_channels),listener_num,story_num,length(timelag));
Correlation_mat.unattendDecoder_attend = zeros(length(select_channels),listener_num,story_num,length(timelag));

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    
    
    %% load data
    data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Speaker-listenerEEG\0-raw r value mat\1.area\',band_file_name);
    data_name = 'Correlation_mat.mat';
    load(strcat(data_path,'\',data_name));
    
    %% plot
    plot_name = fieldnames(Correlation_mat);
    for area_select = 1 : length(select_channels)
        for plot_select = 1 : length(plot_name)
            data_name = strcat('Correlation_mat.',plot_name{plot_select});
            data_for_imagesc = eval(strcat('squeeze(mean(mean(',data_name,',3),2));'));
            
            % imagesc
            set(gcf,'outerposition',get(0,'screensize'));
            range_for_plot = max(max(abs(data_for_imagesc)));
            
            eval(strcat('subplot(24',num2str(plot_area_order(area_select)),');'));
            if plot_select > 1
                hold on;
            end
            plot(timelag,data_for_imagesc(area_select,:),line_style{plot_select},'LineWidth',line_width(plot_select),'Color',color_style{plot_select});
            ylim([-0.011 0.011]);
            
            ylabel('r value');
            title(label66{speaker_chn_total(select_channels(area_select))});
            
            if plot_area_order(area_select) > 4
                xlabel('timelag(ms)');
                
            end
            
        end
        
    end
    
    legend('AD-a','UD-u','AD-u','UD-a','best');
    save_name = strcat('Raw r value-',band_name{band_select},'.jpg');
    suptitle(save_name(1:end-4));
    saveas(gcf,save_name);
    
    save_name = strcat('Raw r value-',band_name{band_select},'.fig');
    %     suptitle(save_name(1:end-4));
    saveas(gcf,save_name);
    close
    
    % file
    
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end