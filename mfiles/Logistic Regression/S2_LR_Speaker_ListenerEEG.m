%% LR_Audio_ListenerEEG
% purpose: use logistic regression
% to find the relation between r value and attend target
% Attend A ->1
% Attend
% LJW
% 2018.3.11

band_name = {'delta','theta','alpha'};
listener_num = 20;
type = {'diff','total'};
%% initial
load('E:\DataProcessing\chn_re_index.mat');
chn_re_index = chn_re_index(1:64);

listener_chn= [1:32 34:42 44:59 61:63];
% % speaker_chn = 63;
% speaker_chn = [28 31 48 63];
% speaker_chn = [2 10 19 28 38 48 56 62];% central channels
speaker_chn = [1:32 34:42 44:59 61:63];
% speaker_chn = [17:21 26:30 36:40];
% speaker_chn = [9:11 18:20 27:29];
load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';

% combine similiar channels together
load('E:\DataProcessing\Label_and_area.mat','order');
new_speaker_order = order;


%% timelag
Fs = 64;
timelag = -500 : 1000/Fs : 500;
label_select = 1 : round(length(timelag)/8) :length(timelag);

R_squared_mat_speaker = zeros(length(speaker_chn),length(timelag));

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    
    for type_select = 1 : length(type)
        
        mkdir(type{type_select});
        cd(type{type_select});
        
        
        
        %% initial
        R_squared_mat = zeros(listener_num,length(timelag));
        
        for chn = 1 : length(speaker_chn)
            chn_file_name = strcat(num2str(chn),'-',label66{speaker_chn(chn)});
            mkdir(chn_file_name);
            cd(chn_file_name);
            disp(chn_file_name);
            
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
                
                
                %% band name
                %         lambda = 2.^(0:5:20);
                lambda = 2.^ 10;
                %     band_name = strcat(' 64Hz delta speakerEEG mTRF Listener',dataName(1:3),' lambda',num2str(lambda),' 10-55s');
                
                
                
                
                for time_point = 1 : length(timelag)
                    %             disp(strcat(timelag(time_point),'ms'));
                    
                    %% load r value data
                    load(strcat('E:\DataProcessing\speaker-listener_experiment\Logistic Regression\Speaker-listenerEEG\',...
                        band_file_name,'\',file_name,'\',chn_file_name,'\mTRF_speakerEEG_listenerEEG_result+',label66{speaker_chn(chn)},...
                        '-timelag',num2str(timelag(time_point)),'ms-',band_file_name,'.mat'));
                    
                    %% combine r value
                    
                    % total
                    if strcmp(type{type_select},'total') == 1
                        r_value_mat = [recon_AttendDecoder_SpeakerA_corr recon_AttendDecoder_SpeakerB_corr recon_UnattendDecoder_SpeakerA_corr recon_UnattendDecoder_SpeakerB_corr];
                    end
                    
                    % difference
                    if strcmp(type{type_select},'diff') == 1
                        r_value_mat = [recon_AttendDecoder_SpeakerA_corr-recon_AttendDecoder_SpeakerB_corr recon_UnattendDecoder_SpeakerA_corr-recon_UnattendDecoder_SpeakerB_corr];
                    end
                    
                    attend_target_mat = attend_target_num'; % 1 -> attend A; 0 -> attend B
                    
                    %% logtistic regression
                    %             disp('Logtistic Regression...')
                    %             tic;
                    glm = fitglm(r_value_mat,attend_target_mat,'distr','binomial');
                    %             toc;
                    
                    %% save result
                    R_squared_mat(i,time_point) = glm.Rsquared.Adjusted;
                    if glm.Rsquared.Adjusted == 1
                        %                 plot(r_value_mat,'*','LineWidth',2);
                        imagesc(r_value_mat);colorbar;
                        data_name = strcat(file_name(2:end),'+',num2str(timelag(time_point)),'ms.jpg');
                        title(data_name(1:end-4));
                        xticks(1:2);
                        %                 xticklabels({'Attend-A','Attend-B','Unattend-A','Unattend-B'});
                        xticklabels({'Attend','Unattend'});
                        saveas(gcf,data_name);
                        close
                    end
                    
                end
            end
            
            
            %% plot
            % imagesc
%             set(gcf,'outerposition',get(0,'screensize'));
%             imagesc(R_squared_mat);colorbar;
%             %     colormap('jet');
%             xticks(label_select);
%             xticklabels(timelag(label_select));
%             
%             save_name = strcat('Audio ListenerEEG Logstic Regresssion r^2 Result-',label66{speaker_chn(chn)},'-',band_name{band_select},'-imagesc-',type{type_select},'.jpg');
%             title(save_name(1:end-4));
%             saveas(gcf,save_name);
%             close
%             
%             % plot mean result
%             set(gcf,'outerposition',get(0,'screensize'));
%             plot(timelag,mean(R_squared_mat),'LineWidth',2);
%             save_name1 = strcat('Audio ListenerEEG Logstic Regresssion r^2 Result-',label66{speaker_chn(chn)},'-',band_name{band_select},'-mean-',type{type_select},'.jpg');
%             title(save_name1(1:end-4));
%             saveas(gcf,save_name1);
%             close
%             
            % save data
            save_name2 = strcat('Audio ListenerEEG Logstic Regresssion r^2 Result-',label66{speaker_chn(chn)},'-',band_name{band_select},'-',type{type_select},'.mat');
            save(save_name2,'R_squared_mat');
            
            % record into mat
            R_squared_mat_speaker(new_speaker_order(find(speaker_chn) == chn),:) = mean(R_squared_mat);
            
            % file
            p = pwd;
            cd(p(1:end-(length(chn_file_name)+1)));
            
        end
        
        % imagesc
        set(gcf,'outerposition',get(0,'screensize'));
        imagesc(R_squared_mat_speaker);colorbar;
        %     colormap('jet');
        xticks(label_select);
        xticklabels(timelag(label_select));
        yticks(1:10:60);
        yticklabels({'Frontal-left','Frontal-right','Central-left','Central-right','Occipital-left','Occipital-right'});
        xlabel('timelag(ms)');
        ylabel('Speaker Channels');
        save_name = strcat('Audio ListenerEEG Logstic Regresssion r^2 Result-total-',band_name{band_select},'-imagesc-',type{type_select},'.jpg');
        title(save_name(1:end-4));
        saveas(gcf,save_name);
        close
        
        p = pwd;
        cd(p(1:end-(length(type{type_select})+1)));
        
    end
    % file
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end