function J = msePointCloud(x,R,N)

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


return