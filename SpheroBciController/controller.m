% Controller for Sphero BCI Golf
% This is the main file that is used to control all phases

% Initialize defauls settings
settings();

% Create the control window
guiFig=gui(); 
info=guidata(guiFig);

% Execute the phase selection loop
while (ishandle(guiFig))
  
  set(guiFig,'visible','on'); % Make the GUI visible
  uiwait(guiFig); 
  
  if ( ~ishandle(guiFig) ) 
      break; % The handler is not valid/present anymore
  end;
  
  set(guiFig,'visible','off');
  info=guidata(guiFig); % Get the data structure from GUI
  subject=info.subject; % Set subject name
  phaseToRun=lower(info.phaseToRun); % Set current phase
  fprintf('Start phase : %s\n',phaseToRun);
  
  % Execute the selected phase
  switch phaseToRun;
   case 'capfitting';
    sendEvent('subject',info.subject);
    sendEvent('startPhase.cmd',phaseToRun);
    % wait until capFitting is done
    buffer_waitData(buffhost,buffport,[],'exitSet',{{phaseToRun} {'end'}},'verb',verb);       

   case 'eegviewer';
    sendEvent('subject',info.subject);
    sendEvent('startPhase.cmd',phaseToRun);
    % wait until capFitting is done
    buffer_waitData(buffhost,buffport,[],'exitSet',{{phaseToRun} {'end'}},'verb',verb);           
    
   case 'practice';
    sendEvent('subject',info.subject);
    sendEvent(phaseToRun,'start');
    onSeq=nSeq; nSeq=4; % override sequence number
    try
      imCalibrateStimulus();
    catch
      % do nothing
    end
    sendEvent(phaseToRun,'end');
    nSeq=onSeq;
    
   case {'calibrate','calibration'};
    sendEvent('subject',info.subject);
    sendEvent('startPhase.cmd',phaseToRun)
    sendEvent(phaseToRun,'start');
    try
      imCalibrateStimulus();
    catch
      sendEvent('stimulus.training','end');    
    end
    sendEvent(phaseToRun,'end');

   case {'train','classifier'};
    sendEvent('subject',info.subject);
    sendEvent('startPhase.cmd',phaseToRun);
    % wait until training is done
    buffer_waitData(buffhost,buffport,[],'exitSet',{{phaseToRun} {'end'}},'verb',verb);  
        
   case {'test','testing'};
    sendEvent('subject',info.subject);
    %sleepSec(.1);
    sendEvent(phaseToRun,'start');
    %try
      sendEvent('startPhase.cmd','testing');
      imOnlineFeedbackStimulus;
    %catch
    %end
    sendEvent('stimulus.test','end');
    sendEvent(phaseToRun,'end');

   case {'neurofeedback'};
    sendEvent('subject',info.subject);
    %sleepSec(.1);
    sendEvent(phaseToRun,'start');
    %try
      sendEvent('startPhase.cmd','testing');
      imNeuroFeedbackStimulus;
    %catch
    %end
    sendEvent('stimulus.test','end');
    sendEvent(phaseToRun,'end');
        
  end
  info.phasesCompleted={info.phasesCompleted{:} info.phaseToRun};
  if ( ~ishandle(guiFig) ) 
    oinfo=info; % store old info
    guiFig=controller(); % make new figure
    info=guidata(guiFig); % get new info
                           % re-place old info
    info.phasesCompleted=oinfo.phasesCompleted;
    info.phaseToRun=oinfo.phaseToRun;
    info.subject=oinfo.subject; set(info.subjectName,'String',info.subject);
    guidata(guiFig,info);
  end;
  %for i=1:numel(info.phasesCompleted); % set all run phases to have green text
  %    set(getfield(info,[info.phasesCompleted{i} 'But']),'ForegroundColor',[0 1 0]);
  %end
end
uiwait(msgbox({'Thankyou for participating in our experiment.'},'Thanks','modal'),10);
pause(1);
% shut down signal proc
sendEvent('startPhase.cmd','exit');
