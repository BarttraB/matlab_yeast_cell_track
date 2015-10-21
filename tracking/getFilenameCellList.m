function filenames=getFilenameCellList(directory,searchPattern)
filelist = dir([directory searchPattern]);
for j=1:length(filelist)
    filelist(j).path=[directory filelist(j).name];    
end
filenames = {filelist.path}';