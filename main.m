function main(jobId)
fprintf('Start job: %d\n', jobId);

%Add path:
addpath(genpath('.'));

%Number of models to include in result:
topN = 200;

%Number of models to go through for each object:
modelN = 2^32-1;

%Resolution:
unit = 0.01;

%Loading metadata:
disp('Loading SUNRGBDMeta_best_Oct19...');
load('./Metadata/SUNRGBDMeta_best_Oct19.mat');

%Specify start and end ID:
startId = (jobId-1)*3+1;
endId = jobId*3;

%Go through each scene:
for imageId = startId:endId
    
    %Check if scene is already processed:
    if size(dir(['output/scene',num2str(imageId),'/*.txt']),1) == length(SUNRGBDMeta_best_Oct19(imageId).groundtruth3DBB)
        disp(['Skip scene ',num2str(imageId),'.']);
        continue;
    end
    
    disp(['Processing scene ',num2str(imageId),'...']);

    %Get data for the target scene:
    imageData = SUNRGBDMeta_best_Oct19(imageId);

    %Get data for all objects:
    objDataset = imageData.groundtruth3DBB;

    %Create output folder for this scene:
    outputFolderPath = ['./output/scene',num2str(imageId)];
    createFolderInstr = ['mkdir ',outputFolderPath];
    system(createFolderInstr);

    %Get 3d points for each object:
    disp('Getting object 3d points...');
    [all_obj_points, all_obj_dim] = get_obj_points(SUNRGBDMeta_best_Oct19,imageId);

    %Go through each object in the scene:
    for objId = 1:length(objDataset)
        
        %Get data for this object:
        objData = objDataset(objId);
        
        %Get class name for the object:
        classname = objData.classname;
        
        %Check if the object is already processed: 
        if any(size(dir(['./output/scene',num2str(imageId),'/',num2str(objId),'_',classname,'_list.txt']),1))
            disp(['Skip object ',num2str(objId),'.']);
            continue;
        end
        
        %Path of input models for this class:
        inputFolderPath = ['../../workspace/Yinda/input/',classname];
        
        %Get all models for this class:
        allModelsAnySize = dir([inputFolderPath,'/*.obj']);
        
        %Keep the reasonably sized models:
        allModels = [];
        for j = 1:length(allModelsAnySize)
            if allModelsAnySize(j).bytes <= 1024*1024
                allModels = [allModels;allModelsAnySize(j)];
            end
        end
        
        %Store path and score for each model:
        pathCell = {};
        scoreCell = {};
        
        %Go through each model:
        for modelId = 1:min(length(allModels),modelN)
            
            %Path to the curent modeL;
            modelPath = [inputFolderPath,'/',allModels(modelId).name];
            
            %Get rendered points of the model:
            [ mdlPoints3d, mdlPoints2d, vList, fList ] = get_render_points( imageData, objData, modelPath );
            
            %Forward similarity score:
            [ similarity1 ] = get_similarity_mutual( mdlPoints3d, all_obj_points{objId},all_obj_dim{objId}, unit );
            
            %Backward similarity score:
            [ similarity2 ] = get_similarity_mutual( all_obj_points{objId}, mdlPoints3d,all_obj_dim{objId}, unit );
            
            %Mutual similarity score:
            similarity = similarity1 + similarity2;
            
            %Update path and score storage:
            pathCell{end+1} = modelPath;
            scoreCell{end+1} = similarity;
        end
        
        %Getting the best N sorted by score:
        A = struct('path',pathCell,'score',scoreCell);
        Acell = struct2cell(A);
        sz = size(Acell);
        Acell = reshape(Acell, sz(1), []);
        Acell = Acell';
        Acell = sortrows(Acell, 2);   
        n = min(topN,length(scoreCell));
        bestN = Acell(1:n, 1:2);
        
        %Write the result for this object:
        write_result(bestN, imageId,SUNRGBDMeta_best_Oct19,objId);  
        
    end
end
end