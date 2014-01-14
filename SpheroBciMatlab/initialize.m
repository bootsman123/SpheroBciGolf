 if(exist('Settings','var') && ~isempty(Settings))
	return;
end;

%% Initialize paths.
% Bas.
%Settings.path.toolbox = 'C:/Users/bootsman/Documents/MATLAB/Toolboxes/buffer_bci';
%Settings.path.application = 'C:/Users/bootsman/Documents/Development/SpheroBciGolf/SpheroBciMatlab';

% Thymen.
Settings.path.toolbox = 'D:/Users/My Documents/MATLAB/buffer_bci';
Settings.path.application = 'D:/Users/My Documents/Studie/Master/BCI/SpheroBciGolf/SpheroBciMatlab';

initPaths = sprintf('%s/%s', Settings.path.toolbox, 'utilities/initPaths');
run initPaths;

%% Backwards compatible.
Settings.verbose = 2;

%% Buffer.
Settings.buffer.host = 'localhost';
Settings.buffer.port = 1972;

%% Logger.
Settings.logger.file = sprintf('%s/%s.%s', Settings.path.application, date, 'log');
Settings.logger.commandWindowLevel = log4m.ALL;
Settings.logger.logLevel = log4m.ALL;

Settings.cap.file = 'cap_tmsi_mobita_im'; % 1010 
Settings.cap.noiseThresholds = [0.0 0.1 0.2 5]; %  [0.5 3]
Settings.cap.badChannelThreshold = 1e-4; % 0.5
Settings.cap.overrideChannelNames = 1; % 1

Settings.data.file = 'data';
Settings.classifier.file = 'classifier';

Settings.numberOfSymbols = 2;
Settings.numberOfSequences = 20;
Settings.trialDuration = 3;
Settings.interTrialDuration = 2;
Settings.baselineDuration = 2;
Settings.feedbackDuration = 1;
Settings.webcamShowDuration = 5;
Settings.instructionTextDuration = 8;
Settings.notificationTextDuration = 3;
Settings.epochDuration = 20; % Number of seconds user can set the direction or power
Settings.numberOfStrokes = 10; % Maximum number user is allowed to shoot the ball

Settings.trial.length = 3000; %3000
Settings.smoothFactor = log(2)/log(10);

Settings.direction.default = 0.5*pi; % Between 0 and 2pi
Settings.power.default = 0.5; % Between 0 and 1
Settings.power.stepSize = 0.05; % Default power increase/decrase
Settings.direction.stepSize = 10; % Default direction change (in degrees) 

%% Initialize clock.
initgetwTime();
initsleepSec();

%% Initialize logger.
Logger = log4m.getLogger(Settings.logger.file);
Logger.setCommandWindowLevel(Settings.logger.commandWindowLevel);
Logger.setLogLevel(Settings.logger.logLevel);