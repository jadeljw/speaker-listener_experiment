%% SpeakerB mTRF forward model
% purpose: to test whether the speaker also has TRF response
% use backward model to reconstruct the audio envelope

% LJW
% 2018.1.21
% on the flight from Hainan to Beijing


%% band name
band_name = {'delta','theta','alpha','beta'};
% band_name = {'delta'};

mkdir('SpeakerB');
cd('SpeakerB');


data_path = 'E:\DataProcessing\speaker-listener_experiment\Forward model\Audio-speakerEEG\SpeakerB';

for band_select = 1 : length(band_name)
    disp(band_name{band_select});
    %     mkdir(band_name{band_select});
    %     cd(band_name{band_select});
    %
    %% band name
    lambda = 2.^10;
    %     band_name = strcat(' 64Hz 2-8Hz sound from wav SpeakerB lambda',num2str(lambda),' 10-55s');
    bandName = strcat(' 64Hz',band_name{band_select},' sound from wav SpeakerB lambda',num2str(lambda),' 10-55s');
    
    %% timelag
    Fs = 64;
    %     timelag = [-300 -200 -100 0 100 200 300 400];
    %     timelag = 100;
    timelag_plot = -250 : 1000/64 : 500;
    
    %% chn_sel
    chn_sel_index = [1:32 34:42 44:59 61:63];
    
    %% lambda index
    lambda_index = -10:20;
    timelag_each = 0:150/12:150;
    
    %% plot initial
    load('E:\DataProcessing\label66.mat');
    layout = 'E:\DataProcessing\easycapm1.mat';
    
    
    
    %% load speaker data
    %     data_band_path = strcat(data_path,'\',band_name{band_select});
    data_band_path = data_path;
    data_name =  strcat('mTRF_sound_SpeakerB_EEG_forward_result_',band_name{band_select},'-lambda1024.mat');
    load(strcat(data_band_path,'\',data_name));
    
    
    %% plot
    set(gcf,'outerposition',get(0,'screensize'));
    
    imagesc(squeeze(mean(model))');colorbar;caxis([-0.02, 0.02]);colormap('jet');
    title('TRF');ylabel('channel');xlabel('timelag(ms)');
    %             ylim([-0.03 0.03]);
    xticklabels(round(timelag_plot(5:5:end)));
    
    
    save_name = strcat('mTRF sound SpeakerB EEG forward result-',band_name{band_select},'.jpg');
    suptitle(save_name(1:end-4));
    saveas(gcf,save_name);
    
    close;
    
end