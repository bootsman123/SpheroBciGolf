configureIM();

% make the target sequence
tgtSeq=mkStimSeqRand(nSymbs,nSeq);

sendEvent('stimulus.training','start');
sendEvent('TEXT_VALUE',['Welcome to the training phase! In the following '...
    'minutes you will see some arrows pointing clockwise (right) or counter clockwise (left). ' ... 
   'Please imagine the direction of each arrow when it is displayed.']);
sendEvent('TEXT_SHOW');

pause(10); % Pause for a while to let Java draw
sendEvent('TEXT_HIDE');
sendEvent('DIRECTION_METER_RESET');
sendEvent('DIRECTION_METER_SHOW');

for si=1:nSeq;
    sleepSec(intertrialDuration);
    sendEvent('stimulus.baseline','start');
    sleepSec(baselineDuration);
    sendEvent('stimulus.baseline','end');
      
    % show the target
    fprintf('%d) tgt=%d : ',si,find(tgtSeq(:,si)>0));

    sendEvent('stimulus.target',find(tgtSeq(:,si)>0));
    if(find(tgtSeq(:,si)>0) == 1)
        sendEvent('DIRECTION_METER_CLOCKWISE');
    else
        sendEvent('DIRECTION_METER_COUNTER_CLOCKWISE');
    end
    sendEvent('stimulus.trial','start');
    sleepSec(trialDuration);
    
    sendEvent('DIRECTION_METER_RESET');
    sendEvent('stimulus.trial','end');
    
    ftime=getwTime();
    fprintf('\n');
end % sequences
% end training marker
sendEvent('DIRECTION_METER_HIDE');
sendEvent('stimulus.training','end');

% thanks message
sendEvent('TEXT_VALUE',['That ends the training phase. ' ... 
   'Thanks for your patience']);
sendEvent('TEXT_SHOW');
pause(5);
sendEvent('TEXT_HIDE');