%MUX stimulator high amplitude surveys
% Because the MUX has a standard layout and channels contradict each other,
% this uses a hard-coded order of stimulus

%% STARTUP: check fastsettle, connect to trellis, connect to MUX
warning('Is fast-settle on?')
keyboard

%If in TCP mode, run this one time at the beginning of testing
% set up to trigger recording
% status = xippmex('tcp');
% if status == 0
%     error('Xippmex is not connecting.')
% end
% 
% oper = 148;
% xippmex('addoper', oper);

%MUX setup
ser = serial("COM4", "BaudRate",9600)
fopen(ser)

start_mux(ser) 

%% Define cat variables
%import cat information
C = experiment_constants_Neville;

%layout in terms of MUX channel label
channel_layout = [18, 1, 5, 17, 37; 32, 8, 2, 6, 27; 28, 0, 4, 16, 26; ...
    19, 9, 3, 7, 31; 39, 20, 23, 15, 51; 50, 34, 21, 24, 42; ...
    40, 11, 13, 35, 46; 45, 10, 22, 25, 41];

%choose all the channel sets
test_order = [18, 0, 23, 35; 1, 4, 15, 46; 5, 16, 51, 40; 17, 26, ]


