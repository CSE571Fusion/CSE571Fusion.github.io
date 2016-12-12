function Tk = perturbOdometry(Tk,alpha)

    % get the values of Tk
    a = Tk(1,3);
    b = Tk(2,3);

    % sample delta errors
%     da = alpha(2)*randn;
%     db = alpha(3)*randn;
%     dtheta = alpha(3)*randn;
    da = alpha(1)*(2*rand-1);
    db = alpha(2)*(2*rand-1);
    dtheta = alpha(3)*(2*rand-1);
    
    % deterministic error (for testing)
%     dtheta = pi/8;
%     da = -0.12;
%     db = -0.25;
    
    Rot = [cos(dtheta), -sin(dtheta);
           sin(dtheta),  cos(dtheta)];
    
    % construct
    R = Tk(1:2,1:2)*Rot;
    T = [a+da; b+db];
    Tk = [R,    T;
          0, 0, 1];


return