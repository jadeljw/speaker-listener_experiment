%% LR_Audio_ListenerEEG
% purpose: use logistic regression
% to find the relation between r value and attend target
% Attend A ->1
% Attend
% LJW
% 2018.3.11

band_name = {'delta','theta','alpha'};
% type = {'diff','total'};

% band_name = {'delta'};

% band_name  = {'alpha', 'alpha_hilbert', 'beta', 'beta_hilbert', 'broadband', 'broadband_hilbert',...
%     'delta', 'delta_hilbert', 'gamma', 'gamma_hilbert', 'theta', 'theta_hilbert'};
% band_name  = {'broadband','broadband_hilbert',...
%     'delta', 'delta_hilbert', 'gamma', 'gamma_hilbert', 'theta', 'theta_hilbert'};

type = {'total'};
% listener_valid = [1:2 4:9 11:16 18:20];
listener_valid = [1:20];
listener_num = length(listener_valid);
story_num = 28;
sig_thr = 0.05;

% range_for_band = [0.1 0.11 0.11 0.13]; % 99%
% range_for_band = [0.09 0.08 0.09 0.09]; % 95%
% range_for_band = [0.08 0.07 0.08 0.08]; % 90%
% range_for_band = [0.07 0.07 0.07 0.07]; % surrogate
%%
mkdir('Speaker ListenerEEG valid');
cd('Speaker ListenerEEG valid');

%% new order
load('E:\DataProcessing\Label_and_area.mat');

select_area = 'Small_area';
chn_area_labels = fieldnames(eval(select_area));

select_label = 1:length(chn_area_labels);
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

% % combine similiar channels together
% load('E:\DataProcessing\Label_and_area.mat','order');
% new_speaker_order = order;


%% timelag
Fs = 64;
timelag = -500 : 1000/Fs : 500;
label_select = 1 : round(length(timelag)/8) :length(timelag);

R_squared_mat_speaker = zeros(length(chn_area_labels),listener_num,length(timelag));
p_value_mat_speaker = zeros(length(chn_area_labels),listener_num,length(timelag));
p_value_sig_mat_speaker = zeros(length(chn_area_labels),listener_num,length(timelag));


for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    
    for type_select = 1 : length(type)
        
        %         mkdir(type{type_select});
        %         cd(type{type_select});
        

        for chn_area_select = select_label
            
            %% initial
            R_squared_mat = zeros(listener_num,length(timelag));
            p_value_mat = zeros(listener_num,length(timelag));
            p_value_sig_mat = zeros(listener_num,length(timelag));
            disp(chn_area_labels{chn_area_select});
            speaker_chn = eval(strcat(select_area,'.',chn_area_labels{chn_area_select}));
            mkdir(chn_area_labels{chn_area_select});
            cd(chn_area_labels{chn_area_select});
            
            for time_point = 1 : length(timelag)
                
                
                attend_target_total = zeros(listener_num,story_num);
                
                % total
                if strcmp(type{type_select},'total') == 1
                    r_value_mat_total = zeros(listener_num,story_num,4); % listener * story * feature
                end
                
                % difference
                if strcmp(type{type_select},'diff') == 1
                    r_value_mat_total = zeros(listener_num,story_num,2); % listener * story * feature
                end
                
                
                % initial
                weights_attend_mat = zeros(listener_num,length(listener_chn));
                weights_unattend_mat = zeros(listener_num,length(listener_chn));
                
                for listener_select = 1 : listener_num
                    
                    %% listener name
                    if listener_valid(listener_select) < 10
                        file_name = strcat('listener10',num2str(listener_valid(listener_select)));
                    else
                        file_name = strcat('listener1',num2str(listener_valid(listener_select)));
                    end
                    
                    %                 mkdir(file_name);
                    %                 cd(file_name);
                    %                     disp(file_name);
                    
                    
                    %% band name
                    %         lambda = 2.^(0:5:20);
                    lambda = 2.^ 10;
                    %     band_name = strcat(' 64Hz delta speakerEEG mTRF Listener',dataName(1:3),' lambda',num2str(lambda),' 10-55s');
                    
                    
                    %             disp(strcat(timelag(time_point),'ms'));
                    
                    %% load r value data
                    %                     load(strcat('E:\DataProcessing\speaker-listener_experiment\Logistic Regression\Speaker-listenerEEG\',...
                    %                         band_file_name,'\',file_name,'\',chn_file_name,'\mTRF_speakerEEG_listenerEEG_result+',label66{speaker_chn(chn)},...
                    %                         '-timelag',num2str(timelag(time_point)),'ms-',band_file_name,'.mat'));
                    data_name = strcat('mTRF_speakerEEG_listenerEEG_result-',chn_area_labels{chn_area_select},'-timelag',num2str(timelag(time_point)),'ms-',band_file_name,'.mat');
                    %                     data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Logistic Regression\4-surrogate\Speaker ListenerEEG zscore surrogate2\',...
                    %                         band_file_name,'\',file_name,'\',chn_area_labels{chn_area_select},'\');
                    
                    %                     data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Logistic Regression\Speaker ListenerEEG_area zscore\',...
                    %                         band_file_name,'\',file_name,'\',chn_area_labels{chn_area_select},'\');
                    
                    data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\Speaker-listenerEEG\0-original r value\raw r value with trans\',...
                        band_file_name,'\',file_name,'\',chn_area_labels{chn_area_select},'\');
                    
                    load(strcat(data_path,data_name));
                    
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
                    
                    r_value_mat_total(listener_select,:,:) = r_value_mat;
                    attend_target_total(listener_select,:) = attend_target_mat;
                    %% logtistic regression
                    %             disp('Logtistic Regression...')
                    %             tic;
                    glm = fitglm(r_value_mat,attend_target_mat,'distr','binomial');
                    %             toc;
                    
                    %% save result
                    R_squared_mat(listener_select,time_point) = glm.Rsquared.Adjusted;
                    weights_attend_mat(listener_select,:) =  squeeze(mean(train_mTRF_attend_w_total,3));
                    weights_unattend_mat(listener_select,:) =  squeeze(mean(train_mTRF_unattend_w_total,3));
                    
                    %% model test
                    d = devianceTest(glm);
                    p_value_mat(listener_select,time_point) =  d.pValue(2);
                    
                    if  p_value_mat(listener_select,time_point) < sig_thr
                        p_value_sig_mat(listener_select,time_point) = 1;
                    end
                    
                    if glm.Rsquared.Adjusted == 1
                        %                 plot(r_value_mat,'*','LineWidth',2);
                        imagesc(r_value_mat);colorbar;
                        data_name = strcat(file_name,'+',num2str(timelag(time_point)),'ms.jpg');
                        title(data_name(1:end-4));
                        xticks(1:4);
                        xticklabels({'Attend-A','Attend-B','Unattend-A','Unattend-B'});
                        %                         xticklabels({'Attend','Unattend'});
                        saveas(gcf,data_name);
                        close
                    end
                    
                    %
                    
                end
                
                % output
                r_time_point_average = mean(R_squared_mat(:,time_point));
                R_squared_time_point = R_squared_mat(:,time_point);
                disp(strcat('Timelag:',num2str(timelag(time_point)),'ms'));
                disp(strcat('R squared:',num2str(r_time_point_average)));
                disp('********************');
                
                %                 if abs(r_time_point_average) > range_for_band(band_select)
                %                     % r_mat save
                %                     R_squared_glm = r_time_point_average;
                %                     save_name2 = strcat('mTRF_speakerEEG_listenerEEG_result-timelag',num2str(timelag(time_point)),'ms-',band_file_name,'.mat');
                %                     save(save_name2,'r_value_mat_total','R_squared_glm','attend_target_total','R_squared_time_point');
                %                     %
                %                     %                     % topoplot
                %                     %
                %                     %                     set(gcf,'outerposition',get(0,'screensize'));
                %                     %
                %                     %                     % attend
                %                     %                     subplot(121);
                %                     %                     U_topoplot(abs(mean(weights_attend_mat,1)'),layout,label66(listener_chn));colorbar('location','EastOutside');
                %                     %                     title('Attended');
                %                     %
                %                     %
                %                     %                     % unattend
                %                     %                     subplot(122);
                %                     %                     U_topoplot(abs(mean(weights_unattend_mat,1)'),layout,label66(listener_chn));colorbar('location','EastOutside');
                %                     %                     title('Unattended');
                %                     %
                %                     %                     save_name = strcat('mTRF-speakerEEG-listenerEEG-result-timelag',num2str(timelag(time_point)),'ms-',band_file_name,'.jpg');
                %                     %                     suptitle(save_name(1:end-4));
                %                     %                     saveas(gcf,save_name);
                %                     %
                %                     %                     close;
                %
                %                 end
                %
                
            end
            
            
            %% plot
            % plot
            
            for listener_select = 1 : listener_num
                set(gcf,'outerposition',get(0,'screensize'));
                subplot(211);
                plot(timelag,R_squared_mat(listener_select,:),'k','LineWidth',3);
                ylim([-0.2 0.8]);
                xlabel('timelag(ms)');
                ylabel('R^2 value');
                title('R^2 value');
                %         save_name = strcat('Audio listenerEEG R^2 value-',band_name{band_select},'-listener No.',num2str(listener_select),'-plot.jpg');
                %         title(save_name(1:end-4));
                %         saveas(gcf,save_name);
                %
                % plot p value
                subplot(212);
                plot(timelag,-log10(p_value_mat(listener_select,:)),'k','LineWidth',3);
                hold on;plot([timelag(1) timelag(end)],[1.3 1.3],'b--');
                hold on;plot([timelag(1) timelag(end)],[2 2],'r--');
                legend('p value','<0.05','<0.01')
                ylim([0 8]);
                xlabel('timelag(ms)');
                ylabel('-log10(p) value');
                title('-log10(p) value');
                
                save_name = strcat('Speaker listenerEEG-',band_name{band_select},'-listener No.',num2str(listener_select),'-plot.jpg');
                suptitle(save_name(1:end-4));
                saveas(gcf,save_name);
                
                close
            end
            %             % imagesc
            
            set(gcf,'outerposition',get(0,'screensize'));
            imagesc(R_squared_mat);colorbar;
            caxis([-0.1 1]);
            %     colormap('jet');
            xticks(label_select);
            xticklabels(timelag(label_select));
            
            save_name = strcat('Speaker ListenerEEG Logstic Regresssion r^2 Result-',chn_area_labels{chn_area_select},'-',band_name{band_select},'-imagesc-',type{type_select},'.jpg');
            title(save_name(1:end-4));
            saveas(gcf,save_name);
            close
            %
            
            % record into mat
            R_squared_mat_speaker(chn_area_select,:,:) = R_squared_mat;
            p_value_mat_speaker(chn_area_select,:,:) = p_value_mat;
            p_value_sig_mat_speaker(chn_area_select,:,:) = p_value_sig_mat;
            
            
            
            % plot mean result
            set(gcf,'outerposition',get(0,'screensize'));
            plot(timelag,mean(R_squared_mat),'k','LineWidth',3);
            xlabel('timelag(ms)');
            ylabel('R^2');
            save_name1 = strcat('Speaker ListenerEEG Logstic Regresssion r^2 Result-',band_name{band_select},'-mean.jpg');
            title(save_name1(1:end-4));
            saveas(gcf,save_name1);
            close
            
            % plot count result
            set(gcf,'outerposition',get(0,'screensize'));
            plot(timelag,sum(p_value_sig_mat),'k','LineWidth',3);
            ylim([0 20]);
            xlabel('timelag(ms)');
            ylabel('significant trail count');
            save_name1 = strcat('Speaker ListenerEEG Logstic Regresssion significant p value Result-',band_name{band_select},'-mean.jpg');
            title(save_name1(1:end-4));
            saveas(gcf,save_name1);
            close
            
            
            % file
            p = pwd;
            cd(p(1:end-(length(chn_area_labels{chn_area_select})+1)));
        end
        
        % imagesc
        %         set(gcf,'outerposition',get(0,'screensize'));
        %         imagesc(squeeze(mean(R_squared_mat_speaker,2)));colorbar;
        %         caxis([-0.04 0.1]);
        %         %     colormap('jet');
        %         xticks(label_select);
        %         xticklabels(timelag(label_select));
        %         yticks(1:length(chn_area_labels));
        %         yticklabels(chn_area_labels);
        %         xlabel('timelag(ms)');
        %         ylabel('Speaker Channels');
        %         save_name = strcat('Speaker ListenerEEG Logstic Regresssion Large r^2 Result-total-',band_name{band_select},'-imagesc-',type{type_select},'-',select_area,'.jpg');
        %         title(save_name(1:end-4));
        %         saveas(gcf,save_name);
        %         close
        
        
        
        % save data
        save_name = strcat('Speaker ListenerEEG Logstic Regresssion r^2 Result-total-',band_name{band_select},'-',type{type_select},'-',select_area,'.mat');
        save(save_name,'R_squared_mat_speaker','p_value_mat_speaker','p_value_sig_mat_speaker');
        %
        %         p = pwd;
        %         cd(p(1:end-(length(type{type_select})+1)));
        
    end
    % file
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end