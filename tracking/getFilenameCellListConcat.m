function filenames=getFilenameCellListConcat(sourceDir,searchPattern,outDir,concat)
filelist = dir([sourceDir searchPattern]);
for j=1:length(filelist)
    filelist(j).path=[outDir concat filelist(j).name];    
end
filenames = {filelist.path}';