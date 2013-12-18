configureIM();

% make the target sequence
tgtSeq=mkStimSeqRand(nSymbs,nSeq);


set(fig,'Name','Imagined Movement -- close window to stop.','color',[0 0 0],'menubar','none','toolbar','none','doublebuffer','on');
stimPos=[]; h=[];
stimRadius=.5;
theta=linspace(0,pi,nSymbs); stimPos=[cos(theta);sin(theta)];
for hi=1:nSymbs; 
  h(hi)=rectangle('curvature',[1 1],'position',[stimPos(:,hi)-stimRadius/2;stimRadius*[1;1]],...
                  'facecolor',bgColor); 
end;
% add symbol for the center of the screen
stimPos(:,nSymbs+1)=[0 0];
h(nSymbs+1)=rectangle('curvature',[1 1],'position',[stimPos(:,end)-stimRadius/4;stimRadius/2*[1;1]],...
                      'facecolor',bgColor); 
set(gca,'visible','off');


% play the stimulus
%% reset the cue and fixation point to indicate trial has finished  
sendEvent('stimulus.testing','start');
sendEvent('BASELINE_SHOW');

  
%% show the screen to alert the subject to trial start
sendEvent('stimulus.baseline','start');
sleepSec(baselineDuration);
sendEvent('stimulus.baseline','end');
sendEvent('BASELINE_HIDE');
%% Reset the figure

% for the trial duration update the fixatation point in response to prediction events
status=buffer('wait_dat',[-1 -1 -1],buffhost,buffport); % get current state
nevents=status.nevents; nsamples=status.nsamples;
% initial fixation point position
fixPos = stimPos(:,end);
trlStartTime=getwTime();
trialDuration = 60*60; % 1hr...
timetogo=trialDuration;
dv = zeros(nSymbs,1);
while (timetogo>0)
  
  timetogo = trialDuration - (getwTime()-trlStartTime); % time left to run in this trial
    
  %% Initialise the command for the Sphero
  SpheroCommand.angle = 0;
  SpheroCommand.velocity = 100;
  SpheroCommand.duration = 2500;
    
  
  %% Get the angle
  % wait for events to process *or* end of trial
  status=buffer('wait_dat',[-1 nevents min(5000,timetogo*1000/4)],buffhost,buffport); 
  fprintf('.');
  stime =getwTime();
  if ( status.nevents <= nevents ) % new events to process
    fprintf('Timeout waiting for prediction events\n');
    drawnow;
    continue;
  end
  
  events=[];
  if (status.nevents>nevents) 
      events=buffer('get_evt',[nevents status.nevents-1],buffhost,buffport); 
  end;
  nevents=status.nevents;
  mi    =matchEvents(events,{'stimulus.prediction'});
  predevents=events(mi);
  % make a random testing event
  if ( 0 ) 
      predevents=struct('type','stimulus.prediction','sample',0,'value',ceil(rand()*nSymbs+eps)); 
  end;
  if ( ~isempty(predevents) ) 
    [ans,si]=sort([predevents.sample],'ascend'); % proc in *temporal* order
    print 'AMOUNT OF PREDICTIONS: ' 
    numel(predevents)
    for ei=1:numel(predevents);
      ev=predevents(si(ei));% event to process
      pred=ev.value;
      if pred==0
          Sphero.angle = Sphero.angle+30;
          
      elseif pred==1
          Sphero.angle = Sphero.angle-30;
      end
      Sphero.angle = mod(Sphero.angle,360);
      
      sendEvent('DIRECTION_METER_VALUE', Sphero.angle*(pi/180));
    end
  end % if prediction events to processa  
  sendEvent('DIRECTION_METER_RESET');
  sendEvent('DIRECTION_METER_HIDE');
  %% Get the velocity
  % wait for events to process *or* end of trial
  status=buffer('wait_dat',[-1 nevents min(5000,timetogo*1000/4)],buffhost,buffport); 
  fprintf('.');
  stime =getwTime();
  if ( status.nevents <= nevents ) % new events to process
    fprintf('Timeout waiting for prediction events\n');
    drawnow;
    continue;
  end
  
  sendEvent('POWER_METER_RESET');
  sendEvent('POWER_METER_SHOW');
  events=[];
  if (status.nevents>nevents) 
      events=buffer('get_evt',[nevents status.nevents-1],buffhost,buffport); 
  end;
  nevents=status.nevents;
  mi    =matchEvents(events,{'stimulus.prediction'});
  predevents=events(mi);
  % make a random testing event
  if ( 0 ) 
      predevents=struct('type','stimulus.prediction','sample',0,'value',ceil(rand()*nSymbs+eps)); 
  end;
  if ( ~isempty(predevents) ) 
    [ans,si]=sort([predevents.sample],'ascend'); % proc in *temporal* order
    print 'AMOUNT OF PREDICTIONS: ' 
    numel(predevents)
    for ei=1:numel(predevents);
      ev=predevents(si(ei));% event to process
      pred=ev.value;
      if pred==0
          Sphero.duration = Sphero.duration+30;
      elseif pred==1
          Sphero.duration = Sphero.duration-30;
      end
      Sphero.duration = max(min(MAXIMUM_DURATION, Sphero.duration),MINIMUM_DURATION);
      sendEvent('POWER_METER_VALUE', (Sphero.duration - MINIMUM_DURATION)/MAXIMUM_DURATION);
    end
    
  end % if prediction events to processa  
  
  %% Update the display after all events processed
  sendEvent('POWER_METER_SHOW');
  %% Send the command to the sphero
  toSendString = [num2str(SpheroCommand.angle), ',' , num2str(SpheroCommand.velocity) , ',' , num2str(SpheroCommand.duration)]
  sendEvent('golfer.shoot',toSendString);
end 

% end training marker
sendEvent('stimulus.testing','end');
