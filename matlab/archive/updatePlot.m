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

% process the map Sk
x  = [min(Sk(1,:)) max(Sk(1,:))];
y  = [min(Sk(2,:)) max(Sk(2,:))];
nr = sum(Sk(1,:) == max(Sk(1,:)));      % number of rows
nc = length(Sk(1,:))/nr;                % number of cols

Z = reshape(Sk(3,:),[nr nc]);
C = 0.5.*(Z+1);

Rkprime = bsxfun(@plus,Tk(1:2,1:2)*Rk,Tk(1:2,3));
Vkprime = bsxfun(@plus,Tk(1:2,1:2)*Vk,Tk(1:2,3));

sf = 0.5;

figure(h),cla
box on; hold on; grid on;
imagesc(x,y,C,'AlphaData',0.5)
scatter(Rkprime(1,:),Rkprime(2,:),2,'k','filled')
scatter(Vkprime(1,:),Vkprime(2,:),6,'r','filled')
plot(Tk(1,3),Tk(2,3),'ob','MarkerSize',12)
quiver(Tk(1,3),Tk(2,3),sf*Tk(1,1),sf*Tk(2,1),'b')
hold off;
xlim(Tk(1,3)+[-5 5])
ylim(Tk(2,3)+[-5 5])
% xlim(x)
% ylim(y)
drawnow





return


