function phaseFeedback()
    settings;
    if ( verb>0 ) 
        fprintf('Starting : %s\n','feedback'); 
        ptime=getwTime(); 
    end;
    if ( ~isequal(clsSubj,subject) || ~exist('clsfr','var') ) 
      clsfrfile = [cname '_' subject '_' datestr];
      if ( ~exist([clsfrfile '.mat'],'file') ) 
          clsfrfile=[cname '_' subject]; 
      end
      if(verb>0)
          fprintf('Loading classifier from file : %s\n',clsfrfile);
      end
      clsfr=load(clsfrfile);
      clsSubj = subject;
    end
    sendEvent(lower(phaseToRun),'start'); % mark start/end testing
    imOnlineFeedbackSignals(clsfr,'buffhost',buffhost,'buffport',buffport,'hdr',hdr)
    sendEvent(lower(phaseToRun),'end');    
    if ( verb>0 ) 
        fprintf('Finished : %s @ %5.3fs\n',phaseToRun,getwTime()-ptime); 
    end
end

