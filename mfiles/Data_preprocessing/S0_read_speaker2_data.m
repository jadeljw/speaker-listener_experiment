
%% Session 1 read data ->retell session

data_cnt = 1;
cfg = [];
cfg.dataset = 'H:\Speaker-listener_experiment\speaker\20170622-FS\20170622-FS.cnt';
cfg.channel= 1:64; 
cfg.trialdef.prestim = 5;
cfg.trialdef.poststim = 65;
cfg.trialfun = 'trialfun_LJW';
cfg = ft_definetrial(cfg);
data_speaker{data_cnt} = ft_preprocessing(cfg);
data_cnt = data_cnt + 1;


%% Session 2 read data ->read session

% data_cnt = 1;
cfg = [];
cfg.dataset = 'H:\Speaker-listener_experiment\speaker\20170622-FS\20170622-FS-s2.cnt';
cfg.channel= 1:64; 
cfg.trialdef.prestim = 5;
cfg.trialdef.poststim = 65;
cfg.trialfun = 'trialfun_LJW_read';
cfg = ft_definetrial(cfg);
data_speaker{data_cnt} = ft_preprocessing(cfg);
data_cnt = data_cnt + 1;

%% combine 2 sessions
cfg = [];
data_speaker2_combine = ft_appenddata(cfg,data_speaker{1},data_speaker{2});  


%% resample
cfg = [];
cfg.resamplefs = 200;
cfg.detrend    = 'no';
data_speaker2_total_resample = ft_resampledata(cfg, data_speaker2_combine);


%% run ICA
cfg = [];
cfg.method = 'runica';
data_comp_speaker2 = ft_componentanalysis(cfg,data_speaker2_total_resample);

%% view ICA result
cfg = [];
cfg.layout = 'easycapM1.lay'; % specify the layout file that should be used for plotting
cfg.viewmode = 'component';
ft_databrowser(cfg, data_comp_speaker2);

%% remove artificial
cfg = [];
cfg.component = [25 56 60]; % to be removed component(s)
data_speaker2_total_after_ica = ft_rejectcomponent(cfg, data_comp_speaker2, data_speaker2_total_resample);

% save('listener1',data_listener_ica);

%% re-ref
chn_sel_index = [1:32 34:42 44:59 61:63];
cfg = [];
cfg.reref = 'yes';
cfg.refchannel = chn_sel_index;
data_speaker2_reref = ft_preprocessing(cfg,data_speaker2_total_after_ica);

% data_listener_reref = ft_preprocessing(cfg,data_comp);


%% bandpass filter
% boradband
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [0.5 40];
data_filtered_boradband = ft_preprocessing(cfg,data_speaker2_reref);

% theta
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [2 8];
data_filtered_theta = ft_preprocessing(cfg,data_speaker2_reref);

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

data_speakerB_retell_theta = cell(1,19);
data_speakerB_read_theta = cell(1,22);

data_speakerB_retell_theta(1:19) = data_filtered_theta.trial(1:19);
data_speakerB_read_theta(1:22)  = data_filtered_theta.trial(20:end);


data_speakerB_retell_boradband = cell(1,19);
data_speakerB_read_boradband = cell(1,22);

data_speakerB_retell_boradband(1:19) = data_filtered_boradband.trial(1:19);
data_speakerB_read_boradband(1:22)  = data_filtered_boradband.trial(20:end);

%% load recording order
load('H:\Speaker-listener_experiment\speaker\20170622-FS\speaker02-recording-order.mat');
load('H:\Speaker-listener_experiment\speaker\20170622-FS\data_preprocessing\Speaker02-FS-read_retell.mat');

read=read(~isnan(read));
retell=retell(~isnan(retell));

read_repeat = diff(read);
retell_repeat = diff(retell);

% 第二段reading的材料用的是第一次录的
read_repeat(2) = 1;
read_repeat(3) = 0;


% read valid
for i = 1 : length(read_repeat)
    if read_repeat(i)
        data_speakerB_read_boradband_valid{read(i)} = data_speakerB_read_boradband{i};
        data_speakerB_read_theta_valid{read(i)} = data_speakerB_read_theta{i};
    end
end
% last one
data_speakerB_read_boradband_valid{read(i)+1} = data_speakerB_read_boradband{i+1};
data_speakerB_read_theta_valid{read(i)+1}  = data_speakerB_read_theta{i+1};

% retell valid
for i = 1 : length(retell_repeat)
    if retell_repeat(i)
        disp(retell(i))
        data_speakerB_retell_boradband_valid{retell(i)} = data_speakerB_retell_boradband{i};
        data_speakerB_retell_theta_valid{retell(i)} = data_speakerB_retell_theta{i};
    end
end

% last one
data_speakerB_retell_boradband_valid{retell(i)+1} = data_speakerB_retell_boradband{i+1};
data_speakerB_retell_theta_valid{retell(i)+1}  = data_speakerB_retell_theta{i+1};
