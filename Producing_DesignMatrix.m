%% EXPERIMENTAL DESIGN MATRIX %%

% We want to have a design matrix of one run in the end which includes the
% timing of the trial start, which of the 4 sequences we have will be used,
% stimulus duration (in ms with stimuli presentation of 1Hz), rehearsal
% duration (in ms, in the same rhythm as stimulus presentation), if the
% trial should present the correct or an incorrect stimulus as target, and
% lastly the inter trial interval between the response and the beginning of
% the next trial (what about the duration of feedback presentation?)

clear;

% global information for trials

ITIs             = [3000 4000 5000 6000]; % in ms
Init_Break     = 1500; %when to start the first trial after beginning of the run
stimdur          = 500; %how long is a beep played? (not needed atm)
stimrate         = 1000;  % Rate of presented beeps in stimphase



% initializing the different types of correct/incorrect trials, and the
% durations of stimulus presentation & rehearsal + condition (play = 1,
% hold = 2, wait = 3) -> same as in original paper

correct   = [1 1 1 0 0 0];
stimphase = [6 6 8 8 10 10];
refphase  = [6 6 8 8 10 10];
condition = [1 1 2 2 3 3];

% Trial Specs of a single Run
Trials_all =   [1 1 1 1 1 1               3 3 3 3 3 3                4 4 4 4 4 4                2 2 2 2 2 2;                 % Which sequence for trial (condition) = different frequencies
                randsample(stimphase,6)   randsample(stimphase,6)    randsample(stimphase,6)    randsample(stimphase,6);     % Stim_dur
                randsample(refphase,6)    randsample(refphase,6)     randsample(refphase,6)     randsample(refphase,6);      % Refreshment_dur                
                randsample(correct,6)     randsample(correct,6)      randsample(correct,6)      randsample(correct,6);       % Correct/Incorrect
                randsample(condition,6)   randsample(condition,6)    randsample(condition,6)    randsample(condition,6)];    % which condition will it be?

            
% stimphase & refphase into ms
Trials_all(2,:) = Trials_all(2,:)*1000;
Trials_all(3,:) = Trials_all(3,:)*1000;


% Randomizing order
trial_order = randperm(length(Trials_all));
for i = 1:length(trial_order)
    Trials(:,i) = Trials_all(:,trial_order(i));
end
clear i Trials_all trial_order;

%adding ITIs
Trials = [Trials; 
          randsample(repmat(ITIs,1,6),24,0)]; 
      
% make a vector that specifies when trial begins
Timing = [Init_Break];    % Start of first trial after X seconds

for i = 1:(length(Trials)-1)
                %last_onset + Sequence    + Rehearsal   + Response +  ITI
    next_onset = Timing(i)  + Trials(2,i) + Trials(3,i) + 1500     + Trials(6,i); % Adding of time

    Timing(i+1) = next_onset; 
    clear next_onset;
end

% Final Design Matrix of one run

Design = [ Timing      ;...      % 1:Trial_onset time in ms
           Trials(1,:) ;...      % 2:Which set of frequencies to use
           Trials(2,:) ;...      % 3:Stimulation duration
           Trials(3,:) ;...      % 4:Rehearsal/Refreshment Duration
           Trials(4,:) ;...      % 5:correct/incorrect
           Trials(5,:) ;...      % 6:experimental condition
           Trials(6,:) ];        % 7:ITI

%Clearing of unused variables
clear Timing Trials i Anfangspause ITIs correct refphase stimphase stimdur stimrate Init_Break condition;