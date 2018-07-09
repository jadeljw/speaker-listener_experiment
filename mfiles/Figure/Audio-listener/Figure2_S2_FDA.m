%% LR_Audio_ListenerEEG
% purpose: use logistic regression
% to find the relation between r value and attend target
% Attend A ->1
% Attend
% LJW
% 2018.3.11

band_name  = {'alpha', 'alpha_hilbert', 'beta', 'beta_hilbert', 'broadband'...
    'delta', 'delta_hilbert', 'theta', 'theta_hilbert'};
% band_name  = {'broadband','broadband_hilbert',...
%     'delta', 'delta_hilbert', 'gamma', 'gamma_hilbert', 'theta', 'theta_hilbert'};

% listener_valid = [1:2 4:9 11:16 18:20];
listener_valid = 1:20;
listener_num = length(listener_valid);
story_num = 28;
%%
mkdir('FDA');
cd('FDA');

%% new order
load('E:\DataProcessing\Label_and_area.mat');

select_area = 'Small_area';
chn_area_labels = fieldnames(eval(select_area));


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

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    
    
    %% initial
    %     Acc_mean_mat = zeros(length(timelag));
    Acc_mat_total = zeros(listener_num,story_num,length(timelag)); % 1 for correct / 0 for uncorrect
    fisher_value_total =  zeros(listener_num,story_num,length(timelag));
    
    %% file
    mkdir('time point individual');
    cd('time point individual');
    %
    for time_point = 1 : length(timelag)
        
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
            lambda = 2.^ 10;
            
   
            %% load r value data
            data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\0-original r value\Audio-listenerEEG\',...
                band_name{band_select},'\',file_name,'\');
            data_name = strcat('mTRF_Audio_listenerEEG_result-timelag',num2str(timelag(time_point)),'ms-',band_name{band_select},'.mat');
            
            load(strcat(data_path,data_name));
            
            %% combine r value
            r_value_mat = [recon_AttendDecoder_AudioA_corr recon_AttendDecoder_AudioB_corr recon_UnattendDecoder_AudioA_corr recon_UnattendDecoder_AudioB_corr];
            %                 r_value_mat = [recon_AttendDecoder_SpeakerA_corr recon_AttendDecoder_SpeakerB_corr];
            attend_target_mat = attend_target_num'; % 1 -> attend A; 0 -> attend B
            
            
            %% FDA
            for story_test = 1 : story_num
                story_train = setdiff(1:story_num,story_test);
                
                [WEIGHTS,INTERCEPT]=FDA_TRAIN(r_value_mat(story_train,:)',attend_target_mat(story_train,:)');
                [LABEL_TEST, Fisher_Values]=FDA_TEST(r_value_mat(story_test,:)',WEIGHTS,INTERCEPT);
                
                % record into mat
                fisher_value_total(listener_select,story_test,time_point) = Fisher_Values;
                if LABEL_TEST == attend_target_mat(story_test)
                    Acc_mat_total(listener_select,story_test,time_point) = 1; % 1 for correct / 0 for uncorrect
                else
                    Acc_mat_total(listener_select,story_test,time_point) = 0;
                end
                
            end
            
            
            acc_listener_time_point_average = squeeze(mean(Acc_mat_total(:,:,time_point),2));
            %                 if acc_listener_time_point_average < 0.3 || acc_listener_time_point_average >0.7
            %                      disp('####################');
            %                     disp(strcat('Listener',num2str(listener_select)));
            %                     disp(strcat('Timelag:',num2str(timelag(time_point)),'ms'));
            %                     disp(strcat('Acc:',num2str(acc_listener_time_point_average * 100),'%'));
            %                     disp('####################');
            %                 end
            
        end
        
        %% plot
        set(0,'DefaultFigureVisible', 'off');
        set(gcf,'outerposition',get(0,'screensize'));
        plot(1:listener_num,100 * acc_listener_time_point_average,'k','LineWidth',2);
        hold on;plot([1 20],[50 50],'b--')
        
        ylim([0 100]);
        
        xlabel('listener No.');
        ylabel('ACC %');
        save_name = strcat('Audio ListenerEEG FDR Result-',band_name{band_select},'-imagesc-',select_area,'timelag',num2str(timelag(time_point)),'ms.jpg');
        title(save_name(1:end-4));
        saveas(gcf,save_name);
        
        save_name = strcat('Audio ListenerEEG FDR Result-',band_name{band_select},'-imagesc-',select_area,'timelag',num2str(timelag(time_point)),'ms.fig');
        saveas(gcf,save_name);
        close
%         
        %% save result
        disp('********************');
        % output
        acc_time_point_average = squeeze(mean(mean(Acc_mat_total(:,:,time_point),2),1));
        disp(strcat('Timelag:',num2str(timelag(time_point)),'ms'));
        disp(strcat('Acc:',num2str(acc_time_point_average * 100),'%'));
        disp('********************');
        
    end
    p = pwd;
    cd(p(1:end-(length('time point individual')+1)));
    
    
    
    
    Acc_mat_mean = squeeze(mean(mean(Acc_mat_total,2),1));
    
    % imagesc
    set(gcf,'outerposition',get(0,'screensize'));
    plot(timelag,100 * Acc_mat_mean,'k','LineWidth',2);
    hold on;plot([timelag(1) timelag(end)],[50 50],'b--')
    %     caxis([0.4 0.8]);
    %     colormap('jet');
%     xticks(label_select);
%     xticklabels(timelag(label_select));
%     yticks(1:length(chn_area_labels));
%     yticklabels(chn_area_labels);
    xlabel('timelag(ms)');
    ylabel('ACC %');
    save_name = strcat('1-Audio ListenerEEG FDR Result-total-',band_name{band_select},'-imagesc-',select_area,'.png');
    title(save_name(1:end-4));
    saveas(gcf,save_name);
    
    save_name = strcat('1-Audio ListenerEEG FDR Result-total-',band_name{band_select},'-imagesc-',select_area,'.fig');
    saveas(gcf,save_name);
    close
    
    
    % save data
    save_name = strcat('1-Audio ListenerEEG FDR Result-total-',band_name{band_select},'-',select_area,'.mat');
    save(save_name,'Acc_mat_total','Acc_mat_mean');
    %
    
    
    
    % file
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end