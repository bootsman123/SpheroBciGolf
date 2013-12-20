configureIM();

% make the target sequence
tgtSeq=mkStimSeqRand(nSymbs,nSeq);

% clf;
% fig=gcf;
% set(fig,'Name','Imagined Movement -- close window to stop.','color',[0 0 0],'menubar','none','toolbar','none','doublebuffer','on');
% stimPos=[]; h=[];
% stimRadius=.5;
% theta=linspace(0,pi,nSymbs); stimPos=[cos(theta);sin(theta)];
% for hi=1:nSymbs; 
%   h(hi)=rectangle('curvature',[1 1],'position',[stimPos(:,hi)-stimRadius/2;stimRadius*[1;1]],...
%                   'facecolor',bgColor); 
% end;
% % add symbol for the center of the screen
% stimPos(:,nSymbs+1)=[0 0];
% h(nSymbs+1)=rectangle('curvature',[1 1],'position',[stimPos(:,end)-stimRadius/4;stimRadius/2*[1;1]],...
%                       'facecolor',bgColor); 
% set(gca,'visible','off');


% play the stimulus
% reset the cue and fixation point to indicate trial has finished  
% set(h(:),'facecolor',bgColor);

sendEvent('stimulus.testing','start');
sendEvent('TEXT_VALUE',['The game is about to start.']);
sendEvent('TEXT_SHOW',0);

pause(10); % Pause for a while to let Java draw
sendEvent('TEXT_HIDE',0);
sendEvent('DIRECTION_METER_RESET',0);
sendEvent('DIRECTION_METER_SHOW',0);
  
% % show the screen to alert the subject to trial start
% set(h(:),'faceColor',bgColor);
% set(h(end),'facecolor',fixColor); % red fixation indicates trial about to start/baseline
% drawnow;% expose; % N.B. needs a full drawnow for some reason
sendEvent('stimulus.baseline','start');
sleepSec(baselineDuration);
sendEvent('stimulus.baseline','end');
% set(h(:),'faceColor',bgColor);
% drawnow;% expose; % N.B. needs a full drawnow for some reason

% for the trial duration update the fixatation point in response to prediction events
status=buffer('wait_dat',[-1 -1 -1],buffhost,buffport); % get current state
nevents=status.nevents; nsamples=status.nsamples;
% initial fixation point position
%fixPos = stimPos(:,end);
trlStartTime=getwTime();
trialDuration = 60*60; % 1hr...
timetogo=trialDuration;
dv = zeros(nSymbs,1);
  % Initialise the command for the Sphero
  SpheroCommand.angle = 0;
  SpheroCommand.velocity = 100;
  SpheroCommand.duration = 2500;
while (timetogo>0)
%   if ( ~ishandle(fig) ) break; end;
  timetogo = trialDuration - (getwTime()-trlStartTime); % time left to run in this trial
  % wait for events to process *or* end of trial
  status=buffer('wait_dat',[-1 nevents min(5000,timetogo*1000/4)],buffhost,buffport); 
  fprintf('.');
  stime =getwTime();
  if ( status.nevents <= nevents ) % new events to process
    fprintf('Timeout waiting for prediction events\n');
%     drawnow;
    continue;
  end
  
  events=[];
  if (status.nevents>nevents) 
      events=buffer('get_evt',[nevents status.nevents-1],buffhost,buffport); 
  end;
  nevents=status.nevents;
  mi = matchEvents(events,{'stimulus.prediction'});
  predevents=events(mi);
  % make a random testing event
  if ( 0 ) 
      predevents = struct('type','stimulus.prediction','sample',0,'value',ceil(rand()*nSymbs+eps)); 
  end;
  if ( ~isempty(predevents) ) 
    [ans,si]=sort([predevents.sample],'ascend'); % proc in *temporal* order
    for ei=1:numel(predevents);
      ev=predevents(si(ei));% event to process
      pred=ev.value;
      % now do something with the prediction....
      if ( numel(pred)==1 )
        if ( pred>0 && pred<=nSymbs && isinteger(pred) ) % predicted symbol, convert to dv
          tmp=pred; pred=zeros(nSymbs,1); pred(tmp)=1;
        else % binary problem
          pred=[pred -pred];
        end
      end
      
      dv = expSmoothFactor*dv + pred(:);
      prob = 1./(1+exp(-dv(:))); 
      prob=prob./sum(prob); % convert from dv to normalised probability
      if ( verb>=0 ) 
        fprintf('%d) dv:',ev.sample);
        fprintf('%5.4f ',pred);
        fprintf('\t\tProb:');
        fprintf('%5.4f ',prob);
        fprintf('\n'); 
      end;
      
      [ans,predTgt]=max(pred);
      if predTgt==1
          SpheroCommand.angle = SpheroCommand.angle+30;  
      elseif predTgt==2
          SpheroCommand.angle = SpheroCommand.angle-30;
      end
      
%       fixPos = stimPos(:,1:end-1)*prob(:); % position is weighted by class probabilties
%       set(h(end),'position',[fixPos-stimRadius/2;stimRadius/2*[1;1]]);
      
      SpheroCommand.angle = mod(SpheroCommand.angle,360);  
      sendEvent('DIRECTION_METER_VALUE', SpheroCommand.angle*(pi/180));
      fprintf('New direction value: %d \n', SpheroCommand.angle*(pi/180));
      
    end
%     drawnow; % update the display after all events processed
  end % if prediction events to processa  
end % loop over epochs in the sequence

% end training marker
sendEvent('DIRECTION_METER_HIDE',0);
sendEvent('stimulus.training','end');

% thanks message
sendEvent('TEXT_VALUE',['That ends the game phase. ' ... 
   'Thanks for your patience']);
sendEvent('TEXT_SHOW',0);
pause(5);
sendEvent('TEXT_HIDE',0);
