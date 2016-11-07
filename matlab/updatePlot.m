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
function h = updatePlot(h,Tk,Rk,Vk,Nk,Sk)



Rkprime = bsxfun(@plus,Tk(1:2,1:2)*Rk,Tk(1:2,3));
Vkprime = bsxfun(@plus,Tk(1:2,1:2)*Vk,Tk(1:2,3));

sf = 0.5;

figure(h),cla;
box on; hold on;
if ~isempty(Sk)
    scatter(Sk(:,1),Sk(:,2),2,[.4 .4 .4],'filled')
end
% scatter(Rkprime(1,:),Rkprime(2,:),6,'k','filled')
scatter(Vkprime(1,:),Vkprime(2,:),8,'r','filled')
plot(Tk(1,3),Tk(2,3),'ob','MarkerSize',12)
quiver(Tk(1,3),Tk(2,3),sf*Tk(1,1),sf*Tk(2,1),'b')
hold off;
ylim([-15 20])
xlim([-25 5])
drawnow





return


