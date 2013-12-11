function phaseCalibration()
    settings;
    if ( verb>0 ) 
        fprintf('Starting : %s\n',phaseToRun); 
        ptime=getwTime(); 
    end
    [traindata,traindevents,state]=buffer_waitData(buffhost,buffport,[],'startSet',{'stimulus.target'},'exitSet',{'stimulus.training' 'end'},'verb',verb,'trlen_ms',trlen_ms);
    mi=matchEvents(traindevents,'stimulus.training','end'); 
    traindevents(mi)=[];
    traindata(mi)=[];%remove exit event
    fprintf('Saving %d epochs to : %s\n',numel(traindevents),[dname '_' subject '_' datestr]);
	save([dname '_' subject '_' datestr],'traindata','traindevents');
	trainSubj=subject;
    if ( verb>0 ) 
        fprintf('Finished : %s @ %5.3fs\n',phaseToRun,getwTime()-ptime); 
    end;
end