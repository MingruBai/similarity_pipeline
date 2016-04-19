function [vList,fList]=create_obj(objData, modelPath)
fprintf('.');

shapeOri = [-1,0,0];
objOri = [objData.orientation(1),objData.orientation(2),objData.orientation(3)];
xBasis = [objData.basis(1,1),objData.basis(1,2),objData.basis(1,3)];
yBasis = [objData.basis(2,1),objData.basis(2,2),objData.basis(2,3)];

%get correct dimensions:
if abs(dot(objOri,xBasis)) > abs(dot(objOri,yBasis))
    xDim = objData.coeffs(1);
    yDim = objData.coeffs(2);
else
    xDim = objData.coeffs(2);
    yDim = objData.coeffs(1);
end
zDim = objData.coeffs(3);


vdot = shapeOri(1)*objOri(1)+shapeOri(2)*objOri(2);
vdet = shapeOri(1)*objOri(2)-shapeOri(2)*objOri(1);
theta = atan2(vdet, vdot);
costheta = cos(theta);
sintheta = sin(theta);
rMatrix = [costheta,-sintheta;sintheta,costheta];

%read shape data:
fid = fopen(modelPath,'r');
file_text=fread(fid, inf, 'uint8=>char')';
fclose(fid);
file_lines = regexp(file_text, '\n+', 'split')';
file_lines(strcmp(file_lines,'')) = [];
linesSplit = regexp(file_lines, ' ', 'split')';
allMat = reshape([linesSplit{:}],4,[])';

vList = str2double(allMat(strcmp(allMat(:,1),'v'),2:4));
fList = str2double(allMat(strcmp(allMat(:,1),'f'),2:4));

temp = vList(:,2);
vList(:,2) = vList(:,3);
vList(:,3) = temp;

%resize:
maxX = max(vList(:,1));
maxY = max(vList(:,2));
maxZ = max(vList(:,3));
ratioX = xDim/maxX;
ratioY = yDim/maxY;
ratioZ = zDim/maxZ;
ratio = min([ratioX,ratioY]);

vList(:,1) = shapeOri(1) * vList(:,1) * ratio;
vList(:,2) = vList(:,2) * ratio;
vList(:,3) = vList(:,3) * ratioZ;

%rotation:
rotatedXY(:,1) = rMatrix(1,1) * vList(:,1) + rMatrix(1,2) * vList(:,2);
rotatedXY(:,2) = rMatrix(2,1) * vList(:,1) + rMatrix(2,2) * vList(:,2);
vList(:,1) = rotatedXY(:,1);
vList(:,2) = rotatedXY(:,2);

%displacement:
vList(:,1) = vList(:,1) + objData.centroid(1);
vList(:,2) = vList(:,2) + objData.centroid(2);
vList(:,3) = vList(:,3) + objData.centroid(3);

end

