% Guard to prevent initializing multiple times.
if(exist('Settings','var') && ~isempty(Settings))
	return;
end;

%run 'D:\Users\My Documents\MATLAB\buffer_bci\utilities\initPaths';
% ^^ PC Bas(?)
run '~/Documents/MATLAB/BCIinpractice/buffer_bci/utilities/initPaths'; 
%^^ PC Roland
Settings.buffer.host = 'localhost';
Settings.buffer.port = 1972;

Settings.logger.file = 'log.txt';
Settings.logger.commandWindowLevel = log4m.ALL;
Settings.logger.logLevel = log4m.DEBUG;

Settings.cap.file = 'cap_tmsi_mobita_im'; %1010

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

% Initialize clock.
initgetwTime();
initsleepSec();

% Initialize logger.
Logger = log4m.getLogger(Settings.logger.file);
Logger.setCommandWindowLevel(Settings.logger.commandWindowLevel);
Logger.setLogLevel(Settings.logger.logLevel);

global ft_buff;
ft_buff = struct('host', Settings.buffer.host, 'port', Settings.buffer.port); % Backwards compatible.

% Wait for the buffer to return a valid header.
header = [];
while(isempty(header) || ~isstruct(header) || (header.nchans==0))
  try 
    header = buffer('get_header', [], Settings.buffer.host, Settings.buffer.port); 
  catch
    header = [];
    Logger.debug('settings', 'Invalid header data...');
  end;
  pause(1);
end;
