initialize;

%% Wait until the buffer is ready.
header = [];
while(isempty(header) || ~isstruct(header) || (header.nchans==0))
    try 
        header = buffer('get_hdr', [], Settings.buffer.host, Settings.buffer.port); 
    catch
        header = [];
        Logger.debug('applicationBuffer', 'Invalid header data...');
    end
    pause(1);
end

%% Main loop.
classifierSubject = [];
trainingSubject = [];

state = struct('pending', [], 'nevents', [], 'nsamples', [], 'hdr', header); 
bufferPhase = [];

while(true)
	if(~isempty(bufferPhase))
		state = [];
	end
	
	%% Process commands.
	Logger.debug('applicationBuffer', 'Waiting for a command...');
	[data, events, state] = buffer_waitData(Settings.buffer.host, Settings.buffer.port, state, 'trlen_ms', 0, 'exitSet', {{'startPhase.cmd' 'subject'}}, 'verb', Settings.verbose, 'timeOut_ms', 5000);   
	if(numel(events) == 0)
		continue
	end
	
    %% Ensure events are processed in *temporal* order.
    [~, order] = sort([events.sample], 'ascend');
    data = data(order);
	events = events(order);
	
	Logger.debug('applicationBuffer', sprintf('Received event: %s', ev2str(events)));
  
	%% Extract subject information.
	bufferPhase = [];
	for index = 1:numel(events)
		if(strcmp(events(index).type, 'subject'))
			subject = events(index).value;
			Logger.debug('applicationBuffer', sprintf('Received subject: %s.', subject));
            continue
		else
			bufferPhase = events(index).value;
            break
        end
    end
	
	if(isempty(bufferPhase))
		continue
    end
	
	Logger.debug('applicationBuffer', sprintf('Received phase %s.', bufferPhase));
	
	switch(bufferPhase)
		%% Cap fitting.
		case 'capFitting'
			sendEvent(bufferPhase, 'start');
			capFitting('noiseThresholds', Settings.cap.noiseThresholds, 'badChThreshold', Settings.cap.badChannelThreshold, 'verb', Settings.verbose, 'showOffset', 0, 'capFile', Settings.cap.file, 'overridechnms', Settings.cap.overrideChannelNames);
			sendEvent(bufferPhase, 'end');

		%% EEG viewer.
		case 'eegViewer'
			sendEvent(bufferPhase, 'start');
			eegViewer(Settings.buffer.host, Settings.buffer.port, 'capFile', Settings.cap.file, 'overridechnms', Settings.cap.overrideChannelNames);
			sendEvent(bufferPhase, 'end');

        %% Phase training.
        case 'phaseTraining';
            [trainData, trainEvents, state] = buffer_waitData(buffhost,buffport,state,'startSet',{'stimulus.target'},'exitSet',{'stimulus.training' 'end'},'verb',Settings.verbose,'trlen_ms',Settings.trial.length);
            
            % Remove last event.
            events = matchEvents(trainEvents,'stimulus.training','end'); 
            trainEvents(events) = [];
            trainData(events) = [];
            
            dataFile = sprintf('%s_%s_%s', date, subject, Settings.data.file);
            save(dataFile, 'trainData', 'trainEvents');
            Logger.debug('applicationBuffer', sprintf('Saved %d epochs to : %s.\n', numel(trainEvents), dataFile));
            
            trainingSubject = subject;
            sendEvent(bufferPhase,'end');
			
		%% Train the classifier.
		case 'trainClassifier'
			if(~isequal(trainingSubject, subject) || ~exist('traindata', 'var'))
				dataFile = sprintf('%s_%s_%s', date, subject, Settings.data.file);
				load(dataFile);
				trainingSubject = subject;
		
				Logger.debug('applicationBuffer', sprintf('Loaded data from %s.', dataFile));
			end
			
			sendEvent(bufferPhase, 'start');
			classifier = buffer_train_ersp_clsfr(trainData, trainevents, state.hdr, 'spatialfilter', 'slap', 'freqband', [6 10 26 30], 'badchrm', 1, 'badtrrm', 1, ...
												 'objFn', 'lr_cg', 'compKernel', 0, 'dim', 3, 'capFile', Settings.cap.file, 'overridechnms', Settings.cap.overrideChannelNames, 'visualize', 2);
			classifierSubject = subject;
			
			classifierFile = sprintf('%s_%s_%s', date, subject, Settings.classifier.file);
			save(classifierFile, '-struct', 'classifier');

			Logger.debug('applicationBuffer', sprintf('Saved classifier to %s.', classifierFile));
	
		%% Phase testing.
		case 'phaseTesting'
			if(~isequal(classifierSubject, subject) || ~exist('classifier','var'))
				classifierFile = sprintf('%s_%s_%s', date, subject, Settings.classifier.file);
				classifier = load(classifierFile);
				classifierSubject = subject;
			end
			
			sendEvent(bufferPhase, 'start');
			phaseTesting;
			sendEvent(bufferPhase, 'end');
		
		%% Exit.
		case 'exit'
			break
    
		otherwise
			Logger.warning('applicationBuffer', sprintf('Unrecognized command %s.', bufferPhase));
	end
end