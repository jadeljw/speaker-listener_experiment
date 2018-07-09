%% LR_Audio_ListenerEEG
% purpose: use logistic regression
% to find the relation between r value and attend target
% Attend A ->1
% Attend
% LJW

mkdir('Audio ListenerEEG topoplot');
cd('Audio ListenerEEG topoplot')


band_name = {'alpha', 'alpha_hilbert', 'beta', 'beta_hilbert', 'broadband',...
    'delta', 'delta_hilbert', 'theta', 'theta_hilbert'};

% band_name = {'alpha', 'beta', 'delta', 'theta'};

listener_num = 20;
story_num = 28;

% surrogate_set = 1:10;

range_select  = -1;

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

%% initial
% Correlation_mat_total.attendDecoder_attend = zeros(length(surrogate_set),length(chn_area_labels),length(timelag)); % speaker area * listener * story * time-lag
% Correlation_mat_total.unattendDecoder_unattend = zeros(length(surrogate_set),length(chn_area_labels),length(timelag));
% Correlation_mat_total.attendDecoder_unattend = zeros(length(surrogate_set),length(chn_area_labels),length(timelag));
% Correlation_mat_total.unattendDecoder_attend = zeros(length(surrogate_set),length(chn_area_labels),length(timelag));

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    disp(band_file_name);
    
    
    %% load Speaker-listenerEEG r value  data
    data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\0-raw r value mat\Speaker-listenerEEG\',band_file_name);
    %     data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Surrogate\0-raw r value\surrogate10\',band_file_name);
    data_name_raw  = 'Correlation_mat.mat';
    load(strcat(data_path,'\',data_name_raw));
    data_raw = Correlation_mat;
    
    
    %% load Audio-listenerEEG r value  data
    data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\0-raw r value mat\Audio-listenerEEG\',band_file_name);
    %     data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Surrogate\0-raw r value\surrogate10\',band_file_name);
    data_name_raw  = 'Correlation_mat.mat';
    load(strcat(data_path,'\',data_name_raw));
    data_Audio = Correlation_mat;
    
    %% plot
    plot_name = fieldnames(Correlation_mat);
    %     plot_name = {'attendDecoder','unattendDecoder'};

    
    % mean mat
    for plot_select = 1 : length(plot_name)
        disp(plot_name{plot_select});
        mkdir(plot_name{plot_select});
        cd(plot_name{plot_select});
        disp(plot_name{plot_select});
        
        % speaker-listener EEG raw data
        data_name_raw = strcat('data_raw.',plot_name{plot_select});
        data_for_imagesc = eval(strcat('squeeze(mean(mean(',data_name_raw,',3),2));'));
        
        % audio listener EEG raw data
        data_Audio_name = strcat('data_Audio.',plot_name{plot_select});
        data_Audio_imagesc = eval(strcat('mean(mean(',data_Audio_name,',2),1);'));

        %% topoplot
        [x_ind, y_ind] = find(data_for_imagesc > range_select);
        
        plot_traing_weights = zeros(length(listener_chn),listener_num);
        
        if ~isempty(y_ind)
            for ind_select = 1 : length(x_ind)
%                 for y_select = 1 : length(y_ind)
                    % load file
                    for listener_select = 1 : listener_num
                        if listener_select < 10
                            listener_file_name = strcat('listener10',num2str(listener_select));
                        else
                            listener_file_name = strcat('listener1',num2str(listener_select));
                        end
                        
                        data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\0-original r value\Audio-listenerEEG\',band_file_name,'\',listener_file_name);
                        data_name = strcat('mTRF_Audio_listenerEEG_result-timelag',num2str(timelag(y_ind(ind_select))),'ms-',band_file_name,'.mat');
                        load(strcat(data_path,'\',data_name));
                        
                        if  strcmp(plot_name{plot_select}(1:5),'attend')
                            plot_traing_weights(:,listener_select)  = mean(train_mTRF_attend_w_total,3);
                        else
                            plot_traing_weights(:,listener_select)  = mean(train_mTRF_unattend_w_total,3);                         
                        end
                    end
                    
                    % topo plot
                    set(0,'DefaultFigureVisible', 'off');
                    U_topoplot(abs(mean(plot_traing_weights,2)),layout,label66(listener_chn));
                    save_name = strcat(band_file_name,'-timelag',num2str(timelag(y_ind(ind_select))),'ms.fig');
                    title(strcat(save_name(1:end-4),' r_S_L=',num2str(data_for_imagesc(x_ind(ind_select),y_ind(ind_select))),...
                        ' r_A_L=',num2str(data_Audio_imagesc(y_ind(ind_select)))));
                    saveas(gcf,save_name);
                    
                    disp(strcat(chn_area_labels{x_ind(ind_select)},'-timelag',num2str(timelag(y_ind(ind_select))),'ms'));
                    disp(strcat('S-L r=',num2str(data_for_imagesc(x_ind(ind_select),y_ind(ind_select)))));
                    disp(strcat('A_L r=',num2str(data_Audio_imagesc(y_ind(ind_select)))));
                    
                    save_name = strcat(band_file_name,'-timelag',num2str(timelag(y_ind(ind_select))),'ms.jpg');
%                     title(save_name(1:end-4));
                    saveas(gcf,save_name);
                    close
%                 end
            end
        end
        
        
    p = pwd;
    cd(p(1:end-(length(plot_name{plot_select})+1)));
    end
    
    
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end
