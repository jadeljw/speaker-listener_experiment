%% speakerEEG mTRF forward model
% purpose: to test whether the speaker also has TRF response
% use forward model to reconstruct the audio envelope

% LJW
% 2018.3.11



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

%% data name
listener_num = 20;
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



mkdir('narrow_theta reverse zscore');
cd('narrow_theta reverse zscore');


for i = 1 : listener_num 
    
    %% listener name
    if i < 10
        file_name = strcat('listener10',num2str(i));
    else
        file_name = strcat('listener1',num2str(i));
    end
    
    mkdir(file_name);
    cd(file_name);
    disp(file_name);
    dataName =  dataName_all{i};
    dataFile = dataFile_all{i};
    
    
    
    %% band name
    lambda = 2^10;
    %     band_name = strcat(' 64Hz narrow_theta speakerEEG mTRF Listener',dataName(1:3),' lambda',num2str(lambda),' 10-55s');
    
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
    
    % boradband
    load('E:\DataProcessing\speaker-listener_experiment\SpeakerData\Speaker01-CFY-read_retell_valid_strict_1-8Hz.mat',...
        'data_speakerA_retell_narrow_theta_valid','data_speakerA_read_narrow_theta_valid');
    load('E:\DataProcessing\speaker-listener_experiment\SpeakerData\Speaker02-FS-read_retell_valid_strict_1-8Hz.mat',...
        'data_speakerB_retell_narrow_theta_valid','data_speakerB_read_narrow_theta_valid');

    
    if strcmp(Type{1},'reading')
        % reading part first
        data_EEG_speakerA = [data_speakerA_read_narrow_theta_valid(speaker_story_read_order) data_speakerA_retell_narrow_theta_valid(speaker_story_retell_order)];
        data_EEG_speakerB = [data_speakerB_read_narrow_theta_valid(speaker_story_read_order) data_speakerB_retell_narrow_theta_valid(speaker_story_retell_order)];
    else
        % retelling part first
        data_EEG_speakerA = [data_speakerA_retell_narrow_theta_valid(speaker_story_retell_order) data_speakerA_read_narrow_theta_valid(speaker_story_read_order)];
        data_EEG_speakerB = [data_speakerB_retell_narrow_theta_valid(speaker_story_retell_order) data_speakerB_read_narrow_theta_valid(speaker_story_read_order)];
        
    end
    %% timelag
    Fs = 64;
    timelag = 0;
    %     timelag = -250:(1000/Fs):500;
    % timelag = timelag(33:49);
    %     timelag = 0;
     timelag_for_plot = -250 : 1000/64 : 500;
     
    %% length
    start_time = 10;
    end_time = 55;
    Listener_time_index = (start_time+5)*Fs+1:(end_time+5)*Fs;
    speaker_time_index =  (start_time+5)*Fs+1:(end_time+5)*Fs;
    %     EEG_time = 15 * Fs : 60 * Fs;
    % clip_length = 5 * Fs;
    %
    % clipNum = round(EEG_time/clip_length);
    
    
    %% load EEG data
    load(strcat('E:\DataProcessing\speaker-listener_experiment\ListenerData\',dataName,'.mat'),'data_filtered_narrow_theta');
    
    % combine
    %     EEGBlock = data_filtered_narrow_theta.trial;
    EEGBlock = data_filtered_narrow_theta.trial;
    EEGBlock = EEGBlock';
    
    for jj = 1 : length(EEGBlock)
        
        % reverse
        if strcmpi(Space(jj),'left')
            EEG_train =  EEGBlock{jj}(listener_chn,Listener_time_index);
        else
            EEG_train = EEGBlock{jj}(chn_re_index,:);
            EEG_train =  EEG_train(listener_chn,Listener_time_index);
        end
        
        % EEG
        EEG_train = EEG_train';
        Listener_EEG_test{jj} = zscore(EEG_train);
    end
    
    %% chn_sel
    Acc_attend = zeros(length(speaker_chn),length(timelag));
    Acc_unattend = zeros(length(speaker_chn),length(timelag));
    
    for chn = 1 : length(speaker_chn)
        chn_file_name = strcat(num2str(chn),'-',label66{speaker_chn(chn)});
        disp(chn_file_name);
        
        for train_index = 1 : length(data_EEG_speakerA)
            % train story
            if strcmpi('A',AttendTarget{train_index})
                Speaker_EEG_attend{train_index} = data_EEG_speakerA{train_index}(speaker_chn(chn),speaker_time_index);
                
                Speaker_EEG_unattend{train_index}= data_EEG_speakerB{train_index}(speaker_chn(chn),speaker_time_index);
            else
                Speaker_EEG_attend{train_index} = data_EEG_speakerB{train_index}(speaker_chn(chn),speaker_time_index);
                Speaker_EEG_unattend{train_index} = data_EEG_speakerA{train_index}(speaker_chn(chn),speaker_time_index);
            end
            
            Speaker_EEG_attend{train_index} = zscore(Speaker_EEG_attend{train_index}');
            Speaker_EEG_unattend{train_index} = zscore(Speaker_EEG_unattend{train_index}');
        end
        
        
        
        
        %% mTRF intitial
        
        start_time = -250;
        end_time = 500;
        
        model_attend = zeros(length(Listener_EEG_test),length(timelag_for_plot),length(listener_chn)); % story * time point * chn
        model_unattend = zeros(length(Listener_EEG_test),length(timelag_for_plot),length(listener_chn)); % story * time point * chn
        
        
        h_attend = zeros(length(timelag_for_plot),length(listener_chn)); % story * time point * chn
        h_unattend = zeros(length(timelag_for_plot),length(listener_chn)); % story * time point * chn
        
        p_attend = zeros(length(timelag_for_plot),length(listener_chn)); % story * time point * chn
        p_unattend = zeros(length(timelag_for_plot),length(listener_chn)); % story * time point * chn
        
       %% mTRF train and test
        for train_story = 1 : length(Listener_EEG_test)
            model_attend(train_story,:,:) = mTRFtrain(Speaker_EEG_attend{train_story},Listener_EEG_test{train_story},Fs,1,start_time,end_time,lambda);
            model_unattend(train_story,:,:) = mTRFtrain(Speaker_EEG_unattend{train_story},Listener_EEG_test{train_story},Fs,1,start_time,end_time,lambda);
        end
        
        
        %% ttest
        for time_point = 1 : length(timelag_for_plot)
            for chn_listener = 1 : length(listener_chn)
            [h_attend(time_point,chn_listener),p_attend(time_point,chn_listener)] =ttest(model_attend(:,time_point,chn_listener));
            [h_unattend(time_point,chn_listener),p_unattend(time_point,chn_listener)] =ttest(model_unattend(:,time_point,chn_listener));
            end
        end
        
        %% save data
        saveName = strcat('mTRF_speakerEEG_listenerEEG_forward_result+',label66{speaker_chn(chn)},'-lambda',num2str(lambda),'.mat');
        %     saveName = strcat('mTRF_sound_EEG_result.mat');
        save(saveName,'model_attend','model_unattend',...
            'h_attend','h_unattend',...
            'p_attend','p_unattend');
        
        
    end
    
    p = pwd;
    cd(p(1:end-(length(file_name)+1)));
end