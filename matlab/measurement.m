%% [Vk,Nk,Tk,Rk] = measurement(T,R,k,sigmaS,sigmaR)
% 
% Description:
%   Compute vertices Vk, normals Nk, robot pose tranformation Tk, and point
%   cloud Rk from raw dataset R,K at samplex index k.
% 
% Inputs:
%   T is a matrix of robot poses for the entire dataset.
%   R is a matrix of laser scan data for the entire dataset.
%   k is the current sample index at which to evaluate the measurement.
%   sigmaS,sigmaR are scalar smoothing parameters for the bilateral filter.
% 
% Example:
%   [Vk,Nk,Tk,Rk] = measurement(T,R,k,sigmaS,sigmaR)
% 
% Dependencies:
%   none
% 
% *************************************************************************
% Modified: 07-Nov-2016
% Created: 07-Nov-2016
%
% Parker Owan, Ph.D. Student
% University of Washington
% *************************************************************************
function [Vk,Nk,Tk,Rk] = measurement(T,R,k,sigmaS,sigmaR)


% filter function
NormSig = @(t,s) exp(-t.^2./(s^2));

% get the laser scan measurement
Z = reshape(R(k,:),[3 length(R(k,:))/3]);

% throw away max reading measurements
% maxR = 8.18
valid = Z(1,:) < 8.18;
Range = Z(1,valid);
Bearing = Z(2,valid);
Intensity = Z(3,valid);

% turn this into a 'point cloud'
Rk = [Range.*cos(Bearing);
      Range.*sin(Bearing)];

% get the robot pose
Pose = T(k,:);
a = Pose(1);
b = Pose(2);
theta = Pose(3);

% return the robot pose homogeneous transformation
% https://en.wikipedia.org/wiki/Transformation_matrix
Tk = [cos(theta), -sin(theta), a;
      sin(theta),  cos(theta), b;
      0,             0,        1];

  
% apply the bilateral smoothing filter
q = [Range;
     Bearing];
Dk = zeros(size(Rk));
for k = 1:length(Range)
    u = q(:,k);
    Rku = Rk(:,k);
    e1 = bsxfun(@minus,u,q);
    e2 = bsxfun(@minus,Rku,Rk);
    arg1 = sqrt(sum(e1.^2,1));
    arg2 = sqrt(sum(e2.^2,1));
    arg3 = NormSig(arg1,sigmaS).*NormSig(arg2,sigmaR);
    arg4 = bsxfun(@times,arg3,Rk);
	Dk(:,k) = sum(arg4,2)./sum(arg3);
end


% vertex computation is easy - we already have it
Vk = Rk;

% compute measurement normals
Del = gradient(Vk);
Nk = [-Del(2,:); Del(1,:)];
Nk = bsxfun(@times,Nk,1./sqrt(sum(Nk.^2,1)));


return