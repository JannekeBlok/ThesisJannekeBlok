function [] = analyseQSData30S(par,fs)
    
%% Load relevant data
    TS(1) = load("TS001.mat");
    TS(2) = load("TS003.mat");
    TS(3) = load("TS004.mat");
    TS(4) = load("TS005.mat");
    TS(5) = load("TS006.mat");
    TS(6) = load("TS007.mat");
    TS(7) = load("TS008.mat");

    
%% Compute the outcome metrics, start with the position

    for subject = 1:length(TS)

        rmsDisp(subject) = computeRMSDisplacement(TS(subject),false); 
        rmsVel(subject)  = computeRMSVelocity(TS(subject),fs, false);
        rmsAcc(subject)  = computeRMSAcceleration(TS(subject), fs, false);
        [rmsJerk(subject).C1, rmsJerk(subject).C2] = computeRMSJerk(TS(subject), fs, true, false);
        rmsCOPVel(subject) = computeCOPVelocity(TS(subject), fs, false);
        
    end



    %% Make figure of all outcomes

    figure;
    set(gcf,'Position',[par.x00, par.y00, 2*par.width, 4*par.height])

    for subject = 1:length(TS)
    
        subplot(2,2,1)
        ax = gca;
        ax.FontSize = par.fontsize;
        ax.FontName = par.fontname;
        ax.XMinorGrid = true;
        ax.YMinorGrid = true;
        scatter(TS(subject).age, rmsJerk(subject).C1.IMU.AP, par.markersize, par.color1, par.markerTypes(subject),'LineWidth', par.linewidth)
        ylabel('RMS of jerk (in m/s^3)')
        hold on
        scatter(TS(subject).age, rmsJerk(subject).C1.IMU.ML, par.markersize, par.color2,par.markerTypes(subject),'LineWidth', par.linewidth)
        legend('AP','ML')
        xlabel('Age (in months)')
        
        subplot(2,2,2)
        ax = gca;
        ax.FontSize = par.fontsize;
        ax.FontName = par.fontname;
        ax.XMinorGrid = true;
        ax.YMinorGrid = true;
        scatter(TS(subject).age, rmsAcc(subject).IMU.AP, par.markersize, par.color1, par.markerTypes(subject),'LineWidth', par.linewidth)
        ylabel('RMS of acceleration (in m/s^2)')
        hold on
        scatter(TS(subject).age, rmsAcc(subject).IMU.ML, par.markersize, par.color2,par.markerTypes(subject),'LineWidth', par.linewidth)
        legend('AP','ML')
        xlabel('Age (in months)')
        
        subplot(2,2,3)
        ax = gca;
        ax.FontSize = par.fontsize;
        ax.FontName = par.fontname;
        ax.XMinorGrid = true;
        ax.YMinorGrid = true;
        scatter(TS(subject).age, rmsVel(subject).IMU.AP, par.markersize, par.color1, par.markerTypes(subject),'LineWidth', par.linewidth)
        ylabel('RMS of angular velocity (in rad/s)')
        hold on
        scatter(TS(subject).age, rmsVel(subject).IMU.ML, par.markersize, par.color2,par.markerTypes(subject),'LineWidth', par.linewidth)
        xlabel('Age (in months)')
        legend('AP','ML')
        
        subplot(2,2,4)
        ax = gca;
        ax.FontSize = par.fontsize;
        ax.FontName = par.fontname;
        ax.XMinorGrid = true;
        ax.YMinorGrid = true;
        scatter(TS(subject).age, rmsDisp(subject).IMU.pitch, par.markersize, par.color1, par.markerTypes(subject),'LineWidth', par.linewidth)
        ylabel('RMS of angular displacement (in deg)')
        hold on
        scatter(TS(subject).age, rmsDisp(subject).IMU.roll, par.markersize, par.color2,par.markerTypes(subject),'LineWidth', par.linewidth)
        xlabel('Age (in months)')
        legend('AP','ML')
    end

    
    %% Jerk plot with both C1 and C2
    
   figure;
   set(gcf,'Position',[par.x00, par.y00, par.width, 3*par.height])
   
   for subject = 1:length(TS)
      
       subplot(3,1,1)
       hold on; grid on
       ax = gca;
       ax.XMinorGrid = true;
       ax.YMinorGrid = true;
       ax.FontSize   = par.fontsize;
       ax.FontName   = par.fontname;
       scatter(TS(subject).age, rmsJerk(subject).C1.IMU.Res, par.markersize, par.color1, par.markerTypes(subject),'Linewidth',par.linewidth)
       scatter(TS(subject).age, rmsJerk(subject).C2.IMU.Res, par.markersize, par.color2, par.markerTypes(subject),'Linewidth', par.linewidth)
       ylabel('RMS of jerk (in m/s^3)')
       legend('C1', 'C2')
       title('Resultant')
       
       subplot(3,1,2)
       hold on; grid on
       ax = gca;
       ax.XMinorGrid = true;
       ax.YMinorGrid = true;
       ax.FontSize   = par.fontsize;
       ax.FontName = par.fontname;
       scatter(TS(subject).age, rmsJerk(subject).C1.IMU.AP, par.markersize, par.color1, par.markerTypes(subject),'Linewidth',par.linewidth)
       scatter(TS(subject).age, rmsJerk(subject).C2.IMU.AP, par.markersize, par.color2, par.markerTypes(subject),'Linewidth', par.linewidth)
       title('AP direction')
       ylabel('RMS of jerk (in m/s^3)')
       
       subplot(3,1,3)
       hold on; grid on
       ax = gca;
       ax.XMinorGrid = true;
       ax.YMinorGrid = true;
       ax.FontSize   = par.fontsize;
       ax.FontName   = par.fontname;
       scatter(TS(subject).age, rmsJerk(subject).C1.IMU.ML, par.markersize, par.color1, par.markerTypes(subject),'Linewidth',par.linewidth)
       scatter(TS(subject).age, rmsJerk(subject).C2.IMU.ML, par.markersize, par.color2, par.markerTypes(subject),'Linewidth', par.linewidth)
       title('ML direction')
       ylabel('RMS of jerk (in m/s^3)')
       xlabel('Age (in months)')
       
   end
   

   %% Plot RMS of jerk vs COP velocity
   figure;
   set(gcf,'Position',[par.x00, par.y00, par.width, 3*par.height])
  
    for subject = 1:length(TS)
        
        subplot(2,1,1)
        hold on; grid on
        ax = gca;
        ax.XMinorGrid = true;
        ax.YMinorGrid = true;
        ax.FontSize = par.fontsize;
        ax.FontName = par.fontname;
        colororder([par.color1; par.color2])
        yyaxis left
        h1 = scatter(TS(subject).age, rmsJerk(subject).C1.IMU.AP, par.markersize, par.color1, par.markerTypes(subject), 'Linewidth', par.linewidth)
        ylabel('RMS of jerk (in m/s^3)')
        yyaxis right
        h2 = scatter(TS(subject).age, rmsCOPVel(subject).QTM.AP, par.markersize, par.color2, par.markerTypes(subject),'Linewidth', par.linewidth)
        ylabel('RMS of COP velocity (in mm/s)')
        title('AP direction')
        legend([h1,h2],'IMU','COP')

        subplot(2,1,2)
        hold on; grid on
        ax = gca;
        ax.XMinorGrid = true;
        ax.YMinorGrid = true;
        ax.FontSize = par.fontsize;
        ax.FontName = par.fontname;
        colororder([par.color1; par.color2])
        yyaxis left
        scatter(TS(subject).age, rmsJerk(subject).C1.IMU.ML, par.markersize, par.color1, par.markerTypes(subject), 'Linewidth', par.linewidth)
        ylabel('RMS of jerk (in m/s^3)')
        yyaxis right
        scatter(TS(subject).age, rmsCOPVel(subject).QTM.ML, par.markersize, par.color2, par.markerTypes(subject),'Linewidth', par.linewidth)
        ylabel('RMS of COP velocity (in mm/s)')
        title('ML direction')
        xlabel('Age (in months)')

    end

   

end