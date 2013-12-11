% Controller for Sphero BCI Golf
% This is the main file that is used to control all phases

% Initialize defauls settings
settings();

% Create the control window
guiFig = gui();
handles=guidata(guiFig); % Access all handles in the GUI

% Execute the phase selection loop
while (ishandle(guiFig)) % The handler/GUI is valid/present
    
    set(handles.current,'String','No phase selected');
    set(guiFig,'visible','on'); % Make the GUI visible
    uiwait(guiFig); % Wait until UIRESUME is called (interaction is made)
    
    if ( ~ishandle(guiFig) )
        break; % The handler/GUI is not valid/present anymore
    end;
    
%     set(guiFig,'visible','off');
    handles = guidata(guiFig); % Update data structure from GUI
    subject=handles.subject; % Set subject name
    phaseToRun=handles.phaseToRun; % Set current phase
    
    
    % Execute the selected phase
    switch phaseToRun;
        case 'capfitting';
            set(handles.current,'String','Capfitting');
            sendEvent('subject',handles.subject);
            sendEvent('startPhase',phaseToRun);
            phaseCapfitting();
            sendEvent('endPhase',phaseToRun);
            
        case 'eegviewer';
            set(handles.current,'String','EEG Viewer');
            sendEvent('subject',handles.subject);
            sendEvent('startPhase',phaseToRun);
            phaseEEGViewer();
            sendEvent('endPhase',phaseToRun);
            
        case 'training';
            set(handles.current,'String','Training');
            sendEvent('subject',handles.subject);
            
            sendEvent('startPhase','training.callibration'); % Java should wait for this event
            set(handles.current,'String','Training (callibration)');
            phaseCalibration();
            sendEvent('endtPhase','training.callibration');
            
            sendEvent('startPhase','training.classifier');
            set(handles.current,'String','Training (classifier)');
            phaseTraining();
            sendEvent('endPhase','training.classifier'); 
             
%         case 'feedback';
%             % Trained classifier is used to predict which hand the subject
%             % is imagining moving and this prediction is used to give the
%             % participant feedback about what the classifier though they
%             % were doing.
%             set(handles.current,'String','Feedback');
%             sendEvent('subject',handles.subject);
%             sendEvent('startPhase',phaseToRun); % Java should wait for this event
%             
%             phaseFeedback();
%             buffer_waitData(buffhost,buffport,[],'exitSet',{{phaseToRun} {'end'}},'verb',verb);
%             
%         case {'golf'};
%             % The game
%             sendEvent('subject',handles.subject);
%             sendEvent('startPhase.cmd',phaseToRun);
%             buffer_waitData(buffhost,buffport,[],'exitSet',{{phaseToRun} {'end'}},'verb',verb);
    end
    
    handles.phasesCompleted={handles.phasesCompleted handles.phaseToRun}; % Add the phase runned
    
    if (~ishandle(guiFig)) % The handler/GUI is not valid/present anymore
        oldHandles = handles; % Store data structure from previous GUI
        guiFig = gui(); % Make a new handler/GUI
        handles = guidata(guiFig); % Get the data from the new handler
        
        % Add the important data from the old handler
        handles.phasesCompleted = oldHandles.phasesCompleted;
        handles.phaseToRun = oldHandles.phaseToRun;
        handles.subject = oldHandles.subject;
        set(handles.subjectName,'String',handles.subject);
        guidata(guiFig,handles);
    end;
end
uiwait(msgbox({'Thank you for participating in our experiment.'},'Thanks','modal'),10);
pause(1);
% shut down signal proc
sendEvent('startPhase.cmd','exit');
