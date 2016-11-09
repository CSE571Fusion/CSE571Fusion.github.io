%%     Sk = updateReconstruction(Tk,Rk,Sk);
%
% Description:
%   Compute Truncated signed distance function from laser scan
%   Rk,Tk are from measurement.m
%
% Inputs:
%   Tk is a matrix of robot poses for the entire dataset.
%   Rk is a matrix of laser scan data for the entire dataset.(x,y)
% Outputs:
%   Sk represent TSDF Fk and weight Wk
% x
% y
% Fk
% Wk
% Other Variables:
%   k is the current sample index at which to evaluate the measurement.
%   t is the translation vector from transformation matrix
%   1/lembda is actually the ray distance
%   p is the point in the globle frame, which is (x,y)
% Example:
%      Sk = updateReconstruction(Tk,Rk,Sk,mu);
%
% Dependencies:
%   none
%
% *************************************************************************
% Modified: 08-Nov-2016
% Created: 08-Nov-2016
%
% Qiuyu Chen, Electrical Engineering
% University of Washington
% *************************************************************************
function Sk = updateReconstruction(Tk,Rk,Sk,mu)

% extract point in the global frame and translation vector
t=[Tk(1,3),Tk(2,3)];
p=Rk;
WRk=1;
% compute point in the sensor frame, which is Rk under laser scan
x=Rk;
% get the distance from the point p to the laser
D=sqrt(p(1,:).^2+p(2,:).^2);
% define the distance to the surface
for i=1:1:length(p)
    % normalization of the ray distance to point p
    lembda(i)=sqrt(x(1,i)^2+x(2,i)^2+1);
    N(i)=sqrt((t(1,1)-p(1,i))^2+(t(2)-p(2,i))^2);
    eta(i)=lembda(i)^-1.*N(i)-D(i);
    % define truncated signed distance function
    FRk(i)=TSDF(eta(i),mu);
    
    if (FRk(i)~=1e10)
        % find the TSDF in previous frame
        c=find(Sk(1,:)==p(1,i) & Sk(2,:)==p(2,i));
        if isempty(c)==1
            Fk=0;
            Wk=0;
        else
        Fk=Sk(3,c);
        Wk=Sk(4,c);
        end
        % define TSDF based on point-wise{p|FR(p)~=null}
        % L2 norm the fused surface results as the zero-crossings of the point-wise
        % SDF F minimising
        Fk=(Wk*Fk+WRk*FRk(i))/(Wk+WRk);
        Wk=1+Wk;
        Sk(:,i)=[p(1,i);p(2,i);Fk;Wk];
    end
end
end







