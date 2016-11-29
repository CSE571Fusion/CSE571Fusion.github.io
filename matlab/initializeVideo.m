function vObj = initializeVideo(h,Sk)


name = 'csail.corrected Raycasting TSDF';
vObj = VideoWriter(name,'MPEG-4');
vObj.FrameRate = 30;
vObj.Quality = 95;
open(vObj);

set(h,'position',[1 5 1280 720])
name = strrep(name,'_','\_');
title([name,sprintf(', Resolution = %2.0f [mm]',1000*Sk.resolution)]);
text(-19,-9,sprintf('k = %02i',1))
xlim([min(min(Sk.x)) max(max(Sk.x))])
ylim([min(min(Sk.y)) max(max(Sk.y))])
view(2)
text(-19,-9,sprintf('k = %02i',1))
patch([-15 -10 -10 -15 -15],[-9.1 -9.1 -8.9 -8.9 -9.1],'k');
text(-12.5,-8.9,'5 m','HorizontalAlignment','center',...
    'VerticalAlignment','bottom')


return