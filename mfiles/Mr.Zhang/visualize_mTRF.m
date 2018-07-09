clear;
r_sur = load('res_mTRF_surrogate.mat');
r = load('res_mTRF.mat');

load label66.mat
layout_file = 'neuroscan61HH.lay';

freqs = {'delta','theta','alpha','beta'};
fs = 64;
lags = r.lags;

%%
for kk = 4%:length(freqs)
    figure;
    subplot(221);
    plot(lags,squeeze(r.r_A(kk,:)));
    hold on;
    plot(lags,squeeze(r_sur.r_A(:,kk,:)),'r');
    title([freqs{kk} ', Speaker A']);
    
    subplot(222);
    plot(lags,squeeze(r.r_B(kk,:)));
    hold on;
    plot(lags,squeeze(r_sur.r_B(:,kk,:)),'r');
    title([freqs{kk} ', Speaker B']);
    
    subplot(223);
    plot(lags,squeeze(r.r_AH(kk,:)));
    hold on;
    plot(lags,squeeze(r_sur.r_AH(:,kk,:)),'r');
    title([freqs{kk} ' Hilbert, Speaker A']);
    
    subplot(224);
    plot(lags,squeeze(r.r_BH(kk,:)));
    hold on;
    plot(lags,squeeze(r_sur.r_BH(:,kk,:)),'r');
    title([freqs{kk} ' Hilbert, Speaker B']);
    
    pause;
    close all;
end

%%
kk = 4;
for i = 1:10
    toi = find(lags>200*i-1200 & lags<=200*i-1000);
    figure;
    subplot(121);
    U_topoplot(squeeze(mean(r.model_A(kk,toi,65:128),2)),layout_file,label66(1:64));
    title([freqs{kk} ', Speaker A']);
    subplot(122);
    U_topoplot(squeeze(mean(r.model_B(kk,toi,65:128),2)),layout_file,label66(1:64));
    title([freqs{kk} ', Speaker B']);
    pause;
    close all;
end
