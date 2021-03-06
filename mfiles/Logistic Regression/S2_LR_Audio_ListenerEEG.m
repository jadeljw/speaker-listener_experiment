%% LR_Audio_ListenerEEG
% purpose: use logistic regression
% to find the relation between r value and attend target
% Attend A ->1
% Attend
% LJW
% 2018.3.11

% band_name = {'delta','theta','alpha'};
 band_name = {'theta'};
listener_num = 20;

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    
    %% initial
    load('E:\DataProcessing\chn_re_index.mat');
    chn_re_index = chn_re_index(1:64);
    
    listener_chn= [1:32 34:42 44:59 61:63];
    % % speaker_chn = 63;
    % speaker_chn = [28 31 48 63];
    % speaker_chn = [2 10 19 28 38 48 56 62];% central channels
    speaker_chn = [1:32 34:42 44:59 61:63];
    % speaker_chn = [17:21 26:30 36:40];
    % speaker_chn = [9:11 18:20 27:29];
    load('E:\DataProcessing\label66.mat');
    layout = 'E:\DataProcessing\easycapm1.mat';
    
    
    
    %% timelag
    Fs = 64;
    timelag = -500 : 1000/Fs : 500;
    label_select = 1 : round(length(timelag)/8) :length(timelag);
    
    %% initial
    R_squared_mat = zeros(listener_num,length(timelag));
    
    for i = 1 : 20
        
        %% listener name
        if i < 10
            file_name = strcat(' listener10',num2str(i));
        else
            file_name = strcat(' listener1',num2str(i));
        end
        
        %         mkdir(file_name);
        %         cd(file_name);
        disp(file_name);
        
        
        %% band name
        %         lambda = 2.^(0:5:20);
        lambda = 2.^ 10;
        %     band_name = strcat(' 64Hz delta speakerEEG mTRF Listener',dataName(1:3),' lambda',num2str(lambda),' 10-55s');
        
        
        for time_point = 1 : length(timelag)
            %             disp(strcat(timelag(time_point),'ms'));
            
            %% load r value data
%             load(strcat('E:\DataProcessing\speaker-listener_experiment\Logistic Regression\Audio-Listener\',...
%                 band_name{band_select},'\',file_name(2:end),'\mTRF_sound_EEG_result+',num2str(timelag(time_point)),'ms 64Hz 2-8Hz sound from wav',file_name,' lambda1024 10-55s.mat'));
%            
            
            
             load(strcat(' E:\DataProcessing\speaker-listener_experiment\mfiles\Figure\Audio-listener\old\',...
                band_name{band_select},'\',file_name(2:end),'\mTRF_sound_EEG_result+',num2str(timelag(time_point)),'ms 64Hz 2-8Hz sound from wav',file_name,' lambda1024 10-55s.mat'));
            %% combine r value
            % total
            r_value_mat = [recon_AttendDecoder_AudioA_corr recon_AttendDecoder_AudioB_corr recon_UnattendDecoder_AudioA_corr recon_UnattendDecoder_AudioB_corr];
            
            % attend only
            %              r_value_mat = [recon_AttendDecoder_AudioA_corr recon_AttendDecoder_AudioB_corr];
            
            % unattend only
            %             r_value_mat = [recon_UnattendDecoder_AudioA_corr recon_UnattendDecoder_AudioB_corr];
            
            % difference
%                         r_value_mat = [recon_AttendDecoder_AudioA_corr-recon_AttendDecoder_AudioB_corr recon_UnattendDecoder_AudioA_corr-recon_UnattendDecoder_AudioB_corr];
            
            attend_target_mat = attend_target_num'; % 1 -> attend A; 0 -> attend B
            
            %% logtistic regression
            %             disp('Logtistic Regression...')
            %             tic;
            glm = fitglm(r_value_mat,attend_target_mat,'distr','binomial');
            %             toc;
            
            %% save result
            R_squared_mat(i,time_point) = glm.Rsquared.Adjusted;
            if glm.Rsquared.Adjusted == 1
%                 plot(r_value_mat,'*','LineWidth',2);
                imagesc(r_value_mat);colorbar;
                data_name = strcat(file_name(2:end),'+',num2str(timelag(time_point)),'ms.jpg');
                title(data_name(1:end-4));
                xticks(1:4);
                xticklabels({'Attend-A','Attend-B','Unattend-A','Unattend-B'});
%                  xticklabels({'Attend','Unattend'});
                saveas(gcf,data_name);
                close
            end
            
        end
    end
    
    %% plot
    % imagesc
    set(gcf,'outerposition',get(0,'screensize'));
    imagesc(R_squared_mat);colorbar;
    %     colormap('jet');
    xticks(label_select);
    xticklabels(timelag(label_select));
    
    save_name = strcat('Audio ListenerEEG Logstic Regresssion r^2 Result-',band_name{band_select},'-imagesc-diff.jpg');
    title(save_name(1:end-4));
    saveas(gcf,save_name);
    close
    
    % plot mean result
    set(gcf,'outerposition',get(0,'screensize'));
    plot(timelag,mean(R_squared_mat),'LineWidth',2);
    save_name1 = strcat('Audio ListenerEEG Logstic Regresssion r^2 Result-',band_name{band_select},'-mean-diff.jpg');
    title(save_name1(1:end-4));
    saveas(gcf,save_name1);
    close
    
    % save data
    save_name2 = strcat('Audio ListenerEEG Logstic Regresssion r^2 Result-',band_name{band_select},'-diff.mat');
    save(save_name2,'R_squared_mat');
    
    % file
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end