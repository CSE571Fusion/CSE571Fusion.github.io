%% h = updatePlot(h,Tk,Rk,Vk,Nk,Sk)
%
% Description:
%
%
% Inputs:
%
%
% Example:
%
%
% Dependencies:
%
%
% *************************************************************************
% Modified: 07-Nov-2016
% Created: 07-Nov-2016
%
% Parker Owan, Ph.D. Student
% University of Washington
% *************************************************************************
function h = updatePlot(h,Tk,Rk,Sk,Odom,k)

% get resolution
dx = Sk.resolution;

Rkprime = bsxfun(@plus,Tk(1:2,1:2)*Rk,Tk(1:2,3));
sf = 0.5;

figure(h),cla
% box on; hold on; axes off;% grid on;
% axis equal
plot(Odom(:,1),Odom(:,2),'.-r')
mesh(Sk.x-dx/2,Sk.y-dx/2,Sk.TSDF,'FaceColor','flat',...
    'EdgeColor','none','FaceAlpha',1)
scatter(Rkprime(1,:),Rkprime(2,:),20,'k','filled')
plot(Tk(1,3),Tk(2,3),'ob','MarkerSize',10)
quiver(Tk(1,3),Tk(2,3),sf*Tk(1,1),sf*Tk(2,1),'b')
xlim([min(min(Sk.x)) max(max(Sk.x))])
ylim([min(min(Sk.y)) max(max(Sk.y))])
view(2)
text(-19,-9,sprintf('k = %02i',k))
patch([-15 -10 -10 -15 -15],[-9.1 -9.1 -8.9 -8.9 -9.1],'k');
text(-12.5,-8.9,'5 m','HorizontalAlignment','center',...
    'VerticalAlignment','bottom')
drawnow




return


