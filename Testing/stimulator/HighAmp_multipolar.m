
%plotting for previously run trials at a single amplitude (multiple
%channels okay)
xippmex('close');
clear_timers; clear_sockets; clear classes; clear

stimch = cellfun(@(x) x+128, generateElecMap([1 5]), 'UniformOutput', false);
%stimChan = sortrows({5 [1 9]; 9 [5 13]; 6 [2 10]; 10 [6 14]; 7 [3 11]; 11 [7 15]; 8 [4 12]; 12 [8 16]}, 1); %example tripolar stim
%stimChan = cellfun(@(x) x+128, stimChan, 'UniformOutput', false);
    
    for i=1:length(stimch)
        fprintf('cathode: %d anode: %d %d %d\n', stimch{i, 1}, stimch{i, 2});
        for amps = [500:50:1000]
            stimDesign_presetAmpsMultichan(stimch{i, 1}, stimch{i, 2}, 'A', amps, ...
                320, 32, 0.2, 2, 2, 'digTrigger_enable', true)
        end
    end