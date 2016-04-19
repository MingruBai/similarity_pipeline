function [ similarity ] = get_similarity_mutual( pointsRefer, pointsCheck,objDim, unit )


if length(pointsRefer) == 0 || length(pointsCheck) == 0
    similarity = single(1000);
    return;
end


xMax = objDim(1)+unit;
xMin = objDim(2)-unit;
yMax = objDim(3)+unit;
yMin = objDim(4)-unit;
zMax = objDim(5)+unit;
zMin = objDim(6)-unit;

xDim = floor((xMax-xMin)/unit);
yDim = floor((yMax-yMin)/unit);
zDim = floor((zMax-zMin)/unit);

bw = zeros(xDim,yDim,zDim);

vix = floor((pointsRefer(:,1)-xMin)/unit)+1;
viy = floor((pointsRefer(:,2)-yMin)/unit)+1;
viz = floor((pointsRefer(:,3)-zMin)/unit)+1;
valid = vix>=1 & vix<=xDim & viy>=1 & viy<=yDim & viz>=1 & viz<=zDim;
ind = sub2ind([xDim yDim zDim], vix(valid), viy(valid), viz(valid));
bw(ind) = 1;

D1 = bwdist(bw);

maxD = max(max(max(D1)));
sD1 = size(D1);

pointsCheckGrid(:,1) = (pointsCheck(:,1)-xMin)/unit + 1;
pointsCheckGrid(:,2) = (pointsCheck(:,2)-yMin)/unit + 1;
pointsCheckGrid(:,3) = (pointsCheck(:,3)-zMin)/unit + 1;

pointsCheckGrid = floor(pointsCheckGrid);
pointsCheckGridValidIndex = pointsCheckGrid(:,1) < sD1(1) & pointsCheckGrid(:,2) < sD1(2) & pointsCheckGrid(:,3) < sD1(3) & pointsCheckGrid(:,1) > 0 & pointsCheckGrid(:,2) > 0 & pointsCheckGrid(:,3) > 0;
indexArray = pointsCheckGrid(pointsCheckGridValidIndex,:);
similarity = sum(D1(sub2ind(size(D1),indexArray(:,1),indexArray(:,2),indexArray(:,3)))) + maxD*(length(pointsCheckGridValidIndex) - sum(pointsCheckGridValidIndex));

similarity = similarity / size(pointsCheck,1);

end

