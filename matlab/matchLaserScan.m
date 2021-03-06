%% Tk = matchLaserScan(Tk,Rk,Sk,eta,nu,Odom,optn)
%
% Description:
%   Match the laser scan data to the SDF map and return transformation Tk
%
% Inputs:
%   Tk is a matrix of robot poses for the entire dataset.
%   Rk is a matrix of laser scan data for the entire dataset.(x,y)
%   Sk represent TSDF Fk and weight Wk
%   nu is a distance threshold for closest point association
% Outputs:
%   Sk represent TSDF Fk and weight Wk
% Example:
%   Tk = matchLaserScan(Tk,Rk,Sk,Odom,optn)
% Dependencies:
%   none
%
% *************************************************************************
% Modified: 01-Dec-2016
% Created: 01-Dec-2016
%
% Parker Owan, Ph.D. Student
% University of Washington
% *************************************************************************
function [Tk,iter,dJ,JStar] = matchLaserScan(Tk,Rk,Sk,nu,e,Odom,optn,k)


% get resolution
dx = Sk.resolution;

% init the laser scan points into the world frame
D = bsxfun(@plus,Tk(1:2,1:2)*Rk,Tk(1:2,3));

% define the +/- index search range
si = round(nu/dx);

% get range indices for map
[numX,numY] = size(Sk.TSDF);



%% ICP Algorithm
dJ = Inf;
JStar  = Inf;
alph = 0.10;        % cost filter parameter
dJThresh = 1e-4;    % gradient of J threshold stop
maxIter = 100;
done = 0;
iter = 1;
while(~done)
    
    printString = sprintf('k = %i | ICP: i = %03i,dJ = %+8.5f,J=,J = %+8.5f',...
        optn.k,iter,dJ,JStar);
    
	if ( optn.plot )
        sf = 0.5;
        sh=[];
        mh=[];
        figure(optn.h),cla
        plot(Odom(:,1),Odom(:,2),'.-r')
        mh = mesh(Sk.x,Sk.y,Sk.TSDF,...
            'FaceColor','flat','EdgeColor','none','FaceAlpha',1);
        plot(Tk(1,3),Tk(2,3),'ob','MarkerSize',10)
        quiver(Tk(1,3),Tk(2,3),sf*Tk(1,1),sf*Tk(2,1),'b')
        scatter3(D(1,:),D(2,:),2*ones(size(D(1,:))),10,'k','filled')
        xlim([min(min(Sk.x)) max(max(Sk.x))])
        ylim([min(min(Sk.y)) max(max(Sk.y))])
        view(2)
        text(min(min(Sk.x))+1,min(min(Sk.y))+1,...
            printString,'FontName','FixedWidth')
        patch([-6 -1 -1 -6 -6]+max(max(Sk.x)),...
            [-0.1 -0.1 0.1 0.1 -0.1]+min(min(Sk.y))+1,'k');
        text(max(max(Sk.x))-3.5,min(min(Sk.y))+1,...
            '5 m','HorizontalAlignment','center',...
            'VerticalAlignment','bottom')
    end
    
    % initialize the Nearest Neighbor
    Neighbors = [];
    Cloud = [];
    
    % ********************************************
    % 1. find nearest point in Sk
    for p = 1:length(D)       
        % find nearest grid cell to initialize local search region
        [ix,iy] = find(abs(Sk.x-D(1,p))<dx/2 & abs(Sk.y-D(2,p))<dx/2);
        if ~isempty(ix)
            
            xR = ix+(-si:si);       % specify the range indices (x)
            yR = iy+(-si:si);       % specify the range indices (y)
            
            xR = max(min(xR,numX),1);   % limit by map size
            yR = max(min(yR,numY),1);   % limit by map size
            
            % consider only a local region in which to search
            LocalX    = Sk.x(xR,yR);
            LocalY    = Sk.y(xR,yR);
            LocalTSDF = Sk.TSDF(xR,yR);
            
            % find TSDF values in local region 
            % that are below and above zero
            idBelow = find(LocalTSDF < 0);
            idAbove = find(LocalTSDF > 0);
            
            if ~isempty(idBelow) && ~isempty(idAbove)
                dBelow = sqrt((LocalX(idBelow)-D(1,p)).^2+...
                    (LocalY(idBelow)-D(2,p)).^2);
                dAbove = sqrt((LocalX(idAbove)-D(1,p)).^2+...
                    (LocalY(idAbove)-D(2,p)).^2);
                
                % grab the index of the TSDF value nearest the zero xing
                if min(dBelow) > min(dAbove)
                    id = find(dBelow == min(dBelow));
                    xN = LocalX(idBelow(id));
                    yN = LocalY(idBelow(id));
                else
                    id = find(dAbove == min(dAbove));
                    xN = LocalX(idAbove(id));
                    yN = LocalY(idAbove(id));
                end
                
                if ( optn.plot )
                    plot3([D(1,p) xN],[D(2,p) yN],[1 1],'Color',[1 .5 0])
                end
                
                % Todo: add raycasting here!
                
                Neighbors = [Neighbors, [xN; yN]];	% Push neighbors
                Cloud = [Cloud, Rk(:,p)];           % Push cloud
            end
        end
    end
    
    if ( optn.plot )
        drawnow
        if isfield(optn,'vObj')
            fra = getframe(optn.h);
            writeVideo(optn.vObj,fra);
        end
    end
    
    
    % ********************************************
    % 2. optimize for Tk*
    
    % define initial point
    x0 = [Tk(1,3);
          Tk(2,3);
          atan2(Tk(2,1),Tk(1,1))];
      
    % perform optimization
%     options = optimoptions(@fminunc,'Display','off');
      options = optimoptions('fminunc','GradObj','on'); % indicate gradient is provided 
%     [xStar,JStar] = fminunc(@(x)msePointCloud(x,Cloud,Neighbors),...
%         x0,options);  
     [xStar,JStar] = fminunc(@(x) msePointCloud(x,Cloud,Neighbors),x0,options);
%      [xStar,JStar,exitflag,output,grad,hessian]=fminunc(@(x) msePointCloud(x,Cloud,Neighbors),x0,options)
%      [JStar,gradJ] = msePointCloud(xStar,R,N);
%  xStar= fminunc(@(x) msePointCloud(x,3),[1;1],options)
    % convert back to Tk
    Tk = [cos(xStar(3)), -sin(xStar(3)), xStar(1);
          sin(xStar(3)),  cos(xStar(3)), xStar(2);
          0,              0,             1];
    
      
    % ********************************************
    % 3. recompute point cloud with new Tk
    D = bsxfun(@plus,Tk(1:2,1:2)*Rk,Tk(1:2,3));
    
    
    % Update steps for propogate
    if iter == 1
        JPrev = JStar;
    else
        J = (1-alph)*JPrev + alph*JStar;      % filter the cost
        dJ = J-JPrev;
        JPrev = J; %JPrev=JStar

        %         if (iter > maxIter) || (abs(dJ) < dJThresh && JStar < e) % add a strong constrain,
        if (iter > maxIter) ||  (dJ < dJThresh) || (JStar < e) % add a strong constrain,
            done = 1;
        end
    end
    iter = iter+1;
end
%% save the final plot
printString = sprintf('k = %i | ICP: i = %03i,dJ = %+8.5f,J=,J = %+8.5f',...
    optn.k,iter,dJ,JStar);

if ( optn.plot )
    sf = 0.5;
    sh=[];
    mh=[];
    figure(optn.h),cla
    plot(Odom(:,1),Odom(:,2),'.-r')
    mh = mesh(Sk.x,Sk.y,Sk.TSDF,...
        'FaceColor','flat','EdgeColor','none','FaceAlpha',1);
    %% save it into matrix: 
    plot(Tk(1,3),Tk(2,3),'ob','MarkerSize',10)
    quiver(Tk(1,3),Tk(2,3),sf*Tk(1,1),sf*Tk(2,1),'b')
    scatter3(D(1,:),D(2,:),2*ones(size(D(1,:))),10,'k','filled')
    xlim([min(min(Sk.x)) max(max(Sk.x))])
    ylim([min(min(Sk.y)) max(max(Sk.y))])
    view(2)
    text(min(min(Sk.x))+1,min(min(Sk.y))+1,...
        printString,'FontName','FixedWidth')
    patch([-6 -1 -1 -6 -6]+max(max(Sk.x)),...
        [-0.1 -0.1 0.1 0.1 -0.1]+min(min(Sk.y))+1,'k');
    text(max(max(Sk.x))-3.5,min(min(Sk.y))+1,...
        '5 m','HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
end
% filename=sprintf('.\\contourfigures\\frame%d.fig',k);
% savefig(optn.h,filename,'compact');
% imwrite(optn.h,filename);



