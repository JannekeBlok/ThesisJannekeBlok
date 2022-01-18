% A function to compute the RMS displacement for both the COP time series
% and the IMU data.
% 
% Input variables:
%   TS                  struct for specific child, including fields IMU and
%                       QTM
%   isSeparateSegments  boolean variable that determines whether the input
%                       segments should be handled as a single segment or 
%                       as separate segments


function [varargout] = computeRMSDisplacement(TS, isSeparateSegments)

    % Check if there is data available for C1
    if any(strcmp(fieldnames(TS.QS.IMU.Data),'C1'))

        % First use the case where the segments are not separate
        if ~isSeparateSegments

            disp.IMU.x = []; disp.IMU.z = [];
            disp.QTM.x = []; disp.QTM.z = [];

            % Loop over all segments to create a single array
            for i = 1:length(TS.QS.IMU.Data.C1)

                % Check if the data is actually useful

                if TS.index.Data(i,1) ~= 1

                    disp.IMU.x = [disp.IMU.x; TS.QS.IMU.Data.C1(i).Top.pitch-mean(TS.QS.IMU.Data.C1(i).Top.pitch)];
                    disp.IMU.z = [disp.IMU.z; TS.QS.IMU.Data.C1(i).Top.roll-mean(TS.QS.IMU.Data.C1(i).Top.roll)];
    
                else

                    disp.IMU.x = NaN;
                    disp.IMU.z = NaN;
                 
                end


            end

            % Compute the RMS for IMU and QTM data
            varargout{1}.IMU.pitch = rms(disp.IMU.x);
            varargout{1}.IMU.roll  = rms(disp.IMU.z);



        % Then do the same for the case where the segments should be
        % treated separately.
        else

            % Loop over all segments
            for i = 1:length(TS.QS.IMU.Data.C1)
                
                if TS.index.Data(i,1) ~= 1

                    disp.IMU(i).x = TS.QS.IMU.Data.C1(i).Top.pitch-mean(TS.QS.IMU.Data.C1(i).Top.pitch);
                    disp.IMU(i).z = TS.QS.IMU.Data.C1(i).Top.roll-mean(TS.QS.IMU.Data.C1(i).Top.roll);

                % Specify the displacement as NaN if the index is 1,
                % because the chosen segment is then not valid. 
                else 

                    disp.IMU(i).x = NaN;
                    disp.IMU(i).z = NaN;

                end

            end

            % Define outcomes for the case where the segments are separate
            for i = 1:length(disp.IMU)

                varargout{1}.IMU.pitch(i) = rms(disp.IMU(i).x);
                varargout{1}.IMU.roll(i)  = rms(disp.IMU(i).z);

            end

        end

    end

end