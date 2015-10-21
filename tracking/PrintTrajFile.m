function PrintTrajFile(fileName,objectCell,trajectory,TrajBin)
%traj_values=zeros(length(trajectory));
%numOfFrames=length(objectCell);
output_write_seg = 'C:\Users\Michael Ferry\experiments\MF220\analysis_data\xy2\segmented\';
segfilelist = dir([output_write_seg 'segment*']);
segfileNames = {segfilelist.name}';

OutputDir='C:\Users\Michael Ferry\experiments\MF220\analysis_data\xy2\Trajectories\20091207_1620\';

numOfFrames=length(TrajBin);
fidO=fopen(fileName,'w');
h = waitbar(0,'Writing traj info file');

for slice=1:numOfFrames
    TrajObjectsInSlice=[TrajBin{slice}{:}];
    TrajNumbers=[TrajObjectsInSlice.Number];
    for i=1:length(TrajNumbers)
            objectNum=trajectory{TrajNumbers(i)}([trajectory{TrajNumbers(i)}.frame]==slice).object;
            s=slice;
            x=round(objectCell{slice}(objectNum).Centroid(1));
            y=round(objectCell{slice}(objectNum).Centroid(2));
            
            fprintf(fidO,'%d\t%d\t%d\t%d\n',s,x,y,TrajNumbers(i));
    end

%     for i=1:length(trajectory)
%         if(any([trajectory{i}.frame]==slice))
%             objectNum=trajectory{i}([trajectory{i}.frame]==slice).object;
%             s=slice;
%             x=round(objectCell{slice}(objectNum).Centroid(1));
%             y=round(objectCell{slice}(objectNum).Centroid(2));
%             
%             fprintf(fidO,'%d\t%d\t%d\t%d\n',s,x,y,i);
% 
%         end
%     end
    waitbar(slice / numOfFrames,h)
end
fclose(fidO);