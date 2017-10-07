cfg = [];%initial the configuration variable
cfg.dataset = 'G:\Speaker-listener_experiment\listener\data\20170718-CYX\20170718-CYX-cocktail.cnt';%making a string
cfg.continuous = 'yes';%the data is a continuous stream
% cfg.channel = 1:9;
data = ft_preprocessing(cfg);

%% Session 1 read data

data_cnt = 1;
cfg = [];
cfg.dataset = 'H:\Speaker-listener_experiment\speaker\20170619-CFY\20170619-CFY.cnt';
cfg.channel= 1:64; 
cfg.trialdef.prestim = 5;
cfg.trialdef.poststim = 65;
cfg.trialfun = 'trialfun_LJW';
cfg = ft_definetrial(cfg);
data_speaker{data_cnt} = ft_preprocessing(cfg);
data_cnt = data_cnt + 1;


%% Session 2 read data

% data_cnt = 1;
cfg = [];
cfg.dataset = 'H:\Speaker-listener_experiment\speaker\20170619-CFY\20170619-CFY-S2.cnt';
cfg.channel= 1:64; 
cfg.trialdef.prestim = 5;
cfg.trialdef.poststim = 65;
cfg.trialfun = 'trialfun_LJW_read';
cfg = ft_definetrial(cfg);
data_speaker{data_cnt} = ft_preprocessing(cfg);
data_cnt = data_cnt + 1;

%% combine 2 sessions
cfg = [];
data_speaker1_combine = ft_appenddata(cfg,data_speaker{1},data_speaker{2});  


%% resample
cfg = [];
cfg.resamplefs = 200;
cfg.detrend    = 'no';
data_speaker1_total_resample = ft_resampledata(cfg, data_speaker1_combine);


%% run ICA
cfg = [];
cfg.method = 'runica';
data_comp_speaker1 = ft_componentanalysis(cfg,data_speaker1_total_resample);

%% view ICA result
cfg = [];
cfg.layout = 'easycapM1.lay'; % specify the layout file that should be used for plotting
cfg.viewmode = 'component';
ft_databrowser(cfg, data_comp_speaker1);

%% remove artificial
cfg = [];
cfg.component = [25 30]; % to be removed component(s)
data_speaker1_total_after_ica = ft_rejectcomponent(cfg, data_comp_speaker1, data_speaker1_total_resample);

% save('listener1',data_listener_ica);

%% re-ref
chn_sel_index = [1:32 34:42 44:59 61:63];
cfg = [];
cfg.reref = 'yes';
cfg.refchannel = chn_sel_index;
data_speaker1_reref = ft_preprocessing(cfg,data_speaker1_total_after_ica);

% data_listener_reref = ft_preprocessing(cfg,data_comp);


%% bandpass filter
% boradband
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [0.5 40];
data_filtered_boradband = ft_preprocessing(cfg,data_speaker1_reref);

% theta
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [2 8];
data_filtered_theta = ft_preprocessing(cfg,data_speaker1_reref);

%% resample to 64Hz
cfg = [];
cfg.resamplefs = 64;
cfg.detrend    = 'no';
data_filtered_boradband = ft_resampledata(cfg, data_filtered_boradband);

cfg = [];
cfg.resamplefs = 64;
cfg.detrend    = 'no';
data_filtered_theta = ft_resampledata(cfg, data_filtered_theta);


%% different type 
load('H:\Speaker-listener_experiment\speaker\20170619-CFY\data_preprocessing\Speaker01-CFY-resample_filter_64Hz.mat');
data_speakerA_retell_theta = cell(1,26);
data_speakerA_read_theta = cell(1,23);

data_speakerA_retell_theta(1:26) = data_filtered_theta.trial(1:26);
data_speakerA_read_theta(1:23)  = data_filtered_theta.trial(27:end);


data_speakerA_retell_boradband = cell(1,26);
data_speakerA_read_boradband = cell(1,23);

data_speakerA_retell_boradband(1:26) = data_filtered_boradband.trial(1:26);
data_speakerA_read_boradband(1:23)  = data_filtered_boradband.trial(27:end);
%% load data
load('H:\Speaker-listener_experiment\speaker\20170619-CFY\data_preprocessing\Speaker01-CFY-read_retell.mat')
load('H:\Speaker-listener_experiment\speaker\20170619-CFY\speaker01-recording-order.mat');


read=read(~isnan(read));
retell=retell(~isnan(retell));

read_repeat = diff(read);
retell_repeat = diff(retell);

% read valid
for i = 1 : length(read_repeat)
    if read_repeat(i)
        data_speakerA_read_boradband_valid{read(i)} = data_speakerA_read_boradband{i};
        data_speakerA_read_theta_valid{read(i)} = data_speakerA_read_theta{i};
    end
end

% last one
data_speakerA_read_boradband_valid{read(i)+1} = data_speakerA_read_boradband{i+1};
data_speakerA_read_theta_valid{read(i)+1}  = data_speakerA_read_theta{i+1};

%
% retell valid
for i = 1 : length(retell_repeat)
%     disp(retell_repeat(i))
    if retell_repeat(i)
        
        data_speakerA_retell_boradband_valid{retell(i)} = data_speakerA_retell_boradband{i};
        data_speakerA_retell_theta_valid{retell(i)} = data_speakerA_retell_theta{i};
    end
end

% last one 最后一段有重复 
data_speakerA_retell_boradband_valid{retell(i)} = data_speakerA_retell_boradband{i+1};
data_speakerA_retell_theta_valid{retell(i)}  = data_speakerA_retell_theta{i+1};

