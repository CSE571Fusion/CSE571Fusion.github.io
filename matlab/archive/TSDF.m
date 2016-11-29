%% compute TSDF at each point
% Example:
%   Fk=TSDF(eta,mu)
% 
% Dependencies:
% No
%
% 
% *************************************************************************
% Modified: 08-Nov-2016
% Created: 08-Nov-2016
%
% Qiuyu Chen, Electrical Engneering
% University of Washington
% *************************************************************************
function Fk=TSDF(eta,mu)
if nargin<2
    mu=1;%default truncated distance
end

% define TSDF
if eta>=-mu
    Fk=min(1,eta/mu)* sign(eta);
else
    % define a really large number
    Fk=1e10;
end




