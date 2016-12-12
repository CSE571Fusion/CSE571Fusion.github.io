function [J,gradJ] = msePointCloud(x,R,N)

    % x : parameters [xr, yr, thetar]
    % R : depth cloud [a; b]
    % N : nearest neighbors [xn; yn]
    
    % map the laser scan points into the world frame
    Rot = [cos(x(3)), -sin(x(3));
           sin(x(3)),  cos(x(3))];
    Trans = [x(1); x(2)];
    D = bsxfun(@plus,Rot*R,Trans);

    % compute the distance
    error = D-N;
    distance = sqrt(sum(error.^2));
    J = sum(distance)/length(distance);

    g_theta=[R(1,:)'-R(2,:)',-(R(1,:)'+R(2,:)')]*[cos(x(3));sin(x(3))];
    gradJ = [sqrt(sum(D(1,:).^2));sqrt(sum(D(2,:).^2));sqrt(sum(g_theta'.^2))];

return
