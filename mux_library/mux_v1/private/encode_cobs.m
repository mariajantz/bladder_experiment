function out = encode_cobs(out_bytes)
%encode COBS
%   return uint8 array
if length(out_bytes) > MLMUX.COBS_MAX - 1
    out = [];
    return
end
out = [0];
dest_index = 2;
code_index = 1;
code = 1;




for b = out_bytes
    if b == 0
        finish
    else
        out = [out b] ;
        
        dest_index = dest_index + 1;
        code = code + 1;
        if code == MLMUX.COBS_MAX
            finish
        end
    end
end
out(code_index) = code;

    function finish
        out(code_index) = code;
        out  = [out 0];
        code_index = dest_index;
        dest_index = dest_index + 1;
        code = 1;
    end

end

