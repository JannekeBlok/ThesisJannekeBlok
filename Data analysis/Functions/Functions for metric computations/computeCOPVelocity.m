% Function to compute the COP velocity
%
% Input variables
%   TS                      Struct with IMU and QTM data for a single child
%   fs                      Sampling frequency (in Hz)
%   isSeparateSegments      Boolean variable that determines whether the
%                           data should be treated as a single segment or
%                           as multiple segments.
%
% Output variables
%   varargout               Struct with RMS of COP velocity

function [varargout] = computeCOPVelocity(TS, fs, isSeparateSegments)

% Check if there is data available for C1
    if any(strcmp(fieldnames(TS.QS.IMU.Data),'C1'))

        % First use the case where the segments are not separate
        if ~isSeparateSegments

            vel.QTM.AP = []; vel.QTM.ML = [];

            % Loop over all segments to create a single array
            for i = 1:length(TS.QS.IMU.Data.C1)

                if TS.index.Data(i,1) ~= 1

                    vel.QTM.AP = [vel.QTM.AP; downsample(firstDiff(TS.QS.QTM.Data.C1(i).COP(2,:),1/(5*fs))-mean(firstDiff(TS.QS.QTM.Data.C1(i).COP(2,:),1/(5*fs))),5)];
                    vel.QTM.ML = [vel.QTM.ML; downsample(firstDiff(TS.QS.QTM.Data.C1(i).COP(1,:),1/(5*fs))-mean(firstDiff(TS.QS.QTM.Data.C1(i).COP(1,:),1/(5*fs))),5)];


                else
                    
                    vel.QTM.AP = NaN;
                    vel.QTM.ML = NaN;
                    
                end

            end

            
            varargout{1}.QTM.AP    = rms(vel.QTM.AP);
            varargout{1}.QTM.ML    = rms(vel.QTM.ML);


        % Then do the same for the case where the segments should be
        % treated separately.
        else

            % Loop over all segments
            for i = 1:length(TS.QS.IMU.Data.C1)
                
                if TS.index.Data(i,1) ~= 1

                    vel.QTM(i).AP = downsample(firstDiff(TS.QS.QTM.Data.C1(i).COP(2,:),1/fs)-mean(firstDiff(TS.QS.QTM.Data.C1(i).COP(2,:),1/fs)),5); 
                    vel.QTM(i).ML = downsample(firstDiff(TS.QS.QTM.Data.C1(i).COP(1,:),1/fs)-mean(firstDiff(TS.QS.QTM.Data.C1(i).COP(1,:),1/fs)),5);

                % Specify the displacement as NaN if the index is 1,
                % because the chosen segment is then not valid. 
                else 


                    vel.QTM(i).AP = NaN;
                    vel.QTM(i).ML = NaN;

                end

            end

            % Define outcomes for the case where the segments are separate
            for i = 1:length(vel.QTM)


                varargout{1}.QTM.AP(i)  = rms(vel.QTM(i).AP);
                varargout{1}.QTM.ML(i)  = rms(vel.QTM(i).ML);

            end

        end

    end

end