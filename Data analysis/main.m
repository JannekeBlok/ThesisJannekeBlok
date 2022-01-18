% Function to determine the outcome metrics for different conditions

%% Plot parameters
fs = 100;

par.color1  = [35, 35, 35]/256;
par.color3 = [183, 239, 246]/256;
par.color2 = [252,141,89]/256;
par.color4  = [56, 114, 108]/256;
par.color5  = [143, 201, 58]/256;
par.color6  = [174, 140, 163]/256;
par.color7  = 'k';
par.x00          = 10;
par.y00          = 10;
par.width        = 600;
par.height       = 200;
par.markersize   = 120;
par.fontsize     = 16;
par.fontname     = 'Times';
par.markerTypes  = ['*', 'o', '^', 'd', '+', 'x', 's'];
par.markerColors = {par.color1, par.color1, par.color1, par.color1, par.color1, par.color1, par.color1};
par.linewidth    = 2.5;

%% Use functions to determine the outcome metrics for different conditions

% Start with the regular 30 second trial. 
analyseQSData30S(par,fs);

% Look at 3x30 seconds
% analyseQSData3x30(par,fs)

% Look at 5:40 seconds with 1-second intervals
% analyseQSData5_40(par, fs)