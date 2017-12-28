
%% read data from cnt files and define trials
cfg=[];
cfg.dataset =  'G:\Speaker-listener_experiment\listener\data\20171115-beep_test\20171115-TSET\20171115-BEEP-TEST-white-noise.cnt';
cfg.channel= [65 66];
cfg.trialdef.eventtype = 'trigger';
cfg.trialdef.prestim = 0;
cfg.trialdef.poststim = 30;
% cfg.trialfun = 'trialfun_LJW_Listener';
cfg.trialdef.eventvalue = [21 31];

cfg = ft_definetrial(cfg);
data_listener_total = ft_preprocessing(cfg);

% choose valid data
cfg = [];
% cfg.trials  = 1 : 20;
data_listener_total = ft_preprocessing(cfg,data_listener_total);



 %% resample
% cfg = [];
% cfg.resamplefs = 200;
% cfg.detrend    = 'no';
% data_listener_total_resample = ft_resampledata(cfg, data_listener_total);

%% view raw data
cfg = [];
cfg.layout = 'easycapM1.lay'; % specify the layout file that should be used for plotting
cfg.viewmode = 'vertical';
ft_databrowser(cfg, data_listener_total);

% save('listener1',data_listener_ica);


