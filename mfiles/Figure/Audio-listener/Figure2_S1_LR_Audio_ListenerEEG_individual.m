%% LR_Audio_ListenerEEG
% purpose: use logistic regression
% to find the relation between r value and attend target
% Attend A ->1
% Attend
% LJW
% 2018.3.11

% band_name  = {'alpha', 'alpha_hilbert', 'beta', 'beta_hilbert', 'broadband'...
%     'delta', 'delta_hilbert', 'theta', 'theta_hilbert'};

band_name = {'alpha','delta','theta'};
% band_name = {'theta'};

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
    
    sig_thr = 0.05;
    
    %% timelag
    Fs = 64;
    timelag = -500 : 1000/Fs : 500;
    label_select = 1 : round(length(timelag)/8) :length(timelag);
    
    %% initial
    R_squared_mat = zeros(listener_num,length(timelag));
    p_value_mat = zeros(listener_num,length(timelag));
    p_value_sig_mat = zeros(listener_num,length(timelag));
    
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
            %             data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Logistic Regression\Audio-Listener\',...
            %                 band_name{band_select},'\',file_name(2:end),'\');
            
            data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Audio-listener\zscore\0-raw r value\',...
                band_name{band_select},'\',file_name(2:end),'\');
            
            
            data_name = strcat('mTRF_Audio_listenerEEG_result-timelag',num2str(timelag(time_point)),'ms-',band_name{band_select},'.mat');
            %             data_name = strcat('mTRF_sound_EEG_result+',num2str(timelag(time_point)),'ms 64Hz 2-8Hz sound from wav L',file_name(3:end),' lambda1024 10-55s.mat');
            load(strcat(data_path,data_name));
            
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
            
            %% model test
            d = devianceTest(glm);
            p_value_mat(i,time_point) =  d.pValue(2);
            
            if  p_value_mat(i,time_point) < sig_thr
                p_value_sig_mat(i,time_point) = 1;
            end
            
            %             if glm.Rsquared.Adjusted == 1
            %                 %                 plot(r_value_mat,'*','LineWidth',2);
            %                 imagesc(r_value_mat);colorbar;
            %                 data_name = strcat(file_name(2:end),'+',num2str(timelag(time_point)),'ms.jpg');
            %                 title(data_name(1:end-4));
            %                 xticks(1:4);
            %                 xticklabels({'Attend-A','Attend-B','Unattend-A','Unattend-B'});
            %                 %                  xticklabels({'Attend','Unattend'});
            %                 saveas(gcf,data_name);
            %                 close
            %             end
            
        end
    end
    
    for listener_select = 1 : listener_num
        % plot r value
        set(gcf,'outerposition',get(0,'screensize'));
%         subplot(211);
        plot(timelag,R_squared_mat(listener_select,:),'LineWidth',3);
        ylim([-0.2 1.1]);
        xlabel('timelag(ms)');
        ylabel('R^2 value');
        title('R^2 value');
        %         save_name = strcat('Audio listenerEEG R^2 value-',band_name{band_select},'-listener No.',num2str(listener_select),'-plot.jpg');
        %         title(save_name(1:end-4));
        %         saveas(gcf,save_name);
        %
        % plot p value
%         subplot(212);
%         plot(timelag,-log10(p_value_mat(listener_select,:)),'LineWidth',3);
%         hold on;plot([timelag(1) timelag(end)],[1.3 1.3],'b--');
%         hold on;plot([timelag(1) timelag(end)],[2 2],'r--');
%         ylim([0 8]);
%         xlabel('timelag(ms)');
%         ylabel('-log10(p) value');
%         title('-log10(p) value');
%         
        save_name = strcat('Audio listenerEEG-',band_name{band_select},'-listener No.',num2str(listener_select),'-plot.jpg');
        suptitle(save_name(1:end-4));
        saveas(gcf,save_name);
        
        close
    end
    
    %% plot
    % imagesc
    set(gcf,'outerposition',get(0,'screensize'));
    imagesc(R_squared_mat);colorbar;
    %     colormap('jet');
    xticks(label_select);
    xticklabels(timelag(label_select));
    
    save_name = strcat('Audio ListenerEEG Logstic Regresssion r^2 Result-',band_name{band_select},'-imagesc.jpg');
    title(save_name(1:end-4));
    saveas(gcf,save_name);
    close
    
    % plot mean result
    set(gcf,'outerposition',get(0,'screensize'));
    plot(timelag,mean(R_squared_mat),'LineWidth',3);
    xlabel('timelag(ms)');
    ylabel('R^2');
    save_name1 = strcat('Audio ListenerEEG Logstic Regresssion r^2 Result-',band_name{band_select},'-mean.jpg');
    title(save_name1(1:end-4));
    saveas(gcf,save_name1);
    close
    
    % plot count result
    set(gcf,'outerposition',get(0,'screensize'));
    plot(timelag,sum(p_value_sig_mat),'LineWidth',2);
    xlabel('timelag(ms)');
    ylabel('significant trail count');
    save_name1 = strcat('Audio ListenerEEG Logstic Regresssion significant p value Result-',band_name{band_select},'-mean.jpg');
    title(save_name1(1:end-4));
    saveas(gcf,save_name1);
    close
    
    % save data
    save_name2 = strcat('Audio ListenerEEG Logstic Regresssion r^2 Result-',band_name{band_select},'.mat');
    save(save_name2,'R_squared_mat','p_value_mat','p_value_sig_mat');
    
    % file
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end