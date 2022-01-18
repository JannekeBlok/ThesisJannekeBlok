% Function that selects the correct quiet sitting indices
%
% Input variables:
%   qtmStruct       struct with QTM data
%
% Output variables:
%   indices         Relevant quiet sitting indices

function [indices] = getQuietSittingIndices(qtmStruct)
    
    startQS = []; endQS = [];
    
    % Loop over the events and find the correct indices
        for i = 1:length(qtmStruct.Events)

            if contains(qtmStruct.Events(i).Label,"quiet",'IgnoreCase',true)       && contains(qtmStruct.Events(i).Label,"start",'IgnoreCase',true)
                startQS(end+1) = qtmStruct.Events(i).Frame; 
            
            elseif contains(qtmStruct.Events(i).Label,"quiet",'IgnoreCase',true)   && contains(qtmStruct.Events(i).Label,"end",'IgnoreCase',true)
                endQS(end+1)   = qtmStruct.Events(i).Frame; 
            end
        end
  
    % Save the arrays to a struct
    indices = struct('startQS',startQS,'endQS',endQS);
end