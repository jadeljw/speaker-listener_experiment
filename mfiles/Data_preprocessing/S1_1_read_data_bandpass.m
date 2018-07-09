
%% read after ICA data
dataFile_all = {'20171122-RT',...
    '20171124-ZR','20171125-LX','20171128-WCW',...
    '20171130-WY','20171202-LGZ','20171205-PXJ','20171206-LNN',...
    '20171209-ZXT','20171209-LX','20171213-SYH',...
    '20171214-WXZ','20171214-LYZ','20171216-ZX',...
    '20171216-HY','20171220-WM','20171221-ZC',...
    '20171221-LYB'};

dataName_all = {'103-RT-Listener-after-ICA',...
    '104-ZR-Listener-after-ICA',...
    '105-LX-Listener-after-ICA',...
    '106-WCW-Listener-after-ICA',...
    '107-WY-Listener-after-ICA',...
    '108-LGZ-Listener-after-ICA',...
    '109-PXJ-Listener-after-ICA',...
    '110-LNN-Listener-after-ICA',...
    '111-ZXT-Listener-after-ICA',...
    '112-LX-Listener-after-ICA',...
    '113-SYH-Listener-after-ICA',...
    '114-WXZ-Listener-after-ICA',...
    '115-LYZ-Listener-after-ICA',...
    '116-ZX-Listener-after-ICA',...
    '117-HY-Listener-after-ICA',...
    '118-WM-Listener-after-ICA',...
    '119-ZC-Listener-after-ICA',...
    '120-LYB-Listener-after-ICA'};

save_name_all = {'103-RT-Listener-ICA-reref-filter_64Hz_new',...
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


for i = 1 : length(dataFile_all)
    
    load(strcat('G:\Speaker-listener_experiment\listener\data\',dataFile_all{i},'\',dataName_all{i},'.mat'));
    %% re-ref
    
    % listener111 的FPZ有问题
    chn_sel_index = [1:32 34:42 44:59 61:63];
    % % chn_sel_index = [1:32 34:42 44:48 50:59 61:63]; % without P2
    % chn_sel_index = [1 3:32 34:42 44:59 61:63]; % without FPZ
    cfg = [];
    cfg.reref = 'yes';
    cfg.refchannel = chn_sel_index;
    data_listener_reref = ft_preprocessing(cfg,data_listener_ica);
    
    % data_listener_reref = ft_preprocessing(cfg,data_comp);
    
    
    
    
    %% bandpass filter only
    % boradband
    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [1 40];
    data_filtered_broadband = ft_preprocessing(cfg,data_listener_reref);
    
    % theta
    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [4 8];
    data_filtered_theta = ft_preprocessing(cfg,data_listener_reref);
    
    % alpha
    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [8 15];
    data_filtered_alpha = ft_preprocessing(cfg,data_listener_reref);
    
    % beta
    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [15 30];
    data_filtered_beta = ft_preprocessing(cfg,data_listener_reref);
    
    
    % delta
    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [1 4];
    data_filtered_delta = ft_preprocessing(cfg,data_listener_reref);
    
    
    % gamma
    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [30 45];
    data_filtered_gamma= ft_preprocessing(cfg,data_listener_reref);
    
    
    %% bandpass filter hilbert
    
    % boradband
    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.hilbert = 'abs';
    cfg.bpfreq = [1 40];
    data_filtered_broadband_hilbert = ft_preprocessing(cfg,data_listener_reref);
    
    % theta
    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.hilbert = 'abs';
    cfg.bpfreq = [4 8];
    data_filtered_theta_hilbert = ft_preprocessing(cfg,data_listener_reref);
    
    % alpha
    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.hilbert = 'abs';
    cfg.bpfreq = [8 15];
    data_filtered_alpha_hilbert = ft_preprocessing(cfg,data_listener_reref);
    
    % beta
    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.hilbert = 'abs';
    cfg.bpfreq = [15 30];
    data_filtered_beta_hilbert = ft_preprocessing(cfg,data_listener_reref);
    
    
    % delta
    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.hilbert = 'abs';
    cfg.bpfreq = [1 4];
    data_filtered_delta_hilbert = ft_preprocessing(cfg,data_listener_reref);
    
    
    % gamma
    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.hilbert = 'abs';
    cfg.bpfreq = [30 45];
    data_filtered_gamma_hilbert= ft_preprocessing(cfg,data_listener_reref);
    
    
    
    %% resample to 64Hz
    
    % raw
    cfg = [];
    cfg.resamplefs = 64;
    cfg.detrend    = 'no';
    data_filtered_broadband = ft_resampledata(cfg, data_filtered_broadband);
    
    cfg = [];
    cfg.resamplefs = 64;
    cfg.detrend    = 'no';
    data_filtered_theta = ft_resampledata(cfg, data_filtered_theta);
    
    cfg = [];
    cfg.resamplefs = 64;
    cfg.detrend    = 'no';
    data_filtered_alpha = ft_resampledata(cfg, data_filtered_alpha);
    
    cfg = [];
    cfg.resamplefs = 64;
    cfg.detrend    = 'no';
    data_filtered_beta = ft_resampledata(cfg, data_filtered_beta);
    
    cfg = [];
    cfg.resamplefs = 64;
    cfg.detrend    = 'no';
    data_filtered_delta = ft_resampledata(cfg, data_filtered_delta);
    
    
    cfg = [];
    cfg.resamplefs = 64;
    cfg.detrend    = 'no';
    data_filtered_gamma = ft_resampledata(cfg, data_filtered_gamma);
    
    
    % hilbert
    cfg = [];
    cfg.resamplefs = 64;
    cfg.detrend    = 'no';
    data_filtered_broadband_hilbert = ft_resampledata(cfg, data_filtered_broadband_hilbert);
    
    cfg = [];
    cfg.resamplefs = 64;
    cfg.detrend    = 'no';
    data_filtered_theta_hilbert = ft_resampledata(cfg, data_filtered_theta_hilbert);
    
    cfg = [];
    cfg.resamplefs = 64;
    cfg.detrend    = 'no';
    data_filtered_alpha_hilbert = ft_resampledata(cfg, data_filtered_alpha_hilbert);
    
    cfg = [];
    cfg.resamplefs = 64;
    cfg.detrend    = 'no';
    data_filtered_beta_hilbert = ft_resampledata(cfg, data_filtered_beta_hilbert);
    
    cfg = [];
    cfg.resamplefs = 64;
    cfg.detrend    = 'no';
    data_filtered_delta_hilbert = ft_resampledata(cfg, data_filtered_delta_hilbert);
    
    
    cfg = [];
    cfg.resamplefs = 64;
    cfg.detrend    = 'no';
    data_filtered_gamma_hilbert = ft_resampledata(cfg, data_filtered_gamma_hilbert);
    
    %% save data
    save(save_name_all{i},'data_filtered_alpha', 'data_filtered_alpha_hilbert', 'data_filtered_beta', 'data_filtered_beta_hilbert', 'data_filtered_broadband', 'data_filtered_broadband_hilbert',...
        'data_filtered_delta', 'data_filtered_delta_hilbert', 'data_filtered_gamma', 'data_filtered_gamma_hilbert', 'data_filtered_theta', 'data_filtered_theta_hilbert');
end