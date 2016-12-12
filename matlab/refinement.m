
%% remove noises and fill small holes: 
% I=rgb2gray(imread('d:\Documents\GitHub\CSE571Fusion.github.io\matlab\figures\test4.png'));
function I3=refinement(I)
% I=rgb2gray(imread('d:\Documents\GitHub\CSE571Fusion.github.io\matlab\figures\test4.png'));
I1=I;
I3=I;
I3(I3==max(I3(:)))=0;% remove background color
I1(I1==max(I1(:)))=0;% remove background color
I1(I1>0)=255;
% inverse the intensity: 
I2=imcomplement(I1);
[L,num]=bwlabel(I2);
[h,w]=size(I2);
% newimage=zeros(h,w);

%% get the number of points in each group
count=1;
for len=1:1:num
    t=0;
    for m=1:1:h
        for n=1:1:w
            if L(m,n)==len
                t=t+1;
            end
            
        end
    end
    A(count,1)=len;
    A(count,2)=t;
    count=count+1;
end

[B1,O1]=sort(A(:,2),'descend');
for t1=2:1:length(O1)
    for m=1:1:h
        for n=1:1:w
           if L(m,n)==O1(t1)
                I3(m,n)=neighavg(m,n,I3);
           end
        end
    end
end

%assign a new intensity value for each pixels in the small hole by
%averaging it's 8-connected neighbors. 
% INPUT: row and col of the current pixel
% Img: NOT binary image, should be TSDF mesh image

function newI=neighavg(r,c,Img)
% find it's 8-connected neighbor with value
neighbor=[];
New=[];
for i=-1:1:1
    for j=-1:1:1
        if i==0 && j==0
            continue;
        else
            if Img(r+i,c+j)~=0
                neighbor(end+1,:)=[r+i,c+j]; 
                New(end+1,:)=Img(r+i,c+j);
            end
        end
    end
end

newI=round(mean(New));





