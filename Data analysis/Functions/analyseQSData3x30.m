function [] = analyseQSData3x30(par,fs)

    %% Load the correct files
    TS(1) = load('TS001_3x30.mat');
    TS(2) = load('TS003_3x30.mat');
    TS(3) = load('TS004_3x30.mat');
    TS(4) = load('TS005_3x30.mat');
    TS(5) = load('TS006_3x30.mat');
    TS(6) = load('TS007_3x30.mat');
    TS(7) = load('TS008_3x30.mat');

    %% Compute the outcome metrics

    for subject = 1:length(TS)

       
        [rmsJerk(subject).C1, rmsJerk(subject).C2] = computeRMSJerk(TS(subject), fs, true, true);

    end

    %% Make plot of RMS of jerk
    
    figure;
    set(gcf,'position',[par.x00, par.y00, par.width, 3*par.height])

    for subject = 1:length(TS)

        subplot(3,1,1)
        hold on; grid on
        ax = gca;
        ax.XMinorGrid = true;
        ax.YMinorGrid = true;
        ax.FontSize   = par.fontsize;
        ax.FontName   = par.fontname;
        scatter(TS(subject).age, rmsJerk(subject).C1.IMU.Res(1), par.markersize, par.color1, par.markerTypes(subject), 'LineWidth', par.linewidth)
        scatter(TS(subject).age, rmsJerk(subject).C1.IMU.Res(2), par.markersize, par.color2, par.markerTypes(subject), 'LineWidth', par.linewidth)
        scatter(TS(subject).age, rmsJerk(subject).C1.IMU.Res(3), par.markersize, par.color3, par.markerTypes(subject), 'LineWidth', par.linewidth)
        ylabel('RMS of jerk (in m/s^3)')
        title('Resultant')
        legend('Lowest rms(\omega)','Second-lowest rms(\omega)','Third-lowest rms(\omega)')

        subplot(3,1,2)
        hold on; grid on
        ax = gca;
        ax.XMinorGrid = true;
        ax.YMinorGrid = true;
        ax.FontSize   = par.fontsize;
        ax.FontName   = par.fontname;
        scatter(TS(subject).age, rmsJerk(subject).C1.IMU.AP(1), par.markersize, par.color1, par.markerTypes(subject), 'LineWidth', par.linewidth)
        scatter(TS(subject).age, rmsJerk(subject).C1.IMU.AP(2), par.markersize, par.color2, par.markerTypes(subject), 'LineWidth', par.linewidth)
        scatter(TS(subject).age, rmsJerk(subject).C1.IMU.AP(3), par.markersize, par.color3, par.markerTypes(subject), 'LineWidth', par.linewidth)
        ylabel('RMS of jerk (in m/s^3)')
        title('AP direction')

        subplot(3,1,3)
        hold on; grid on
        ax = gca;
        ax.XMinorGrid = true;
        ax.YMinorGrid = true;
        ax.FontSize   = par.fontsize;
        ax.FontName   = par.fontname;
        scatter(TS(subject).age, rmsJerk(subject).C1.IMU.ML(1), par.markersize, par.color1, par.markerTypes(subject), 'LineWidth', par.linewidth)
        scatter(TS(subject).age, rmsJerk(subject).C1.IMU.ML(2), par.markersize, par.color2, par.markerTypes(subject), 'LineWidth', par.linewidth)
        scatter(TS(subject).age, rmsJerk(subject).C1.IMU.ML(3), par.markersize, par.color3, par.markerTypes(subject), 'LineWidth', par.linewidth)
        ylabel('RMS of jerk (in m/s^3)')
        title('ML direction')
        xlabel('Age (in months)')

    end

end