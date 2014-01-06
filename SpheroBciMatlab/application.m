initialize;

%% Phase execution loop.
Gui.figure = gui();
Gui.data = guidata(Gui.figure); 

while(ishandle(Gui.figure))
    set(Gui.figure, 'visible', 'on');
    uiwait(Gui.figure);
    if(~ishandle(Gui.figure))
        break
    end

    set(Gui.figure, 'visible', 'off');
    Gui.data = guidata(Gui.figure); 
    
    Logger.debug('application', sprintf('Starting phase %s.', Gui.data.phase));
  
    switch Gui.data.phase
        %% Capfitting.
        case 'capFitting'
            sendEvent('subject', Gui.data.subject);
            sendEvent('startPhase.cmd', Gui.data.phase);
            buffer_waitData(Settings.buffer.host, Settings.buffer.port, [], 'exitSet', {{Gui.data.phase} {'end'}}, 'verb', Settings.verbose);

        %% EEG viewer.
        case 'eegViewer'
            sendEvent('subject', Gui.data.subject);
            sendEvent('startPhase.cmd', Gui.data.phase);
            buffer_waitData(Settings.buffer.host, Settings.buffer.port, [],'exitSet', {{Gui.data.phase} {'end'}}, 'verb', Settings.verbose);
            
        %% Training.
        case 'phaseTraining'
            sendEvent('subject', Gui.data.subject);
            
            sendEvent(Gui.data.phase, 'start');
            phaseTraining;
            sendEvent(Gui.data.phase, 'end');

        %% Train classifier.
        case 'trainClassifier'
            sendEvent('subject', Gui.data.subject);
            sendEvent('startPhase.cmd', Gui.data.phase);
            buffer_waitData(Settings.buffer.host, Settings.buffer.port, [], 'exitSet', {{Gui.data.phase} {'end'}}, 'verb', Settings.verbose);

        %% Feedback.
        case 'phaseFeedback';
            sendEvent('subject', Gui.data.subject);
            
            sendEvent(Gui.data.phase,'start');
            phaseFeedback;
            sendEvent(Gui.data.phase,'end');
   
        %% Feedback.
        case 'phaseTesting';
            sendEvent('subject', Gui.data.subject);
            
            sendEvent(Gui.data.phase,'start');
            phaseTesting;
            sendEvent(Gui.data.phase,'end');
    end

    if(~ishandle(Gui.figure)) 
        oldGuiData = Gui.data;
        Gui.figure = gui();
        Gui.data = guidata(Gui.figure);

        Gui.data.phase = oldGuiData.phase;
        Gui.data.subject = oldGuiData.subject;
        set(Gui.data.subject, 'String', Gui.data.subject); % TODO: Look into this...
        guidata(Gui.figure, Gui.data);
    end
end

sendEvent('startPhase.cmd', 'exit');
