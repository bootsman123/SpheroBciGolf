function [ steps ] = epochOnline( epochType )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

status=buffer('wait_dat',[-1 -1 -1],buffhost,buffport); % get current state
nevents=status.nevents;
nsamples=status.nsamples;
steps = 0;

epochStartTime = getwTime();
epochDuration = 15;
timeLeft = epochDuration;

sendEvent('stimulus.testing.epoch',epochType);

% Tell the user what is the purpose of the current epoch
if(strcmp(epochType, 'DIRECTION'))
    sendEvent('TEXT_VALUE','You can now set the direction of your move.');
    sendEvent('TEXT_SHOW',0);
elseif(strcmp(epochType, 'POWER'))
    sendEvent('TEXT_VALUE','You can now set the speed of your move.');
    sendEvent('TEXT_SHOW',0);
end
pause(3);
sendEvent('TEXT_HIDE',0);

% Initialize the right baseline panel
if(strcmp(epochType, 'DIRECTION'))
    sendEvent('DIRECTION_METER_RESET',0);
    sendEvent('DIRECTION_METER_SHOW',0);
elseif(strcmp(epochType, 'POWER'))
    sendEvent('POWER_METER_RESET',0);
    sendEvent('POWER_METER_SHOW',0);
end

% Start with the baseline
sendEvent('stimulus.baseline','start');
sleepSec(baselineDuration);
sendEvent('stimulus.baseline','end');

while (timeLeft>0)
    timeLeft = epochDuration - (getwTime()-epochStartTime); % Update the time left in this epoch
    status=buffer('wait_dat',[-1 nevents min(5000,timetogo*1000/4)],buffhost,buffport); % Wait for events or stop epoch
    fprintf('.');
    stime = getwTime();
    
    if ( status.nevents <= nevents ) % Check whether there are new events to process
        fprintf('Timeout waiting for prediction events\n');
        continue;
    end
    
    % If there are events to process, update the Sphereo state.
    allEvents=[];
    if (status.nevents > nevents)
        allEvents=buffer('get_evt',[nevents status.nevents-1],buffhost,buffport); % Get all new events.
    end;
    nevents = status.nevents; % Store latest received event.
    matchedEvents = matchEvents(allEvents,{'stimulus.prediction'});
    predictionEvents=allEvents(matchedEvents);
    
    % Only update the Sphero if there are predicted events
    if (~isempty(predictionEvents))
        [ans,si]=sort([predictionEvents.sample],'ascend'); % proc in *temporal* order
        for ei=1:numel(predictionEvents);
            event=predictionEvents(si(ei));% event to process
            prediction=event.value;
            % now do something with the prediction....
            if ( numel(prediction)==1 )
                if ( prediction>0 && prediction<=nSymbs && isinteger(prediction) ) % predicted symbol, convert to dv
                    tmp=prediction;
                    prediction=zeros(nSymbs,1);
                    prediction(tmp)=1;
                else % binary problem
                    prediction=[prediction -prediction];
                end
            end
            
            [ans,predictedTarget]=max(prediction);
            if predictedTarget==1
                steps = steps - 1;
                % TODO: update the direction or power meter
            elseif predictedTarget==2
                steps = steps + 1;
                % TODO: change the direction or power meter
            end
        end
    end % if prediction events to processa
end % loop over epochs in the sequence

end

