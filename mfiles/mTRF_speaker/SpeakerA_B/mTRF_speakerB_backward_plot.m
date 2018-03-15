% mTRF_spekaerB_plot_backward

band_name = {'delta','theta','alpha','beta'};


for band_select = 1 : length(band_name)
    
    %% load plot data
    data_name = strcat('mTRF_sound_SpeakerB_EEG_backward_result_timelag-150ms_',band_name{band_select},'.mat');
    data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Backward model\SpeakerB\',band_name{band_select});
    load(strcat(data_path,'\',data_name));

    %% plot
    set(gcf,'outerposition',get(0,'screensize'));
    subplot(131);plot(mean(R),'LineWidth',2);title('R value');xlabel('lambda 2^');ylabel('r');
    subplot(132);plot(mean(MSE),'LineWidth',2);title('MSE');xlabel('lambda 2^');ylabel('MSE');
    subplot(133);plot(mean(P),'LineWidth',2);title('P value');xlabel('lambda 2^');ylabel('P');
    
    save_name = strcat('mTRF-sound-SpeakerB-EEG-backward-result-',band_name{band_select},'.jpg');
    suptitle(save_name(1:end-4));
    saveas(gcf,save_name);
    
    close;
    
end