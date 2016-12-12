%%     Sk = updateReconstruction(Tk,Rk,Sk,mu,dx,plotOptn,h);
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
function Sk = updateReconstruction(Tk,Rk,Sk,mu,dx,plotOptn,h)

% extract point in the global frame and translation vector
t=[Tk(1,3),Tk(2,3)];

% map point cloud to global
p = Tk*[Rk; ones(1,length(Rk))];

% take inverse once
Tkinv = inv(Tk);
WRk=1;


% figure(1),clf;scatter(p(1,:),p(2,:))
% hold on;
% scatter(Sk(1,:)-0.5,Sk(2,:)-0.5,'+')


% compute point in the sensor frame, which is Rk under laser scan
for i=1:1:length(p)
    
    p(1:2,i) = round(p(1:2,i)/dx)*dx;
    x = Tkinv*p(:,i);
    
    % normalization of the ray distance to point p
    lembda(i)=norm(x(1:2),2);
    N(i)=norm(t'-p(1:2,i),2);
    D(i)=norm(Rk(:,i),2);
    eta(i)=N(i)./lembda(i)-D(i);

    % define truncated signed distance function
    FRk(i)=TSDF(eta(i),mu);
    
    if (FRk(i)~=1e10)
        % find the TSDF in previous frame
        e = bsxfun(@minus,Sk(1:2,:),p(1:2,i));
        c = find(sum(abs(e),1) < dx/3);
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
        Sk(3:4,c) = [Fk;Wk];
    end
end
end







