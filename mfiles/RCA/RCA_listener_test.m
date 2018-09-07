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
load('E:\DataProcessing\Label_and_area.mat');

select_area = 'Small_area';
chn_area_labels = fieldnames(eval(select_area));


%% data name
dataName_all = {'101-YJMQ-Listener-ICA-reref-filter_64Hz_new',...
    '102-LTX-Listener-ICA-reref-filter_64Hz_new',...
    '103-RT-Listener-ICA-reref-filter_64Hz_new',...
    '104-ZR-Listener-ICA-reref-filter_64Hz_new',...
    '105-LX-Listener-ICA-reref-filter_64Hz_new',...
    '106-WCW-Listener-ICA-reref-filter_64Hz_new',...
    '107-WY-Listener-ICA-reref-filter_64Hz_new',...
    '108-LGZ-Listener-ICA-reref-filter_64Hz_new',...
    '109-PXJ-Listener-ICA-reref-filter_64Hz_new',...
    '110-LNN-Listener-ICA-reref-filter_64Hz_new',...
    '111-ZXT-Listener-ICA-reref-filter_64Hz_new',...
    '112-LX-Listener-ICA-reref-filter_64Hz_new',...
    '113-SYH-Listener-ICA-reref-filter_64Hz_new',...
    '114-WXZ-Listener-ICA-reref-filter_64Hz_new',...
    '115-LYZ-Listener-ICA-reref-filter_64Hz_new',...
    '116-ZX-Listener-ICA-reref-filter_64Hz_new',...
    '117-HY-Listener-ICA-reref-filter_64Hz_new',...
    '118-WM-Listener-ICA-reref-filter_64Hz_new',...
    '119-ZC-Listener-ICA-reref-filter_64Hz_new',...
    '120-LYB-Listener-ICA-reref-filter_64Hz_new'};

dataFile_all = {'20171118-YJMQ','20171122-LTX','20171122-RT',...
    '20171124-ZR','20171125-LX','20171128-WCW',...
    '20171130-WY','20171202-LGZ','20171205-PXJ','20171206-LNN',...
    '20171209-ZXT','20171209-LX','20171213-SYH',...
    '20171214-WXZ','20171214-LYZ','20171216-ZX',...
    '20171216-HY','20171220-WM','20171221-ZC',...
    '20171221-LYB'};



% band_name = {'alpha', 'alpha_hilbert', 'beta', 'beta_hilbert', 'broadband',...
%     'delta', 'delta_hilbert', 'theta', 'theta_hilbert'};
band_name = {'alpha','delta','theta'};
% band_name = {'beta'};

story_num = 28;

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    %
    %
    for i = 1 : 20
        
        %% listener name
        if i < 10
            file_name = strcat('listener10',num2str(i));
        else
            file_name = strcat('listener1',num2str(i));
        end
        
        dataName =  dataName_all{i};
        dataFile = dataFile_all{i};
        
        disp('Combining...');
        disp(file_name);
        %% load EEG data
        % load('E:\DataProcessing\speaker-listener_experiment\ListenerData\0-LZR-Listener-ICA-filter-reref-64Hz.mat');
        % load('E:\DataProcessing\speaker-listener_experiment\ListenerData\01-CYX-Listener-ICA-filter-reref-64Hz.mat')
        %     load(strcat('E:\DataProcessing\speaker-listener_experiment\ListenerData\',dataName,'.mat'),'data_filtered_theta');
        data_temp = strcat('data_filtered_',band_name{band_select});
        load(strcat('E:\DataProcessing\speaker-listener_experiment\ListenerData\',dataName,'.mat'),data_temp);
        
        % combine
        %     EEGBlock = data_filtered_theta.trial;
        
        EEGBlock = eval(strcat('data_filtered_',band_name{band_select},'.trial'));
        EEGBlock = EEGBlock';
        
        
        %% load counterbalance
        load(strcat('E:\DataProcessing\speaker-listener_experiment\CountBalanceTable\CountBalanceTable_listener',dataName(1:3),'.mat'));
        
        %% timelag
        Fs = 64;
        % timelag = -250:500/32:500;
        timelag = -500:(1000/Fs):500;
        % timelag = timelag(33:49);
        %         timelag = 0;
        
        %% length
        start_time = 10;
        end_time = 55;
        Listener_time_index = (start_time+5)*Fs+1:(end_time+5)*Fs;
        speaker_time_index =  (start_time+5)*Fs+1:(end_time+5)*Fs;
        %     EEG_time = 15 * Fs : 60 * Fs;
        % clip_length = 5 * Fs;
        %
        % clipNum = round(EEG_time/clip_length);
        
        %     Audio_time = 10 * Fs : 55 * Fs;
        data_listener_RCA = zeros(length(Listener_time_index),length(listener_chn),length(EEGBlock));
        %% combine data
        for story = 1 : length(EEGBlock)
            
            if strcmpi(Space(story),'left')
                EEG_train = EEGBlock{story}(listener_chn,Listener_time_index);
                EEG_train = zscore(EEG_train');
            else
                EEG_train = EEGBlock{story}(chn_re_index,:);
                EEG_train = EEG_train(listener_chn,Listener_time_index);
                EEG_train = zscore(EEG_train');
            end
            
            data_listener_RCA(:,:,story) = EEG_train;
        end
        
        data_listener_RCA_total{i} = data_listener_RCA;
        %         cd(p(1:end-(length(file_name)+1)));
        %            p = pwd;
    end
    
    %% save data
    eval(strcat('data_listener_RCA_all_band.',band_file_name,'=data_listener_RCA_total;'));
    
    %% RCA
%     set(gcf,'outerposition',get(0,'screensize'));
    [dataOut,W,A] = rcaRun_new(data_listener_RCA_total,label66(listener_chn));
    
    suptitle(strcat('RCA listener-',band_name{band_select}));
    saveas(gcf,strcat('RCA listener-',band_name{band_select},'.fig'));
    pause
    
    %% save data
    saveName = strcat('RCA listener-',band_name{band_select},'.mat');
    save(saveName,'dataOut','W','A');
    
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end

%% save data
saveName = 'data_listener_RCA_total.mat';
save(saveName,'data_listener_RCA_all_band');

