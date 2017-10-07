%% only read sound channels
cfg = [];
cfg.channel= [65 66]; % sound
% cfg.dataset='H:\Speaker-listener_experiment\listener\data\20170705-LZR\20170705-LZR.cnt';
cfg.dataset='H:\Speaker-listener_experiment\listener\data\20170718-CYX\20170718-CYX-EfferenceChinese.cnt'; 
% cfg.dataset='H:\Speaker-listener_experiment\listener\data\20170718-CYX\20170718-CYX-cocktail.cnt';


cfg.trialdef.eventtype = 'trigger';
cfg.trialdef.prestim = 0;
cfg.trialdef.poststim = 41;

% cfg.demean        = 'yes'; %whether to apply baseline correction (default = 'no')
% cfg.baselinewindow = [0 2];
% cfg.trialfun = 'trialfun_LJW_Listener';
cfg.trialdef.eventvalue = [21 31];
cfg = ft_definetrial(cfg);
data_listener_total = ft_preprocessing(cfg);


%% plot

data_read = cell(1,14);
data_retell = cell(1,14);
data_other = cell(1,14);

% find different event
cnt_retell = 1;
cnt_read = 1;
cnt_other = 1 ;

for i = 1 : length(data_listener_total.trial)
    
    figure;plot(data_listener_total.trial{i}');
    title(strcat('Trial No.',num2str(i),' trigger',num2str(data_listener_total.trialinfo(i))));
%     saveas(gcf,strcat('Trial No.',num2str(i),' trigger',num2str(data_listener_total.trialinfo(i)),'.jpg'));
%     close;

end

%% hilbert first
for i = 1 : length(data_listener_total.trial)
    
    data_listener_total.trial{i}(1,:) = abs(hilbert(data_listener_total.trial{i}(1,:)));
    data_listener_total.trial{i}(2,:) = abs(hilbert(data_listener_total.trial{i}(2,:)));

end

%% resample
cfg = [];
cfg.resamplefs = 64;
cfg.detrend    = 'no';
data_listener_total_resample = ft_resampledata(cfg, data_listener_total);

%% lowpass filter

cfg = [];
cfg.lpfilter = 'yes';
cfg.lpfreq = 8;
data_filtered_8Hz = ft_preprocessing(cfg,data_listener_total_resample);


