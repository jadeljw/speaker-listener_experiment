%% behavioral result


%% load data by hand
i = 20;

%% listener name
if i < 10
    file_name = strcat('listener10',num2str(i));
else
    file_name = strcat('listener1',num2str(i));
end

%% initial
Attend_correct = zeros(28,2);
Unattend_correct = zeros(28,2);

%% Answer_mat
Correct_or_not = cell2mat(RightAnswer)-cell2mat(Response);

%% load counterband table
load(strcat('E:\DataProcessing\speaker-listener_experiment\CountBalanceTable\CountBalanceTable_listener',file_name(end-2:end),'.mat'));

for j = 1 : length(AttendTarget)
    if strcmpi(AttendTarget{j},'A')
        Attend_correct(j,:) = Correct_or_not(j,1:2);
        Unattend_correct(j,:) = Correct_or_not(j,3:4);
    else
        Attend_correct(j,:) = Correct_or_not(j,3:4);
        Unattend_correct(j,:) = Correct_or_not(j,1:2);
    end
end

%% ACC
Attend_acc = length(find(Attend_correct==0))/(size(Attend_correct,1)*size(Attend_correct,2))
Unattend_acc = length(find(Unattend_correct==0))/(size(Unattend_correct,1)*size(Unattend_correct,2))


%% other
concentration = mean(cell2mat(selfReport_concentration(:,2)))
difficulty = mean(cell2mat(selfReport_difficulty(:,2)))
familiar = mean(cell2mat(selfReport_familiar(:,2)))

%% save
 saveName = strcat('Behavioral_',file_name,'.mat');
        %     saveName = strcat('mTRF_sound_EEG_result.mat');
        save(saveName,'Attend_acc','Unattend_acc','concentration','difficulty','familiar');