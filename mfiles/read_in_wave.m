%% read-in .wav files
dirA='G:\Speaker-listener_experiment\speaker\20170619-CFY';
dirB='G:\Speaker-listener_experiment\speaker\20170622-FS';
Fs=44100;
fs_down=64;


% retell
for i=1:15
    if(i<10)
        y_a_retell=audioread([dirA '/S01-0' int2str(i) '_retelling.wav' ]);
        y_b_retell=audioread([dirB '/S02-0' int2str(i) '_retelling.wav' ]);
    else
        y_a_retell=audioread([dirA '/S01-' int2str(i) '_retelling.wav' ]);
        y_b_retell=audioread([dirB '/S02-' int2str(i) '_retelling.wav' ]);
    end
    %take the first 0-30(sound_length) sec and resample to 200Hz power envelop
    
    sound_length = 65;
    y_a_retell=smooth(y_a_retell.^2,0.1*Fs);
    y_b_retell=smooth(y_b_retell.^2,0.1*Fs);
    y_a_retell=resample(y_a_retell,fs_down,Fs);
    y_b_retell=resample(y_b_retell,fs_down,Fs);
    y_a_retell=y_a_retell(fs_down*0+1:fs_down*sound_length);
    y_b_retell=y_b_retell(fs_down*0+1:fs_down*sound_length);
    YA_retell(i,:)=y_a_retell;
    YB_retell(i,:)=y_b_retell;
end

% read
for i=1:15
    if(i<10)
        y_a_read=audioread([dirA '/S01-0' int2str(i) '_reading.wav' ]);
        y_b_read=audioread([dirB '/S02-0' int2str(i) '_reading.wav' ]);
    else
        y_a_read=audioread([dirA '/S01-' int2str(i) '_reading.wav' ]);
        y_b_read=audioread([dirB '/S02-' int2str(i) '_reading.wav' ]);
    end
    %take the first 0-30(sound_length) sec and resample to 200Hz power envelop
    
    sound_length = 65;
    y_a_read=smooth(y_a_read.^2,0.1*Fs);
    y_b_read=smooth(y_b_read.^2,0.1*Fs);
    y_a_read=resample(y_a_read,fs_down,Fs);
    y_b_read=resample(y_b_read,fs_down,Fs);
    y_a_read=y_a_read(fs_down*0+1:fs_down*sound_length);
    y_b_read=y_b_read(fs_down*0+1:fs_down*sound_length);
    YA_read(i,:)=y_a_read;
    YB_read(i,:)=y_b_read;
end


%% plot sound wave

for i = 1 : 15
    figure;plot(YA_retell(i,:));
    title(strcat('SpeakerA Audio',num2str(i)));
    figure;
    plot(YB_retell(i,:));title(strcat('SpeakerB Audio',num2str(i)));
end


%% lowpass
Fs= 64;
lowpass_filter = 8;
AudioA_retell=  ft_preproc_lowpassfilter(YA_retell,Fs,lowpass_filter);
AudioA_read = ft_preproc_lowpassfilter(YA_read,Fs,lowpass_filter);
AudioB_retell=  ft_preproc_lowpassfilter(YB_retell,Fs,lowpass_filter);
AudioB_read = ft_preproc_lowpassfilter(YB_read,Fs,lowpass_filter);

%% plot
for i = 1 : 15
    Fs = 64;
    N = length(AudioA_retell(i,:));
    df=Fs/(N-1);
    f=(0:N-1)*df;
    
    figure;
    plot(f,fftshift(abs(fft(AudioA_retell(i,:)))));
    title(strcat('SpeakerA retell Audio',num2str(i)));
    figure;
    plot(abs(fft(AudioA_read(i,:))));
    title(strcat('SpeakerA read  Audio',num2str(i)));
    
    figure;
    plot(abs(fft(AudioB_retell(i,:))));
    title(strcat('SpeakerB retell Audio',num2str(i)));
    figure;
    plot(abs(fft(AudioB_read(i,:))));
    title(strcat('SpeakerB read  Audio',num2str(i)));
end


%% hilbert
for i = 1 : 15
    AudioA_retell(i,:) = abs(hilbert(AudioA_retell(i,:))); 
    AudioB_retell(i,:) = abs(hilbert(AudioB_retell(i,:)));
    AudioA_read(i,:) = abs(hilbert(AudioA_read(i,:))); 
    AudioB_read(i,:) = abs(hilbert(AudioB_read(i,:)));  
end

%% write into cell

for i = 1 : 15
    AudioA_retell_cell{i} = AudioA_retell(i,:); 
    AudioB_retell_cell{i} = AudioB_retell(i,:);
    AudioA_read_cell{i}= AudioA_read(i,:); 
    AudioB_read_cell{i}= AudioB_read(i,:);  
end