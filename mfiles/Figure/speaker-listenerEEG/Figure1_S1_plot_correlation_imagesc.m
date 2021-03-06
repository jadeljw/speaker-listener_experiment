%% LR_Audio_ListenerEEG
% purpose: use logistic regression
% to find the relation between r value and attend target
% Attend A ->1
% Attend
% LJW
% 2018.3.11
mkdir('Speaker-listenerEEG 99.9%');
cd('Speaker-listenerEEG 99.9%')

band_name = {'alpha', 'alpha_hilbert', 'beta', 'beta_hilbert', 'broadband',...
    'delta', 'delta_hilbert', 'theta', 'theta_hilbert'};

listener_num = 20;
story_num = 28;
range_total  = [0.0066	0.00822	0.003516	0.005964	0.00415	0.0074	0.0097	0.004495	0.0099];

%% new order
load('E:\DataProcessing\Label_and_area.mat');

select_area = 'Small_area';
chn_area_labels = fieldnames(eval(select_area));

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
Correlation_mat.attendDecoder_attend = zeros(length(chn_area_labels),listener_num,story_num,length(timelag)); % speaker area * listener * story * time-lag
Correlation_mat.unattendDecoder_unattend = zeros(length(chn_area_labels),listener_num,story_num,length(timelag));
Correlation_mat.attendDecoder_unattend = zeros(length(chn_area_labels),listener_num,story_num,length(timelag));
Correlation_mat.unattendDecoder_attend = zeros(length(chn_area_labels),listener_num,story_num,length(timelag));

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    mkdir(band_file_name);
    cd(band_file_name);
    
    range_select = range_total(band_select);
    
    %% load data
        data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Figure\0-raw r value mat\Speaker-listenerEEG\',band_file_name);
%     data_path = strcat('E:\DataProcessing\speaker-listener_experiment\Surrogate\0-raw r value\surrogate1\',band_file_name);
    data_name = 'Correlation_mat.mat';
    load(strcat(data_path,'\',data_name));
    
    %% plot
    plot_name = fieldnames(Correlation_mat);
    for plot_select = 1 : length(plot_name)
        data_name = strcat('Correlation_mat.',plot_name{plot_select});
        data_for_imagesc = eval(strcat('squeeze(mean(mean(',data_name,',3),2));'));
        
        % imagesc
        set(gcf,'outerposition',get(0,'screensize'));
        imagesc((data_for_imagesc> range_select).* data_for_imagesc);colorbar;
%         caxis([-0.01 0.01]);
        %     colormap('jet');
        xticks(label_select);
        xticklabels(timelag(label_select));
        yticks(1:length(chn_area_labels));
        yticklabels(chn_area_labels);
        xlabel('timelag(ms)');
        ylabel('Speaker Channels');
        save_name = strcat('Raw r value-',band_name{band_select},'-imagesc-',plot_name{plot_select},'-',select_area,'.jpg');
        title(save_name(1:end-4));
        saveas(gcf,save_name);
        close
        
        % histogram
%         %% histgram
%         h = histogram(data_for_imagesc);
%         h.BinLimits = [-0.01 0.01];
%         ylabel('count');
%         xlabel('R value');
%         title(strcat(band_file_name,'-',plot_name{plot_select}));
%         
%         for i = 1 : length(h.BinCounts)
%             if sum(h.BinCounts(1:i))/sum(h.BinCounts) > 0.9
%                 hold on; plot([h.BinEdges(i),h.BinEdges(i)],[h.BinEdges(i),max(h.BinCounts)],'y','LineWidth',2);
%                 legend('Count','90%');
%                 disp(strcat('90% :',num2str(h.BinEdges(i))));
%                 break
%             end
%         end
%         
%         for i = 1 : length(h.BinCounts)
%             if sum(h.BinCounts(1:i))/sum(h.BinCounts) > 0.95
%                 hold on; plot([h.BinEdges(i),h.BinEdges(i)],[h.BinEdges(i),max(h.BinCounts)],'r','LineWidth',2);
%                 legend('Count','90%','95%');
%                 disp(strcat('95% :',num2str(h.BinEdges(i))));
%                 break
%             end
%         end
%         
%         for i = 1 : length(h.BinCounts)
%             if sum(h.BinCounts(1:i))/sum(h.BinCounts) > 0.99
%                 hold on; plot([h.BinEdges(i),h.BinEdges(i)],[h.BinEdges(i),max(h.BinCounts)],'b','LineWidth',2);
%                 legend('Count','90%','95%','99%');
%                 disp(strcat('99% :',num2str(h.BinEdges(i))));
%                 break
%             end
%         end
        
        
%         save
%         save_name = strcat(band_file_name,'-',plot_name{plot_select},'.jpg');
%         saveas(gcf,save_name);
%         close;
    end
    
    % file
    
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
end