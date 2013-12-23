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
  
    switch phase
        %% Capfitting.
        case 'capFitting';
            sendEvent('subject', Gui.data.subject);
            sendEvent('startPhase.cmd', phase);
            buffer_waitData(Settings.buffer.host,Settings.buffer.port,[],'exitSet',{{phase} {'end'}},'verb',verb);
            break;

        %% EEG viewer.
        case 'eegViewer'
            sendEvent('subject', Gui.data.subject);
            sendEvent('startPhase.cmd', phase);
            buffer_waitData(Settings.buffer.host, Settings.buffer.port,[],'exitSet',{{phase} {'end'}},'verb',verb);
            break;        
            
        %% Training.
        case 'training'
            sendEvent('subject', Gui.data.subject);
            
            sendEvent(phase, 'start');
            phaseTraining();
            sendEvent(phase, 'end');

        %% Train classifier.
        case 'trainClassifier'
            sendEvent('subject', Gui.data.subject);
            sendEvent('startPhase.cmd', phase);
            buffer_waitData(Settings.buffer.host, Settings.buffer.port,[],'exitSet',{{phase} {'end'}},'verb',verb);
            break;

        %% Feedback.
        case 'feedback';
            sendEvent('subject', Gui.data.subject);
            
            sendEvent(phase,'start');
            phaseFeedback();
            sendEvent(phase,'end');
            break;
   
        %% Feedback.
        case 'testing';
            sendEvent('subject', Gui.data.subject);
            
            sendEvent(phase,'start');
            phaseTesting();
            sendEvent(phase,'end');
            break;
    end;
  
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
end;

sendEvent('startPhase.cmd', 'exit');
