function [BinX BinY]=getBinCoords(Centroid,binSize)

BinX = max(round(Centroid(1)/binSize),1);
BinY = max(round(Centroid(2)/binSize),1); 