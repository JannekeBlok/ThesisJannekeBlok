% Function to filter COP data with a low-pass filter. 
% 
% Input variables
%   COP             Struct with COP data
%   fs              Sampling frequency of the COP data (in Hz)
%   cutOffLowPass   Cut-off frequency low-pass filter (in Hz). If this is
%                   an array, the function will loop over the specified
%                   cut-off frequencies.
% 
% Output variables
%   QTM             Struct with filtered COP data

function [QTM] = filterQTM(COP, fs, cutOffLowPass)

    % Filter parameters
    fn = fs/2;      % Nyquist frequency (in Hz) 
    n  = 2;         % Filter order

    % Loop 
    for idx_freq = 1:length(cutOffLowPass)

        % Define current normalised cut-off frequency
        wn = cutOffLowPass(idx_freq)/fn;

        % Generate n-th order low-pass Butterworth filter
        [B, A] = butter(n, wn);

        % Filter COP data
        COP_filtered = filter(B, A, COP, [], 2);
        
        % Save the COP data to a struct
        QTM(idx_freq).COP = COP_filtered.';


    end

end