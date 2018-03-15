%% SpeakerB mTRF forward model
% purpose: to test whether the speaker also has TRF response
% use backward model to reconstruct the audio envelope

% LJW
% 2018.1.21
% on the flight from Hainan to Beijing


%% band name
% band_name = {'delta','theta','alpha','beta'};
band_name = {'delta'};

mkdir('SpeakerB');
cd('SpeakerB');


data_path = 'E:\DataProcessing\speaker-listener_experiment\Forward model\SpeakerB';

for band_select = 1 : length(band_name)
    disp(band_name{band_select});
    mkdir(band_name{band_select});
    cd(band_name{band_select});
    
    %% band name
    lambda = 2.^(-10:20);
    %     band_name = strcat(' 64Hz 2-8Hz sound from wav SpeakerB lambda',num2str(lambda),' 10-55s');
    bandName = strcat(' 64Hz',band_name{band_select},' sound from wav SpeakerB lambda',num2str(lambda),' 10-55s');
    
    %% timelag
    Fs = 64;
%     timelag = [-300 -200 -100 0 100 200 300 400];
    timelag = 100;
    
    %% chn_sel
    chn_sel_index = [1:32 34:42 44:59 61:63];
    
    
    %% lambda index 
    lambda_index = -10:20;
    timelag_each = 0:150/12:150;
%     timelag_each = timelag_each(2:end);
    
    %% plot initial
    load('E:\DataProcessing\label66.mat');
    layout = 'E:\DataProcessing\easycapm1.mat';
    
    
    for j = 1 : length(timelag)
        disp(strcat('timelag',num2str(timelag(j)),'ms'));
        mkdir(strcat('timelag',num2str(timelag(j)),'ms'));
        cd(strcat('timelag',num2str(timelag(j)),'ms'));
        
        %% load speaker data
        data_band_path = strcat(data_path,'\',band_name{band_select});
        data_name =  strcat('mTRF_sound_SpeakerB_EEG_forward_result_timelag',num2str(timelag(j)-150),'ms_',band_name{band_select},'.mat');
        load(strcat(data_band_path,'\',data_name));
        
        for chn = 1 : length(chn_sel_index)
            %% plot
            set(gcf,'outerposition',get(0,'screensize'));
            % R
            subplot(221);
            R_for_plot = squeeze(mean(R));
            plot(lambda_index,R_for_plot(:,chn),'LineWidth',2);
            title('R value');xlabel('lambda 2^');ylabel('r');
            
            % MSE
            subplot(222);
            MSE_for_plot = squeeze(mean(MSE));
            plot(lambda_index,MSE_for_plot(:,chn),'LineWidth',2);
            title('MSE');xlabel('lambda 2^');ylabel('MSE');
            
            % P
            subplot(223);
            P_for_plot = squeeze(mean(P));
            plot(lambda_index,P_for_plot(:,chn),'LineWidth',2);
            title('P value');xlabel('lambda 2^');ylabel('P');
            
            % model
            subplot(224);
            model_for_plot = squeeze(mean(model));
            plot(timelag_each+timelag(j)-150,model_for_plot(:,:,chn)');
            title('TRF');xlabel('timelag(ms)');ylabel('a.u.');
            
            
            save_name = strcat('mTRF sound SpeakerB EEG forward result timelag',num2str(timelag(j)-150),'ms-',band_name{band_select},'-',label66{chn_sel_index(chn)},'.jpg');
            suptitle(save_name(1:end-4));
            saveas(gcf,save_name);
            
            close;
            
        end
        
        p = pwd;
        cd(p(1:end-(length(strcat('timelag',num2str(timelag(j)),'ms')+1))));
       
    end
    
    p = pwd;
    cd(p(1:end-(length(band_name{band_select})+1)));
end