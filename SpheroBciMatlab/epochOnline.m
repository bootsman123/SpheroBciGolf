status=buffer('wait_dat',[-1 -1 -1],Settings.buffer.host,Settings.buffer.port); % get current state
nevents=status.nevents;
nsamples=status.nsamples;

epochStartTime = getwTime();
epochDuration = Settings.epochDuration;
timeLeft = epochDuration;

sendEvent('stimulus.testing.epoch',epochType);

%% Tell the user what is the purpose of the current epoch
if(strcmp(epochType, 'DIRECTION'))
    sendEvent('TEXT_VALUE','You can now set the direction of your move.');
    sendEvent('TEXT_SHOW',0);
elseif(strcmp(epochType, 'POWER'))
    sendEvent('TEXT_VALUE','You can now set the speed of your move.');
    sendEvent('TEXT_SHOW',0);
end
pause(Settings.notificationTextDuration);
sendEvent('TEXT_HIDE',0);

%% Initialize the right baseline panel
if(strcmp(epochType, 'DIRECTION'))
    sendEvent('DIRECTION_METER_VALUE',directionValue);
    sendEvent('DIRECTION_METER_SHOW',0);
elseif(strcmp(epochType, 'POWER'))
    sendEvent('POWER_METER_VALUE',powerValue);
    sendEvent('POWER_METER_SHOW',0);
end

%% Start with the baseline
sendEvent('stimulus.baseline','start');
sleepSec(Settings.baselineDuration);
sendEvent('stimulus.baseline','end');

%% Loop until an epoch has finished
while (timeLeft>0)
    timeLeft = epochDuration - (getwTime()-epochStartTime); % Update the time left in this epoch
    status=buffer('wait_dat',[-1 nevents min(5000,timeLeft*1000/4)],Settings.buffer.host,Settings.buffer.port); % Wait for events or stop epoch
    fprintf('.');
    stime = getwTime();
    
    if ( status.nevents <= nevents ) % Check whether there are new events to process
        fprintf('Timeout waiting for prediction events\n');
        continue;
    end
    
    %% Get all new events and filter them
    allEvents=buffer('get_evt',[nevents status.nevents-1],Settings.buffer.host,Settings.buffer.port);
    nevents = status.nevents; % Store latest received event.
    matchedEvents = matchEvents(allEvents,{'stimulus.prediction'});
    predictionEvents=allEvents(matchedEvents);
    
    %% Process prediction events
    if (~isempty(predictionEvents))
        [~,si]=sort([predictionEvents.sample],'ascend'); % proc in *temporal* order
        for ei=1:numel(predictionEvents);
            event=predictionEvents(si(ei));% event to process
            prediction=event.value;
            % now do something with the prediction....
            if ( numel(prediction)==1 )
                if ( prediction>0 && prediction<=Settings.numberOfSymbols && isinteger(prediction) ) % predicted symbol, convert to dv
                    tmp=prediction;
                    prediction=zeros(Settings.numberOfSymbols,1);
                    prediction(tmp)=1;
                else % binary problem
                    prediction=[prediction -prediction];
                end
            end
            
            [ans,predictedTarget]=max(prediction);
            
            %% Update state variables based on the predicted class
            if predictedTarget==1
                if(strcmp(epochType, 'DIRECTION'))
                    directionValue = directionValue - degtorad(Setting.direction.stepSize);
                    directionValue = mod(directionValue,2*pi);
                elseif(strcmp(epochType, 'POWER'))
                    powerValue= powerValue + Settings.power.stepSize;
                    powerValue= min(powerValue, 1);
                end
            elseif predictedTarget==2
                if(strcmp(epochType, 'DIRECTION'))
                    directionValue  = directionValue  + degtorad(Setting.direction.stepSize);
                    directionValue  = mod(directionValue ,2*pi);
                elseif(strcmp(epochType, 'POWER'))
                    powerValue = powerValue - Settings.power.stepSize;
                    powerValue= max(powerValue, 0);
                end
            end
            
            %% Update the stimulus viewer
            if(strcmp(epochType, 'DIRECTION'))
                sendEvent('DIRECTION_METER_VALUE',directionValue);
            elseif(strcmp(epochType, 'POWER'))
                sendEvent('POWER_METER_VALUE',powerValue);
            end
            
        end
    end
end
