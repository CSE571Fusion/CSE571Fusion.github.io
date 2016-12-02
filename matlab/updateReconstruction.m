%% Sk = updateReconstruction(Tk,Rk,Sk,mu,dx,plotOptn,h);
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
% Parker Owan, Ph.D. Student
% University of Washington
% *************************************************************************
function Sk = updateReconstruction(Tk,Rk,Sk,mu,Odom,optn)


% get resolution
dx = Sk.resolution;

% get robot position info
tr = Tk(1:2,3);

% map the laser scan points into the world frame
point = bsxfun(@plus,Tk(1:2,1:2)*Rk,Tk(1:2,3));
    
if ( optn.plot )
    printString = sprintf('k = %02i',optn.k);
    sf = 0.5;
    sh=[];
    mh=[];
    figure(optn.h),cla
    plot(Odom(:,1),Odom(:,2),'.-r')
    mh = mesh(Sk.x,Sk.y,Sk.TSDF,...
        'FaceColor','flat','EdgeColor','none','FaceAlpha',1);
    plot(Tk(1,3),Tk(2,3),'ob','MarkerSize',10)
    quiver(Tk(1,3),Tk(2,3),sf*Tk(1,1),sf*Tk(2,1),'b')
    xlim([min(min(Sk.x)) max(max(Sk.x))])
    ylim([min(min(Sk.y)) max(max(Sk.y))])
    view(2)
    text(min(min(Sk.x))+1,min(min(Sk.y))+1,...
        printString)
    patch([-6 -1 -1 -6 -6]+max(max(Sk.x)),...
        [-0.1 -0.1 0.1 0.1 -0.1]+min(min(Sk.y))+1,'k');
    text(max(max(Sk.x))-3.5,min(min(Sk.y))+1,...
        '5 m','HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
end

plotCounter = 1;

for k = 1:length(point)
    
    % Raycast algorithm - using equation for a line ***********************
    m = (point(2,k)-tr(2))./(point(1,k)-tr(1));     % slope = dy/dx
    if abs(m) > 1
        % redefine the raycast to avoid singularity in dy/dx for dx -> 0
        m = (point(1,k)-tr(1))./(point(2,k)-tr(2));	% slope = dx/dy
        b = point(1,k) - m*point(2,k);
        yv = round(point(2,k)/dx)*dx+(-5:5)*dx;
        xv = round((m*yv+b)/dx)*dx;
    else
        b = point(2,k) - m*point(1,k);
        xv = round(point(1,k)/dx)*dx+(-5:5)*dx;
        yv = round((m*xv+b)/dx)*dx;
    end
    % *********************************************************************
    
    % Compute the TSDF
    for i = 1:length(xv)
        % compute the TSDF
        D = norm(point(:,k)-tr,2);
        N(i) = norm([xv(i);yv(i)]-tr,2);
        eta(i) = N(i)-D;
        val(i) = TSDF(eta(i),mu);
        
        % fuse TSDF into Sk
        WRk = exp(-0.5*5*D);
        [ix,iy] = find(abs(Sk.x-xv(i))<dx/3 & abs(Sk.y-yv(i))<dx/3);
        if ~isnan(Sk.TSDF(ix,iy))
            nn = Sk.Weights(ix,iy)+WRk;
            Sk.TSDF(ix,iy) = (Sk.TSDF(ix,iy)*Sk.Weights(ix,iy)+...
                WRk*val(i))./nn;
            Sk.Weights(ix,iy) = nn;
        else
            Sk.TSDF(ix,iy) = val(i);
            Sk.Weights(ix,iy) = WRk;
        end
    end
    
    nSkips = 30;
%     if optn.plot && ((plotCounter-1)/nSkips==round((plotCounter-1)/nSkips))
%         % Draw raycast
%         plot([tr(1) point(1,k)],[tr(2) point(2,k)],...
%             '-','Color',[.5 .5 .5],'MarkerSize',10);
%         delete(sh);
%         sh=scatter(point(1,1:k),point(2,1:k),8,'k','filled');
%         delete(mh);
%         mh=mesh(Sk.x+dx/2,Sk.y+dx/2,Sk.TSDF,...
%             'FaceColor','flat',...
%             'EdgeColor','none','FaceAlpha',1);
%         drawnow
%         if isfield(optn,'vObj')
%             fra = getframe(optn.h);
%             writeVideo(optn.vObj,fra);
%         end
%     end
    plotCounter = plotCounter+1;
end





