cfg = [];%initial the configuration variable
cfg.dataset = 'G:\Speaker-listener_experiment\listener\data\20170718-CYX\20170718-CYX-cocktail.cnt';%making a string
cfg.continuous = 'yes';%the data is a continuous stream
% cfg.channel = 1:9;
data = ft_preprocessing(cfg);

%% read data from cnt files and define trials for s1
cfg=[];
cfg.dataset = 'G:\Speaker-listener_experiment\listener\data\20170801-ZM\20170801-ZM.cnt';

cfg.channel= 1:64;
cfg.trialdef.eventtype = 'trigger';
cfg.trialdef.prestim = 5;
cfg.trialdef.poststim = 65;
% cfg.trialfun = 'trialfun_LJW_Listener';
cfg.trialdef.eventvalue = [31 21];

cfg = ft_definetrial(cfg);
data_listener_total_s1 = ft_preprocessing(cfg);


% choose valid data
cfg = [];
cfg.trials  = 1 : 4;
data_listener_total_s1_valid = ft_preprocessing(cfg,data_listener_total_s1);


% cfg = [];
% cfg.dataset = ['../' sub_id '/' sub_id '.cnt'];
% cfg.trialdef.eventtype  = 'trigger';
% cfg.trialdef.eventvalue = [31 32];%[11 12 13 14 15 16];
% cfg.trialdef.prestim    = 0.2;
% cfg.trialdef.poststim   = 1;
% cfg_p300_cond2 = ft_definetrial(cfg);



%% read data from cnt files and define trials s2
cfg=[];
cfg.dataset = 'G:\Speaker-listener_experiment\listener\data\20170801-ZM\20170801-ZM-s2.cnt';
cfg.channel= 1:64;
cfg.trialdef.eventtype = 'trigger';
cfg.trialdef.prestim = 5;
cfg.trialdef.poststim = 65;
% cfg.trialfun = 'trialfun_LJW_Listener';
cfg.trialdef.eventvalue = [21 31];

cfg = ft_definetrial(cfg);
data_listener_total_s2 = ft_preprocessing(cfg);

% choose valid data
cfg = [];
cfg.trials  = 4 : 27;
data_listener_total_s2_valid = ft_preprocessing(cfg,data_listener_total_s2);


%% data append
cfg = [];
data_listener_total = ft_appenddata(cfg,data_listener_total_s1_valid,data_listener_total_s2_valid);

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
cfg = [];
cfg.layout = 'easycapM1.lay'; % specify the layout file that should be used for plotting
cfg.viewmode = 'component';
ft_databrowser(cfg, data_comp);

%% remove artificial
cfg = [];
cfg.component = [3 7]; % to be removed component(s)
data_listener_ica = ft_rejectcomponent(cfg, data_comp, data_listener_total_resample);

%% view after remove artifacts result
cfg = [];
cfg.layout = 'easycapM1.lay'; % specify the layout file that should be used for plotting
cfg.viewmode = 'vertical';
ft_databrowser(cfg, data_listener_ica);

% save('listener1',data_listener_ica);

%% read after ICA data
load('G:\Speaker-listener_experiment\listener\data\20170705-LZR\0-LZR-Listener-ica');

%% re-ref

% listener01 的FPZ有问题
chn_sel_index = [1:32 34:42 44:59 61:63];
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
ft_databrowser(cfg, data_filtered_boradband);
% ft_databrowser(cfg, data_filtered_boradband);

%% different type 
% load listener0 data
load('G:\Speaker-listener_experiment\listener\data\20170705-LZR\0-LZR-Listener-ICA-filter-reref.mat');

% label corrections
data_filtered_boradband.trialinfo(25) = 21;
data_filtered_boradband.trialinfo(26) = 21;

data_filtered_theta.trialinfo(25)= 21;
data_filtered_theta.trialinfo(26) = 21;

% different trial types
listener_boradband_retell = data_filtered_boradband.trial(data_filtered_boradband.trialinfo==21);
listener_boradband_read = data_filtered_boradband.trial(data_filtered_boradband.trialinfo==31);

listener_theta_retell = data_filtered_theta.trial(data_filtered_theta.trialinfo==21);
listener_theta_read = data_filtered_theta.trial(data_filtered_theta.trialinfo==31);

%% different type listener01 and after

% load listener01 data
% load('G:\Speaker-listener_experiment\listener\data\20170718-CYX\01-CYX-Listener-ICA-filter-reref.mat')

% different trial types
listener_boradband_retell = data_filtered_boradband.trial(data_filtered_boradband.trialinfo==21);
listener_boradband_read = data_filtered_boradband.trial(data_filtered_boradband.trialinfo==31);

listener_theta_retell = data_filtered_theta.trial(data_filtered_theta.trialinfo==21);
listener_theta_read = data_filtered_theta.trial(data_filtered_theta.trialinfo==31);

