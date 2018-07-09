%% compare raw data and afterICA data

%% load map
load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';

%% load data

% raw dat
temp_raw_data = load('E:\DataProcessing\speaker-listener_experiment\Speaker Validation\1-forward model\all channels\AudioA_speakerA_forward_raw.mat','Audio_speakerA_forward');
raw_data_select = temp_raw_data.Audio_speakerA_forward.delta.model;

% after ICA
temp_afterICA_data = load('E:\DataProcessing\speaker-listener_experiment\Speaker Validation\1-forward model\all channels\AudioA_speakerA_forward_afterICA.mat','Audio_speakerA_forward');
afterICA_data_select = temp_afterICA_data.Audio_speakerA_forward.delta.model;


%% initial
Fs = 64;
timelag = -500 : 1000/(Fs+1) : 500;

%% data
raw_delta_model = squeeze(mean(raw_data_select,1));
afterICA_delta_model = squeeze(mean(afterICA_data_select,1));


for j = 20 : length(timelag)
    
    subplot(121);U_topoplot(raw_delta_model(j,:)',layout,label66(1:64));title(strcat('raw',num2str(timelag(j)),'ms'));
    subplot(122);U_topoplot(afterICA_delta_model(j,:)',layout,label66(1:64));title(strcat('afterICA',num2str(timelag(j)),'ms'));
    pause;
    close;
    
end