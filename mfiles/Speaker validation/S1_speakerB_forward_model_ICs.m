% S1_speakerA_forward model

% by LJW
% 2018.6.5
% for speaker-listener experiment
% forward: Audio -> EEG

%% data type
data_type = {'ICs'};

%% new order
% load('E:\DataProcessing\Label_and_area.mat');
% 
% select_area = 'Small_area';
% chn_area_labels = fieldnames(eval(select_area));

for type_select = 1 : length(data_type)
    
    %% load data
    % EEG
%     load(strcat('E:\DataProcessing\speaker-listener_experiment\Speaker Validation\0-raw data\data_speakerB_',data_type{type_select},'.mat'));
     load('E:\DataProcessing\speaker-listener_experiment\Speaker Validation\0-raw data\ICA\data_speakerB_ICs.mat');
     
    % Audio
    load('E:\DataProcessing\speaker-listener_experiment\Speaker Validation\0-raw data\Audio_B.mat');
    
    % valid mat
    %     load('E:\DataProcessing\speaker-listener_experiment\Speaker Validation\0-raw data\data_speakerB_ICA_select.mat');
    
    %% band
    band_name = {'alpha', 'alpha_hilbert', 'beta', 'beta_hilbert',...
        'delta', 'delta_hilbert', 'theta', 'theta_hilbert'};
    
    %% initial
    lambda = 2^10;
    Fs = 64;
    timelag = -500 : 1000/Fs : 500;
    start_time = -500;
    end_time = 500;
    map = 1;
    
    %% mTRF
    for band_select = 1 : length(band_name)
        
        % calculate
        temp_resp = eval(strcat('data_speakerB_total.',band_name{band_select}));
        temp_stim = eval(strcat('Audio_B_total.',band_name{band_select}));
        
        % mean into different area
%         for i = 1 : length(temp_stim)
%             for area_select = 1 :length(chn_area_labels)
%                 chn_number = eval(strcat(select_area,'.',chn_area_labels{area_select}));
%                 temp_resp_area{i}(:,area_select) = mean(temp_resp{i}(:,chn_number),2);
%             end
%         end
%         [r,p,mse,~,model] = mTRFcrossval(temp_stim,temp_resp_area,Fs,map,start_time,end_time,lambda);
        [r,p,mse,~,model] = mTRFcrossval(temp_stim,temp_resp,Fs,map,start_time,end_time,lambda);
        
        % save result
        data_name = strcat('Audio_speakerB_forward.',band_name{band_select});
        % model
        eval(strcat(data_name,'.model = model;'));
        eval(strcat(data_name,'.r = r;'));
        eval(strcat(data_name,'.p = p;'));
        eval(strcat(data_name,'.mse = mse;'));
    end
    
    save(strcat('AudioB_speakerB_forward_',data_type{type_select},'.mat'),'Audio_speakerB_forward');
end