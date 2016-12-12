function h = initializePlot()

h = figure(1);cla
colormap(h,flipud(gray))
box on; hold on;
axis off;
% grid on;
axis equal
% create a custom colormap for the TSDF
cmap = [.5,   1,  .5;
        .5,  .95, .5;
        .5,  .9,  .5;
        .5,  .85, .5;
        .5,  .8,  .5;
        .5,  .75, .5;
        .5,  .7,  .5;
        .5,  .65, .5;
        .5,  .6,  .5;
        .5,  .55, .5;
        .5,  .5,  .5;
        .55, .5,  .5;
        .6,  .5,  .5;
        .65, .5,  .5;
        .7,  .5,  .5;
        .75, .5,  .5;
        .8,  .5,  .5;
        .85, .5,  .5;
        .9,  .5,  .5;
        .95, .5,  .5;
         1,  .5,  .5];
colormap(gcf,cmap)
colorbar('SouthOutside')



% figure(2);cla
% colormap(gcf,cmap)

return