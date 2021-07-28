%% FULL CODE %%

% Start by clearing the workspace
clearvars;
close all;
clear all; 
sca;


%% EXPERIMENTAL DESIGN MATRIX %%

% We want to have a design matrix of one run in the end which includes the
% timing of the trial start, which of the 4 sequences we have will be used,
% stimulus duration (in ms with stimuli presentation of 1Hz), rehearsal
% duration (in ms, in the same rhythm as stimulus presentation), if the
% trial should present the correct or an incorrect stimulus as target, the
% condition (either PLAY (1) or HOLD (2)), and lastly the inter trial 
% interval between the response and the beginning of the next trial.

% global information for trials

ITIs             = [3000 4000 5000 6000]; % in ms
Init_Break       = 1500; %when to start the first trial after beginning of the run
stimdur          = 600; %how long is a beep played? 
stimrate         = 1000;  % Rate of presented beeps in stimphase



% initializing the different types of correct/incorrect trials, and the
% durations of stimulus presentation & rehearsal + condition (play = 1,
% hold = 2) -> same as in original paper

correct   = [1 1 1 0 0 0];
stimphase = [6 6 8 8 10 10];
refphase  = [6 6 8 8 10 10];
condition = [1 1 1 2 2 2];

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
clear Timing Trials i Anfangspause ITIs correct refphase stimphase Init_Break condition;


%% MATLAB-LOGFILE of response collection & design matrix
log_aud.date         = date;
log_aud.time         = clock;
log_aud.responses    = zeros(7,24); 
% 1: RT 
% 2: correct or incorrect target (1 or 0)
% 3: which key pressend (right = 1, left = 0)
% 4: was trial correctly responded to? (1 or 0)
% 5: trial condition (1 = PLAY, 2 = HOLD)
% 6: was there a timeout?
% 7: participant id

participant          = 1;
participant_name     = 'P01';
log_path  = fullfile(pwd, [participant_name, '_Response.mat']);
save(log_path, 'log_aud'); %saving response collection
run_path = fullfile(pwd, [participant_name, '_RunInfo.mat']);
save(run_path, 'Design') %saving design matrix 

%% RUN %%
try 

% Setup so that it will work (you might not need this, but uncomment if
% you get a error message regarding syncing !

Screen('Preference', 'SkipSyncTests',  1);

%---------------
% Sound Setup
%---------------

% Initialize Sounddriver
InitializePsychSound(1);

% Number of channels and sample frequency of the sound
nrchannels = 2;
freq = 48000;

% How many times do we wish to play the sound
repetitions = 1;

% Length of the beep
beepLengthSecs = 0.6;

% Length of the pause between beeps
beepPauseTime = 0.4;

% Start immediately (0 = immediately)
startCue = 0;

% Should we wait for the device to really start (1 = yes)
waitForDeviceStart = 1;

% Open Psych-Audio port, with the follow arguements
% (1) [] = default sound device
% (2) 1 = sound playback only
% (3) 1 = default level of latency
% (4) Requested frequency in samples per second
% (5) 2 = stereo putput
pahandle = PsychPortAudio('Open', [], 1, 1, freq, nrchannels);

% Set the volume to half
PsychPortAudio('Volume', pahandle, 0.5);

% Our frequency spectrum of tones (all 68Hz distance from each other,
% centured around 440Hz) & sequences are a set of 3 with always one 
% frequency that is 136 Hz (2 steps) away from an initial frequency and one
% that is 272 (4 steps) away from the second frequency, resulting in 4
% sequences

freqs = [169   237   305   372   440   508   575   643];

% Make a beep which we will play back to the user
Beeps = num2cell(zeros(1, length(freqs)));
for b=1:length(freqs)
    
    Beeps{b} = MakeBeep(freqs(b), beepLengthSecs, freq);
    
end

% Make permutations list. In the end, every trial will present a random 
% permutation of one of the sequences

Permutations = {};
Permutations{1} = [1 3 7];
Permutations{2} = [2 4 8];
Permutations{3} = [8 6 2];
Permutations{4} = [7 5 1];


%---------------
% Screen Setup
%--------------- 

% ome default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Select the external screen if it is present, else revert to the native
% screen
screenNumber = max(screens);

% Define black, white
black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);

% Open an on screen window and color it black
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% Set the blend funciton for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Get the size of the on screen window in pixels
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window in pixels
[~, ~] = RectCenter(windowRect);

% Set the text size
Screen('TextSize', window, 100);

% Calculate how long the beep and pause are in frames + how long between
% presentations of 3 sound sequences (for now) which we'll set to 1sec
beepLengthFrames = round(beepLengthSecs / ifi);
beepPauseLengthFrames = round(beepPauseTime / ifi);
numSecs = 1;
numFrames = round(numSecs / ifi);
numQuestion = round(1.5/ifi); 


% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 40;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 4;
lineWidthPix2 = 2;

%---RESPONSE COLLECTION 
%starting timer
tic;  % time counter

% improve portability of your code acorss operating systems 
KbName('UnifyKeyNames');
% specify key names of interest in the study
activeKeys = [KbName('LeftArrow') KbName('RightArrow')];
activeKeys_name = ["LeftArrow" "RightArrow"];
RestrictKeysForKbCheck(activeKeys);
% set value for maximum time to wait for response (in seconds)
t2wait = 1.5; 


for t = 1:4 %length(Design)
    
    current_trial = Design(:,t);
    shuffled_perm = Shuffle(Permutations{current_trial(2)});
    rep_seq = repmat(shuffled_perm,1,8);
    current_seq = rep_seq(1:current_trial(3)/stimrate);
    rehearsal_dur = current_trial(4)/stimrate;
    Beep_play = rep_seq((length(current_seq)+rehearsal_dur)-1+current_trial(5));
    Beep_hold = current_seq(end-1+current_trial(5));
    tStart = toc;
    ListenChar(2) 
    
    if t == 1
        while toc <= current_trial(1)/1000 - 0.5
        end
        % Draw fixation cross 0.5sec before first tone of run
        Screen('DrawLines', window, allCoords,...
        lineWidthPix2, white, [xCenter yCenter], 2);
        % Flip to the screen
        Screen('Flip', window);    
    end
    
    
    while toc <= current_trial(1)/1000 
    end
    
    % AUDIO PRESENTATION PHASE %
    
    for p = 1:length(current_seq)
        
        
        % Fill Buffer with correct frequency tone
            PsychPortAudio('FillBuffer', pahandle, [Beeps{current_seq(p)}; Beeps{current_seq(p)}]);
            
            % Start audio playback #1
            PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
            
            if p < length(current_seq)
                
                % Draw beep screen 
                for i = 1:beepLengthFrames

                    % Draw the fixation cross in white, set it to the center of our screen and
                    % set good quality antialiasing
                   Screen('DrawLines', window, allCoords,...
                   lineWidthPix, white, [xCenter yCenter], 2);

                    % Flip to the screen
                    Screen('Flip', window);

                end %end of beep text presentation on screen
                
            else 
                
                % Draw beep screen 
                for i = 1:beepLengthFrames

                   % Draw the CONDITION CUE
                   if current_trial(6) == 1 %play condition 
                   
                       DrawFormattedText(window, 'PLAY', 'center', 'center', [0.5 0.5 0.5]);
                       
                   else
                       
                       DrawFormattedText(window, 'HOLD', 'center', 'center', [0.5 0.5 0.5]);
                    
                   end    
                    % Flip to the screen
                    Screen('Flip', window);

                end %end of beep text presentation on screen
            end
            
            % Stop Audio
            PsychPortAudio('Stop', pahandle);

            % Silence 
            for i = 1:beepPauseLengthFrames

                % Draw text
                Screen('DrawLines', window, allCoords,...
                lineWidthPix2, white, [xCenter yCenter], 2);

                % Flip to the screen
                Screen('Flip', window);

            end %end of silence presentation on screen

    end % end presentation of one stimuli  

    % REHEARSAL PHASE %
    
    for r = 1:rehearsal_dur
        
        if r < rehearsal_dur
        
            % Draw beep screen (bold fixation cross)
            for i = 1:beepLengthFrames

                % Draw the fixation cross in white, set it to the center of our screen and
                % set good quality antialiasing
               Screen('DrawLines', window, allCoords,...
               lineWidthPix, white, [xCenter yCenter], 2);

                % Flip to the screen
                Screen('Flip', window);

            end %end of beep text presentation on screen

            % Silence (normal fixation cross)
            for i = 1:beepPauseLengthFrames

                % Draw text
                Screen('DrawLines', window, allCoords,...
                lineWidthPix2, white, [xCenter yCenter], 2);

                % Flip to the screen
                Screen('Flip', window);

            end %end of silence presentation on screen
            
        else
            
            % Fill Buffer with correct frequency tone
            if current_trial(6) == 1 %play condition 
                
                PsychPortAudio('FillBuffer', pahandle, [Beeps{Beep_play}; Beeps{Beep_play}]);
            
            else
                
                PsychPortAudio('FillBuffer', pahandle, [Beeps{Beep_hold}; Beeps{Beep_hold}]);
                
            end    
            
            % Start audio playback of target stimulus
            PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
            
            timedout = true;
            tStart = toc;
            for i = 1:numQuestion
                
                 % Draw text
                DrawFormattedText(window, '?', 'center', 'center', [0.5 0.5 0.5]);

                % Flip to the screen
                Screen('Flip', window);
                
                %waiting for pressing right or left arrow
                [secs, keyCode, deltaSecs] = KbWait([], 2, t2wait);
                
                %if ~isempty(KbName(keyCode)) & ismember(KbName(keyCode), activeKeys_name)
                % not needed if RestrictKeysForKbCheck is defined correctly
                
                  % store code for key pressed and reaction time
                  if(string(KbName(keyCode))~="")
               
                      % a valid key was pressed so we didn't time out
                      timedout = false;
                      
                      log_aud.responses(1,t) = toc - tStart; % time
                      log_aud.responses(3,t) = (KbName(keyCode) == "RightArrow"); % recording 1 for right and 0 for left arrow
                      if (KbName(keyCode) == "RightArrow" && current_trial(5) == 1) || (KbName(keyCode) == "LeftArrow" && current_trial(5) == 0)
                          log_aud.responses(4,t) = 1; % participant correct
                      else
                          log_aud.responses(4,t) = 0; %participant incorrect
                      end
                      log_aud.responses(2,t) = current_trial(5); % stimuli is the correct target
                      log_aud.responses(5,t) = current_trial(6); % trial condition type
                      log_aud.responses(7,t) = participant; % participant id
                      break;
                
                  end
                  
                %end % end of checking if one of the two correct keys were pressed
                
                % re-enable echo to the command line for key presses
                % if code crashes before reaching this point 
                % CTRL-C will reenable keyboard input
                ListenChar(0)

            end 
            
            if timedout == 1 %adding information for timedout trial
                
                log_aud.responses(2,t) = current_trial(5);  % stimuli matched    
                log_aud.responses(5,t) = current_trial(6);  % trial condition type
                log_aud.responses(7,t) = participant;       % participant id
                log_aud.responses(6,t) = 1;                 % timedout: yes
                
            end    
            
            % Stop Audio
            PsychPortAudio('Stop', pahandle);
            
        end
    
    end
    
    
    
        % Add 1.5sec with feddback display or timedout

        for frame = 1:(numFrames*1.5)
            
            % show if timedout or correct/incorrect
            if timedout == 1
                DrawFormattedText(window, 'timed out', 'center', 'center', [1 0 0]);
            elseif  log_aud.responses(4,t) == 1
               DrawFormattedText(window, ' + + + ', 'center', 'center', [0 1 0]);
            elseif log_aud.responses(4,t) == 0
                DrawFormattedText(window, ' - - - ', 'center', 'center', [1 0 0]);
            end
            
            % Flip to the screen
            Screen('Flip', window);

        end %end showing feedback
        
    %always save log file after every run to have data even if programm crashes
    save(log_path, 'log_aud');
 
        
    for frame = 1:(numFrames)    
        Screen('FillRect', window, [0 0 0]); %back to black screen
        Screen('Flip', window);
    end
    
    if t<length(Design) %drawing fixation cross 1 second before first tone
        while toc <= Design(1,t+1)/1000 - 1
        end
        % Draw fixation cross
        Screen('DrawLines', window, allCoords,...
        lineWidthPix2, white, [xCenter yCenter], 2);

        % Flip to the screen
        Screen('Flip', window);
    end    

end

for frame = 1:(numFrames*3) %short display of performance for 3 seconds
    
    DrawFormattedText(window, ['Performance: ', char(string(round((sum(log_aud.responses(4,:))/t)*100, 1))), '%'], 'center', 'center', [0.5 0.5 0.5]);
    Screen('Flip', window);
    
end

for frame = 1:(numFrames*1.5) %short black screen of 1.5sec for not automatically shutting down after performance presentation
    
    Screen('FillRect', window, [0 0 0]); %back to black screen
    Screen('Flip', window);
    
end


sca;

catch ME
    
    sca;
    rethrow(ME);
    
end