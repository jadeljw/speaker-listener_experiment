% adapted from mTRF_decoding_sound_from_wav_keep_order_all_listener.m date:
% 2018.4.17 author: LJW purpose: to calculate r value using attend decoder
% and unattend decoder Attend target A ->1 Attend target B ->0

band_name = {'delta','theta','alpha'};
% band_name = {'theta'};
% band_name = {'alpha', 'alpha_hilbert', 'beta', 'beta_hilbert', 'broadband',...
%     'delta', 'delta_hilbert', 'theta', 'theta_hilbert'};


%% initial
load('E:\DataProcessing\chn_re_index.mat');
chn_re_index = chn_re_index(1:64);

listener_chn= [1:32 34:42 44:59 61:63];
load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';




for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    
    
    %% data name
    dataName_all = {'101-YJMQ-Listener-ICA-reref-filter_64Hz',...
        '102-LTX-Listener-ICA-reref-filter_64Hz',...
        '103-RT-Listener-ICA-reref-filter_64Hz',...
        '104-ZR-Listener-ICA-reref-filter_64Hz',...
        '105-LX-Listener-ICA-reref-filter_64Hz',...
        '106-WCW-Listener-ICA-reref-filter_64Hz',...
        '107-WY-Listener-ICA-reref-filter_64Hz',...
        '108-LGZ-Listener-ICA-reref-filter_64Hz',...
        '109-PXJ-Listener-ICA-reref-filter_64Hz',...
        '110-LNN-Listener-ICA-reref-filter_64Hz',...
        '111-ZXT-Listener-ICA-reref-filter_64Hz',...
        '112-LX-Listener-ICA-reref-filter_64Hz',...
        '113-SYH-Listener-ICA-reref-filter_64Hz',...
        '114-WXZ-Listener-ICA-reref-filter_64Hz',...
        '115-LYZ-Listener-ICA-reref-filter_64Hz',...
        '116-ZX-Listener-ICA-reref-filter_64Hz',...
        '117-HY-Listener-ICA-reref-filter_64Hz',...
        '118-WM-Listener-ICA-reref-filter_64Hz',...
        '119-ZC-Listener-ICA-reref-filter_64Hz',...
        '120-LYB-Listener-ICA-reref-filter_64Hz'};
    
    dataFile_all = {'20171118-YJMQ','20171122-LTX','20171122-RT',...
        '20171124-ZR','20171125-LX','20171128-WCW',...
        '20171130-WY','20171202-LGZ','20171205-PXJ','20171206-LNN',...
        '20171209-ZXT','20171209-LX','20171213-SYH',...
        '20171214-WXZ','20171214-LYZ','20171216-ZX',...
        '20171216-HY','20171220-WM','20171221-ZC',...
        '20171221-LYB'};
    
    listener_num = 20;
    story_num  = 28;
    
    
    %% mTRF matrix intial
    start_time = -500;
    end_time = 500;
    Fs = 64;
    
    train_mTRF_attend_w_total = zeros(listener_num,length(listener_chn),(end_time-start_time)/(1000/Fs)+1,story_num);
    train_mTRF_unattend_w_total = zeros(listener_num,length(listener_chn),(end_time-start_time)/(1000/Fs)+1,story_num);
    train_mTRF_attend_con_total = zeros(listener_num,length(listener_chn),1,story_num);
    train_mTRF_unattend_con_total = zeros(listener_num,length(listener_chn),1,story_num);
    
    timelag_for_plot = -500 : 1000/Fs : 500;
    
    for i = 1 : 20
        
        %% listener name
        if i < 10
            file_name = strcat('listener10',num2str(i));
        else
            file_name = strcat('listener1',num2str(i));
        end
        
        %         mkdir(file_name);
        %         cd(file_name);
        dataName =  dataName_all{i};
        dataFile = dataFile_all{i};
        
        
        %% band name
        lambda = 2^10;
        bandName = strcat(' 64Hz 2-8Hz sound from wav Listener',dataName(1:3),' lambda',num2str(lambda),' 10-55s');
        
        %% load sound data from wav
        % %
        % load('E:\DataProcessing\speaker-listener_experiment\AudioData\Audio_envelope_64Hz_hilbert_cell.mat');
        % load('E:\DataProcessing\speaker-listener_experiment\AudioData\from
        % wav\Listener01_Audio_envelope_hilbert_first_64Hz_keep_order.mat');
        % load('E:\DataProcessing\speaker-listener_experiment\AudioData\from
        % wav\Listener0_Audio_envelope_hilbert_first_64Hz_keep_order.mat');
        % load('E:\DataProcessing\speaker-listener_experiment\AudioData\from
        % wav\Listener101_Audio_envelope_hilbert_first_64Hz_keep_order.mat');
        
        
        load(strcat('E:\DataProcessing\speaker-listener_experiment\AudioData\from wav\Listener',dataName(1:3),'_Audio_envelope_hilbert_first_64Hz_keep_order.mat'));
        
        %          load(strcat('E:\DataProcessing\speaker-listener_experiment\AudioData\from wav\old\Listener',dataName(1:3),'_Audio_envelope_hilbert_first_64Hz_keep_order.mat'));
        
        %% load EEG data
        % load('E:\DataProcessing\speaker-listener_experiment\ListenerData\0-LZR-Listener-ICA-filter-reref-64Hz.mat');
        % load('E:\DataProcessing\speaker-listener_experiment\ListenerData\01-CYX-Listener-ICA-filter-reref-64Hz.mat')
        data_name_temp = strcat('data_filtered_',band_name{band_select});
        load(strcat('E:\DataProcessing\speaker-listener_experiment\ListenerData\',dataName,'_new.mat'),data_name_temp);
        %         load(strcat('G:\Speaker-listener_experiment\listener\data\old 2018.3.21\',dataName,'.mat'),data_name_temp);
        
        % combine
        EEGBlock = eval(strcat('data_filtered_',band_file_name,'.trial'));
        EEGBlock = EEGBlock';
        
        %% attend stream
        load(strcat('E:\DataProcessing\speaker-listener_experiment\CountBalanceTable\CountBalanceTable_listener',dataName(1:3),'.mat'));
        attend_target_num = zeros(1,length(EEGBlock));
        
        for attend_story = 1 : length(EEGBlock)
            if strcmpi(AttendTarget(attend_story),'A')
                attend_target_num(attend_story) = 1;
            else
                attend_target_num(attend_story) = 0;
            end
        end
        %
        %% timelag
        Fs = 64;
        % timelag = -250:500/32:500;
        %         timelag = -500:(1000/Fs):500;
        % timelag = timelag(33:49);
        timelag = 0;
        
        %% length
        %         EEG_time = 15 * Fs : 60 * Fs;
        Listener_time_index = 15 * Fs : 60 * Fs;
        Audio_time = 10 * Fs : 55 * Fs;
        
        
        
        
        for j = 1 : length(timelag)
            %% mTRF intitial
            
            start_time = -500 + timelag(j);
            end_time = 500 + timelag(j);
            % lambda = 1e5;
            
            
            %% mTRF train
            data_left = data_left_theta;
            data_right = data_right_theta;
            
            for train_index = 1 : length(EEGBlock)
                
                % train story
                if strcmpi(Space(train_index),'left')
                    Audio_attend_train = data_left{train_index}(Audio_time)';
                    Audio_unattend_train= data_right{train_index}(Audio_time)';
                else
                    Audio_attend_train = data_right{train_index}(Audio_time)';
                    Audio_unattend_train = data_left{train_index}(Audio_time)';
                end
                
                Audio_attend_train = zscore(Audio_attend_train);
                Audio_unattend_train = zscore(Audio_unattend_train);
                
                
                % train EEG
                if strcmpi(Space(train_index),'left')
                    EEG_train =  EEGBlock{train_index}(listener_chn,Listener_time_index);
                    EEG_train = zscore(EEG_train');
                else
                    EEG_train = EEGBlock{train_index}(chn_re_index,:);
                    EEG_train =  EEG_train(listener_chn,Listener_time_index);
                    EEG_train = zscore(EEG_train');
                end
                
                disp(strcat('Training story',num2str(train_index),'...'));
                
                
                %train process
                [w_train_mTRF_attend,t_train_mTRF_attend,con_train_mTRF_attend] = mTRFtrain(Audio_attend_train',EEG_train,Fs,1,start_time,end_time,lambda);
                [w_train_mTRF_unattend,t_train_mTRF_unattend,con_train_mTRF_unattend] = mTRFtrain(Audio_unattend_train',EEG_train,Fs,1,start_time,end_time,lambda);
                
                
                % record all weights into one matrix
                train_mTRF_attend_w_total(i,:,:,train_index) = transpose(squeeze(w_train_mTRF_attend));
                %                 train_mTRF_attend_con_total(:,:,train_index) = con_train_mTRF_attend;
                
                train_mTRF_unattend_w_total(i,:,:,train_index) = transpose(squeeze(w_train_mTRF_unattend));
                %                 train_mTRF_unattend_con_total(:,:,train_index) = con_train_mTRF_unattend;
                
                
                %                 train_mTRF_attend_w_trans_total(:,:,train_index) = w_train_mTRF_trans_attend;
                %                 train_mTRF_attend_con_trans_total(:,:,train_index) = con_train_mTRF_trans_attend;
                %
                %                 train_mTRF_unattend_w_trans_total(:,:,train_index) = w_train_mTRF_trans_unattend;
                %                 train_mTRF_unattend_con_trans_total(:,:,train_index) = con_train_mTRF_trans_unattend;
                
                %                 train_mTRF_attend_w_train_all_story{train_index}=
                %                 train_mTRF_attend_w_total;
                %                 train_mTRF_unattend_w_train_all_story{train_index}
                %                 = train_mTRF_unattend_w_total;
                
            end
            
            
            
            
            
            % save data
            %             saveName =
            %             strcat('mTRF_sound_EEG_result+',num2str(timelag(j)),'ms',bandName,'.mat');
            
        end
    end
    
    %         p = pwd;
    %         cd(p(1:end-(length(file_name)+1)));
    
    %% GFP
    GFP_timeplot_attend = zeros(1,length(timelag_for_plot));
    GFP_timeplot_unattend = zeros(1,length(timelag_for_plot));
    
    
    train_mTRF_attend_w_mean =transpose(zscore(transpose(squeeze(mean(mean(train_mTRF_attend_w_total,4),1)))));
    train_mTRF_unattend_w_mean= transpose(zscore(transpose(squeeze(mean(mean(train_mTRF_unattend_w_total,4),1)))));
    
    for time_point = 1 : length(timelag_for_plot)
        for chn_select = 1 : length(listener_chn)
            GFP_timeplot_attend(time_point)  = GFP_timeplot_attend (time_point) +  train_mTRF_attend_w_mean(chn_select,time_point) .^2;
            GFP_timeplot_unattend(time_point)  = GFP_timeplot_unattend(time_point) +  train_mTRF_unattend_w_mean(chn_select,time_point) .^2;
        end
    end
    
    
    %% plot
    % attend
    plot(timelag_for_plot,GFP_timeplot_attend,'lineWidth',2);
    save_name = strcat('GFP attend forward-',band_file_name);
    title(save_name);
    xlabel('timelag(ms)');
    ylabel('a.u.');
    saveas(gcf,strcat(save_name,'.jpg'));
    saveas(gcf,strcat(save_name,'.fig'));
    close
    
    % topoplot
    [~,GFP_attend_max]  = max(GFP_timeplot_attend);
    U_topoplot(train_mTRF_attend_w_mean(:,GFP_attend_max),layout,label66(listener_chn));
    save_name = strcat('GFP attend topoplot-',band_file_name,'-timelag',num2str(timelag_for_plot(GFP_attend_max)),'ms');
    title(save_name);
    saveas(gcf,strcat(save_name,'.jpg'));
    saveas(gcf,strcat(save_name,'.fig'));
    close
    
    
    % unattend
    plot(timelag_for_plot,GFP_timeplot_unattend,'lineWidth',2);
    save_name = strcat('GFP unattend forward-',band_file_name);
    title(save_name);
    xlabel('timelag(ms)');
    ylabel('a.u.');
    saveas(gcf,strcat(save_name,'.jpg'));
    saveas(gcf,strcat(save_name,'.fig'));
    close
    
    % topoplot
    [~,GFP_unattend_max]  = max(GFP_timeplot_unattend);
    U_topoplot(train_mTRF_unattend_w_mean(:,GFP_unattend_max),layout,label66(listener_chn));
    save_name = strcat('GFP unattend topoplot-',band_file_name,'-timelag',num2str(timelag_for_plot(GFP_unattend_max)),'ms');
    title(save_name);
    saveas(gcf,strcat(save_name,'.jpg'));
    saveas(gcf,strcat(save_name,'.fig'));
    close
    
    
    %% save data
    saveName = strcat('mTRF_Audio_listenerEEG_result-timelag',num2str(timelag(j)),'ms-',band_file_name,'.mat');
    
    %     saveName = strcat('mTRF_sound_EEG_result.mat');
    save(saveName,...
        'train_mTRF_attend_w_total','train_mTRF_unattend_w_total',...
        'attend_target_num','GFP_timeplot_attend','GFP_timeplot_unattend');
    
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end