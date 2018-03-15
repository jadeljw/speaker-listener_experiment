%% speakerA mTRF reconstruction
% purpose: to test whether the speaker also has TRF response
% use backward model to reconstruct the audio envelope


% LJW
% 2018.1.21
% on the flight from Hainan to Beijing

%% band name
band_name = {'delta','theta','alpha','beta'};


for band_select = 1 : length(band_name)
    mkdir(band_name{band_select});
    cd(band_name{band_select});
    
    %% load speaker data
    load('E:\DataProcessing\speaker-listener_experiment\SpeakerData\Speaker01-CFY-read_retell_valid.mat');
    %
    %     %     theta
    %     data_EEG_speakerA = [data_speakerA_read_theta_valid(1:14)...
    %         data_speakerA_retell_theta_valid(1:7)...
    %         data_speakerA_retell_theta_valid(15)...
    %         data_speakerA_retell_theta_valid(9:14)];
    
    speaker_data_string = strcat('[data_speakerA_read_',band_name{band_select},'_valid(1:14) data_speakerA_retell_',band_name{band_select},'_valid(1:7) data_speakerA_retell_',band_name{band_select},'_valid(15) data_speakerA_retell_',band_name{band_select},'_valid(9:14)];');
    data_EEG_speakerA = eval(speaker_data_string);
    
    EEGBlock = data_EEG_speakerA;
    EEGBlock = EEGBlock';
    
    %% load Audio data
    load('E:\DataProcessing\speaker-listener_experiment\AudioData\from wav\Listener101_Audio_envelope_hilbert_first_64Hz_keep_order.mat');
    data_left = eval(strcat('data_left_',band_name{band_select}));
    data_right = eval(strcat('data_right_',band_name{band_select}));
    Audio_A = [data_left(1:14) data_right(15:28)];
    
    %% band name
    lambda = 2^5;
    %     band_name = strcat(' 64Hz 2-8Hz sound from wav SpeakerA lambda',num2str(lambda),' 10-55s');
    bandName = strcat(' 64Hz',band_name{band_select},' sound from wav SpeakerA lambda',num2str(lambda),' 10-55s');
    
    %% timelag
    Fs = 64;
    % timelag = -250:500/32:500;
    timelag = -250:(1000/Fs):500;
    % timelag = timelag(33:49);
    % timelag = 0;
    
    %% length
    EEG_time = 15 * Fs : 60 * Fs;
    Audio_time = 10 * Fs : 55 * Fs;
    
    %% chn_sel
    chn_sel_index = [1:32 34:42 44:59 61:63];
    
    %% plot initial
    listener_chn= [1:32 34:42 44:59 61:63];
    load('E:\DataProcessing\label66.mat');
    layout = 'E:\DataProcessing\easycapm1.mat';
    
    mkdir('SpeakerA');
    cd('SpeakerA');
    
    recon_AttendDecoder_attend_corr_total = zeros(1,length(timelag));
    
    
    for j = 1 : length(timelag)
        %% mTRF intitial
        
        start_time = 0 + timelag(j);
        end_time = 0 + timelag(j);
        
        %% mTRF matrix intial
        train_mTRF_attend_w_total = zeros(length(chn_sel_index),(end_time-start_time)/(1000/Fs)+1,size(EEGBlock,1)-1);
        train_mTRF_attend_con_total = zeros(length(chn_sel_index),1,size(EEGBlock,1)-1);
        
        train_mTRF_attend_w_train_all_story = cell(size(EEGBlock,1),1);
        recon_AttendDecoder_attend_corr = zeros(size(EEGBlock,1),1);
        p_recon_AttendDecoder_attend_corr = zeros(size(EEGBlock,1),1);
        MSE_recon_AttendDecoder_attend_corr = zeros(size(EEGBlock,1),1);
        
        
        %% mTRF train and test
        for test_index = 1 : length(EEGBlock)
            
            % test data
            Audio_attend_test = Audio_A{test_index}(Audio_time)';
            
            % EEG
            EEG_test =  EEGBlock{test_index}(chn_sel_index,EEG_time);
            
            disp(strcat('Training story',num2str(test_index),'...'));
            % traing process
            cnt_train_index = 1;
            for train_index = 1 : length(EEGBlock)
                if train_index ~= test_index
                    
                    % train story
                    Audio_attend_train = Audio_A{train_index}(Audio_time)';
                    
                    
                    % train EEG
                    EEG_train =  EEGBlock{train_index}(chn_sel_index,EEG_time);
                    
                    %train process
                    [w_train_mTRF_attend,t_train_mTRF_attend,con_train_mTRF_attend] = mTRFtrain(Audio_attend_train',EEG_train',Fs,-1,start_time,end_time,lambda);
                    
                    
                    % record all weights into one matrix
                    train_mTRF_attend_w_total(:,:,cnt_train_index) = w_train_mTRF_attend;
                    train_mTRF_attend_con_total(:,:,cnt_train_index) = con_train_mTRF_attend;
                    
                    train_mTRF_attend_w_train_all_story{test_index}= train_mTRF_attend_w_total;
                    
                    
                    cnt_train_index = cnt_train_index + 1;
                end
                
            end
            
            
            % mean of weights
            train_mTRF_attend_w_mean = mean(train_mTRF_attend_w_total,3);
            train_mTRF_attend_con_mean = mean(train_mTRF_attend_con_total,3);
            
            train_mTRF_attend_w_all_story_mean{test_index} = train_mTRF_attend_w_mean;
            
            
            % predict
            disp(strcat('Testing story',num2str(test_index),'...'));
            
            [recon_audio_attend_AttendDecoder,recon_AttendDecoder_attend_corr(test_index),p_recon_AttendDecoder_attend_corr(test_index),MSE_recon_AttendDecoder_attend_corr(test_index)] =...
                mTRFpredict(Audio_attend_test',EEG_test',train_mTRF_attend_w_mean,Fs,-1,start_time,end_time,train_mTRF_attend_con_mean);
            
            
        end
        %% timeplot
        mkdir('timelag plot');
        cd('timelag plot');
        % reconstruction accuracy plot attend
        figure; plot(mean(recon_AttendDecoder_attend_corr,2),'r');
        xlabel('Story No.'); ylabel('r value')
        saveName1 = strcat('SpeakerA Reconstruction Acc using mTRF method timelag',num2str(timelag(j)),'ms',bandName,'.jpg');
        % saveName1 = strcat('Reconstruction Accuracy using mTRF method for attend decoder.jpg');
        title(saveName1(1:end-4));
        legend('Audio attend ');
        saveas(gcf,saveName1);
        close
        
        p = pwd;
        cd(p(1:end-(length('timelag plot')+1)));
        
        %% topoplot
        mkdir('topoplot');
        cd('topoplot');
        U_topoplot(abs(zscore(train_mTRF_attend_w_mean)),layout,label66(listener_chn));%plot(w_A(:,1));
        save_name = strcat('SpeakerA-Topoplot-timelag ',num2str(timelag(j)),'ms.jpg');
        suptitle(save_name(1:end-4));
        saveas(gcf,save_name)
        close;
        p = pwd;
        cd(p(1:end-(length('topoplot')+1)));
        
        %% save data
        saveName = strcat('mTRF_sound_speakerA_EEG_result+',num2str(timelag(j)),'ms',bandName,'.mat');
        %     saveName = strcat('mTRF_sound_EEG_result.mat');
        save(saveName,'recon_AttendDecoder_attend_corr',...
            'p_recon_AttendDecoder_attend_corr',...
            'MSE_recon_AttendDecoder_attend_corr',...
            'train_mTRF_attend_w_all_story_mean');
        
        recon_AttendDecoder_attend_corr_total(j) = mean(mean(recon_AttendDecoder_attend_corr,2));
    end
    
    figure; plot(timelag,recon_AttendDecoder_attend_corr_total,'r');
    xlabel('SpeakerA'); ylabel('r value')
    saveName = strcat('SpeakerA Reconstruction Acc using mTRF method across timelag',bandName,'.jpg');
    % saveName1 = strcat('Reconstruction Accuracy using mTRF method for attend decoder.jpg');
    title(saveName1(1:end-4));
    legend('AudioA ');
    saveas(gcf,saveName);
    close;
    
    p = pwd;
    cd(p(1:end-(length(band_name{band_select})+1)));
end