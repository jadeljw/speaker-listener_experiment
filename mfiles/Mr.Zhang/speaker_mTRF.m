clear;

load data_speakerA_afterICA
load Audio_A
load data_speakerB_afterICA
load Audio_B

fs = 64;
lamda = 2^10;

freqs = {'delta','theta','alpha','beta'};

for kk = 1:length(freqs)
    disp(['Processing ' freqs{kk}]);
    % (MAP==1: feats by lags by chans,
    %  MAP==-1: chans by lags by feats)
    eval(['speakerA_one = data_speakerA_total.' freqs{kk} ';']);
    eval(['speakerB_one = data_speakerB_total.' freqs{kk} ';']);
    eval(['speakerAH_one = data_speakerA_total.' freqs{kk} '_hilbert;']);
    eval(['speakerBH_one = data_speakerB_total.' freqs{kk} '_hilbert;']);
    for i = 1:28
        stimA{i} = Audio_A_total.delta{i};
        respA{i} = speakerA_one{i};
        respAH{i} = speakerAH_one{i};
        stimB{i} = Audio_B_total.delta{i};
        respB{i} = speakerB_one{i};
        respBH{i} = speakerBH_one{i};
        %     [w,t] = mTRFtrain(stim{i},resp{i},fs,-1,-500,500,lamda);
        %     w_all(i,:,:) = squeeze(w);
    end
    
    lags = -1000:1000/fs:1000;
    for i = 1:length(lags)%time, -500 to 500 ms
        i
        [r,p,mse,pred,model] = mTRFcrossval(stimA,respA,fs,-1,lags(i),lags(i),lamda);
        r_A(kk,i) = mean(r);
        model_A(kk,i,:) = squeeze(mean(model,1));
        [r,p,mse,pred,model] = mTRFcrossval(stimA,respAH,fs,-1,lags(i),lags(i),lamda);
        r_AH(kk,i) = mean(r);
        model_AH(kk,i,:) = squeeze(mean(model,1));
        [r,p,mse,pred,model] = mTRFcrossval(stimB,respB,fs,-1,lags(i),lags(i),lamda);
        r_B(kk,i) = mean(r);
        model_B(kk,i,:) = squeeze(mean(model,1));
        [r,p,mse,pred,model] = mTRFcrossval(stimB,respBH,fs,-1,lags(i),lags(i),lamda);
        r_BH(kk,i) = mean(r);
        model_BH(kk,i,:) = squeeze(mean(model,1));
    end
    %CV codes, reserved, now lamda = 1024 seemed to be the optimal
    % for i = -20:1:20
    %     i
    %    [r,p,mse] = mTRFcrossval(stim,resp,fs,-1,-500,500,2^i);
    %    r_all(i+21,:) = squeeze(r);
    %    mse_all(i+21,:) = squeeze(mse);
    % end
end

save res_mTRF r_A r_B r_AH r_BH model_A model_B model_AH model_BH lags

% %% visualization 
% 
% load label66.mat
% layout_file = 'neuroscan61HH.lay';
% 
% % h = figure;
% % set(gca,'FontSize',20);
% % plot(lags,squeeze(r_A(3,:)),'linewidth',2);
% % ylim([0 0.15]);
% 
% kk = 1;
% for i = 1:65
%     figure;
%     U_topoplot(squeeze(model_B(kk,i,65:128)),layout_file,label66(1:64));
%     title([num2str(lags(i)) ' ms, r = ' num2str(r_B(kk,i))]);
%     pause;
%     close all;
% end
% 
% %%
% for kk = 1:length(freqs)
%     h = figure;
%     plot(lags,squeeze(r_A(kk,:)));
%     hold on;
%     plot(lags,squeeze(r_B(kk,:)),'r.');
%     title([freqs{kk}]);
%     
%     h = figure;
%     plot(lags,squeeze(r_AH(kk,:)));
%     hold on;
%     plot(lags,squeeze(r_BH(kk,:)),'r.');
%     title([freqs{kk} ', Hilbert']);
% end
