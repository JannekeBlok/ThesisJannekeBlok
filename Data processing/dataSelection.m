% Data selection 
%
% This file will filter and select the correct data segments using a
% specified method. 
%   1.  First, the QTM data will be loaded. This includes the force data
%       (COP), as double-checked by computing manually with the separate 
%       channels.
%   2.  The COP data is downsampled to the same sampling frequency as the
%       IMU data.
%   3.  The relevant QTM data will then be loaded onto a separate struct.
%       This struct will include the events, the force plate data for the
%       correct force plate (force plate E).
%   4.  Load and filter the IMU data with a specified cut-off frequency for
%       the low-pass filter.
%   5.  Select quiet sitting data using the specified method.
%   6.  Select movement data using the specified indices

%% Define parameters required for data selection

fs = 100;                       % Sampling frequency (in Hz) used during the measurements, remains the same
cutOffLowPass = 10;             % Specified cut-off frequency of the low-pass filter. If this is an array, segments corresponding to each frequency will be selected. 
isAutomatic   = 1;              % Specify the data selection criterion used
isOverlap     = true;          % Boolean variable to specify whether overlap is allowed: if isOverlap == true, the timeframe(s) specified can have overlapping segments.
timeframe     = 30;             % Timeframe of segment(s). 

%% ---------------- Test Subject 001 ---------------- %%

% Define parameters specific to subject 1
backHeight         = 0.30;  % Back height of the subject, in m
topSensorHeight    = 0.17;  % Height from the ground to the top sensor, in m
bottomSensorHeight = 0.06;  % Height from the ground to the bottom sensor, in m
age                = 10;    % Age, in months

% 1. Load QTM data
load('TS001_C1_001.mat');
load('TS001_C1_002.mat');
load('TS001_C1_003.mat');

load('TS001_C2_001.mat');

% 2. Filter COP data
COP_C1_001       = filterQTM(TS001_C1_001.Force(3).COP, TS001_C1_001.Force(3).Frequency, cutOffLowPass);
COP_C1_002       = filterQTM(TS001_C1_002.Force(3).COP, TS001_C1_002.Force(3).Frequency, cutOffLowPass);
COP_C1_003       = filterQTM(TS001_C1_003.Force(3).COP, TS001_C1_003.Force(3).Frequency, cutOffLowPass);

% Save data for two force plates for condition C2
COP_C2_001.FP2   = filterQTM(TS001_C2_001.Force(3).COP, TS001_C2_001.Force(3).Frequency, cutOffLowPass);
COP_C2_001.FP3   = filterQTM(TS001_C2_001.Force(1).COP, TS001_C2_001.Force(1).Frequency, cutOffLowPass);

% 3. Save relevant QTM data as struct
QTM.C1(1) = struct('Events', TS001_C1_001.Events, ...
                   'COP',    COP_C1_001);

QTM.C1(2) = struct('Events', TS001_C1_002.Events, ...
                   'COP',    COP_C1_002);

QTM.C1(3) = struct('Events', TS001_C1_003.Events, ...
                   'COP',    COP_C1_003);


QTM.C2(1) = struct('Events', TS001_C2_001.Events, ...
                   'COP',    COP_C2_001);


% 4. Load, filter and save IMU data 
IMU.C1(1).Top    = loadAndFilter('TS001_C1_001_top.txt',   fs, cutOffLowPass);
IMU.C1(1).Bottom = loadAndFilter('TS001_C1_001_bottom.txt',fs, cutOffLowPass);

IMU.C1(2).Top    = loadAndFilter('TS001_C1_002_top.txt',   fs, cutOffLowPass);
IMU.C1(2).Bottom = loadAndFilter('TS001_C1_002_bottom.txt',fs, cutOffLowPass);

IMU.C1(3).Top    = loadAndFilter('TS001_C1_003_top.txt',   fs, cutOffLowPass);
IMU.C1(3).Bottom = loadAndFilter('TS001_C1_003_bottom.txt',fs, cutOffLowPass);

IMU.C2(1).Top    = loadAndFilter('TS001_C2_001_top.txt',   fs, cutOffLowPass);
IMU.C2(1).Bottom = loadAndFilter('TS001_C2_001_bottom.txt',fs, cutOffLowPass);


% 5. Select quiet sitting data using the specified data selection criterion
[QS.IMU, QS.QTM, minRMS, index, relevantDataset] = selectQuietSittingData(isAutomatic, timeframe, isOverlap, fs, IMU, QTM);
    
% 6. Select movement data
[AP,ML,ROT] = selectMovementData(isAutomatic, fs, timeframe, index(1).Data, relevantDataset(1).Data, IMU, QTM);


% 7. Save to Mat file
if isAutomatic == 1 && length(timeframe) == 1 && length(cutOffLowPass) == 1

    save("TS001", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

elseif isAutomatic == 1 && length(timeframe) == 3

    save("TS001_3x30", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

elseif isAutomatic == 1 && length(timeframe) > 3

    save("TS001_5_40", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

else 

    save("TS001_new", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

end


clear QS; clear AP; clear ML; clear ROT; clear IMU; clear QTM

%% ---------------- Test Subject 003 ---------------- %%

% Define parameters specific to subject 3
backHeight         = 0.33;  % in m
topSensorHeight    = 0.23;  % in m
bottomSensorHeight = 0.12;  % in m
age                = 13.5;  % in months

% 1. Load QTM data
load('TS003_C1_001.mat');
load('TS003_C1_002.mat');

load('TS003_C2_001.mat');

% 2. Downsample COP data to 100 Hz

COP_C1_001   = filterQTM(TS003_C1_001.Force(3).COP, TS003_C1_001.Force(3).Frequency, cutOffLowPass);
COP_C1_002   = filterQTM(TS003_C1_002.Force(3).COP, TS003_C1_002.Force(3).Frequency, cutOffLowPass);

COP_C2_001.FP2   = filterQTM(TS003_C2_001.Force(3).COP, TS003_C2_001.Force(3).Frequency, cutOffLowPass);
COP_C2_001.FP3   = filterQTM(TS003_C2_001.Force(1).COP, TS003_C2_001.Force(1).Frequency, cutOffLowPass);

% 3. Save QTM data as struct
QTM.C1(1) = struct('Events', TS003_C1_001.Events, ...
                   'COP',    COP_C1_001);

QTM.C1(2) = struct('Events', TS003_C1_002.Events, ...
                   'COP',    COP_C1_002);


QTM.C2(1) = struct('Events', TS003_C2_001.Events, ...
                   'COP',    COP_C2_001);


% 4. Load, filter and save IMU data 
IMU.C1(1).Top    = loadAndFilter('TS003_C1_001_top.txt',   fs, cutOffLowPass);
IMU.C1(1).Bottom = loadAndFilter('TS003_C1_001_bottom.txt',fs, cutOffLowPass);

IMU.C1(2).Top    = loadAndFilter('TS003_C1_002_top.txt',   fs, cutOffLowPass);
IMU.C1(2).Bottom = loadAndFilter('TS003_C1_002_bottom.txt',fs, cutOffLowPass);


IMU.C2(1).Top    = loadAndFilter('TS003_C2_001_top.txt',   fs, cutOffLowPass);
IMU.C2(1).Bottom = loadAndFilter('TS003_C2_001_bottom.txt',fs, cutOffLowPass);


% 5. Select quiet sitting data
[QS.IMU, QS.QTM, minRMS, index, relevantDataset] = selectQuietSittingData(isAutomatic, timeframe, isOverlap, fs, IMU, QTM);

% 6. Select movement data
[AP,ML,ROT] = selectMovementData(isAutomatic, fs, timeframe, index(1).Data, relevantDataset(1).Data, IMU, QTM);

% 7. Save to Mat file
if isAutomatic == 1 && length(timeframe) == 1 && length(cutOffLowPass) == 1

    save("TS003", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

elseif isAutomatic == 1 && length(timeframe) == 3

    save("TS003_3x30", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

elseif isAutomatic == 1 && length(cutOffLowPass) > 1

    save("TS003_5_40", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

else 

    save("TS003_new", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

end


clear QS; clear AP; clear ML; clear ROT; clear IMU; clear QTM


%% ---------------- Test Subject 004 ---------------- %%

% Define parameters specific to subject 3
backHeight         = 0.40;  % in m
topSensorHeight    = 0.27;  % in m
bottomSensorHeight = 0.18;  % in m
age                = 24;    % in months

% 1. Load QTM data
load('TS004_C1_001.mat');
load('TS004_C1_002.mat');


% 2. Downsample COP data to 100 Hz
COP_C1_001   = filterQTM(TS004_C1_001.Force(3).COP, TS004_C1_001.Force(3).Frequency, cutOffLowPass);
COP_C1_002   = filterQTM(TS004_C1_002.Force(3).COP, TS004_C1_002.Force(3).Frequency, cutOffLowPass);



% 3. Save QTM data as struct
QTM.C1(1) = struct('Events', TS004_C1_001.Events, ...
                   'COP',    COP_C1_001);

QTM.C1(2) = struct('Events', TS004_C1_002.Events, ...
                   'COP',    COP_C1_002);


% 4. Load, filter and save IMU data 
IMU.C1(1).Top    = loadAndFilter('TS004_C1_001_top.txt',   fs, cutOffLowPass);
IMU.C1(1).Bottom = loadAndFilter('TS004_C1_001_bottom.txt',fs, cutOffLowPass);

IMU.C1(2).Top    = loadAndFilter('TS004_C1_002_top.txt',   fs, cutOffLowPass);
IMU.C1(2).Bottom = loadAndFilter('TS004_C1_002_bottom.txt',fs, cutOffLowPass);



% 5. Select quiet sitting data
[QS.IMU, QS.QTM, minRMS, index, relevantDataset] = selectQuietSittingData(isAutomatic, timeframe, isOverlap, fs, IMU, QTM);

% 6. Select movement data
[AP,ML,ROT] = selectMovementData(isAutomatic, fs, timeframe, index(1).Data, relevantDataset(1).Data, IMU, QTM);

% 7. Save to Mat file
if isAutomatic == 1 && length(timeframe) == 1 && length(cutOffLowPass) == 1

    save("TS004", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

elseif isAutomatic == 1 && length(timeframe) == 3

    save("TS004_3x30", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

elseif isAutomatic == 1 && length(cutOffLowPass) > 1

    save("TS004_5_40", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

else 

    save("TS004_new", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

end


clear QS; clear AP; clear ML; clear ROT; clear IMU; clear QTM


%% ---------------- Test Subject 005 ---------------- %%

% Define parameters specific to subject 5
backHeight         = 0.34;  % in m
topSensorHeight    = 0.20;  % in m
bottomSensorHeight = 0.08;  % in m
age                = 23;    % in months


% 1. Load QTM data
load('TS005_C1_001.mat');
load('TS005_C1_002.mat');

load('TS005_C2_001.mat');

% 2. Downsample COP data to 100 Hz
COP_C1_001   = filterQTM(TS005_C1_001.Force(3).COP, TS005_C1_001.Force(3).Frequency, cutOffLowPass);
COP_C1_002   = filterQTM(TS005_C1_002.Force(3).COP, TS005_C1_002.Force(3).Frequency, cutOffLowPass);

COP_C2_001.FP2   = filterQTM(TS005_C2_001.Force(3).COP, TS005_C2_001.Force(3).Frequency, cutOffLowPass);
COP_C2_001.FP3   = filterQTM(TS005_C2_001.Force(1).COP, TS005_C2_001.Force(1).Frequency, cutOffLowPass);

% 3. Save QTM data as struct
QTM.C1(1) = struct('Events', TS005_C1_001.Events, ...
                   'COP',    COP_C1_001);

QTM.C1(2) = struct('Events', TS005_C1_002.Events, ...
                   'COP',    COP_C1_002);
               
               
QTM.C2(1) = struct('Events', TS005_C2_001.Events, ...
                   'COP',    COP_C2_001);


% 4. Load, filter and save IMU data 
IMU.C1(1).Top    = loadAndFilter('TS005_C1_001_top.txt',   fs, cutOffLowPass);
IMU.C1(1).Bottom = loadAndFilter('TS005_C1_001_bottom.txt',fs, cutOffLowPass);

IMU.C1(2).Top    = loadAndFilter('TS005_C1_002_top.txt',   fs, cutOffLowPass);
IMU.C1(2).Bottom = loadAndFilter('TS005_C1_002_bottom.txt',fs, cutOffLowPass);


IMU.C2(1).Top    = loadAndFilter('TS005_C2_001_top.txt',   fs, cutOffLowPass);
IMU.C2(1).Bottom = loadAndFilter('TS005_C2_001_bottom.txt',fs, cutOffLowPass);



% 5. Select quiet sitting data
[QS.IMU, QS.QTM, minRMS, index, relevantDataset] = selectQuietSittingData(isAutomatic, timeframe, isOverlap, fs, IMU, QTM);

% 6. Select movement data
[AP,ML,ROT] = selectMovementData(isAutomatic, fs, timeframe, index(1).Data, relevantDataset(1).Data, IMU, QTM);
    
if isAutomatic == 1 && length(timeframe) == 1 && length(cutOffLowPass) == 1

    save("TS005", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

elseif isAutomatic == 1 && length(timeframe) == 3

    save("TS005_3x30", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

elseif isAutomatic == 1 && length(cutOffLowPass) > 1

    save("TS005_5_40", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

else 

    save("TS005_new", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

end
clear QS; clear AP; clear ML; clear ROT; clear IMU; clear QTM

%% ---------------- Test Subject 006 ---------------- %%

% Define parameters specific to subject 6
backHeight         = 0.37;  % in m
topSensorHeight    = 0.19;  % in m
bottomSensorHeight = 0.06;  % in m
age                = 36;    % in months


% 1. Load QTM data
load('TS006_C1_001.mat');

load('TS006_C2_001.mat');

% 2. Downsample COP data to 100 Hz
COP_C1_001   = filterQTM(TS006_C1_001.Force(3).COP, TS006_C1_001.Force(3).Frequency, cutOffLowPass);

COP_C2_001.FP2   = filterQTM(TS006_C2_001.Force(3).COP, TS006_C2_001.Force(3).Frequency, cutOffLowPass);
COP_C2_001.FP3   = filterQTM(TS006_C2_001.Force(1).COP, TS006_C2_001.Force(1).Frequency, cutOffLowPass);


% 3. Save QTM data as struct
QTM.C1(1) = struct('Events', TS006_C1_001.Events, ...
                   'COP',    COP_C1_001);
               
               
QTM.C2(1) = struct('Events', TS006_C2_001.Events, ...
                   'COP',    COP_C2_001);


% 4. Load, filter and save IMU data 
IMU.C1(1).Top    = loadAndFilter('TS006_C1_001_top.txt',   fs, cutOffLowPass);
IMU.C1(1).Bottom = loadAndFilter('TS006_C1_001_bottom.txt',fs, cutOffLowPass);


IMU.C2(1).Top    = loadAndFilter('TS006_C2_001_top.txt',   fs, cutOffLowPass);
IMU.C2(1).Bottom = loadAndFilter('TS006_C2_001_bottom.txt',fs, cutOffLowPass);



% 5. Select quiet sitting data
[QS.IMU, QS.QTM, minRMS, index, relevantDataset] = selectQuietSittingData(isAutomatic, timeframe, isOverlap, fs, IMU, QTM);

% 6. Select movement data
[AP,ML,ROT] = selectMovementData(isAutomatic, fs, timeframe, index(1).Data, relevantDataset(1).Data, IMU, QTM);

% 7. Save to Mat file
if isAutomatic == 1 && length(timeframe) == 1 && length(cutOffLowPass) == 1

    save("TS006", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

elseif isAutomatic == 1 && length(timeframe) == 3

    save("TS006_3x30", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

elseif isAutomatic == 1 && length(cutOffLowPass) > 1

    save("TS006_5_40", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

else 

    save("TS006_new", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

end

clear QS; clear AP; clear ML; clear ROT; clear IMU; clear QTM

%% ---------------- Test Subject 007 ---------------- %%

% Define parameters specific to subject 7
backHeight         = 0.39;  % in m
topSensorHeight    = 0.20;  % in m
bottomSensorHeight = 0.09;  % in m
age                = 13;    % in months


% 1. Load QTM data
load('TS007_C1_001.mat');

load('TS007_C2_001.mat');
load('TS007_C2_002.mat');

% 2. Downsample COP data to 100 Hz
COP_C1_001   = filterQTM(TS007_C1_001.Force(3).COP, TS007_C1_001.Force(3).Frequency, cutOffLowPass);

COP_C2_001.FP2   = filterQTM(TS007_C2_001.Force(3).COP, TS007_C2_001.Force(3).Frequency, cutOffLowPass);
COP_C2_001.FP3   = filterQTM(TS007_C2_001.Force(1).COP, TS007_C2_001.Force(1).Frequency, cutOffLowPass);
COP_C2_002.FP2   = filterQTM(TS007_C2_002.Force(3).COP, TS007_C2_002.Force(3).Frequency, cutOffLowPass);
COP_C2_002.FP3   = filterQTM(TS007_C2_002.Force(1).COP, TS007_C2_002.Force(1).Frequency, cutOffLowPass);


% 3. Save QTM data as struct
QTM.C1(1) = struct('Events', TS007_C1_001.Events, ...
                   'COP',    COP_C1_001);
               
               
QTM.C2(1) = struct('Events', TS007_C2_001.Events, ...
                   'COP',    COP_C2_001);
               
QTM.C2(2) = struct('Events', TS007_C2_002.Events, ...
                   'COP',    COP_C2_002);


% 4. Load, filter and save IMU data 
IMU.C1(1).Top    = loadAndFilter('TS007_C1_001_top.txt',   fs, cutOffLowPass);
IMU.C1(1).Bottom = loadAndFilter('TS007_C1_001_bottom.txt',fs, cutOffLowPass);


IMU.C2(1).Top    = loadAndFilter('TS007_C2_001_top.txt',   fs, cutOffLowPass);
IMU.C2(1).Bottom = loadAndFilter('TS007_C2_001_bottom.txt',fs, cutOffLowPass);

IMU.C2(2).Top    = loadAndFilter('TS007_C2_002_top.txt',   fs, cutOffLowPass);
IMU.C2(2).Bottom = loadAndFilter('TS007_C2_002_bottom.txt',fs, cutOffLowPass);



% 5. Select quiet sitting data
[QS.IMU, QS.QTM, minRMS, index, relevantDataset] = selectQuietSittingData(isAutomatic, timeframe, isOverlap, fs, IMU, QTM);

% 6. Select movement data
[AP,ML,ROT] = selectMovementData(isAutomatic, fs, timeframe, index(1).Data, relevantDataset(1).Data, IMU, QTM);
    

% 7. Save to mat file
if isAutomatic == 1 && length(timeframe) == 1 && length(cutOffLowPass) == 1

    save("TS007", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

elseif isAutomatic == 1 && length(timeframe) == 3

    save("TS007_3x30", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

elseif isAutomatic == 1 && length(cutOffLowPass) > 1

    save("TS007_5_40", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

else 

    save("TS007_new", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

end
  

clear QS; clear AP; clear ML; clear ROT; clear IMU; clear QTM


%% ---------------- Test Subject 008 ---------------- %%

% Define parameters specific to subject 8
backHeight         = 0.39;  % in m
topSensorHeight    = 0.24;  % in m
bottomSensorHeight = 0.16;  % in m
age                = 20;    % in months


% 1. Load QTM data
load('TS008_C1_001.mat');
load('TS008_C1_002.mat');

load('TS008_C2_001.mat');
load('TS008_C2_002.mat');

% 2. Downsample COP data to 100 Hz

COP_C1_001   = filterQTM(TS008_C1_001.Force(3).COP, TS008_C1_001.Force(3).Frequency, cutOffLowPass);
COP_C1_002   = filterQTM(TS008_C1_002.Force(3).COP, TS008_C1_002.Force(3).Frequency, cutOffLowPass);

COP_C2_001.FP2   = filterQTM(TS008_C2_001.Force(3).COP, TS008_C2_001.Force(3).Frequency, cutOffLowPass);
COP_C2_001.FP3   = filterQTM(TS008_C2_001.Force(1).COP, TS008_C2_001.Force(1).Frequency, cutOffLowPass);
COP_C2_002.FP2   = filterQTM(TS008_C2_002.Force(3).COP, TS008_C2_002.Force(3).Frequency, cutOffLowPass);
COP_C2_002.FP3   = filterQTM(TS008_C2_002.Force(1).COP, TS008_C2_002.Force(3).Frequency, cutOffLowPass);


% 3. Save QTM data as struct
QTM.C1(1) = struct('Events', TS008_C1_001.Events, ...
                   'COP',    COP_C1_001);
QTM.C1(2) = struct('Events', TS008_C1_002.Events, ...
                   'COP',    COP_C1_002);
               
               
QTM.C2(1) = struct('Events', TS008_C2_001.Events, ...
                   'COP',    COP_C2_001);
               
QTM.C2(2) = struct('Events', TS008_C2_002.Events, ...
                   'COP',    COP_C2_002);


% 4. Load, filter and save IMU data 
IMU.C1(1).Top    = loadAndFilter('TS008_C1_001_top.txt',   fs, cutOffLowPass);
IMU.C1(1).Bottom = loadAndFilter('TS008_C1_001_bottom.txt',fs, cutOffLowPass);

IMU.C1(1).Top    = loadAndFilter('TS008_C1_002_top.txt',   fs, cutOffLowPass);
IMU.C1(1).Bottom = loadAndFilter('TS008_C1_002_bottom.txt',fs, cutOffLowPass);



IMU.C2(1).Top    = loadAndFilter('TS008_C2_001_top.txt',   fs, cutOffLowPass);
IMU.C2(1).Bottom = loadAndFilter('TS008_C2_001_bottom.txt',fs, cutOffLowPass);

IMU.C2(2).Top    = loadAndFilter('TS008_C2_002_top.txt',   fs, cutOffLowPass);
IMU.C2(2).Bottom = loadAndFilter('TS008_C2_002_bottom.txt',fs, cutOffLowPass);




% 5. Select quiet sitting data
[QS.IMU, QS.QTM, minRMS, index, relevantDataset] = selectQuietSittingData(isAutomatic, timeframe, isOverlap, fs, IMU, QTM);

% 6. Select movement data
[AP,ML,ROT] = selectMovementData(isAutomatic, fs, timeframe, index(1).Data, relevantDataset(1).Data, IMU, QTM);

% 7. Save to Mat file
if isAutomatic == 1 && length(timeframe) == 1 && length(cutOffLowPass) == 1

    save("TS008", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

elseif isAutomatic == 1 && length(timeframe) == 3

    save("TS008_3x30", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

elseif isAutomatic == 1 && length(cutOffLowPass) > 1

    save("TS008_5_40", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

else 

    save("TS008_new", 'QS','AP','ML','ROT','age','topSensorHeight','bottomSensorHeight','backHeight', 'isAutomatic', 'index','relevantDataset','minRMS');

end

clear QS; clear AP; clear ML; clear ROT; clear IMU; clear QTM