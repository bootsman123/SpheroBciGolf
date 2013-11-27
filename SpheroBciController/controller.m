% Controller for Sphero BCI Golf
% This is the main file that is used to control all phases

% Initialize defauls settings
settings();

% Create the control window
guiFig = gui();
handles=guidata(guiFig); % Access all handles in the GUI

% Execute the phase selection loop
while (ishandle(guiFig)) % The handler/GUI is valid/present
    
    set(guiFig,'visible','on'); % Make the GUI visible
    uiwait(guiFig); % Wait until UIRESUME is called (interaction is made)
    
    if ( ~ishandle(guiFig) )
        break; % The handler/GUI is not valid/present anymore
    end;
    
    set(guiFig,'visible','off');
    guidata(guiFig,handles); % Update data structure from GUI
    subject=handles.subject; % Set subject name
    phaseToRun=lower(handles.phaseToRun); % Set current phase
    
    fprintf('Start phase : %s\n',phaseToRun);
    
    % Execute the selected phase
    switch phaseToRun;
        case 'capfitting';
            sendEvent('subject',handles.subject);
            sendEvent('startPhase.cmd',phaseToRun);
            buffer_waitData(buffhost,buffport,[],'exitSet',{{phaseToRun} {'end'}},'verb',verb);
            
        case 'eegviewer';
            sendEvent('subject',handles.subject);
            sendEvent('startPhase.cmd',phaseToRun);
            buffer_waitData(buffhost,buffport,[],'exitSet',{{phaseToRun} {'end'}},'verb',verb);
            
        case 'training';
            sendEvent('subject',handles.subject);
            sendEvent('startPhase.cmd',phaseToRun);
            onSeq=nSeq; nSeq=4; % override sequence number (why?)
            % Run two functions simultaneously
            % phaseClassifierLearn has to gather data and save it when
            % training phase is completed.
            matlabpool open 2
            parfor i = 1:2
                if i == 1
                    phaseClassifierLearn();
                else
                    phaseTrainging();
                end
            end
            buffer_waitData(buffhost,buffport,[],'exitSet',{{'training.classifier'} {'end'}},'verb',verb);
            sendEvent(phaseToRun,'end');
            nSeq=onSeq;
            
        case 'feedback';
            % Trained classifier is used to predict which hand the subject
            % is imagining moving and this prediction is used to give the
            % participant feedback about what the classifier though they
            % were doing.
            sendEvent('subject',handles.subject);
            sendEvent('startPhase.cmd',phaseToRun);
            phaseFeedback();
            buffer_waitData(buffhost,buffport,[],'exitSet',{{phaseToRun} {'end'}},'verb',verb);
            
        case {'golf'};
            % The game
            sendEvent('subject',handles.subject);
            sendEvent('startPhase.cmd',phaseToRun);
            buffer_waitData(buffhost,buffport,[],'exitSet',{{phaseToRun} {'end'}},'verb',verb);   
    end
    
    handles.phasesCompleted={handles.phasesCompleted handles.phaseToRun}; % Add the phase runned
    
    if (~ishandle(guiFig)) % The handler/GUI is not valid/present anymore
        oldHandles=handles; % Store data structure from previous GUI
        guiFig=gui(); % Make a new handler/GUI
        handles=guidata(guiFig); % Get the data from the new handler
        
        % Add the important data from the old handler
        handles.phasesCompleted=oldHandles.phasesCompleted;
        handles.phaseToRun=oldHandles.phaseToRun;
        handles.subject=oldHandles.subject; 
        set(handles.subjectName,'String',handles.subject);
        guidata(guiFig,handles);
    end;
end
uiwait(msgbox({'Thankyou for participating in our experiment.'},'Thanks','modal'),10);
pause(1);
% shut down signal proc
sendEvent('startPhase.cmd','exit');
