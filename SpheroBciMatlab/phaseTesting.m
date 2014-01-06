initialize;

%% Inform the user about the phase
sendEvent('TEXT_VALUE',['Welcome to the Sphero Golf Game!\n'...
    'During the game you need to perform a set of moves in order to reach the hole.']);
sendEvent('TEXT_SHOW',0);
pause(Settings.instructionTextDuration); 
sendEvent('TEXT_VALUE','Please get ready to make your first move.');
pause(Settings.instructionTextDuration); 
sendEvent('TEXT_HIDE',0);

%% Set time variables
gameStartTime=getwTime();
gameDuration = 60*60;
timeLeft=gameDuration;

%% Run the game
while (timeLeft>0)
	timeLeft = gameDuration - (getwTime() - gameStartTime);
  
	%% Initialise the Sphero command   
    Sphero.power = 0.5;
    Settings.sphero.angle = 0.5*pi;
  
    %% Let the user plan a move
    sendEvent('TEXT_VALUE','Take a look at the golf course and plan your next move.');
    sendEvent('TEXT_SHOW',0);
    pause(Settings.instructionTextDuration); 
    sendEvent('TEXT_HIDE',0);
    sendEvent('WEBCAM_SHOW',0);
    pause(Settings.webcamShowDuration); 
    sendEvent('WEBCAM_HIDE',0);
    
    %% Let the user imagine the direction and power of the move
    epochType = 'DIRECTION';
    epochOnline();
    epochType = 'POWER';
    epochOnline();
    
    %% Let the Spehere perform the move
    sendEvent('TEXT_VALUE','Now, it is time to let the Sphero move.');
    sendEvent('TEXT_SHOW',0);
    pause(Settings.instructionTextDuration ); 
    sendEvent('TEXT_HIDE',0);
    sendEvent('WEBCAM_SHOW',0);
    sendEvent('GOLFER_DIRECTION_VALUE',radtodeg(Settings.sphero.angle));
    sendEvent('GOLFER_POWER_VALUE',Settings.sphero.power);
    pause(Settings.webcamShowDuration);
    sendEvent('GOLFER_SHOOT',0);
    pause(Settings.webcamShowDuration); 
    sendEvent('WEBCAM_HIDE',0);
end 

sendEvent('stimulus.training','end');

%% Thanks message
sendEvent('TEXT_VALUE',['That ends the game phase. ' ... 
   'Thanks for your patience']);
sendEvent('TEXT_SHOW',0);
pause(5);
sendEvent('TEXT_HIDE',0);
