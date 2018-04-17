% mTRF_SpeakerB_forward_plot_r_value

% reversed 2018.4.9
% author: LJW
% purpose: to plot mTRF crossval r value for SpeakerB

% band_name = {'delta','theta','alpha'};
band_name = {'alpha'};
% band_name = {'narrow_theta'};


%% new order
load('E:\DataProcessing\Label_and_area.mat');

%% initial
load('E:\DataProcessing\chn_re_index.mat');
chn_re_index = chn_re_index(1:64);

% listener
listener_chn = order;
% listener_chn= [1:32 34:42 44:59 61:63];

% speaker
speaker_chn = order;
% speaker_chn = 63;
% speaker_chn = [28 31 48 60];
% speaker_chn = [1:32 34:42 44:59 61:63];
% speaker_chn = [17:21 26:30 36:40];
% speaker_chn = [9:11 18:20 27:29];
load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';

%% listener
listener_num = 20;


%% timelag
Fs = 64;
timelag_plot = -1000: 1000/Fs: 1000;
%     timelag = -250:(1000/Fs):500;
% timelag = timelag(33:49);
%     timelag = 0;
% timelag_select = timelag_plot(1:end);
% timelag_index = 1:length(timelag_select);

%% timelag label
% xtick_index = -1000 : 250 : 1000;
% label_select  = xtick_index(2:end);
label_select = 1 : round(length(timelag_plot)/8) :length(timelag_plot);
chn_label = {'Frontal';'Central';'Occipital'};
y_tick = 1 : 15 : 60;



for band_select = 1 : length(band_name)
    disp(band_name{band_select});
    
    model_for_GFP_attend = zeros(listener_num,length(timelag_plot),length(listener_chn));
    model_for_GFP_unattend = zeros(listener_num,length(timelag_plot),length(listener_chn));
    
    model_attend_GFP = zeros(length(speaker_chn),length(timelag_plot));
    model_unattend_GFP  =  zeros(length(speaker_chn),length(timelag_plot));
    
    for chn_speaker = 1 : length(speaker_chn)
        chn_file_name = strcat(num2str(chn_speaker),'-',label66{speaker_chn(chn_speaker)});
        %         mkdir(chn_file_name);
        %         cd(chn_file_name);
        disp(chn_file_name);
        
        
        %% initial
        
        %% lambda index
        lambda_index = 10;
        
        for lambda_select  = 1 : length(lambda_index)
            file_name = strcat('lambda 2^',num2str(lambda_index(lambda_select)));
            disp(file_name);
            %             mkdir(file_name);
            %             cd(file_name);
            
            for i = 1 : listener_num
                %                 disp(strcat('listener',num2str(i)));
                
                %% listener name
                if i < 10
                    listener_file_name = strcat('listener10',num2str(i));
                else
                    listener_file_name = strcat('listener1',num2str(i));
                end
                
                %% load data
                data_name = strcat('mTRF_speakerEEG_listenerEEG_forward_result+',label66{speaker_chn(chn_speaker)},'-',band_name{band_select},'.mat');
                data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Forward model\SpeakerEEG-listenerEEG\-1s_1s\',band_name{band_select},'\',listener_file_name);
                load(strcat(data_path,'\',data_name));
                
                
                %% data
                % attend
                model_for_GFP_attend_temp = mean(squeeze(model_reshape_attend));
                % unattend
                model_for_GFP_unattend_temp = mean(squeeze(model_reshape_unattend));
                
                %% calculate
                for time_point = 1 : length(timelag_plot)
                    % attend
                    temp_attend = squeeze(model_for_GFP_attend_temp(:,time_point,:));
                    model_attend_GFP(chn_speaker,time_point) = sum(temp_attend.^2)/length(listener_chn);
                    % unattend
                    temp_unattend =squeeze(model_for_GFP_unattend_temp(:,time_point,:));
                    model_unattend_GFP(chn_speaker,time_point) = sum(temp_unattend.^2)/length(listener_chn);
                end
            end
            
            
            
            
            
            %             p = pwd;
            %             cd(p(1:end-(length(file_name)+1)));
        end
        
        
    end
    
    
    %% plot
    
    % attend
    set(gcf,'outerposition',get(0,'screensize'));
    
    % attend
    subplot(211);
    imagesc(model_attend_GFP);colormap('jet');
    caxis([0 1e-4]);
    xticks(label_select);
    xticklabels(timelag_plot(label_select));
    yticks(y_tick(2:end));
    yticklabels(chn_label);
    colorbar;
    title('R attended');
    
    % unattend
    subplot(212);
    imagesc(model_unattend_GFP);colormap('jet');
    caxis([0 1e-4]);
    xticks(label_select);
    xticklabels(timelag_plot(label_select));yticklabels(chn_label);
    yticks(y_tick(2:end));
    yticklabels(chn_label);
    colorbar;
    title('R unattended');
    
    
    save_name = strcat('mTRF SpeakerEEG-ListenerEEG-',band_name{band_select},'.jpg');
    suptitle(save_name(1:end-4));
    saveas(gcf,save_name);
    
    close;
end