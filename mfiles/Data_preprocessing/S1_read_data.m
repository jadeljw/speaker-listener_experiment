cfg = [];%initial the configuration variable
cfg.dataset = 'G:\Speaker-listener_experiment\listener\data\20171118-YJMQ\20171118-YJMQ-cocktail.cnt';%making a string
cfg.continuous = 'yes';%the data is a continuous stream
% cfg.channel = 1:9;
data = ft_preprocessing(cfg);

%% read data from cnt files and define trials
cfg=[];
cfg.dataset = 'H:\Speaker-listener2017\data\20171221-LYB\20171221-LYB.cnt';
% cfg.dataset = 'G:\Speaker-listener2017\data\20171125-LX\20171125-LX.cnt';
cfg.channel= 1:64;
cfg.trialdef.eventtype = 'trigger';
cfg.trialdef.prestim = 5;
cfg.trialdef.poststim = 65;
% cfg.trialfun = 'trialfun_LJW_Listener';
cfg.trialdef.eventvalue = [21 31];

cfg = ft_definetrial(cfg);
data_listener_total = ft_preprocessing(cfg);

% % choose valid data
% cfg = [];
% cfg.trials  = 1 : 20;
% data_listener_total = ft_preprocessing(cfg,data_listener_total);



%% resample
cfg = [];
cfg.resamplefs = 200;
cfg.detrend    = 'no';
data_listener_total_resample = ft_resampledata(cfg, data_listener_total);

%% view raw data
cfg = [];
cfg.layout = 'easycapM1.lay'; % specify the layout file that should be used for plotting
cfg.viewmode = 'vertical';
ft_databrowser(cfg, data_listener_total_resample);

% save('listener1',data_listener_ica);


%% run ICA
cfg = [];
cfg.method = 'runica';
data_comp = ft_componentanalysis(cfg,data_listener_total_resample);

%% view ICA result
% load('E:\DataProcessing\easycapm1.mat');
cfg = [];
cfg.layout = 'E:\DataProcessing\easycapm1.mat'; % specify the layout file that should be used for plotting
cfg.viewmode = 'component';
ft_databrowser(cfg, data_comp);

%% remove artificial
cfg = [];
cfg.component = [16 49 61]; % to be removed component(s)
data_listener_ica = ft_rejectcomponent(cfg, data_comp, data_listener_total_resample);

%% view after remove artifacts result
cfg = [];
% cfg.layout = 'easycapM1.lay'; % specify the layout file that should be used for plotting
cfg.layout = 'E:\DataProcessing\easycapm1.mat';
cfg.viewmode = 'vertical';
ft_databrowser(cfg, data_listener_ica);

% save('listener1',data_listener_ica);

%% read after ICA data
load('G:\Speaker-listener_experiment\listener\data\20170705-LZR\0-LZR-Listener-ica');

%% re-ref

% listener111 的FPZ有问题
chn_sel_index = [1:32 34:42 44:59 61:63];
% chn_sel_index = [1:32 34:42 44:48 50:59 61:63]; % without P2
% chn_sel_index = [1 3:32 34:42 44:59 61:63]; % without FPZ
cfg = [];
cfg.reref = 'yes';
cfg.refchannel = chn_sel_index;
data_listener_reref = ft_preprocessing(cfg,data_listener_ica);

% data_listener_reref = ft_preprocessing(cfg,data_comp);


%% bandpass filter
% boradband
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [0.5 40];
data_filtered_boradband = ft_preprocessing(cfg,data_listener_reref);

% theta
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [2 8];
data_filtered_theta = ft_preprocessing(cfg,data_listener_reref);


%% resample to 64Hz
cfg = [];
cfg.resamplefs = 64;
cfg.detrend    = 'no';
data_filtered_boradband = ft_resampledata(cfg, data_filtered_boradband);

cfg = [];
cfg.resamplefs = 64;
cfg.detrend    = 'no';
data_filtered_theta = ft_resampledata(cfg, data_filtered_theta);

%% view after bandpass result
cfg = [];
cfg.layout = 'easycapM1.lay'; % specify the layout file that should be used for plotting
cfg.viewmode = 'vertical';
ft_databrowser(cfg, data_filtered_theta);
% ft_databrowser(cfg, data_filtered_boradband);

%% different type 


% different trial types
listener_boradband_retell = data_filtered_boradband.trial(data_filtered_boradband.trialinfo==21);
listener_boradband_read = data_filtered_boradband.trial(data_filtered_boradband.trialinfo==31);

listener_theta_retell = data_filtered_theta.trial(data_filtered_theta.trialinfo==21);
listener_theta_read = data_filtered_theta.trial(data_filtered_theta.trialinfo==31);

