% A function to compute the RMS acceleration for both the COP time series
% and the IMU data.
% 
% Input variables:
%   TS                  struct for specific child, including fields IMU and
%                       QTM
%   isSeparateSegments  boolean variable that determines whether the input
%                       segments should be handled as a single segment or 
%                       as separate segments


function [varargout] = computeRMSAcceleration(TS, fs, isSeparateSegments)

    % Check if there is data available for C1
    if any(strcmp(fieldnames(TS.QS.IMU.Data),'C1'))

        % First use the case where the segments are not separate
        if ~isSeparateSegments

            acc.IMU.AP = []; acc.IMU.ML = [];


            % Loop over all segments to create a single array
            for i = 1:length(TS.QS.IMU.Data.C1)

                if TS.index.Data(i,1) ~= 1
    
                    acc.IMU.AP = [acc.IMU.AP; TS.QS.IMU.Data.C1(i).Top.acc_z-mean(TS.QS.IMU.Data.C1(i).Top.acc_z)];
                    acc.IMU.ML = [acc.IMU.ML; TS.QS.IMU.Data.C1(i).Top.acc_x-mean(TS.QS.IMU.Data.C1(i).Top.acc_x)];
    
                else

                    acc.IMU.AP = NaN;
                    acc.IMU.ML = NaN;

                   
                end

            end

            % Compute the RMS for IMU  data
            varargout{1}.IMU.AP = rms(acc.IMU.AP);
            varargout{1}.IMU.ML  = rms(acc.IMU.ML);



        % Then do the same for the case where the segments should be
        % treated separately.
        else

            % Loop over all segments
            for i = 1:length(TS.QS.IMU.Data.C1)
                
                if TS.index.Data(i,1) ~= 1

                    acc.IMU(i).AP = TS.QS.IMU.Data.C1(i).Top.acc_z-mean(TS.QS.IMU.Data.C1(i).Top.acc_z);
                    acc.IMU(i).ML = TS.QS.IMU.Data.C1(i).Top.acc_x-mean(TS.QS.IMU.Data.C1(i).Top.acc_x);

            
                % Specify the displacement as NaN if the index is 1,
                % because the chosen segment is then not valid. 
                else 

                    acc.IMU(i).AP = NaN;
                    acc.IMU(i).ML = NaN;

             
                end

            end

            % Define outcomes for the case where the segments are separate
            for i = 1:length(acc.IMU)

                varargout{1}.IMU.pitch(i) = rms(acc.IMU(i).AP);
                varargout{1}.IMU.roll(i)  = rms(acc.IMU(i).ML);

            end

        end

    end

end