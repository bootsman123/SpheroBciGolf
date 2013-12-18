configureIM();

% make the target sequence
tgtSeq=mkStimSeqRand(nSymbs,nSeq);

sendEvent('stimulus.training','start');
sendEvent('DIRECTION_METER_SHOW');
sendEvent('DIRECTION_METER_SHOW');
sendEvent('DIRECTION_METER_SHOW');

pause(2); % Pause for a while to let Java draw

for si=1:nSeq;
        
    sleepSec(intertrialDuration);

    sendEvent('BASELINE_SHOW');
    sendEvent('stimulus.baseline','start');
    
    sleepSec(baselineDuration);
    sendEvent('BASELINE_HIDE');
    sendEvent('stimulus.baseline','end');
    
    
    % show the target
    fprintf('%d) tgt=%d : ',si,find(tgtSeq(:,si)>0));
    %   set(h(tgtSeq(:,si)>0),'facecolor',tgtColor);
    %   set(h(tgtSeq(:,si)<=0),'facecolor',bgColor);
    %   set(h(end),'facecolor',[0 1 0]); % green fixation indicates trial running
    
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
text(mean(get(ax,'xlim')),mean(get(ax,'ylim')),{'That ends the training phase.','Thanks for your patience'},'HorizontalAlignment','center','color',[0 1 0],'fontunits','normalized','FontSize',.1);
pause(3);