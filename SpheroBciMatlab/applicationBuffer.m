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
bufferPhase = [];

while(true)
	if( ~isempty(bufferPhase) )
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
            
        case 'phaseTraining';
            [traindata,traindevents,state]=buffer_waitData(buffhost,buffport,state,'startSet',{'stimulus.target'},'exitSet',{'stimulus.training' 'end'},'verb',verb,'trlen_ms',Settings.trial.length);
            mi=matchEvents(traindevents,'stimulus.training','end'); 
            traindevents(mi)=[];
            traindata(mi)=[];%remove exit event
            Logger.debug('applicationBuffer', fprinf('Saving %d epochs to : %s\n',numel(traindevents),[dname '_' subject '_' datestr]));
            save([dname '_' subject '_' datestr],'traindata','traindevents');
            trainingSubject = subject;
            sendEvent(bufferPhase,'end'); % mark start/end testing
			
		%% Train the classifier.
		case 'trainClassifier'
			if(~isequal(trainingSubject, subject) || ~exist('traindata', 'var'))
				dataFile = sprintf('%s_%s_%s', date, subject, Settings.data.file);
				load(dataFile);
				trainingSubject = subject;
		
				Logger.debug('applicationBuffer', sprintf('Loaded data from %s.', dataFile));
			end
			
			sendEvent(bufferPhase, 'start');
			classifier = buffer_train_ersp_clsfr(traindata, trainevents, state.hdr, 'spatialfilter', 'slap', 'freqband', [6 10 26 30], 'badchrm', 1, 'badtrrm', 1, ...
												 'objFn', 'lr_cg', 'compKernel', 0, 'dim', 3, 'capFile', Settings.cap.file, 'overridechnms', Settings.cap.overrideChannelNames, 'visualize', 2);
			classifierSubject = subject;
			
			classifierFile = sprintf('%s_%s_%s', date, subject, Settings.classifier.file);
			save(classifierFile, '-struct', 'classifier');

			Logger.debug('applicationBuffer', sprintf('Saved classifier to %s.', classifierFile));
	
		%% Testing.
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