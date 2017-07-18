cfg = [];%initial the configuration variable
cfg.dataset = 'G:\Speaker-listener_experiment\listener\data\20170705-LZR\20170704-LZR.cnt';%making a string
cfg.continuous = 'yes';%the data is a continuous stream
% cfg.channel = 1:9;
data = ft_preprocessing(cfg);

%% read data from cnt files and define trials
cfg=[];
cfg.dataset='G:\Speaker-listener_experiment\listener\data\20170705-LZR\20170704-LZR.cnt';

cfg.trialdef.eventtype = 'trigger';
cfg.trialdef.prestim = 5;
cfg.trialdef.poststim = 80;
% cfg.trialfun = 'trialfun_LJW_Listener';
cfg_tri.trialdef.eventvalue = [21 31];

cfg = ft_definetrial(cfg);
data_listener_total = ft_preprocessing(cfg);


% cfg = [];
% cfg.dataset = ['../' sub_id '/' sub_id '.cnt'];
% cfg.trialdef.eventtype  = 'trigger';
% cfg.trialdef.eventvalue = [31 32];%[11 12 13 14 15 16];
% cfg.trialdef.prestim    = 0.2;
% cfg.trialdef.poststim   = 1;
% cfg_p300_cond2 = ft_definetrial(cfg);



%% resample
cfg = [];
cfg.resamplefs = 200;
cfg.detrend    = 'no';
data_listener_total_resample = ft_resampledata(cfg, data_listener_total);


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
cfg.component = [2 13 66]; % to be removed component(s)
data_listener_ica = ft_rejectcomponent(cfg, data_comp, data_listener_total_resample);

% save('listener1',data_listener_ica);

%% read after ICA data
load('G:\Speaker-listener_experiment\listener\data\20170705-LZR\0-LZR-Listener-ica');

%% re-ref
chn_sel_index = [1:32 34:42 44:59 61:63];
cfg = [];
cfg.reref = 'yes';
cfg.refchannel = chn_sel_index;
data_listener_reref = ft_preprocessing(cfg,data_listener_ica);




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


%% read filtered theta
% load('G:\Speaker-listener_experiment\listener\data\20170705-LZR\0-LZR-Listener-ICA-filter.mat')

data_read = cell(1,14);
data_retell = cell(1,14);
 
% find different event
cnt_retell = 1;
cnt_read = 1;

for i = 1 : length(data_filtered_theta.trialinfo)
    
    if data_filtered_theta.trialinfo(i) == 21
        data_retell(cnt_retell) =  data_filtered_theta.trial(cnt_retell);
        cnt_retell = cnt_retell + 1;
    end
    
    if data_filtered_theta.trialinfo(i) == 31
        data_read(cnt_read) =  data_filtered_theta.trial(cnt_read + 1);
        cnt_read = cnt_read + 1;
    end
    
end

%% read filtered 8Hz
% load('G:\Speaker-listener_experiment\listener\data\20170705-LZR\0-LZR-Listener-ICA-filter.mat')

data_read = cell(1,14);
data_retell = cell(1,14);
 
% find different event
cnt_retell = 1;
cnt_read = 1;

for i = 1 : length(data_filtered_8Hz.trialinfo)
    
    if data_filtered_8Hz.trialinfo(i) == 21
        data_retell(cnt_retell) =  data_filtered_8Hz.trial(cnt_retell);
        cnt_retell = cnt_retell + 1;
    end
    
    if data_filtered_8Hz.trialinfo(i) == 31
        data_read(cnt_read) =  data_filtered_8Hz.trial(cnt_read + 1);
        cnt_read = cnt_read + 1;
    end
    
end



