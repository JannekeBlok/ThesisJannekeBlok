% Function that computes the rms velocity for both the COP linear velocity
% and the IMU angular velocity as obtained from the gyroscope.
%
% Input variables 
%   TS                  Struct with fields IMU and QTM that contain the 
%                       data for a single child
%   isSeparateSegments  boolean variable that defines whether the segments
%                       should be treated as separate segments or as a
%                       single segment.
% 

function [varargout] = computeRMSVelocity(TS, fs, isSeparateSegments)

     % Check if there is data available for C1
    if any(strcmp(fieldnames(TS.QS.IMU.Data),'C1'))

        % First use the case where the segments are not separate
        if ~isSeparateSegments

            vel.IMU.AP = []; vel.IMU.ML = [];
            vel.QTM.AP = []; vel.QTM.ML = [];

            % Loop over all segments to create a single array
            for i = 1:length(TS.QS.IMU.Data.C1)

                if TS.index.Data(i,1) ~= 1

                    vel.IMU.AP = [vel.IMU.AP; TS.QS.IMU.Data.C1(i).Top.vel_x-mean(TS.QS.IMU.Data.C1(i).Top.vel_x)];
                    vel.IMU.ML = [vel.IMU.ML; TS.QS.IMU.Data.C1(i).Top.vel_z-mean(TS.QS.IMU.Data.C1(i).Top.vel_z)];
    
                else

                    vel.IMU.AP = NaN;
                    vel.IMU.ML = NaN;
                    
                    vel.QTM.AP = NaN;
                    vel.QTM.ML = NaN;
                    
                end

            end

            % Compute the RMS for IMU and QTM data
            varargout{1}.IMU.AP  = rms(vel.IMU.AP);
            varargout{1}.IMU.ML  = rms(vel.IMU.ML);
            


        % Then do the same for the case where the segments should be
        % treated separately.
        else

            % Loop over all segments
            for i = 1:length(TS.QS.IMU.Data.C1)
                
                if TS.index.Data(i,1) ~= 1

                    vel.IMU(i).AP = TS.QS.IMU.Data.C1(i).Top.vel_x-mean(TS.QS.IMU.Data.C1(i).Top.vel_x);
                    vel.IMU(i).ML = TS.QS.IMU.Data.C1(i).Top.vel_z-mean(TS.QS.IMU.Data.C1(i).Top.vel_z);

                % Specify the displacement as NaN if the index is 1,
                % because the chosen segment is then not valid. 
                else 

                    vel.IMU(i).AP = NaN;
                    vel.IMU(i).ML = NaN;

                end

            end

            % Define outcomes for the case where the segments are separate
            for i = 1:length(vel.IMU)

                varargout{1}.IMU.AP(i)  = rms(vel.IMU(i).AP);
                varargout{1}.IMU.ML(i)  = rms(vel.IMU(i).ML);


            end

        end

    end

end