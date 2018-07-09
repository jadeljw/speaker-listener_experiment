% S2_plot_forward_mTRF

% by LJW
%% data type
data_type = {'raw','afterICA'};

%% initial plot
Fs = 64;
timelag = -500 : 1000/Fs : 500;
label_select = 1 : round(length(timelag)/8) :length(timelag);
timelag_for_plot = -500: 1000/(Fs+1) : 500;

%% new order
load('E:\DataProcessing\Label_and_area.mat');

select_area = 'Small_area';
chn_area_labels = fieldnames(eval(select_area));
% chn_area_labels_new = [chn_area_labels(4:6)' chn_area_labels(1:3)' chn_area_labels(7:9)'];
chn_area_labels_plot_order = [4 6 5 2 1 3 7:9];

for type_select = 1 : length(data_type)
    file_name =strcat( 'SpeakerA AudioA-',data_type{type_select});
    mkdir(file_name);
    cd(file_name);
    disp(file_name);
    
    %% load data
    load(strcat('E:\DataProcessing\speaker-listener_experiment\Speaker Validation\1-forward model\AudioA_speakerA_forward_',data_type{type_select},'.mat'));
    band_name = fieldnames(Audio_speakerA_forward);
    
    for band_select = 1 : length(band_name)
        band_file_name = band_name{band_select};
        mkdir(band_file_name);
        cd(band_file_name);
        disp(band_file_name);
        
        %% calculate data
        temp_model = eval(strcat('Audio_speakerA_forward.',band_name{band_select},'.model'));
        temp_model_mean = squeeze(mean(temp_model,1))';
        
        %% imagesc
        set(gcf,'outerposition',get(0,'screensize'));
        imagesc(temp_model_mean);colorbar;
        %     caxis([-0.04 0.1]);
        %     colormap('jet');
        xticks(label_select);
        xticklabels(timelag(label_select));
        yticks(1:length(chn_area_labels));
        yticklabels(chn_area_labels);
        xlabel('timelag(ms)');
        ylabel('Speaker Channels');
        save_name = strcat('AudioA SpeakerA forward models-',data_type{type_select},'-',band_name{band_select},'.fig');
        title(save_name(1:end-4));
        saveas(gcf,save_name);
        
        save_name = strcat('AudioA SpeakerA forward models-',data_type{type_select},'-',band_name{band_select},'.jpg');
        saveas(gcf,save_name);
        close
        
        %% plot
        set(gcf,'outerposition',get(0,'screensize'));
        range_for_plot = max(max(abs(temp_model_mean)));
        
        for area_select = 1: length(chn_area_labels)
            if chn_area_labels_plot_order(area_select)>6
                eval(strcat('subplot(33',num2str(chn_area_labels_plot_order(area_select)),')'));
                plot(timelag_for_plot,temp_model_mean(area_select,:),'LineWidth',2);
                title(chn_area_labels{area_select});
                ylim([-range_for_plot range_for_plot]);
                xlabel('timelag(ms)');
                ylabel('amplitude');
            else
                eval(strcat('subplot(33',num2str(chn_area_labels_plot_order(area_select)),')'));
                plot(timelag_for_plot,temp_model_mean(area_select,:),'LineWidth',2);
                ylim([-range_for_plot range_for_plot]);
                title(chn_area_labels{area_select});
                ylabel('amplitude');
            end
        end
        
        save_name1 = strcat('AudioA SpeakerA forward models plot-',data_type{type_select},'-',band_name{band_select},'.fig');
        suptitle(save_name1(1:end-4));
        saveas(gcf,save_name1);
        
        save_name1 = strcat('AudioA SpeakerA forward models plot-',data_type{type_select},'-',band_name{band_select},'.jpg');
        saveas(gcf,save_name1);
        close
        
        
        p = pwd;
        cd(p(1:end-(length(band_file_name)+1)));
    end
    p = pwd;
    cd(p(1:end-(length(file_name)+1)));
end