%% speaker RCA test

%% initial
band_name = {'delta','alpha','theta'};
story_num = 28;

%% initial
load('E:\DataProcessing\chn_re_index.mat');
chn_re_index = chn_re_index(1:64);

listener_chn= [1:32 34:42 44:59 61:63];
speaker_chn = [1:32 34:42 44:59 61:63];
load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';

Fs = 64;
timealag = -500: 1000/Fs : 500;

%% length
start_time = 10;
end_time = 55;
Listener_time_index = (start_time+5)*Fs+1:(end_time+5)*Fs;
speaker_time_index =  (start_time+5)*Fs+1:(end_time+5)*Fs;

%% new order
load('E:\DataProcessing\Label_and_area.mat');

select_area = 'Small_area';
chn_area_labels = fieldnames(eval(select_area));


%% combine data
for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    %% data preparation
    % load data
    load('E:\DataProcessing\speaker-listener_experiment\Demo data\20180605\data_speakerA_total.mat');
    load('E:\DataProcessing\speaker-listener_experiment\Demo data\20180605\data_speakerB_total.mat');
    
    
    % data
    data_speakerA = eval(strcat('data_speakerA_total.',band_name{band_select}));
    data_speakerB = eval(strcat('data_speakerB_total.',band_name{band_select}));
    clear data_speakerA_total
    clear data_speakerB_total
    
    % data_mat
    data_speakerA_mat = zeros(length(speaker_time_index),length(speaker_chn),length(data_speakerA));
    data_speakerB_mat = zeros(length(speaker_time_index),length(speaker_chn),length(data_speakerB));
    
    % combine data
    for story_select = 1 : length(data_speakerA)
        data_speaekerA_temp = zscore(data_speakerA{story_select}(:,speaker_chn));
        data_speakerA_mat(:,:,story_select) = data_speaekerA_temp;
        data_speaekerB_temp = zscore(data_speakerB{story_select}(:,speaker_chn));
        data_speakerB_mat(:,:,story_select) = data_speaekerB_temp;
    end
    
    data_speaker{1} = data_speakerA_mat;
    data_speaker{2} = data_speakerB_mat;
    
    %% RCA
    % speakerA
%     [dataOut.speakerA,W.speakerA,A.speakerA] = rcaRun_new(data_speakerA_mat,label66(speaker_chn));
%     suptitle(strcat('RCA SpeakerA-',band_name{band_select}));
%     saveas(gcf,strcat('RCA SpeakerA-',band_name{band_select},'.fig'));
%     pause
%     
%     % speakerB
%     [dataOut.speakerB,W.speakerB,A.speakerB] = rcaRun_new(data_speakerB_mat,label66(speaker_chn));
%     suptitle(strcat('RCA SpeakerB-',band_name{band_select}));
%     saveas(gcf,strcat('RCA SpeakerB-',band_name{band_select},'.fig'));
%     pause
    
    % speaker
    [dataOut.All,W.All,A.All] = rcaRun_new(data_speaker,label66(speaker_chn));
    suptitle(strcat('RCA Speaker all-',band_name{band_select}));
    saveas(gcf,strcat('RCA Speaker all-',band_name{band_select},'.fig'));
    pause
    
    %% save data
    saveName = strcat('RCA speaker-',band_name{band_select},'.mat');
    save(saveName,'dataOut','W','A');
    
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end