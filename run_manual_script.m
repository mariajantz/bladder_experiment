%Script to run the stimulation experiments,  either monopolar or
%multipolar, using preset values for stimulation

%clear any lingering data/activity
xippmex('close');
clear_timers; clear_sockets; clear classes; clear

%SET VARIABLES TO RUN STIMULATION
%Set monopolar/multipolar stimulation amplitudes. For multipolar, input the
%array with cathode first, then anode. Input as the channel + 128 (or
%the add value for the headstage being used)
stimChan = 129:144; %monopolar stimulation
%stimChan = sortRows({5 [1 9]; 9 [5 13]; 6 [2 10]; 10 [6 14]; 7 [3 11]; 11 [7 15]; 8 [4 12]; 12 [8 16]}, 1); %example tripolar stim
%stimChan = cellfun(@(x) x+128, stimChan, 'UniformOutput', false);
% stimChan = {129 133; 130 134; 131 135; 132 136; 133 137; 134 138; 135 139; 136 140; 137 141; 138 142; 139 143; 140 144};
% stimChan = cellfun(@(x) x+128, generateElecMap([2 1]), 'UniformOutput', false);
digTriggerChan = 2; %channel hooked up on DIO headstage to trigger file collection
catname = 'Caravel';
epiLoc = ' '; %use ' ' if not epidural
amps = [200:50:800];
highAmpSurvey = true; % set this way for high amplitude survey plotting, only works
%with one amplitude at a time

%define variables from other paths
savepath = ['C:\Users\RNEL\Desktop\experiment_control\' catname '\'];
filename = 'manualLog'; %sprintf('manualLog%03d', size(dir([savepath '*.xls*']), 1));
C = experiment_constants;
if highAmpSurvey
    stimParams.numPulses = max(C.STA_REPS_PER_SET);
else
    stimParams.numPulses = C.SELECTIVTY_REPS_PER_SET;
end
stimParams.freq = C.STIM_FREQUENCY;
stimParams.phaseDur = C.STIM_CATH_DUR_MS;
stimParams.quietRec = 0.5;
drgLoc = C.DRG_LOCATION(end-1:end);
chanLabels = [C.BIPOLAR.CUFF_LABELS C.TRIPOLAR.CUFF_LABELS];

%not currently doing anything with this variable: TODO - add plotting
datapath = ['X:\2018\' catname '\Grapevine'];

if exist([savepath filename '.xls'])
    xlStart = size(xlsread([savepath filename]), 1)+1;
else
    xlStart = 1;
end
xlswrite([savepath filename], [{'params'}, stimParams.numPulses, stimParams.freq, stimParams.phaseDur, stimParams.quietRec], ...
    1, ['A' num2str(xlStart)]);
xlStart = xlStart + 1;

%check xippmex and reset it before entering loop
status = xippmex;
if status == 0
    error('We have a problem...You dont say?')
end

xippmex('digout', digTriggerChan, 0);
pause(1)

%TODO: add NEVfilenum to all xlswrites
%TODO: revamp so I have plots of at least high amplitude waveforms and can
%skip if they're terrible
if min(size(stimChan))==1 %monopolar stimulation
    for i=stimChan
        disp(i);
        timr = tic;
        disp('Pre channel quiet recording');
        xippmex('digout', digTriggerChan, 1);
        pause(ceil(stimParams.numPulses/stimParams.freq) + stimParams.quietRec);
        xippmex('digout', digTriggerChan, 0);
        pause(0.5);
        %xlswrite file log
        allNEV = dir(datapath);
        xlswrite([savepath filename], [' ', ' ', allNEV(end).name(9:12), 'quiet recording'], 1, ['A' num2str(xlStart)]);
        xlStart = xlStart + 1;
        
        for a = amps
            stimDesign_presetAmps(i,'A',a,stimParams.numPulses,stimParams.freq,stimParams.phaseDur,stimParams.quietRec,0.5, 'digTrigger_enable', true, 'digTrigger_chan', 2)
            %xls columns: amp, freq, nevfile, location, epidural location, cathode1, anode 1, 2
            %get last NEVfile, write xls log
            allNEV = dir(datapath);
            xlswrite([savepath filename], [a, stimParams.freq, allNEV(end).name(9:12), drgLoc, epiLoc, i], 1, ['A' num2str(xlStart)]);
            xlStart = xlStart + 1;
            
        end
        toc(timr)
    end
    
else %multipolar stimulation
    for i=1:size(stimChan, 1)
        fprintf('cathode: %d anode: %d %d %d', stimChan{i, 1}, stimChan{i, 2});
        fprintf('\n\n');
        disp('Pre channel quiet recording');
        xippmex('digout', digTriggerChan, 1);
        pause(ceil(stimParams.numPulses/stimParams.freq) + stimParams.quietRec);
        xippmex('digout', digTriggerChan, 0);
        pause(0.5);
        %xlswrite file log
        allNEV = dir(datapath);
        xlswrite([savepath filename], [' ', ' ', allNEV(end).name(9:12), 'quiet recording'], 1, ['A' num2str(xlStart)]);
        xlStart = xlStart + 1;
        
        for a = amps
            stimDesign_presetAmpsMultichan(stimChan{i, 1}, stimChan{i, 2}, 'A', a, ...
                stimParams.numPulses, stimParams.freq, stimParams.phaseDur, stimParams.quietRec, 0.5, 'digTrigger_enable', true, 'digTrigger_chan', 2)
            %xls columns: amp, freq, nevfile, location, epidural location, cathode1, anode 1, 2
            allNEV = dir(datapath);
            xlswrite([savepath filename], [a, stimParams.freq, allNEV(end).name(9:12), drgLoc, epiLoc], 1, ['A' num2str(xlStart)]);
            xlswrite([savepath filename], [num2cell(stimChan{i, 1}), num2cell(stimChan{i, 2})], 1, ['F' num2str(xlStart)]);
            xlStart = xlStart + 1;
        end
    end
end


