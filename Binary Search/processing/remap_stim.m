function stim = remap_stim(layout, stim)
%take the correct indices from the stimulation map, find them in the actual
%layout map of electrodes, and substitute these values

for i = 1:size(stim, 1)
    for j = 1:size(stim, 2)
        for k = 1:length(stim{i, j})
            yval = rem(stim{i, j}(k), size(layout, 2));
            if yval == 0
                yval = size(layout, 2); 
            end
            xval = ceil(stim{i, j}(k)/size(layout, 2)); 
            stim{i, j}(k) = layout(xval, yval);
        end
    end
end