%% read-in .wav files
% dirA='H:\Speaker-listener_experiment\speaker\20170619-CFY';
% dirB='H:\Speaker-listener_experiment\speaker\20170622-FS';
% Fs=44100;
% fs_down=64;
%
%
% % retell
% for i=1:15
%     if(i<10)
%         y_a_retell=audioread([dirA '/S01-0' int2str(i) '_retelling.wav' ]);
%         y_b_retell=audioread([dirB '/S02-0' int2str(i) '_retelling.wav' ]);
%     else
%         y_a_retell=audioread([dirA '/S01-' int2str(i) '_retelling.wav' ]);
%         y_b_retell=audioread([dirB '/S02-' int2str(i) '_retelling.wav' ]);
%     end
%     %take the first 0-30(sound_length) sec and resample to 200Hz power envelop
%
%     sound_length = 65;
%     y_a_retell=smooth(y_a_retell.^2,0.1*Fs);
%     y_b_retell=smooth(y_b_retell.^2,0.1*Fs);
%     y_a_retell=resample(y_a_retell,fs_down,Fs);
%     y_b_retell=resample(y_b_retell,fs_down,Fs);
%     y_a_retell=y_a_retell(fs_down*0+1:fs_down*sound_length);
%     y_b_retell=y_b_retell(fs_down*0+1:fs_down*sound_length);
%     YA_retell(i,:)=y_a_retell;
%     YB_retell(i,:)=y_b_retell;
% end
%
% % read
% for i=1:15
%     if(i<10)
%         y_a_read=audioread([dirA '/S01-0' int2str(i) '_reading.wav' ]);
%         y_b_read=audioread([dirB '/S02-0' int2str(i) '_reading.wav' ]);
%     else
%         y_a_read=audioread([dirA '/S01-' int2str(i) '_reading.wav' ]);
%         y_b_read=audioread([dirB '/S02-' int2str(i) '_reading.wav' ]);
%     end
%     %take the first 0-30(sound_length) sec and resample to 200Hz power envelop
%
%     sound_length = 65;
%     y_a_read=smooth(y_a_read.^2,0.1*Fs);
%     y_b_read=smooth(y_b_read.^2,0.1*Fs);
%     y_a_read=resample(y_a_read,fs_down,Fs);
%     y_b_read=resample(y_b_read,fs_down,Fs);
%     y_a_read=y_a_read(fs_down*0+1:fs_down*sound_length);
%     y_b_read=y_b_read(fs_down*0+1:fs_down*sound_length);
%     YA_read(i,:)=y_a_read;
%     YB_read(i,:)=y_b_read;
% end
%
%
% % change order of stories
% YA_retell(2,:) = YA_retell(15,:);
% YB_retell(2,:) = YB_retell(15,:);


%% load sound data
load('E:\DataProcessing\speaker-listener_experiment\AudioData\from wav\Listener0_Audio_envelope_hilbert_first_64Hz_keep_order.mat');

%% timelag
Fs = 64;
timelag = -100: 200;
timelag = timelag(37:165); % -1000ms -> 1000ms
% timelag = 0;
timelag_realtime = (1000/Fs) * timelag;

%% clip
EEG_clip_sel = 5 * Fs +1: 60 * Fs;
% clip_sel_time_index = clip_sel * Fs;
sound_clip_sel =0 * Fs +1: 55 * Fs;

%% load sound data from EEG
load('E:\DataProcessing\speaker-listener_experiment\AudioData\from EEG\00-LZR-Listener-hilbert-sound_64Hz_lowpass8Hz.mat');

%% attend stream
% attend_stream = 1;
load('CountBalanceTable_listener01.mat');
% AttendTarget = [Retell_AttendTarget;Read_AttendTarget];

%% sound wave and EEG sound wave correlation
chn_number = 1;
corr_audio_EEG = [];
corr_audio_EEG.left = zeros(28,length(timelag));
corr_audio_EEG.right = zeros(28,length(timelag));
% corr_audio_EEG.audioA_read = zeros(4,length(timelag));
% corr_audio_EEG.audioB_read = zeros(4,length(timelag));



for j = 1 : length(timelag)
    %     speakerA retell story 1-3
    for i = 1 : 28
        corr_audio_EEG.left(i,j) = corr(data_filtered_8Hz.trial{i}(1,EEG_clip_sel+timelag(j))',data_left{i}(sound_clip_sel,:));
%         corr_audio_EEG.right(i,j) = corr(data_filtered_8Hz.trial{i}(2,EEG_clip_sel+timelag(j))',data_right{i}(sound_clip_sel,:));
    end
end




%% plot result
%
figure;plot(timelag_realtime,corr_audio_EEG.left);title('Audio left and EEG');xlabel('timelag');ylabel('r value');
saveas(gcf,'Listener0 AudioA left and EEG.jpg');


% figure;plot(timelag_realtime,corr_audio_EEG.right);title('Audio right and EEG');xlabel('timelag');ylabel('r value');
% saveas(gcf,'Listener0 AudioB right and EEG.jpg');



% figure;plot(timelag,corr_audio_EEG.audioA_retell);title('AudioA retell and EEG');xlabel('timelag');ylabel('r value');
%
% figure;plot(timelag,corr_audio_EEG.audioB_retell);title('AudioB retell and EEG');xlabel('timelag');ylabel('r value');
%
% figure;plot(timelag,corr_audio_EEG.audioA_read);title('AudioA read and EEG');xlabel('timelag');ylabel('r value');
%
% figure;plot(timelag,corr_audio_EEG.audioB_read);title('AudioB read and EEG');xlabel('timelag');ylabel('r value');