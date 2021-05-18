%% Run Micro-leads MUX to Switch Ripple Stimulation Channels
% You only need a few functions in this MATLAB software package to
% send commands to ML MUX controller box, which in turn controls 
% Micro-leads MUX ASIC embedded in the active cat paddle.
%
% <<img/system_diagram.svg>>
% 
% The goal is to be able to "switch"  MUX ASIC so that Ripple
% stimulation currents can be routed to different electrodes in the
% active cat paddle for neural stimulation (see the system diagram above).
%
%
%% Connect the Hardware
% Connect all the hardware according to the diagram above. Plug in the USB
% cable *last*. Because there is no power on/off button, you can plug/unplug 
% the USB cable to power/un-power the ML MUX controller box. The USB
% isolator is to isolate (or "float") the ML MUX controller box from the connected PC
% power supply "ground".
% 
% A BLUE LED lights up when ML MUX controller box is powered up
% and finishes its internal check-up sequence. This may take several
% seconds after USB plug-in. 
%
% In case you haven't plugged in the DB9 MUX control cable, there is no 
% electrical connection to ML active cat paddle or the breakout MUX tester,
% RED LED will start flashing.
%
% RED LED flashing indicates a missing communication link between ML MUX
% controller box and the MUX ASIC. To establish or re-establish this link, you
% need to follow the steps below.



%% Open Serial Port
% 1. Find the USB Serial Port number from your "System/Device Manager" (for example COM89 in the screen shot below)
%
% <<img/com_port.jpg>>
% 


%%
% 2. Open the serial port with *YOUR serial port number* (probably not
% COM89 in your case) and set baudrate = 9600; Now "ser" is the handle to
% that serial port that is used to communicate to the MUX controller box. 

ser = serial("COM4", "BaudRate",9600)
fopen(ser)
%instrfind %run line to check if status is open
%if unplugged and replugged in, do this: 
%delete(instrfind)

%% Initialize/Re-initalize MUX 
% To power up MUX ASIC properly, run "start_mux" function with the serial
% port #.
%
% The RED LED flashing should be extinguished after calling this function

start_mux(ser) 

%%
% The communication link between the MUX controller box and the MUX ASIC is constantly
% monitored. Whenever the link is broken, run this function immediately to re-establish the link.
% 
% MUX ASIC will *NOT* function when RED LED is flashing.
%
% If the USB cable is unplugged and re-plugged, the "serial" port needs to
% be re-opened as well.


%% Assign Stimulation Channels
% You select the list of electrodes from the paddle (see paddle electrode
% sites mapping) to be stimulated, as the input to "mux_assign" function.
% 
% <<img/electrode_sites.jpg>>
%
% The output "e" should match your input, indicating the assignment
% completed successfully.
% 
% The output "s" are the corresponding Ripple stimulation channels to be
% turned on for stimulation (see Ripple connector pinout mapping)
%
% <<img/ripple_channels.jpg>>
%
% The output "p" are the command bytes to be sent to MUX controller box

[e,s,p] = mux_assign([1,8,0,9]) %doesn't run stim yet, just spits out electrode numbers - e: electrode site, s: ripple channel, p: command for switching


%%
% In the example above, the selected electrode sites are list [1,8,0,9]. 
% The corresponding Ripple channels are list [3, 1, 9, 15].
% Note: the order of these two lists indicates one-to-one relationship
%
% * Ripple_channel 3 <==> Paddle_e_site 1 
% * Ripple_channel 1 <==> Paddle_e_site 8
% * Ripple_channel 9 <==> Paddle_e_site 0
% * Ripple_channel 15 <==> Paddle_e_site 9



%% Switch MUX
% Once the assignment completes successfully, you can perform the
% experiment by following the last two steps:
%
% 1. send the command "p" to ML MUX Controller box to activate the switching
%
switch_mux(ser, p)

%%
% 2. send stimulation to the corresponding Ripple channels, as the list in "s"
fprintf("Ripple ch%d <==> E%d \n", [s;e])

% NOTE: << add your Ripple commands to send stimulations on channels "s" >>


%% Build and run Ripple commands

C.ACTIVE_CHAN = [1:128]; %This assumes that you are plugging this headstage into port A
%Numbers relevant to each port B, C, D are in the xippmex docs.
C.STIM_POLARITY = 0; % 1 - positive (anodic) phase first, we usually do cathodic first
C.STIM_PW_MS = 0.2; % pulse width in milliseconds for each phase.
C.THRESH_REPS = 200; %how many pulses to include in the stimulus train
C.QUIET_REC = 0.5; %time in seconds to record without stimulation before and after

cathAmp = 500; %microamps of stimulation on each electrode
freq = 10; % stimulation frequency in Hz

fpath = 'D:\DataTanks\2020\MUXtest\datafile';

%build cmd and stim
single_amp_stim(C, s, cathAmp, freq, fpath)

%% Intense testing - set MUX channels, run Ripple stim, set new MUX 
% channels with no pause...see if issues

test_chan = {[0 1 3], [6 9 4], [18 5 12], [30 20 25], [34 11 13], [23 15 51], [50 40 45]};

err = []; 
for i = 1:length(test_chan)
    [e,s,p] = mux_assign(test_chan{i});
    if isempty(p)
        err = [err i]; 
        continue
    end
    switch_mux(ser, p); 
    %pause?
    single_amp_stim(C, s, cathAmp, freq, fpath)
end

err




