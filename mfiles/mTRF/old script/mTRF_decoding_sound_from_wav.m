% mTRF for speaker-listener-new-experiment data
% Experiment date : 2017.7.5
% purpose: mTRF validation
% by:LJW

%% data name
dataName = '101-YJMQ-Listener-ICA-reref-filter_type';

%% band name
lambda = 2^5;
band_name = strcat(' 64Hz 2-8Hz lambda',num2str(lambda),' 10-55s');

%% load sound data from wav
load('E:\DataProcessing\speaker-listener_experiment\AudioData\Audio_envelope_64Hz_hilbert_cell.mat');

% % retelling story 2 is original story 15 % listener0 and listener11 needs
% % this correctness
% AudioA_retell_cell{2} = AudioA_retell_cell{15};
% AudioB_retell_cell{2} = AudioB_retell_cell{15};
% 
% % only has 14 stories for each type

% write into cell
AudioA_total = [AudioA_read_cell(1:14) AudioA_retell_cell(1:14)];
AudioB_total = [AudioB_read_cell(1:14) AudioB_retell_cell(1:14)];
AudioA_total = AudioA_total';
AudioB_total = AudioB_total';

% %% load sound data from EEG
% % load('E:\DataProcessing\speaker-listener_experiment\ListenerData\0-LZR-Listener-hilbert-sound_64Hz_lowpass8Hz_type.mat');
% % load('E:\DataProcessing\speaker-listener_experiment\ListenerData\Audio_envelope_64Hz_hilbert_cell.mat');
% load('E:\DataProcessing\speaker-listener_experiment\AudioData\0-LZR-Listener-hilbert-sound_64Hz_lowpass8Hz_type_baseline.mat')
% % correct labels
% data_retell{13}=data_retell{11};
% data_retell{14}=data_retell{12};
% data_retell{11}=data_read{15};
% data_retell{12}=data_read{16};
% 
% % combine
% % EEGBlock = [data_retell data_read(1:14)];
% % EEGBlock = EEGBlock';
% audio_EEGBlock = [data_retell data_read(1:14)];
% audio_EEGBlock = audio_EEGBlock';

%% data name
p = pwd;

%% load EEG data
% load('E:\DataProcessing\speaker-listener_experiment\ListenerData\0-LZR-Listener-ICA-filter-reref_type.mat');
% load('E:\DataProcessing\speaker-listener_experiment\ListenerData\11-ZM-Listener-ICA-reref-filter_type.mat','listener_theta_read','listener_theta_retell')
load(strcat('E:\DataProcessing\speaker-listener_experiment\ListenerData\',dataName,'.mat'),'listener_theta_read','listener_theta_retell');

% % correct labels
% data_retell{13}=data_retell{11};
% data_retell{14}=data_retell{12};
% data_retell{11}=data_read{15};
% data_retell{12}=data_read{16};

% combine
EEGBlock = [listener_theta_read listener_theta_retell];
EEGBlock = EEGBlock';


%% attend stream
load(strcat('E:\DataProcessing\speaker-listener_experiment\mfiles\CountBalanceTable\CountBalanceTable_listener',dataName(1:2),'.mat'));

%% timelag
Fs = 64;
% timelag = -250:500/32:500;
timelag = -250:(1000/Fs):500;
% timelag = timelag(33);
% timelag = 0;

%% length
startTime = 10;
endTime = 55;

EEG_time = (startTime + 5 )*Fs : (endTime + 5 )*Fs;
% clip_length = 5 * Fs;
%
% clipNum = round(EEG_time/clip_length);

Audio_time = startTime*Fs : endTime*Fs;


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
    
    train_mTRF_attend_w_train_all_listener = cell(size(EEGBlock,1),1);
    train_mTRF_unattend_w_train_all_listener = cell(size(EEGBlock,1),1);
    train_mTRF_attend_w_all_listener = cell(size(EEGBlock,1),1);
    train_mTRF_unattend_w_all_listener = cell(size(EEGBlock,1),1);
    
    
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
        % Audio
        if  strcmpi('A',AttendTarget{test_index})  % attend retell A and A is left
            Audio_attend_train = AudioA_total{test_index}(Audio_time);
            Audio_unattend_train  = AudioB_total{test_index}(Audio_time);
        else
            Audio_attend_train  = AudioB_total{test_index}(Audio_time);
            Audio_unattend_train  = AudioA_total{test_index}(Audio_time);
        end
        

        % EEG
        EEG_test =  EEGBlock{test_index}(chn_sel_index,EEG_time);
        
        disp(strcat('Training story',num2str(test_index),'...'));
        cnt_train_index = 1;
        
        for train_index = 1 : length(EEGBlock)
            if train_index ~= test_index
                
                if  strcmpi('A',AttendTarget{train_index})  % attend retell A and A is left
                    Audio_attend_test = AudioA_total{train_index}(Audio_time);
                    Audio_unattend_test = AudioB_total{train_index}(Audio_time);
                else
                    Audio_attend_test = AudioB_total{train_index}(Audio_time);
                    Audio_unattend_test = AudioA_total{train_index}(Audio_time);
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
                
                train_mTRF_attend_w_train_all_listener{test_index}= train_mTRF_attend_w_total;
                train_mTRF_unattend_w_train_all_listener{test_index} = train_mTRF_unattend_w_total;
                
                cnt_train_index = cnt_train_index + 1;
            end
            
        end
        
        
        % mean of weights
        train_mTRF_attend_w_mean = mean(train_mTRF_attend_w_total,3);
        train_mTRF_attend_con_mean = mean(train_mTRF_attend_con_total,3);
        
        train_mTRF_unattend_w_mean = mean(train_mTRF_unattend_w_total,3);
        train_mTRF_unattend_con_mean = mean(train_mTRF_unattend_con_total,3);
        
        train_mTRF_attend_w_all_listener{test_index} = train_mTRF_attend_w_mean;
        train_mTRF_unattend_w_all_listener{test_index} = train_mTRF_unattend_w_mean;
        
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
            if  strcmpi('A',AttendTarget{train_index})
                Audio_attend_train = AudioA_total{train_index}(Audio_time);
                Audio_unattend_train = AudioB_total{train_index}(Audio_time);
            else
                Audio_attend_train = AudioB_total{train_index}(Audio_time);
                Audio_unattend_train = AudioA_total{train_index}(Audio_time);
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
    
    
    %% plot
    % reconstruction accuracy plot attend
    figure; plot(mean(recon_AttendDecoder_attend_corr,2),'r');
    hold on; plot(mean(recon_AttendDecoder_unattend_corr,2),'b');
    xlabel('Subject No.'); ylabel('r value')
    saveName1 = strcat('Reconstruction Accuracy using mTRF method for attend decoder+',num2str(timelag(j)),'ms',band_name,'.jpg');
    % saveName1 = strcat('Reconstruction Accuracy using mTRF method for attend decoder.jpg');
    title(saveName1(1:end-4));
    legend('Audio attend ','Audio not Attend')
    saveas(gcf,saveName1);
    close
    
    % reconstruction accuracy plot unattend
    figure; plot(mean(recon_UnattendDecoder_attend_corr,2),'r');
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
    figure; plot(Decoding_result_attend_decoder,'r');
    hold on; plot(Decoding_result_unattend_decoder,'b');
    xlabel('Subject No.'); ylabel('Difference');ylim([-0.2 0.2]);
    saveName3 = strcat('Decoding accuracy using mTRF method for attend and unattend decoder+',num2str(timelag(j)),'ms',band_name,'.jpg');
    % saveName3 = strcat('Decoding accuracy using mTRF method for attend and unattend decoder.jpg');
    title(saveName3(1:end-4))
    legend('Attend Decoder','Unattend Decoder')
    saveas(gcf,saveName3);
    close
    
    saveName = strcat('mTRF_sound_EEG_result+',num2str(timelag(j)),'ms',band_name,'.mat');
    %     saveName = strcat('mTRF_sound_EEG_result.mat');
    save(saveName,'recon_AttendDecoder_attend_corr','recon_UnattendDecoder_unattend_corr' ,'recon_AttendDecoder_unattend_corr','recon_UnattendDecoder_attend_corr',...
        'p_recon_AttendDecoder_attend_corr','p_recon_UnattendDecoder_unattend_corr', 'p_recon_AttendDecoder_unattend_corr','p_recon_UnattendDecoder_attend_corr',...
        'MSE_recon_AttendDecoder_attend_corr','MSE_recon_UnattendDecoder_unattend_corr','MSE_recon_AttendDecoder_unattend_corr','MSE_recon_UnattendDecoder_attend_corr',...
        'recon_AttendDecoder_attend_corr_train','recon_UnattendDecoder_unattend_corr_train' ,'recon_AttendDecoder_unattend_corr_train','recon_UnattendDecoder_attend_corr_train',...
        'p_recon_AttendDecoder_attend_corr_train','p_recon_UnattendDecoder_unattend_corr_train', 'p_recon_AttendDecoder_unattend_corr_train','p_recon_UnattendDecoder_attend_corr_train',...
        'MSE_recon_AttendDecoder_attend_corr_train','MSE_recon_UnattendDecoder_unattend_corr_train','MSE_recon_AttendDecoder_unattend_corr_train','MSE_recon_UnattendDecoder_attend_corr_train',...
        'train_mTRF_attend_w_total','train_mTRF_unattend_w_total');
end


