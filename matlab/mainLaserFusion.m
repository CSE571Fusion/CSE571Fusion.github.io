
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
% addpath(genpath('D:\Documents\GitHub\CSE571Fusion.github.io\matlab'));
warning off
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
%% Simulation options
optn.plot = true;
optn.video = true;

% Bilateral filter parameters
sigmaS = 1.0;
sigmaR = 1.0;

% truncated distance
mu = 0.5;

% scan matching
nu = 0.3;     % [m] - distance to associate closest point
 
% perturbation parameters for Tk, set == 0 for no error
% alpha = [0, 0, 0];
alpha = [.1, .1, .2];   % [x, y, theta]

% map representation settings
xRange = [-10 10];      % [-15 45]
yRange = [-15 5];       % [-15 15]
dx = 0.05;              % 0.01;

%constrain of sum(D-N): error between predicted surface and projected point
%clouds. Strong constraint + gradient=1e-4
e=dx/sqrt(2);%0.012;

% stop index
kStop = 50;     % 26;

% *************************************************************************
%% Initialization

% preprocess the dataset
[T,R] = preprocessDataset(2,false);

% initialize the map
Sk = initializeMap(xRange,yRange,dx);

% initialize the odometry
Odom = [];
Cost = [];

% Open the plot
if ( optn.plot )
    optn.h = initializePlot();
    if ( optn.video )
        optn.vObj = initializeVideo(optn.h,Sk);
    end
end

% *************************************************************************
%% Main loop
% load saved_k=26.mat
% kStart = k+1;
% for k = kStart:kStart+20        
fileID = fopen('iterations.txt','w');
formatSpec = 'When k is %4.2f, it needs %d iterations. dJ: %8.3f, J: %8.3f\n';
for k = 1:length(T)
    
    % push k to options struct
    optn.k = k;
    
    % measurement
    [Vk,Nk,Tk,Rk] = measurement(T,R,k,sigmaS,sigmaR);
    
    % scan matching
    if k > 1
        Tk = perturbOdometry(Tk,alpha);
        [Tk,iter,dJ,J] = matchLaserScan(Tk,Rk,Sk,nu,e,Odom,optn,k);
        fprintf(fileID,formatSpec,k,iter,dJ,J);
    end
    Odom = [Odom; Tk(1:2,3)'];
    
    % compute and fuse the TSDF
    Sk = updateReconstruction(Tk,Rk,Sk,mu,Odom,optn);
    mh = mesh(Sk.x,Sk.y,Sk.TSDF,...
        'FaceColor','flat','EdgeColor','none','FaceAlpha',1);
    % don't let it run for the entire dataset - we'll change this later
    if k == kStop
        break;
    end
end
fclose(fileID);
% *************************************************************************
%% Cleanup
if optn.plot
    if optn.video
        close(optn.vObj);
    end
end

% *************************************************************************
