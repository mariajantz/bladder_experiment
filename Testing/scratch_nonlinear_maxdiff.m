
for i = 1:32
idc = find(amps{i}(:, 2)<100);
amps{i}(idc, :) = [];
clear('c', 'd'); 
fprintf('Channel %d \n', i); 
a = amps{i}(:, 2)-amps{i}(:, 3);
b = amps{i}(:, 2)+amps{i}(:, 4);
c = find(a./amps{i}(:, 2)>0.05);
c = [c; find(a./amps{i}(:, 2)<-0.05)];
c = [c; find(b./amps{i}(:, 2)>0.05)];
c = [c; find(b./amps{i}(:, 2)<-0.05)];
fprintf('Outside of .05: %d \n', length(c));
d = find(a./amps{i}(:, 2)>0.1);
d = [d; find(a./amps{i}(:, 2)<-0.1)];
d = [d; find(b./amps{i}(:, 2)>0.1)];
d = [d; find(b./amps{i}(:, 2)<-0.1)];
fprintf('Outside of .10: %d \n', length(d));
end