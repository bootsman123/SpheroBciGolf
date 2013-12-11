% guard to prevent running multiple times
if (exist('imSettings','var') && ~isempty(imSettings) ) 
    return; 
end;

imSettings=true;

%run ../utilities/initPaths;
run '/Users/roland/Documents/MATLAB/BCIinpractice/buffer_bci/utilities/initPaths';

buffhost='localhost';
buffport=1972;

global ft_buff; ft_buff=struct('host',buffhost,'port',buffport);
% wait for the buffer to return valid header information
hdr=[];
while ( isempty(hdr) || ~isstruct(hdr) || (hdr.nchans==0) ) % wait for the buffer to contain valid data
  try 
    hdr=buffer('get_hdr',[],buffhost,buffport); 
  catch
    hdr=[];
    fprintf('Invalid header info... waiting.\n');
  end;
  pause(1);
end;

% set the real-time-clock to use
initgetwTime();
initsleepSec();

capFile='cap_tmsi_mobita_im';

verb=0;
buffhost='localhost';
buffport=1972;
nSymbs=3;
nSeq=20;
nBlock=2;%10; % number of stim blocks to use
trialDuration=3;
baselineDuration=1;
intertrialDuration=2;
feedbackDuration=1;
moveScale = .1;
bgColor=[.5 .5 .5];
fixColor=[1 0 0];
tgtColor=[0 1 0];

% Neurofeedback smoothing
expSmoothFactor = log(2)/log(10); % smooth the last 10...

if ( ~exist('capFile','var') ) 
    capFile='1010'; 
end; %'cap_tmsi_mobita_num'; 
if ( ~isempty(strfind(capFile,'tmsi')) ) 
    thresh=[.0 .1 .2 5]; 
    badchThresh=1e-4; 
    overridechnms=1;
else
    thresh=[.5 3];  
    badchThresh=.5;   
    overridechnms=0;
end

datestr = datevec(now); 
datestr = sprintf('%02d%02d%02d',datestr(1)-2000,datestr(2:3));
dname='training_data';
cname='clsfr';
testname='testing_data';