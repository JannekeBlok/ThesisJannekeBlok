% Depending on the required method, this function will select the correct
% quiet sitting segment(s).
%
% Input variables:
%   isAutomatic         Variable that states which method is used.
%                       If isAutomatic = 0, the manual method is used.
%                       If isAutomatic = 1, the automatic method by
%                       minimal RMS velocity is used. If isAutomatic = 2,
%                       the automatic method by minimal RMS acceleration is
%                       used.
%   timeframe           Required quiet sitting timeframe if isAutomatic = 1
%   isOverlap           Boolean variable to decide whether chosen segments 
%                       can overlap
%   fs                  Sampling frequency, in Hz
%   IMU                 Struct with IMU data, including Top and Bottom
%                       fields for both conditions C1 and C2
%   QTM                 Structs with QTM data
%
% Output variables:
%   newIMU              Struct with correct segments of IMU data
%   newQTM              Struct with correct segments of QTM data
%   minRMS              Array with the minimal RMS values used for the
%                       first two methods, equal to NaN if the manual
%                       method is chosen.
%   index               Starting index of the chosen segment. If this is
%                       equal to 1, the algorithm was not able to find a
%                       minimum.
%   relevantDataset     The dataset from which each segment was selected.


function [newIMU, newQTM, minRMS, index, relevantDataset] = selectQuietSittingData(isAutomatic, timeframe, isOverlap, fs, IMU, QTM)


    % Use the first method: the minimal RMS velocity
    if isAutomatic == 1
            
            for idx_freq = 1:length(IMU.C1(1).Top)

                % Select data by the minimal RMS velocity
                [newIMU(idx_freq).Data, newQTM(idx_freq).Data, minRMS(idx_freq).Data, index(idx_freq).Data, relevantDataset(idx_freq).Data] = selectDataByMinRmsVel(timeframe, fs, isOverlap, IMU, QTM, idx_freq);

            end
            
        
    % Use the second method: the minimal RMS acceleration
    elseif isAutomatic == 2
        
        for idx_freq = 1:length(IMU.C1(1).Top)

                % Select data by the minimal RMS acceleration
                [newIMU(idx_freq).Data, newQTM(idx_freq).Data, minRMS(idx_freq).Data, index(idx_freq).Data, relevantDataset(idx_freq).Data] = selectDataByMinRmsAcc(timeframe, fs, isOverlap, IMU, QTM, idx_freq);

        end
            

    % Use the third method: Manually using QTM events
    else

        % Select data by the QTM indices
        [newIMU, newQTM] = selectDataByIndices(IMU, QTM);
        minRMS = NaN;
        index.Data  = 1;
        relevantDataset.Data = NaN;

            
    end
    
end