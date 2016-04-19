function [all_obj_points, all_obj_dim] = get_obj_points(SUNRGBDMeta,imageId)
 
all_obj_points = {};
all_obj_dim = {};

data = SUNRGBDMeta(imageId);
[rgb,points3d,depthInpaint,imsize]=read3dPoints(data);
objDataSet = data.groundtruth3DBB;

for i = 1:length(objDataSet)
    objData = objDataSet(i);
    objCentroid  = objData.centroid;
    objCoeffs = objData.coeffs;
    
    [ inside_valid ] = get_points_in_box( points3d, objData );
    objPoints3D = points3d(inside_valid,:);
    all_obj_points{end+1} = objPoints3D;
    
    corners = get_corners_of_bb3d(objData);
    rectx = double(corners(1:4,1));
    recty = double(corners(1:4,2));
    zLo = objCentroid(3) - objCoeffs(3);
    zHi = objCentroid(3) + objCoeffs(3);
    
    obj_dim = [max(rectx),min(rectx),max(recty),min(recty),zHi,zLo];
    all_obj_dim{end + 1} = obj_dim;
end
end