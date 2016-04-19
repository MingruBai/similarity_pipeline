function [ mdlPoints3d, mdlPoints2d, vList, fList ] = get_render_points( cameraData, objData, shapePath )
[vList,fList] = create_obj(objData, shapePath);

fList = [fList fList(:,1)];

img = imread(cameraData.depthpath);
imsize = size(img);

K = cameraData.K;
P = K*[inv(cameraData.Rtilt*[1 0 0;0 0 1;0 1 0]) zeros(3,1)];

result = RenderMex(P, imsize(2), imsize(1), vList', uint32(fList'-1))';

z_near = 0.3;
depth = z_near./(1-double(result)/2^32);

[ points3d, points2d ] = depth2points3d( depth, cameraData);

[ inside_valid ] = get_points_in_box( points3d, objData );
mdlPoints3d = points3d(inside_valid,:);
mdlPoints2d = points2d(inside_valid,:);
end

