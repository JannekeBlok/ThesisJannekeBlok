% Function to analyse data for 5:40 seconds

function [] = analyseQSData5_40(par, fs)

    %% Load relevant data
    
    TS(1) = load("TS001_5_40.mat");
    TS(2) = load("TS003_5_40.mat");
    TS(3) = load("TS004_5_40.mat");
    TS(4) = load("TS005_5_40.mat");
    TS(5) = load("TS006_5_40.mat");
    TS(6) = load("TS007_5_40.mat");
    TS(7) = load("TS008_5_40.mat");

    ages = arrayfun(@(x) x.age, TS);

    %% Compute outcome metrics
    for subject = 1:length(TS)

        [rmsJerk(subject).C1, rmsJerk(subject).C2] = computeRMSJerk(TS(subject), fs, true, true);
        
    end

    %% Put them in the correct format 

    for subject = 1:length(TS)
        
        Jerk.C1.Res(:,subject) = rmsJerk(subject).C1.IMU.Res;
        Jerk.C1.AP(:,subject) = rmsJerk(subject).C1.IMU.AP;
        Jerk.C1.ML(:,subject) = rmsJerk(subject).C1.IMU.ML;

        

    end

    %% Make boxplot

    figure;
    set(gcf,'Position', [par.x00, par.y00, par.width, 2*par.height])
    boxplot(Jerk.C1.Res(1:30,:), ages)
    ax = gca;
    ax.FontSize = par.fontsize;
    ax.FontName = par.fontname;
    xlabel('Age (in months)')
    ylabel('RMS of jerk (in m/s^3)')


end