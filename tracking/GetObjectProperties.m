function [frame,traj_values]=GetObjectProperties(objectCell,trajectory)
%'a'
traj_values=zeros(length(trajectory),1);
frame=zeros(length(trajectory),1);
%length(trajectory)
%trajectory
for i=1:length(trajectory)
    %i
    frame(i)=trajectory(i).frame;
    traj_values(i)=objectCell{trajectory(i).frame}(trajectory(i).object).fluorMean(1);
    
    %     traj_values(i).Area=objectCell{frames(i)}(selectedObjects(i)).Area;
    %     traj_values(i).Eccentricity=objectCell{frames(i)}(selectedObjects(i)).Eccentricity;
    %     traj_values(i).CentroidX=objectCell{frames(i)}(selectedObjects(i)).Centroid(1);
    %     traj_values(i).CentroidY=objectCell{frames(i)}(selectedObjects(i)).Centroid(2);
end