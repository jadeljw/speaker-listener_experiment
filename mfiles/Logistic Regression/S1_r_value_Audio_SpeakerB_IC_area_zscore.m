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

mkdir('Audio SpeakerB ICA');
cd('Audio SpeakerB ICA');

%% initial
load('E:\DataProcessing\chn_re_index.mat');
chn_re_index = chn_re_index(1:64);

listener_chn= [1:32 34:42 44:59 61:63];
% speaker_chn = [1:32 34:42 44:59 61:63];
load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';


%% new order
% load('E:\DataProcessing\Label_and_area.mat');
load('G:\Speaker-listener_experiment\speaker\20170622-FS\data_preprocessing\ICA component\data_speakerB_ICA_select.mat');

select_area = 'data_speakerB_ICA';
chn_area_labels = fieldnames(eval(select_area));


%%
band_name = {'alpha', 'alpha_hilbert', 'beta', 'beta_hilbert',...
    'delta', 'delta_hilbert', 'theta', 'theta_hilbert'};
% band_name = {'delta', 'delta_hilbert', 'theta', 'theta_hilbert'};
% band_name = {'beta'};


for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    
    %% band name
    lambda = 2^10;
    %         bandName = strcat(' 64Hz theta speakerEEG mTRF Listener',dataName(1:3),' lambda',num2str(lambda),' 10-55s');
    
    
    %% load speaker data
    load('G:\Speaker-listener_experiment\speaker\20170622-FS\data_preprocessing\ICA component\data_speakerB_ICA_component_64Hz_read_retell.mat')
    
    %
    %     %     theta
    %     data_EEG_SpeakerB = [data_SpeakerB_read_theta_valid(1:14)...
    %         data_SpeakerB_retell_theta_valid(1:7)...
    %         data_SpeakerB_retell_theta_valid(15)...
    %         data_SpeakerB_retell_theta_valid(9:14)];
    
    speaker_data_string = strcat('[data_speakerB_read_',band_name{band_select},'_valid(1:14) data_speakerB_retell_',band_name{band_select},'_valid(1:7) data_speakerB_retell_',band_name{band_select},'_valid(15) data_speakerB_retell_',band_name{band_select},'_valid(9:14)];');
    data_EEG_SpeakerB = eval(speaker_data_string);
    
    EEGBlock = data_EEG_SpeakerB;
    
    
    %% load Audio data
    load('E:\DataProcessing\speaker-listener_experiment\AudioData\from wav\Listener101_Audio_envelope_hilbert_first_64Hz_keep_order.mat');
    if length(band_name{band_select})>7
        if strcmp(band_name{band_select}(end-6:end),'hilbert')
            data_left = eval(strcat('data_left_',band_name{band_select-1}));
            data_right = eval(strcat('data_right_',band_name{band_select-1}));
            Audio_B = [data_right(1:14) data_left(15:28)];
        else
            data_left = eval(strcat('data_left_',band_name{band_select}));
            data_right = eval(strcat('data_right_',band_name{band_select}));
            Audio_B = [data_right(1:14) data_left(15:28)];
        end
    else
        data_left = eval(strcat('data_left_',band_name{band_select}));
        data_right = eval(strcat('data_right_',band_name{band_select}));
        Audio_B = [data_right(1:14) data_left(15:28)];
    end
    
    %% timelag
    Fs = 64;
    timelag = -500:500/32:500;
    label_select = 1 : round(length(timelag)/8) :length(timelag);
    %     timelag = -250:(1000/Fs):500;
    % timelag = timelag(33:49);
    %     timelag = [-300 -200 -100 0 100 200 300 400];
    
    %% length
    start_time = 10;
    end_time = 55;
    %     Listener_time_index = (start_time+5)*Fs+1:(end_time+5)*Fs;
    speaker_time_index =  (start_time+5)*Fs+1:(end_time+5)*Fs;
    %     EEG_time = 15 * Fs : 60 * Fs;
    % clip_length = 5 * Fs;
    %
    % clipNum = round(EEG_time/clip_length);
    Audio_time = start_time * Fs +1 : end_time * Fs;
    
    %% imagesc initial
    imagesc_mat = zeros(length(chn_area_labels),length(timelag));
    
    %% chn_sel
    for chn_area_select = 1 : length(chn_area_labels)
        disp(chn_area_labels{chn_area_select});
        speaker_chn = eval(strcat(select_area,'.',chn_area_labels{chn_area_select}));
        %         mkdir(chn_area_labels{chn_area_select});
        %         cd(chn_area_labels{chn_area_select});
        
        
        for j = 1 : length(timelag)
            %% mTRF intitial
            
            start_time = 0  + timelag(j);
            end_time = 0 + timelag(j);
            % lambda = 1e5;
            
            %% mTRF matrix intial
            train_mTRF_attend_w_total = zeros(length(speaker_chn),(end_time-start_time)/(1000/Fs)+1,size(EEGBlock,1));
            %             train_mTRF_unattend_w_total = zeros(length(listener_chn),(end_time-start_time)/(1000/Fs)+1,size(EEGBlock,1));
            train_mTRF_attend_con_total = zeros(length(speaker_chn),1,size(EEGBlock,1)-1);
            %             train_mTRF_unattend_con_total = zeros(length(listener_chn),1,size(EEGBlock,1)-1);
            %
            train_mTRF_attend_w_train_all_story = cell(size(EEGBlock,1),1);
            %             train_mTRF_unattend_w_train_all_story = cell(size(EEGBlock,1),1);
            train_mTRF_attend_w_all_story_mean = cell(size(EEGBlock,1),1);
            %             train_mTRF_unattend_w_all_story_mean = cell(size(EEGBlock,1),1);
            %
            
            recon_AttendDecoder_SpeakerB_corr = zeros(size(EEGBlock,1),1);
            
            p_recon_AttendDecoder_SpeakerB_corr = zeros(size(EEGBlock,1),1);
            
            
            MSE_recon_AttendDecoder_SpeakerB_corr = zeros(size(EEGBlock,1),1);
            
            
            
            %% mTRF train and test
            tic;
            % train process
            disp('Training...');
            for train_index = 1 : length(EEGBlock)
                % train story
                Audio_attend_train = zscore(Audio_B{train_index}(Audio_time)');
                
                
                % train EEG
                EEG_train =  EEGBlock{train_index}(speaker_chn,speaker_time_index);
                EEG_train = zscore(EEG_train');
                
                
                %train process
                [w_train_mTRF_attend,t_train_mTRF_attend,con_train_mTRF_attend] = mTRFtrain(Audio_attend_train',EEG_train,Fs,-1,start_time,end_time,lambda);
                %                 [w_train_mTRF_unattend,t_train_mTRF_unattend,con_train_mTRF_unattend] = mTRFtrain(Audio_unattend_train',EEG_train,Fs,-1,start_time,end_time,lambda);
                
                
                % record all weights into one matrix
                train_mTRF_attend_w_total(:,:,train_index) = w_train_mTRF_attend;
                train_mTRF_attend_con_total(:,:,train_index) = con_train_mTRF_attend;
                
                %                 train_mTRF_unattend_w_total(:,:,train_index) = w_train_mTRF_unattend;
                %                 train_mTRF_unattend_con_total(:,:,train_index) = con_train_mTRF_unattend;
            end
            
            % test
            for test_index = 1 : length(EEGBlock)
                disp(strcat('Testing story',num2str(test_index),'...'));
                train_index_select = setdiff(1 : length(EEGBlock),test_index);
                
                
                % test Audio
                Audio_attend_test= zscore(Audio_B{test_index}(Audio_time)');
                
                
                % test EEG
                EEG_test =  EEGBlock{test_index}(speaker_chn,speaker_time_index);
                EEG_test = zscore(EEG_test');
                
                
                % mean of weights
                train_mTRF_attend_w_mean = mean(train_mTRF_attend_w_total(:,:,train_index_select),3);
                train_mTRF_attend_con_mean = mean(train_mTRF_attend_con_total(:,:,train_index_select),3);
                
                %                 train_mTRF_unattend_w_mean = mean(train_mTRF_unattend_w_total(:,:,train_index_select),3);
                %                 train_mTRF_unattend_con_mean = mean(train_mTRF_unattend_con_total(:,:,train_index_select),3);
                
                %                     train_mTRF_attend_w_all_story_mean{test_index} = train_mTRF_attend_w_mean;
                %                     train_mTRF_unattend_w_all_story_mean{test_index} = train_mTRF_unattend_w_mean;
                
                %                     train_mTRF_attend_w_train_all_story{test_index}= train_mTRF_attend_w_total(:,:,train_index_select);
                %                     train_mTRF_unattend_w_train_all_story{test_index} = train_mTRF_attend_con_total(:,:,train_index_select);
                
                % predict
                
                [~,recon_AttendDecoder_SpeakerB_corr(test_index),p_recon_AttendDecoder_SpeakerB_corr(test_index),MSE_recon_AttendDecoder_SpeakerB_corr(test_index)] =...
                    mTRFpredict(Audio_attend_test',EEG_test,train_mTRF_attend_w_mean,Fs,-1,start_time,end_time,train_mTRF_attend_con_mean);
                
                %                 [~,recon_AttendDecoder_SpeakerB_corr(test_index),p_recon_AttendDecoder_SpeakerB_corr(test_index),MSE_recon_AttendDecoder_SpeakerB_corr(test_index)] =...
                %                     mTRFpredict(SpeaekerB_test',EEG_test,train_mTRF_attend_w_mean,Fs,-1,start_time,end_time,train_mTRF_attend_con_mean);
                
                %                 [~,recon_UnattendDecoder_SpeakerB_corr(test_index),p_recon_UnattendDecoder_SpeakerB_corr(test_index),MSE_recon_UnattendDecoder_SpeakerB_corr(test_index)] =...
                %                     mTRFpredict(SpeaekerA_test',EEG_test,train_mTRF_unattend_w_mean,Fs,-1,start_time,end_time,train_mTRF_unattend_con_mean);
                %
                %                 [~,recon_UnattendDecoder_SpeakerB_corr(test_index),p_recon_UnattendDecoder_SpeakerB_corr(test_index),MSE_recon_UnattendDecoder_SpeakerB_corr(test_index)] =...
                %                     mTRFpredict(SpeaekerB_test',EEG_test,train_mTRF_unattend_w_mean,Fs,-1,start_time,end_time,train_mTRF_unattend_con_mean);
                
            end
            
            toc;
            
            % save data
            %             saveName = strcat('mTRF_Audio_SpeakerB_result-',chn_area_labels{chn_area_select},'-timelag',num2str(timelag(j)),'ms-',band_file_name,'.mat');
            %             %     saveName = strcat('mTRF_sound_EEG_result.mat');
            %             save(saveName,'recon_AttendDecoder_SpeakerB_corr','recon_UnattendDecoder_SpeakerB_corr' ,'recon_AttendDecoder_SpeakerB_corr','recon_UnattendDecoder_SpeakerB_corr',...
            %                 'p_recon_AttendDecoder_SpeakerB_corr','p_recon_UnattendDecoder_SpeakerB_corr', 'p_recon_AttendDecoder_SpeakerB_corr','p_recon_UnattendDecoder_SpeakerB_corr',...
            %                 'MSE_recon_AttendDecoder_SpeakerB_corr','MSE_recon_UnattendDecoder_SpeakerB_corr','MSE_recon_AttendDecoder_SpeakerB_corr','MSE_recon_UnattendDecoder_SpeakerB_corr',...
            %                 'train_mTRF_attend_w_total','train_mTRF_unattend_w_total');
            
            imagesc_mat(chn_area_select,j) = mean(recon_AttendDecoder_SpeakerB_corr);
            
        end
        
        %         p = pwd;
        %         cd(p(1:end-(length(chn_area_labels{chn_area_select})+1)));
    end
    
    % imagesc
    set(gcf,'outerposition',get(0,'screensize'));
    imagesc(imagesc_mat);colorbar;
    %     caxis([-0.04 0.1]);
    %     colormap('jet');
    xticks(label_select);
    xticklabels(timelag(label_select));
    yticks(1:length(chn_area_labels));
    yticklabels(chn_area_labels);
    xlabel('timelag(ms)');
    ylabel('Speaker Channels');
    save_name = strcat('Audio-SpeakerB r value Result-total-',band_name{band_select},'-',select_area,'.jpg');
    title(save_name(1:end-4));
    saveas(gcf,save_name);
    close
    
    
    save_name = strcat('Audio-SpeakerB r value Result-total-',band_name{band_select},'-',select_area,'.mat');
    save(save_name,'imagesc_mat');
    
    
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end
