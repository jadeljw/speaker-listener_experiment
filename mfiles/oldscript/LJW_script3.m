%% AEP analysis 
clear
load data_listener_ica

%%
% t_task = find(data_listener_fil.time{1}>5 & data_listener_fil.time{1}<25);
% t_baseline = find(data_listener_fil.time{1}>-2 & data_listener_fil.time{1}<0);
% for i = 1:45
%     for j = 1:66
%         AEP(i,j)=mean(data_listener_fil.trial{i}(j,t_task))-mean(data_listener_fil.trial{i}(j,t_baseline));
%     end
% end
% 
% mAEP=mean(AEP,1);
% load label66
% U_topoplot(mAEP','easycapm1.lay',label66);

%% read-in .wav files
dirA='G:\ZhangDan\personal\LJW\program\Listener3.0\SpeakerA';
dirB='G:\ZhangDan\personal\LJW\program\Listener3.0\SpeakerB';
Fs=44100;
fs_down=20;
for i=1:15
    if(i<10)
        y_a=wavread([dirA '/0' int2str(i) 'A.wav' ]);
        y_b=wavread([dirB '/0' int2str(i) 'B.wav' ]);
    else
        y_a=wavread([dirA '/' int2str(i) 'A.wav' ]);
        y_b=wavread([dirB '/' int2str(i) 'B.wav' ]);
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
cfg.reref = 'yes';
cfg.refchannel = {'M1','M2'};
data_listener_reref = ft_preprocessing(cfg,data_listener_ica);

cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [0.5 40];
% cfg.bpfreq = [4 8];
data_listener_fil = ft_preprocessing(cfg,data_listener_reref);

% chn_sel=[1:32 34:42 44:59 61:63];
% chn_sel=[9 10 11 18 19 20 27 28 29 38];
smooth_para=20;%100ms @ 200Hz
for i=1:45
    for j=1:66
%         data_listener_fil.trial{i}(j,:)=smooth(data_listener_fil.trial{i}(j,:).^2,smooth_para);
        data_listener_fil.trial{i}(j,:)=smooth(data_listener_fil.trial{i}(j,:),smooth_para);
    end
end

fs_down=20;
cfg = [];
cfg.resamplefs = fs_down;
cfg.detrend    = 'no';
data_listener_fil = ft_resampledata(cfg, data_listener_fil);

%%
data_seq=load('1-LGY-Listener-20150512-1707.mat','OrderNum');
% chn_sel=[9 10 11 18 19 20 27 28 29 38];
% chn_sel_r=[11 10 9 20 19 18 29 28 27 38];
chn_sel=[1:32 34:42 44:59 61:63];
chn_sel_r=[3:-1:1 5 4 14:-1:6 23:-1:15 32:-1:24 42:-1:34 52:-1:44 59:-1:53 63:-1:61];
%pure A
data_audio=[];data_eeg=[];
t_sel=find(data_listener_fil.time{1}>5 & data_listener_fil.time{1}<=20);
for i=1:15
    audio_index=str2num(data_seq.OrderNum{15+i,2}(1:2));
    data_audio=[data_audio YA(audio_index,:)];
    if(strcmp(data_seq.OrderNum{15+i,2}(3),'L'))
        data_one=data_listener_fil.trial{15+i}(chn_sel,t_sel);
    else
        data_one=data_listener_fil.trial{15+i}(chn_sel_r,t_sel);
    end
    data_eeg=[data_eeg data_one];
end
[A_a B_a r_a]=canoncorr(data_audio',data_eeg');
data_audio_a=data_audio;
data_eeg_a=data_eeg;

data_audio=[];data_eeg=[];
for i=1:15
    audio_index=str2num(data_seq.OrderNum{30+i,2}(1:2));
    data_audio=[data_audio YB(audio_index,:)];
    if(strcmp(data_seq.OrderNum{30+i,2}(3),'L'))
        data_one=data_listener_fil.trial{30+i}(chn_sel,t_sel);
    else
        data_one=data_listener_fil.trial{30+i}(chn_sel_r,t_sel);
    end
    data_eeg=[data_eeg data_one];
end
[A_b B_b r_b]=canoncorr(data_audio',data_eeg');
data_audio_b=data_audio;
data_eeg_b=data_eeg;

%%
%pure audio A
for i=1:15
    if(strcmp(data_seq.OrderNum{15+i,2}(3),'L'))
        data_one=data_listener_fil.trial{15+i}(chn_sel,t_sel);
    else
        data_one=data_listener_fil.trial{15+i}(chn_sel_r,t_sel);        
    end
    %filtered by A
    for j=1:15
        r_a(i,j)=corr(data_one'*B_a,YA(j,:)');
        r_b(i,j)=corr(data_one'*B_a,YB(j,:)');
    end
end

%%
%pure audio B
for i=1:15
    if(strcmp(data_seq.OrderNum{30+i,2}(3),'L'))
        data_one=data_listener_fil.trial{30+i}(chn_sel,t_sel);
    else
        data_one=data_listener_fil.trial{30+i}(chn_sel_r,t_sel);        
    end
    %filtered by B
    for j=1:15
        r_a(i,j)=corr(data_one'*B_b,YA(j,:)');
        r_b(i,j)=corr(data_one'*B_b,YB(j,:)');
    end
end

%%
%audio A+B - to-be-re-organized - mapping?
for i=1:15
    if(strcmp(data_seq.OrderNum{i,2}(3),'L'))
        data_one=data_listener_fil.trial{i}(chn_sel,t_sel);
    else
        data_one=data_listener_fil.trial{i}(chn_sel_r,t_sel);        
    end
    %filtered by A/B
    for j=1:15
        r_a_fila(i,j)=corr(data_one'*B_a,YA(j,:)');
        r_b_fila(i,j)=corr(data_one'*B_a,YB(j,:)');
        r_a_filb(i,j)=corr(data_one'*B_b,YA(j,:)');
        r_b_filb(i,j)=corr(data_one'*B_b,YB(j,:)');
    end
end
