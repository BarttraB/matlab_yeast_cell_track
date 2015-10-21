function [Centroid]=getUpdatedCentroidFromVelocityField(velocityfield,curFrame,Centroid,endObjectFrame)
binSize=8;
minX=16;
minY=16;
BinXLim=size(velocityfield{1}{5},2);
BinYLim=size(velocityfield{1}{6},1);

%Centroid=TrajObject.Centroid;

for i=endObjectFrame:curFrame
    
    BinX = (Centroid(1)-minX/2)/binSize;
    BinY = (Centroid(2)-minY/2)/binSize;
    
    if((BinX > 1 && BinX <= BinXLim) && (BinY > 1 && BinY <= BinYLim) && curFrame <=length(velocityfield))
        
        BinXC = [floor(BinX),ceil(BinX)];
        BinYC = [floor(BinY),ceil(BinY)];
        
        %     subU=velocityfield{curFrame}{5}(BinYC,BinXC);
        %     subV=velocityfield{curFrame}{6}(BinYC,BinXC);
        subU=velocityfield{i}{5}(BinYC,BinXC);
        subV=velocityfield{i}{6}(BinYC,BinXC);
        
        normBinX=BinX-floor(BinX);
        normBinY=BinY-floor(BinY);
        
        %computes the bilinear interpolated values of the velocity field
        u = [1-normBinY,normBinY]*subU*[1-normBinX;normBinX];
        v = [1-normBinY,normBinY]*subV*[1-normBinX;normBinX];
        
        Centroid(1)=Centroid(1)+u;
        Centroid(2)=Centroid(2)+v;
    end
end
    
    
    