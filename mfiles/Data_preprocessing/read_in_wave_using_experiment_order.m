%% read-in .wav files
% dirA='H:\Speaker-listener_experiment\speaker\20170619-CFY';
% dirB='H:\Speaker-listener_experiment\speaker\20170622-FS';
dir = 'H:\Speaker-listener_experiment\listener\program\audio';
Fs=44100;
fs_down=64;

%% CountBalance
load('CountBalanceTable_listener01.mat')

%% workpath
p = pwd;

%% load wav
% retell
data_left = cell(1,28);
data_right = cell(1,28);

for i= 1 : 28
    cd(dir);
    [data_left{i},~] = audioread([char(left(i)) '.wav']);
%     [Y2,~,~] = wavread([char(right(i)) '.wav']);
    [data_right{i},~] = audioread([char(right(i)) '.wav']);
    cd(p);
end

%% hilbert
for i= 1 : 28
   
    data_left{i} = abs(hilbert(data_left{i}));
    data_right{i} = abs(hilbert(data_right{i}));
end


%% sample down
% oldFs = 200;
for i= 1 : 28
   
    data_left{i} = resample(data_left{i},fs_down,Fs);
    data_right{i} = resample(data_right{i},fs_down,Fs);
end




%% lowpass
fs_down= 64;
lowpass_filter = 8;
% AudioA_retell=  ft_preproc_lowpassfilter(YA_retell,Fs,lowpass_filter);
% AudioA_read = ft_preproc_lowpassfilter(YA_read,Fs,lowpass_filter);
% AudioB_retell=  ft_preproc_lowpassfilter(YB_retell,Fs,lowpass_filter);
% AudioB_read = ft_preproc_lowpassfilter(YB_read,Fs,lowpass_filter);
for i= 1 : 28
   
    data_left{i} = ft_preproc_lowpassfilter(data_left{i},fs_down,lowpass_filter);
    data_right{i} = ft_preproc_lowpassfilter(data_right{i},fs_down,lowpass_filter);
end



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


%% write into cell

for i = 1 : 15
    AudioA_retell_cell{i} = AudioA_retell(i,:); 
    AudioB_retell_cell{i} = AudioB_retell(i,:);
    AudioA_read_cell{i}= AudioA_read(i,:); 
    AudioB_read_cell{i}= AudioB_read(i,:);  
end