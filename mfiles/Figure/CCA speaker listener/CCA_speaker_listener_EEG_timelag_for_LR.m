%% Speaker EEG & listener EEG cca for Speaker_listener study
% Li Jiawei:  jx_ljw@163.com
% 2017.7.26


% adapted : 2018.7.29

% CCA analysis for Speaker-listener Experiment
% using CCA method to figure out the relationship between Speakers' EEG and
% listener's EEG

%% data name
dataName_all = {'101-YJMQ-Listener-ICA-reref-filter_64Hz_new',...
    '102-LTX-Listener-ICA-reref-filter_64Hz_new',...
    '103-RT-Listener-ICA-reref-filter_64Hz_new',...
    '104-ZR-Listener-ICA-reref-filter_64Hz_new',...
    '105-LX-Listener-ICA-reref-filter_64Hz_new',...
    '106-WCW-Listener-ICA-reref-filter_64Hz_new',...
    '107-WY-Listener-ICA-reref-filter_64Hz_new',...
    '108-LGZ-Listener-ICA-reref-filter_64Hz_new',...
    '109-PXJ-Listener-ICA-reref-filter_64Hz_new',...
    '110-LNN-Listener-ICA-reref-filter_64Hz_new',...
    '111-ZXT-Listener-ICA-reref-filter_64Hz_new',...
    '112-LX-Listener-ICA-reref-filter_64Hz_new',...
    '113-SYH-Listener-ICA-reref-filter_64Hz_new',...
    '114-WXZ-Listener-ICA-reref-filter_64Hz_new',...
    '115-LYZ-Listener-ICA-reref-filter_64Hz_new',...
    '116-ZX-Listener-ICA-reref-filter_64Hz_new',...
    '117-HY-Listener-ICA-reref-filter_64Hz_new',...
    '118-WM-Listener-ICA-reref-filter_64Hz_new',...
    '119-ZC-Listener-ICA-reref-filter_64Hz_new',...
    '120-LYB-Listener-ICA-reref-filter_64Hz_new'};



dataFile_all = {'20171118-YJMQ','20171122-LTX','20171122-RT',...
    '20171124-ZR','20171125-LX','20171128-WCW',...
    '20171130-WY','20171202-LGZ','20171205-PXJ','20171206-LNN',...
    '20171209-ZXT','20171209-LX','20171213-SYH',...
    '20171214-WXZ','20171214-LYZ','20171216-ZX',...
    '20171216-HY','20171220-WM','20171221-ZC',...
    '20171221-LYB'};



%% band name
band_name = {'delta'};


%% new order
load('E:\DataProcessing\Label_and_area.mat');

select_area = 'Small_area';
chn_area_labels = fieldnames(eval(select_area));
% area_select_index = 1 : length(chn_area_labels);
area_select_index = 2;

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    %% chn_sel
    for chn_area_select = area_select_index
        disp(chn_area_labels{chn_area_select});
        speaker_chn = eval(strcat(select_area,'.',chn_area_labels{chn_area_select}));
        mkdir(chn_area_labels{chn_area_select});
        cd(chn_area_labels{chn_area_select});
        
        for ii = 1 : 20
            
            %% listener name
            if ii < 10
                file_name = strcat('listener10',num2str(ii));
            else
                file_name = strcat('listener1',num2str(ii));
            end
            
            mkdir(file_name);
            cd(file_name);
            dataName =  dataName_all{ii};
            %     dataName = '102-LTX-Listener-ICA-reref-filter_64Hz';
            
            %% initial
            Fs = 64;
            start_time = 10;
            end_time = 55;
            listener_time_index =  (start_time+5)*Fs+1:(end_time+5)*Fs;
            speaker_time_index =  (start_time+5)*Fs+1:(end_time+5)*Fs;
            
            % % band for analysis
            % theta = 0;
            % broadband = 1;
            
            %% workpath
            p = pwd;
            
            %% CounterBalanceTable
            load(strcat('E:\DataProcessing\speaker-listener_experiment\CountBalanceTable\CountBalanceTable_listener',dataName(1:3),'.mat'));
            
            % speaker story number
            speaker_story_read_order = zeros(1,14);
            speaker_story_retell_order = zeros(1,14);
            
            if strcmp(Type{1},'reading')
                % reading part first
                for i = 1 : 14
                    speaker_story_read_order(i) = str2double(left{i}(5:6));
                end
                
                for i = 15 : 28
                    speaker_story_retell_order(i-14)  = str2double(left{i}(5:6));
                end
            else
                % retell part first
                for i = 1 : 14
                    speaker_story_retell_order(i)  = str2double(left{i}(5:6));
                end
                
                for i = 15 : 28
                    speaker_story_read_order(i-14) = str2double(left{i}(5:6));
                end
            end
            
            %% load speaker data
            
            % data name
            data_speakerA_retell = strcat('data_speakerA_retell_',band_file_name,'_valid');
            data_speakerB_retell = strcat('data_speakerB_retell_',band_file_name,'_valid');
            data_speakerA_read = strcat('data_speakerA_read_',band_file_name,'_valid');
            data_speakerB_read = strcat('data_speakerB_read_',band_file_name,'_valid');
            
            % load data
            load('E:\DataProcessing\speaker-listener_experiment\SpeakerData\Speaker01-CFY-read_retell_valid_strict_new.mat',...
                data_speakerA_retell,data_speakerA_read);
            load('E:\DataProcessing\speaker-listener_experiment\SpeakerData\Speaker02-FS-read_retell_valid_strict_new.mat',...
                data_speakerB_retell,data_speakerB_read);
            
            % data
            data_speakerA_retell = eval(strcat('data_speakerA_retell_',band_file_name,'_valid'));
            data_speakerB_retell = eval(strcat('data_speakerB_retell_',band_file_name,'_valid'));
            data_speakerA_read = eval(strcat('data_speakerA_read_',band_file_name,'_valid'));
            data_speakerB_read = eval(strcat('data_speakerB_read_',band_file_name,'_valid'));
            
            if strcmp(Type{1},'reading')
                % reading part first
                data_EEG_speakerA = [data_speakerA_read(speaker_story_read_order) data_speakerA_retell(speaker_story_retell_order)];
                data_EEG_speakerB = [data_speakerB_read(speaker_story_read_order) data_speakerB_retell(speaker_story_retell_order)];
            else
                % retelling part first
                data_EEG_speakerA = [data_speakerA_retell(speaker_story_retell_order) data_speakerA_read(speaker_story_read_order)];
                data_EEG_speakerB = [data_speakerB_retell(speaker_story_retell_order) data_speakerB_read(speaker_story_read_order)];
                
            end
            
            
            %% load EEG data
            % load('E:\DataProcessing\speaker-listener_experiment\ListenerData\0-LZR-Listener-ICA-filter-reref-64Hz.mat');
            % load('E:\DataProcessing\speaker-listener_experiment\ListenerData\01-CYX-Listener-ICA-filter-reref-64Hz.mat')
            %     load(strcat('E:\DataProcessing\speaker-listener_experiment\ListenerData\',dataName,'.mat'),'data_filtered_theta');
            data_temp = strcat('data_filtered_',band_name{band_select});
            load(strcat('E:\DataProcessing\speaker-listener_experiment\ListenerData\',dataName,'.mat'),data_temp);
            
            % combine
            %     EEGBlock = data_filtered_theta.trial;
            
            EEGBlock = eval(strcat('data_filtered_',band_name{band_select},'.trial'));
            EEGBlock = EEGBlock';
            
            %% Attend Target
            
            attend_target_num = zeros(1,length(EEGBlock));
            for attend_story = 1 : length(EEGBlock)
                if strcmpi(AttendTarget(attend_story),'A')
                    attend_target_num(attend_story) = 1;
                else
                    attend_target_num(attend_story) = 0;
                end
            end
            
            
            %% Channel Index
            % listener_chn= [6:32 34:42 44:59 61:63];
            % speaker_chn = [1:32 34:42 44:59 61:63];
            %         listener_chn= [7:13 16:22 25:31 35:41 45:51];
            %         speaker_chn = [7:13 16:22 25:31 35:41 45:51];
            listener_chn= [1:32 34:42 44:59 61:63];
            
            
            %% timelag
            %     timelag = 0;
            timelag = (-500:1000/Fs:500)/(1000/Fs);
            % timelag = (-250:1000/Fs:500)/(1000/Fs);
            % timelag = (-3000:500/32:3000)/(1000/Fs);
            % timelag = 250/(1000/Fs);
            % timelag = timelag(11:49);
            
            if length(speaker_chn)<5
                
                cca_comp = length(speaker_chn);
            else
                cca_comp = 5;
            end
            
            
            
            %% timelag
            for j = 1: length(timelag)
                
                % %% Combine data
                disp('combining data ...');
                tic;
                eval(strcat('eeg_dual_total=zeros(length(listener_chn),length(listener_time_index));'));
                %     eval(strcat('eeg_B_',dataName,'_total=[];'));
                eval(strcat('Speaker_Attend_total=zeros(length(speaker_chn),length(speaker_time_index));'));
                eval(strcat('Speaker_unAttend_total=zeros(length(speaker_chn),length(speaker_time_index));'));
                
                % Combine data
                cnt = 1;
                for i = 1 : length(EEGBlock)
                    
                    % listener EEG
                    %                 tempDataA = eval(dataName);
                    EEG_all = EEGBlock{i};
                    EEG_all = EEG_all(listener_chn,listener_time_index+timelag(j));
                    %             eval(strcat('eeg_dual_',dataName,'_total(:,cnt:cnt+length(listener_time_index)-1)= EEG_all;'));
                    eeg_dual_total(:,cnt:cnt+length(listener_time_index)-1)= EEG_all;
                    
                    
                    % speaker EEG
                    SpeakerA = data_EEG_speakerA{i}(speaker_chn,speaker_time_index);
                    SpeakerB = data_EEG_speakerB{i}(speaker_chn,speaker_time_index);
                    if  strcmpi('A',AttendTarget{i}) % attend A
                        %                 eval(strcat('audio_Attend_',dataName,'_total=[audio_Attend_',dataName,'_total',' Sound_envelopeA]'));
                        %                 eval(strcat('audio_notAttend_',dataName,'_total=[audio_notAttend_',dataName,'_total',' Sound_envelopeB]'));
                        eval(strcat('Speaker_Attend_total(:,cnt:cnt+length(speaker_time_index)-1) = SpeakerA;'));
                        eval(strcat('Speaker_unAttend_total(:,cnt:cnt+length(speaker_time_index)-1) = SpeakerB;'));
                    else
                        %                 eval(strcat('audio_Attend_',dataName,'_total=[audio_Attend_',dataName,'_total',' Sound_envelopeB]'));
                        %                 eval(strcat('audio_notAttend_',dataName,'_total=[audio_notAttend_',dataName,'_total',' Sound_envelopeA]'));
                        eval(strcat('Speaker_Attend_total(:,cnt:cnt+length(speaker_time_index)-1)=SpeakerB;'));
                        eval(strcat('Speaker_unAttend_total(:,cnt:cnt+length(speaker_time_index)-1)=SpeakerA;'));
                    end
                    cnt = cnt + length(listener_time_index);
                end
                
                
                disp('done');
                toc
                
                
                
                
                %% correlation
                % initial
                train_cca_attend_listener_w_mean = zeros(cca_comp,length(listener_chn),length(EEGBlock));
                train_cca_attend_speaker_w_mean = zeros(cca_comp,length(speaker_chn),length(EEGBlock));
                train_cca_unattend_listener_w_mean = zeros(cca_comp,length(listener_chn),length(EEGBlock));
                train_cca_unattend_speaker_w_mean = zeros(cca_comp,length(speaker_chn),length(EEGBlock));
                
                
                recon_AttendDecoder_speakerA_cca = zeros(cca_comp,length(EEGBlock));
                p_recon_AttendDecoder_speakerA_cca= zeros(cca_comp,length(EEGBlock));
                recon_AttendDecoder_speakerB_cca = zeros(cca_comp,length(EEGBlock));
                p_recon_AttendDecoder_speakerB_cca= zeros(cca_comp,length(EEGBlock));
                
                recon_UnattendDecoder_speakerA_cca = zeros(cca_comp,length(EEGBlock));
                p_recon_UnattendDecoder_speakerA_cca= zeros(cca_comp,length(EEGBlock));
                recon_UnattendDecoder_speakerB_cca = zeros(cca_comp,length(EEGBlock));
                p_recon_UnattendDecoder_speakerB_cca= zeros(cca_comp,length(EEGBlock));
                
                
                recon_AttendDecoder_attend_cca = zeros(cca_comp,length(EEGBlock));
                p_recon_AttendDecoder_attend_cca= zeros(cca_comp,length(EEGBlock));
                recon_AttendDecoder_unattend_cca = zeros(cca_comp,length(EEGBlock));
                p_recon_AttendDecoder_unattend_cca= zeros(cca_comp,length(EEGBlock));
                
                recon_UnattendDecoder_attend_cca = zeros(cca_comp,length(EEGBlock));
                p_recon_UnattendDecoder_attend_cca= zeros(cca_comp,length(EEGBlock));
                recon_UnattendDecoder_unattend_cca = zeros(cca_comp,length(EEGBlock));
                p_recon_UnattendDecoder_unattend_cca= zeros(cca_comp,length(EEGBlock));
                
                train_cca_attend_r_total = zeros(length(speaker_chn),length(EEGBlock));
                train_cca_unattend_r_total = zeros(length(speaker_chn),length(EEGBlock));
                
                for story = 1 : length(EEGBlock)
                    
                    disp(strcat('Training story ',num2str(story),'...'));
                    % predict data -> predict data
                    predict_time_index = length(listener_time_index)*(story-1)+1:length(listener_time_index)*story;
                    %             story_predict_listener_EEG = eval(strcat('Listener',num2str(listener),'{story}'));
                    
                    story_predict_listener_EEG =EEGBlock{i};
                    story_predict_listener_EEG = story_predict_listener_EEG(listener_chn,listener_time_index+timelag(j));
                    
                    story_predict_speaker_A = data_EEG_speakerA{story}(speaker_chn,speaker_time_index);
                    story_predict_speaker_B = data_EEG_speakerB{story}(speaker_chn,speaker_time_index);
                    
                    % train data
                    story_train_listener_EEG = eeg_dual_total;
                    story_train_listener_EEG(:,predict_time_index) = [];
                    
                    %             story_train_speaker_Attend = eval(strcat('Speaker_Attend_Listener',num2str(listener),'_total'));
                    %             story_train_speaker_unAttend = eval(strcat('Speaker_notAttend_Listener',num2str(listener),'_total'));
                    story_train_speaker_Attend = Speaker_Attend_total;
                    story_train_speaker_unAttend = Speaker_unAttend_total;
                    story_train_speaker_Attend(:,predict_time_index) = [];
                    story_train_speaker_unAttend(:,predict_time_index) = [];
                    
                    
                    % cca
                    [train_cca_attend_listener_w,train_cca_attend_speaker_w,train_cca_attend_r] = canoncorr(story_train_listener_EEG',story_train_speaker_Attend');
                    [train_cca_unattend_listener_w,train_cca_unattend_speaker_w,train_cca_unattend_r] = canoncorr(story_train_listener_EEG',story_train_speaker_unAttend');
                    
                    train_cca_attend_r_total(:,story) = train_cca_attend_r;
                    train_cca_unattend_r_total(:,story) = train_cca_unattend_r;
                    
                    
                    
                    
                    for r = 1 : cca_comp
                        % record into one matrix
                        train_cca_attend_listener_w_mean(r,:,story) = train_cca_attend_listener_w(:,r);
                        train_cca_attend_speaker_w_mean(r,:,story) = train_cca_attend_speaker_w(:,r);
                        train_cca_unattend_listener_w_mean(r,:,story) = train_cca_unattend_listener_w(:,r);
                        train_cca_unattend_speaker_w_mean(r,:,story) = train_cca_unattend_speaker_w(:,r);
                        
                        
                        
                        % predict
                        disp(strcat('Predicting story ',num2str(story),'...'));
                        % listener
                        reconstruction_listener_attend = squeeze(train_cca_attend_listener_w_mean(r,:,story)) *  story_predict_listener_EEG;
                        reconstruction_listener_unattend = squeeze(train_cca_unattend_listener_w_mean(r,:,story)) *  story_predict_listener_EEG;
                        
                        % speaker
                        reconstruction_speakerA_attend = squeeze(train_cca_attend_speaker_w_mean(r,:,story)) *  story_predict_speaker_A;
                        reconstruction_speakerB_attend = squeeze(train_cca_attend_speaker_w_mean(r,:,story)) *  story_predict_speaker_B;
                        reconstruction_speakerA_unattend = squeeze(train_cca_unattend_speaker_w_mean(r,:,story)) *  story_predict_speaker_A;
                        reconstruction_speakerB_unattend = squeeze(train_cca_unattend_speaker_w_mean(r,:,story)) *  story_predict_speaker_B;
                        
                        
                        % r for LR
                        [recon_AttendDecoder_speakerA_cca(r,story),p_recon_AttendDecoder_speakerA_cca(r,story)] =...
                            corr(reconstruction_listener_attend',reconstruction_speakerA_attend');
                        [recon_AttendDecoder_speakerB_cca(r,story),p_recon_AttendDecoder_speakerB_cca(r,story)] = ...
                            corr(reconstruction_listener_attend',reconstruction_speakerB_attend');
                        
                        [recon_UnattendDecoder_speakerB_cca(r,story),p_recon_UnattendDecoder_speakerB_cca(r,story)] = ...
                            corr(reconstruction_listener_unattend',reconstruction_speakerB_unattend');
                        
                        [recon_UnattendDecoder_speakerA_cca(r,story),p_recon_UnattendDecoder_speakerA_cca(r,story)] = ...
                            corr(reconstruction_listener_unattend',reconstruction_speakerA_unattend');
                        
                        % r for different types
                        
                        if strcmpi('A',AttendTarget{i})
                            [recon_AttendDecoder_attend_cca(r,story),p_recon_AttendDecoder_attend_cca(r,story)] =...
                                corr(reconstruction_listener_attend',reconstruction_speakerA_attend');
                            [recon_AttendDecoder_unattend_cca(r,story),p_recon_AttendDecoder_unattend_cca(r,story)] = ...
                                corr(reconstruction_listener_attend',reconstruction_speakerB_attend');
                            
                            [recon_UnattendDecoder_unattend_cca(r,story),p_recon_UnattendDecoder_unattend_cca(r,story)] = ...
                                corr(reconstruction_listener_unattend',reconstruction_speakerB_unattend');
                            
                            [recon_UnattendDecoder_attend_cca(r,story),p_recon_UnattendDecoder_attend_cca(r,story)] = ...
                                corr(reconstruction_listener_unattend',reconstruction_speakerA_unattend');
                        else
                            [recon_AttendDecoder_attend_cca(r,story),p_recon_AttendDecoder_attend_cca(r,story)] = ...
                                corr(reconstruction_listener_attend',reconstruction_speakerB_attend');
                            
                            [recon_AttendDecoder_unattend_cca(r,story),p_recon_AttendDecoder_unattend_cca(r,story)] = ...
                                corr(reconstruction_listener_attend',reconstruction_speakerA_attend');
                            
                            [recon_UnattendDecoder_unattend_cca(r,story),p_recon_UnattendDecoder_unattend_cca(r,story)] = ...
                                corr(reconstruction_listener_unattend',reconstruction_speakerA_unattend');
                            
                            [recon_UnattendDecoder_attend_cca(r,story),p_recon_UnattendDecoder_attend_cca(r,story)] = ...
                                corr(reconstruction_listener_unattend',reconstruction_speakerB_unattend');
                        end
                        
                        
                        
                    end
                    
                    
                    
                end
                % save data
                saveName = strcat('cca_S-L_EEG_result+',num2str((1000/Fs)*timelag(j)),'ms.mat');
                save(saveName,'recon_AttendDecoder_attend_cca','recon_UnattendDecoder_unattend_cca' ,'recon_AttendDecoder_unattend_cca','recon_UnattendDecoder_attend_cca',...
                    'p_recon_AttendDecoder_attend_cca','p_recon_UnattendDecoder_unattend_cca', 'p_recon_AttendDecoder_unattend_cca','p_recon_UnattendDecoder_attend_cca',...
                    'recon_AttendDecoder_speakerA_cca','recon_UnattendDecoder_speakerA_cca' ,'recon_AttendDecoder_speakerB_cca','recon_UnattendDecoder_speakerB_cca',...
                    'p_recon_AttendDecoder_speakerA_cca','p_recon_UnattendDecoder_speakerA_cca', 'p_recon_AttendDecoder_speakerB_cca','p_recon_UnattendDecoder_speakerB_cca',...
                    'train_cca_attend_listener_w_mean','train_cca_unattend_listener_w_mean','train_cca_attend_speaker_w_mean','train_cca_unattend_speaker_w_mean',...
                    'train_cca_attend_r_total','train_cca_unattend_r_total',...
                    'attend_target_num');
                
                
                %% plot
                
                %                 for r = 1 : cca_comp
                %
                %                     % r rank initial
                %                     %                     cca_file_name = strcat(' 0.5Hz-40Hz 64Hz central r rank',num2str(r));
                %                     %                     mkdir(cca_file_name(2:end));
                %                     %                     cd(cca_file_name(2:end))
                %
                %                     %plot
                %                     % reconstruction accuracy plot attend
                %                     set(gcf,'outerposition',get(0,'screensize'));
                %                     %                     figure('visible','off');
                %                     subplot(121);plot(recon_AttendDecoder_attend_cca(r,:),'k','lineWidth',2);
                %                     hold on; plot(recon_AttendDecoder_unattend_cca(r,:),'k--','lineWidth',1);
                %                     xlabel('Story No.'); ylabel('r value')
                %                     title('Attend decoder');
                %                     legend('Attend ','unAttend')
                %
                %                     % reconstruction accuracy plot unattend
                %                     subplot(122);
                %                     plot(recon_UnattendDecoder_attend_cca(r,:),'k','lineWidth',2);
                %                     hold on; plot(recon_UnattendDecoder_unattend_cca(r,:),'k--','lineWidth',1);
                %                     xlabel('Story No.'); ylabel('r value')
                %                     title('Unattend decoder');
                %                     legend('Attend ','unAttend')
                %
                %                     saveName2 = strcat('R value timelag',num2str((1000/Fs)*timelag(j)),'ms-',band_file_name,'-r rank',num2str(r),'.jpg');
                %                     suptitle(saveName2(1:end-4));
                %                     saveas(gcf,saveName2);
                %                     close
                
                
                %                     p = pwd;
                %                     cd(strcat(p(1:end-length(cca_file_name))));
                %                 end
                
            end
            p = pwd;
            cd(strcat(p(1:end-(length(file_name)+1))));
        end
        
        p = pwd;
        cd(p(1:end-(length(chn_area_labels{chn_area_select})+1)));
        
    end
    
    
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end