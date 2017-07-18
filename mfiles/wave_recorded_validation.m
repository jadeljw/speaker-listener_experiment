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
load('E:\DataProcessing\speaker-listener_experiment\AudioData\Audio_envelope_64Hz_hilbert_cell.mat');

% retelling story 2 is original story 15
AudioA_retell_cell{2} = AudioA_retell_cell{15};
AudioB_retell_cell{2} = AudioB_retell_cell{15};

%% timelag
Fs = 64;
timelag = -100: 200;
timelag = timelag(37:165); % -1000ms -> 1000ms
% timelag = 0;
timelag_realtime = (1000/Fs) * timelag;

%% clip
EEG_clip_sel = 5 * Fs +1: 55 * Fs;
% clip_sel_time_index = clip_sel * Fs;
sound_clip_sel =0 * Fs +1: 50 * Fs;

%% load sound data from EEG
load('E:\DataProcessing\speaker-listener_experiment\AudioData\0-LZR-Listener-raw-sound_64Hz_lowpass8Hz_type_baseline.mat')
% load('E:\DataProcessing\speaker-listener_experiment\AudioData\0-LZR-Listener-raw-sound_64Hz_lowpass8Hz_type.mat')
% correct labels
data_retell{13}=data_retell{11};
data_retell{14}=data_retell{12};
data_retell{11}=data_read{15};
data_retell{12}=data_read{16};
%% attend stream
% attend_stream = 1;
load('CountBalanceTable.mat');
% AttendTarget = [Retell_AttendTarget;Read_AttendTarget];

%% sound wave and EEG sound wave correlation
chn_number = 1;
corr_audio_EEG = [];
corr_audio_EEG.audioA_retell = zeros(3,length(timelag));
corr_audio_EEG.audioB_retell = zeros(3,length(timelag));
corr_audio_EEG.audioA_read = zeros(4,length(timelag));
corr_audio_EEG.audioB_read = zeros(4,length(timelag));



for j = 1 : length(timelag)
    %     speakerA retell story 1-3
    for i = 1 : 3
        
        corr_audio_EEG.audioA_retell(i,j) = corr(data_retell{i}(chn_number,EEG_clip_sel+timelag(j))',AudioA_retell_cell{i}(1,sound_clip_sel)');
%         figure;plot(zscore(data_retell{i}(chn_number,EEG_clip_sel+timelag(j))));hold on; plot(zscore(AudioA_retell_cell{i}(1,sound_clip_sel)));
%         title(strcat('SpeakerA retell story',num2str(i)));
%         legend('EEG','wav file');
%         saveas(gcf,strcat('SpeakerA retell story',num2str(i),'.jpg'));
%         close

    end
    
    for i = 1 : 4
        %     for i = 4
        corr_audio_EEG.audioA_read(i,j) = corr(data_read{i}(chn_number,EEG_clip_sel+timelag(j))',AudioA_read_cell{i}(1,sound_clip_sel)');
%         figure;plot(zscore(data_read{i}(chn_number,EEG_clip_sel+timelag(j))));hold on; plot(zscore(AudioA_read_cell{i}(1,sound_clip_sel)));
%         
%         title(strcat('SpeakerA read story',num2str(i)));
%         legend('EEG','wav file');
%         saveas(gcf,strcat('SpeakerA read story',num2str(i),'.jpg'));
%          close

    end
    
    
    for i = 4 : 6
        corr_audio_EEG.audioB_retell(i-3,j) = corr(data_retell{i}(chn_number,EEG_clip_sel+timelag(j))',AudioB_retell_cell{i}(1,sound_clip_sel)');
%         figure;plot(zscore(data_retell{i}(chn_number,EEG_clip_sel+timelag(j))));hold on; plot(zscore(AudioB_retell_cell{i}(1,sound_clip_sel)));
%         title(strcat('SpeakerB retell story',num2str(i)));
%         legend('EEG','wav file');
%         saveas(gcf,strcat('SpeakerB retell story',num2str(i),'.jpg'));
%         close

    end
    
    for i = 5 : 8
        corr_audio_EEG.audioB_read(i-4,j) = corr(data_read{i}(chn_number,EEG_clip_sel+timelag(j))',AudioB_read_cell{i}(1,sound_clip_sel)');
%         figure;plot(zscore(data_read{i}(chn_number,EEG_clip_sel+timelag(j))));hold on; plot(zscore(AudioB_read_cell{i}(1,sound_clip_sel)));
%         title(strcat('SpeakerB read story',num2str(i)));
%         legend('EEG','wav file');
%         saveas(gcf,strcat('SpeakerB read story',num2str(i),'.jpg'));
%         close

    end
end




%% plot result
%
figure;plot(timelag_realtime,corr_audio_EEG.audioA_retell);title('AudioA retell and EEG');xlabel('timelag');ylabel('r value');
saveas(gcf,'AudioA retell and EEG.jpg');
close

figure;plot(timelag_realtime,corr_audio_EEG.audioB_retell);title('AudioB retell and EEG');xlabel('timelag');ylabel('r value');
saveas(gcf,'AudioB retell and EEG.jpg');
close

figure;plot(timelag_realtime,corr_audio_EEG.audioA_read);title('AudioA read and EEG');xlabel('timelag');ylabel('r value');
saveas(gcf,'AudioA read and EEG.jpg');
close

figure;plot(timelag_realtime,corr_audio_EEG.audioB_read);title('AudioB read and EEG');xlabel('timelag');ylabel('r value');
saveas(gcf,'AudioB read and EEG.jpg');
close

% figure;plot(timelag,corr_audio_EEG.audioA_retell);title('AudioA retell and EEG');xlabel('timelag');ylabel('r value');
%
% figure;plot(timelag,corr_audio_EEG.audioB_retell);title('AudioB retell and EEG');xlabel('timelag');ylabel('r value');
%
% figure;plot(timelag,corr_audio_EEG.audioA_read);title('AudioA read and EEG');xlabel('timelag');ylabel('r value');
%
% figure;plot(timelag,corr_audio_EEG.audioB_read);title('AudioB read and EEG');xlabel('timelag');ylabel('r value');