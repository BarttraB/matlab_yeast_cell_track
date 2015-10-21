

nframes=800;

tic

%allocate space

seeds4=zeros(1040,1392,nframes);

% seed_label=BW;

for f=1:nframes%:nframes 
f
%read in -fast`
Ir=imread(['/Volumes/Storage/Expt_BB/expt12_aug8_2014_Ti2/begin001/c1/t000' sprintf('%03g', f) 'xy1c1.tif']);
%Ir=imread(['F:\CarbStarve_Rtg1_Whi5\c1\t000' sprintf('%03g', f) 'xy1c1.tif']);
Ia=imadjust(Ir);

%*threshold image
Id=double(Ia);
It(f) = otsuthresh(Id,[],'');
BW=Ia<2e4;
BW=Ia<It(f);

bw1=imerode(BW,strel('disk',20));
bw2=imdilate(bw1,strel('disk',23));

imagesc(bw2+BW)

BW2=BW;
BW2(bw2)=0;
imagesc(BW2)


%watershed with seeds
seed_new=imerode(BW2,strel('disk',8));



im_out = double(watershed(-(BW2 +seed_new)));
im_out(BW2==0)=0;
imagesc(im_out)


%*remove spots
BWo=bwareaopen(1-BW, 200);
%nameout= ['/Volumes/Storage/Expt_BB/expt12_aug8_2014/begin001/fiji/premasks/premask_t000', sprintf('%04g',f),'.tif'];
%imwrite(uint8(BWo*255), nameout);

seeds=imdilate(BWo,strel('disk',12));

seeds2=imerode(seeds, strel('disk',10));

%last two steps to remove the outside big area
seeds3=bwareaopen(1-seeds2, 8000);
% seeds4(:,:,f)=(1-seeds2)-seeds3 ;
seeds4=(1-seeds2)-seeds3 ;

nameout2= ['/Volumes/Storage/Expt_BB/expt12_aug8_2014_Ti2/begin001/masks/mask_t000', sprintf('%04g',f),'.tif'];
%imwrite(uint8((1-seeds4(:,:,f))*255), nameout2)
imwrite(uint8((1-seeds4(:,:))*255), nameout2)


%seeds4(:,:,f)=imerode(seeds, strel('disk',12));
% bwlabel= labelmatrix(bwconncomp())
%seed_label(:,:,f) = bwlabel(1-seeds2(:,:,f));
end

toc
%takes <225.803705 seconds for 800 images

%*making movie
%implay(seeds3);
%s3g=mat2gray(seeds3);
tic
movie_maker_VW(1-seeds4,'seg_testvid');
toc
