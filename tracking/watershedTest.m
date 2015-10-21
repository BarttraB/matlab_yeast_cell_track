%close all
%clear all
% center1 = -10;
% center2 = -center1;
% dist = sqrt(2*(2*center1)^2);
% radius = dist/2 * 1.4;
% lims = [floor(center1-1.2*radius) ceil(center2+1.2*radius)];
% [x,y] = meshgrid(lims(1):lims(2));
% bw1 = sqrt((x-center1).^2 + (y-center1).^2) <= radius;
% bw2 = sqrt((x-center2).^2 + (y-center2).^2) <= radius;
% bw = bw1 | bw2;
% figure, imshow(bw,'InitialMagnification','fit'), title('bw')

I=imread('wsTest2.tif');
I2=~logical(I);
figure, imshow(I2)

%D = bwdist(~bw);
D = bwdist(~I2);
figure, imshow(D,[],'InitialMagnification','fit')
title('Distance transform of ~bw')

D = -D;
%D(~bw) = -Inf;
D(~I2) = -Inf;

L = watershed(D);
rgb = label2rgb(L,'jet',[.5 .5 .5]);
figure, imshow(rgb,'InitialMagnification','fit')
title('Watershed transform of D')