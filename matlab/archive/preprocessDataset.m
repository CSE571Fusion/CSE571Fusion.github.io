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
%   identifier = 1;     % intel-01-sorted.mat
%                2;     % 
% 
% Example:
%   [T,R] = preprocessDataset(identifier)
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
function [T,R] = preprocessDataset(identifier)


switch identifier
    
    case 1
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
        
    case 2
        load csail.corrected.mat
        T = Tk.data;
        R = Rk.data;
        
        Rp = R(:,1:3:end);
        Rp(Rp > 81) = nan;
        
        figure(100),clf
        subplot(211)
        hold on; grid on;
        imagesc(Rp')
        colormap(gca,hot)
        axis tight
        ylabel('Range Index')
        
        subplot(212)
        hold on; grid on;
        plot(T)
        axis tight
        xlabel('$k$')
        ylabel('Robot Odometry')
end


%}

return







