function phaseEEGViewer()
    settings;
    if ( verb>0 ) 
        fprintf('Starting : %s\n','eegviewer'); 
        ptime=getwTime(); 
    end
    sendEvent('eegviewer','start'); % mark start/end testing
    eegViewer(buffhost,buffport,'capFile',capFile,'overridechnms',overridechnms);
    sendEvent('eegviewer','end'); % mark start/end testing
    if ( verb>0 ) 
        fprintf('Finished : %s @ %5.3fs\n','eegviewer',getwTime()-ptime); 
    end
end