% adapted from mTRF_decoding_sound_from_wav_keep_order_all_listener.m date:
% 2018.4.17 author: LJW purpose: to calculate r value using attend decoder
% and unattend decoder Attend target A ->1 Attend target B ->0

% band_name = {'delta','theta','alpha','beta'};
band_name = {'delta'};
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
    Fs = 64;
    

    
    for listener_select = 1 : 20
        
        %% listener name
        if listener_select < 10
            listener_file_name = strcat('listener10',num2str(listener_select));
        else
            listener_file_name = strcat('listener1',num2str(listener_select));
        end
        
        mkdir(listener_file_name);
        cd(listener_file_name);
        dataName =  dataName_all{listener_select};
        dataFile = dataFile_all{listener_select};
        
        
        %% band name
        lambda_index = 0:2:20;
        lambda = 2.^lambda_index;
        %         bandName = strcat(' 64Hz 2-8Hz sound from wav Listener',dataName(1:3),' lambda',num2str(lambda),' 10-55s');
        
        %% load sound data from wav
        load(strcat('E:\DataProcessing\speaker-listener_experiment\AudioData\from wav\Listener',dataName(1:3),'_Audio_envelope_hilbert_first_64Hz_keep_order.mat'));
        
        %% load EEG data
        
        data_name_temp = strcat('data_filtered_',band_name{band_select});
        load(strcat('E:\DataProcessing\speaker-listener_experiment\ListenerData\',dataName,'_new.mat'),data_name_temp);
        
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
        %         timelag = 0;
        
        %% length
        %         EEG_time = 15 * Fs : 60 * Fs;
        Listener_time_index = 15 * Fs : 60 * Fs;
        Audio_time = 10 * Fs : 55 * Fs;
        
        %% mTRF intitial
        
        %         start_time_total = [-500 -500 -250 0 250 -150 -500 0];
        %         end_time_total = [500 -250 0  250 500 450 0 500];
        
        
        start_time_total = -2000;
        end_time_total = 2000;
        % lambda = 1e5;
        
        Audio_attend_train_set = cell(1,length(EEGBlock));
        Audio_unattend_train_set = cell(1,length(EEGBlock));
        EEG_train_set = cell(1,length(EEGBlock));
        
        %% mTRF preparation
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
            
            Audio_attend_train_set{train_index} = zscore(Audio_attend_train)';
            Audio_unattend_train_set{train_index} = zscore(Audio_unattend_train)';
            
            
            % train EEG
            if strcmpi(Space(train_index),'left')
                EEG_train =  EEGBlock{train_index}(listener_chn,Listener_time_index);
                EEG_train = zscore(EEG_train');
            else
                EEG_train = EEGBlock{train_index}(chn_re_index,:);
                EEG_train =  EEG_train(listener_chn,Listener_time_index);
                EEG_train = zscore(EEG_train');
            end
            
            EEG_train_set{train_index} = EEG_train;
            
            
        end
        
        %% mTRF crossval
        for time_select = 1 : length(start_time_total)
            tic;
            disp(strcat('start_time:',num2str(start_time_total(time_select)),'ms end_time:',num2str(end_time_total(time_select)),'ms'));
            % train
            [R_att,P_att,MSE_att,~,MODEL_att] = mTRFcrossval(Audio_attend_train_set,EEG_train_set,Fs,1,start_time_total(time_select),end_time_total(time_select),lambda);
            [R_unatt,P_unatt,MSE_unatt,~,MODEL_unatt] = mTRFcrossval(Audio_unattend_train_set,EEG_train_set,Fs,1,start_time_total(time_select),end_time_total(time_select),lambda);
            % save name
            save_name = strcat('mTRF Audio-listener start_time',num2str(start_time_total(time_select)),'ms end_time',num2str(end_time_total(time_select)),'ms.mat');
            save(save_name,'R_att','P_att','MSE_att','MODEL_att',...
                'R_unatt','P_unatt','MSE_unatt','MODEL_unatt');
            
            toc;
            % p and mse
            set(gcf,'outerposition',get(0,'screensize'));
            subplot(121);
            plot(squeeze(mean(mean(R_att,1),3)),'k','lineWidth',2);
            hold on;plot(squeeze(mean(mean(R_unatt,1),3)),'k--','lineWidth',2);
            title('Grand average R value');
            xticks(1:length(lambda_index));
            xticklabels(lambda_index);
            xlabel('lambda 2^');
            ylabel('R value');
            legend('attend','unattend');
            
            subplot(122);
            plot(squeeze(mean(mean(MSE_att,1),3)),'k','lineWidth',2);title('Grand average MSE value');
            hold on;plot(squeeze(mean(mean(MSE_unatt,1),3)),'k--','lineWidth',2);
            xticks(1:length(lambda_index));
            xticklabels(lambda_index);
            xlabel('lambda 2^');
            ylabel('MSE value');
            legend('attend','unattend');
            
            save_figure_name = strcat(listener_file_name,' start-time',num2str(start_time_total(time_select)),'ms end-time',num2str(end_time_total(time_select)),'ms');
            suptitle(save_figure_name);
            saveas(gcf,strcat(save_figure_name,'.jpg'));
            saveas(gcf,strcat(save_figure_name,'.fig'));
            close
            
            
        end
        
        
        %  file
        p = pwd;
        cd(p(1:end-(length(listener_file_name)+1)));
    end
    
    
    
    
    
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end