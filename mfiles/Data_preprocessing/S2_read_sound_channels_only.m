%% only read sound channels
cfg = [];
cfg.channel= [65 66]; % sound
cfg.dataset='H:\Speaker-listener_experiment\listener\data\20170718-CYX\20170718-CYX-cocktail.cnt';

cfg.trialdef.eventtype = 'trigger';
cfg.trialdef.prestim = 5;
cfg.trialdef.poststim = 65;

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
    saveas(gcf,strcat('Trial No.',num2str(i),' trigger',num2str(data_listener_total.trialinfo(i)),'.jpg'));
    close;
%         if data_listener_total.trialinfo(i) == 21
%             data_retell(cnt_retell) =  data_listener_total.trial(cnt_retell);
%             figure;plot(data_retell{cnt_retell}');title(strcat('Raw Sound data from EEG retell story',num2str(cnt_retell)));
%     %         ylim([-1000 1000]);
%             saveas(gcf,strcat('Raw Sound data from EEG retell',num2str(cnt_retell)),'jpg');
%             close;
%             cnt_retell = cnt_retell + 1;
%         else
%             if data_listener_total.trialinfo(i) == 31
%             data_read(cnt_read) =  data_listener_total.trial(cnt_read + 1);
%             figure;plot(data_read{cnt_read}');title(strcat('Raw Sound data from EEG read story',num2str(cnt_retell)));
%             saveas(gcf,strcat('Raw Sound data from EEG read',num2str(cnt_read)),'jpg');
%     
%             close;
%             cnt_read = cnt_read + 1;
%             else
%                 data_other(cnt_other) =  data_listener_total.trial(cnt_other + 1);
%                 figure;plot(data_other{cnt_other}');title(strcat('Raw Sound data from EEG other type',num2str(cnt_other)));
%                 saveas(gcf,strcat('Raw Sound data from EEG other type',num2str(cnt_read)),'jpg');
%     
%             close;
%             cnt_other = cnt_other + 1;
    
    
%             end
%         end
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
        figure;plot(data_retell{cnt_retell}');title(strcat('Raw Sound data from EEG retell story',num2str(cnt_retell)));
        %         ylim([-1000 1000]);
        saveas(gcf,strcat('Raw Sound data from EEG retell',num2str(cnt_retell)),'jpg');
        close;
        cnt_retell = cnt_retell + 1;
    end
    
    if data_filtered_8Hz.trialinfo(i) == 31
        data_read(cnt_read) =  data_filtered_8Hz.trial(cnt_read + 1);
        figure;plot(data_read{cnt_read}');title(strcat('Raw Sound data from EEG read story',num2str(cnt_retell)));ylim([-1000 1000]);
        saveas(gcf,strcat('Raw Sound data from EEG read',num2str(cnt_read)),'jpg');
        
        close;
        cnt_read = cnt_read + 1;
    end
    
end


%% read filtered 8Hz hilbert
%
% % load('G:\Speaker-listener_experiment\listener\data\20170705-LZR\0-LZR-Listener-ICA-filter.mat')
%
data_read = cell(1,14);
data_retell = cell(1,14);

% find different event
cnt_retell = 1;
cnt_read = 1;

for i = 1 : length(data_filtered_8Hz.trialinfo)
    
    if data_filtered_8Hz.trialinfo(i) == 21
        data_retell{cnt_retell}=  abs(hilbert(data_filtered_8Hz.trial{cnt_retell}));
        %         figure;plot(data_retell{cnt_retell}');title(strcat('Hilbert Sound data from EEG retell story',num2str(cnt_retell)));ylim([-10 1500]);
        %         saveas(gcf,strcat('Hilbert Sound data from EEG retell',num2str(cnt_retell)),'jpg');
        %         close;
        cnt_retell = cnt_retell + 1;
        
    end
    
    if data_filtered_8Hz.trialinfo(i) == 31
        data_read{cnt_read}=  abs(hilbert(data_filtered_8Hz.trial{cnt_read + 1}));
        %         figure;plot(data_read{cnt_read}');title(strcat('Hilbert Sound data from EEG read story',num2str(cnt_retell)));ylim([-10 1500]);
        %         saveas(gcf,strcat('Hilbert Sound data from EEG read',num2str(cnt_read)),'jpg');
        cnt_read = cnt_read + 1;
        
    end
    
end

