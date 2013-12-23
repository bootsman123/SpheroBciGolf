initialize();

%% Wait until the buffer is ready.
header = [];
while(isempty(header) || ~isstruct(header) || (header.nchans==0))
  try 
    header = buffer('get_header', [], Settings.buffer.host, Settings.buffer.port); 
  catch
    header = [];
    Logger.debug('buffer', 'Invalid header data...');
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
	Logger.debug('buffer', 'Waiting for a command...');
	
	[data, devents, state] = buffer_waitData(Settings.buffer.host, Settings.buffer.port, state, 'trlen_ms', 0, 'exitSet', {{'startPhase.cmd' 'subject'}}, 'verb', Settings.verbose, 'timeOut_ms', 5000);   
	if(numel(devents) == 0)
		continue
	end
	
    %% Ensure events are processed in *temporal* order.
    [ans, eventsorder] = sort([devents.sample], 'ascend');
    data = data(eventsorder);
	devents = devents(eventsorder);
	
	Logger.debug('buffer', sprintf('Received event: %s', ev2str(devents)));
  
	%% Extract subject information.
	phase = [];
	
	for index = 1:numel(devents)
		if(strcmp(devents(index).type, 'subject'))
			subject = devents(index).value;
			Logger.debug('buffer', sprintf('Received subject: %s', subject));
			continue
		else
			phase = devents(index).value;
			break
		end
	end
	
	if(isempty(phase))
		continue
	end
	
	Logger.debug('[%d]: %s', getwTime(), phase);
	
	switch(phase)
		%% Cap fitting.
		case 'capFitting'
			sendEvent(phase, 'start');
			capFitting('noiseThresholds', Settings.cap.noiseThresholds, 'badChThreshold', Settings.cap.badChannelThreshold, 'verb', Settings.verbose, 'showOffset', 0, 'capFile', Settings.cap.file, 'overridechnms', Settings.cap.overrideChannelNames);
			sendEvent(phase, 'end');
			break

		%% EEG viewer.
		case 'eegViewer'
			sendEvent(phase, 'start');
			eegViewer(Settings.buffer.host, Settings.buffer.port, 'capFile', Settings.cap.file, 'overridechnms', Settings.cap.overrideChannelNames);
			sendEvent(phase, 'end');
			break
			
		%% Training.
		case 'training'
			if(~isequal(trainingSubject, subject) || ~exist('traindata', 'var'))
				dataFile = sprintf('%s_%s_%s', date, subject, Settings.data.file);
				load(dataFile);
				trainingSubject = subject;
		
				Logger.debug('buffer', sprintf('Loaded data from %s.', dataFile));
			end
			
			sendEvent(phase, 'start');
			classifier = buffer_train_ersp_clsfr(traindata, traindevents, state.hdr, 'spatialfilter', 'slap', 'freqband', [6 10 26 30], 'badchrm', 1, 'badtrrm', 1, ...
												 'objFn', 'lr_cg', 'compKernel', 0, 'dim', 3, 'capFile', Settings.cap.file, 'overridechnms', Settings.cap.overrideChannelNames, 'visualize', 2);
			classifierSubject = subject;
			
			classifierFile = sprintf('%s_%s_%s', date, subject, Settings.classifier.file);
			save(classifierFile, '-struct', 'classifier');

			Logger.debug('buffer', sprintf('Saved classifier to %s.', classifierFile));
			break
	
		%% Testing.
		case 'testing'
			if(~isequal(classifierSubject, subject) || ~exist('classifier','var'))
				classifierFile = sprintf('%s_%s_%s', date, subject, Settings.classifier.file);
				classifier = load(classifierFile);
				classifierSubject = subject;
			end
			
			sendEvent(phase, 'start');
			phaseTesting();
			sendEvent(phase, 'end');
			break
		
		%% Exit.
		case 'exit'
			break
    
		otherwise
			Logger.warning('buffer', sprintf('Unrecognized phase %s.', phase));
			break
	end
end