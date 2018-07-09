cfg = [];%initial the configuration variable
cfg.dataset = 'G:\Speaker-listener_experiment\listener\data\20170718-CYX\20170718-CYX-cocktail.cnt';%making a string
cfg.continuous = 'yes';%the data is a continuous stream
% cfg.channel = 1:9;
data = ft_preprocessing(cfg);

%% Session 1 read data

data_cnt = 1;
cfg = [];
cfg.dataset = 'G:\Speaker-listener_experiment\speaker\20170619-CFY\20170619-CFY.cnt';
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
cfg.dataset = 'G:\Speaker-listener_experiment\speaker\20170619-CFY\20170619-CFY-S2.cnt';
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
cfg.component = [1 25 30 55]; % to be removed component(s)
data_speaker1_total_after_ica = ft_rejectcomponent(cfg, data_comp_speaker1, data_speaker1_total_resample);

% save('listener1',data_listener_ica);

%% re-ref
% chn_sel_index = [1:32 34:42 44:59 61:63];
chn_sel_index = [1:32 34:42 44:48 50:59 61:63]; % without P2
cfg = [];
cfg.reref = 'yes';
cfg.refchannel = chn_sel_index;
data_speaker1_reref = ft_preprocessing(cfg,data_speaker1_total_after_ica);
% data_speaker1_reref = ft_preprocessing(cfg,data_speaker1_total_resample);
% data_listener_reref = ft_preprocessing(cfg,data_comp);


%% bandpass filter old
% % boradband
% cfg = [];
% cfg.bpfilter = 'yes';
% cfg.bpfreq = [0.5 40];
% data_filtered_boradband = ft_preprocessing(cfg,data_speaker1_reref);
% 
% % theta
% cfg = [];
% cfg.bpfilter = 'yes';
% cfg.bpfreq = [2 8];
% data_filtered_theta = ft_preprocessing(cfg,data_speaker1_reref);
% 
% % alpha
% cfg = [];
% cfg.bpfilter = 'yes';
% cfg.bpfreq = [8 12];
% data_filtered_alpha = ft_preprocessing(cfg,data_speaker1_reref);
% 
% % beta
% cfg = [];
% cfg.bpfilter = 'yes';
% cfg.bpfreq = [12 30];
% data_filtered_beta = ft_preprocessing(cfg,data_speaker1_reref);
% 
% 
% % delta
% cfg = [];
% cfg.bpfilter = 'yes';
% cfg.bpfreq = [0.5 4];
% data_filtered_delta = ft_preprocessing(cfg,data_speaker1_reref);
% 
% 
% % narrow theta
% cfg = [];
% cfg.bpfilter = 'yes';
% cfg.bpfreq = [4 7];
% data_filtered_narrow_theta = ft_preprocessing(cfg,data_speaker1_reref);
% 
% 
% % 1-8Hz
% cfg = [];
% cfg.bpfilter = 'yes';
% cfg.bpfreq = [1 8];
% data_filtered_1_8Hz = ft_preprocessing(cfg,data_speaker1_reref);

%% bandpass filter raw
% boradband
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [1 45];
data_filtered_broadband = ft_preprocessing(cfg,data_speaker1_reref);

% theta
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [4 8];
data_filtered_theta = ft_preprocessing(cfg,data_speaker1_reref);

% alpha
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [8 15];
data_filtered_alpha = ft_preprocessing(cfg,data_speaker1_reref);

% beta
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [15 30];
data_filtered_beta = ft_preprocessing(cfg,data_speaker1_reref);


% delta
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [1 4];
data_filtered_delta = ft_preprocessing(cfg,data_speaker1_reref);


% gamma
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [30 45];
data_filtered_gamma = ft_preprocessing(cfg,data_speaker1_reref);

%% bandpass filter hilbert
% boradband
cfg = [];
cfg.bpfilter = 'yes';
cfg.hilbert = 'abs';
cfg.bpfreq = [1 45];
data_filtered_broadband_hilbert = ft_preprocessing(cfg,data_speaker1_reref);

% theta
cfg = [];
cfg.bpfilter = 'yes';
cfg.hilbert = 'abs';
cfg.bpfreq = [4 8];
data_filtered_theta_hilbert = ft_preprocessing(cfg,data_speaker1_reref);

% alpha
cfg = [];
cfg.bpfilter = 'yes';
cfg.hilbert = 'abs';
cfg.bpfreq = [8 15];
data_filtered_alpha_hilbert = ft_preprocessing(cfg,data_speaker1_reref);

% beta
cfg = [];
cfg.bpfilter = 'yes';
cfg.hilbert = 'abs';
cfg.bpfreq = [15 30];
data_filtered_beta_hilbert = ft_preprocessing(cfg,data_speaker1_reref);


% delta
cfg = [];
cfg.bpfilter = 'yes';
cfg.hilbert = 'abs';
cfg.bpfreq = [1 4];
data_filtered_delta_hilbert = ft_preprocessing(cfg,data_speaker1_reref);


% gamma
cfg = [];
cfg.bpfilter = 'yes';
cfg.hilbert = 'abs';
cfg.bpfreq = [30 45];
data_filtered_gamma_hilbert = ft_preprocessing(cfg,data_speaker1_reref);


%% resample to 64Hz
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

%% different type raw

% data type
band_type = {'alpha', 'alpha_hilbert', 'beta', 'beta_hilbert', 'broadband', 'broadband_hilbert',...
        'delta', 'delta_hilbert', 'gamma', 'gamma_hilbert', 'theta', 'theta_hilbert'};

 for jj = 1 : length(band_type)
     temp_name_retell = strcat('data_speakerA_retell_',band_type{jj});
     temp_name_read = strcat('data_speakerA_read_',band_type{jj});
     temp_name_EEG = strcat('data_filtered_',band_type{jj},'.trial');
     eval(strcat(temp_name_retell,'(1:26)=',temp_name_EEG,'(1:26);'));
     eval(strcat(temp_name_read,'(1:23)=',temp_name_EEG,'(27:end);'));
     
 end
 

%% load data
% load('G:\Speaker-listener_experiment\speaker\20170619-CFY\data_preprocessing\Speaker01-CFY-read_retell.mat')
load('G:\Speaker-listener_experiment\speaker\20170619-CFY\speaker01-recording-order.mat');


read=read(~isnan(read));
retell=retell(~isnan(retell));

read_repeat = diff(read);
retell_repeat = diff(retell);

% read valid
for jj = 1 : length(band_type)
    temp_read_name_valid = strcat('data_speakerA_read_',band_type{jj},'_valid');
    temp_read_name = strcat('data_speakerA_read_',band_type{jj});
    
    for i = 1 : length(read_repeat)
        if read_repeat(i)
            eval(strcat(temp_read_name_valid,'{read(i)}=',temp_read_name,'{i};'));
        end
    end
    
    % last one
    eval(strcat(temp_read_name_valid,'{15}=',temp_read_name,'{i+1};'));

    %
    % retell valid
    temp_retell_name_valid = strcat('data_speakerA_retell_',band_type{jj},'_valid');
    temp_retell_name = strcat('data_speakerA_retell_',band_type{jj});
    
    for i = 1 : length(retell_repeat)
        if retell_repeat(i)
            eval(strcat(temp_retell_name_valid,'{retell(i)}=',temp_retell_name,'{i};'));
        end
    end
  
    % last one
   eval(strcat(temp_retell_name_valid,'{15}=',temp_retell_name,'{i+1};'));
end