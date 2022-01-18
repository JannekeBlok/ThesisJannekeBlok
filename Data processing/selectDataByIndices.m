% Function that selects the relevant IMU and QTM data by indices, used for
% the manual method. 

% Input variables       
%   IMU         Struct with IMU data, including fields Top and
%                       Bottom
%   QTM         Structs with QTM data

function [newIMU, newQTM] = selectDataByIndices(IMU, QTM)
    
    % Initialize counter to choose the correct struct fields
    counter = 1;
    
    QTM.NoOfSegmentsC1 = 0;
    QTM.NoOfSegmentsC2 = 0;
    
    for i = 1:length(IMU.C1)        % Loop over all C1 datasets
        
        % Find the C1 quiet sitting indices based on the events in QTM
        indices = getQuietSittingIndices(QTM.C1(i));
        QTM(1).NoOfSegmentsC1 = QTM(1).NoOfSegmentsC1 + length(indices.startQS);

        for index = 1:length(indices.startQS)   % Loop over all indices
            
            % Save the correct segments of IMU data
            newIMU.C1(counter).Top             = structfun(@(x) (x(indices.startQS(index):indices.endQS(index))), IMU.C1(i).Top,'UniformOutput',false);
            newIMU.C1(counter).Top.rot_GS      = IMU.C1(i).Top.rot_GS(:,:,indices.startQS(index):indices.endQS(index));
            newIMU.C1(counter).Bottom          = structfun(@(x) (x(indices.startQS(index):indices.endQS(index))), IMU.C1(i).Bottom,'UniformOutput',false);
            newIMU.C1(counter).Bottom.rot_GS   = IMU.C1(i).Bottom.rot_GS(:,:,indices.startQS(index):indices.endQS(index));
            
            % Save the correct segments of COP data for the relevant force plate 
            newQTM.C1(counter).COP = QTM.C1(i).COP(1).COP(5*indices.startQS(index):5*(indices.startQS(index)+length(newIMU.C1(counter).Top.acc_x))-1,:).';

            % Progress the counter
            counter = counter + 1;
        end
        
    end
    
    
    % Re-initialize the counter for the C2 condition
    counter = 1;
    
    if strcmp(fieldnames(IMU),'C2')
        for i = 1:length(IMU.C2)        % Loop over all C2 datasets
            
            % Find the C1 quiet sitting indices based on the events in QTM
            indices = getQuietSittingIndices(QTM.C2(i));
            QTM(1).NoOfSegmentsC2 = QTM(1).NoOfSegmentsC2 + length(indices.startQS);
    
            for index = 1:length(indices.startQS)   % Loop over all indices
                
                % Save the correct segments of IMU data
                newIMU.C2(counter).Top             = structfun(@(x) (x(indices.startQS(index):indices.endQS(index))), IMU.C2(i).Top,'UniformOutput',false);
                newIMU.C2(counter).Top.rot_GS      = IMU.C2(i).Top.rot_GS(:,:,indices.startQS(index):indices.endQS(index));
                newIMU.C2(counter).Bottom          = structfun(@(x) (x(indices.startQS(index):indices.endQS(index))), IMU.C2(i).Bottom,'UniformOutput',false);
                newIMU.C2(counter).Bottom.rot_GS   = IMU.C2(i).Bottom.rot_GS(:,:,indices.startQS(index):indices.endQS(index));
                
                % Save the correct segments of COP data for the relevant force plate 
                newQTM.C2(counter).COP = QTM.C2(i).COP(1).COP(5*indices.startQS(index):5*(indices.startQS(index)+length(newIMU.C2(counter).Top.acc_x))-1,:).';
    
                % Progress the counter
                counter = counter + 1;
            end
            
        end
    
    end
end