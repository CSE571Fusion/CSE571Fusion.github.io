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
% set(0,'DefaultTextInterpreter','Latex',...
%       'defaultLegendInterpreter','Latex',...
%       'DefaultTextFontSize',18,...
%       'DefaultAxesFontSize',18,...
%       'DefaultLineLineWidth',1,...
%       'DefaultLineMarkerSize',7.75);

% *************************************************************************
% Simulation options

% set plotOptn flag to true or false
plotOptn = true;
makeVideo = true;

% Bilateral filter parameters
sigmaS = 1.0;
sigmaR = 1.0;
% truncated distance
mu=1.5;

%% Open the plot
if plotOptn
    h = figure(1);cla
    colormap(h,flipud(gray))
    
    if makeVideo
        name = 'intel-01-sorted_medRare';
        vObj = VideoWriter(name,'MPEG-4');
        vObj.FrameRate = 30;
        vObj.Quality = 95;
        open(vObj);
        
        set(h,'position',[1 5 1280 720])
        name = strrep(name,'_','\_');
        title(name)
    end
    
end


%% Main

% preprocess the dataset
[T,R] = preprocessDataset();

% initialize the map
dx = 0.1;
% Sk = initializeMap([-25 5],[-15 20],0.5);
Sk = initializeMap([-15 5],[-10 10],dx);

% initialize previous states
Vkprev = [];
Nkprev = [];
Tkprev = [];

for k = 1:length(T)
    
    % measurement
    [Vk,Nk,Tk,Rk] = measurement(T,R,k,sigmaS,sigmaR);

    % TODO: we need to perform the pose estimation, reconstruction and
    % prediction steps still.  These functions have not yet been created.
    % update reconstruction
    Sk = updateReconstruction(Tk,Rk,Sk,mu,dx);
    %{
    % pose estimation
    Tk = estimatePose(Vk,Nk,Vkprev,Nkprev,Tkprev);
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
        if makeVideo
            fra = getframe(h);
            writeVideo(vObj,fra);
        end
    end
    
    % don't let it run for the entire dataset - we'll change this later
    if k > 400
        break
    end
    
    
end

% close videowriter
if plotOptn
    if makeVideo
        close(vObj);
    end
end








