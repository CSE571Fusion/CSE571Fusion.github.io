function newI=smoothness(I,threshold)
%% INPUT: I: image needs to be refined
%% Threshold: remove small number of connected pixels
I1=I;
I1(I1==max(I1(:)))=0;% remove background color
I1(I1>0)=255;
% inverse the intensity: 
[L,num]=bwlabel(I1);
[h,w]=size(I1);
% newimage=zeros(h,w);
newI=I;
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

for t1=1:1:length(B1)
    if B1(t1)<threshold
        [r,c]=find(L==O1(t1));
        newI(r,c)=0;
    end
end
