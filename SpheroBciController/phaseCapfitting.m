function phaseCapfitting()
    settings;
    if ( verb>0 ) 
        fprintf('Starting : capfitting\n'); 
        ptime=getwTime(); 
    end
    sendEvent('capfitting','start'); % mark start/end testing
    capFitting('noiseThresholds',thresh,'badChThreshold',badchThresh,'verb',verb,'showOffset',0,'capFile',capFile,'overridechnms',overridechnms);
    sendEvent('capfitting','end'); % mark start/end testing
    if ( verb>0 ) 
        fprintf('Finished : %s @ %5.3fs\n','capfitting',getwTime()-ptime); 
    end
end