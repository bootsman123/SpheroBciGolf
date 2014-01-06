initialize();

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
phase = [];

while(true)
	if( ~isempty(phase) )
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
	phase = [];
	for index = 1:numel(events)
		if(strcmp(events(index).type, 'subject'))
			subject = events(index).value;
			Logger.debug('applicationBuffer', sprintf('Received subject: %s.', subject));
            continue
		else
			phase = events(index).value;
            break
        end
    end
	
	if(isempty(phase))
		continue
    end
	
	Logger.debug('applicationBuffer', sprintf('Received phase %s.', phase));
	
	switch(phase)
		%% Cap fitting.
		case 'capFitting'
			sendEvent(phase, 'start');
			capFitting('noiseThresholds', Settings.cap.noiseThresholds, 'badChThreshold', Settings.cap.badChannelThreshold, 'verb', Settings.verbose, 'showOffset', 0, 'capFile', Settings.cap.file, 'overridechnms', Settings.cap.overrideChannelNames);
			sendEvent(phase, 'end');

		%% EEG viewer.
		case 'eegViewer'
			sendEvent(phase, 'start');
			eegViewer(Settings.buffer.host, Settings.buffer.port, 'capFile', Settings.cap.file, 'overridechnms', Settings.cap.overrideChannelNames);
			sendEvent(phase, 'end');
			
		%% Training.
		case 'phaseTraining'
			if(~isequal(trainingSubject, subject) || ~exist('traindata', 'var'))
				dataFile = sprintf('%s_%s_%s', date, subject, Settings.data.file);
				load(dataFile);
				trainingSubject = subject;
		
				Logger.debug('applicationBuffer', sprintf('Loaded data from %s.', dataFile));
			end
			
			sendEvent(phase, 'start');
			classifier = buffer_train_ersp_clsfr(traindata, trainevents, state.hdr, 'spatialfilter', 'slap', 'freqband', [6 10 26 30], 'badchrm', 1, 'badtrrm', 1, ...
												 'objFn', 'lr_cg', 'compKernel', 0, 'dim', 3, 'capFile', Settings.cap.file, 'overridechnms', Settings.cap.overrideChannelNames, 'visualize', 2);
			classifierSubject = subject;
			
			classifierFile = sprintf('%s_%s_%s', date, subject, Settings.classifier.file);
			save(classifierFile, '-struct', 'classifier');

			Logger.debug('applicationBuffer', sprintf('Saved classifier to %s.', classifierFile));
	
		%% Testing.
		case 'trainClassifier'
			if(~isequal(classifierSubject, subject) || ~exist('classifier','var'))
				classifierFile = sprintf('%s_%s_%s', date, subject, Settings.classifier.file);
				classifier = load(classifierFile);
				classifierSubject = subject;
			end
			
			sendEvent(phase, 'start');
			phaseTesting();
			sendEvent(phase, 'end');
		
		%% Exit.
		case 'exit'
			break
    
		otherwise
			Logger.warning('applicationBuffer', sprintf('Unrecognized command %s.', phase));
	end
end