% plot histgram for r^2 value


%% label
band_name = {'delta','theta','alpha','beta'};
% band_name = {'beta'};

for band_select = 1 : length(band_name)
    band_file_name = strcat(band_name{band_select});
    disp(band_file_name);
    %% load data
%     load(strcat('E:\DataProcessing\speaker-listener_experiment\Logistic Regression\4-surrogate\0-plot\Speaker ListenerEEG zscore surrogate1\',...
%         band_file_name,'\total\Audio ListenerEEG Logstic Regresssion r^2 Result-total-',...
%         band_file_name,'-total-Small_area.mat'));

    load(strcat('E:\DataProcessing\speaker-listener_experiment\Logistic Regression\1-large r value\zscore\95%\',...
        band_file_name,'\total\Audio ListenerEEG Logstic Regresssion r^2 Result-total-',...
        band_file_name,'-total-Small_area.mat'));
    
    
    %% histgram
    h = histogram(R_squared_mat_speaker);
    h.BinLimits = [-0.1 0.18];
    ylabel('count');
    xlabel('R^2 value');
    title(band_file_name);
    
    for i = 1 : length(h.BinCounts)
        if sum(h.BinCounts(1:i))/sum(h.BinCounts) > 0.9
            hold on; plot([h.BinEdges(i),h.BinEdges(i)],[h.BinEdges(i),max(h.BinCounts)],'y','LineWidth',2);
            legend('Count','90%');
            disp(strcat('90% :',num2str(h.BinEdges(i))));
            break
        end
    end
    
    for i = 1 : length(h.BinCounts)
        if sum(h.BinCounts(1:i))/sum(h.BinCounts) > 0.95
            hold on; plot([h.BinEdges(i),h.BinEdges(i)],[h.BinEdges(i),max(h.BinCounts)],'r','LineWidth',2);
            legend('Count','90%','95%');
            disp(strcat('95% :',num2str(h.BinEdges(i))));
            break
        end
    end
    
    for i = 1 : length(h.BinCounts)
        if sum(h.BinCounts(1:i))/sum(h.BinCounts) > 0.99
            hold on; plot([h.BinEdges(i),h.BinEdges(i)],[h.BinEdges(i),max(h.BinCounts)],'b','LineWidth',2);
            legend('Count','90%','95%','99%');
            disp(strcat('99% :',num2str(h.BinEdges(i))));
            break
        end
    end
    
    
    %% save
    save_name = strcat(band_file_name,'.jpg');
    saveas(gcf,save_name);
    close;
    
end


