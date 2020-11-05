
%ONLY CHANGE THESE PARAMETERS
C = experiment_constants_Picaroons;
yr = num2str(year(datetime(datestr(now))));

savepath = sprintf('D:\\DataTanks\\%s\\%s\\Documents\\Experiment_Files\\', yr, C.CAT_NAME); %file path for saving constants/run info
savepath = [savepath C.LOCATION '\'];
% savepath = 'D:\DataTanks\2019\test_folder_Jess\';

datapath = sprintf('D:\\DataTanks\\%s\\%s\\Grapevine', yr, C.CAT_NAME);

warning('Make sure fast settle is off'); 
notes_update = input('Have you updated these notes to be accurate? y/n ', 's');
if strcmp(notes_update, 'n')
    error('Update the notes')
end
notes = 'peripheral nerve stim, bladder fill 10/11 ml.';

stimTime = 10; %seconds of stimulation
freqs = [3 33]; %Hz each frequency is applied to all of the nerves
amps = [500]; %uA of nerve cuff stimulation. Will run all of these amplitudes for each nerve
nerverange = [1:2]; %Will run all of these nerves, one at a time
% 1 - Pelvic, 2 - Pudendal, 3 - Sensory, 4 - Caudal Rectal, 5 - Deep
% Perineal, 6 - Sciatic

C.STIM_HEADSTAGE_LOC = 'B1'; 

C.REC_HEADSTAGE_LOC   = 'D';

% Switch channels to match location of the stimulation headstage
chanOrder             = {1:32, 129:160, 161:192, 193:224, 129:224, 385:416};
stimLocation          = {'A', 'B1', 'B2', 'B3', 'B123', 'D'};
C.ACTIVE_CHAN         = chanOrder{ismember(stimLocation, C.STIM_HEADSTAGE_LOC)};
C.QUIET_REC           = 10; %seconds before and after stim

% if length(freqs)==1
%     freqs = freqs*ones(size(nerverange));
% end

[curFile, ~] = find_curFile(datapath, 'testing', 0, 'datafiles', []);
filenums = [];
%curFile = 1;

for i = nerverange
    for f = 1:length(freqs)
        freq = freqs(f);
        C.THRESH_REPS = stimTime*freq; %set the number of stimuli that should be applied
        % :length(C.BIPOLAR.CUFF_CHANNELS)
        for j = 1:length(amps)
            single_amp_stim(C, C.BIPOLAR.CUFF_CHANNELS{i}+1, amps(j), freq, fullfile(datapath, 'datafile'));
            filenums = [filenums curFile];
            curFile = curFile + 1;
        end
        
        stimulated_cuffs{i} = {C.BIPOLAR.CUFF_CHANNELS{i}, C.BIPOLAR.CUFF_LABELS{i}};
        
        %save and overwrite after each cycle so we always have the saved file
        %about what we did.
        save(sprintf('%snerve_cuff_stim%04d', savepath, filenums(1)), 'C', 'filenums', 'freq', 'freqs', 'stimTime', 'amps', 'stimulated_cuffs', 'nerverange', 'notes');
        %fprintf('Pausing to let stimulation return to baseline\n');
        pause(5); %to let the function return to baseline
        
    end
end

amps = repmat(amps, 1, length(C.BIPOLAR.CUFF_CHANNELS));

disp('done with nerve cuff stimulation');

