clear;
close all;

load label64
load 102-LTX-Listener-ICA-reref-filter_type
load Speaker01-CFY-read_retell_valid
load Speaker02-FS-read_retell_valid
%data from pre-5s to post-65s
%retell的1-7注意的是speakerA，read的8-14注意的speakerA

fs = 64;
t_sel = 10*fs+1:60*fs;

Att_Task = [1 1 1 1 1 1 1 0 0 0 0 0 0 0];

if_plot = 0;

%%
if_retell = 1;%take retell data
chn_ALL = 1:64;
chn_selS = 6:64;
chn_selL = 1:64;

cca_comp = 20;
chnS_exc = setdiff(chn_ALL,chn_selS);
chnL_exc = setdiff(chn_ALL,chn_selL);

if(~if_retell)
    % read
    Att_Task_test_cca = zeros(1,14);
    for k = 1:14
        k
        %cross-validation
        train_set = setdiff(1:14,k);
        speakerA = [];
        speakerB = [];
        listenerA = [];
        listenerB = [];
        for i = train_set
            if(Att_Task(i)==1)%then speakerA
                speakerA = [speakerA data_speakerA_read_boradband_valid{i}(:,t_sel)];
                listenerA = [listenerA listener_boradband_read{i}(:,t_sel)];
            else%then speaker B
                speakerB = [speakerB data_speakerB_read_boradband_valid{i}(:,t_sel)];
                listenerB = [listenerB listener_boradband_read{i}(:,t_sel)];
            end
        end
        speakerA(chnS_exc,:) = 0;
        speakerB(chnS_exc,:) = 0;
        listenerA(chnL_exc,:) = 0;
        listenerB(chnL_exc,:) = 0;
        [w_A,v_A,r_A] = canoncorr(speakerA',listenerA');
        [w_B,v_B,r_B] = canoncorr(speakerB',listenerB');
        for kk = 1:cca_comp
            if(if_plot)
                figure;
                subplot(121);U_topoplot(w_A(:,kk),'biosemi64.lay',label64);%plot(w_A(:,1));
                subplot(122);U_topoplot(v_B(:,kk),'biosemi64.lay',label64);%plot(v_B(:,1));
                pause;
                close all;
            end
            data_speakerA_test = data_speakerA_read_boradband_valid{k}(:,t_sel)';
            data_speakerB_test = data_speakerB_read_boradband_valid{k}(:,t_sel)';
            data_listener_test = listener_boradband_read{k}(:,t_sel)';
            data_speakerA_test(chnS_exc,:) = 0;
            data_speakerB_test(chnS_exc,:) = 0;
            data_listener_test(chnL_exc,:) = 0;
            r_A_test(k) = corr(data_speakerA_test*w_A(:,kk),data_listener_test*v_A(:,kk));
            r_B_test(k) = corr(data_speakerB_test*w_B(:,kk),data_listener_test*v_B(:,kk));
            if(r_A_test(k)>r_B_test(k))
                Att_Task_test_cca(kk,k) = 1;
            end
        end
    end
else
    % retell
    Att_Task_test_cca = zeros(1,14);
    for k = 1:14
        k
        %cross-validation
        train_set = setdiff(1:14,k);
        speakerA = [];
        speakerB = [];
        listenerA = [];
        listenerB = [];
        for i = train_set
            if(Att_Task(i)==1)%then speakerA
                speakerA = [speakerA data_speakerA_retell_boradband_valid{i}(:,t_sel)];
                listenerA = [listenerA listener_boradband_retell{i}(:,t_sel)];
            else%then speaker B
                speakerB = [speakerB data_speakerB_retell_boradband_valid{i}(:,t_sel)];
                listenerB = [listenerB listener_boradband_retell{i}(:,t_sel)];
            end
        end
        speakerA(chnS_exc,:) = 0;
        speakerB(chnS_exc,:) = 0;
        listenerA(chnL_exc,:) = 0;
        listenerB(chnL_exc,:) = 0;
        [w_A,v_A,r_A] = canoncorr(speakerA',listenerA');
        [w_B,v_B,r_B] = canoncorr(speakerB',listenerB');
        for kk = 1:cca_comp
            if(if_plot)
                figure;
                subplot(121);U_topoplot(w_A(:,kk),'biosemi64.lay',label64);%plot(w_A(:,1));
                subplot(122);U_topoplot(v_B(:,kk),'biosemi64.lay',label64);%plot(v_B(:,1));
                pause;
                close all;
            end
            data_speakerA_test = data_speakerA_retell_boradband_valid{k}(:,t_sel)';
            data_speakerB_test = data_speakerB_retell_boradband_valid{k}(:,t_sel)';
            data_listener_test = listener_boradband_retell{k}(:,t_sel)';
            data_speakerA_test(chnS_exc,:) = 0;
            data_speakerB_test(chnS_exc,:) = 0;
            data_listener_test(chnL_exc,:) = 0;
            r_A_test(k) = corr(data_speakerA_test*w_A(:,kk),data_listener_test*v_A(:,kk));
            r_B_test(k) = corr(data_speakerB_test*w_B(:,kk),data_listener_test*v_B(:,kk));
            if(r_A_test(k)>r_B_test(k))
                Att_Task_test_cca(kk,k) = 1;
            end
        end
    end
end

for i = 1:cca_comp
   Accs(i) = length(find(Att_Task == Att_Task_test_cca(i,:)))/length(Att_Task);
end
