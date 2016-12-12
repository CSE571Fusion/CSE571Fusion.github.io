%% Sk = initializeMap(x,y,dx)
%
% Description:
%   Initialize the map in Sk to take the range x = [xmin xmax], and 
%   y = [ymin ymax] for a spacing specified by dx.
%
% Inputs:
%   none
%
% Example:
%   
%   Sk = initializeMap([0 2],[0 4],0.01);
%
% Dependencies:
%
% *************************************************************************
% Modified: 22-Nov-2016
% Created: 22-Nov-2016
%
% Parker Owan, Ph.D. Student
% University of Washington
% *************************************************************************
function Sk = initializeMap(x,y,dx)

if nargin < 3
    error('Not enough input arguments, see help initializeMap')
end

xv = x(1):dx:x(2);
yv = y(1):dx:y(2);

[xm,ym] = meshgrid(xv,yv);

Sk.grid = [xm(:)';
           ym(:)';
           zeros(size(xm(:)'));      % SDF
           ones(size(xm(:)'))];      % weight

return