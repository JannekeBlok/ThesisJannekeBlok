% Function that selects all movement data based on the correct indices in
% QTM
%
% Input variables
%   QSisAutomatic           Boolean variable that defines whether the quiet 
%                           sitting data is selected automatically
%   fs                      Sampling frequency
%   timeframe               Timeframe to be selected
%   QS_index                The index of the quiet sitting segment selected
%                           if the automatic method is used for this.
%   relevantDataset         The dataset from which QS data is acquired
%   IMU                     struct with IMU data
%   QTM                     struct with QTM data
%
% Output variables  
%   AP                      struct with data for AP bending
%   ML                      struct with data for ML bending
%   ROT                     struct with data for trunk rotation

function [AP, ML, ROT] = selectMovementData(QSisAutomatic, fs, timeframe, QS_index, relevantDataset, IMU, QTM)
   
    
    samples = timeframe*fs;
    AP.TotalLength = 0; ML.TotalLength = 0; ROT.TotalLength = 0;
    
    APcounter = 1; MLcounter = 1; ROTcounter = 1;
    
    % Loop over all datasets
    for dataset = 1:length(QTM.C1)
        
        % Retrieve the relevant indices from the QTM dataset
        indices = getIndices(QTM.C1(dataset));

        % Make sure that automatically selected QS data is removed
        if QSisAutomatic && length(timeframe) == 1 && QS_index(1) ~= 1 && dataset == relevantDataset(1)
            
            % Generate a booleanArray consisting of zeros
            booleanArray = zeros(length(IMU.C1(dataset).Top(1).acc_x),1);

            % Set the values that were deemed quiet sitting equal to 1
            booleanArray(QS_index(1):QS_index(1)+timeframe*fs-1) = ones(timeframe*fs,1);
            
            k = 0;
            
            % Start with forward (AP) bending
            for AP_index = 1:length(indices.startAP)
                
                k = k + 1;
                
                % Find if any of the relevant indices is contained in the
                % section of the boolean array that corresponds with QS
                if any(booleanArray(indices.startAP(k):indices.endAP(k)))
                    
                    % Change the final AP index to the start of quiet
                    % sitting if only this index is contained in the QS
                    % part
                    if indices.startAP(k) < QS_index(1) && indices.endAP(k) < QS_index(1)+timeframe*fs

                        indices.endAP(k) = QS_index(1);

                    % Change the starting AP index if only this index is
                    % contained in the QS part
                    elseif indices.startAP(k) > QS_index(1) && indices.endAP(k) > QS_index(1)+timeframe*fs
                        
                        indices.startAP(k) = QS_index(1)+timeframe*fs;

                        
                    % Remove both indices if the entire part is contained
                    % in the QS section
                    elseif indices.startAP(k) > QS_index(1) && indices.endAP(k) < QS_index(1)+timeframe*fs
                        
                        indices.startAP(k) = [];
                        indices.endAP(k)   = [];
                        
                        k = k-1;

                        
                    % Split the AP section in two parts if the QS section
                    % lies fully within this section.
                    else 

                        indices.startAP(end+1)    = QS_index(1)+samples(1);
                        indices.endAP(end+1)      = indices.endAP(k);
                        indices.endAP(k)          = QS_index(1);
                        
                    end
 
                end

            end

            
            % Now do the same for ML
            for ML_index = 1:length(indices.startML)


                % Find if any of the relevant indices is contained in the
                % section of the boolean array that corresponds with QS
                if any(booleanArray(indices.startML(ML_index):indices.endML(ML_index)))
                    
                    % Change the final ML index to the start of quiet
                    % sitting if only this index is contained in the QS
                    % part
                    if indices.startML(ML_index) < QS_index(1) && indices.endML(ML_index) < QS_index(1)+timeframe*fs

                        indices.endML(ML_index) = QS_index(1);


                    % Change the starting ML index if only this index is
                    % contained in the QS part
                    elseif indices.startML(ML_index) > QS_index(1) && indices.endML(ML_index) > QS_index(1)+timeframe*fs
                        
                        indices.startML(ML_index) = QS_index(1)+timeframe*fs;


                    % Remove both indices if the entire part is contained
                    % in the QS section    
                    elseif indices.startML(ML_index) > QS_index(1) && indices.endML(ML_index) < QS_index(1)+timeframe*fs
                        
                        indices.startML(ML_index) = [];
                        indices.endML(ML_index)   = [];

                    % Split the ML section in two parts if the QS section
                    % lies fully within this section.    
                    else 

                        indices.startML(end+1)    = QS_index(1)+samples(1);
                        indices.endML(end+1)      = indices.endML(ML_index);
                        indices.endML(ML_index)   = QS_index(1);
                        
                    end
 
                end

            end

            % And do the same for rotation
            for Rot_index = 1:length(indices.startRot)

                % Find if any of the relevant indices is contained in the
                % section of the boolean array that corresponds with QS
                if any(booleanArray(indices.startRot(Rot_index):indices.endRot(Rot_index)))
                    
                    % Change the final ROT index to the start of quiet
                    % sitting if only this index is contained in the QS
                    % part
                    if indices.startRot(Rot_index) < QS_index(1) && indices.endRot(Rot_index) < QS_index(1)+timeframe*fs

                        indices.endRot(Rot_index) = QS_index(1);


                    % Change the starting ROT index if only this index is
                    % contained in the QS part
                    elseif indices.startRot(Rot_index) > QS_index(1) && indices.endRot(Rot_index) > QS_index(1)+timeframe*fs
                        
                        indices.startRot(Rot_index) = QS_index(1)+timeframe*fs;


                    % Remove both indices if the entire part is contained
                    % in the QS section  
                    elseif indices.startRot(Rot_index) > QS_index(1) && indices.endRot(Rot_index) < QS_index(1)+timeframe*fs
                        
                        indices.startRot(Rot_index) = [];
                        indices.endRot(Rot_index)   = [];


                    % Split the ROT section in two parts if the QS section
                    % lies fully within this section.  
                    else 

                        indices.startRot(end+1)    = QS_index(1)+samples(1);
                        indices.endRot(end+1)      = indices.endRot(Rot_index);
                        indices.endRot(Rot_index)   = QS_index(1);
                        
                    end
 
                end

            end

        end
        
        % Loop over all indices to select the correct parts
        for index = 1:length(indices.startAP)

            % Start with the IMU data
            AP.IMU.C1(APcounter).Top            = structfun(@(x) (x(indices.startAP(index):indices.endAP(index))), IMU.C1(dataset).Top(1),'UniformOutput',false);
            AP.IMU.C1(APcounter).Top.rot_GS     = IMU.C1(dataset).Top(1).rot_GS(:,:,indices.startAP(index):indices.endAP(index));
            AP.IMU.C1(APcounter).Bottom         = structfun(@(x) (x(indices.startAP(index):indices.endAP(index))), IMU.C1(dataset).Bottom(1),'UniformOutput',false);
            AP.IMU.C1(APcounter).Bottom.rot_GS  = IMU.C1(dataset).Bottom(1).rot_GS(:,:,indices.startAP(index):indices.endAP(index));
            
            % Then continue with the QTM data
            AP.QTM.C1(APcounter).COP            = QTM.C1(dataset).COP(1).COP(5*indices.startAP(index):5*(indices.startAP(index)+length(AP.IMU.C1(APcounter).Top.acc_x))-1,:).';

            % Check whether the COP and IMU have the correct length
            assert(length(AP.QTM.C1(APcounter).COP) == 5*length(AP.IMU.C1(APcounter).Top.acc_x), 'IMU or QTM dataset does not have the correct length.')

            % Set correct length for AP movement
            AP.TotalLength = AP.TotalLength + length(AP.IMU.C1(APcounter).Top.acc_x);
            APcounter = APcounter + 1;

        end
            
        AP.NoOfSegmentsC1 = APcounter-1;

        
        for index = 1:length(indices.startML)
            
            % Start with the IMU indices
            ML.IMU.C1(MLcounter).Top            = structfun(@(x) (x(indices.startML(index):indices.endML(index))), IMU.C1(dataset).Top(1),'UniformOutput',false);
            ML.IMU.C1(MLcounter).Top.rot_GS     = IMU.C1(dataset).Top(1).rot_GS(:,:,indices.startML(index):indices.endML(index));
            ML.IMU.C1(MLcounter).Bottom         = structfun(@(x) (x(indices.startML(index):indices.endML(index))), IMU.C1(dataset).Bottom(1),'UniformOutput',false);
            ML.IMU.C1(MLcounter).Bottom.rot_GS  = IMU.C1(dataset).Bottom(1).rot_GS(:,:,indices.startML(index):indices.endML(index));
            
            % Then continue with the QTM data
            ML.QTM.C1(MLcounter).COP            = QTM.C1(dataset).COP(1).COP(5*indices.startML(index):5*(indices.startML(index)+length(ML.IMU.C1(MLcounter).Top.acc_x))-1,:).';

            % Check whether the COP and IMU have the correct length
            assert(length(ML.QTM.C1(MLcounter).COP) == 5*length(ML.IMU.C1(MLcounter).Top.acc_x), 'IMU or QTM dataset does not have the correct length.')


            ML.TotalLength = ML.TotalLength + length(ML.IMU.C1(MLcounter).Top.acc_x);
            
            MLcounter = MLcounter + 1;
            
        end

        ML.NoOfSegmentsC1 = MLcounter-1;

        
        for index = 1:length(indices.startRot)
            
            % Start with IMU data
            ROT.IMU.C1(ROTcounter).Top            = structfun(@(x) (x(indices.startRot(index):indices.endRot(index))), IMU.C1(dataset).Top(1),'UniformOutput',false);
            ROT.IMU.C1(ROTcounter).Top.rot_GS     = IMU.C1(dataset).Top(1).rot_GS(:,:,indices.startRot(index):indices.endRot(index));
            ROT.IMU.C1(ROTcounter).Bottom         = structfun(@(x) (x(indices.startRot(index):indices.endRot(index))), IMU.C1(dataset).Bottom(1),'UniformOutput',false);
            ROT.IMU.C1(ROTcounter).Bottom.rot_GS  = IMU.C1(dataset).Bottom(1).rot_GS(:,:,indices.startRot(index):indices.endRot(index));
            
            % Then continue with the QTM data
            ROT.QTM.C1(ROTcounter).COP            = QTM.C1(dataset).COP(1).COP(5*indices.startRot(index):5*(indices.startRot(index)+length(ROT.IMU.C1(ROTcounter).Top.acc_x))-1,:).';

            % Check whether the COP and IMU have the correct length
            assert(length(ROT.QTM.C1(ROTcounter).COP) == 5*length(ROT.IMU.C1(ROTcounter).Top.acc_x), 'IMU or QTM dataset does not have the correct length.')


            ROT.TotalLength = ROT.TotalLength + length(ROT.IMU.C1(ROTcounter).Top.acc_x);
            
            ROTcounter = ROTcounter + 1;
            
        end

        ROT.NoOfSegmentsC1 = ROTcounter-1;

        
    end
    
    
    APcounter = 1; MLcounter = 1; ROTcounter = 1;
    
    
    
end