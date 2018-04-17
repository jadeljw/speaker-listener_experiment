% mTRF_SpeakerB_forward_plot_r_value

% reversed 2018.4.9
% author: LJW
% purpose: to plot mTRF crossval r value for SpeakerB

band_name = {'delta','theta','alpha'};
% band_name = {'narrow_theta'};

%% initial
load('E:\DataProcessing\chn_re_index.mat');
chn_re_index = chn_re_index(1:64);

listener_chn= [1:32 34:42 44:59 61:63];
% speaker_chn = 63;
% speaker_chn = [28 31 48 60];
speaker_chn = [1:32 34:42 44:59 61:63];
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

for band_select = 1 : length(band_name)
    disp(band_name{band_select});
    
    %% initial
    r_topoplot_attend_max = zeros(length(speaker_chn),1);
    r_topoplot_unattend_max = zeros(length(speaker_chn),1);
    
    for chn_speaker = 1 : length(speaker_chn)
        chn_file_name = strcat(num2str(chn_speaker),'-',label66{speaker_chn(chn_speaker)});
        %         mkdir(chn_file_name);
        %         cd(chn_file_name);
        disp(chn_file_name);
        
        
        % initial
        r_topoplot_attend = zeros(length(listener_chn),listener_num);
        r_topoplot_unattend = zeros(length(listener_chn),listener_num);
        
        
        
        
        %% lambda index
        lambda_index = 10;
        
        for lambda_select  = 1 : length(lambda_index)
            file_name = strcat('lambda 2^',num2str(lambda_index(lambda_select)));
            disp(file_name);
            %             mkdir(file_name);
            %             cd(file_name);
            
            for i = 1 : listener_num
                disp(strcat('listener',num2str(i)));
                
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
                
                %% calculate
                for chn = 1 : length(listener_chn)
                    % attend
                    r_topoplot_attend(chn,i) = mean(R_attend(:,lambda_select,chn),1);
                    %                     MSE_topoplot_attend(chn,i) = mean(MSE_attend(:,lambda_select,chn),1);
                    %                     p_topoplot_attend(chn,i) = mean(P_attend(:,lambda_select,chn),1);
                    
                    % unattend
                    r_topoplot_unattend(chn,i) = mean(R_unattend(:,lambda_select,chn),1);
                    %                     MSE_topoplot_unattend(chn,i) = mean(MSE_unattend(:,lambda_select,chn),1);
                    %                     p_topoplot_unattend(chn,i) = mean(P_unattend(:,lambda_select,chn),1);
                end
            end
            
        end
        
        r_topoplot_attend_max(chn_speaker) = max(mean(r_topoplot_attend,2));
        r_topoplot_unattend_max(chn_speaker) = max(mean(r_topoplot_unattend,2));
        
        
        
    end
    
    %% plot
    
    set(gcf,'outerposition',get(0,'screensize'));
    
    % attend
    subplot(121);
    U_topoplot(r_topoplot_attend_max,layout,label66(listener_chn));colorbar('location','South');
    title('R max attended');
    
    
    % unattend
    subplot(122);
    U_topoplot(r_topoplot_unattend_max,layout,label66(listener_chn));colorbar('location','South');
    title('R max unattended');
    
    
    
    save_name = strcat('mTRF Speaker-listenerEEG r Max-',band_name{band_select},'.jpg');
    %         legend('attend','unattend');
    suptitle(save_name(1:end-4));
    saveas(gcf,save_name);
    close;
    
end

