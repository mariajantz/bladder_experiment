function analog_out(session, val, scale)
% val = analog output value
% scale = scale factor
% session = DAQ session
% assumes +/-10 V range
    outval = val/scale;
    outval = min(max(outval, -10), 10);
    outputSingleScan(session, outval);
end