% mTRF_speakerEEG_plot_forward

band_name = {'delta','theta','alpha','beta','broadband','1_8Hz'};
% band_name = {'narrow_theta'};

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
    timelag_select = timelag_plot(1:end);
    timelag_index = 1:length(timelag_select);
    
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
    
    model_attend_GFP = zeros(length(listener_chn),length(timelag_select));
    model_unattend_GFP= zeros(length(listener_chn),length(timelag_select));
    
    %% calculating GFP
    disp('Calculating GFP...')
    for chn_speaker = 1 : length(speaker_chn)
        for time_point = 1 : length(timelag_select)
            % attend
            temp_attend = squeeze(mean(model_attend_mean(:,chn_speaker,time_point,:)));
            model_attend_GFP(chn_speaker,time_point) = sum(temp_attend.^2)/length(listener_chn);
            % unattend
            temp_unattend = squeeze(mean(model_unattend_mean(:,chn_speaker,time_point,:)));
            model_unattend_GFP(chn_speaker,time_point) = sum(temp_unattend.^2)/length(listener_chn);
        end
    end
    
    
    %% plot
    plot_page_each = 20;
    for plot_page = 1 : round(length(speaker_chn)/plot_page_each)
        cnt = 1;
        for chn_speaker = (plot_page-1) * plot_page_each + 1 : plot_page * plot_page_each 
            
            disp(strcat(num2str(chn_speaker),'-',label66{speaker_chn(chn_speaker)}));
            chn_file_name = strcat(num2str(chn_speaker),'-',label66{speaker_chn(chn_speaker)});
            
            
            %% plot
            set(gcf,'outerposition',get(0,'screensize'));
            eval(strcat('subplot(4,5,',num2str(cnt),')'));
            
            plot(timelag_select,model_attend_GFP(chn_speaker,timelag_index)','LineWidth',1);
%             ylim([0,1.2*1e-5]);
            hold on; 
            plot(timelag_select,model_unattend_GFP(chn_speaker,timelag_index)','LineWidth',1);
%             legend('attend','unattend');
            ylim([0,max(max([model_attend_GFP model_unattend_GFP]))]);
            title(label66{listener_chn(chn_speaker)});
            cnt = cnt + 1;
            %         close;
        end
        
        save_name = strcat('mTRF SpeakerEEG-listenerEEG GFP-',band_name{band_select},'-page',num2str(plot_page),'.jpg');
        legend('attend','unattend');
        suptitle(save_name(1:end-4));
        saveas(gcf,save_name);
        close
    end
    
    save_name = strcat('mTRF SpeakerEEG-listenerEEG GFP-',band_name{band_select},'.mat');
    save(save_name,'model_attend_mean','model_unattend_mean',...
        'model_attend_GFP','model_unattend_GFP');
        
    
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end
