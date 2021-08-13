clear all; 


%%%SOME STATISTICS FOR NMP

%% Prepare data for plotting%%

%%%graphs included: 
%%%%%% 1. Accuracy by trial type (correct vs hold) per participant 
%%%%%% 2. Correct vs. incorrect (percentage) bar plots 
%%%%%% 3. Accuracy by Trial Type (correct vs hold) Across Participants 
%%%%%% 4. Reaction time per participant and overall 

% Loading individual responses into the workspace  
P04 = load('/Users/annicklanglois/Desktop/Matlab NMP/P04_Response.mat');
P03 = load('/Users/annicklanglois/Desktop/Matlab NMP/P03_Response.mat');
P02 = load('/Users/annicklanglois/Desktop/Matlab NMP/P02_Response.mat');
P01 = load('/Users/annicklanglois/Desktop/Matlab NMP/P01_Response.mat');

% Reshaping into log format (i.e., RT column, trial column, etc) 
P01.log_aud.responses = P01.log_aud.responses';
P02.log_aud.responses = P02.log_aud.responses';
P03.log_aud.responses = P03.log_aud.responses';
P03.log_aud.responses(:,7) = 3; % change ID to 3 for 3rd participant 
P04.log_aud.responses = P04.log_aud.responses';


% Concatenate the individual structs into one table 
combined = [P01.log_aud.responses; P02.log_aud.responses; P03.log_aud.responses; P04.log_aud.responses]; % concatenate structs
tcombined = array2table(combined); % transform into table (not sure if this is the best option)
tcombined.Properties.VariableNames = {'RT' 'Target', 'KeyPressed', 'Feedback', 'TrialType', 'Timeout', 'ID'}; % rename columns

%% Accuracy by Trial Type
G2 = groupcounts(tcombined, {'Feedback', 'TrialType'}, 'IncludeEmptyGroups', true); % more correct responses for HOLD condition 
labels = categorical({'Incorrect/PLAY','Incorrect/HOLD','Correct/PLAY','Correct/HOLD'});
labels = reordercats(labels,string(labels));
Y = G2.Percent;
clr = [178 198 100; 
    178 198 150; 
    134 180 211; 
    134 200 211] / 255;
b = bar(labels, Y, 'facecolor', 'flat');
b.CData = clr;
ylabel('Percent (%)');
xlabel('Feedback/Condition');
ylim([0 60]);
title('Accuracy by Trial Type');

%% Barplot of overall % correct/incorrect reponses 
G1 = groupcounts(tcombined, {'Feedback'}); 
x = categorical({'Incorrect', 'Correct'});
y = G1.Percent; 
bar(x,y);
xlabel('Feedback')
ylabel('% of correct replies')
title('Performance');

%% Accuracy by Trial Type Across Participants 
P1 = tcombined(1:24,:);
P2 = tcombined(25:48,:);
P3 = tcombined(49:72,:);
P4 = tcombined(73:96,:);

percP1 = groupcounts(P1, {'Feedback', 'TrialType'});
percP2 = groupcounts(P2, {'Feedback', 'TrialType'});
percP3 = groupcounts(P3, {'Feedback', 'TrialType'}); 
percP4 = groupcounts(P4, {'Feedback', 'TrialType'});

x = categorical({'1', '2', '3', '4'});
% vals = [12.5 12.5 37.5 37.5; 12.5 0 0 25; 37.5 37.5 20.833 29.167; 37.5 50 50 25]
vals = [12.5000 12.5000 37.5000 37.5000; 12.5000 0 37.5000 50.0000; 29.1667 0 20.8333 50.0000; 20.8333 25.0000 29.1667 25.0000];
b = bar(x,vals, 'FaceColor', 'flat', 'BarWidth', 1);
b(1).FaceColor = [178 198 100]/255; % change colors to be the same as above  
b(2).FaceColor = [178 198 150]/255; % change colors to be the same as above 
b(3).FaceColor = [134 180 211]/255; % change colors to be the same as above 
b(4).FaceColor = [134 200 211]/255; % change colors to be the same as above 
set(b, {'DisplayName'}, {'Incorrect/PLAY','Incorrect/HOLD','Correct/PLAY', 'Correct/HOLD'}') % prepare legend
legend() % add legend
ylim([0 60]) 
xlabel('Participant')
ylabel('Percent (%)')
title('Accuracy by Trial Type Across Participants')


%% Plot RT 

%RT by Participant
boxplot(tcombined.RT, tcombined.ID);
xlabel('Participant');
ylabel('Reaction Time (ms)');
title('Reaction Time (RT) by Participant'); 

% RT by Trial Type
boxplot(tcombined.RT, tcombined.TrialType, 'Labels', {'PLAY', 'HOLD'});
title('Reaction Time (RT) by Trial Type'); 
xlabel('Condition');
ylabel('Reaction Time (ms)');

