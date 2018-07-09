% S3_plot_mTRF_GFP

% by LJW
% 2018.6.8
% ref:
% Crosse, M. J., Di Liberto, G. M., Bednar, A., & Lalor, E. C. (2016).
% The Multivariate Temporal Response Function (mTRF) Toolbox: A MATLAB Toolbox for Relating Neural Signals to Continuous Stimuli.
% Frontiers in Human Neuroscience, 10(November), 604.

% Figure 2
mkdir('speakerA Audio');
cd('speakerA Audio');

%% load data
load('E:\DataProcessing\speaker-listener_experiment\Speaker Validation\1-forward model\all channels\AudioA_speakerA_forward_afterICA.mat');

%% band name
band_name = fieldnames(Audio_speakerA_forward);


%% initial
load('E:\DataProcessing\chn_re_index.mat');
chn_re_index = chn_re_index(1:64);

listener_chn = [1:32 34:42 44:59 61:63];

load('E:\DataProcessing\label66.mat');
chn_area_labels  = label66;
layout = 'E:\DataProcessing\easycapm1.mat';

%% timelag
Fs = 64;
timelag = -500 : 1000/(Fs+1) : 500;
label_select = 1 : round(length(timelag)/8) :length(timelag);

select_plot_chn = [find(listener_chn==19) find(listener_chn==62)]; % FCz Oz
%% calculate
for band_select = 1 : length(band_name)
    band_file_name = band_name{band_select};
    mkdir(band_file_name);
    cd(band_file_name);
    
    % select data
    temp_data_model = eval(strcat('Audio_speakerA_forward.',band_name{band_select},'.model'));
    temp_data_model_mean =  squeeze(mean(temp_data_model,1));
    temp_data_model_mean = temp_data_model_mean(:,listener_chn);
    
    temp_GFP = zeros(1,size(temp_data_model_mean,1));
    
    %% GFP calculate
    for time_point = 1 : size(temp_data_model_mean,1)
        for chn = 1: size(temp_data_model_mean,2)
            temp_GFP(time_point) = temp_GFP(time_point) + temp_data_model_mean(time_point, chn) ^ 2;
        end
    end
    
    % get max timelag
    [~,Index] = sort(temp_GFP,'descend');
    
    set(gcf,'outerposition',get(0,'screensize'));
    %% plot topoplot
    
    for i = 1 : 6
        % plot
        eval(strcat('subplot(23',num2str(i),');'));
        U_topoplot(temp_data_model_mean(Index(i),:)',layout,label66(listener_chn));colorbar('location','EastOutside');
        title(strcat('GFP Max No.',num2str(i),' timelag',num2str(timelag(Index(i))),'ms'));
    end
    
    save_plot_name = strcat('mTRF topoplot-',band_name{band_select},'.fig');
    suptitle(save_plot_name(1:end-4));
    saveas(gcf,save_plot_name);
    
    save_plot_name = strcat('mTRF topoplot-',band_name{band_select},'.jpg');
    saveas(gcf,save_plot_name);
    close
    
    %% GFP plot
    plot(timelag,temp_GFP,'LineWidth',2);
    save_name = strcat('mTRF GFP-',band_name{band_select},'.fig');
    title(save_name(1:end-4));
    saveas(gcf,save_name);
    
    save_name = strcat('mTRF GFP-',band_name{band_select},'.jpg');
    saveas(gcf,save_name);
    close;
    
    %% mTRF plot
    set(gcf,'outerposition',get(0,'screensize'));
    for chn  = 1 : length(select_plot_chn)
%         eval(strcat('subplot(21',num2str(chn),');'));
        plot(timelag,temp_data_model_mean(:,select_plot_chn(chn)),'LineWidth',2);
        hold on;
        
%         ylim([-0.05 0.05]);
    end
    
    legend(label66(listener_chn(select_plot_chn)));
    save_plot_name = strcat('mTRF channel-',band_name{band_select},'.fig');
    suptitle(save_plot_name(1:end-4));
    saveas(gcf,save_plot_name);
    
    save_plot_name = strcat('mTRF channel-',band_name{band_select},'.jpg');
    saveas(gcf,save_plot_name);
    close
    
    p = pwd;
    cd(p(1:end-(length(band_file_name)+1)));
    
    % save data
    eval(strcat('mTRF_GFP.',band_name{band_select},'=temp_GFP;'));
end


save('mTRF_GFP.mat','mTRF_GFP');
