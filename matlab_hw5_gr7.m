% Presentation of Auditory Stimuli %
% This script provides a demo of the 4 permutations of the set of 8  
% auditory stimuli that we will use in our paradigm. 
% Each permutation consists of 3 different tones varying
% in frequency. 

% Start by clearing the workspace
clearvars;
close all;
clear all; 
sca;

% Setup so that it will work (you might not need this, but uncomment if
% you get a error message regarding syncing !

Screen('Preference', 'SkipSyncTests',  1)

%---------------
% Sound Setup
%---------------

% Initialize Sounddriver
InitializePsychSound(1);

% Number of channels and Frequency of the sound
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
% INFO: See help PsychPortAudio
waitForDeviceStart = 1;

% Open Psych-Audio port, with the follow arguements
% (1) [] = default sound device
% (2) 1 = sound playback only
% (3) 1 = default level of latency
% (4) Requested frequency in samples per second
% (5) 2 = stereo putput
pahandle = PsychPortAudio('Open', [], 1, 1, freq, nrchannels);

% Set the volume to half for this demo
PsychPortAudio('Volume', pahandle, 0.5);

% Our frequency spectrum of tones (all 68Hz distance from each other,
% centured around 440Hz) & permutations are a set of 3 with always one 
% frequency that is 136 Hz (2 steps) away from an initial frequency and one
% that is 272 (4 steps) away from the second frequency

freqs = [169   237   305   372   440   508   575   643];

% Make a beep which we will play back to the user
Beeps = num2cell(zeros(1, length(freqs)));
for b=1:length(freqs)
    
    Beeps{b} = MakeBeep(freqs(b), beepLengthSecs, freq);
    
end
% Make permutations list (these won't always be presented in this order,
% but this is to check the discriminability of the different stimuli. In
% the end, every trial will present a randomized sequence of one of the
% premutations

Permutations = {};
Permutations{1} = [1 3 7];
Permutations{2} = [2 4 8];
Permutations{3} = [8 6 2];
Permutations{4} = [7 5 1];


%---------------
% Screen Setup
%--------------- 

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Select the external screen if it is present, else revert to the native
% screen
screenNumber = max(screens);

% Define black, white and grey
black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
%grey = white / 2;

% Open an on screen window and color it grey
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% Set the blend funciton for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Get the size of the on screen window in pixels
% For help see: Screen WindowSize?
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window in pixels
% For help see: help RectCenter
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

% improve portability of your code acorss operating systems 
KbName('UnifyKeyNames');
% specify key names of interest in the study
activeKeys = [KbName('LeftArrow') KbName('RightArrow')];
% set value for maximum time to wait for response (in seconds)
t2wait = 1.5; 
% if the wait for presses is in a loop, 
% then the following two commands should come before the loop starts
% restrict the keys for keyboard input to the keys we want
RestrictKeysForKbCheck(activeKeys);
% suppress echo to the command line for keypresses
ListenChar(2);

% one presentation of three stimuli 

for t = 1:1
    
    for p = 1:width(Permutations)
        
        for s = Permutations{p}
            
            % Fill Buffer with correct frequency tone
            PsychPortAudio('FillBuffer', pahandle, [Beeps{s}; Beeps{s}]);
            
            % Start audio playback #1
            PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);

            % Draw beep screen 
            for i = 1:beepLengthFrames

                % Draw the fixation cross in white, set it to the center of our screen and
                % set good quality antialiasing
               Screen('DrawLines', window, allCoords,...
               lineWidthPix, white, [xCenter yCenter], 2);

                % Flip to the screen
                Screen('Flip', window);

            end %end of beep text presentation on screen
            
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
           
        end % end permutation sequence
        
           for i = 1:numQuestion
                
                 % Draw text
                DrawFormattedText(window, '?', 'center', 'center', [0.5 0.5 0.5]);

                % Flip to the screen
                Screen('Flip', window);
                
                % get the time stamp at the start of waiting for key input 
                % so we can evaluate timeout and reaction time
                % tStart can also be the timestamp for the onset of the stimuli, 
                % for example the VBLTimestamp returned by the 'Flip'
                tStart = GetSecs;
                % repeat until a valid key is pressed or we time out
                timedout = false;
                % initialise fields for rsp variable 
                % that would contain details about the response if given
                rsp.RT = NaN; rsp.keyCode = []; rsp.keyName = [];
                
                
                while ~timedout,
                    % check if a key is pressed
                    % only keys specified in activeKeys are considered valid
                    [ keyIsDown, keyTime, keyCode ] = KbCheck; 
                      if(keyIsDown), break; end
                      if((GetSecs - tStart) > t2wait), timedout=true; break; end
                      
                      % time between iterations of KbCheck loop
                      % WaitSecs(0.001);
                end
                  
                  % store code for key pressed and reaction time
                  if(~timedout)
                      rsp.RT      = keyTime - tStart;
                      rsp.keyCode = keyCode;
                      rsp.keyName = KbName(rsp.keyCode);
                  end

                  % if the wait for presses is in a loop, 
                  %then the following two commands should come after the loop finishes
                  % reset the keyboard input checking for all keys
                  RestrictKeysForKbCheck;
                  % re-enable echo to the command line for key presses
                  % if code crashes before reaching this point 
                  % CTRL-C will reenable keyboard input
                  ListenChar(1)

           end 
    
        % Add waiting of 1sec until next sequence plays (for now, later
        % this will turn into some sort of pause between trials)
        % This may be able to be done more elegantly, I'm not yet sure
        % about how to just add a black screen for 1second and then move on
        % from the beginning of the Permutations loop
        
        for frame = 1:numFrames

            % Color the screen black
            Screen('FillRect', window, [0 0 0]); %back to black screen

            % Flip to the screen
            Screen('Flip', window);

        end %end waiting time between permutation set presentation
        
    end %end selection of permutation 
    
end %end trial

sca;
