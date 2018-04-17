%% speakerEEG mTRF forward model
% purpose: to test whether the speaker also has TRF response
% use forward model to reconstruct the audio envelope

% LJW
% 2018.3.11

% reversed 4.8 
%-> mTRFcrossval replaced by mTRFcrossval_reshape

band_name = {'delta','theta','alpha','beta'};


for band_select = 1 : length(band_name)
    disp(band_name{band_select});
    mkdir(band_name{band_select});
    cd(band_name{band_select});
    
    %% initial
    load('E:\DataProcessing\chn_re_index.mat');
    chn_re_index = chn_re_index(1:64);
    
    listener_chn= [1:32 34:42 44:59 61:63];
    % % speaker_chn = 63;
    % speaker_chn = [28 31 48 63];
    % speaker_chn = [2 10 19 28 38 48 56 62];% central channels
    % speaker_chn = [1:32 34:42 44:59 61:63];
    % speaker_chn = [17:21 26:30 36:40];
    % speaker_chn = [9:11 18:20 27:29];
    load('E:\DataProcessing\label66.mat');
    layout = 'E:\DataProcessing\easycapm1.mat';
    
    %% data name
    dataName_all = {'101-YJMQ-Listener-ICA-reref-filter_64Hz',...
        '102-LTX-Listener-ICA-reref-filter_64Hz',...
        '103-RT-Listener-ICA-reref-filter_64Hz',...
        '104-ZR-Listener-ICA-reref-filter_64Hz',...
        '105-LX-Listener-ICA-reref-filter_64Hz',...
        '106-WCW-Listener-ICA-reref-filter_64Hz',...
        '107-WY-Listener-ICA-reref-filter_64Hz',...
        '108-LGZ-Listener-ICA-reref-filter_64Hz',...
        '109-PXJ-Listener-ICA-reref-filter_64Hz',...
        '110-LNN-Listener-ICA-reref-filter_64Hz',...
        '111-ZXT-Listener-ICA-reref-filter_64Hz',...
        '112-LX-Listener-ICA-reref-filter_64Hz',...
        '113-SYH-Listener-ICA-reref-filter_64Hz',...
        '114-WXZ-Listener-ICA-reref-filter_64Hz',...
        '115-LYZ-Listener-ICA-reref-filter_64Hz',...
        '116-ZX-Listener-ICA-reref-filter_64Hz',...
        '117-HY-Listener-ICA-reref-filter_64Hz',...
        '118-WM-Listener-ICA-reref-filter_64Hz',...
        '119-ZC-Listener-ICA-reref-filter_64Hz',...
        '120-LYB-Listener-ICA-reref-filter_64Hz'};
    
    dataFile_all = {'20171118-YJMQ','20171122-LTX','20171122-RT',...
        '20171124-ZR','20171125-LX','20171128-WCW',...
        '20171130-WY','20171202-LGZ','20171205-PXJ','20171206-LNN',...
        '20171209-ZXT','20171209-LX','20171213-SYH',...
        '20171214-WXZ','20171214-LYZ','20171216-ZX',...
        '20171216-HY','20171220-WM','20171221-ZC',...
        '20171221-LYB'};
    
    
    
%     mkdir('Audio theta reverse zscore');
%     cd('Audio theta reverse zscore');
    
    
    for i = 1 : 20
        
        %% listener name
        if i < 10
            file_name = strcat('listener10',num2str(i));
        else
            file_name = strcat('listener1',num2str(i));
        end
        
%         mkdir(file_name);
%         cd(file_name);
        disp(file_name);
        dataName =  dataName_all{i};
        dataFile = dataFile_all{i};
        
        
        
        %% band name
        lambda = 2.^(0:5:40);
        %     band_name = strcat(' 64Hz theta speakerEEG mTRF Listener',dataName(1:3),' lambda',num2str(lambda),' 10-55s');
        
        %% CounterBalanceTable
        load(strcat('E:\DataProcessing\speaker-listener_experiment\CountBalanceTable\CountBalanceTable_listener',dataName(1:3),'.mat'));
        
        %% load Audio data
        load(strcat('E:\DataProcessing\speaker-listener_experiment\AudioData\from wav\Listener',dataName(1:3),'_Audio_envelope_hilbert_first_64Hz_keep_order.mat'));
        
        %% timelag
        Fs = 64;
        timelag = 0;
        %     timelag_gap = timelag(2)-timelag(1);
        %     timelag_interval = 9;
%         timelag_length = 6000;
        %     timelag = timelag(1:timelag_interval:end);
        %     timelag = -250:(1000/Fs):500;
        % timelag = timelag(33:49);
        %     timelag = 0;
        
        %% length
        start_time = 10;
        end_time = 55;
        Listener_time_index = (start_time+5)*Fs+1:(end_time+5)*Fs;
        Audio_time_index =  start_time*Fs+1:end_time*Fs;
        %     EEG_time = 15 * Fs : 60 * Fs;
        % clip_length = 5 * Fs;
        %
        % clipNum = round(EEG_time/clip_length);
        
        
        %% load EEG data
        temp_data_name = strcat('data_filtered_',band_name{band_select});
        load(strcat('E:\DataProcessing\speaker-listener_experiment\ListenerData\',dataName,'.mat'),temp_data_name);
        
        % combine
        %     EEGBlock = data_filtered_theta.trial;
        EEGBlock = eval(strcat(temp_data_name,'.trial'));
        EEGBlock = EEGBlock';
        
        for jj = 1 : length(EEGBlock)
            
            % reverse
            if strcmpi(Space(jj),'left')
                EEG_train =  EEGBlock{jj}(listener_chn,Listener_time_index);
            else
                EEG_train = EEGBlock{jj}(chn_re_index,:);
                EEG_train =  EEG_train(listener_chn,Listener_time_index);
            end
            
            % EEG
            EEG_train = EEG_train';
            Listener_EEG_test{jj} = zscore(EEG_train);
        end
        
        % train EEG
        
        
        
        
        %% chn_sel
        data_left = eval(strcat('data_left_',band_name{band_select}));
        data_right = eval(strcat('data_right_',band_name{band_select}));
        
        for train_index = 1 : length(data_left)
            % train story
            if strcmpi('left',Space{train_index})
                Audio_attend{train_index} = data_left{train_index}(Audio_time_index);
                
                Audio_unattend{train_index}= data_right{train_index}(Audio_time_index);
            else
                Audio_attend{train_index} = data_right{train_index}(Audio_time_index);
                Audio_unattend{train_index} = data_left{train_index}(Audio_time_index);
            end
            
            Audio_attend{train_index} = zscore(Audio_attend{train_index});
            Audio_unattend{train_index} = zscore(Audio_unattend{train_index});
        end
        
        
        for j = 1 : length(timelag)
            disp(strcat('timelag',num2str(timelag(j)),'ms'));
            
            %% mTRF intitial
            
            start_time = -1000 + timelag(j);
            end_time = 1000 + timelag(j);
            
            
            %% mTRF train and test
            [R_attend,P_attend,MSE_attend,~,model_attend,model_reshape_attend] = mTRFcrossval_reshape(Audio_attend,Listener_EEG_test,Fs,1,start_time,end_time,lambda);
            [R_unattend,P_unattend,MSE_unattend,~,model_unattend,model_reshape_unattend] = mTRFcrossval_reshape(Audio_unattend,Listener_EEG_test,Fs,1,start_time,end_time,lambda);
            
            %% save data
            saveName = strcat('mTRF_Audio_listenerEEG_forward_result_',band_name{band_select},'-',file_name,'.mat');
            %     saveName = strcat('mTRF_sound_EEG_result.mat');
            save(saveName,'R_attend','P_attend','MSE_attend','model_attend','model_reshape_attend',...
                'R_unattend','P_unattend','MSE_unattend','model_unattend','model_reshape_unattend');
            
        end
        
        
%         p = pwd;
%         cd(p(1:end-(length(file_name)+1)));
    end
    
    p = pwd;
    cd(p(1:end-(length(band_name{band_select})+1)));
end