% mTRF for speaker-listener-new-experiment data
% adapted from mTRF_decoding_sound_from_wav_keep_order_all_listener.m
% date: 2018.4.17
% author: LJW
% purpose: to calculate r value using attend decoder and unattend decoder
% Attend target A ->1
% Attend target B ->0

% revised 11.19 for speaker-listener experiment
% using mTRF 1.5 toolbox

% using every channel of speaker EEG as audio input

mkdir('Speaker ListenerEEG');
cd('Speaker ListenerEEG');

%% initial
load('E:\DataProcessing\chn_re_index.mat');
chn_re_index = chn_re_index(1:64);

listener_chn= [1:32 34:42 44:59 61:63];
speaker_chn = [1:32 34:42 44:59 61:63];
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



band_name = {'alpha'};


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
        %         bandName = strcat(' 64Hz theta speakerEEG mTRF Listener',dataName(1:3),' lambda',num2str(lambda),' 10-55s');
        
        
        %% CounterBalanceTable
        load(strcat('E:\DataProcessing\speaker-listener_experiment\CountBalanceTable\CountBalanceTable_listener',dataName(1:3),'.mat'));
        % speaker story number
        speaker_story_read_order = zeros(1,14);
        speaker_story_retell_order = zeros(1,14);
        
        if strcmp(Type{1},'reading')
            % reading part first
            for ii = 1 : 14
                speaker_story_read_order(ii) = str2double(left{ii}(5:6));
            end
            
            for ii = 15 : 28
                speaker_story_retell_order(ii-14)  = str2double(left{ii}(5:6));
            end
        else
            % retell part first
            for ii = 1 : 14
                speaker_story_retell_order(ii) = str2double(left{ii}(5:6));
            end
            
            for ii = 15 : 28
                speaker_story_read_order(ii-14) = str2double(left{ii}(5:6));
            end
        end
        
        
        
        %% load speaker data
        
        % data name
        data_speakerA_retell = strcat('data_speakerA_retell_',band_file_name,'_valid');
        data_speakerB_retell = strcat('data_speakerB_retell_',band_file_name,'_valid');
        data_speakerA_read = strcat('data_speakerA_read_',band_file_name,'_valid');
        data_speakerB_read = strcat('data_speakerB_read_',band_file_name,'_valid');
        
        % load data
        load('E:\DataProcessing\speaker-listener_experiment\SpeakerData\Speaker01-CFY-read_retell_valid_strict_1-8Hz.mat',...
            data_speakerA_retell,data_speakerA_read);
        load('E:\DataProcessing\speaker-listener_experiment\SpeakerData\Speaker02-FS-read_retell_valid_strict_1-8Hz.mat',...
            data_speakerB_retell,data_speakerB_read);
        
        % data
        data_speakerA_retell = eval(strcat('data_speakerA_retell_',band_file_name,'_valid'));
        data_speakerB_retell = eval(strcat('data_speakerB_retell_',band_file_name,'_valid'));
        data_speakerA_read = eval(strcat('data_speakerA_read_',band_file_name,'_valid'));
        data_speakerB_read = eval(strcat('data_speakerB_read_',band_file_name,'_valid'));
        
        if strcmp(Type{1},'reading')
            % reading part first
            data_EEG_speakerA = [data_speakerA_read(speaker_story_read_order) data_speakerA_retell(speaker_story_retell_order)];
            data_EEG_speakerB = [data_speakerB_read(speaker_story_read_order) data_speakerB_retell(speaker_story_retell_order)];
        else
            % retelling part first
            data_EEG_speakerA = [data_speakerA_retell(speaker_story_retell_order) data_speakerA_read(speaker_story_read_order)];
            data_EEG_speakerB = [data_speakerB_retell(speaker_story_retell_order) data_speakerB_read(speaker_story_read_order)];
            
        end
        
        
        
        %% load EEG data
        % load('E:\DataProcessing\speaker-listener_experiment\ListenerData\0-LZR-Listener-ICA-filter-reref-64Hz.mat');
        % load('E:\DataProcessing\speaker-listener_experiment\ListenerData\01-CYX-Listener-ICA-filter-reref-64Hz.mat')
        %     load(strcat('E:\DataProcessing\speaker-listener_experiment\ListenerData\',dataName,'.mat'),'data_filtered_theta');
        data_temp = strcat('data_filtered_',band_name{band_select});
        load(strcat('E:\DataProcessing\speaker-listener_experiment\ListenerData\',dataName,'.mat'),data_temp);
        
        % combine
        %     EEGBlock = data_filtered_theta.trial;
        
        EEGBlock = eval(strcat('data_filtered_',band_name{band_select},'.trial'));
        EEGBlock = EEGBlock';
        
        
        
        %% Attend Target
        
        attend_target_num = zeros(1,length(EEGBlock));
        for attend_story = 1 : length(EEGBlock)
            if strcmpi(AttendTarget(attend_story),'A')
                attend_target_num(attend_story) = 1;
            else
                attend_target_num(attend_story) = 0;
            end
        end
        
        
        %% timelag
        Fs = 64;
        % timelag = -250:500/32:500;
        timelag = -500:(1000/Fs):500;
        % timelag = timelag(33:49);
        %         timelag = 0;
        
        %% length
        start_time = 10;
        end_time = 55;
        Listener_time_index = (start_time+5)*Fs+1:(end_time+5)*Fs;
        speaker_time_index =  (start_time+5)*Fs+1:(end_time+5)*Fs;
        %     EEG_time = 15 * Fs : 60 * Fs;
        % clip_length = 5 * Fs;
        %
        % clipNum = round(EEG_time/clip_length);
        
        %     Audio_time = 10 * Fs : 55 * Fs;
        
        
        %% chn_sel
        Acc_attend = zeros(length(speaker_chn),length(timelag));
        Acc_unattend = zeros(length(speaker_chn),length(timelag));
        
        for chn = 1 : length(speaker_chn)
            chn_file_name = strcat(num2str(chn),'-',label66{speaker_chn(chn)});
            mkdir(chn_file_name);
            cd(chn_file_name);
            
            for j = 1 : length(timelag)
                %% mTRF intitial
                
                start_time = 0  + timelag(j);
                end_time = 0 + timelag(j);
                % lambda = 1e5;
                
                %% mTRF matrix intial
                train_mTRF_attend_w_total = zeros(length(listener_chn),(end_time-start_time)/(1000/Fs)+1,size(EEGBlock,1));
                train_mTRF_unattend_w_total = zeros(length(listener_chn),(end_time-start_time)/(1000/Fs)+1,size(EEGBlock,1));
                train_mTRF_attend_con_total = zeros(length(listener_chn),1,size(EEGBlock,1)-1);
                train_mTRF_unattend_con_total = zeros(length(listener_chn),1,size(EEGBlock,1)-1);
                
                train_mTRF_attend_w_train_all_story = cell(size(EEGBlock,1),1);
                train_mTRF_unattend_w_train_all_story = cell(size(EEGBlock,1),1);
                train_mTRF_attend_w_all_story_mean = cell(size(EEGBlock,1),1);
                train_mTRF_unattend_w_all_story_mean = cell(size(EEGBlock,1),1);
                
                
                recon_AttendDecoder_SpeakerA_corr = zeros(size(EEGBlock,1),1);
                recon_UnattendDecoder_SpeakerA_corr = zeros(size(EEGBlock,1),1);
                recon_AttendDecoder_SpeakerB_corr = zeros(size(EEGBlock,1),1);
                recon_UnattendDecoder_SpeakerB_corr = zeros(size(EEGBlock,1),1);
                
                p_recon_AttendDecoder_SpeakerA_corr = zeros(size(EEGBlock,1),1);
                p_recon_UnattendDecoder_SpeakerA_corr = zeros(size(EEGBlock,1),1);
                p_recon_AttendDecoder_SpeakerB_corr = zeros(size(EEGBlock,1),1);
                p_recon_UnattendDecoder_SpeakerB_corr = zeros(size(EEGBlock,1),1);
                
                MSE_recon_AttendDecoder_SpeakerA_corr = zeros(size(EEGBlock,1),1);
                MSE_recon_UnattendDecoder_SpeakerA_corr = zeros(size(EEGBlock,1),1);
                MSE_recon_AttendDecoder_SpeakerB_corr = zeros(size(EEGBlock,1),1);
                MSE_recon_UnattendDecoder_SpeakerB_corr = zeros(size(EEGBlock,1),1);
                
                
                %% mTRF train and test
                tic;
                % train process
                disp('Training...');
                for train_index = 1 : length(EEGBlock)
                    % train story
                    if strcmpi('A',AttendTarget{train_index})
                        Audio_attend_train = data_EEG_speakerA{train_index}(speaker_chn(chn),speaker_time_index);
                        Audio_unattend_train= data_EEG_speakerB{train_index}(speaker_chn(chn),speaker_time_index);
                    else
                        Audio_attend_train = data_EEG_speakerB{train_index}(speaker_chn(chn),speaker_time_index);
                        Audio_unattend_train = data_EEG_speakerA{train_index}(speaker_chn(chn),speaker_time_index);
                    end
                    
                    % train EEG
                    if strcmpi(Space(train_index),'left')
                        EEG_train =  EEGBlock{train_index}(listener_chn,Listener_time_index);
                    else
                        EEG_train = EEGBlock{train_index}(chn_re_index,:);
                        EEG_train =  EEG_train(listener_chn,Listener_time_index);
                    end
                    
                    %train process
                    [w_train_mTRF_attend,t_train_mTRF_attend,con_train_mTRF_attend] = mTRFtrain(Audio_attend_train',EEG_train',Fs,-1,start_time,end_time,lambda);
                    [w_train_mTRF_unattend,t_train_mTRF_unattend,con_train_mTRF_unattend] = mTRFtrain(Audio_unattend_train',EEG_train',Fs,-1,start_time,end_time,lambda);
                    
                    
                    % record all weights into one matrix
                    train_mTRF_attend_w_total(:,:,train_index) = w_train_mTRF_attend;
                    train_mTRF_attend_con_total(:,:,train_index) = con_train_mTRF_attend;
                    
                    train_mTRF_unattend_w_total(:,:,train_index) = w_train_mTRF_unattend;
                    train_mTRF_unattend_con_total(:,:,train_index) = con_train_mTRF_unattend;
                end
                
                % test
                for test_index = 1 : length(EEGBlock)
                    disp(strcat('Testing story',num2str(test_index),'...'));
                    train_index_select = setdiff(1 : length(EEGBlock),test_index);
                    
                    SpeaekerA_test = data_EEG_speakerA{test_index}(speaker_chn(chn),speaker_time_index);
                    SpeaekerB_test = data_EEG_speakerB{test_index}(speaker_chn(chn),speaker_time_index);
                    
                    
                    % test EEG
                    if strcmpi(Space(test_index),'left')
                        EEG_test =  EEGBlock{test_index}(listener_chn,Listener_time_index);
                    else
                        EEG_test = EEGBlock{test_index}(chn_re_index,:);
                        EEG_test =  EEG_test(listener_chn,Listener_time_index);
                    end
                    
                    % mean of weights
                    train_mTRF_attend_w_mean = mean(train_mTRF_attend_w_total(:,:,train_index_select),3);
                    train_mTRF_attend_con_mean = mean(train_mTRF_attend_con_total(:,:,train_index_select),3);
                    
                    train_mTRF_unattend_w_mean = mean(train_mTRF_unattend_w_total(:,:,train_index_select),3);
                    train_mTRF_unattend_con_mean = mean(train_mTRF_unattend_con_total(:,:,train_index_select),3);
                    
                    train_mTRF_attend_w_all_story_mean{test_index} = train_mTRF_attend_w_mean;
                    train_mTRF_unattend_w_all_story_mean{test_index} = train_mTRF_unattend_w_mean;
                    
                    train_mTRF_attend_w_train_all_story{test_index}= train_mTRF_attend_w_total(:,:,train_index_select);
                    train_mTRF_unattend_w_train_all_story{test_index} = train_mTRF_attend_con_total(:,:,train_index_select);
                    
                    % predict
                    
                    [~,recon_AttendDecoder_SpeakerA_corr(test_index),p_recon_AttendDecoder_SpeakerA_corr(test_index),MSE_recon_AttendDecoder_SpeakerA_corr(test_index)] =...
                        mTRFpredict(SpeaekerA_test',EEG_test',train_mTRF_attend_w_mean,Fs,-1,start_time,end_time,train_mTRF_attend_con_mean);
                    
                    [~,recon_AttendDecoder_SpeakerB_corr(test_index),p_recon_AttendDecoder_SpeakerB_corr(test_index),MSE_recon_AttendDecoder_SpeakerB_corr(test_index)] =...
                        mTRFpredict(SpeaekerB_test',EEG_test',train_mTRF_attend_w_mean,Fs,-1,start_time,end_time,train_mTRF_attend_con_mean);
                    
                    [~,recon_UnattendDecoder_SpeakerA_corr(test_index),p_recon_UnattendDecoder_SpeakerA_corr(test_index),MSE_recon_UnattendDecoder_SpeakerA_corr(test_index)] =...
                        mTRFpredict(SpeaekerA_test',EEG_test',train_mTRF_unattend_w_mean,Fs,-1,start_time,end_time,train_mTRF_unattend_con_mean);
                    
                    [~,recon_UnattendDecoder_SpeakerB_corr(test_index),p_recon_UnattendDecoder_SpeakerB_corr(test_index),MSE_recon_UnattendDecoder_SpeakerB_corr(test_index)] =...
                        mTRFpredict(SpeaekerB_test',EEG_test',train_mTRF_unattend_w_mean,Fs,-1,start_time,end_time,train_mTRF_unattend_con_mean);
                    
                end
                
                toc;
                
                % save data
                saveName = strcat('mTRF_speakerEEG_listenerEEG_result+',label66{speaker_chn(chn)},'-timelag',num2str(timelag(j)),'ms-',band_file_name,'.mat');
                %     saveName = strcat('mTRF_sound_EEG_result.mat');
                save(saveName,'recon_AttendDecoder_SpeakerA_corr','recon_UnattendDecoder_SpeakerA_corr' ,'recon_AttendDecoder_SpeakerB_corr','recon_UnattendDecoder_SpeakerB_corr',...
                    'p_recon_AttendDecoder_SpeakerA_corr','p_recon_UnattendDecoder_SpeakerA_corr', 'p_recon_AttendDecoder_SpeakerB_corr','p_recon_UnattendDecoder_SpeakerB_corr',...
                    'MSE_recon_AttendDecoder_SpeakerA_corr','MSE_recon_UnattendDecoder_SpeakerA_corr','MSE_recon_AttendDecoder_SpeakerB_corr','MSE_recon_UnattendDecoder_SpeakerB_corr',...
                    'attend_target_num');
            end
            
            p = pwd;
            cd(p(1:end-(length(chn_file_name)+1)));
        end
        
        p = pwd;
        cd(p(1:end-(length(file_name)+1)));
    end
    
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end
