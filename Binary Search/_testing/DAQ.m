classdef DAQ
    
    methods(Static)
        
        % Helper method for initializing the data acquisition
        % Return:
        % session - NI DAQ session. Use the DAQ session to set record time,
        %   sampling frequency, etc... Use session.startForeground() or
        %   session.startBackground to start recording.
        %   https://www.mathworks.com/help/daq/ref/daq.createsession.html
        % daqMap - cell array containing the daq module ID, analog input
        %   channel, channel number, and daq module serial number for each
        %   channel
        function [session, daqMap] = initialize(channelsToRecord)
                                    
            % Create daq session
            session = daq.createSession('ni');
            daqModules = daq.getDevices;
            
            % Find 9220 module locations using NI 9220 (DSUB) model property
            I = strcmp({daqModules(:).Model}, 'NI 9220 (DSUB)');
            modules = {daqModules(I).ID};
            
            % Initialize daqMap
            m = length(channelsToRecord);
            daqMap{m, 4} = zeros(m, 4);
            
            % Configure DAQ channels
            for n = 1:length(channelsToRecord)
                
                k = floor(n/17) + 1; % Module number
                
                addAnalogInputChannel(session, ... % Session
                    modules{k}, ... % Module
                    k + mod(n,17) - 2, ... % Analog input channel
                    'Voltage'); % Measure voltage
                
                % Get module serial number
                [~, serialNumber] = daq.ni ...
                    .NIDAQmx ...
                    .DAQmxGetDevSerialNum(modules{k}, uint32(0));
                
                % Record the DAQ module properties
                daqMap{n, 1} = modules{k}; % DAQ module ID
                daqMap{n, 2} = session.Channels(n).ID; % DAQ module AI channel
                daqMap{n, 3} = ['Channel_' num2str(channelsToRecord(n))]; % Channel number
                daqMap{n, 4} = dec2hex(serialNumber); % DAQ module serial number
                
            end
            
            % Clean up
            clear serialNumber I daqModules modules k m n;
            
        end
    end
end