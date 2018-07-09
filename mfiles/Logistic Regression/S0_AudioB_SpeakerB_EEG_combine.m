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


%% initial
load('E:\DataProcessing\chn_re_index.mat');
chn_re_index = chn_re_index(1:64);

listener_chn= [1:32 34:42 44:59 61:63];
% speaker_chn = [1:32 34:42 44:59 61:63];
load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';


%% new order
% % load('E:\DataProcessing\Label_and_area.mat');
% load('G:\Speaker-listener_experiment\speaker\20170622-FS\data_preprocessing\ICA component\data_speakerB_ICA_select.mat');
% 
% select_area = 'data_speakerB_ICA';
% chn_area_labels = fieldnames(eval(select_area));


%%
band_name = {'alpha', 'alpha_hilbert', 'beta', 'beta_hilbert',...
    'delta', 'delta_hilbert', 'theta', 'theta_hilbert'};
% band_name = {'delta', 'delta_hilbert', 'theta', 'theta_hilbert'};
% band_name = {'beta'};


for band_select = 1 : length(band_name)

    %% band name
    lambda = 2^10;
    %         bandName = strcat(' 64Hz theta speakerEEG mTRF Listener',dataName(1:3),' lambda',num2str(lambda),' 10-55s');
    
    %% load speaker data
%     load('G:\Speaker-listener_experiment\speaker\20170622-FS\data_preprocessing\ICA component\data_speakerB_ICA_component_64Hz_read_retell.mat')
    load('G:\Speaker-listener_experiment\speaker\20170622-FS\data_preprocessing\before and afterICA\speakerB_afterICA_64Hz_read_retell.mat')

    
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
    
    %% combine
    for story_select = 1 :length(EEGBlock)
        % train story
        temp_AudioB{story_select} = zscore(Audio_B{story_select}(Audio_time)')';

        % train EEG
        temp_EEG{story_select} =  EEGBlock{story_select}(:,speaker_time_index);
        temp_EEG{story_select}  = zscore(temp_EEG{story_select}');
    end
    
    data_EEG_name = strcat('data_speakerB_total.',band_name{band_select});
    eval(strcat(data_EEG_name,'=temp_EEG'));
    data_Audio_name = strcat('Audio_B_total.',band_name{band_select});
    eval(strcat(data_Audio_name,'=temp_AudioB'));
    
end

save('data_speakerB_afterICA.mat','data_speakerB_total');
% save('Audio_B.mat','Audio_B_total');
