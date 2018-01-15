% mTRF for speaker-listener-new-experiment data
% Experiment date : 2017.7.5
% purpose: mTRF validation
% by:LJW

% revised 11.19 for speaker-listener experiment
% using mTRF 1.5 toolbox
%% initial
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

for i = 5 : 20
    
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
    lambda = 2^5;
    band_name = strcat(' 64Hz 2-8Hz sound from wav Listener',dataName(1:3),' lambda',num2str(lambda),' 10-55s');
    
    %% load sound data from wav
    % % load('E:\DataProcessing\speaker-listener_experiment\AudioData\Audio_envelope_64Hz_hilbert_cell.mat');
    % load('E:\DataProcessing\speaker-listener_experiment\AudioData\from wav\Listener01_Audio_envelope_hilbert_first_64Hz_keep_order.mat');
    % load('E:\DataProcessing\speaker-listener_experiment\AudioData\from wav\Listener0_Audio_envelope_hilbert_first_64Hz_keep_order.mat');
    % load('E:\DataProcessing\speaker-listener_experiment\AudioData\from wav\Listener101_Audio_envelope_hilbert_first_64Hz_keep_order.mat');
    load(strcat('E:\DataProcessing\speaker-listener_experiment\AudioData\from wav\Listener',dataName(1:3),'_Audio_envelope_hilbert_first_64Hz_keep_order.mat'));
    
    
    %% load EEG data
    % load('E:\DataProcessing\speaker-listener_experiment\ListenerData\0-LZR-Listener-ICA-filter-reref-64Hz.mat');
    % load('E:\DataProcessing\speaker-listener_experiment\ListenerData\01-CYX-Listener-ICA-filter-reref-64Hz.mat')
    load(strcat('E:\DataProcessing\speaker-listener_experiment\ListenerData\',dataName,'.mat'),'data_filtered_theta');
    
    
    % combine
    EEGBlock = data_filtered_theta.trial;
    EEGBlock = EEGBlock';
    
    %% attend stream
    % attend_stream = 1;
    % load('E:\DataProcessing\speaker-listener_experiment\Attend_Target.mat');
    % AttendTarget = [Retell_AttendTarget;Read_AttendTarget];
    % load('CountBalanceTable_listener0_analysis.mat')
    % load('CountBalanceTable_listener01.mat')
    
    load(strcat('G:\Speaker-listener_experiment\listener\data\',dataFile,'\CountBalanceTable_listener',dataName(1:3),'.mat'));
    % load(strcat('H:\Speaker-listener2017\data\',dataFile,'\CountBalanceTable_listener',dataName(1:3),'.mat'));
    % % load(strcat('E:\DataProcessing\speaker-listener_experiment\counterbalanceTable\CountBalanceTable_listener',dataName(1:3),'.mat'));
    %
    %% timelag
    Fs = 64;
    % timelag = -250:500/32:500;
    timelag = -250:(1000/Fs):500;
    % timelag = timelag(33:49);
%     timelag = 0;
    
    %% length
    EEG_time = 15 * Fs : 60 * Fs;
    % clip_length = 5 * Fs;
    %
    % clipNum = round(EEG_time/clip_length);
    
    Audio_time = 10*Fs : 55 * Fs;
    
    
    %% chn_sel
    chn_sel_index = [1:32 34:42 44:59 61:63];
    
    
    for j = 1 : length(timelag)
        %% mTRF intitial
        
        start_time = 0 + timelag(j);
        end_time = 0 + timelag(j);
        % lambda = 1e5;
        
        %% mTRF matrix intial
        train_mTRF_attend_w_total = zeros(length(chn_sel_index),(end_time-start_time)/(1000/Fs)+1,size(EEGBlock,1)-1);
        train_mTRF_unattend_w_total = zeros(length(chn_sel_index),(end_time-start_time)/(1000/Fs)+1,size(EEGBlock,1)-1);
        train_mTRF_attend_con_total = zeros(length(chn_sel_index),1,size(EEGBlock,1)-1);
        train_mTRF_unattend_con_total = zeros(length(chn_sel_index),1,size(EEGBlock,1)-1);
        
        train_mTRF_attend_w_train_all_story = cell(size(EEGBlock,1),1);
        train_mTRF_unattend_w_train_all_story = cell(size(EEGBlock,1),1);
        train_mTRF_attend_w_all_story_mean = cell(size(EEGBlock,1),1);
        train_mTRF_unattend_w_all_story_mean = cell(size(EEGBlock,1),1);
        
        
        recon_AttendDecoder_attend_corr = zeros(size(EEGBlock,1),1);
        recon_UnattendDecoder_unattend_corr = zeros(size(EEGBlock,1),1);
        recon_AttendDecoder_unattend_corr = zeros(size(EEGBlock,1),1);
        recon_UnattendDecoder_attend_corr = zeros(size(EEGBlock,1),1);
        
        p_recon_AttendDecoder_attend_corr = zeros(size(EEGBlock,1),1);
        p_recon_UnattendDecoder_unattend_corr = zeros(size(EEGBlock,1),1);
        p_recon_AttendDecoder_unattend_corr = zeros(size(EEGBlock,1),1);
        p_recon_UnattendDecoder_attend_corr = zeros(size(EEGBlock,1),1);
        
        MSE_recon_AttendDecoder_attend_corr = zeros(size(EEGBlock,1),1);
        MSE_recon_UnattendDecoder_unattend_corr = zeros(size(EEGBlock,1),1);
        MSE_recon_AttendDecoder_unattend_corr = zeros(size(EEGBlock,1),1);
        MSE_recon_UnattendDecoder_attend_corr = zeros(size(EEGBlock,1),1);
        
        recon_AttendDecoder_attend_corr_train = zeros(size(EEGBlock,1)-1,size(EEGBlock,1));
        recon_UnattendDecoder_unattend_corr_train =  zeros(size(EEGBlock,1)-1,size(EEGBlock,1));
        recon_AttendDecoder_unattend_corr_train =  zeros(size(EEGBlock,1)-1,size(EEGBlock,1));
        recon_UnattendDecoder_attend_corr_train =  zeros(size(EEGBlock,1)-1,size(EEGBlock,1));
        
        p_recon_AttendDecoder_attend_corr_train =  zeros(size(EEGBlock,1)-1,size(EEGBlock,1));
        p_recon_UnattendDecoder_unattend_corr_train =  zeros(size(EEGBlock,1)-1,size(EEGBlock,1));
        p_recon_AttendDecoder_unattend_corr_train =  zeros(size(EEGBlock,1)-1,size(EEGBlock,1));
        p_recon_UnattendDecoder_attend_corr_train =  zeros(size(EEGBlock,1)-1,size(EEGBlock,1));
        
        MSE_recon_AttendDecoder_attend_corr_train =  zeros(size(EEGBlock,1)-1,size(EEGBlock,1));
        MSE_recon_UnattendDecoder_unattend_corr_train =  zeros(size(EEGBlock,1)-1,size(EEGBlock,1));
        MSE_recon_AttendDecoder_unattend_corr_train =  zeros(size(EEGBlock,1)-1,size(EEGBlock,1));
        MSE_recon_UnattendDecoder_attend_corr_train =  zeros(size(EEGBlock,1)-1,size(EEGBlock,1));
        
        %% mTRF train and test
        for test_index = 1 : length(EEGBlock)
            
            % test data
            if strcmpi(Space(test_index),'left')
                Audio_attend_test = data_left{test_index}(Audio_time)';
                Audio_unattend_test = data_right{test_index}(Audio_time)';
            else
                Audio_attend_test = data_right{test_index}(Audio_time)';
                Audio_unattend_test = data_left{test_index}(Audio_time)';
            end
            
            % EEG
            EEG_test =  EEGBlock{test_index}(chn_sel_index,EEG_time);
            
            disp(strcat('Training story',num2str(test_index),'...'));
            
            % traing process
            cnt_train_index = 1;
            for train_index = 1 : length(EEGBlock)
                if train_index ~= test_index
                    
                    % train story
                    if strcmpi(Space(train_index),'left')
                        Audio_attend_train = data_left{train_index}(Audio_time)';
                        Audio_unattend_train= data_right{train_index}(Audio_time)';
                    else
                        Audio_attend_train = data_right{train_index}(Audio_time)';
                        Audio_unattend_train = data_left{train_index}(Audio_time)';
                    end
                    
                    % train EEG
                    EEG_train =  EEGBlock{train_index}(chn_sel_index,EEG_time);
                    
                    %train process
                    [w_train_mTRF_attend,t_train_mTRF_attend,con_train_mTRF_attend] = mTRFtrain(Audio_attend_train',EEG_train',Fs,-1,start_time,end_time,lambda);
                    [w_train_mTRF_unattend,t_train_mTRF_unattend,con_train_mTRF_unattend] = mTRFtrain(Audio_unattend_train',EEG_train',Fs,-1,start_time,end_time,lambda);
                    
                    
                    % record all weights into one matrix
                    train_mTRF_attend_w_total(:,:,cnt_train_index) = w_train_mTRF_attend;
                    train_mTRF_attend_con_total(:,:,cnt_train_index) = con_train_mTRF_attend;
                    
                    train_mTRF_unattend_w_total(:,:,cnt_train_index) = w_train_mTRF_unattend;
                    train_mTRF_unattend_con_total(:,:,cnt_train_index) = con_train_mTRF_unattend;
                    
                    train_mTRF_attend_w_train_all_story{test_index}= train_mTRF_attend_w_total;
                    train_mTRF_unattend_w_train_all_story{test_index} = train_mTRF_unattend_w_total;
                    
                    cnt_train_index = cnt_train_index + 1;
                end
                
            end
            
            
            % mean of weights
            train_mTRF_attend_w_mean = mean(train_mTRF_attend_w_total,3);
            train_mTRF_attend_con_mean = mean(train_mTRF_attend_con_total,3);
            
            train_mTRF_unattend_w_mean = mean(train_mTRF_unattend_w_total,3);
            train_mTRF_unattend_con_mean = mean(train_mTRF_unattend_con_total,3);
            
            train_mTRF_attend_w_all_story_mean{test_index} = train_mTRF_attend_w_mean;
            train_mTRF_unattend_w_all_story_mean{test_index} = train_mTRF_unattend_w_mean;
            
            % predict
            disp(strcat('Testing story',num2str(test_index),'...'));
            
            [recon_audio_attend_AttendDecoder,recon_AttendDecoder_attend_corr(test_index),p_recon_AttendDecoder_attend_corr(test_index),MSE_recon_AttendDecoder_attend_corr(test_index)] =...
                mTRFpredict(Audio_attend_test',EEG_test',train_mTRF_attend_w_mean,Fs,-1,start_time,end_time,train_mTRF_attend_con_mean);
            
            [recon_audio_unattend_AttendDecoder,recon_AttendDecoder_unattend_corr(test_index),p_recon_AttendDecoder_unattend_corr(test_index),MSE_recon_AttendDecoder_unattend_corr(test_index)] =...
                mTRFpredict(Audio_unattend_test',EEG_test',train_mTRF_attend_w_mean,Fs,-1,start_time,end_time,train_mTRF_attend_con_mean);
            
            [recon_audio_unattend_unAttendDecoder,recon_UnattendDecoder_unattend_corr(test_index),p_recon_UnattendDecoder_unattend_corr(test_index),MSE_recon_UnattendDecoder_unattend_corr(test_index)] =...
                mTRFpredict(Audio_unattend_test',EEG_test',train_mTRF_unattend_w_mean,Fs,-1,start_time,end_time,train_mTRF_unattend_con_mean);
            
            [recon_audio_attend_unAttendDecoder,recon_UnattendDecoder_attend_corr(test_index),p_recon_UnattendDecoder_attend_corr(test_index),MSE_recon_UnattendDecoder_attend_corr(test_index)] =...
                mTRFpredict(Audio_attend_test',EEG_test',train_mTRF_unattend_w_mean,Fs,-1,start_time,end_time,train_mTRF_unattend_con_mean);
            
            cnt_train_index = 1;
            for train_index = 1 : length(EEGBlock)
                % train audio
                %             if attend_stream == 1
                %                 Audio_attend_train = AudioEnv{train_index}(1,EEG_time);
                %                 Audio_unattend_train= AudioEnv{train_index}(2,EEG_time);
                %             else
                %                 Audio_attend_train = AudioEnv{train_index}(2,EEG_time);
                %                 Audio_unattend_train = AudioEnv{train_index}(1,EEG_time);
                %             end
                %             if  strcmpi('A',AttendTarget{train_index})
                %                 Audio_attend_train = AudioA_total{train_index}(Audio_time);
                %                 Audio_unattend_train = AudioB_total{train_index}(Audio_time);
                %             else
                %                 Audio_attend_train = AudioB_total{train_index}(Audio_time);
                %                 Audio_unattend_train = AudioA_total{train_index}(Audio_time);
                %             end
                
                if strcmpi(Space(train_index),'left')
                    Audio_attend_train = data_left{train_index}(Audio_time)';
                    Audio_unattend_train= data_right{train_index}(Audio_time)';
                else
                    Audio_attend_train = data_right{train_index}(Audio_time)';
                    Audio_unattend_train = data_left{train_index}(Audio_time)';
                end
                
                
                % train EEG
                EEG_train =  EEGBlock{train_index}(chn_sel_index,EEG_time);
                
                % apply weights to individual story
                [recon_audio_attend_AttendDecoder_train,recon_AttendDecoder_attend_corr_train(cnt_train_index,test_index),p_recon_AttendDecoder_attend_corr_train(cnt_train_index,test_index),MSE_recon_AttendDecoder_attend_corr_train(cnt_train_index,test_index)] =...
                    mTRFpredict(Audio_attend_train',EEG_train',train_mTRF_attend_w_mean,Fs,-1,start_time,end_time,con_train_mTRF_attend);
                
                [recon_audio_unattend_AttendDecoder_train,recon_AttendDecoder_unattend_corr_train(cnt_train_index,test_index),p_recon_AttendDecoder_unattend_corr_train(cnt_train_index,test_index),MSE_recon_AttendDecoder_unattend_corr_train(cnt_train_index,test_index)] =...
                    mTRFpredict(Audio_unattend_train',EEG_train',train_mTRF_attend_w_mean,Fs,-1,start_time,end_time,con_train_mTRF_attend);
                
                [recon_audio_unattend_unAttendDecoder_train,recon_UnattendDecoder_unattend_corr_train(cnt_train_index,test_index),p_recon_UnattendDecoder_unattend_corr_train(cnt_train_index,test_index),MSE_recon_UnattendDecoder_unattend_corr_train(cnt_train_index,test_index)] =...
                    mTRFpredict(Audio_unattend_train',EEG_train',train_mTRF_unattend_w_mean,Fs,-1,start_time,end_time,con_train_mTRF_unattend);
                
                [recon_audio_attend_unAttendDecoder_train,recon_UnattendDecoder_attend_corr_train(cnt_train_index,test_index),p_recon_UnattendDecoder_attend_corr_train(cnt_train_index,test_index),MSE_recon_UnattendDecoder_attend_corr_train(cnt_train_index,test_index)] =...
                    mTRFpredict(Audio_attend_train',EEG_train',train_mTRF_unattend_w_mean,Fs,-1,start_time,end_time,con_train_mTRF_unattend);
                cnt_train_index = cnt_train_index + 1;
            end
        end
        
        
        %% timelag plot
        mkdir('timelag plot');
        cd('timelag plot');
        % reconstruction accuracy plot attend
        figure('visible','off'); plot(mean(recon_AttendDecoder_attend_corr,2),'r');
        hold on; plot(mean(recon_AttendDecoder_unattend_corr,2),'b');
        xlabel('Subject No.'); ylabel('r value')
        saveName1 = strcat('Reconstruction Accuracy using mTRF method for attend decoder+',num2str(timelag(j)),'ms',band_name,'.jpg');
        % saveName1 = strcat('Reconstruction Accuracy using mTRF method for attend decoder.jpg');
        title(saveName1(1:end-4));
        legend('Audio attend ','Audio not Attend')
        saveas(gcf,saveName1);
        close
        
        % reconstruction accuracy plot unattend
        figure('visible','off'); plot(mean(recon_UnattendDecoder_attend_corr,2),'r');
        hold on; plot(mean(recon_UnattendDecoder_unattend_corr,2),'b');
        xlabel('Subject No.'); ylabel('r value')
        saveName2 = strcat('Reconstruction Accuracy using mTRF method for unattend decoder+',num2str(timelag(j)),'ms',band_name,'.jpg');
        % saveName2 = strcat('Reconstruction Accuracy using mTRF method for unattend decoder.jpg');
        title(saveName2(1:end-4));
        legend('Audio attend ','Audio not Attend')
        saveas(gcf,saveName2);
        close
        
        % Decoding accuracy plot attend
        Decoding_result_attend_decoder = recon_AttendDecoder_attend_corr-recon_AttendDecoder_unattend_corr;
        Individual_subjects_result_attend = sum(Decoding_result_attend_decoder>0)/length(EEGBlock);
        mean(Individual_subjects_result_attend)
        Decoding_result_unattend_decoder = recon_UnattendDecoder_unattend_corr-recon_UnattendDecoder_attend_corr;
        Individual_subjects_result_unattend = sum(Decoding_result_unattend_decoder>0)/length(EEGBlock);
        mean(Individual_subjects_result_unattend)
        figure('visible','off'); plot(Decoding_result_attend_decoder,'r');
        hold on; plot(Decoding_result_unattend_decoder,'b');
        xlabel('Subject No.'); ylabel('Difference');ylim([-0.2 0.2]);
        saveName3 = strcat('Decoding accuracy using mTRF method for attend and unattend decoder+',num2str(timelag(j)),'ms',band_name,'.jpg');
        % saveName3 = strcat('Decoding accuracy using mTRF method for attend and unattend decoder.jpg');
        title(saveName3(1:end-4))
        legend('Attend Decoder','Unattend Decoder')
        saveas(gcf,saveName3);
        close
        
        p = pwd;
        cd(p(1:end-(length('timelag plot')+1)));
        %% topoplot
        
        mkdir('topoplot');
        cd('topoplot');
        subplot(121);
        U_topoplot(abs(zscore(train_mTRF_attend_w_mean)),layout,label66(listener_chn));%plot(w_A(:,1));
        title('Attended decoder');
        subplot(122);
        U_topoplot(abs(zscore(train_mTRF_unattend_w_mean)),layout,label66(listener_chn));%plot(v_B(:,1));
        title('Unattended decoder');
        save_name = strcat(file_name,'-Topoplot-timelag ',num2str(timelag(j)),'ms.jpg');
        suptitle(save_name(1:end-4));
        saveas(gcf,save_name)
        close;
        p = pwd;
        cd(p(1:end-(length('topoplot')+1)));
        
        % save data
        saveName = strcat('mTRF_sound_EEG_result+',num2str(timelag(j)),'ms',band_name,'.mat');
        %     saveName = strcat('mTRF_sound_EEG_result.mat');
        save(saveName,'recon_AttendDecoder_attend_corr','recon_UnattendDecoder_unattend_corr' ,'recon_AttendDecoder_unattend_corr','recon_UnattendDecoder_attend_corr',...
            'p_recon_AttendDecoder_attend_corr','p_recon_UnattendDecoder_unattend_corr', 'p_recon_AttendDecoder_unattend_corr','p_recon_UnattendDecoder_attend_corr',...
            'MSE_recon_AttendDecoder_attend_corr','MSE_recon_UnattendDecoder_unattend_corr','MSE_recon_AttendDecoder_unattend_corr','MSE_recon_UnattendDecoder_attend_corr',...
            'recon_AttendDecoder_attend_corr_train','recon_UnattendDecoder_unattend_corr_train' ,'recon_AttendDecoder_unattend_corr_train','recon_UnattendDecoder_attend_corr_train',...
            'p_recon_AttendDecoder_attend_corr_train','p_recon_UnattendDecoder_unattend_corr_train', 'p_recon_AttendDecoder_unattend_corr_train','p_recon_UnattendDecoder_attend_corr_train',...
            'MSE_recon_AttendDecoder_attend_corr_train','MSE_recon_UnattendDecoder_unattend_corr_train','MSE_recon_AttendDecoder_unattend_corr_train','MSE_recon_UnattendDecoder_attend_corr_train',...
            'train_mTRF_attend_w_all_story_mean','train_mTRF_unattend_w_all_story_mean','train_mTRF_attend_w_train_all_story','train_mTRF_unattend_w_train_all_story');
    end
    
    p = pwd;
    cd(p(1:end-(length(file_name)+1)));
end
