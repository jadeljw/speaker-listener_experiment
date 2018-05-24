% Combine listener Behavior Result

% LJW
% 2018.5.15


%% initial data
listener_num = 20;
Behavioral_result.Attend_acc = zeros(listener_num,1);
Behavioral_result.concentration= zeros(listener_num,1);
Behavioral_result.difficulty= zeros(listener_num,1);
Behavioral_result.familiar= zeros(listener_num,1);
Behavioral_result.Unattend_acc= zeros(listener_num,1);
%% load data

for i = 1 : 20
    
    %% listener name
    if i < 10
        file_name = strcat('listener10',num2str(i));
    else
        file_name = strcat('listener1',num2str(i));
    end
    
    
    %% load data
    data_name = strcat('Behavioral_',file_name,'.mat');
    data_path = 'E:\DataProcessing\speaker-listener_experiment\Behavioral Result';
    load(strcat(data_path,'\',data_name));
    
    %% combine
    Behavioral_result.Attend_acc(i) =  Attend_acc;
    Behavioral_result.concentration(i) = concentration;
    Behavioral_result.difficulty(i) = difficulty;
    Behavioral_result.familiar(i) = familiar;
    Behavioral_result.Unattend_acc(i) = Unattend_acc;
    
end