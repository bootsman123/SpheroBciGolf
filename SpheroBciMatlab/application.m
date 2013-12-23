settings();

% create the control window and execute the phase selection loop
Gui.figure = gui();
Gui.data = guidata(Gui.figure); 

while(ishandle(Gui.figure))
  set(Gui.figure,'visible', 'on');
  uiwait(Gui.figure);
  if(~ishandle(Gui.figure))
	break;
  end;
  
  set(Gui.figure,'visible','off');
  Gui.data = guidata(Gui.figure); 
  subject = Gui.data.subject;
  phase = lower(Gui.data.phase);
  
  Logger.debug('application', sprintf('Starting phase %s', phase));
  
  switch phase;
   %% Capfitting.
   case 'capfitting';
    sendEvent('subject', Gui.data.subject);
    sendEvent('startPhase.cmd', phase);
	
    buffer_waitData(Settings.buffer.host,Settings.buffer.port,[],'exitSet',{{phase} {'end'}},'verb',verb);       

   %% EEG viewer.
   case 'eegviewer';
    sendEvent('subject', Gui.data.subject);
    sendEvent('startPhase.cmd', phase);
	
    buffer_waitData(Settings.buffer.host,Settings.buffer.port,[],'exitSet',{{phase} {'end'}},'verb',verb);   

   %% Training.
   % TODO: Remove multiple cases.
   case {'train','classifier'};
    sendEvent('subject', Gui.data.subject);
    sendEvent('startPhase.cmd', phase);
	
    buffer_waitData(Settings.buffer.host,Settings.buffer.port,[],'exitSet',{{phase} {'end'}},'verb',verb);          
    
   %% Practicing.
   case 'practice';
    sendEvent('subject',Gui.data.subject);
    sendEvent(phase,'start');
    onSeq=nSeq; nSeq=4; % override sequence number
    imCalibrateStimulus();
    sendEvent(phase,'end');
    nSeq=onSeq;
    
   %% Calibrating.
   % TODO: Remove multiple cases.
   case {'calibrate','calibration'};
    sendEvent('subject',Gui.data.subject);
    sendEvent('startPhase.cmd',phase)
    sendEvent(phase,'start');
    imCalibrateStimulus();
    sendEvent(phase,'end');

   %% Feedback.
   case 'epochfeedback';
    sendEvent('subject',Gui.data.subject);
    %sleepSec(.1);
    sendEvent(phase,'start');
    %try
      sendEvent('startPhase.cmd','testing');
      phaseTrainingFeedback();
    %catch
      % le=lasterror;fprintf('ERROR Caught:\n %s\n%s\n',le.identifer,le.message);
    %end
    sendEvent('stimulus.test','end');
    sendEvent(phase,'end');
   
   %% Testing
   % TODO: Remove multiple.
   case {'test','testing','contfeedback'};
    sendEvent('subject',Gui.data.subject);
    %sleepSec(.1);
    sendEvent(phase,'start');
    %try
      sendEvent('startPhase.cmd','testing');
      imOnlineFeedbackStimulus;
    %catch
      % le=lasterror;fprintf('ERROR Caught:\n %s\n%s\n',le.identifer,le.message);
    %end
    sendEvent('stimulus.test','end');
    sendEvent(phase,'end');

   %% Neuro feedback stimulus.
   case {'neurofeedback'};
    sendEvent('subject',Gui.data.subject);
    %sleepSec(.1);
    sendEvent(phase,'start');
    %try
      sendEvent('startPhase.cmd','testing');
      imNeuroFeedbackStimulus;
    %catch
      % le=lasterror;fprintf('ERROR Caught:\n %s\n%s\n',le.identifer,le.message);
    %end
    sendEvent('stimulus.test','end');
    sendEvent(phase,'end');
        
  end
  
  Gui.data.phasesCompleted = {Gui.data.phasesCompleted{:} Gui.data.phase};
  if ( ~ishandle(Gui.figure) ) 
    oGui.data = Gui.data;
    Gui.figure = gui();
    Gui.data = guidata(Gui.figure);

    Gui.data.phasesCompleted = oGui.data.phasesCompleted;
    Gui.data.phase = oGui.data.phase;
    Gui.data.subject = oGui.data.subject;
	set(Gui.data.subjectName,'String',Gui.data.subject);
    guidata(Gui.figure, Gui.data);
  end;
end

% TODO: Replace.
uiwait(msgbox({'Thankyou for participating in our experiment.'},'Thanks','modal'),10);
pause(1);

sendEvent('startPhase.cmd','exit');
