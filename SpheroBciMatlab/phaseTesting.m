initialize;

%% Inform the user about the phase
sendEvent('TEXT_VALUE',['Welcome to the Sphero Golf Game!\n'...
    'During the game you need to perform a set of strokes in order to reach the hole.\n'...
    'You can set the direction and speed of a stroke during imagined movements.']);
sendEvent('TEXT_SHOW',0);
pause(Settings.instructionTextDuration); 
sendEvent('TEXT_HIDE',0);

%% Set time variables
gameStartTime=getwTime();
strokesLeft = Settings.numberOfStrokes;

%% Run the game
while (strokesLeft > 0) 
	%% Initialise the Sphero command   
    powerValue = Settings.power.default;
    directionValue = Settings.direction.default;
  
    %% Let the user plan a move
    if(strokesLeft > 1)
        numStrokesNotificaton = sprintf('You have %d strokes left.\n',strokesLeft);
    else
        numStrokesNotificaton = 'This is your last attempt to hit the Shero into the hole.\n';
    end;
    sendEvent('TEXT_VALUE',[numStrokesNotificaton...
        'You can now plan your next move.\n']);
    sendEvent('TEXT_SHOW',0);
    pause(Settings.notificationTextDuration); 
    sendEvent('TEXT_HIDE',0);
    sendEvent('WEBCAM_SHOW',0);
    pause(Settings.webcamShowDuration); 
    sendEvent('WEBCAM_HIDE',0);
    
    %% Let the user imagine the direction and power of the move
    epochType = 'DIRECTION';
    epochOnline;
    epochType = 'POWER';
    epochOnline;
    
    %% Let the Spehere perform the move
    sendEvent('TEXT_VALUE','Now, it is time to hit the Sphero.');
    sendEvent('TEXT_SHOW',0);
    sendEvent('GOLFER_DIRECTION_VALUE',radtodeg(directionValue));
    sendEvent('GOLFER_POWER_VALUE',powerValue);
    pause(Settings.notificationTextDuration); 
    sendEvent('TEXT_HIDE',0);
    sendEvent('WEBCAM_SHOW',0);
    pause(Settings.webcamShowDuration);
    sendEvent('GOLFER_SHOOT',0);
    pause(Settings.webcamShowDuration); 
    sendEvent('WEBCAM_HIDE',0);
    
    strokesLeft = strokesLeft - 1;
end 

sendEvent('stimulus.training','end');

%% Thanks message
sendEvent('TEXT_VALUE',['That ends the game phase.\n' ... 
   'Thanks for your patience']);
sendEvent('TEXT_SHOW',0);
pause(Settings.notificationTextDuration); 
sendEvent('TEXT_HIDE',0);

Logger.debug('phaseTesting', 'Testing phase ended');