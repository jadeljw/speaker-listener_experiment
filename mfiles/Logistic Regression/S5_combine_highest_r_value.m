% logistic regression

%% load data set 

data_set1 = load('E:\DataProcessing\speaker-listener_experiment\Logistic Regression\1-large r value\theta\total\FZ\mTRF_speakerEEG_listenerEEG_result-timelag-203.125ms-theta.mat');

data_set2 =load('E:\DataProcessing\speaker-listener_experiment\Logistic Regression\1-large r value\theta\total\FZ\mTRF_speakerEEG_listenerEEG_result-timelag-62.5ms-theta.mat');
label = 'Fz-Fz';
band = 'theta';

%% initial
listener_num =  size(data_set1.r_value_mat_total,1);
story_num = size(data_set1.r_value_mat_total,2);

%% combine feature
temp_r_value1 = permute(data_set1.r_value_mat_total,[3 1 2]);
temp_r_value2 = permute(data_set2.r_value_mat_total,[3 1 2]);
r_value_combine = [temp_r_value1;temp_r_value2];


Rsquared_Ordinary = zeros(1,listener_num);
Rsquared_Adjusted = zeros(1,listener_num);

%% glm
for listener_select = 1 : listener_num
    r_value_mat = squeeze(r_value_combine(:,listener_select,:))';
    attend_target = data_set1.attend_target_total(listener_select,:);
    glm = fitglm(r_value_mat,attend_target,'distr','binomial');
    Rsquared_Ordinary(listener_select) = glm.Rsquared.Ordinary;
    Rsquared_Adjusted(listener_select) = glm.Rsquared.Adjusted;
end

%% output
disp('*********************');
disp(strcat('Label: ',label));
disp(strcat('Band: ',band));
disp(strcat('Original dataset1 r^2 value:',num2str(data_set1.R_squared_glm)));
disp(strcat('Original dataset2 r^2 value:',num2str(data_set2.R_squared_glm)));
disp(strcat('Combine Rsquared Ordinary value:',num2str(mean(Rsquared_Ordinary))));
disp(strcat('Combine Rsquared Adjusted value:',num2str(mean(Rsquared_Adjusted))));