% adapted from mTRF_decoding_sound_from_wav_keep_order_all_listener.m
% date: 2018.4.17
% author: LJW
% purpose: to calculate r value using attend decoder and unattend decoder
% Attend target A ->1
% Attend target B ->0

band_name = {'alpha', 'alpha_hilbert', 'beta', 'beta_hilbert', 'broadband',...
    'delta', 'delta_hilbert', 'theta', 'theta_hilbert'};

surrogate_time = 10;
story_num = 28;
listener_num = 20;

% mkdir('Audio ListenerEEG surrogate');
% cd('Audio ListenerEEG surrogate');

%% initial
load('E:\DataProcessing\chn_re_index.mat');
chn_re_index = chn_re_index(1:64);


listener_chn= [1:32 34:42 44:59 61:63];
load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';

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

for surrogate_order = 9 : surrogate_time
    % shuffle order
    [Shuffle_Audio,Shuffle_listener]=U_Shuffle_for_surrogate(1:story_num,1:story_num);
    
    Shuffle_Audio
    Shuffle_listener
    %     pause;
    
    %% file
    surrogate_file_name = strcat('Audio ListenerEEG zscore surrogate',num2str(surrogate_order));
    mkdir(surrogate_file_name);
    cd(surrogate_file_name);
    
    
    save_name = strcat('Shuffle_order-',datestr(now,30),'.mat');
    save(save_name,'Shuffle_Audio','Shuffle_listener');
    
    for band_select = 1 : length(band_name)
        band_file_name = strcat(band_name{band_select});
        mkdir(band_file_name);
        cd(band_file_name);
        
        
        
        for i = 1 : 20
            
            %% listener name
            if i < 10
                file_name = strcat('listener10',num2str(i));
            else
                file_name = strcat('listener1',num2str(i));
            end
            
            mkdir(file_name);
            cd(file_name);
            dataName =  dataName_all{i};
            dataFile = dataFile_all{i};
            
            
            %% band name
            lambda = 2^10;
            %             bandName = strcat(' 64Hz 2-8Hz sound from wav Listener',dataName(1:3),' lambda',num2str(lambda),' 10-55s');
            
            %% load sound data from wav
            % % load('E:\DataProcessing\speaker-listener_experiment\AudioData\Audio_envelope_64Hz_hilbert_cell.mat');
            % load('E:\DataProcessing\speaker-listener_experiment\AudioData\from wav\Listener01_Audio_envelope_hilbert_first_64Hz_keep_order.mat');
            % load('E:\DataProcessing\speaker-listener_experiment\AudioData\from wav\Listener0_Audio_envelope_hilbert_first_64Hz_keep_order.mat');
            % load('E:\DataProcessing\speaker-listener_experiment\AudioData\from wav\Listener101_Audio_envelope_hilbert_first_64Hz_keep_order.mat');
            load(strcat('E:\DataProcessing\speaker-listener_experiment\AudioData\from wav\Listener',dataName(1:3),'_Audio_envelope_hilbert_first_64Hz_keep_order.mat'));
            
            
            %% load EEG data
            % load('E:\DataProcessing\speaker-listener_experiment\ListenerData\0-LZR-Listener-ICA-filter-reref-64Hz.mat');
            % load('E:\DataProcessing\speaker-listener_experiment\ListenerData\01-CYX-Listener-ICA-filter-reref-64Hz.mat')
            data_name_temp = strcat('data_filtered_',band_name{band_select});
            load(strcat('E:\DataProcessing\speaker-listener_experiment\ListenerData\',dataName,'_new.mat'),data_name_temp);
            
            
            % combine
            EEGBlock = eval(strcat('data_filtered_',band_file_name,'.trial'));
            EEGBlock = EEGBlock';
            
            %% attend stream
            load(strcat('E:\DataProcessing\speaker-listener_experiment\CountBalanceTable\CountBalanceTable_listener',dataName(1:3),'.mat'));
            attend_target_num = zeros(1,length(EEGBlock));
            
            for attend_story = 1 : length(EEGBlock)
                if strcmpi(AttendTarget{Shuffle_Audio(attend_story)},'A')
                    attend_target_num(attend_story) = 1;
                else
                    attend_target_num(attend_story) = 0;
                end
            end
            %
            %% timelag
            Fs = 64;
            % timelag = -250:500/32:500;
            timelag = -500:(1000/Fs):500;
            % timelag = timelag(33:49);
            %     timelag = 0;
            
            %% length
            %             EEG_time = 15 * Fs : 60 * Fs;
            Listener_time_index = 15 * Fs : 60 * Fs;
            Audio_time = 10 * Fs : 55 * Fs;
            
            
            %% chn_sel
            chn_sel_index = [1:32 34:42 44:59 61:63];
            
            
            for j = 1 : length(timelag)
                %% mTRF intitial
                
                start_time = 0 + timelag(j);
                end_time = 0 + timelag(j);
                % lambda = 1e5;
                
                %% mTRF matrix intial
                train_mTRF_attend_w_total = zeros(length(chn_sel_index),(end_time-start_time)/(1000/Fs)+1,size(EEGBlock,1));
                train_mTRF_unattend_w_total = zeros(length(chn_sel_index),(end_time-start_time)/(1000/Fs)+1,size(EEGBlock,1));
                train_mTRF_attend_con_total = zeros(length(chn_sel_index),1,size(EEGBlock,1));
                train_mTRF_unattend_con_total = zeros(length(chn_sel_index),1,size(EEGBlock,1));
                
                train_mTRF_attend_w_train_all_story = cell(size(EEGBlock,1),1);
                train_mTRF_unattend_w_train_all_story = cell(size(EEGBlock,1),1);
                train_mTRF_attend_w_all_story_mean = cell(size(EEGBlock,1),1);
                train_mTRF_unattend_w_all_story_mean = cell(size(EEGBlock,1),1);
                
                
                recon_AttendDecoder_AudioA_corr = zeros(size(EEGBlock,1),1);
                recon_UnattendDecoder_AudioB_corr = zeros(size(EEGBlock,1),1);
                recon_AttendDecoder_AudioB_corr = zeros(size(EEGBlock,1),1);
                recon_UnattendDecoder_AudioA_corr = zeros(size(EEGBlock,1),1);
                
                p_recon_AttendDecoder_AudioA_corr = zeros(size(EEGBlock,1),1);
                p_recon_UnattendDecoder_AudioB_corr = zeros(size(EEGBlock,1),1);
                p_recon_AttendDecoder_AudioB_corr = zeros(size(EEGBlock,1),1);
                p_recon_UnattendDecoder_AudioA_corr = zeros(size(EEGBlock,1),1);
                
                MSE_recon_AttendDecoder_AudioA_corr = zeros(size(EEGBlock,1),1);
                MSE_recon_UnattendDecoder_AudioB_corr = zeros(size(EEGBlock,1),1);
                MSE_recon_AttendDecoder_AudioB_corr = zeros(size(EEGBlock,1),1);
                MSE_recon_UnattendDecoder_AudioA_corr = zeros(size(EEGBlock,1),1);
                
                
                %% mTRF train
                data_left = data_left_theta;
                data_right =data_right_theta;
                
                for train_index = 1 : length(EEGBlock)
                    
                    % train story
                    if strcmpi(Space(Shuffle_Audio(train_index)),'left')
                        Audio_attend_train = data_left{Shuffle_Audio(train_index)}(Audio_time)';
                        Audio_unattend_train= data_right{Shuffle_Audio(train_index)}(Audio_time)';
                    else
                        Audio_attend_train = data_right{Shuffle_Audio(train_index)}(Audio_time)';
                        Audio_unattend_train = data_left{Shuffle_Audio(train_index)}(Audio_time)';
                    end
                    
                    Audio_attend_train = zscore(Audio_attend_train);
                    Audio_unattend_train = zscore(Audio_unattend_train);
                    
                    
                    % train EEG
                    if strcmpi(Space(Shuffle_Audio(train_index)),'left')
                        EEG_train =  EEGBlock{Shuffle_Audio(train_index)}(listener_chn,Listener_time_index);
                        EEG_train = zscore(EEG_train');
                    else
                        EEG_train = EEGBlock{Shuffle_Audio(train_index)}(chn_re_index,:);
                        EEG_train =  EEG_train(listener_chn,Listener_time_index);
                        EEG_train = zscore(EEG_train');
                    end
                    %                     EEG_train =  EEGBlock{Shuffle_listener(train_index)}(chn_sel_index,EEG_time);
                    
                    disp(strcat('Training story',num2str(train_index),'...'));
                    
                    
                    %train process
                    [w_train_mTRF_attend,t_train_mTRF_attend,con_train_mTRF_attend] = mTRFtrain(Audio_attend_train',EEG_train,Fs,-1,start_time,end_time,lambda);
                    [w_train_mTRF_unattend,t_train_mTRF_unattend,con_train_mTRF_unattend] = mTRFtrain(Audio_unattend_train',EEG_train,Fs,-1,start_time,end_time,lambda);
                    
                    
                    % record all weights into one matrix
                    train_mTRF_attend_w_total(:,:,train_index) = w_train_mTRF_attend;
                    train_mTRF_attend_con_total(:,:,train_index) = con_train_mTRF_attend;
                    
                    train_mTRF_unattend_w_total(:,:,train_index) = w_train_mTRF_unattend;
                    train_mTRF_unattend_con_total(:,:,train_index) = con_train_mTRF_unattend;
                    
                    %                 train_mTRF_attend_w_train_all_story{train_index}= train_mTRF_attend_w_total;
                    %                 train_mTRF_unattend_w_train_all_story{train_index} = train_mTRF_unattend_w_total;
                    
                end
                
                
                
                %% mTRF test
                for test_index = 1 : length(EEGBlock)
                    train_data_index = setdiff(1:length(EEGBlock),test_index);
                    % mean of weights
                    train_mTRF_attend_w_mean = mean(train_mTRF_attend_w_total(:,:,train_data_index),3);
                    train_mTRF_attend_con_mean = mean(train_mTRF_attend_con_total(:,:,train_data_index),3);
                    
                    train_mTRF_unattend_w_mean = mean(train_mTRF_unattend_w_total(:,:,train_data_index),3);
                    train_mTRF_unattend_con_mean = mean(train_mTRF_unattend_con_total(:,:,train_data_index),3);
                    
                    train_mTRF_attend_w_all_story_mean{test_index} = train_mTRF_attend_w_mean;
                    train_mTRF_unattend_w_all_story_mean{test_index} = train_mTRF_unattend_w_mean;
                    
                    % test data
                    if strcmpi(Space(Shuffle_listener(test_index)),'left')
                        Audio_attend_test = data_left{Shuffle_listener(test_index)}(Audio_time)';
                        Audio_unattend_test = data_right{Shuffle_listener(test_index)}(Audio_time)';
                    else
                        Audio_attend_test = data_right{Shuffle_listener(test_index)}(Audio_time)';
                        Audio_unattend_test = data_left{Shuffle_listener(test_index)}(Audio_time)';
                    end
                    
                    Audio_attend_test = zscore(Audio_attend_test);
                    Audio_unattend_test = zscore(Audio_unattend_test);
                    
                    
                    % test EEG
                    if strcmpi(Space(Shuffle_Audio(test_index)),'left')
                        EEG_test =  EEGBlock{Shuffle_Audio(test_index)}(listener_chn,Listener_time_index);
                        EEG_test = zscore(EEG_test');
                    else
                        EEG_test = EEGBlock{Shuffle_Audio(test_index)}(chn_re_index,:);
                        EEG_test =  EEG_test(listener_chn,Listener_time_index);
                        EEG_test = zscore(EEG_test');
                    end
                    
                    % predict
                    disp(strcat('Testing story',num2str(test_index),'...'));
                    
                    [~,recon_AttendDecoder_AudioA_corr(test_index),p_recon_AttendDecoder_AudioA_corr(test_index),MSE_recon_AttendDecoder_AudioA_corr(test_index)] =...
                        mTRFpredict(Audio_attend_test',EEG_test,train_mTRF_attend_w_mean,Fs,-1,start_time,end_time,train_mTRF_attend_con_mean);
                    
                    [~,recon_AttendDecoder_AudioB_corr(test_index),p_recon_AttendDecoder_AudioB_corr(test_index),MSE_recon_AttendDecoder_AudioB_corr(test_index)] =...
                        mTRFpredict(Audio_unattend_test',EEG_test,train_mTRF_attend_w_mean,Fs,-1,start_time,end_time,train_mTRF_attend_con_mean);
                    
                    [~,recon_UnattendDecoder_AudioB_corr(test_index),p_recon_UnattendDecoder_AudioB_corr(test_index),MSE_recon_UnattendDecoder_AudioB_corr(test_index)] =...
                        mTRFpredict(Audio_unattend_test',EEG_test,train_mTRF_unattend_w_mean,Fs,-1,start_time,end_time,train_mTRF_unattend_con_mean);
                    
                    [~,recon_UnattendDecoder_AudioA_corr(test_index),p_recon_UnattendDecoder_AudioA_corr(test_index),MSE_recon_UnattendDecoder_AudioA_corr(test_index)] =...
                        mTRFpredict(Audio_attend_test',EEG_test,train_mTRF_unattend_w_mean,Fs,-1,start_time,end_time,train_mTRF_unattend_con_mean);
                    
                end
                
                %% save data
                
                % save data
                %                 saveName = strcat('mTRF_sound_EEG_result+',num2str(timelag(j)),'ms',bandName,'.mat');
                saveName = strcat('mTRF_Audio_listenerEEG_result-timelag',num2str(timelag(j)),'ms-',band_file_name,'.mat');
                
                %     saveName = strcat('mTRF_sound_EEG_result.mat');
                save(saveName,'recon_AttendDecoder_AudioA_corr','recon_UnattendDecoder_AudioA_corr' ,'recon_AttendDecoder_AudioB_corr','recon_UnattendDecoder_AudioB_corr',...
                    'p_recon_AttendDecoder_AudioA_corr','p_recon_UnattendDecoder_AudioA_corr', 'p_recon_AttendDecoder_AudioB_corr','p_recon_UnattendDecoder_AudioB_corr',...
                    'MSE_recon_AttendDecoder_AudioA_corr','MSE_recon_UnattendDecoder_AudioA_corr','MSE_recon_AttendDecoder_AudioB_corr','MSE_recon_UnattendDecoder_AudioB_corr',...
                    'train_mTRF_attend_w_all_story_mean','train_mTRF_unattend_w_all_story_mean',...
                    'attend_target_num');
            end
            
            p = pwd;
            cd(p(1:end-(length(file_name)+1)));
            
            
        end
        p = pwd;
        cd(p(1:end-(length(band_file_name)+1)));
        
    end
    
    p = pwd;
    cd(p(1:end-(length(surrogate_file_name)+1)));
end