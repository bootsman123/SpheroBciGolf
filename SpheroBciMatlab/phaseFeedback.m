initialize;

% make the target sequence
targets = mkStimSeqRand(Settings.numberOfSymbols, Settings.numberOfSequences);

sendEvent('stimulus.testing', 'start');
sendEvent('TEXT_VALUE', ['Welcome back! Now, you have to imagine some movements again.\n'...
    'However, this time we will present to you our prediction of the imagined movement.']);
sendEvent('TEXT_SHOW', 0);
pause(Settings.instructionTextDuration);
sendEvent('TEXT_HIDE',0);
sendEvent('DIRECTION_METER_RESET',0);
sendEvent('DIRECTION_METER_SHOW',0);

endTesting = false;
dvs = [];

for index = 1:Settings.numberOfSequences
    Logger.debug('phaseFeedback', sprintf('[Sequence %d]: Target %d', index, find(targets(:,index) > 0)));
	
    pause(Settings.interTrialDuration);
    sendEvent('stimulus.baseline','start');
    pause(Settings.baselineDuration);
    sendEvent('stimulus.baseline','end');
    
    sendEvent('stimulus.target',find(targets(:,index) > 0));
    if(find(targets(:,index)>0) == 1)
        sendEvent('DIRECTION_METER_ROTATION','CLOCKWISE');
    else
        sendEvent('DIRECTION_METER_ROTATION','COUNTER_CLOCKWISE');
    end
    sendEvent('stimulus.trial','start');
   
    % initial fixation point poindextion
    dvs(:) = 0;
    numberOfPredictions = 0;
    state = [];
    
    trialTimeStart = clock;
    trialTimeLeft = Settings.trialDuration * 1000;
    
    while (trialTimeLeft > 0)  
        trialTimeLeft = Settings.trialDuration * 1000 - round(etime(clock, trialTimeStart) * 1000);
        
        [dat, events, state] = buffer_waitData(Settings.buffer.host, Settings.buffer.port, state, 'exitSet', {trialTimeLeft {'stimulus.prediction' 'stimulus.testing'}}, 'verb', Settings.verbose);
        for ei=1:numel(events);
            ev = events(ei);
            if ( strcmp(ev.type,'stimulus.prediction') )
                pred=ev.value;
                % now do something with the prediction....
                if ( numel(pred)==1 )
                    if ( pred>0 && pred<=Settings.numberOfSymbols && isinteger(pred) ) % predicted symbol, convert to dv equivalent
                        tmp=pred; pred=zeros(Settings.numberOfSymbols,1); pred(tmp)=1;
                    else % binary problem, convert to per-class
                        pred=[pred -pred];
                    end
                end
                numberOfPredictions = numberOfPredictions + 1;
                dvs(:,numberOfPredictions) = pred;
                Logger.debug('phaseFeedback', sprintf('dv: %5.4f', pred));
            elseif ( strcmp(ev.type,'stimulus.testing') )
                endTesting=true; 
                break;
            end
        end
        if ( endTesting ) 
            break; 
        end;
    end
    
    %% Determine prediction.
    dv = sum(dvs,2);
	prob=1./(1+exp(-dv));
	prob=prob./sum(prob);
	
	Logger.debug('phaseFeedback', sprintf('Prediction: %5.4f (%5.4f)', pred, prob));

    [~, prediction]=max(dv); % prediction is max clasindexfier output
    
    %% Display prediction.
    sendEvent('stimulus.predTgt', prediction);
    sendEvent('DIRECTION_METER_RESET', 0);
    if(prediction == 1)
        sendEvent('DIRECTION_METER_VALUE', 0);
    else
        sendEvent('DIRECTION_METER_VALUE', pi);
    end
    pause(Settings.feedbackDuration);
    
    sendEvent('DIRECTION_METER_RESET', 0);
    sendEvent('stimulus.trial','end');
    
    ftime = getwTime();
end

%% End training.
sendEvent('DIRECTION_METER_HIDE',0);
sendEvent('stimulus.testing','end');

sendEvent('TEXT_VALUE', 'That ends the feedback phase.\nThanks for your patience!');
sendEvent('TEXT_SHOW',0);
pause(Settings.notificationTextDuration);
sendEvent('TEXT_HIDE',0);

Logger.debug('phaseFeedback', 'Feedback phase ended.');