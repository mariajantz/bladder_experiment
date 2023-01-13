%

impedance_gnd = [38, 5.9, 17.1, 5.3, 8.8; 21.7, 21, 16.5, 6.8, 5.5; ...
    14.6 42.1 21.6 6.3 0; 20.8 9.7 21.9 6.2 4.8; 28.4 0 27.3 18 20.9; ...
    19.9 23 23.7 8 0; 32.3 17.3 23.9 5.7 18.1; 21.8 17.2 10.6 14.4 23.8];
figure; 
imagesc(impedance_gnd)

colormap(viridis)
colorbar

impedance_nognd = [26.2, 21.9, 32, 21.8, 25.4; 37.6, 35.6, 25, 24.6, 24.6; ...
    33.8 58 38.1 26.4 0; 37.7 21.4 37.8 25.6 24.2; 49.8 0 46.2 38.6 38.7; ...
    38.6 40.1 45.8 19.8 0; 41.9 35.8 40.9 17.4 37.3; 40.5 31.7 22.3 34.1 43.2];
figure; 
imagesc(impedance_nognd)

colormap(viridis)
colorbar