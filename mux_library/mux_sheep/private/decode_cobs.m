function src = decode_cobs(in_bytes)
src = [];
i = 1;
    while i <= length(in_bytes)
        code = in_bytes(i);
        i = i + 1;
        for j=1:code-1
            src = [src in_bytes(i)];
            i = i + 1;
        end
        if code < MLMUX.COBS_MAX && i <= length(in_bytes)
            src = [src 0];
        end
    end
end