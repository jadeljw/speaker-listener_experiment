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

mkdir('mTRF');
cd('mTRF');


%% initial
load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';


band_name = {'alpha','delta','theta'};
% band_name = {'beta'};

story_num = 28;
listener_num = 20;
nComp = 3;

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    
    
    for listener_select = 1 : listener_num
        
        %% listener name
        if listener_select < 10
            file_name = strcat('listener10',num2str(listener_select));
        else
            file_name = strcat('listener1',num2str(listener_select));
        end
        
        mkdir(file_name);
        cd(file_name);
        
        %% band name
        lambda = 2^10;
        %         bandName = strcat(' 64Hz theta speakerEEG mTRF Listener',dataName(1:3),' lambda',num2str(lambda),' 10-55s');
        
        
        %% CounterBalanceTable
        load(strcat('E:\DataProcessing\speaker-listener_experiment\CountBalanceTable\CountBalanceTable_listener',file_name(end-2:end),'.mat'));
        % speaker story number
        Listener_story_order = zeros(1,28);
        
        if strcmp(Type{1},'reading')
            % reading part first
            for ii = 1 : 14
                speech_index = str2double(left{ii}(5:6));
                Listener_story_order(speech_index) = ii;
            end
            
            for ii = 15 : 28
                
                speech_index = str2double(left{ii}(5:6));
                % correct index
                if speech_index == 15
                    speech_index = 8;
                end
                Listener_story_order(speech_index+14)  = ii;
            end
        else
            % retell part first
            for ii = 1 : 14
                speech_index = str2double(left{ii}(5:6));
                % correct index
                if speech_index == 15
                    speech_index = 8;
                end
                Listener_story_order(speech_index+14)  = ii;
            end
            
            for ii = 15 : 28
                speech_index = str2double(left{ii}(5:6));
                Listener_story_order(speech_index) = ii;
            end
        end
        
        
        
        %% load speaker data
        load(strcat('E:\DataProcessing\speaker-listener_experiment\mfiles\RCA\Speaker\',band_file_name,'\RCA speaker-',band_file_name));
        
        data_EEG_speakerA = dataOut.All{1};
        data_EEG_speakerB = dataOut.All{2};
        
        
        %% load EEG data
        load(strcat('E:\DataProcessing\speaker-listener_experiment\mfiles\RCA\Listener\',band_file_name,'\RCA Listener-',band_file_name));
        
        EEGBlock = dataOut{listener_select};
        EEGBlcok = EEGBlock(:,:,Listener_story_order);
        
   %% Attend Target
          attend_target_num = zeros(1,length(Listener_story_order));
          for attend_story = 1 : length(Listener_story_order)
              if strcmpi(AttendTarget(Listener_story_order(attend_story)),'A')
                  attend_target_num(attend_story) = 1;
              else
                  attend_target_num(attend_story) = 0;
              end
          end
        
        %% delete missing match trail
        
        data_EEG_speakerA(:,:,22) = [];
        data_EEG_speakerB(:,:,22) = [];
        EEGBlock(:,:,22) = [];
        attend_target_num(22) = [];
        

        %% timelag
        Fs = 64;
        % timelag = -250:500/32:500;
        timelag = -500:(1000/Fs):500;
        % timelag = timelag(33:49);
        %         timelag = 0;
        
        %% length
        start_time = 10;
        end_time = 55;
        
        
        for j = 1 : length(timelag)
            %% mTRF intitial
            
            start_time = 0  + timelag(j);
            end_time = 0 + timelag(j);
            % lambda = 1e5;
            
            %% mTRF matrix intial
            train_mTRF_attend_w_total = zeros(size(EEGBlock,2),(end_time-start_time)/(1000/Fs)+1,nComp,size(EEGBlock,3));
            train_mTRF_unattend_w_total = zeros(size(EEGBlock,2),(end_time-start_time)/(1000/Fs)+1,nComp,size(EEGBlock,3));
            train_mTRF_attend_con_total = zeros(size(EEGBlock,2),nComp);
            train_mTRF_unattend_con_total = zeros(size(EEGBlock,2),nComp);
            
            
            
            train_mTRF_attend_w_trans_total = zeros(size(EEGBlock,2),(end_time-start_time)/(1000/Fs)+1,nComp,size(EEGBlock,3));
            train_mTRF_unattend_w_trans_total = zeros(size(EEGBlock,2),(end_time-start_time)/(1000/Fs)+1,nComp,size(EEGBlock,3));
            train_mTRF_attend_con_trans_total = zeros(size(EEGBlock,2),nComp);
            train_mTRF_unattend_con_trans_total = zeros(size(EEGBlock,2),nComp);
            
            
            %             train_mTRF_attend_w_train_all_story = cell(size(EEGBlock,1),1);
            %             train_mTRF_unattend_w_train_all_story = cell(size(EEGBlock,1),1);
            %             train_mTRF_attend_w_all_story_mean = cell(size(EEGBlock,1),1);
            %             train_mTRF_unattend_w_all_story_mean = cell(size(EEGBlock,1),1);
            
            
            recon_AttendDecoder_SpeakerA_corr = zeros(size(EEGBlock,3),nComp);
            recon_UnattendDecoder_SpeakerA_corr = zeros(size(EEGBlock,3),nComp);
            recon_AttendDecoder_SpeakerB_corr = zeros(size(EEGBlock,3),nComp);
            recon_UnattendDecoder_SpeakerB_corr = zeros(size(EEGBlock,3),nComp);
            
            p_recon_AttendDecoder_SpeakerA_corr = zeros(size(EEGBlock,3),nComp);
            p_recon_UnattendDecoder_SpeakerA_corr = zeros(size(EEGBlock,3),nComp);
            p_recon_AttendDecoder_SpeakerB_corr = zeros(size(EEGBlock,3),nComp);
            p_recon_UnattendDecoder_SpeakerB_corr = zeros(size(EEGBlock,3),nComp);
            
            MSE_recon_AttendDecoder_SpeakerA_corr = zeros(size(EEGBlock,3),nComp);
            MSE_recon_UnattendDecoder_SpeakerA_corr = zeros(size(EEGBlock,3),nComp);
            MSE_recon_AttendDecoder_SpeakerB_corr = zeros(size(EEGBlock,3),nComp);
            MSE_recon_UnattendDecoder_SpeakerB_corr = zeros(size(EEGBlock,3),nComp);
            

            %% mTRF train and test
            tic;
            % train process
            disp('Training...');
            for train_index = 1 : size(EEGBlock,3)
                % train story
                if  attend_target_num(train_index) == 1 % attend A
                    Audio_attend_train = data_EEG_speakerA(:,:,train_index);
                    Audio_unattend_train= data_EEG_speakerB(:,:,train_index);
                else
                    Audio_attend_train = data_EEG_speakerB(:,:,train_index);
                    Audio_unattend_train = data_EEG_speakerA(:,:,train_index);
                end
                
                % train EEG
              EEG_train =  EEGBlock(:,:,train_index);

                %train process
                [w_train_mTRF_attend,t_train_mTRF_attend,con_train_mTRF_attend] = mTRFtrain(Audio_attend_train,EEG_train,Fs,-1,start_time,end_time,lambda);
                [w_train_mTRF_unattend,t_train_mTRF_unattend,con_train_mTRF_unattend] = mTRFtrain(Audio_unattend_train,EEG_train,Fs,-1,start_time,end_time,lambda);
                
                % transfrom
                [w_train_mTRF_trans_attend,t_train_mTRF_trans_attend,con_train_mTRF_trans_attend] = ...
                    mTRFtransform(Audio_attend_train,EEG_train,w_train_mTRF_attend,Fs,-1,start_time,end_time,con_train_mTRF_attend);
                [w_train_mTRF_trans_unattend,t_train_mTRF_trans_unattend,con_train_mTRF_trans_unattend] = ...
                    mTRFtransform(Audio_unattend_train,EEG_train,w_train_mTRF_unattend,Fs,-1,start_time,end_time,con_train_mTRF_unattend);
                
                
                % record all weights into one matrix
                train_mTRF_attend_w_total(:,:,:,train_index) = w_train_mTRF_attend;
                train_mTRF_attend_con_total(:,:,train_index) = con_train_mTRF_attend;
                
                train_mTRF_unattend_w_total(:,:,:,train_index) = w_train_mTRF_unattend;
                train_mTRF_unattend_con_total(:,:,train_index) = con_train_mTRF_unattend;
                
                train_mTRF_attend_w_trans_total(:,:,:,train_index) = w_train_mTRF_trans_attend;
                train_mTRF_attend_con_trans_total(:,:,train_index) = con_train_mTRF_trans_attend;
                
                train_mTRF_unattend_w_trans_total(:,:,:,train_index) = w_train_mTRF_trans_unattend;
                train_mTRF_unattend_con_trans_total(:,:,train_index) = con_train_mTRF_trans_unattend;
            end
            
            % test
            for test_index = 1 : size(EEGBlock,3)
                disp(strcat('Testing story',num2str(test_index),'...'));
                train_index_select = setdiff(1 : size(EEGBlock,3),test_index);
                
                SpeaekerA_test = data_EEG_speakerA(:,:,test_index);
                SpeaekerB_test = data_EEG_speakerB(:,:,test_index);
                
                
                % test EEG
                EEG_test =  EEGBlock(:,:,test_index);
                
                % mean of weights
                train_mTRF_attend_w_mean = mean(train_mTRF_attend_w_total(:,:,:,train_index_select),4);
                train_mTRF_attend_con_mean = mean(train_mTRF_attend_con_total(:,:,train_index_select),3);
                
                train_mTRF_unattend_w_mean = mean(train_mTRF_unattend_w_total(:,:,:,train_index_select),4);
                train_mTRF_unattend_con_mean = mean(train_mTRF_unattend_con_total(:,:,train_index_select),3);
                
                %                     train_mTRF_attend_w_all_story_mean{test_index} = train_mTRF_attend_w_mean;
                %                     train_mTRF_unattend_w_all_story_mean{test_index} = train_mTRF_unattend_w_mean;
                
                %                     train_mTRF_attend_w_train_all_story{test_index}= train_mTRF_attend_w_total(:,:,train_index_select);
                %                     train_mTRF_unattend_w_train_all_story{test_index} = train_mTRF_attend_con_total(:,:,train_index_select);
                
                % predict
                
                [~,recon_AttendDecoder_SpeakerA_corr(test_index,:),p_recon_AttendDecoder_SpeakerA_corr(test_index,:),MSE_recon_AttendDecoder_SpeakerA_corr(test_index,:)] =...
                    mTRFpredict(SpeaekerA_test,EEG_test,train_mTRF_attend_w_mean,Fs,-1,start_time,end_time,train_mTRF_attend_con_mean);
                
                [~,recon_AttendDecoder_SpeakerB_corr(test_index,:),p_recon_AttendDecoder_SpeakerB_corr(test_index,:),MSE_recon_AttendDecoder_SpeakerB_corr(test_index,:)] =...
                    mTRFpredict(SpeaekerB_test,EEG_test,train_mTRF_attend_w_mean,Fs,-1,start_time,end_time,train_mTRF_attend_con_mean);
                
                [~,recon_UnattendDecoder_SpeakerA_corr(test_index,:),p_recon_UnattendDecoder_SpeakerA_corr(test_index,:),MSE_recon_UnattendDecoder_SpeakerA_corr(test_index,:)] =...
                    mTRFpredict(SpeaekerA_test,EEG_test,train_mTRF_unattend_w_mean,Fs,-1,start_time,end_time,train_mTRF_unattend_con_mean);
                
                [~,recon_UnattendDecoder_SpeakerB_corr(test_index,:),p_recon_UnattendDecoder_SpeakerB_corr(test_index,:),MSE_recon_UnattendDecoder_SpeakerB_corr(test_index,:)] =...
                    mTRFpredict(SpeaekerB_test,EEG_test,train_mTRF_unattend_w_mean,Fs,-1,start_time,end_time,train_mTRF_unattend_con_mean);
                
            end
            
            toc;
            
            
            tic;
            % save data
            saveName = strcat('mTRF_speaker_listenerEEG_RCA_result-timelag',num2str(timelag(j)),'ms-',band_file_name,'.mat');
            %     saveName = strcat('mTRF_sound_EEG_result.mat');
            save(saveName,'recon_AttendDecoder_SpeakerA_corr','recon_UnattendDecoder_SpeakerA_corr' ,'recon_AttendDecoder_SpeakerB_corr','recon_UnattendDecoder_SpeakerB_corr',...
                'p_recon_AttendDecoder_SpeakerA_corr','p_recon_UnattendDecoder_SpeakerA_corr', 'p_recon_AttendDecoder_SpeakerB_corr','p_recon_UnattendDecoder_SpeakerB_corr',...
                'MSE_recon_AttendDecoder_SpeakerA_corr','MSE_recon_UnattendDecoder_SpeakerA_corr','MSE_recon_AttendDecoder_SpeakerB_corr','MSE_recon_UnattendDecoder_SpeakerB_corr',...
                'attend_target_num',...
                'train_mTRF_attend_w_total','train_mTRF_unattend_w_total','train_mTRF_attend_w_trans_total','train_mTRF_unattend_w_trans_total');
            toc;
        end
        
        
        
        p = pwd;
        cd(p(1:end-(length(file_name)+1)));
    end
    
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end

