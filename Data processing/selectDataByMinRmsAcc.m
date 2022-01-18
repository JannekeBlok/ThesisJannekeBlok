% Function that selects the relevant IMU and QTM data by the minimal
% rms of resultant acceleration, used for the automatic method. 
% 
% Input variables
%   timeframes          Total time that the user is interested in, in s.
%                       If this is an array, segments of each length in the
%                       array will be chosen. 
%   fs                  Sampling frequency, in Hz
%   isOverlap           Boolean variable to decide whether chosen segments 
%                       can overlap
%   IMU                 Struct with IMU data
%   QTM                 Struct with QTM data
%   idx_freq            Index used if a frequency sweep is desired.

function [newIMU, newQTM, minRMS, index, relevantDataset] = selectDataByMinRmsAcc(timeframes, fs, isOverlap, IMU, QTM, idx_freq)

    % Extract the number of required segments from timeframes
    noOfRequiredSegments = length(timeframes);
    

    % Extract the number of samples required per segment;
    samples = timeframes*fs;


    % Initialize index, relevant dataset and minRMS arrays
    index           = ones(noOfRequiredSegments, 2);
    relevantDataset = ones(noOfRequiredSegments, 2);
    minRMS          = ones(noOfRequiredSegments, 2);

    
    % Loop over the number of required segments
    for segment = 1:noOfRequiredSegments
        
        % Initialize the minimal RMS as a value that will definitely be
        % higher than the actual accelerations.
        minRMS(segment, 1) = 30;


        % Loop over all datasets available for condition 1
        for dataset = 1:length(IMU.C1)
           
            % Initialize boolean array with same dimension
            booleanArray = ones(length(IMU.C1(dataset).Top(idx_freq).acc_x),1);
            
            % Make sure that datasets do not overlap if isOverlap == false
            if segment ~= 1 && dataset == relevantDataset(1,1) && ~isOverlap
                
                booleanArray(index(1):index(1)+samples(1)-1) = zeros(samples(1),1);
                
            end
            
            if segment > 2 && dataset == relevantDataset(2,1) && ~isOverlap
                
                booleanArray(index(2,1):index(2,1)+samples(2)-1) = zeros(samples(2),1);
                
            end
         
            
            % Make sure that datasets can only contain useful data: use QTM
            % indices to remove data that is not useful.
            startUseless = []; endUseless = [];
            
            for event = 1:length(QTM.C1(dataset).Events)
                
                % Fill startUseless
                if     contains(QTM.C1(dataset).Events(event).Label, "useful", 'IgnoreCase', true) && contains(QTM.C1(dataset).Events(event).Label, "start",'IgnoreCase', true);
                    
                    startUseless(end+1) = QTM.C1(dataset).Events(event).Frame;
                    
                % Fill endUseless
                elseif contains(QTM.C1(dataset).Events(event).Label, "useful", 'IgnoreCase', true) && contains(QTM.C1(dataset).Events(event).Label, "end",  'IgnoreCase', true);
                    
                    endUseless(end+1) = QTM.C1(dataset).Events(event).Frame;
                    
                end
            end
            
            % Remove useless data from the boolean array
            for k = 1:length(startUseless)
                    
                booleanArray(round(startUseless(k)):round(endUseless(k))) = zeros(round(endUseless(k))-round(startUseless(k))+1,1);
                    
            end
            

            % Check to see if the array is the correct size
            if isOverlap
                assert(sum(round(endUseless-startUseless))+length(startUseless)==length(booleanArray)-sum(booleanArray),'The dimensions of the boolean array do not match the useful data.')
            end
            
            

            % Loop over all elements in the dataset
            for i = 1:length(IMU.C1(dataset).Top(idx_freq).acc_x)-samples(segment)
                
                % Only include the useful parts => exclude zero parts
                % defined by boolean array
                if all(booleanArray(i:i+samples(segment)-1))
                    
                    % Compute resultant acceleration for a single timeframe
                    accRes = sqrt(IMU.C1(dataset).Top(idx_freq).acc_x(i:(i+samples(segment)-1))+IMU.C1(dataset).Top(idx_freq).acc_z(i:(i+samples(segment)-1)));
                    
                    % Check if the new RMS is lower than the current rms
                    if rms(accRes) < minRMS(segment,1)
                        
                        % Redefine index, minimal RMS and relevant dataset
                        index(segment,  1)          = i;
                        minRMS(segment, 1)          = rms(accRes);
                        relevantDataset(segment, 1) = dataset;
                        
                    end
                    
                end
                
            end
            
            
        end


        % Small check to see if the current minimum is an actual minimum
        if index(segment,1)~=1 && (index(segment, 1)+samples(segment)) ~= length(IMU.C1(relevantDataset(segment,1)).Top(idx_freq).acc_x) && booleanArray(index(segment,1)+samples(segment))~=0
            accRes_next     = rms(sqrt(IMU.C1(relevantDataset(segment, 1)).Top(idx_freq).acc_x((index(segment,1)+1):(index(segment,1)+samples(segment)))+IMU.C1(relevantDataset(segment, 1)).Top(idx_freq).acc_z(index(segment,1)+1:(index(segment,1)+samples(segment)))));
            assert(minRMS(segment, 1) <= accRes_next,     'The RMS is not a minimum.')

        elseif index(segment,1) ~= 1
            accRes_previous = rms(sqrt(IMU.C1(relevantDataset(segment, 1)).Top(idx_freq).acc_x((index(segment,1)-1):(index(segment,1)+samples(segment)-2))+IMU.C1(relevantDataset(segment, 1)).Top(idx_freq).acc_z(index(segment,1)-1:(index(segment,1)+samples(segment)-2))));
            assert(minRMS(segment, 1) < accRes_previous, 'The RMS is not a minimum.')
        end
        
        % Save correct IMU values to struct
        newIMU.C1(segment).Top            = structfun(@(x) x(index(segment,1):index(segment,1)+samples(segment)-1), IMU.C1(relevantDataset(segment,1)).Top(idx_freq),   'UniformOutput', false);
        newIMU.C1(segment).Top.rot_GS     = IMU.C1(relevantDataset(segment, 1)).Top(idx_freq).rot_GS(:,:,index(segment,1):index(segment,1)+samples(segment)-1);
        
        newIMU.C1(segment).Bottom        = structfun(@(x) x(index(segment,1):index(segment,1)+samples(segment)-1), IMU.C1(relevantDataset(segment,1)).Bottom(idx_freq),'UniformOutput', false);
        newIMU.C1(segment).Bottom.rot_GS  = IMU.C1(relevantDataset(segment, 1)).Bottom(idx_freq).rot_GS(:,:,index(segment,1):index(segment,1)+samples(segment)-1);

        % Save correct QTM values to struct
        newQTM.C1(segment).COP            = QTM.C1(relevantDataset(segment,1)).COP(idx_freq).COP(5*index(segment,1):5*(index(segment,1)+samples(segment))-1,:).';
        
    end

    %% Now we need to do the same for C2

    % Check whether data is available for condition C2
    if any(strcmp(fieldnames(IMU),'C2'))

        % Loop over the number of required segments
        for segment = 1:noOfRequiredSegments
            
            % Define a large initial value for the minimal RMS
            minRMS(segment, 2) = 30;

            for dataset = 1:length(IMU.C2)
               
                % Initialize boolean array with same dimension
                booleanArray = ones(length(IMU.C2(dataset).Top(idx_freq).acc_x),1);
                
                % Make sure that datasets do not overlap if isOverlap == false
                if segment ~= 1 && dataset == relevantDataset(1,2) && ~isOverlap
                    
                    booleanArray(index(1,2):index(1,2)+samples(1)-1) = zeros(samples(1),1);
                    
                end
                
                if segment > 2 && dataset == relevantDataset(2,2) && ~isOverlap
                    
                    booleanArray(index(2,2):index(2,2)+samples(2)-1) = zeros(samples(2),1);
                    
                end
             
                
                % Make sure that datasets can only contain useful data
                startUseless = []; endUseless = [];
                
                for event = 1:length(QTM.C2(dataset).Events)
                    
                    % Fill startUseless
                    if     contains(QTM.C2(dataset).Events(event).Label, "useful", 'IgnoreCase', true) && contains(QTM.C2(dataset).Events(event).Label, "start",'IgnoreCase', true);
                        
                        startUseless(end+1) = QTM.C2(dataset).Events(event).Frame;
                        
                    % Fill endUseless
                    elseif contains(QTM.C2(dataset).Events(event).Label, "useful", 'IgnoreCase', true) && contains(QTM.C2(dataset).Events(event).Label, "end",  'IgnoreCase', true);
                        
                        endUseless(end+1) = QTM.C2(dataset).Events(event).Frame;
                        
                    end
                end
                
                % Remove useless data from boolean array
                for k = 1:length(startUseless)
                        
                    booleanArray(round(startUseless(k)):round(endUseless(k))) = zeros(round(endUseless(k))-round(startUseless(k))+1,1);
                        
                end
                
                % Check if the boolean array is correct
                if isOverlap
                    assert(sum(round(endUseless-startUseless))+length(startUseless)==length(booleanArray)-sum(booleanArray),'The dimensions of the boolean array do not match the useful data.')
                end
                    
                acc_x = booleanArray.*IMU.C2(dataset).Top(idx_freq).acc_x;
                acc_z = booleanArray.*IMU.C2(dataset).Top(idx_freq).acc_z;

                % Perform a check to see if the correct 
                assert(nnz(acc_x) == sum (booleanArray),'The number of nonzero elements do not match the Boolean array.')
                assert(nnz(acc_z) == sum (booleanArray),'The number of nonzero elements do not match the Boolean array.')
    
                % Loop over all elements in the dataset
                for i = 1:length(IMU.C2(dataset).Top(idx_freq).acc_x)-samples(segment)
                    
                    % Only include the useful parts => exclude zero parts
                    % defined by boolean array
                    if all(acc_x(i:i+samples(segment)-1))
                        
                        % Compute resultant acceleration for a single timeframe
                        accRes = sqrt(IMU.C2(dataset).Top(idx_freq).acc_x(i:(i+samples(segment)-1))+IMU.C2(dataset).Top(idx_freq).acc_z(i:(i+samples(segment)-1)));
                        
                        % Check if the new RMS is lower than the current rms
                        if rms(accRes) < minRMS(segment,2)
                            
                            % Redefine index, minimal RMS and relevant dataset
                            index(segment,  2)          = i;
                            minRMS(segment, 2)          = rms(accRes);
                            relevantDataset(segment, 2) = dataset;
                            
                        end
                        
                    end
                    
                end
                
                
            end

            % Check whether the current minimum is really a (local) minimum
            if (index(segment, 2)+samples(segment)) ~= length(IMU.C2(relevantDataset(segment,2)).Top(idx_freq).acc_x) && all(acc_x(index(segment,2)+1:index(segment,2)+samples(segment)))
                accRes_next     = rms(sqrt(IMU.C2(relevantDataset(segment, 2)).Top(idx_freq).acc_x((index(segment,2)+1):(index(segment,2)+samples(segment)))+IMU.C2(relevantDataset(segment, 2)).Top(idx_freq).acc_z(index(segment,2)+1:(index(segment,2)+samples(segment)))));
                assert(minRMS(segment, 2) < accRes_next,     'The RMS is not a minimum.')

            elseif index(segment,2) ~= 1
                accRes_previous = rms(sqrt(IMU.C2(relevantDataset(segment, 2)).Top(idx_freq).acc_x((index(segment,2)-1):(index(segment,2)+samples(segment)-2))+IMU.C2(relevantDataset(segment, 2)).Top(idx_freq).acc_z(index(segment,2)-1:(index(segment,2)+samples(segment)-2))));
                assert(minRMS(segment, 2) < accRes_previous, 'The RMS is not a minimum.')
            end
            
            % Save correct IMU values to struct
            newIMU.C2(segment).Top            = structfun(@(x) x(index(segment,2):index(segment,2)+samples(segment)-1), IMU.C2(relevantDataset(segment,2)).Top(idx_freq),   'UniformOutput', false);
            newIMU.C2(segment).Top.rot_GS     = IMU.C2(relevantDataset(segment, 2)).Top(idx_freq).rot_GS(:,:,index(segment,2):index(segment,2)+samples(segment)-1);
            
            newIMU.C2(segment).Bottom        = structfun(@(x) x(index(segment, 2):index(segment,2)+samples(segment)-1), IMU.C2(relevantDataset(segment,2)).Bottom(idx_freq),'UniformOutput', false);
            newIMU.C2(segment).Bottom.rot_GS  = IMU.C2(relevantDataset(segment, 2)).Bottom(idx_freq).rot_GS(:,:,index(segment,2):index(segment,2)+samples(segment)-1);
            
            if 5*(index(segment,2)+samples(segment))-1<= length(QTM.C2(relevantDataset(segment,2)).COP.FP2(idx_freq).COP)
                % Save correct QTM values to struct
                newQTM.C2(segment).COP.FP2            = QTM.C2(relevantDataset(segment,2)).COP.FP2(idx_freq).COP(5*index(segment,2):5*(index(segment,2)+samples(segment))-1,:).';
                newQTM.C2(segment).COP.FP3            = QTM.C2(relevantDataset(segment,2)).COP.FP3(idx_freq).COP(5*index(segment,2):5*(index(segment,2)+samples(segment))-1,:).';
            else
                newQTM.C2(segment).COP.FP2            = QTM.C2(relevantDataset(segment,2)).COP.FP2(idx_freq).COP(5*index(segment,2):end,:).';
                newQTM.C2(segment).COP.FP3            = QTM.C2(relevantDataset(segment,2)).COP.FP3(idx_freq).COP(5*index(segment,2):end,:).';
            end

        end

end




