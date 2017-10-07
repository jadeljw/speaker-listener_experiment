function [trl event] = trialfun_LJW(cfg)
%requiring fields:
% for trial definition:
% cfg.trialdef.prestim - prestim time before the trigger
% cfg.trialdef.poststim - poststim time after the trigger

%output new field:
% cfg.trial_trigger_error - index of the trial with erroneous triggers
%trial extraction function for LJW's undergraduate thesis project
%Dan Zhang, dzhang@tsinghua.edu.cn, 2015-4-14

%get the sampling rate
cfg_fs = [];
cfg_fs.dataset = cfg.dataset;
cfg_fs.continuous = 'yes';
cfg_fs.channel = 1;
data_fs = ft_preprocessing(cfg_fs);
fs = data_fs.fsample;

prestim=cfg.trialdef.prestim;
poststim=cfg.trialdef.poststim;

cfg_tri = [];
cfg_tri.trialdef.eventtype = 'trigger';
cfg_tri.dataset = cfg.dataset;
cfg_tri.trialdef.eventvalue = [31 32];
cfg_tri.trialdef.prestim    = prestim;
%poststim set to a small duration, to make sure all triggers can be captured 
%(especially these at the end)
%otherwise the last few triggers will be skipped by FieldTrip due to
%insufficient 'trial length'
cfg_tri.trialdef.poststim   = 1;
cfg_tri = ft_definetrial(cfg_tri);

% check the triggers
tri_sel = [];
error_index = [];
tri_cnt = 1;
flag_start = 0;
flag_end = 0;
while tri_cnt <= length(cfg_tri.trl)
    %find the first trigger
    while cfg_tri.trl(tri_cnt,4) ~= 31
        tri_cnt = tri_cnt + 1;
    end
    if(cfg_tri.trl(tri_cnt,4) == 31)
        %check if there is 3 continuous triggers of 224
        cnt_start = U_trigger_check(cfg_tri.trl(tri_cnt+1:end,4),31);
        if(cnt_start == 2)
            flag_start = 1;
        end
        %check if there is 3 continuous triggers of 144 afterwards
        cnt_end = U_trigger_check(cfg_tri.trl(tri_cnt+cnt_start+1:end,4),32);
        if(cnt_end == 3)
            flag_end = 1;
        end
        
        tri_sel = [tri_sel tri_cnt];
        if(flag_start && flag_end)            
            tri_cnt = tri_cnt + 6;
        else
            tri_cnt = tri_cnt + cnt_start + cnt_end + 1;
            disp(['error in trial #' num2str(length(tri_sel))]);
            error_index = [error_index length(tri_sel)];
        end
        flag_start = 0;
        flag_end = 0;
   end
end

%adjust the poststim value
for i = 1:size(cfg_tri.trl,1)
    cfg_tri.trl(i,2) = cfg_tri.trl(i,2)+fs*(poststim-1);
end
trl = cfg_tri.trl(tri_sel,:);
event = cfg_tri.event;

function cnt = U_trigger_check(data,value)
    cnt = 1;
    while cnt<=length(data) && data(cnt) == value
        cnt = cnt + 1;
    end
    cnt = cnt - 1;
end

end
