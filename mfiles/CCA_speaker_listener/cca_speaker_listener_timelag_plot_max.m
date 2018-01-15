%% mTRF - speaker listener timelag plot
% mTRF timelog plot for speaker-listener-new-experiment data
% Experiment date : 2017.7.5
% purpose: mTRF validation
% by:LJW


%% timelag

% timelag = -200:25:500;
Fs = 64;
timelag = -250:(1000/Fs):500;
cca_comp = 15;

% timelag = (-3000:500/32:3000)/(1000/Fs);
% timelag = (-250:500/32:500)/(1000/Fs);
% timelag= timelag(33:40);
% timelag = (0:500/32:500)/(1000/Fs);

decoding_acc_attended = zeros(1,length(timelag));
decoding_acc_unattended = zeros(1,length(timelag));

%% initial topoplot
listener_chn= [6:32 34:42 44:59 61:63];
speaker_chn = [1:32 34:42 44:59 61:63];

load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';


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
        
        r_rank_max_attend_acc_topoplot_speaker = cell(1,length(timelag));
        r_rank_max_attend_acc_topoplot_listener = cell(1,length(timelag));
        r_rank_max_unattend_acc_topoplot_speaker = cell(1,length(timelag));
        r_rank_max_unattend_acc_topoplot_listener = cell(1,length(timelag));
        
        for  j = 1 : length(timelag)
            
            r_rank_max_attend_acc = 0;
            r_rank_max_unattend_acc = 0;
            
            for r_rank = 1 : cca_comp
                bandName = strcat(' 0.5Hz-40Hz 64Hz r rank',num2str(r_rank));
                
                %%  CCA speaker listener plot
                % p = pwd;
                p =strcat('E:\DataProcessing\speaker-listener_experiment\Decoding Result\CCA-speaker-listener\',file_name,'\',data_type_select);
                % category = 'mTRF';
                category = bandName(2:end);
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
                
                
                %
                
                %decoding accuracy
                Decoding_result_attend_decoder = recon_AttendDecoder_attend_cca-recon_AttendDecoder_unattend_cca;
                Individual_subjects_result_attend = mean(sum(Decoding_result_attend_decoder>0)/length(Decoding_result_attend_decoder));
                % ttest
                %     Decoding_acc_attend_ttest_result(j) = ttest(Individual_subjects_result_attend,0.5);
                r_rank_attend_acc_temp= Individual_subjects_result_attend;
                
                Decoding_result_unattend_decoder = recon_UnattendDecoder_unattend_cca-recon_UnattendDecoder_attend_cca;
                Individual_subjects_result_unattend = mean(sum(Decoding_result_unattend_decoder>0)/length(Decoding_result_unattend_decoder));
                % ttest
                %     Decoding_acc_unattend_ttest_result(j) = ttest(Individual_subjects_result_unattend,0.5);
                r_rank_unattend_acc_temp = Individual_subjects_result_unattend;
                
                % leave the the highest acc
                if  r_rank_attend_acc_temp > r_rank_max_attend_acc
                    r_rank_max_attend_acc = r_rank_attend_acc_temp;
                    r_rank_max_attend_acc_topoplot_listener{j} = mean(train_cca_attend_listener_w_mean,2);
                    r_rank_max_attend_acc_topoplot_speaker{j} = mean(train_cca_attend_speaker_w_mean,2);
                end
                
                if  r_rank_unattend_acc_temp > r_rank_max_unattend_acc
                    r_rank_max_unattend_acc = r_rank_unattend_acc_temp;
                    r_rank_max_unattend_acc_topoplot_listener{j} = mean(train_cca_unattend_listener_w_mean,2);
                    r_rank_max_unattend_acc_topoplot_speaker{j} = mean(train_cca_unattend_speaker_w_mean,2);
                end
                
            end
            
            %decoding accuracy
            decoding_acc_attended(j)= r_rank_max_attend_acc;
            decoding_acc_unattended(j) = r_rank_max_unattend_acc;
            
            figure;
            subplot(121);
            U_topoplot(abs(zscore(r_rank_max_attend_acc_topoplot_listener{j})),layout,label66(listener_chn));%plot(w_A(:,1));
            title('Listener');
            subplot(122);
            U_topoplot(abs(zscore(r_rank_max_attend_acc_topoplot_speaker{j})),layout,label66(speaker_chn));%plot(v_B(:,1));
            title('Speaker');
            save_name = strcat(file_name,'-',data_type_select,'-Topoplot for attend decoder-highest acc in timelag',num2str(timelag(j)),'ms.jpg');
            suptitle(save_name(1:end-4));
            saveas(gcf,save_name)
            close;
            
            figure;
            subplot(121);
            U_topoplot(abs(zscore(r_rank_max_unattend_acc_topoplot_listener{j})),layout,label66(listener_chn));%plot(w_A(:,1));
            title('Listener');
            subplot(122);
            U_topoplot(abs(zscore(r_rank_max_unattend_acc_topoplot_speaker{j})),layout,label66(speaker_chn));%plot(v_B(:,1));
            title('Speaker');
            save_name = strcat(file_name,'-',data_type_select,'-Topoplot for unattend decoder-highest acc in timelag',num2str(timelag(j)),'ms.jpg');
            suptitle(save_name(1:end-4));
            saveas(gcf,save_name)
            close;
        end
        
        figure;
        plot(timelag,decoding_acc_attended*100,'r');
        % hold on;plot(timelag(Decoding_acc_attend_ttest_result>0),decoding_acc_attended(Decoding_acc_attend_ttest_result>0)*100,'r*');
        hold on; plot(timelag,decoding_acc_unattended*100,'b');
        % hold on;plot(timelag(Decoding_acc_unattend_ttest_result>0),decoding_acc_unattended(Decoding_acc_unattend_ttest_result>0)*100,'b*');
        xlabel('Times(ms)');
        ylabel('Decoding accuracy(%)')
        saveName3 =strcat('Max Acc-r rank acrcoss time-lags using CCA S-L method-',file_name,'.jpg');
        % saveName3 =strcat('Decoding-Accuracy across all time-lags using mTRF method',band_name,'.jpg');
        title(saveName3(1:end-4));
        % legend('Attended decoder','significant ¡Ù 50%','Unattended decoder','significant ¡Ù 50%','Location','northeast');ylim([30,100]);
        legend('Attended decoder','Unattended decoder','Location','northeast');ylim([30,100]);
        saveas(gcf,saveName3);
        close
        
        saveName =strcat('Max Acc-r rank across time-lags using CCA S-L method-',file_name,'.mat');
        save(saveName,'decoding_acc_attended', 'decoding_acc_unattended','r_rank_max_attend_acc_topoplot_listener','r_rank_max_unattend_acc_topoplot_listener',...
            'r_rank_max_attend_acc_topoplot_speaker','r_rank_max_unattend_acc_topoplot_speaker');
        
        p = pwd;
        cd(p(1:end-(length(data_type_select)+1)));
        
    end
    p = pwd;
    cd(p(1:end-(length(file_name)+1)));
end
