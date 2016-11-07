%% [T,R] = preprocessDataset()
% 
% Description:
%   preprocessor for the dataset.  Imports the 'intel-01-sorted.mat'
%   datafile generated from parseDataset(), and time aligns by nearest
%   neighbor odometry sample.  The output T is a [N x 6] matrix of sampled
%   robot odometry with columns (x, y, theta, xdot, ydot, thetadot) and
%   output R is a [N x 543] matrix of laser scan data with repeating
%   columns (range, bearing, intensity,...).
% 
% Inputs:
%   none
% 
% Example:
%   [T,R] = preprocessDataset()
% 
% Dependencies:
%   intel-01-sorted.mat exists in the current directory
%
% 
% *************************************************************************
% Modified: 07-Nov-2016
% Created: 07-Nov-2016
%
% Parker Owan, Ph.D. Student
% University of Washington
% *************************************************************************
function [T,R] = preprocessDataset()


load intel-01-sorted.mat

idx = [];
c = 1;

for k = 1:length(Rk.time)
    
    while Rk.time(k)-Tk.time(c) > 0
        c = c+1;
    end
    
    idx = [idx; c];
    
end

% grab only the nearest time for robot odometry Tk
T = Tk.data(idx,:);
R = Rk.data;

return







