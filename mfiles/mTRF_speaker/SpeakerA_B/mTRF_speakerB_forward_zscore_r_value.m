%% SpeakerB mTRF forward model
% purpose: to test whether the speaker also has TRF response
% use backward model to reconstruct the audio envelope

% LJW
% 2018.1.21
% on the flight from Hainan to Beijing

%% band name
band_name = {'delta','theta','alpha','beta'};

mkdir('SpeakerB');
cd('SpeakerB');


for band_select = 1 : length(band_name)
    disp(band_name{band_select});
%     mkdir(band_name{band_select});
%     cd(band_name{band_select});
    
    %% load speaker data
    load('E:\DataProcessing\speaker-listener_experiment\SpeakerData\Speaker02-FS-read_retell_valid_strict_1-8Hz.mat');
    %
    %     %     theta
    %     data_EEG_SpeakerB = [data_SpeakerB_read_theta_valid(1:14)...
    %         data_SpeakerB_retell_theta_valid(1:7)...
    %         data_SpeakerB_retell_theta_valid(15)...
    %         data_SpeakerB_retell_theta_valid(9:14)];
    
    speaker_data_string = strcat('[data_speakerB_read_',band_name{band_select},'_valid(1:14) data_speakerB_retell_',band_name{band_select},'_valid(1:7) data_speakerB_retell_',band_name{band_select},'_valid(15) data_speakerB_retell_',band_name{band_select},'_valid(9:14)];');
    data_EEG_speakerB = eval(speaker_data_string);
    
    EEGBlock = data_EEG_speakerB;
    
    
    %% load Audio data
    load('E:\DataProcessing\speaker-listener_experiment\AudioData\from wav\Listener101_Audio_envelope_hilbert_first_64Hz_keep_order.mat');
    data_left = eval(strcat('data_left_',band_name{band_select}));
    data_right = eval(strcat('data_right_',band_name{band_select}));
    Audio_B = [data_right(1:14) data_left(15:28)];
    
    %% band name
    lambda = 2.^(0:5:40);
    %     band_name = strcat(' 64Hz 2-8Hz sound from wav SpeakerB lambda',num2str(lambda),' 10-55s');
    bandName = strcat(' 64Hz',band_name{band_select},' sound from wav SpeakerB lambda',num2str(lambda),' 10-55s');
    
    %% timelag
    Fs = 64;
    timelag = 0;
    timelag_for_plot = -1000 :1000/Fs: 1000; 
%     timelag_gap = timelag(2)-timelag(1);
%     timelag_interval = 9;
%     timelag_length = timelag_gap * timelag_interval;
%     timelag = timelag(1:timelag_interval:end);
    
    %% length
    EEG_time = 15 * Fs : 60 * Fs;
    Audio_time = 10 * Fs : 55 * Fs;
    %% chn_sel
    chn_sel_index = [1:32 34:42 44:59 61:63];
    
    
    %% initial
    for jj = 1 : length(EEGBlock)
        % test data
        Audio_test{jj} = Audio_B{jj}(Audio_time);
        Audio_test{jj} = zscore(Audio_test{jj});
        
        % EEG
        EEG_test{jj} =  EEGBlock{jj}(chn_sel_index,EEG_time);
%         EEG_test{jj} = EEG_test{jj}';
        EEG_test{jj} = zscore(EEG_test{jj}');
    end
    
    
    %% plot initial
    listener_chn= [1:32 34:42 44:59 61:63];
    load('E:\DataProcessing\label66.mat');
    layout = 'E:\DataProcessing\easycapm1.mat';
    
    
    for j = 1 : length(timelag)
        disp(strcat('timelag',num2str(timelag(j))));
        
        %% mTRF intitial
        
        start_time = -3000 + timelag(j);
        end_time = 3000 + timelag(j);
        
        
        %% mTRF train and test
        [R,P,MSE,~,model,model_reshape] = mTRFcrossval_reshape(Audio_test,EEG_test,Fs,1,start_time,end_time,lambda);
        
        %% save data
        saveName = strcat('mTRF_sound_SpeakerB_EEG_forward_result_',band_name{band_select},'.mat');
        %     saveName = strcat('mTRF_sound_EEG_result.mat');
        save(saveName,'R','P','MSE','model','model_reshape');
        
    end
    
%     p = pwd;
%     cd(p(1:end-(length(band_name{band_select})+1)));
    
end