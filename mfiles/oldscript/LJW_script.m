%processing script for LJW's speaker-listener exp, 2015-05-17

cfg=[];
cfg.dataset='G:\DataProcessing\Lijiawei\Speaker-Listener\Data\ListenerRecord\1-LGY-20150512\1-LGY-20150512.cnt';

cfg.trialdef.prestim = 5;
cfg.trialdef.poststim = 45;
cfg.trialfun = 'trialfun_LJW_Listener';
cfg = ft_definetrial(cfg);
data_listener = ft_preprocessing(cfg);

cfg = [];
cfg.resamplefs = 200;
cfg.detrend    = 'no';
data_listener = ft_resampledata(cfg, data_listener_reref);

cfg = [];
cfg.method = 'runica';
data_comp = ft_componentanalysis(cfg,data_listener);

%%
cfg = [];
cfg.layout = 'easycapM1.lay'; % specify the layout file that should be used for plotting
cfg.viewmode = 'component';
ft_databrowser(cfg, data_comp);

%%
cfg = [];
cfg.component = [1 5]; % to be removed component(s)
data_listener_ica = ft_rejectcomponent(cfg, data_comp, data_listener);

save data_listener_ica data_listener_ica

%% AEP analysis 
clear
load data_listener_ica

cfg = [];
cfg.reref = 'yes';
cfg.refchannel = {'M1','M2'};
data_listener_reref = ft_preprocessing(cfg,data_listener_ica);

cfg = [];
cfg.bpfilter = 'yes';
% cfg.bpfreq = [0.5 40];
cfg.bpfreq = [4 8];
data_listener_fil = ft_preprocessing(cfg,data_listener_reref);

%%
t_task = find(data_listener_fil.time{1}>5 & data_listener_fil.time{1}<25);
t_baseline = find(data_listener_fil.time{1}>-2 & data_listener_fil.time{1}<0);
for i = 1:45
    for j = 1:66
        AEP(i,j)=mean(data_listener_fil.trial{i}(j,t_task))-mean(data_listener_fil.trial{i}(j,t_baseline));
    end
end

mAEP=mean(AEP,1);
load label66
U_topoplot(mAEP','easycapm1.lay',label66);

%% read-in .wav files
dirA='G:\ZhangDan\personal\LJW\program\Listener3.0\SpeakerA';
dirB='G:\ZhangDan\personal\LJW\program\Listener3.0\SpeakerB';
Fs=44100;
fs_down=20;
for i=1:15
    if(i<10)
        y_a=wavread([dirA '\0' int2str(i) 'A.wav' ]);
        y_b=wavread([dirB '\0' int2str(i) 'B.wav' ]);
    else
        y_a=wavread([dirA '\' int2str(i) 'A.wav' ]);
        y_b=wavread([dirB '\' int2str(i) 'B.wav' ]);
    end
    %take the first 5-20 sec and resample to 20Hz power envelop
    y_a=smooth(y_a.^2,0.1*Fs);
    y_b=smooth(y_b.^2,0.1*Fs);
    y_a=resample(y_a,fs_down,Fs);
    y_b=resample(y_b,fs_down,Fs);
    y_a=y_a(fs_down*5+1:fs_down*20);
    y_b=y_b(fs_down*5+1:fs_down*20);
    YA(i,:)=y_a;
    YB(i,:)=y_b;
end

%% correlation analysis, theta power envelop vs. auditory input
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [4 8];
data_listener_theta = ft_preprocessing(cfg,data_listener_reref);

% chn_sel=[1:32 34:42 44:59 61:63];
chn_sel=[9 10 11 18 19 20 27 28 29 38];
smooth_para=20;%100ms @ 200Hz
for i=1:45
    for j=1:66
        data_listener_theta.trial{i}(j,:)=smooth(data_listener_theta.trial{i}(j,:).^2,smooth_para);
    end
end

fs_down=20;
cfg = [];
cfg.resamplefs = fs_down;
cfg.detrend    = 'no';
data_listener_theta = ft_resampledata(cfg, data_listener_theta);

for n_step = -10:10
    n_step
    t_sel=find(data_listener_theta.time{1}>5 & data_listener_theta.time{1}<=20);
    t_sel=t_sel+n_step*0.1*fs_down;
    for i=1:45
        for j=1:15
            [A B r]=canoncorr(data_listener_theta.trial{i}(chn_sel,t_sel)',YA(j,:)');
            r_a(i,j,n_step+11)=r(1);
            [A B r]=canoncorr(data_listener_theta.trial{i}(chn_sel,t_sel)',YB(j,:)');
            r_b(i,j,n_step+11)=r(1);
        end
    end
end

%% CCA for between trials
chn_sel=[9 10 11 18 19 20 27 28 29 38];
% chn_sel=[1:32 34:42 44:59 61:63];
for i=1:45
    for j=i+1:45
       [A B r]=canoncorr(data_listener_theta.trial{i}(chn_sel,t_sel)',data_listener_theta.trial{j}(chn_sel,t_sel)');
       r_trial(i,j)=r(1);
       r_trial(j,i)=r(1);
    end
    r_trial(i,i)=1;
end
