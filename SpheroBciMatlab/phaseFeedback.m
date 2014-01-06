initialize;

% make the target sequence
targets = mkStimSeqRand(Settings.numberOfSymbols, Settings.numberOfSequences);

sendEvent('stimulus.testing', 'start');
sendEvent('TEXT_VALUE', 'Congratulations, you succesfully fullfilled the training phase!\nNow, you have to imagine some movements again.\nHowever, this time we will present to you our prediction of the movement you imagined.');
sendEvent('TEXT_SHOW', 0);

pause(Settings.instructionTextDuration);
sendEvent('TEXT_HIDE',0);
sendEvent('DIRECTION_METER_RESET',0);
sendEvent('DIRECTION_METER_SHOW',0);

endTesting=false;
dvs=[];

for index = 1:Settings.numberOfSequences
    Logger.debug('phaseFeedback', sprintf('[Sequence %d]: Target %d', index, find(targets(:,index) > 0)));
	
    sleepSec(Settings.interTrialDuration);
    sendEvent('stimulus.baseline','start');
    sleepSec(Settings.baselineDuration);
    sendEvent('stimulus.baseline','end');
    
    sendEvent('stimulus.target',find(targets(:,index) > 0));
    if(find(targets(:,index)>0) == 1)
        sendEvent('DIRECTION_METER_ROTATION','CLOCKWISE');
    else
        sendEvent('DIRECTION_METER_ROTATION','COUNTER_CLOCKWISE');
    end
    sendEvent('stimulus.trial','start');
   
    % initial fixation point poindextion
    dvs(:)=0; nPred=0; state=[];
    trlStartTime=getwTime();
    timetogo = Settings.trialDuration;
    while (timetogo>0)  
        Logger.debug('phaseFeedback', sprintf('Time to go: %d.\n', timetogo));
        timetogo = Settings.trialDuration - (getwTime()-trlStartTime); % time left to run in this trial
        % wait for events to process *or* end of trial *or* out of time
        [dat,events,state]=buffer_waitData(Settings.buffer.host,Settings.buffer.port,state,'exitSet',{timetogo*1000 {'stimulus.prediction' 'stimulus.testing'}},'verb',Settings.verbose);
        Logger.debug('phaseFeedback', sprintf('We have %d events.\n', numel(events)));
        
        for ei=1:numel(events);
            ev=events(ei);
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
                nPred=nPred+1;
                dvs(:,nPred)=pred;
                Logger.debug('phaseFeedback',sprintf('dv: %5.4f \n', pred));
            elseif ( strcmp(ev.type,'stimulus.testing') )
                endTesting=true; 
                break;
            end % prediction events to processa
        end % if feedback events to process
        if ( endTesting ) 
            break; 
        end;
    end % loop accumulating prediction events
    
    % give the feedback on the predicted class
    dv = sum(dvs,2);
	prob=1./(1+exp(-dv));
	prob=prob./sum(prob);
	
	Logger.debug('phaseTrainingFeedback', sprintf('[Prediction]: %5.4f (%5.4f)', pred, prob));

    [ans,predTgt]=max(dv); % prediction is max clasindexfier output
    
    % predicaion is made, now display the prediction
    % TODO: maybe we need to give this feedback another color
    sendEvent('stimulus.predTgt',predTgt);
    sendEvent('DIRECTION_METER_RESET',0);
    if(predTgt == 1)
        sendEvent('DIRECTION_METER_VALUE', 0);
    else
        sendEvent('DIRECTION_METER_VALUE', pi);
    end
    sleepSec(Settings.feedbackDuration);
    
    sendEvent('DIRECTION_METER_RESET',0);
    sendEvent('stimulus.trial','end');
    
    ftime = getwTime();
end

%% End training.
sendEvent('DIRECTION_METER_HIDE',0);
sendEvent('stimulus.testing','end');

sendEvent('TEXT_VALUE', 'That ends the feedback phase.\nThanks for your patience!');
sendEvent('TEXT_SHOW',0);
pause(Settings.instructionTextDuration);
sendEvent('TEXT_HIDE',0);