configureIM();

% make the target sequence
tgtSeq=mkStimSeqRand(nSymbs,nSeq);

fig=gcf;
clf;
set(fig,'Name','Imagined Movement','color',[0 0 0],'menubar','none','toolbar','none','doublebuffer','on');
ax=axes('position',[0.025 0.025 .95 .95],'units','normalized','visible','off','box','off',...
        'xtick',[],'xticklabelmode','manual','ytick',[],'yticklabelmode','manual',...
        'color',[0 0 0],'DrawMode','fast','nextplot','replacechildren',...
        'xlim',[-1.5 1.5],'ylim',[-1.5 1.5],'Ydir','normal');

stimPos=[]; h=[];
stimRadius=.5;
theta=linspace(0,pi,nSymbs); 
stimPos=[cos(theta);sin(theta)];



sendEvent('stimulus.testing','start');
pause(5); % N.B. pause so fig redraws

for si=1:nSeq;
  sleepSec(intertrialDuration);
  % show the screen in the Java instance to alert the subject to trial start
  sendEvent('stimulus.baseline','start');
  sleepSec(baselineDuration);
  sendEvent('stimulus.baseline','end');

  % show the target in our Java instance
  sendEvent('stimulus.target',find(tgtSeq(:,si)>0));
  sendEvent('stimulus.trial','start');
  
  % for the trial duration update the fixatation point in response to prediction events
  status=buffer('wait_dat',[-1 -1 -1],buffhost,buffport); % get current state
  nevents=status.nevents; nsamples=status.nsamples;
  % initial fixation point position
  trlStartTime=getwTime();
  timetogo = trialDuration;
  while (timetogo>0)
    timetogo = trialDuration - (getwTime()-trlStartTime); % time left to run in this trial
    % wait for events to process *or* end of trial
    status=buffer('wait_dat',[-1 -1 timetogo*1000/4],buffhost,buffport); 
    stime =getwTime();
    if ( status.nevents > nevents ) % new events to process
      events=[];
      if (status.nevents>nevents) 
          events=buffer('get_evt',[nevents status.nevents-1],buffhost,buffport); 
      end;
      mi= matchEvents(events,{'stimulus.prediction'});
      predevents=events(mi);
      % make a random testing event
      if ( 0 ) 
          predevents=struct('type','stimulus.prediction','sample',0,'value',ceil(rand()*nSymbs+eps)); 
      end;
      if ( ~isempty(predevents) ) 
        [ans,si]=sort([predevents.sample],'ascend'); % proc in *temporal* order
        for ei=1:numel(predevents);
          ev=predevents(si(ei));% event to process
          pred=ev.value;
          % now do something with the prediction....
          if ( numel(pred)==1 )
            if ( pred>0 && pred<=nSymbs && isinteger(pred) ) % predicted symbol, convert to dv equivalent
              tmp=pred; pred=zeros(nSymbs,1); pred(tmp)=1;
            else % binary problem
              pred=[pred -pred];
            end
          end
          prob = 1./(1+exp(-pred)); prob=prob./sum(prob); % convert from dv to normalised probability
          if ( verb>=0 ) 
              fprintf('dv:');fprintf('%5.4f ',pred);fprintf('\t\tProb:');fprintf('%5.4f ',prob);fprintf('\n'); 
          end;
          
          % feedback information... simply move in direction detected by the BCI
         % dx = stimPos(:,1:end-1)*prob(:); % change in position is weighted by class probs
         % fixPos = fixPos + dx*moveScale;
         % set(h(end),'position',[fixPos-stimRadius/2;stimRadius/2*[1;1]]);
        end
      end % prediction events to processa  
    end % if feedback events to process
    
  end % loop over epochs in the sequence

  % reset the cue and fixation point to indicate trial has finished, also reset the position of the fixation point
  sendEvent('stimulus.trial','resetcue');
  sendEvent('stimulus.trial','end');
  
  ftime=getwTime();
  fprintf('\n');
end % loop over sequences in the experiment
% end training marker
sendEvent('stimulus.testing','end');
pause(3);