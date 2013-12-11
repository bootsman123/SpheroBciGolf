configureIM();

% make the target sequence
tgtSeq=mkStimSeqRand(nSymbs,nSeq);

% make the stimulus
%figure;
% fig=gcf;
% set(fig,'Name','Imagined Movement','color',[0 0 0],'menubar','none','toolbar','none','doublebuffer','on');
% clf;
% ax=axes('position',[0.025 0.025 .95 .95],'units','normalized','visible','off','box','off',...
%         'xtick',[],'xticklabelmode','manual','ytick',[],'yticklabelmode','manual',...
%         'color',[0 0 0],'DrawMode','fast','nextplot','replacechildren',...
% %         'xlim',[-1.5 1.5],'ylim',[-1.5 1.5],'Ydir','normal');
%
% stimPos=[]; h=[];
% stimRadius=.5;
% theta=linspace(0,pi,nSymbs); stimPos=[cos(theta);sin(theta)];
% for hi=1:nSymbs;
%   h(hi)=rectangle('curvature',[1 1],'position',[stimPos(:,hi)-stimRadius/2;stimRadius*[1;1]],...
%                   'facecolor',bgColor);
% end;
% add symbol for the center of the screen
% stimPos(:,nSymbs+1)=[0 0];
% h(nSymbs+1)=rectangle('curvature',[1 1],'position',[stimPos(:,nSymbs+1)-stimRadius/4;stimRadius/2*[1;1]],...
%                       'facecolor',bgColor);
% set(gca,'visible','off');
%
% % play the stimulus
% % reset the cue and fixation point to indicate trial has finished
% set(h(:),'facecolor',bgColor);
sendEvent('stimulus.training','start');
sendEvent('DIRECTION_METER_VALUE', pi/2);
sendEvent('DIRECTION_METER_SHOW');

% drawnow; pause(5); % N.B. pause so fig redraws

for si=1:nSeq;
    
    %   if ( ~ishandle(fig) ) break; end;
    
    sleepSec(intertrialDuration);
    %   % show the screen to alert the subject to trial start
    %   set(h(end),'facecolor',fixColor); % red fixation indicates trial about to start/baseline
    %   drawnow;% expose; % N.B. needs a full drawnow for some reason
    sendEvent('BASELINE_SHOW');
    sendEvent('stimulus.baseline','start');
    
    sleepSec(baselineDuration);
    sendEvent('BASELINE_HIDE');
    sendEvent('stimulus.baseline','end');
    
    
    % show the target
    fprintf('%d) tgt=%d : ',si,find(tgtSeq(:,si)>0));
    %   set(h(tgtSeq(:,si)>0),'facecolor',tgtColor);
    %   set(h(tgtSeq(:,si)<=0),'facecolor',bgColor);
    %   set(h(end),'facecolor',[0 1 0]); % green fixation indicates trial running
    

    sendEvent('stimulus.target',find(tgtSeq(:,si)>0));
    sendEvent('DIRECTION_METER_VALUE', currentTarget);
    if(find(tgtSeq(:,si)>0) == 1)
        sendEvent('DIRECTION_METER_VALUE', currentTarget);
    else
        sendEvent('DIRECTION_METER_VALUE', pi);
    end
    sendEvent('stimulus.trial','start');
    sleepSec(trialDuration);
    
    sendEvent('DIRECTION_METER_VALUE', pi/2);
    sendEvent('stimulus.trial','end');
    
    ftime=getwTime();
    fprintf('\n');
end % sequences
% end training marker
sendEvent('DIRECTION_METER_HIDE');
sendEvent('stimulus.training','end');

% thanks message
text(mean(get(ax,'xlim')),mean(get(ax,'ylim')),{'That ends the training phase.','Thanks for your patience'},'HorizontalAlignment','center','color',[0 1 0],'fontunits','normalized','FontSize',.1);
pause(3);