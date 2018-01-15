%plot CCA speaker listener result
Fs = 64;
timelag = -250:750/10:500;
timelag = timelag(2:10);

for i = 1 : 20
    %% data type
    data_type = {'read';'retell'};
    
    for j = 1 : length(data_type)
        data_type_select = data_type{j};
        
        %% data name
        if i < 10
            file_name = strcat('listener10',num2str(i));
        else
            file_name = strcat('listener1',num2str(i));
        end
        
        %% load data
        data_name = strcat('E:\DataProcessing\speaker-listener_experiment\Decoding Result\CCA-speaker-listener\',file_name,'\',data_type_select,'\',file_name,'_Accuracy.mat');
        load(data_name);
        
        %% plot
        figure;
        set(gcf,'outerposition',get(0,'screensize'));
        subplot(211); 
        imagesc(Acc_attend);colorbar;colormap('jet'); 
        xlabel('timelag(ms)'); ylabel('CCA rank');
        set(gca, 'XTickLabel', timelag); 
        title(strcat(file_name,'-',data_type_select,'-Classification Acc for attend decoder'));
        subplot(212); 
        imagesc(Acc_unattend);colorbar;colormap('jet'); 
        xlabel('timelag(ms)'); ylabel('CCA rank');
        set(gca, 'XTickLabel', timelag); 
        title(strcat(file_name,'-',data_type_select,'-Classification Acc for unattend decoder'));
        
        save_Name = strcat(file_name,'-',data_type_select,'-Classification Acc');
        saveas(gcf,save_Name);
        close;
    end
end