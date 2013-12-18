configureIM();

% make the target sequence
tgtSeq=mkStimSeqRand(nSymbs,nSeq);

sendEvent('stimulus.testing','start');
sendEvent('DIRECTION_METER_VALUE', pi/2);
sendEvent('DIRECTION_METER_SHOW');

endTesting=false; dvs=[];
for si=1:nSeq;  
    sleepSec(intertrialDuration);
    sendEvent('BASELINE_SHOW');
    sendEvent('stimulus.baseline','start');
    sleepSec(baselineDuration);
    sendEvent('BASELINE_HIDE');
    sendEvent('stimulus.baseline','end');
    
    % show the target
    fprintf('%d) tgt=%d : ',si,find(tgtSeq(:,si)>0));
    
    sendEvent('stimulus.target',find(tgtSeq(:,si)>0));
    if(find(tgtSeq(:,si)>0) == 1)
        sendEvent('DIRECTION_METER_VALUE', 0);
    else
        sendEvent('DIRECTION_METER_VALUE', pi);
    end
    sendEvent('stimulus.trial','start');
    
    % initial fixation point position
    dvs(:)=0; nPred=0; state=[];
    trlStartTime=getwTime();
    timetogo = trialDuration;
    while (timetogo>0)
        timetogo = trialDuration - (getwTime()-trlStartTime); % time left to run in this trial
        % wait for events to process *or* end of trial *or* out of time
        [dat,events,state]=buffer_waitData(buffhost,buffport,state,'exitSet',{timetogo*1000 {'stimulus.prediction' 'stimulus.testing'}},'verb',verb);
        for ei=1:numel(events);
            ev=events(ei);
            if ( strcmp(ev.type,'stimulus.prediction') )
                pred=ev.value;
                % now do something with the prediction....
                if ( numel(pred)==1 )
                    if ( pred>0 && pred<=nSymbs && isinteger(pred) ) % predicted symbol, convert to dv equivalent
                        tmp=pred; pred=zeros(nSymbs,1); pred(tmp)=1;
                    else % binary problem, convert to per-class
                        pred=[pred -pred];
                    end
                end
                nPred=nPred+1;
                dvs(:,nPred)=pred;
                if ( verb>=0 )
                    fprintf('dv:');fprintf('%5.4f ',pred);fprintf('\n');
                end;
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
    dv = sum(dvs,2); prob=1./(1+exp(-dv)); prob=prob./sum(prob);
    if ( verb>=0 )
        fprintf('dv:');fprintf('%5.4f ',pred);fprintf('\t\tProb:');fprintf('%5.4f ',prob);fprintf('\n');
    end;
    [ans,predTgt]=max(dv); % prediction is max classifier output
    
    % predicaion is made, now display the prediction
    % TODO: maybe we need to give this feedback another color
    sendEvent('stimulus.predTgt',predTgt);
    if(predTgt == 1)
        sendEvent('DIRECTION_METER_VALUE', 0);
    else
        sendEvent('DIRECTION_METER_VALUE', pi);
    end
    
    sleepSec(feedbackDuration);
    
    sendEvent('DIRECTION_METER_VALUE', pi/2);
    sendEvent('stimulus.trial','end');
    
    ftime=getwTime();
    fprintf('\n');
end % loop over sequences in the experiment
% end training marker
sendEvent('DIRECTION_METER_HIDE');
sendEvent('stimulus.testing','end');
text(mean(get(ax,'xlim')),mean(get(ax,'ylim')),{'That ends the testing phase.','Thanks for your patience'},'HorizontalAlignment','center','color',[0 1 0],'fontunits','normalized','FontSize',.1);
pause(3);