% Helper function that initializes a NI DAQ session with max sampling rate
% numberOfChannels - array of channels to record (ex: [1:32], [1,3,5]...)
% recordTimeInSeconds - numbers of seconds to record

% returns - DAQ session, call session.startForeground() to start recording
function session = initializeDAQ(channelsToRecord, recordTimeInSeconds)

if min(channelsToRecord) < 1 || max(channelsToRecord) > 32
    error('DAQ only supports channels 1-32') 
end

if length(channelsToRecord) > 32
   error('DAQ only supports 32 channels') 
end     

session = daq.createSession('ni');
daqModules = daq.getDevices;

I = strcmp({daqModules(:).Model},'NI 9220 (DSUB)');
modules = {daqModules(I).ID};

for n = channelsToRecord
    
    if n < 17
        addAnalogInputChannel(session, modules{1}, (n-1), 'Voltage');
    else
        addAnalogInputChannel(session, modules{2}, (n-17), 'Voltage');
    end
    
end

session.DurationInSeconds = recordTimeInSeconds;

session.Rate = session.RateLimit(2);

end

function startBackgroundDataCollection()
    
end

function data = startForegroundDataCollection()
    data = obj.Session.startForeground();
end

% DAQ background callback function
function handleData(~, event)
    daqData = event.Data; % Set the global daq data
end