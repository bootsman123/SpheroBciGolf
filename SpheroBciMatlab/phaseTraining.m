initialize;

% Target sequence.
targets = mkStimSeqRand(Settings.numberOfSymbols, Settings.numberOfSequences);

sendEvent('stimulus.training','start');
sendEvent('TEXT_VALUE', 'Welcome to the training phase!\nIn the following minutes you will see some arrows pointing clockwise (right) or counter clockwise (left).\nPlease imagine the direction of each arrow when it is displayed.');
sendEvent('TEXT_SHOW',0);

pause(10); % Pause for a while to let Java draw
sendEvent('TEXT_HIDE',0);
sendEvent('DIRECTION_METER_RESET',0);
sendEvent('DIRECTION_METER_SHOW',0);

for index = 1:Settings.numberOfSequences
    Logger.debug('phaseTraining', sprintf('[Sequence %d]: Target %d', index, find(targets(:,index) > 0)));
	
    pause(Settings.interTrialDuration);
    sendEvent('stimulus.baseline','start');
	
    pause(Settings.baselineDuration);
    sendEvent('stimulus.baseline','end');

    sendEvent('stimulus.target', find(targets(:,index) > 0));
    if(find(targets(:,index)>0) == 1)
        sendEvent('DIRECTION_METER_ROTATION','CLOCKWISE');
    else
        sendEvent('DIRECTION_METER_ROTATION','COUNTER_CLOCKWISE');
    end
	
    sendEvent('stimulus.trial','start');
    pause(Settings.trialDuration);
    
    sendEvent('DIRECTION_METER_RESET',0);
    sendEvent('stimulus.trial','end');
end

%% End training.
sendEvent('DIRECTION_METER_HIDE', 0);
sendEvent('stimulus.training', 'end');

sendEvent('TEXT_VALUE', 'That ends the training phase.\nThanks for your patience!');
sendEvent('TEXT_SHOW', 0);
pause(5);
sendEvent('TEXT_HIDE', 0);

Logger.debug('phaseTraining', 'Training phase ended.');