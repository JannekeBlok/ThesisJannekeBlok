% Function that loads and filters IMU data
%
% Input variables:
%   filename            Filename of the txt file with IMU data
%   cutOffLowPass       Cut-off frequency of the applied second-order
%                       Butterworth low-pass filter. If this input is an
%                       array, the function will loop over the cut-off
%                       frequencies specified in the array.
% 
% Output variables:
%   IMU                 Struct with filtered IMU data


function [IMU] = loadAndFilter(filename, fs, cutOffLowPass)

    % Specify numerical accuracy value
    eps = 1e-3;

    % Read the txt file as a table
    table = readtable(filename);

    % Generate filter variables 
    fn = fs/2;      % Nyquist frequency (in Hz)
    n  = 2;         % Filter order

    % Initialize gravity vector
    gravity = [0;0;-9.81];

    % Loop over the length of the input cutOffLowPass. 
    for idx_freq = 1:length(cutOffLowPass)
        
        % Define current normalised cut-off frequency
        wn = cutOffLowPass(idx_freq)/fn;

        % Generate n-th order low-pass Butterworth filter with the cut-off
        % corresponding with the current loop index. 
        [B, A] = butter(n, wn);
        
        % Filter the angular velocities
        vel_x  = filter(B, A, table.('Gyr_X'));
        vel_y  = filter(B, A, table.('Gyr_Y'));
        vel_z  = filter(B, A, table.('Gyr_Z'));

        % Select Euler angles
        pitch = table.('Pitch');
        roll  = table.('Roll');
        yaw   = table.('Yaw');

        % Initialize rotation matrix and empty gravity vector
        rot_GS = NaN(3,3,height(table));        % 3x3xtotal number of 
                                                % samples rotation matrix
        gravityVec = NaN(3,height(table));      % 3xtotal number of samples
                                                % gravity vector
        
        % Loop over total number of indices
        for idx = 1:height(table)
            
            % Define rotation matrix by values in table.
            rot_GS(:,:,idx)   = [table.('Mat_1__1_')(idx) table.('Mat_1__2_')(idx) table.('Mat_1__3_')(idx);
                                 table.('Mat_2__1_')(idx) table.('Mat_2__2_')(idx) table.('Mat_2__3_')(idx);
                                 table.('Mat_3__1_')(idx) table.('Mat_3__2_')(idx) table.('Mat_3__3_')(idx)];
            
            % Test if the given rotation matrix has determinant 1
            assert(det(rot_GS(:,:,idx))>1-eps && det(rot_GS(:,:,idx))<1+eps,'Determinant of rotation matrix not equal to 1.')
            
            % Rotate gravity vector to sensor frame
            gravityVec(:,idx) = rot_GS(:,:,idx).'*gravity;
            
            % Test if the resultant gravity vector remains equal to 9.81
            assert(norm(gravityVec(:,idx))>9.81-eps && norm(gravityVec(:,idx))<9.81+eps,'Gravity vector no longer equal to 9.81.')

        end
        
        % Add the gravity vector to the acceleration data and low-pass
        % filter afterwards
        acc_x = filter(B,A,table.('Acc_X') + gravityVec(1,:).');
        acc_y = filter(B,A,table.('Acc_Y') + gravityVec(2,:).');
        acc_z = filter(B,A,table.('Acc_Z') + gravityVec(3,:).');

        
        IMU(idx_freq) = struct('acc_x',   acc_x,   'acc_y',   acc_y,   'acc_z',   acc_z,                       ...
                               'vel_x',   vel_x,   'vel_y',   vel_y,   'vel_z',   vel_z,                       ...
                               'pitch',   pitch,   'roll',    roll,    'yaw',     yaw,                         ...
                               'rot_GS',  rot_GS);

    end

end