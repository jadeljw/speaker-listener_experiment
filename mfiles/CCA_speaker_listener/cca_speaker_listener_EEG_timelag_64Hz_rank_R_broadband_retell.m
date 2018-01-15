%% Speaker EEG & listener EEG cca for Speaker_listener study
% Li Jiawei:  jx_ljw@163.com
% 2017.7.26

% CCA analysis for Speaker-listener Experiment
% using CCA method to figure out the relationship between Speakers' EEG and
% listener's EEG

%% data name
dataName = '101-YJMQ-Listener-ICA-reref-filter_64Hz';

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
% speaker_story_read_order = zeros(1,14);
speaker_story_retell_order = zeros(1,14);

if strcmp(Type{1},'reading')
    % reading part first
    %     for i = 1 : 14
    %         speaker_story_read_order(i) = str2double(left{i}(5:6));
    %     end
    
    for i = 15 : 28
        speaker_story_retell_order(i-14)  = str2double(left{i}(5:6));
    end
else
    %     retell part first
    for i = 1 : 14
        speaker_story_retell_order(i) = str2double(left{i}(5:6));
    end
    
    %     for i = 15 : 28
    %         speaker_story_read_order(i-14) = str2double(left{i}(5:6));
    %     end
end

%% load speaker data
load('E:\DataProcessing\speaker-listener_experiment\SpeakerData\Speaker01-CFY-read_retell_valid.mat',...
    'data_speakerA_retell_boradband_valid');
load('E:\DataProcessing\speaker-listener_experiment\SpeakerData\Speaker02-FS-read_retell_valid.mat',...
    'data_speakerB_retell_boradband_valid');

data_EEG_speakerA = data_speakerA_retell_boradband_valid(speaker_story_retell_order);
data_EEG_speakerB = data_speakerB_retell_boradband_valid(speaker_story_retell_order);




%% load listener data
load(strcat('E:\DataProcessing\speaker-listener_experiment\ListenerData\',dataName,'.mat'),'data_filtered_boradband');

if strcmp(Type{1},'reading')
    data_EEG_listener = data_filtered_boradband.trial(15:28);
else
    data_EEG_listener = data_filtered_boradband.trial(1:14);
end

%% Channel Index
listener_chn= [6:32 34:42 44:59 61:63];
speaker_chn = [1:32 34:42 44:59 61:63];

cca_comp = 15;



%% timelag
% timelag = 0;
timelag = (-250:500/32:500)/(1000/Fs);
% timelag = (-250:1000/Fs:500)/(1000/Fs);
% timelag = (-3000:500/32:3000)/(1000/Fs);
% timelag = 250/(1000/Fs);
% timelag = timelag(11:49);

%% new file
mkdir(strcat('listener',dataName(1:3)));
cd(strcat('listener',dataName(1:3)));
mkdir('retell');
cd('retell');

%% initial accuracy mat
Acc_attend= zeros(cca_comp,length(timelag));
Acc_unattend = zeros(cca_comp,length(timelag));

for r = 1 : cca_comp
    %% band name
    band_name = strcat(' 0.5Hz-40Hz 64Hz r rank',num2str(r));
    
    
    mkdir(band_name(2:end));
    cd(band_name(2:end))
    
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
        for i = 1 : length(data_EEG_listener)
            
            % listener EEG
            %                 tempDataA = eval(dataName);
            EEG_all = data_EEG_listener{i};
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
        recon_AttendDecoder_attend_cca = zeros(1,length(data_EEG_listener));
        recon_UnattendDecoder_unattend_cca = zeros(1,length(data_EEG_listener));
        recon_AttendDecoder_unattend_cca = zeros(1,length(data_EEG_listener));
        recon_UnattendDecoder_attend_cca = zeros(1,length(data_EEG_listener));
        
        p_recon_AttendDecoder_attend_cca = zeros(1,length(data_EEG_listener));
        p_recon_UnattendDecoder_unattend_cca = zeros(1,length(data_EEG_listener));
        p_recon_AttendDecoder_unattend_cca = zeros(1,length(data_EEG_listener));
        p_recon_UnattendDecoder_attend_cca = zeros(1,length(data_EEG_listener));
        
        
        % train matrix
        recon_AttendDecoder_attend_cca_train = zeros(length(data_EEG_listener)-1,length(data_EEG_listener)); % training story numbers,  story
        recon_UnattendDecoder_unattend_cca_train = zeros(length(data_EEG_listener)-1,length(data_EEG_listener));
        recon_AttendDecoder_unattend_cca_train = zeros(length(data_EEG_listener)-1,length(data_EEG_listener));
        recon_UnattendDecoder_attend_cca_train = zeros(length(data_EEG_listener)-1,length(data_EEG_listener));
        
        p_recon_AttendDecoder_attend_cca_train = zeros(length(data_EEG_listener)-1,length(data_EEG_listener));
        p_recon_UnattendDecoder_unattend_cca_train = zeros(length(data_EEG_listener)-1,length(data_EEG_listener));
        p_recon_AttendDecoder_unattend_cca_train = zeros(length(data_EEG_listener)-1,length(data_EEG_listener));
        p_recon_UnattendDecoder_attend_cca_train = zeros(length(data_EEG_listener)-1,length(data_EEG_listener));
        
        % weights matrix
        %         train_cca_attend_listener_w_total = cell(1,length(data_EEG_listener));
        %         train_cca_attend_speaker_w_total = cell(1,length(data_EEG_listener));
        %         train_cca_unattend_listener_w_total = cell(1,length(data_EEG_listener));
        %         train_cca_unattend_speaker_w_total = cell(1,length(data_EEG_listener));
        %
        
        
        train_cca_attend_listener_w_mean = zeros(length(listener_chn),length(data_EEG_listener));
        train_cca_attend_speaker_w_mean = zeros(length(speaker_chn),length(data_EEG_listener));
        train_cca_attend_r = zeros(length(speaker_chn),length(data_EEG_listener));
        
        train_cca_unattend_listener_w_mean = zeros(length(listener_chn),length(data_EEG_listener));
        train_cca_unattend_speaker_w_mean = zeros(length(speaker_chn),length(data_EEG_listener));
        train_cca_unattend_r = zeros(length(speaker_chn),length(data_EEG_listener));
        
        for story = 1 : length(data_EEG_listener)
            
            disp(strcat('Training story ',num2str(story),'...'));
            % predict data -> predict data
            predict_time_index = length(listener_time_index)*(story-1)+1:length(listener_time_index)*story;
            %             story_predict_listener_EEG = eval(strcat('Listener',num2str(listener),'{story}'));
            
            story_predict_listener_EEG =data_EEG_listener{i};
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
            
            % record into one matrix
            train_cca_attend_listener_w_mean(:,story) = train_cca_attend_listener_w(:,r);
            train_cca_attend_speaker_w_mean(:,story) = train_cca_attend_speaker_w(:,r);
            train_cca_attend_r(:,story) = train_cca_attend_r(r);
            train_cca_unattend_listener_w_mean(:,story) = train_cca_unattend_listener_w(:,r);
            train_cca_unattend_speaker_w_mean(:,story) = train_cca_unattend_speaker_w(:,r);
            train_cca_unattend_r(:,story) = train_cca_unattend_r(r);
            
            % apply weights to each story as training sample
            cnt_train_story = 1;
            for train_story = 1 : length(data_EEG_listener)
                
                
                if train_story ~= story
                    story_train_EEG = data_EEG_listener{train_story};
                    story_train_EEG = story_train_EEG(listener_chn,listener_time_index+timelag(j));
                    story_train_speaker_A = data_EEG_speakerA{train_story}(speaker_chn,speaker_time_index);
                    story_train_speaker_B = data_EEG_speakerB{train_story}(speaker_chn,speaker_time_index);
                    
                    
                    % apply weights to individual story
                    % speaker
                    reconstruction_speakerA_attend_train = train_cca_attend_speaker_w_mean(:,story)' *  story_train_speaker_A;
                    reconstruction_speakerB_attend_train = train_cca_attend_speaker_w_mean(:,story)' *  story_train_speaker_B;
                    reconstruction_speakerA_unattend_train = train_cca_unattend_speaker_w_mean(:,story)' *  story_train_speaker_A;
                    reconstruction_speakerB_unattend_train = train_cca_unattend_speaker_w_mean(:,story)' *  story_train_speaker_B;
                    
                    % listener
                    reconstruction_listener_attend_train = train_cca_attend_listener_w_mean(:,story)' *  story_train_EEG;
                    reconstruction_listener_unattend_train = train_cca_unattend_listener_w_mean(:,story)' *  story_train_EEG;
                    
                    
                    if  strcmpi('A',AttendTarget{train_story})
                        [recon_AttendDecoder_attend_cca_train(cnt_train_story,story),p_recon_AttendDecoder_attend_cca(story)] =...
                            corr(reconstruction_listener_attend_train',reconstruction_speakerA_attend_train');
                        [recon_AttendDecoder_unattend_cca_train(cnt_train_story,story),p_recon_AttendDecoder_unattend_cca(story)] = ...
                            corr(reconstruction_listener_attend_train',reconstruction_speakerB_attend_train');
                        
                        [recon_UnattendDecoder_unattend_cca_train(cnt_train_story,story),p_recon_UnattendDecoder_unattend_cca(story)] = ...
                            corr(reconstruction_listener_unattend_train',reconstruction_speakerB_unattend_train');
                        
                        [recon_UnattendDecoder_attend_cca_train(cnt_train_story,story),p_recon_UnattendDecoder_attend_cca(story)] = ...
                            corr(reconstruction_listener_unattend_train',reconstruction_speakerA_unattend_train');
                    else
                        [recon_AttendDecoder_attend_cca_train(cnt_train_story,story),p_recon_AttendDecoder_attend_cca(story)] = ...
                            corr(reconstruction_listener_attend_train',reconstruction_speakerB_attend_train');
                        
                        [recon_AttendDecoder_unattend_cca_train(cnt_train_story,story),p_recon_AttendDecoder_unattend_cca(story)] = ...
                            corr(reconstruction_listener_attend_train',reconstruction_speakerA_attend_train');
                        
                        [recon_UnattendDecoder_unattend_cca_train(cnt_train_story,story),p_recon_UnattendDecoder_unattend_cca(story)] = ...
                            corr(reconstruction_listener_unattend_train',reconstruction_speakerA_unattend_train');
                        
                        [recon_UnattendDecoder_attend_cca_train(cnt_train_story,story),p_recon_UnattendDecoder_attend_cca(story)] = ...
                            corr(reconstruction_listener_unattend_train',reconstruction_speakerB_unattend_train');
                    end
                    
                    
                    cnt_train_story = cnt_train_story + 1;
                    
                end
                
                
            end
            
            
            % predict
            disp(strcat('Predicting story ',num2str(story),'...'));
            % listener
            reconstruction_listener_attend = train_cca_attend_listener_w_mean(:,story)' *  story_predict_listener_EEG;
            reconstruction_listener_unattend = train_cca_unattend_listener_w_mean(:,story)' *  story_predict_listener_EEG;
            
            % speaker
            reconstruction_speakerA_attend = train_cca_attend_speaker_w_mean(:,story)' *  story_predict_speaker_A;
            reconstruction_speakerB_attend = train_cca_attend_speaker_w_mean(:,story)' *  story_predict_speaker_B;
            reconstruction_speakerA_unattend = train_cca_unattend_speaker_w_mean(:,story)' *  story_predict_speaker_A;
            reconstruction_speakerB_unattend = train_cca_unattend_speaker_w_mean(:,story)' *  story_predict_speaker_B;
            
            
            if strcmpi('A',AttendTarget{i})
                [recon_AttendDecoder_attend_cca(story),p_recon_AttendDecoder_attend_cca(story)] =...
                    corr(reconstruction_listener_attend',reconstruction_speakerA_attend');
                [recon_AttendDecoder_unattend_cca(story),p_recon_AttendDecoder_unattend_cca(story)] = ...
                    corr(reconstruction_listener_attend',reconstruction_speakerB_attend');
                
                [recon_UnattendDecoder_unattend_cca(story),p_recon_UnattendDecoder_unattend_cca(story)] = ...
                    corr(reconstruction_listener_unattend',reconstruction_speakerB_unattend');
                
                [recon_UnattendDecoder_attend_cca(story),p_recon_UnattendDecoder_attend_cca(story)] = ...
                    corr(reconstruction_listener_unattend',reconstruction_speakerA_unattend');
            else
                [recon_AttendDecoder_attend_cca(story),p_recon_AttendDecoder_attend_cca(story)] = ...
                    corr(reconstruction_listener_attend',reconstruction_speakerB_attend');
                
                [recon_AttendDecoder_unattend_cca(story),p_recon_AttendDecoder_unattend_cca(story)] = ...
                    corr(reconstruction_listener_attend',reconstruction_speakerA_attend');
                
                [recon_UnattendDecoder_unattend_cca(story),p_recon_UnattendDecoder_unattend_cca(story)] = ...
                    corr(reconstruction_listener_unattend',reconstruction_speakerA_unattend');
                
                [recon_UnattendDecoder_attend_cca(story),p_recon_UnattendDecoder_attend_cca(story)] = ...
                    corr(reconstruction_listener_unattend',reconstruction_speakerB_unattend');
            end
            
            
        end
        
        %         train_cca_attend_listener_w_total{listener} = train_cca_attend_listener_w_mean;
        %         train_cca_unattend_listener_w_total{listener} = train_cca_unattend_listener_w_mean;
        %         train_cca_attend_speaker_w_total{listener} = train_cca_attend_speaker_w_mean;
        %         train_cca_unattend_speaker_w_total{listener} = train_cca_unattend_speaker_w_mean;
        
        train_cca_attend_listener_w_total = train_cca_attend_listener_w_mean;
        train_cca_unattend_listener_w_total= train_cca_unattend_listener_w_mean;
        train_cca_attend_speaker_w_total= train_cca_attend_speaker_w_mean;
        train_cca_unattend_speaker_w_total= train_cca_unattend_speaker_w_mean;
        
        %% plot
        saveName = strcat('cca_S-L_EEG_result+',num2str((1000/Fs)*timelag(j)),'ms',band_name,'.mat');
        save(saveName,'recon_AttendDecoder_attend_cca','recon_UnattendDecoder_unattend_cca' ,'recon_AttendDecoder_unattend_cca','recon_UnattendDecoder_attend_cca',...
            'p_recon_AttendDecoder_attend_cca','p_recon_UnattendDecoder_unattend_cca', 'p_recon_AttendDecoder_unattend_cca','p_recon_UnattendDecoder_attend_cca',...
            'recon_AttendDecoder_attend_cca_train','recon_UnattendDecoder_unattend_cca_train' ,'recon_AttendDecoder_unattend_cca_train','recon_UnattendDecoder_attend_cca_train',...
            'p_recon_AttendDecoder_attend_cca_train','p_recon_UnattendDecoder_unattend_cca_train', 'p_recon_AttendDecoder_unattend_cca_train','p_recon_UnattendDecoder_attend_cca_train',...
            'train_cca_attend_listener_w_mean','train_cca_unattend_listener_w_mean','train_cca_attend_speaker_w_mean','train_cca_unattend_speaker_w_mean');
        
        %plot
        % reconstruction accuracy plot attend
        figure('visible','off');
        plot(recon_AttendDecoder_attend_cca,'r');
        hold on; plot(recon_AttendDecoder_unattend_cca,'b');
        xlabel('Story No.'); ylabel('r value')
        title('Reconstruction Accuracy using cca method for attend decoder');
        legend('Audio attend ','Audio not Attend')
        saveName1 = strcat('Reconstruction Accuracy using S-L cca method for attend decoder+',num2str((1000/Fs)*timelag(j)),'ms',band_name,'.jpg');
        title(saveName1(1:end-4));
        legend('Audio attend ','Audio not Attend')
        saveas(gcf,saveName1);
        close
        
        % reconstruction accuracy plot unattend
        figure('visible','off');
        plot(recon_UnattendDecoder_attend_cca,'r');
        hold on; plot(recon_UnattendDecoder_unattend_cca,'b');
        xlabel('Story No.'); ylabel('r value')
        saveName2 = strcat('Reconstruction Accuracy using S-L cca method for unattend decoder+',num2str((1000/Fs)*timelag(j)),'ms',band_name,'.jpg');
        title(saveName2(1:end-4));
        legend('Audio attend ','Audio not Attend')
        
        saveas(gcf,saveName2);
        close
        
        % Decoding accuracy plot attend
        Decoding_result_attend_decoder = recon_AttendDecoder_attend_cca-recon_AttendDecoder_unattend_cca;
        Individual_subjects_result_attend = sum(Decoding_result_attend_decoder>0,2)/length(data_EEG_listener);
        mean(Individual_subjects_result_attend)
        Decoding_result_unattend_decoder = recon_UnattendDecoder_unattend_cca-recon_UnattendDecoder_attend_cca;
        Individual_subjects_result_unattend = sum(Decoding_result_unattend_decoder>0,2)/length(data_EEG_listener);
        mean(Individual_subjects_result_unattend)
        figure('visible','off');
        plot(Decoding_result_attend_decoder*100,'r');
        hold on; plot(Decoding_result_unattend_decoder*100,'b');
        xlabel('Subject No.'); ylabel('difference');
        saveName3 = strcat('Decoding accuracy using S-L cca method for attend and unattend decoder+',num2str((1000/Fs)*timelag(j)),'ms',band_name,'.jpg');
        title(saveName3(1:end-4))
        legend('Attend Decoder','Unattend Decoder')
        saveas(gcf,saveName3);
        close
        
        Acc_attend(r,j) = mean(Individual_subjects_result_attend);
        Acc_unattend(r,j) = mean(Individual_subjects_result_unattend);
        
    end
    
    cd(strcat(p,'\listener',dataName(1:3),'\retell'));
    
    saveName4 = strcat('listener',dataName(1:3),'_Accuracy.mat');
    save(saveName4,'Acc_attend', 'Acc_unattend');
end