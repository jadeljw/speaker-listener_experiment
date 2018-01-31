Fs = 64;
timelag = -250:(1000/Fs):500;
cca_comp = 15;


timelag_plot = -250:750/10:500;
timelag_plot = timelag_plot(2:10);

for i = 1 : 20
    %% data name
    if i < 10
        file_name = strcat('listener10',num2str(i));
    else
        file_name = strcat('listener1',num2str(i));
    end
    
    r_value_AttendDecoder_attend_all = zeros(cca_comp,length(timelag));
    r_value_AttendDecoder_unattend_all = zeros(cca_comp,length(timelag));
    r_value_UnattendDecoder_attend_all = zeros(cca_comp,length(timelag));
    r_value_UnattendDecoder_unattend_all = zeros(cca_comp,length(timelag));
    
    for j = 1 : length(timelag)
        %% load data
        load(strcat('E:\DataProcessing\speaker-listener_experiment\Decoding Result\CCA-speaker-listener\theta\',file_name,'\cca_S-L_EEG_result+',num2str(timelag(j)),'ms.mat'));
        
        for r_rank = 1 : cca_comp
            r_value_AttendDecoder_attend_all(r_rank,j) =  mean(recon_AttendDecoder_attend_cca{r_rank});
            r_value_AttendDecoder_unattend_all(r_rank,j) = mean(recon_AttendDecoder_unattend_cca{r_rank});
            r_value_UnattendDecoder_attend_all(r_rank,j) = mean(recon_UnattendDecoder_attend_cca{r_rank});
            r_value_UnattendDecoder_unattend_all(r_rank,j) = mean(recon_UnattendDecoder_unattend_cca{r_rank});
        end
        
    end
    
    %% plot
    % attended
    figure;
    set(gcf,'outerposition',get(0,'screensize'));
    subplot(211);
    imagesc(r_value_AttendDecoder_attend_all);colorbar;colormap('jet');
    xlabel('timelag(ms)'); ylabel('CCA rank');
    set(gca, 'XTickLabel', timelag_plot);
    title(strcat(file_name,'-r value for attend decoder'));
    subplot(212);
    imagesc(r_value_AttendDecoder_unattend_all);colorbar;colormap('jet');
    xlabel('timelag(ms)'); ylabel('CCA rank');
    set(gca, 'XTickLabel', timelag_plot);
    title(strcat(file_name,'-r value for unattend decoder'));
    suptitle('Attended decoder');
    save_Name = strcat(file_name,'-r value-attended.jpg');
    saveas(gcf,save_Name);
    close;
    
    % unattended
    figure;
    set(gcf,'outerposition',get(0,'screensize'));
    subplot(211);
    imagesc(r_value_UnattendDecoder_attend_all);colorbar;colormap('jet');
    xlabel('timelag(ms)'); ylabel('CCA rank');
    set(gca, 'XTickLabel', timelag_plot);
    title(strcat(file_name,'-r value for attend decoder'));
    subplot(212);
    imagesc(r_value_UnattendDecoder_unattend_all);colorbar;colormap('jet');
    xlabel('timelag(ms)'); ylabel('CCA rank');
    set(gca, 'XTickLabel', timelag_plot);
    title(strcat(file_name,'-r value for unattend decoder'));
    suptitle('Unattended decoder');
    save_Name = strcat(file_name,'-r value-unattended.jpg');
    saveas(gcf,save_Name);
    close;
    
end