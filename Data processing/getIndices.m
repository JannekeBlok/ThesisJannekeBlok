% Function that finds the correct indices for the different movements from
% the QTM data.
% 
% Input variables
%   QTM         Struct with field events for a given dataset.
% 
% Output variables
%   indices     Indices where movement data is found. 

function [indices] = getIndices(QTM)

    % Initialize matrices 
    startRot = []; endRot = [];
    startAP = [];  endAP = [];
    startML = [];  endML = [];
    
    % Loop over all events
    for i = 1:length(QTM.Events)
        
        % Select forward movement
        if contains(QTM.Events(i).Label,"forward",'IgnoreCase',true) && contains(QTM.Events(i).Label,"start",'IgnoreCase',true)
            
            % Append index to the correct array
            startAP(end+1) = QTM.Events(i).Frame; 
            
            
        elseif contains(QTM.Events(i).Label, "forward",'IgnoreCase',true)&& contains(QTM.Events(i).Label,"end",'IgnoreCase',true)
            
            % Append index to the correct array
            endAP(end+1)   = QTM.Events(i).Frame; 
            
            
        % Select sideways movement
        elseif contains(QTM.Events(i).Label, "sideways",'IgnoreCase',true) && contains(QTM.Events(i).Label,"start",'IgnoreCase',true)
           
            % Append index to the correct array
            startML(end+1) = QTM.Events(i).Frame; 

            
        elseif contains(QTM.Events(i).Label, "sideways",'IgnoreCase',true) && contains(QTM.Events(i).Label,"end",'IgnoreCase',true)
            
            % Append index to the correct array
            endML(end+1)   = QTM.Events(i).Frame; 
            

        % Select rotation
        elseif contains(QTM.Events(i).Label, "rotation", 'IgnoreCase', true) && contains(QTM.Events(i).Label,"start",'IgnoreCase',true)
            
            % Append index to the correct array
            startRot(end+1) = QTM.Events(i).Frame; 
            

        elseif contains(QTM.Events(i).Label, "rotation", 'IgnoreCase', true) && contains(QTM.Events(i).Label,"end",'IgnoreCase',true)
            
            % Append index to the correct array
            endRot(end+1)   = QTM.Events(i).Frame; 
            
        end
    end
    
    % Create a struct with the arrays as fields for later data selection
    indices = struct('startAP',startAP,'endAP',endAP,'startML',startML,'endML',endML,'startRot',startRot,'endRot',endRot);
end