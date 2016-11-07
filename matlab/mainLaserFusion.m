%% mainLaserFusion.m
% 
% Description:
%   run the main laser fusion with TSDF on the intel laser scan dataset
% 
% Inputs:
%   none
% 
% Example:
%   mainLaserFusion
% 
% Dependencies:
%   preprocessDataset()
%   measurement()
%   estimatePose()
%   updateReconstruction()
%   predictSurface()
%   updatePlot()
% 
% *************************************************************************
% Modified: 07-Nov-2016
% Created: 07-Nov-2016
%
% Parker Owan, Qiuyu Chen, and Tyler Yeats
% University of Washington
% CSE 571: Probabilistic robotics
% *************************************************************************

disp('Running mainLaserFusion.m...')
disp('******************************************')
set(0,'DefaultTextInterpreter','Latex',...
      'DefaultLegendInterpreter','Latex',...
      'DefaultTextFontSize',18,...
      'DefaultAxesFontSize',18,...
      'DefaultLineLineWidth',1,...
      'DefaultLineMarkerSize',7.75);
  
% *************************************************************************
% Simulation options

% set plotOptn flag to true or false
plotOptn = true;

% Bilateral filter parameters
sigmaS = 1.0;
sigmaR = 1.0;


%% Open the plot
if plotOptn
    h = figure(1);cla
end


%% Main

% preprocess the dataset
[T,R] = preprocessDataset();

% initialize a blank map
Sk = [];

% initialize previous states
Vkprev = [];
Nkprev = [];
Tkprev = [];

for k = 1:length(T)
    
    % measurement
    [Vk,Nk,Tk,Rk] = measurement(T,R,k,sigmaS,sigmaR);
    
    % TODO: we need to perform the pose estimation, reconstruction and
    % prediction steps still.  These functions have not yet been created.
    %{
    % pose estimation
    Tk = estimatePose(Vk,Nk,Vkprev,Nkprev,Tkprev);
    
    % update reconstruction
    Sk = updateReconstruction(Tk,Rk,Sk);
    
    % predict surface
    [Vkhat,Nkhat,Tk] = predictSurface(Sk,Tkprev);
    
    % hold on to previous states
    Vkprev = Vkhat;
    Nkprev = Nkhat;
    Tkprev = Tk;
    %}
    
    % update the plot
    if plotOptn
        h = updatePlot(h,Tk,Rk,Vk,Nk,Sk);
    end
    
    % don't let it run for the entire dataset - we'll change this later
    if k > 500
        break
    end
    

end








