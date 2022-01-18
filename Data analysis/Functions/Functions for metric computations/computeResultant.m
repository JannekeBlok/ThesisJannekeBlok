% Function to compute the resultant of two arrays
%
% Input variables
%   varargin            Either 2 or 3 arrays of which the resultant should
%                       be found
% Output variables
%   resultant           The resultant array

function [resultant] = computeResultant(varargin)

    if nargin == 2
        
        resultant = sqrt(varargin{1}.^2+varargin{2}.^2);

    elseif nargin == 3

        resultant = sqrt(varargin{1}.^2+varargin{2}.^2+varargin{3}.^2);

    end

end