%% LR_Audio_ListenerEEG
% purpose: use logistic regression
% to find the relation between r value and attend target
% Attend A ->1
% Attend
% LJW

mkdir('GLM');
cd('GLM')


band_name = {'alpha', 'alpha_hilbert', 'beta', 'beta_hilbert', 'broadband',...
    'delta', 'delta_hilbert', 'theta', 'theta_hilbert'};

listener_num = 20;
story_num = 28;
bin_num = 40;
surrogate_set = 1:10;


%% new order
load('E:\DataProcessing\Label_and_area.mat');

select_area = 'Small_area';
chn_area_labels = fieldnames(eval(select_area));
plot_area_order = [4 6 5 2 1 3 7 8 9];

%% colormap
load('E:\DataProcessing\colormap_blue_red.mat');

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

%% timelag
Fs = 64;
timelag = -500 : 1000/Fs : 500;
label_select = 1 : round(length(timelag)/8) :length(timelag);

%% initial
Correlation_mat_total.AttendAcc = zeros(length(surrogate_set),length(chn_area_labels),length(timelag)); % speaker area * listener * story * time-lag
Correlation_mat_total.Concentration = zeros(length(surrogate_set),length(chn_area_labels),length(timelag));
Correlation_mat_total.Difficulty = zeros(length(surrogate_set),length(chn_area_labels),length(timelag));
Correlation_mat_total.Familiar = zeros(length(surrogate_set),length(chn_area_labels),length(timelag));

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    %     mkdir(band_file_name);
    %     cd(band_file_name);
    disp(band_file_name);
    
    
    %% load raw data
    data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\6-GLM\',band_file_name);
    %     data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Surrogate\0-raw r value\surrogate10\',band_file_name);
    data_name_raw = strcat('Correlation between R^2-',band_file_name,'-unattendDecoder_attend.mat');
    load(strcat(data_path,'\',data_name_raw));
    data_raw = GLM_Rsquared_mat;
    
    %% load surrogate data
    for surrogate_select  = 1 : length(surrogate_set)
        %     data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\0-correlation mat\',band_file_name);
        data_path = strcat(' E:\DataProcessing\speaker-listener_experiment\Surrogate\3-GLM\surrogate',num2str(surrogate_set(surrogate_select)),'\',band_file_name);
        data_name = strcat('Correlation between R^2-',band_file_name,'.mat');
        load(strcat(data_path,'\',data_name));
        eval(strcat('data_surrogate',num2str(surrogate_set(surrogate_select)),' = GLM_Rsquared_mat;'));
    end
    
    %% plot
    plot_name = fieldnames(GLM_Rsquared_mat);
    %     plot_name = {'attendDecoder','unattendDecoder'};
    
    
    for plot_select = 1 : 4
        disp(plot_name{plot_select});
        % raw data
        data_name_raw = strcat('data_raw.',plot_name{plot_select});
        data_for_imagesc = eval(data_name_raw);
        
        % surrogate data
        for surrogate_select  = 1 : length(surrogate_set)
            data_name_surrogate = strcat('data_surrogate',num2str(surrogate_set(surrogate_select)),'.',plot_name{plot_select});
            data_for_imagesc_surrogate = eval(data_name_surrogate);
            
            % merge into total mat
            eval(strcat('Correlation_mat_total.',plot_name{plot_select},'(surrogate_select,:,:,:)=  data_for_imagesc_surrogate;'));
            
            % individual plot
%             eval(strcat('data_surrogate_imagesc',num2str(surrogate_set(surrogate_select)),'=data_for_imagesc_surrogate;'));
        end
        
        set(gcf,'outerposition',get(0,'screensize'));
        eval(strcat('subplot(22',num2str(plot_select),');'));
        data_total_temp = eval(strcat('Correlation_mat_total.',plot_name{plot_select}));
        
        % plot surrogate
        h_surrogate = histogram(data_total_temp,bin_num,'Normalization','probability');
        
        
        % plot real
        hold on; h_real = histogram(data_for_imagesc,bin_num,'Normalization','probability','FaceAlpha',0.2);
        
        
        % print out
        for i = 1 : length(h_surrogate.BinCounts)
            if sum(h_surrogate.BinCounts(1:i))/sum(h_surrogate.BinCounts) > 0.99
                %                 hold on; plot([h_surrogate.BinEdges(i),h_surrogate.BinEdges(i)],[h_surrogate.BinEdges(i),0.1],'b','LineWidth',2);
                disp(strcat('surrogate 99% :',num2str(h_surrogate.BinEdges(i))));
                break
            end
        end
        % print out
        for i = 1 : length(h_surrogate.BinCounts)
            if sum(h_surrogate.BinCounts(1:i))/sum(h_surrogate.BinCounts) > 0.995
                %                 hold on; plot([h_surrogate.BinEdges(i),h_surrogate.BinEdges(i)],[h_surrogate.BinEdges(i),0.1],'b','LineWidth',2);
                disp(strcat('surrogate 99.5% :',num2str(h_surrogate.BinEdges(i))));
                break
            end
        end
        % print out
        for i = 1 : length(h_surrogate.BinCounts)
            if sum(h_surrogate.BinCounts(1:i))/sum(h_surrogate.BinCounts) > 0.999
                %                 hold on; plot([h_surrogate.BinEdges(i),h_surrogate.BinEdges(i)],[h_surrogate.BinEdges(i),0.1],'b','LineWidth',2);
                disp(strcat('surrogate 99.9% :',num2str(h_surrogate.BinEdges(i))));
                break
            end
        end
        
        
        % print out
        for i = 1 : length(h_real.BinCounts)
            if sum(h_real.BinCounts(1:i))/sum(h_real.BinCounts) > 0.99
                %                 hold on; plot([h_real.BinEdges(i),h_real.BinEdges(i)],[h_real.BinEdges(i),0.1],'r','LineWidth',2);
                disp(strcat('real 99% :',num2str(h_real.BinEdges(i))));
                break
            end
        end
        
        % print out
        for i = 1 : length(h_real.BinCounts)
            if sum(h_real.BinCounts(1:i))/sum(h_real.BinCounts) > 0.995
                %                 hold on; plot([h_real.BinEdges(i),h_real.BinEdges(i)],[h_real.BinEdges(i),0.1],'r','LineWidth',2);
                disp(strcat('real 99.5% :',num2str(h_real.BinEdges(i))));
                break
            end
        end
        
        % print out
        for i = 1 : length(h_real.BinCounts)
            if sum(h_real.BinCounts(1:i))/sum(h_real.BinCounts) > 0.999
                %                 hold on; plot([h_real.BinEdges(i),h_real.BinEdges(i)],[h_real.BinEdges(i),0.1],'r','LineWidth',2);
                disp(strcat('real 99.9% :',num2str(h_real.BinEdges(i))));
                break
            end
        end
        
        
        disp('*********************************************************');
        
        %     xlim([-0.012 0.012]);
        %         legend('surrogate','99%','real','99%');
        legend('surrogate','real');
        ylabel('Probability');
        title(plot_name{plot_select});
        
        
    end
    save_name = strcat('GLM surrogate-',band_name{band_select},'-histogram.jpg');
    suptitle(save_name(1:end-4));
    saveas(gcf,save_name);
    
    save_name = strcat('GLM difference surrogate-',band_name{band_select},'-histogram.fig');
    saveas(gcf,save_name);
    close
    
    
    % file
    
    %     p = pwd;
    %     cd(p(1:end-(length(band_file_name)+1)));
end