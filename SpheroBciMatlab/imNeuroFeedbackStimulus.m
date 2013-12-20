configureIM();

sendEvent('stimulus.testing','start');

%% Inform the user about the phase
sendEvent('TEXT_VALUE',['Welcome to the Sphero Golf Game!\n'...
    'During the game you need to perform a set of moves in order to reach the hole.']);
sendEvent('TEXT_SHOW',0);
pause(5); 
sendEvent('TEXT_VALUE','Please get ready to make your first move.');
pause(2); 
sendEvent('TEXT_HIDE',0);

%% Set time variables
gameStartTime=getwTime();
gameDuration = 60*60;
timeLeft=gameDuration;

% TODO: Implement Sphero move
% Pseudocode:
% while (game_is_playing)
%     Now perform an move, a move has the following sequence:
%     - Show webcam, reset direction, reset dv array, etc.
%     - Set direction (another while loop: for about 10 seconds the user can imagine moves)
%     - Set power (another while loop: for about 10 seconds the user can imagine moves)
%     - Perform move, show move on webcam
% end

while (timeLeft>0)
	timeLeft = gameDuration - (getwTime() - gameStartTime);
  
	%% Initialise the Sphero command
    SpheroCommand.angle = 0;
    SpheroCommand.velocity = 100;
    SpheroCommand.duration = 2500;
  
    sendEvent('TEXT_VALUE','Take a look at the golf course and plan your next move.');
    sendEvent('TEXT_SHOW',0);
    pause(2); 
    sendEvent('TEXT_HIDE',0);
    sendEvent('WEBCAM_SHOW',0);
    pause(5); 
    sendEvent('WEBCAM_HIDE',0);
    moveDirection = epochOnline('DIRECTION');
    SpheroCommand.angle = mod(moveDirection*30,360); % TODO: calculate the amount of degrees per step  
    movePower = epochOnline('POWER');
    SpheroCommand.duration = SpheroCommand.duration+movePower*300;
    SpheroCommand.duration = max(min(MAXIMUM_DURATION, Sphero.duration),MINIMUM_DURATION);
    sendEvent('TEXT_VALUE','Now, it is time to let the Sphero move.');
    sendEvent('TEXT_SHOW',0);
    pause(2); 
    sendEvent('TEXT_HIDE',0);
    sendEvent('WEBCAM_SHOW',0);
    pause(1);
    sendEvent('golfer.shoot',[num2str(SpheroCommand.angle) ',' num2str(SpheroCommand.velocity) ',' num2str(SpheroCommand.duration)]);
    pause(5); 
    sendEvent('WEBCAM_HIDE',0);
end % loop over epochs in the sequence

sendEvent('stimulus.training','end');

%% thanks message
sendEvent('TEXT_VALUE',['That ends the game phase. ' ... 
   'Thanks for your patience']);
sendEvent('TEXT_SHOW',0);
pause(5);
sendEvent('TEXT_HIDE',0);
