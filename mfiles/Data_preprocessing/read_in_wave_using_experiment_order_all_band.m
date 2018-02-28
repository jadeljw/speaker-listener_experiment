
dataFile_all = {'20171118-YJMQ','20171122-LTX','20171122-RT',...
    '20171124-ZR','20171125-LX','20171128-WCW',...
    '20171130-WY','20171202-LGZ','20171205-PXJ','20171206-LNN',...
    '20171209-ZXT','20171209-LX','20171213-SYH',...
    '20171214-WXZ','20171214-LYZ','20171216-ZX',...
    '20171216-HY','20171220-WM','20171221-ZC',...
    '20171221-LYB'};

for listener = 1 : length(dataFile_all)
    
    %% read-in .wav files
    % dirA='H:\Speaker-listener_experiment\speaker\20170619-CFY';
    % dirB='H:\Speaker-listener_experiment\speaker\20170622-FS';
    dir = 'G:\Speaker-listener_experiment\listener\program\Listener20171113\audio_new';
    % dir = 'H:\Speaker-listener2017\program\Listener20171113\audio_new';
    Fs=44100;
    fs_down=64;
    
    start_story = 1;
    end_story = 28;
    
    %% CountBalance
    % load('CountBalanceTable_listener01.mat')
    if listener < 10
        dataName = strcat('G:\Speaker-listener_experiment\listener\data\',dataFile_all{listener},'\CountBalanceTable_listener10',num2str(listener),'.mat');
    else
        dataName = strcat('G:\Speaker-listener_experiment\listener\data\',dataFile_all{listener},'\CountBalanceTable_listener1',num2str(listener),'.mat');
    end
    
    load(dataName);
    % load('H:\Speaker-listener2017\data\20171221-LYB\CountBalanceTable_listener120.mat');
    %% workpath
    p = pwd;
    
    %% load wav
    % retell
    data_left = cell(1,28);
    data_right = cell(1,28);
    
    for i= start_story : end_story
        cd(dir);
        [data_left{i},~] = audioread([char(left(i)) '.wav']);
        %     [Y2,~,~] = wavread([char(right(i)) '.wav']);
        [data_right{i},~] = audioread([char(right(i)) '.wav']);
        cd(p);
    end
    
    %% hilbert
    for i= start_story : end_story
        
        data_left{i} = abs(hilbert(data_left{i}));
        data_right{i} = abs(hilbert(data_right{i}));
    end
    
    
    %% sample down
    % oldFs = 200;
    for i= start_story : end_story
        
        data_left{i} = resample(data_left{i},fs_down,Fs);
        data_right{i} = resample(data_right{i},fs_down,Fs);
    end
    
    
    
    
    %% lowpass
    % delta
    fs_down= 64;
    lowpass_filter = 8;
    for i= 1 : 28
        
        data_left_delta{i} = ft_preproc_lowpassfilter(data_left{i},fs_down,lowpass_filter);
        data_right_delta{i} = ft_preproc_lowpassfilter(data_right{i},fs_down,lowpass_filter);
    end
    
    
    % theta
    fs_down= 64;
    lowpass_filter = 8;
    for i= 1 : 28
        
        data_left_theta{i} = ft_preproc_lowpassfilter(data_left{i},fs_down,lowpass_filter);
        data_right_theta{i} = ft_preproc_lowpassfilter(data_right{i},fs_down,lowpass_filter);
    end
    
    
    % alpha
    fs_down= 64;
    lowpass_filter = 12;
    for i= 1 : 28
        data_left_alpha{i} = ft_preproc_lowpassfilter(data_left{i},fs_down,lowpass_filter);
        data_right_alpha{i} = ft_preproc_lowpassfilter(data_right{i},fs_down,lowpass_filter);
    end
    
    
    % beta
    fs_down= 64;
    lowpass_filter = 30;
    
    for i= 1 : 28
        data_left_beta{i} = ft_preproc_lowpassfilter(data_left{i},fs_down,lowpass_filter);
        data_right_beta{i} = ft_preproc_lowpassfilter(data_right{i},fs_down,lowpass_filter);
    end
    
    %% save data
    if listener < 10
        saveName = strcat('Listener10',num2str(listener),'_Audio_envelope_hilbert_first_64Hz_keep_order.mat');     
    else
        saveName = strcat('Listener1',num2str(listener),'_Audio_envelope_hilbert_first_64Hz_keep_order.mat');  
    end
    
    save(saveName,'data_left_delta','data_right_delta',...
            'data_left_theta','data_right_theta',...
            'data_left_alpha','data_right_alpha',...
            'data_left_beta','data_right_beta');
end
