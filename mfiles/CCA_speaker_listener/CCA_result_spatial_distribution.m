%% mTRF - speaker listener timelag plot
% mTRF timelog plot for speaker-listener-new-experiment data
% Experiment date : 2017.7.5
% purpose: mTRF validation
% by:LJW

%% initial
listener_chn= [6:32 34:42 44:59 61:63];
speaker_chn = [1:32 34:42 44:59 61:63];

load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';

Acc_cut = 0.7;

%% timelag

% timelag = -200:25:500;
Fs = 64;
timelag = -250:(1000/Fs):500;

for i = 1 : 20
    
    %% data name
    if i < 10
        file_name = strcat('listener10',num2str(i));
    else
        file_name = strcat('listener1',num2str(i));
    end
    
    mkdir(file_name);
    cd(file_name);
    
    
    %% data type
    data_type = {'read';'retell'};
    
    for jj = 1 : length(data_type)
        data_type_select = data_type{jj};
        mkdir(data_type_select);
        cd(data_type_select);
        
        for r_rank = 1:15
            bandName = strcat(' 0.5Hz-40Hz 64Hz r rank',num2str(r_rank));
            
            %%  CCA speaker listener plot
            % p = pwd;
            p =strcat('E:\DataProcessing\speaker-listener_experiment\Decoding Result\CCA-speaker-listener\',file_name,'\',data_type_select);
            % category = 'mTRF';
            category = bandName(2:end);
            
            for  j = 1 : length(timelag)
                % load data
                %     datapath = strcat(p,'\',category);
                %     dataName = strcat('mTRF_sound_EEG_result+',num2str(timelag(j)),'ms.mat');
                %     datapath = strcat(p,'\',category,'\-200ms_500ms_64Hz');
                datapath = strcat(p,'\',category);
                %     dataName = strcat('mTRF_sound_EEG_result+',num2str((1000/Fs)*timelag(j)),'ms.mat');
                %     dataName = strcat('mTRF_sound_EEG_result+',num2str((1000/Fs)*timelag(j)),'ms',bandName,'.mat');
                dataName = strcat('cca_S-L_EEG_result+',num2str(timelag(j)),'ms',bandName,'.mat');
                %     band_name = strcat(' broadband 0.1-40Hz lambda',num2str(lambda(j)));
                %     dataName = strcat('mTRF_sound_EEG_result -200~500 ms',band_name,'.mat');
                load(strcat(datapath,'\',dataName));
                
                % decoding accuracy
                % attend decoder
                Decoding_result_attend_decoder = recon_AttendDecoder_attend_cca-recon_AttendDecoder_unattend_cca;
                Individual_subjects_result_attend = mean(sum(Decoding_result_attend_decoder>0)/length(Decoding_result_attend_decoder));
                if Individual_subjects_result_attend > Acc_cut
                    figure;
                    subplot(121);
                    U_topoplot(zscore(mean(train_cca_attend_listener_w_mean,2)),layout,label66(listener_chn));%plot(w_A(:,1));
                    title('Listener');
                    subplot(122);
                    U_topoplot(zscore(mean(train_cca_attend_speaker_w_mean,2)),layout,label66(speaker_chn));%plot(v_B(:,1));
                    title('Speaker');
                    save_name = strcat(file_name,'-',data_type_select,'-Topoplot for attend decoder r rank',num2str(r_rank),'-timelag',num2str(timelag(j)),'ms.jpg');
                    suptitle(save_name(1:end-4));
                    saveas(gcf,save_name)
                    close;
                end
                
                % unattend decoder
                Decoding_result_unattend_decoder = recon_UnattendDecoder_unattend_cca-recon_UnattendDecoder_attend_cca;
                Individual_subjects_result_unattend = mean(sum(Decoding_result_unattend_decoder>0)/length(Decoding_result_unattend_decoder));
                if Individual_subjects_result_unattend > Acc_cut
                    figure;
                    subplot(121);
                    U_topoplot(zscore(mean(train_cca_unattend_listener_w_mean,2)),layout,label66(listener_chn));%plot(w_A(:,1));
                    title('Listener');
                    subplot(122);
                    U_topoplot(zscore(mean(train_cca_unattend_speaker_w_mean,2)),layout,label66(speaker_chn));%plot(v_B(:,1));
                    title('Speaker');
                    save_name = strcat(file_name,'-',data_type_select,'-Topoplot for unattend decoder r rank',num2str(r_rank),'-timelag',num2str(timelag(j)),'ms.jpg');
                    suptitle(save_name(1:end-4));
                    saveas(gcf,save_name)
                    close;
                end
                
            end
            
            
            
        end
        p = pwd;
        cd(p(1:end-(length(data_type_select)+1)));
        
    end
    p = pwd;
    cd(p(1:end-(length(file_name)+1)));
end
