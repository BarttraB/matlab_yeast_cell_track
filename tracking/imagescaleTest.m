phase=imread('C:\Users\Michael Ferry\Desktop\Bridget\ymc003\t000001xy2c1.tif');
segColor=imread('C:\Users\Michael Ferry\Desktop\Bridget\outTest24\SegmentedColor1.tif');

boundariesLow=0.0125;
%boundariesHigh=0.975;
boundariesHigh=1-boundariesLow;

phaseDBL=im2double(phase);
[M N]=size(phaseDBL);
phaseRESHAPE=reshape(phaseDBL,M*N,1);
hist(phaseRESHAPE,25)

phaseRESHAPE_sort=sort(phaseRESHAPE);

phaseRESHAPE_length=length(phaseRESHAPE_sort);

lowbound=phaseRESHAPE_sort(phaseRESHAPE_length*boundariesLow);
highbound=phaseRESHAPE_sort(phaseRESHAPE_length*boundariesHigh);

phaseDBLscaled=(1/(highbound-lowbound))*(phaseDBL-lowbound);

phaseRESHAPEscaled=reshape(phaseDBLscaled,M*N,1);
figure
hist(phaseRESHAPEscaled,25)

phaseUINT8=im2uint8(phaseDBLscaled);


[phaseInd,map]=gray2ind(phaseUINT8);
phaseRGB=ind2rgb8(phaseInd,map);

comprgb=0.5*phaseRGB+0.5*segColor;

figure
imshow(comprgb)