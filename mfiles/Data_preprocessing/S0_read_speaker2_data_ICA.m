
%% Session 1 read data ->retell session

data_cnt = 1;
cfg = [];
cfg.dataset = 'G:\Speaker-listener_experiment\speaker\20170622-FS\20170622-FS.cnt';
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
cfg.dataset = 'G:\Speaker-listener_experiment\speaker\20170622-FS\20170622-FS-s2.cnt';
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



%% bandpass filter raw
% boradband
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [1 45];
data_filtered_broadband = ft_preprocessing(cfg,data_comp_speaker2);

% theta
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [4 8];
data_filtered_theta = ft_preprocessing(cfg,data_comp_speaker2);

% alpha
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [8 15];
data_filtered_alpha = ft_preprocessing(cfg,data_comp_speaker2);

% beta
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [15 30];
data_filtered_beta = ft_preprocessing(cfg,data_comp_speaker2);


% delta
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [1 4];
data_filtered_delta = ft_preprocessing(cfg,data_comp_speaker2);


% gamma
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [30 45];
data_filtered_gamma = ft_preprocessing(cfg,data_comp_speaker2);

%% bandpass filter hilbert
% boradband
cfg = [];
cfg.bpfilter = 'yes';
cfg.hilbert = 'abs';
cfg.bpfreq = [1 45];
data_filtered_broadband_hilbert = ft_preprocessing(cfg,data_comp_speaker2);

% theta
cfg = [];
cfg.bpfilter = 'yes';
cfg.hilbert = 'abs';
cfg.bpfreq = [4 8];
data_filtered_theta_hilbert = ft_preprocessing(cfg,data_comp_speaker2);

% alpha
cfg = [];
cfg.bpfilter = 'yes';
cfg.hilbert = 'abs';
cfg.bpfreq = [8 15];
data_filtered_alpha_hilbert = ft_preprocessing(cfg,data_comp_speaker2);

% beta
cfg = [];
cfg.bpfilter = 'yes';
cfg.hilbert = 'abs';
cfg.bpfreq = [15 30];
data_filtered_beta_hilbert = ft_preprocessing(cfg,data_comp_speaker2);


% delta
cfg = [];
cfg.bpfilter = 'yes';
cfg.hilbert = 'abs';
cfg.bpfreq = [1 4];
data_filtered_delta_hilbert = ft_preprocessing(cfg,data_comp_speaker2);


% gamma
cfg = [];
cfg.bpfilter = 'yes';
cfg.hilbert = 'abs';
cfg.bpfreq = [30 45];
data_filtered_gamma_hilbert = ft_preprocessing(cfg,data_comp_speaker2);


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
     temp_name_retell = strcat('data_speakerB_retell_',band_type{jj});
     temp_name_read = strcat('data_speakerB_read_',band_type{jj});
     temp_name_EEG = strcat('data_filtered_',band_type{jj},'.trial');
     eval(strcat(temp_name_retell,'(1:19)=',temp_name_EEG,'(1:19);'));
     eval(strcat(temp_name_read,'(1:22)=',temp_name_EEG,'(20:end);'));
     
 end
 

%% load data
load('G:\Speaker-listener_experiment\speaker\20170622-FS\speaker02-recording-order.mat');
load('G:\Speaker-listener_experiment\speaker\20170622-FS\data_preprocessing\Speaker02-FS-read_retell.mat');


read=read(~isnan(read));
retell=retell(~isnan(retell));

read_repeat = diff(read);
retell_repeat = diff(retell);

% read valid
for jj = 1 : length(band_type)
    temp_read_name_valid = strcat('data_speakerB_read_',band_type{jj},'_valid');
    temp_read_name = strcat('data_speakerB_read_',band_type{jj});
    
    for i = 1 : length(read_repeat)
        if read_repeat(i)
            eval(strcat(temp_read_name_valid,'{read(i)}=',temp_read_name,'{i};'));
        end
    end
    
    % last one
    eval(strcat(temp_read_name_valid,'{15}=',temp_read_name,'{i+1};'));

    %
    % retell valid
    temp_retell_name_valid = strcat('data_speakerB_retell_',band_type{jj},'_valid');
    temp_retell_name = strcat('data_speakerB_retell_',band_type{jj});
    
    for i = 1 : length(retell_repeat)
        if retell_repeat(i)
            eval(strcat(temp_retell_name_valid,'{retell(i)}=',temp_retell_name,'{i};'));
        end
    end
  
    % last one
   eval(strcat(temp_retell_name_valid,'{15}=',temp_retell_name,'{i+1};'));
end




