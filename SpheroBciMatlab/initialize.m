if(exist('Settings','var') && ~isempty(Settings))
	return;
end;

%run 'D:\Users\My Documents\MATLAB\buffer_bci\utilities\initPaths';
% ^^ PC Bas(?)
%run '~/Documents/MATLAB/BCIinpractice/buffer_bci/utilities/initPaths'; 
%^^ PC Roland

%% Backwards compatible.
Settings.verbose = 2;

%% Buffer.
Settings.buffer.host = 'localhost';
Settings.buffer.port = 1972;

%% Logger.
Settings.logger.file = sprintf('%s.%s', date, 'log');
Settings.logger.commandWindowLevel = log4m.ALL;
Settings.logger.logLevel = log4m.DEBUG;

Settings.cap.file = 'cap_tmsi_mobita_im'; % 1010
Settings.cap.noiseThresholds = [0.5 3]; % [0.0 0.1 0.2 5]
Settings.cap.badChannelThreshold = 0.5; % 1e-4
Settings.cap.overrideChannelNames = 0; % 1

Settings.data.file = 'data';
Settings.classifier.file = 'classifier';

Settings.numberOfSymbols = 2;
Settings.numberOfSequences = 20;
Settings.numberOfBlocks = 2; %10
Settings.trialDuration = 3;
Settings.interTrialDuration = 2;
Settings.baselineDuration = 2;
Settings.feedbackDuration = 1;
Settings.webcamShowDuration = 5;
Settings.instructionTextDuration = 5;

Settings.trial.length = 3000;
Settings.trial.lengthOl = 3000; %?
Settings.smoothFactor = log(2)/log(10);

Settings.sphero.angle = 0; % Between 0 and 360
Settings.sphero.power = 0.5; % Between 0 and 1

%% Initialize clock.
initgetwTime();
initsleepSec();

%% Initialize logger.
Logger = log4m.getLogger(Settings.logger.file);
Logger.setCommandWindowLevel(Settings.logger.commandWindowLevel);
Logger.setLogLevel(Settings.logger.logLevel);