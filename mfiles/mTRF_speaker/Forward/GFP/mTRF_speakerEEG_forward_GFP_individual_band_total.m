% mTRF_speakerEEG_plot_forward

band_name = {'delta','theta','alpha','beta','broadband','1_8Hz','narrow_theta'};
% band_name = {'alpha'};


%% initial
load('E:\DataProcessing\chn_re_index.mat');
chn_re_index = chn_re_index(1:64);

listener_chn= [1:32 34:42 44:59 61:63];
% speaker_chn = 63;
% speaker_chn = [28 31 48 60];
speaker_chn = [1:32 34:42 44:59 61:63];
% speaker_chn = [17:21 26:30 36:40];
% speaker_chn = [9:11 18:20 27:29];
load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';


%% timelag
Fs = 64;
timelag_plot = -250:500/32:500;
%     timelag = -250:(1000/Fs):500;
% timelag = timelag(33:49);
%     timelag = 0;
timelag_select = timelag_plot(1:end);
timelag_index = 1:length(timelag_select);

%% lambda index
lambda = 2 ^ 10;

%% initial
listener_num = 20;
story_num = 28;

model_attend_GFP_total = zeros(listener_num,length(speaker_chn),length(timelag_select));
model_unattend_GFP_total = zeros(listener_num,length(speaker_chn),length(timelag_select));

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select},' reverse');
%     mkdir(band_file_name);
%     cd(band_file_name);
    
    % listener
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
        %% initial
        model_attend_all = zeros(story_num,length(speaker_chn),length(timelag_select),length(listener_chn));
        model_unattend_all = zeros(story_num,length(speaker_chn),length(timelag_select),length(listener_chn));
        
        %% record into matrix
        for chn_speaker = 1 : length(speaker_chn)
            chn_file_name = strcat(num2str(chn_speaker),'-',label66{speaker_chn(chn_speaker)});
            disp(strcat(file_name,'-',chn_file_name));
            %% load plot data
            data_name =  strcat('mTRF_speakerEEG_listenerEEG_forward_result+',label66{speaker_chn(chn_speaker)},'-lambda',num2str(lambda),'.mat');
            data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Forward model\SpeakerEEG-listenerEEG\',band_name{band_select},' reverse zscore\',file_name);
            load(strcat(data_path,'\',data_name));
            
            %% record into matrix
            %             R_attend_mean(i,chn_speaker,:,:) = squeeze(mean(R_attend)); % listener * timelag * chn *time point
            %             R_unattend_mean(i,chn_speaker,:,:) = squeeze(mean(R_unattend));
            
            model_attend_all(:,chn_speaker,:,:) = squeeze(model_attend(:,timelag_index,:));
            model_unattend_all(:,chn_speaker,:,:) = squeeze(model_unattend(:,timelag_index,:));
            
        end
        
        
        %% merge into big mat
        model_attend_GFP = zeros(length(speaker_chn),length(timelag_select));
        model_unattend_GFP= zeros(length(speaker_chn),length(timelag_select));
        
        
        %% calculating GFP for every listener
        disp('Calculating GFP...')
        for chn_speaker = 1 : length(speaker_chn)
            for time_point = 1 : length(timelag_select)
                % attend
                temp_attend = squeeze(mean(model_attend_all(:,chn_speaker,time_point,:)));
                model_attend_GFP(chn_speaker,time_point) = sum(temp_attend.^2)/length(listener_chn);
                % unattend
                temp_unattend = squeeze(mean(model_unattend_all(:,chn_speaker,time_point,:)));
                model_unattend_GFP(chn_speaker,time_point) = sum(temp_unattend.^2)/length(listener_chn);
            end
        end
        
        
        %% merge into total GFP mat
        model_attend_GFP_total(i,:,:) = model_attend_GFP;
        model_unattend_GFP_total(i,:,:) = model_unattend_GFP;

        
    end
    save_name = strcat('mTRF SpeakerEEG-listenerEEG GFP-',band_name{band_select},'-total.mat');
    save(save_name,'model_attend_GFP_total','model_unattend_GFP_total');
    
%     p = pwd;
%     cd(p(1:end-(length(band_file_name)+1)));
end
