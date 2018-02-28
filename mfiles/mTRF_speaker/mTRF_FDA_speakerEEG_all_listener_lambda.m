%% mTRF - speaker listener timelag plot
% mTRF timelog plot for speaker-listener-new-experiment data
% Experiment date : 2017.7.5
% purpose: mTRF validation
% by:LJW
%% initial topoplot
listener_chn= [1:32 34:42 44:59 61:63];
% speaker_chn = [2 5 10 28 40 50];
% speaker_chn = [1:32 34:42 44:59 61:63];
% speaker_chn = [17:21 26:30 36:40];
speaker_chn = 28;
% speaker_chn = [9:11 18:20 27:29];
load('E:\DataProcessing\label66.mat');
layout = 'E:\DataProcessing\easycapm1.mat';


%% listener
listener_num = 20;
% lambda_para = [0 5 10 15 20];
%% timelag

% timelag = -200:25:500;
Fs = 64;
timelag = -250:(1000/Fs):500;
lambda_para = 5;


for lambda_num = 1 : length(lambda_para)
    lambda = 2^lambda_para(lambda_num);
    
    mkdir(strcat('lambda',num2str(lambda)));
    cd(strcat('lambda',num2str(lambda)));
    
    decoding_acc_attended_all_listener  = zeros(listener_num,length(timelag));
    decoding_acc_unattended_all_listener  = zeros(listener_num,length(timelag));
    decoding_acc_allDecoder_all_listener  = zeros(listener_num,length(timelag));
    Decoding_acc_attend_ttest_result_all_listener  = zeros(listener_num,length(timelag));
    Decoding_acc_unattend_ttest_result_all_listener  = zeros(listener_num,length(timelag));
    Decoding_acc_allDecoder_ttest_result_all_listener  = zeros(listener_num,length(timelag));
    
    
    for chn = 1:length(speaker_chn)
        
        chn_file_name = strcat(num2str(chn),'-',label66{speaker_chn(chn)});
        mkdir(chn_file_name);
        cd(chn_file_name);
        
        for i = 1 : listener_num
            
            
            %% initial
            decoding_acc_attended = zeros(1,length(timelag));
            decoding_acc_unattended = zeros(1,length(timelag));
            decoding_acc_all = zeros(1,length(timelag));
            Decoding_acc_attend_ttest_result = zeros(1,length(timelag));
            Decoding_acc_unattend_ttest_result = zeros(1,length(timelag));
            Decoding_acc_all_ttest_result = zeros(1,length(timelag));
            
            %% data name
            if i < 10
                file_name = strcat('listener10',num2str(i));
            else
                file_name = strcat('listener1',num2str(i));
            end
            
%             bandName = strcat(' 64Hztheta sound from wav l', file_name(2:end),' lambda',num2str(lambda),' 10-55s');
            bandName = strcat(' 64Hz broadband speakerEEG mTRF Listener',file_name(end-2:end),' lambda',num2str(lambda),' 10-55s');
            
            mkdir(file_name);
            cd(file_name);
            
            
            %%  mTRF plot
            % p = pwd;
            %         p = strcat('E:\DataProcessing\speaker-listener_experiment\Decoding Result\mTRF\lambda',num2str(lambda));
            p = strcat('E:\DataProcessing\speaker-listener_experiment\Decoding Result\mTRF_speaker\Listener-Speaker\broadband reverse for fisher\',file_name);
            % category = 'mTRF';
            %     category = '64Hz 2-8Hz lambda32 10-55s';
            category =chn_file_name;
            
            
            for  j = 1 : length(timelag)
                % load data
                datapath = strcat(p,'\',category);
                %             dataName = strcat('mTRF_sound_EEG_result+',num2str(timelag(j)),'ms',bandName,'.mat');
%                 dataName = strcat('mTRF_sound_EEG_result across timelags-',file_name,'-',label66{speaker_chn(chn)},'.mat');
                dataName = strcat('mTRF_speakerEEG_listenerEEG_result+',label66{speaker_chn(chn)},'-timelag',num2str(timelag(j)),'ms',bandName,'.mat');

                load(strcat(datapath,'\',dataName));
                
                decoding_acc_attend_temp = zeros(1,length(fisher_feature_test_Attend_all_story));
                decoding_acc_unattend_temp = zeros(1,length(fisher_feature_test_Attend_all_story));
                decoding_acc_all_temp = zeros(1,length(fisher_feature_test_Attend_all_story));
                
                for test_story = 1 : length(fisher_feature_test_Attend_all_story)
                    fisher_feature_train_allDecoder = [fisher_feature_train_Attend_all_story{test_story};fisher_feature_train_Unattend_all_story{test_story}];
                    fisher_feature_test_allDecoder = [fisher_feature_test_Attend_all_story{test_story};fisher_feature_test_Unattend_all_story{test_story}];
                    % FDA train
                    [W_attend, I_attend] = FDA_TRAIN(fisher_feature_train_Attend_all_story{test_story},fisher_label_train_all_story{test_story});
                    [W_unattend, I_unattend] = FDA_TRAIN(fisher_feature_train_Unattend_all_story{test_story},fisher_label_train_all_story{test_story});
                    [W_all, I_all] = FDA_TRAIN(fisher_feature_train_allDecoder,fisher_label_train_all_story{test_story});
                    % FDA test
                    [label_attend, values_attend] = FDA_TEST(fisher_feature_test_Attend_all_story{test_story},W_attend,I_attend);
                    if label_attend == fisher_label_test_all_story{test_story}
                        decoding_acc_attend_temp(test_story) = 1;
                    else
                        decoding_acc_attend_temp(test_story) = 0;
                    end
                    
                    
                    [label_unattend, values_unattend] = FDA_TEST(fisher_feature_test_Unattend_all_story{test_story},W_unattend,I_unattend);
                    if label_unattend == fisher_label_test_all_story{test_story}
                        decoding_acc_unattend_temp(test_story) = 1;
                    else
                        decoding_acc_unattend_temp(test_story) = 0;
                    end
                    
                    
                    [label_all, values_all] = FDA_TEST(fisher_feature_test_allDecoder,W_all,I_all);
                    if label_all == fisher_label_test_all_story{test_story}
                        decoding_acc_all_temp(test_story) = 1;
                    else
                        decoding_acc_all_temp(test_story) = 0;
                    end
                    
                end
                
                
                %decoding accuracy
                decoding_acc_attended(j)= sum(decoding_acc_attend_temp)/length(fisher_feature_test_Attend_all_story);
                decoding_acc_unattended(j) = sum(decoding_acc_unattend_temp)/length(fisher_feature_test_Attend_all_story);
                decoding_acc_all(j) = sum(decoding_acc_all_temp)/length(fisher_feature_test_Attend_all_story);
                
            end
            
            
            %% timelag plot
            
            figure; plot(timelag,decoding_acc_attended*100,'r','LineWidth',2);
            hold on; plot(timelag,decoding_acc_unattended*100,'b','LineWidth',2);
            hold on; plot(timelag,decoding_acc_all*100,'g','LineWidth',2);
            xlabel('Times(ms)');
            ylabel('Decoding accuracy(%)')
            saveName3 =strcat('Decoding-Accuracy across timelags using mTRF method',bandName,'.jpg');
            title(saveName3(1:end-4));
            legend('Attended decoder','Unattended decoder','All decoder','Location','northeast');ylim([30,100]);
            saveas(gcf,saveName3);
            close
            
            decoding_acc_attended_all_listener(i,:) = decoding_acc_attended;
            decoding_acc_unattended_all_listener(i,:) = decoding_acc_unattended;
            decoding_acc_allDecoder_all_listener(i,:) = decoding_acc_all;
            
            
            % save data
            saveName = strcat('mTRF_speaker_EEG_result across timelags-',file_name,'.mat');
            %     saveName = strcat('mTRF_sound_EEG_result.mat');
            save(saveName,'decoding_acc_attended','decoding_acc_unattended','decoding_acc_all');
            
            p = pwd;
            cd(p(1:end-(length(file_name)+1)));
        end
    end
    
    %% all listener
    % save data
    saveName ='mTRF_speaker_EEG_result across timelags all listener.mat';
    %     saveName = strcat('mTRF_sound_EEG_result.mat');
    save(saveName, 'decoding_acc_attended_all_listener',...
        'decoding_acc_unattended_all_listener',...
        'decoding_acc_allDecoder_all_listener');
    
    
    p = pwd;
    temp_data_path = strcat('lambda',num2str(lambda));
    cd(p(1:end-(length(temp_data_path)+1)));
end