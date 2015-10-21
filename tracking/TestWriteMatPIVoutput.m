
outdir='C:\Users\Michael Ferry\Desktop\Bridget\MatPIV_test\';
outPrefix='matPIVtest';
i=1;
fu=ones(128,128);
fv=zeros(128,128);

fileName=sprintf('%s%s_%05d%s',outdir,outPrefix,i,'.mat');
[fid,message]=fopen(fileName);
%     message
%     fu
%     fv
%fu=fread(fid);
fwrite(fid, fv, 'double');
fclose(fid);