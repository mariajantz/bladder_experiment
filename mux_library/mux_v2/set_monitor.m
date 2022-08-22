function set_monitor(ser, on)
if on == true
    fwrite(ser, [encode_cobs(MLMUX.FLAG_MONITOR) 0 MLMUX.SET_FLAG])
  
else
    fwrite(ser, [encode_cobs(MLMUX.FLAG_MONITOR_OFF) 0 MLMUX.SET_FLAG])

end

end

