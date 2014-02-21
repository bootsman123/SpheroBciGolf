initialize;

%% Inform the user about the phase
sendEvent('TEXT_VALUE',['Welcome to the Sphero Golf Game! '...
    'During the game you need hit a serie of holes.\n'...
    'You go from hole 1, to 2, to 3 and finally hole 4.\n'...
    'You can set the direction and speed of a stroke using imagined movements.']);
sendEvent('TEXT_SHOW',0);
pause(Settings.instructionTextDuration); 
pause(Settings.notificationTextDuration);
sendEvent('TEXT_HIDE',0);

%% Set time variables
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
    sendEvent('GOLFER_DIRECTION_VALUE',mod(-atan2(sin(directionValue-pi),cos(directionValue-pi)),2*pi)*180/pi); % Sphero directions are a bit different
    sendEvent('GOLFER_POWER_VALUE',powerValue);
    
    Logger.debug('phaseTesting', sprintf('Direction valaue: %f\n',directionValue));
    Logger.debug('phaseTesting', sprintf('Power value: %f\n',powerValue));
    Logger.debug('phaseTesting', sprintf('Direction to robot: %f\n',mod(-atan2(sin(directionValue-pi),cos(directionValue-pi)),2*pi)*180/pi));
    Logger.debug('phaseTesting', sprintf('Power to robot: %f\n',powerValue));
    
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