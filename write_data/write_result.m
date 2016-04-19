function write_result(cell_towrite, imageId, SUNRGBDMeta,i)

classname = SUNRGBDMeta(imageId).groundtruth3DBB(i).classname;

filepath = ['./output/scene',num2str(imageId),'/',num2str(i),'_',classname,'_list.txt'];
createFileInstr = ['touch ',filepath];
system(createFileInstr);

fp = fopen(filepath,'w');

for j = 1:size(cell_towrite,1)
    p = cell_towrite{j,1};
    s = num2str(cell_towrite{j,2});
    toWrite = [p,'\t',s,'\n'];
    fprintf(fp,toWrite);
end

fclose(fp);

end