%% sound envelope & EEG cca for Speaker_listener study
% Li Jiawei:  jx_ljw@163.com
% 2016.11.28
% sound envelope & EEG cca
% for Speaker_listener studysound envelope & EEG correlation for Speaker_listener study

%% initial
% speaker time -5 to 45s
Fs = 64;
start_time = 10;
end_time = 55;
% listener_time_index =  2001:8000; % 5 s - 35s
listener_time_index =  (start_time+5)*Fs+1:(end_time+5)*Fs; % 10 s - 35s


% band for analysis
theta = 1;
broadband = 0;


%% attend matrix
load('E:\DataProcessing\speaker-listener_experiment\mfiles\CountBalanceTable\CountBalanceTable_listener0_analysis.mat');

%% boradband load data
if broadband
    % load Listener data
%     load('E:\DataProcessing\speaker-listener_experiment\ListenerData\0-LZR-Listener-ICA-filter-reref_type.mat','listener_boradband_read','listener_boradband_retell');
    load('E:\DataProcessing\speaker-listener_experiment\ListenerData\01-CYX-Listener-ICA-filter-reref_type.mat','listener_boradband_read','listener_boradband_retell');
    data_EEG_listener = [listener_boradband_retell listener_boradband_read];
    
    %load speaker data
    load('E:\DataProcessing\speaker-listener_experiment\SpeakerData\Speaker01-CFY-read_retell_valid.mat',...
        'data_speakerA_retell_boradband_valid','data_speakerA_read_boradband_valid');
    load('E:\DataProcessing\speaker-listener_experiment\SpeakerData\Speaker02-FS-read_retell_valid.mat',...
        'data_speakerB_retell_boradband_valid','data_speakerB_read_boradband_valid');
    
    %     % correct label for listener0
    %     data_speakerA_retell_boradband_valid(2)=data_speakerA_retell_boradband_valid(15);
    %     data_speakerB_retell_boradband_valid(2)=data_speakerB_retell_boradband_valid(15);
    
    data_EEG_speakerA = [data_speakerA_retell_boradband_valid(1:14) data_speakerA_read_boradband_valid(1:14)];
    data_EEG_speakerB = [data_speakerB_retell_boradband_valid(1:14) data_speakerB_read_boradband_valid(1:14)];
    
    
    %bandname
    band_name = ' 0.5Hz-40Hz 64Hz';
    
end

%% theta load data
if theta
    % load Listener data
    %     load('E:\DataProcessing\speaker-listener_experiment\ListenerData\0-LZR-Listener-ICA-filter-reref_type.mat','listener_theta_read','listener_theta_retell');
    load('E:\DataProcessing\speaker-listener_experiment\ListenerData\01-CYX-Listener-ICA-filter-reref_type.mat','listener_theta_retell','listener_theta_read')
    
    data_EEG_listener = [listener_theta_retell listener_theta_read];

    % bandname
    band_name = ' 2Hz-8Hz 64Hz';
end





%% load sound from wav
sound_time_index =  start_time*Fs+1:end_time*Fs;

load('E:\DataProcessing\speaker-listener_experiment\AudioData\Audio_envelope_64Hz_hilbert_cell.mat');

% retelling story 2 is original story 15
% AudioA_retell_cell{2} = AudioA_retell_cell{15};
% AudioB_retell_cell{2} = AudioB_retell_cell{15};

% only has 14 stories for each type

% write into cell
AudioA_total = [AudioA_retell_cell(1:14) AudioA_read_cell(1:14)];
AudioB_total = [AudioB_retell_cell(1:14) AudioB_read_cell(1:14)];



%% Channel Index
chn_sel_index= [1:32 34:42 44:59 61:63];

%% attend matrix
load('E:\DataProcessing\ListenA_Or_Not.mat')

%% timelag
timelag = (-250:500/32:500)/(1000/Fs); % Fs = 200Hz -> -200ms~500ms
% timelag = 0;
% 1 point = 5 ms

%% topoplot initial
load('E:\DataProcessing\label66.mat');
load('E:\DataProcessing\easycapm1.mat');
chn2chnName= [1:32 34:42 44:59 61:63];

%% Combine data
for j =  1 : length(timelag)
    % %% Combine data
    disp('combining data ...');
    tic;
    eval(strcat('eeg_dual_total=zeros(length(chn_sel_index),length(listener_time_index)*length(data_EEG_listener));'));
    %     eval(strcat('eeg_B_',dataName,'_total=[];'));
    eval(strcat('audio_Attend_total=zeros(1,length(sound_time_index)*length(data_EEG_listener));'));
    eval(strcat('audio_unAttend_total=zeros(1,length(sound_time_index)*length(data_EEG_listener));'));
    
    % Combine data
    cnt = 1;
    for i = 1 : length(data_EEG_listener)
        
        % listener EEG
        %                 tempDataA = eval(dataName);
        EEG_all = data_EEG_listener{i};
        EEG_all = EEG_all(chn_sel_index,listener_time_index+timelag(j));
        %             eval(strcat('eeg_dual_',dataName,'_total(:,cnt:cnt+length(listener_time_index)-1)= EEG_all;'));
        eeg_dual_total(:,cnt:cnt+length(listener_time_index)-1)= EEG_all;
        
        
        % speaker EEG
        AudioA = AudioA_total{i}(sound_time_index);
        AudioB = AudioB_total{i}(sound_time_index);
        if  strcmpi('B',AttendTarget{i}) % attend A
            audio_Attend_total(:,cnt:cnt+length(sound_time_index)-1) = AudioA;
            audio_unAttend_total(:,cnt:cnt+length(sound_time_index)-1) = AudioB;
        else
            audio_Attend_total(:,cnt:cnt+length(sound_time_index)-1) = AudioB;
            audio_unAttend_total(:,cnt:cnt+length(sound_time_index)-1) = AudioA;
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
    
    
    recon_AttendDecoder_attend_total = zeros(1,length(timelag));
    recon_AttendDecoder_unattend_total = zeros(1,length(timelag));
    recon_UnattendDecoder_attend_total = zeros(1,length(timelag));
    recon_UnattendDecoder_unattend_total = zeros(1,length(timelag));
    decoding_acc_attended = zeros(1,length(timelag));
    decoding_acc_unattended = zeros(1,length(timelag));
    
    % train matrix
    recon_AttendDecoder_attend_cca_train = zeros(length(data_EEG_listener)-1,length(data_EEG_listener)); % training story numbers, listener, story
    recon_UnattendDecoder_unattend_cca_train = zeros(length(data_EEG_listener)-1,length(data_EEG_listener));
    recon_AttendDecoder_unattend_cca_train = zeros(length(data_EEG_listener)-1,length(data_EEG_listener));
    recon_UnattendDecoder_attend_cca_train = zeros(length(data_EEG_listener)-1,length(data_EEG_listener));
    
    p_recon_AttendDecoder_attend_cca_train = zeros(length(data_EEG_listener)-1,length(data_EEG_listener));
    p_recon_UnattendDecoder_unattend_cca_train = zeros(length(data_EEG_listener)-1,length(data_EEG_listener));
    p_recon_AttendDecoder_unattend_cca_train = zeros(length(data_EEG_listener)-1,length(data_EEG_listener));
    p_recon_UnattendDecoder_attend_cca_train = zeros(length(data_EEG_listener)-1,length(data_EEG_listener));
    
    for story = 1 : length(data_EEG_listener)
        
        disp(strcat('Training story ',num2str(story),'...'));
        % predict data -> predict data
        predict_time_index = length(listener_time_index)*(story-1)+1:length(listener_time_index)*story;
        story_predict_EEG = data_EEG_listener{story};
        story_predict_EEG = story_predict_EEG(chn_sel_index,listener_time_index+timelag(j));
        
        story_predict_audio_A = AudioA_total{story}(sound_time_index);
        story_predict_audio_B = AudioB_total{story}(sound_time_index);
        
        % train data
        %         story_train_EEG = eval(strcat('eeg_dual_Listener',num2str(listener),'_total'));
        story_train_EEG  = eeg_dual_total;
        story_train_EEG(:,predict_time_index) = [];
        
        %         story_train_audio_Attend = eval(strcat('audio_Attend_Listener',num2str(listener),'_total'));
        story_train_audio_Attend = audio_Attend_total;
        story_train_audio_unAttend = audio_unAttend_total;
        %         story_train_audio_unAttend = eval(strcat('audio_notAttend_Listener',num2str(listener),'_total'));
        story_train_audio_Attend(:,predict_time_index) = [];
        story_train_audio_unAttend(:,predict_time_index) = [];
        
        
        % cca
        [train_cca_attend_w1,train_cca_attend_w2,train_cca_attend_r] = canoncorr(story_train_EEG',story_train_audio_Attend');
        [train_cca_unattend_w1,train_cca_unattend_w2,train_cca_unattend_r] = canoncorr(story_train_EEG',story_train_audio_unAttend');
        
        % record into one matrix
        train_cca_attend_mean(:,story) = train_cca_attend_w1;
        train_cca_attend_r(:,story) = train_cca_attend_r;
        train_cca_unattend_mean(:,story) = train_cca_unattend_w1;
        train_cca_unattend_r(:,story) = train_cca_unattend_r;
        
        
        % apply weights to each story as training sample
        cnt_train_story = 1;
        for train_story = 1 : length(data_EEG_listener)
            
            
            if train_story ~= story
                story_train_EEG = data_EEG_listener{train_story};
                story_train_EEG = story_train_EEG(chn_sel_index,listener_time_index+timelag(j));
                story_train_audio_A = AudioA_total{train_story}(sound_time_index);
                story_train_audio_B = AudioB_total{train_story}(sound_time_index);
                
                % apply weights to individual story
                reconstruction_audio_attend = train_cca_attend_mean(:,story)' *  story_train_EEG;
                reconstruction_audio_unattend = train_cca_unattend_mean(:,story)' *  story_train_EEG;
                
                if strcmpi('B',AttendTarget{train_story})
                    [recon_AttendDecoder_attend_cca_train(cnt_train_story,story),p_recon_AttendDecoder_attend_cca_train(cnt_train_story,story)] =...
                        corr(reconstruction_audio_attend',story_train_audio_A');
                    [recon_AttendDecoder_unattend_cca_train(cnt_train_story,story),p_recon_AttendDecoder_unattend_cca_train(cnt_train_story,story)] = ...
                        corr(reconstruction_audio_attend',story_train_audio_B');
                    
                    [recon_UnattendDecoder_unattend_cca_train(cnt_train_story,story),p_recon_UnattendDecoder_unattend_cca_train(cnt_train_story,story)] = ...
                        corr(reconstruction_audio_unattend',story_train_audio_B');
                    
                    [recon_UnattendDecoder_attend_cca_train(cnt_train_story,story),p_recon_UnattendDecoder_attend_cca_train(cnt_train_story,story)] = ...
                        corr(reconstruction_audio_unattend',story_train_audio_A');
                else
                    [recon_AttendDecoder_attend_cca_train(cnt_train_story,story),p_recon_AttendDecoder_attend_cca_train(cnt_train_story,story)] = ...
                        corr(reconstruction_audio_attend',story_train_audio_B');
                    
                    [recon_AttendDecoder_unattend_cca_train(cnt_train_story,story),p_recon_AttendDecoder_unattend_cca_train(cnt_train_story,story)] = ...
                        corr(reconstruction_audio_attend',story_train_audio_A');
                    
                    [recon_UnattendDecoder_unattend_cca_train(cnt_train_story,story),p_recon_UnattendDecoder_unattend_cca_train(cnt_train_story,story)] = ...
                        corr(reconstruction_audio_unattend',story_train_audio_A');
                    
                    [recon_UnattendDecoder_attend_cca_train(cnt_train_story,story),p_recon_UnattendDecoder_attend_cca_train(cnt_train_story,story)] = ...
                        corr(reconstruction_audio_unattend',story_train_audio_B');
                    
                    
                end
                
                
                cnt_train_story = cnt_train_story + 1;
                
            end
            
            
        end
        
        
        
        % predict
        disp(strcat('Predicting story ',num2str(story),'...'));
        reconstruction_audio_attend = train_cca_attend_mean(:,story)' *  story_predict_EEG;
        reconstruction_audio_unattend = train_cca_unattend_mean(:,story)' *  story_predict_EEG;
        
        if strcmpi('B',AttendTarget{story})
            [recon_AttendDecoder_attend_cca(story),p_recon_AttendDecoder_attend_cca(story)] =...
                corr(reconstruction_audio_attend',story_predict_audio_A');
            [recon_AttendDecoder_unattend_cca(story),p_recon_AttendDecoder_unattend_cca(story)] = ...
                corr(reconstruction_audio_attend',story_predict_audio_B');
            
            [recon_UnattendDecoder_unattend_cca(story),p_recon_UnattendDecoder_unattend_cca(story)] = ...
                corr(reconstruction_audio_unattend',story_predict_audio_B');
            
            [recon_UnattendDecoder_attend_cca(story),p_recon_UnattendDecoder_attend_cca(story)] = ...
                corr(reconstruction_audio_unattend',story_predict_audio_A');
        else
            [recon_AttendDecoder_attend_cca(story),p_recon_AttendDecoder_attend_cca(story)] = ...
                corr(reconstruction_audio_attend',story_predict_audio_B');
            
            [recon_AttendDecoder_unattend_cca(story),p_recon_AttendDecoder_unattend_cca(story)] = ...
                corr(reconstruction_audio_attend',story_predict_audio_A');
            
            [recon_UnattendDecoder_unattend_cca(story),p_recon_UnattendDecoder_unattend_cca(story)] = ...
                corr(reconstruction_audio_unattend',story_predict_audio_A');
            
            [recon_UnattendDecoder_attend_cca(story),p_recon_UnattendDecoder_attend_cca(story)] = ...
                corr(reconstruction_audio_unattend',story_predict_audio_B');
        end
        
        
        
    end
    
    
    % save
    saveName = strcat('cca_sound_EEG_result+',num2str((1000/Fs)*timelag(j)),'ms',band_name,'.mat');
    save(saveName,'recon_AttendDecoder_attend_cca','recon_UnattendDecoder_unattend_cca' ,'recon_AttendDecoder_unattend_cca','recon_UnattendDecoder_attend_cca',...
        'p_recon_AttendDecoder_attend_cca','p_recon_UnattendDecoder_unattend_cca', 'p_recon_AttendDecoder_unattend_cca','p_recon_UnattendDecoder_attend_cca',...
        'recon_AttendDecoder_attend_cca_train','recon_UnattendDecoder_unattend_cca_train' ,'recon_AttendDecoder_unattend_cca_train','recon_UnattendDecoder_attend_cca_train',...
        'p_recon_AttendDecoder_attend_cca_train','p_recon_UnattendDecoder_unattend_cca_train', 'p_recon_AttendDecoder_unattend_cca_train','p_recon_UnattendDecoder_attend_cca_train');
    
    %plot
    % reconstruction accuracy plot attend
    figure; plot(recon_AttendDecoder_attend_cca,'r');
    hold on; plot(recon_AttendDecoder_unattend_cca,'b');
    xlabel('Subject No.'); ylabel('r value')
    title('Reconstruction Accuracy using cca method for attend decoder');
    legend('Audio attend ','Audio not Attend')
    saveName1 = strcat('Reconstruction Accuracy using cca method for attend decoder+',num2str((1000/Fs)*timelag(j)),'ms',band_name,'.jpg');
    title(saveName1(1:end-4));
    legend('Audio attend ','Audio not Attend')
    saveas(gcf,saveName1);
    close
    
    % reconstruction accuracy plot unattend
    figure; plot(recon_UnattendDecoder_attend_cca,'r');
    hold on; plot(recon_UnattendDecoder_unattend_cca,'b');
    xlabel('story No.'); ylabel('r value')
    saveName2 = strcat('Reconstruction Accuracy using cca method for unattend decoder+',num2str((1000/Fs)*timelag(j)),'ms',band_name,'.jpg');
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
    figure; plot(Decoding_result_attend_decoder,'r');
    hold on; plot(Decoding_result_unattend_decoder,'b');
    xlabel('story No.'); ylabel('different');
%     ylim([0,100]);
    saveName3 = strcat('Decoding accuracy using cca method for attend and unattend decoder+',num2str((1000/Fs)*timelag(j)),'ms',band_name,'.jpg');
    title(saveName3(1:end-4))
    legend('Attend Decoder','Unattend Decoder')
    saveas(gcf,saveName3);
    close
    
    
    
end



