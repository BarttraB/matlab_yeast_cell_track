function [AvArea,AvBox]=GetAveragePropsFromObjects(ObjectCell)
%traj_values=NaN(length(frames),1);

for i=1:length(ObjectCell)
%     index=[selectedObjects.frame]==i;
%     if(any(index))
%         objectNum=selectedObjects(index).object;
%         if(~isnan(objectNum))
%             traj_values(i)=objectCell{frames(i)}(objectNum).fluorMean(1);
%         end
%     end
     Area(i)=mean([ObjectCell{i}.Area]);
     Box(i)=mean([ObjectCell{i}.Area].^0.5);
%     traj_values(i).Eccentricity=objectCell{frames(i)}(selectedObjects(i)).Eccentricity;
%     traj_values(i).CentroidX=objectCell{frames(i)}(selectedObjects(i)).Centroid(1);
%     traj_values(i).CentroidY=objectCell{frames(i)}(selectedObjects(i)).Centroid(2);
end
AvArea=mean(Area);
AvBox=mean(Box);