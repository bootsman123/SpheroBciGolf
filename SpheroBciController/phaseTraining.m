function phaseTraining()
    settings;
    if ( verb>0 ) 
        fprintf('Starting : %s\n',phaseToRun); 
        ptime=getwTime(); 
    end
    if ( ~isequal(trainSubj,subject) || ~exist('traindata','var') )
        fprintf('Loading training data from : %s\n',[dname '_' subject '_' datestr]);
        load([dname '_' subject '_' datestr]); 
        trainSubj=subject;
    end
    if ( verb>0 ) 
        fprintf('%d epochs\n',numel(traindevents)); 
    end;
    clsfr=buffer_train_ersp_clsfr(traindata,traindevents,state.hdr,'spatialfilter','slap','freqband',[6 10 26 30],'badchrm',1,'badtrrm',1,'objFn','lr_cg','compKernel',0,'dim',3,'capFile',capFile,'overridechnms',overridechnms,'visualize',2);
    clsSubj=subject;
    fprintf('Saving classifier to : %s\n',[cname '_' subject '_' datestr]);
	save([cname '_' subject '_' datestr],'-struct','clsfr');
	if ( verb>0 ) 
        fprintf('Finished : %s @ %5.3fs\n',phaseToRun,getwTime()-ptime); 
    end
end