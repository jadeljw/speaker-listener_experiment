% mTRF_speakerEEG_plot_forward

band_name = {'delta','theta','alpha','beta','broadband'};

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select},' reverse');
    mkdir(band_file_name);
    cd(band_file_name);
    
    
    
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
    timelag_select = timelag_plot(1:7:end);
    timelag_index = 1 : 7 : 49;

    %% lambda index
    lambda = 2 ^ 10;
    
    %% initial
    listener_num = 20;
    
    model_attend_mean = zeros(listener_num,length(speaker_chn),length(timelag_select),length(listener_chn));
    model_unattend_mean = zeros(listener_num,length(speaker_chn),length(timelag_select),length(listener_chn));
    
    for i = 1 : 20
        
        %% listener name
        if i < 10
            file_name = strcat('listener10',num2str(i));
        else
            file_name = strcat('listener1',num2str(i));
        end
        
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
            
            model_attend_mean(i,chn_speaker,:,:) = squeeze(mean(model_attend(:,timelag_index,:)));
            model_unattend_mean(i,chn_speaker,:,:) = squeeze(mean(model_unattend(:,timelag_index,:)));
            
        end
    end
    
    
    %% plot
    for time_point = 1 : length(timelag_select)
        time_point_name = strcat(num2str(timelag_select(time_point)),'ms');
%         mkdir(time_point_name);
%         cd(time_point_name);
        
        
        % attend
        for chn_speaker = 1 : length(speaker_chn)
            chn_file_name = strcat(num2str(chn_speaker),'-',label66{speaker_chn(chn_speaker)});
            %% plot
            set(gcf,'outerposition',get(0,'screensize'));
            eval(strcat('subplot(6,10,',num2str(chn_speaker),')'));
            
            R_attend_for_topoplot = squeeze(mean(model_attend_mean(:,chn_speaker,time_point,:)));
%             U_topoplot(abs(zscore(R_attend_for_topoplot)),layout,label66(listener_chn),[],3);
            U_topoplot(R_attend_for_topoplot,layout,label66(listener_chn),[],4*1e-3);
            title(label66{listener_chn(chn_speaker)});
            
        end
        save_name = strcat('mTRF SpeakerEEG-listenerEEG attend Topoplot timelag',num2str(timelag_select(time_point)),'ms-',band_name{band_select},'.jpg');
        suptitle(save_name(1:end-4));
        saveas(gcf,save_name);
        
        close;
        
        % unatttend
        for chn_speaker = 1 : length(speaker_chn)
            chn_file_name = strcat(num2str(chn_speaker),'-',label66{speaker_chn(chn_speaker)});
            %% plot
            set(gcf,'outerposition',get(0,'screensize'));
            eval(strcat('subplot(6,10,',num2str(chn_speaker),')'));
            
            R_unattend_for_topoplot = squeeze(mean(model_unattend_mean(:,chn_speaker,time_point,:)));
            U_topoplot(R_unattend_for_topoplot,layout,label66(listener_chn),[],4*1e-3);
            title(label66{listener_chn(chn_speaker)});
            
        end
        save_name = strcat('mTRF SpeakerEEG-listenerEEG forward unattend Topoplot timelag',num2str(timelag_select(time_point)),'ms-',band_name{band_select},'.jpg');
        suptitle(save_name(1:end-4));
        saveas(gcf,save_name);
        
        close;
        
%         p = pwd;
%         cd(p(1:end-(length(time_point_name)+1)));
    end
    
     p = pwd;
     cd(p(1:end-(length(band_file_name)+1)));
end
