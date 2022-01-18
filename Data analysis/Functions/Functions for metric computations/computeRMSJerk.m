% Function to determine the RMS of jerk
% 
% Input variable
%   TS          Structure with data for a single child, including QTM and
%               IMU data.

function [varargout] = computeRMSJerk(TS, fs, isQuietSitting, isSeparateSegments,varargin)

    dt = 1/fs;

    if ~isSeparateSegments

        totalJerk.IMU.Res = []; totalJerk.IMU.AP = []; totalJerk.IMU.ML = [];
        QSJerk.IMU.Res = [];    QSJerk.IMU.AP = [];    QSJerk.IMU.ML = [];
        APJerk.IMU.Res = [];    APJerk.IMU.AP = [];    APJerk.IMU.ML = [];
        MLJerk.IMU.Res = [];    MLJerk.IMU.AP = [];    MLJerk.IMU.ML = [];
        ROTJerk.IMU.Res = [];   ROTJerk.IMU.AP = [];   ROTJerk.IMU.ML = [];


    end
    
    % Check if C1 is included
    if any(strcmp(fieldnames(TS.QS.IMU(1).Data),'C1'))

        % Make case with only quiet sitting and a single segment
        if isQuietSitting && ~isSeparateSegments

            for i = 1:length(TS.QS.IMU(1).Data.C1)

                    % Check if the index is equal to 1. If it is, the data
                    % is not usable.
                    if TS.index(1).Data(i,1) ~= 1
    
                        QSJerk.IMU.Res = [QSJerk.IMU.Res; computeResultant(firstDiff(TS.QS.IMU.Data.C1(i).Top.acc_x, dt), firstDiff(TS.QS.IMU.Data.C1(i).Top.acc_z, dt))-mean(computeResultant(firstDiff(TS.QS.IMU.Data.C1(i).Top.acc_x, dt), firstDiff(TS.QS.IMU.Data.C1(i).Top.acc_z, dt)))];
                        QSJerk.IMU.AP  = [QSJerk.IMU.AP;  firstDiff(TS.QS.IMU.Data.C1(i).Top.acc_z, dt)-mean(firstDiff(TS.QS.IMU.Data.C1(i).Top.acc_z, dt))];
                        QSJerk.IMU.ML  = [QSJerk.IMU.ML;  firstDiff(TS.QS.IMU.Data.C1(i).Top.acc_x, dt)-mean(firstDiff(TS.QS.IMU.Data.C1(i).Top.acc_x, dt))];
                                                                                    

                    else 
    
                        QSJerk.IMU.Res = NaN;
                        QSJerk.IMU.AP  = NaN;
                        QSJerk.IMU.ML  = NaN;

                    end

                

            

            end

            totalJerk = QSJerk;


        % Now do the same for the separate segments    
        elseif isQuietSitting

            for i = 1:length(TS.QS.IMU(1).Data.C1)

                if isempty(varargin)
                    
                    % Check if the index is equal to 1. If it is, the data
                    % is not usable.
                    if TS.index.Data(i,1) ~= 1
    
                        QSJerk.IMU(i).Res = computeResultant(firstDiff(TS.QS.IMU.Data.C1(i).Top.acc_x, dt), firstDiff(TS.QS.IMU.Data.C1(i).Top.acc_z, dt))-mean(computeResultant(firstDiff(TS.QS.IMU.Data.C1(i).Top.acc_x, dt), firstDiff(TS.QS.IMU.Data.C1(i).Top.acc_z, dt)));
                        QSJerk.IMU(i).AP  = firstDiff(TS.QS.IMU.Data.C1(i).Top.acc_z, dt)-mean(firstDiff(TS.QS.IMU.Data.C1(i).Top.acc_z, dt));
                        QSJerk.IMU(i).ML  = firstDiff(TS.QS.IMU.Data.C1(i).Top.acc_x, dt)-mean(firstDiff(TS.QS.IMU.Data.C1(i).Top.acc_x, dt));
    
                    else
    
                        QSJerk.IMU(i).Res = NaN;
                        QSJerk.IMU(i).AP  = NaN;
                        QSJerk.IMU(i).ML  = NaN;
    
                        QSJerk.QTM(i).Res = NaN;
                        QSJerk.QTM(i).AP  = NaN;
                        QSJerk.QTM(i).ML  = NaN;
    
                    end

                else
                    
                    % Check if the index is equal to 1. If it is, the data
                    % is not usable.
                    if TS.index(1).Data(i,1) ~= 1

                        for idx = 1:length(TS.QS.IMU)
    
                            QSJerk.IMU(idx).Res = computeResultant(firstDiff(TS.QS.IMU(idx).Data.C1(i).Top.acc_x, dt), firstDiff(TS.QS.IMU(idx).Data.C1(i).Top.acc_z, dt))-mean(computeResultant(firstDiff(TS.QS.IMU(idx).Data.C1(i).Top.acc_x, dt), firstDiff(TS.QS.IMU(idx).Data.C1(i).Top.acc_z, dt)));
                            QSJerk.IMU(idx).AP  = firstDiff(TS.QS.IMU(idx).Data.C1(i).Top.acc_z, dt)-mean(firstDiff(TS.QS.IMU(idx).Data.C1(i).Top.acc_z, dt));
                            QSJerk.IMU(idx).ML  = firstDiff(TS.QS.IMU(idx).Data.C1(i).Top.acc_x, dt)-mean(firstDiff(TS.QS.IMU(idx).Data.C1(i).Top.acc_x, dt));
    
                        end
                    else 
    
                        QSJerk.IMU(i).Res = NaN;
                        QSJerk.IMU(i).AP  = NaN;
                        QSJerk.IMU(i).ML  = NaN;
    
    
                    end

                end

                totalJerk = QSJerk;

            end

        

        end

        if length(totalJerk.IMU) > 1

    
            for i = 1:length(totalJerk.IMU)

                varargout{1}.IMU.Res(i) = rms(totalJerk.IMU(i).Res);
                varargout{1}.IMU.AP(i)  = rms(totalJerk.IMU(i).AP);
                varargout{1}.IMU.ML(i)  = rms(totalJerk.IMU(i).ML);


            end

        else 

            varargout{1}.IMU.Res = rms(totalJerk.IMU.Res);
            varargout{1}.IMU.AP  = rms(totalJerk.IMU.AP);
            varargout{1}.IMU.ML  = rms(totalJerk.IMU.ML);

        end

        
        
        
        %% Now do the same for the C2 condition
        % Check if C1 is included
        if any(strcmp(fieldnames(TS.QS.IMU(1).Data),'C2'))
            if ~isSeparateSegments

                totalJerk.IMU.Res = []; totalJerk.IMU.AP = []; totalJerk.IMU.ML = [];
                QSJerk.IMU.Res = [];    QSJerk.IMU.AP = [];    QSJerk.IMU.ML = [];
                APJerk.IMU.Res = [];    APJerk.IMU.AP = [];    APJerk.IMU.ML = [];
                MLJerk.IMU.Res = [];    MLJerk.IMU.AP = [];    MLJerk.IMU.ML = [];
                ROTJerk.IMU.Res = [];   ROTJerk.IMU.AP = [];   ROTJerk.IMU.ML = [];

                totalJerk.QTM.Res = []; totalJerk.QTM.AP = []; totalJerk.QTM.ML = [];
                QSJerk.QTM.Res = [];    QSJerk.QTM.AP = [];    QSJerk.QTM.ML = [];
                APJerk.QTM.Res = [];    APJerk.QTM.AP = [];    APJerk.QTM.ML = [];
                MLJerk.QTM.Res = [];    MLJerk.QTM.AP = [];    MLJerk.QTM.ML = [];
                ROTJerk.QTM.Res = [];   ROTJerk.QTM.AP = [];   ROTJerk.QTM.ML = [];

            end
    
    

            % Make case with only quiet sitting and a single segment
            if isQuietSitting && ~isSeparateSegments

                for i = 1:length(TS.QS.IMU(1).Data.C2)

                        % Check if the index is equal to 1. If it is, the data
                    % is not usable.
                        if TS.index(1).Data(i,2) ~= 1

                            QSJerk.IMU.Res = [QSJerk.IMU.Res; computeResultant(firstDiff(TS.QS.IMU.Data.C2(i).Top.acc_x, dt), firstDiff(TS.QS.IMU.Data.C2(i).Top.acc_z, dt))-mean(computeResultant(firstDiff(TS.QS.IMU.Data.C2(i).Top.acc_x, dt), firstDiff(TS.QS.IMU.Data.C2(i).Top.acc_z, dt)))];
                            QSJerk.IMU.AP  = [QSJerk.IMU.AP;  firstDiff(TS.QS.IMU.Data.C2(i).Top.acc_z, dt)-mean(firstDiff(TS.QS.IMU.Data.C2(i).Top.acc_z, dt))];
                            QSJerk.IMU.ML  = [QSJerk.IMU.ML;  firstDiff(TS.QS.IMU.Data.C2(i).Top.acc_x, dt)-mean(firstDiff(TS.QS.IMU.Data.C2(i).Top.acc_x, dt))];

                        else 

                            QSJerk.IMU.Res = NaN;
                            QSJerk.IMU.AP  = NaN;
                            QSJerk.IMU.ML  = NaN;

                        end





                end

                totalJerk = QSJerk;


            % Now do the same for the separate segments    
            elseif isQuietSitting

                for i = 1:length(TS.QS.IMU(1).Data.C2)

                    if isempty(varargin)

                        % Check if the index is equal to 1. If it is, the data
                    % is not usable.
                        if TS.index.Data(i,2) ~= 1

                            QSJerk.IMU(i).Res = computeResultant(firstDiff(TS.QS.IMU.Data.C2(i).Top.acc_x, dt), firstDiff(TS.QS.IMU.Data.C2(i).Top.acc_z, dt))-mean(computeResultant(firstDiff(TS.QS.IMU.Data.C2(i).Top.acc_x, dt), firstDiff(TS.QS.IMU.Data.C2(i).Top.acc_z, dt)));
                            QSJerk.IMU(i).AP  = firstDiff(TS.QS.IMU.Data.C2(i).Top.acc_z, dt)-mean(firstDiff(TS.QS.IMU.Data.C2(i).Top.acc_z, dt));
                            QSJerk.IMU(i).ML  = firstDiff(TS.QS.IMU.Data.C2(i).Top.acc_x, dt)-mean(firstDiff(TS.QS.IMU.Data.C2(i).Top.acc_x, dt));

                        else

                            QSJerk.IMU(i).Res = NaN;
                            QSJerk.IMU(i).AP  = NaN;
                            QSJerk.IMU(i).ML  = NaN;

                        end

                    else

                        if TS.index(1).Data(i,2) ~= 1

                            for idx = 1:length(TS.QS.IMU)

                                QSJerk.IMU(idx).Res = computeResultant(firstDiff(TS.QS.IMU(idx).Data.C2(i).Top.acc_x, dt), firstDiff(TS.QS.IMU(idx).Data.C2(i).Top.acc_z, dt))-mean(computeResultant(firstDiff(TS.QS.IMU(idx).Data.C2(i).Top.acc_x, dt), firstDiff(TS.QS.IMU(idx).Data.C2(i).Top.acc_z, dt)));
                                QSJerk.IMU(idx).AP  = firstDiff(TS.QS.IMU(idx).Data.C2(i).Top.acc_z, dt)-mean(firstDiff(TS.QS.IMU(idx).Data.C2(i).Top.acc_z, dt));
                                QSJerk.IMU(idx).ML  = firstDiff(TS.QS.IMU(idx).Data.C2(i).Top.acc_x, dt)-mean(firstDiff(TS.QS.IMU(idx).Data.C2(i).Top.acc_x, dt));

                            end
                        else 

                            QSJerk.IMU(i).Res = NaN;
                            QSJerk.IMU(i).AP  = NaN;
                            QSJerk.IMU(i).ML  = NaN;

                        end

                    end

                    totalJerk = QSJerk;

                end



            end

            if length(totalJerk.IMU) > 1


                for i = 1:length(totalJerk.IMU)

                    varargout{2}.IMU.Res(i) = rms(totalJerk.IMU(i).Res);
                    varargout{2}.IMU.AP(i)  = rms(totalJerk.IMU(i).AP);
                    varargout{2}.IMU.ML(i)  = rms(totalJerk.IMU(i).ML);


                end

            else 

                varargout{2}.IMU.Res = rms(totalJerk.IMU.Res);
                varargout{2}.IMU.AP  = rms(totalJerk.IMU.AP);
                varargout{2}.IMU.ML  = rms(totalJerk.IMU.ML);


            end
            
        else
            varargout{2}.IMU.Res = NaN;
            varargout{2}.IMU.AP  = NaN;
            varargout{2}.IMU.ML  = NaN;
            
        end
        
end