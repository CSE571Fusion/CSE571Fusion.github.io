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
clear all; clc
disp('Running mainLaserFusion.m...')
disp('******************************************')
set(0,'DefaultTextInterpreter','Latex',...
      'defaultLegendInterpreter','Latex',...
      'DefaultTextFontSize',18,...
      'DefaultAxesFontSize',18,...
      'DefaultLineLineWidth',1,...
      'DefaultLineMarkerSize',7.75);

% *************************************************************************
% Simulation options
optn.plot = true;
optn.video = false;

% Bilateral filter parameters
sigmaS = 1.0;
sigmaR = 1.0;

% truncated distance
mu = 0.5;


% *************************************************************************
% Initialization

% preprocess the dataset
[T,R] = preprocessDataset(2,false);

% initialize the map
Sk = initializeMap([-15 45],[-15 15],0.05);
Odom = [];

% Open the plot
if ( optn.plot )
    optn.h = initializePlot();
    if ( optn.video )
        optn.vObj = initializeVideo(optn.h,Sk);
    end
end

% *************************************************************************
% Main loop
for k = 1:length(T)
    
    % push k to options struct
    optn.k = k;
    
    % measurement
    [Vk,Nk,Tk,Rk] = measurement(T,R,k,sigmaS,sigmaR);
    Odom = [Odom; Tk(1:2,3)'];
    
    % compute the TSDF
    Sk = updateReconstruction(Tk,Rk,Sk,mu,Odom,optn);
    
    % don't let it run for the entire dataset - we'll change this later
    if k == 100
        break;
    end
end

% *************************************************************************
% Cleanup
if optn.plot
    if plot.video
        close(optn.vObj);
    end
end








