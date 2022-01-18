% This function will determine the first derivative using a fourth order
% centered numerical approximation.
%
% Input variables
%   x       Timeseries that you need the derivative of
%   dt      Time step
%
% Output variables
%   y       Numerical approximation of the derivative


function [y] = firstDiff(x, dt)
    
    % Initialize the y-vector with NaN
    y = NaN(length(x),1);
    
    % Use a central difference formula for the interior points of y
    for i = 3:length(x)-2
        
        y(i) = (-x(i+2)+8*x(i+1)-8*x(i-1)+x(i-2))/(12*dt);

    end

    % Remove parts that are still NaN
    y = y(3:end-2);        



end