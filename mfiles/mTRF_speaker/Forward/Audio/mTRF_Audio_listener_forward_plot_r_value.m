% mTRF_SpeakerB_forward_plot_r_value

% reversed 2018.4.9
% author: LJW
% purpose: to plot mTRF crossval r value for SpeakerB

band_name = {'delta','theta','alpha','beta'};
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
timelag_select = timelag_plot(1:end);
timelag_index = 1:length(timelag_select);

for band_select = 1 : length(band_name)
    disp(band_name{band_select});
    
    %% initial
    r_topoplot_attend = zeros(length(listener_chn),listener_num);
    MSE_topoplot_attend = zeros(length(listener_chn),listener_num);
    p_topoplot_attend = zeros(length(listener_chn),listener_num);
    
    r_topoplot_unattend = zeros(length(listener_chn),listener_num);
    MSE_topoplot_unattend = zeros(length(listener_chn),listener_num);
    p_topoplot_unattend = zeros(length(listener_chn),listener_num);
    %% lambda index
    lambda_index = 0 : 5 : 40;
    
    for lambda_select  =  find(lambda_index == 10)
        file_name = strcat('lambda 2^',num2str(lambda_index(lambda_select)));
        disp(file_name);
        mkdir(file_name);
        cd(file_name);
        
        for i = 1 : listener_num
            disp(strcat('listener',num2str(i)));
            
            %% listener name
            if i < 10
                listener_file_name = strcat('listener10',num2str(i));
            else
                listener_file_name = strcat('listener1',num2str(i));
            end
            
            %% load data
            data_name = strcat('mTRF_Audio_listenerEEG_forward_result_',band_name{band_select},'-',listener_file_name);
            data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Forward model\Audio-listenerEEG\-1s_1s\',band_name{band_select});
            load(strcat(data_path,'\',data_name));
            
            %% calculate
            for chn = 1 : length(listener_chn)
                % attend
                r_topoplot_attend(chn,i) = mean(R_attend(:,lambda_select,chn),1);
                MSE_topoplot_attend(chn,i) = mean(MSE_attend(:,lambda_select,chn),1);
                p_topoplot_attend(chn,i) = mean(P_attend(:,lambda_select,chn),1);
                
                % unattend
                r_topoplot_unattend(chn,i) = mean(R_unattend(:,lambda_select,chn),1);
                MSE_topoplot_unattend(chn,i) = mean(MSE_unattend(:,lambda_select,chn),1);
                p_topoplot_unattend(chn,i) = mean(P_unattend(:,lambda_select,chn),1);
            end
        end
        
        
        %% plot
        
        % attend
        set(gcf,'outerposition',get(0,'screensize'));
        
        % R
        subplot(121);
        U_topoplot(mean(r_topoplot_attend,2),layout,label66(listener_chn));
%         colorbar('location','EastOutside');
        colorbar('location','South');
        title('R attended');
        
        
%         % MSE
%         subplot(223);
%         U_topoplot(mean(MSE_topoplot_attend,2),layout,label66(listener_chn));
%         colorbar('location','EastOutside');
%         title('MSE attended');
        
%         R
        subplot(122);
        U_topoplot(mean(r_topoplot_unattend,2),layout,label66(listener_chn));
%         colorbar('location','EastOutside');
        colorbar('location','South');
        title('R unattended');
        
        
        % MSE
%         subplot(224);
%         U_topoplot(mean(MSE_topoplot_unattend,2),layout,label66(listener_chn));
%         colorbar('location','EastOutside');
%         title('MSE unattended');
        
        save_name = strcat('mTRF Audio-ListenerEEG-',band_name{band_select},'-lambda 2^',num2str(lambda_index(lambda_select)),'.jpg');
        suptitle(save_name(1:end-4));
        saveas(gcf,save_name);
        
        close;
        
        
        p = pwd;
        cd(p(1:end-(length(file_name)+1)));
    end
    
    
end
