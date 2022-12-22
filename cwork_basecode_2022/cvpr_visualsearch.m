%% EEE3032 - Computer Vision and Pattern Recognition (ee3.cvpr)
%%
%% cvpr_visualsearch.m
%% Skeleton code provided as part of the coursework assessment
%%
%% This code will load in all descriptors pre-computed (by the
%% function cvpr_computedescriptors) from the images in the MSRCv2 dataset.
%%
%% It will pick a descriptor at random and compare all other descriptors to
%% it - by calling cvpr_compare.  In doing so it will rank the images by
%% similarity to the randomly picked descriptor.  Note that initially the
%% function cvpr_compare returns a random number - you need to code it
%% so that it returns the Euclidean distance or some other distance metric
%% between the two descriptors it is passed.
%%
%% (c) John Collomosse 2010  (J.Collomosse@surrey.ac.uk)
%% Centre for Vision Speech and Signal Processing (CVSSP)
%% University of Surrey, United Kingdom

close all;
clear all;

%% Edit the following line to the folder you unzipped the MSRCv2 dataset to
DATASET_FOLDER = '/user/HS402/nt00601/Documents/MATLAB/CV/MSRC_ObjCategImageDatabase_v2';

%% Folder that holds the results...
DESCRIPTOR_FOLDER = '/user/HS402/nt00601/Documents/MATLAB/CV/descriptors';
%% and within that folder, another folder to hold the descriptors
%% we are interested in working with
DESCRIPTOR_SUBFOLDER='/globalRGBhisto';

tic

%% 1) Load all the descriptors into "ALLFEAT"
%% each row of ALLFEAT is a descriptor (is an image)

ALLFILES=cell(1,0);
ctr=1;
allfiles=dir (fullfile([DATASET_FOLDER,'/Images/*.bmp']));

ALLFEAT=[];
descr_per_img = zeros(2,length(allfiles)); % If use BOVW
for filenum=1:length(allfiles)
    fname=allfiles(filenum).name;
    imgfname_full=([DATASET_FOLDER,'/Images/',fname]);
    img=double(imread(imgfname_full))./256;
    thesefeat=[];
    featfile=[DESCRIPTOR_FOLDER,'/',DESCRIPTOR_SUBFOLDER,'/',fname(1:end-4),'.mat'];%replace .bmp with .mat
    load(featfile,'F');
    ALLFILES{ctr}=imgfname_full;
%     ALLFEAT=[ALLFEAT; F]; % For Colour or EOH descriptors
    
    % Uncomment following 3 lines if use BOVW
    ALLFEAT=[ALLFEAT, F]; % For Sift descriptors
    descr_per_img(2,filenum) = size(F,2);
    descr_per_img(1,filenum) = filenum;

    ctr=ctr+1;
end
ALLFEAT = BOVW(ALLFEAT,descr_per_img, length(allfiles));


%% 2) Sweep every image to be the query to calculate MAP
NIMG=size(ALLFEAT,1);               % number of images in collection
AP = zeros(1,NIMG);
for queryimg = 1:NIMG
    %% 3) Compute the distance of image to the query
    dst=zeros(NIMG,2);

    %If use PCA/Mahalanobis
    e = Eigen_Build(ALLFEAT');
%     e = Eigen_Deflate(e,'keepn',length(F)); % Keep all eigenvectors
%     e = Eigen_Deflate(e,'keepn',fix(length(F)*0.50));
    e = Eigen_Deflate(e,'keepn',fix(size(ALLFEAT,2)*0.10));
    ALLFEATPCA = Eigen_Project(ALLFEAT',e)';
    query = ALLFEATPCA(queryimg,:); % Loaded query descriptor 

    % For plotting, comment these if benchmarking runtime obv
%     plot3(ALLFEATPCA(:,1), ALLFEATPCA(:,2), ALLFEATPCA(:,3), 'rx');
%     xlabel('1st Eigenvector');
%     ylabel('2nd Eigenvector');
%     zlabel('3rd Eigenvector');
    
    % if use Euclidean or Cosine
%     query = ALLFEAT(queryimg,:);  % Loaded query descr
    
    for i=1:NIMG
        % Loaded candidate descr at index i 
%         candidate = ALLFEAT(i,:); % If use Euclid or Cosine
        candidate = ALLFEATPCA(i,:); % If use PCA
    
        % Euclidean dst
%         thedst=cvpr_compare(query,candidate,'Euclidean');
    
        % Mahalanobis dst
        thedst=cvpr_compare(query,candidate,'Mahalanobis',e.val);
        
        % Cosine dst
%         thedst=cvpr_compare(query,candidate,'Cosine');

        dst(i,1) = thedst;
        dst(i,2) = i;
    end
    dst=sortrows(dst,1);  % sort dsts for Euclid and Mahalanobis
%     dst=sortrows(dst,1,"descend"); % sort dsts if use Cosine


    %% 4) Visualise the results
    %% These may be a little hard to see using imgshow
    %% If you have access, try using imshow(outdisplay) or imagesc(outdisplay)
%     SHOW=10; % Show top 10 results
%     dstShow=dst(1:SHOW,:);
%     outdisplay=[];
%     for i=1:size(dstShow,1)
%        img=imread(ALLFILES{dstShow(i,2)});
%        img=img(1:2:end,1:2:end,:); % make image a quarter size
%        img=img(1:81,:,:); % crop image to uniform size vertically (some MSVC images are different heights)
%        outdisplay = [outdisplay img];
%     end
%     figure(1);
%     imgshow(outdisplay);
%     axis off;
    

    %% 5) Evaluate result with PR curve and AP
    % Get category index for query img
    queryName = allfiles(queryimg).name;
    queryIndices = extractBefore(queryName, '_s.bmp');
    queryRow = extractBefore(queryIndices, '_');
    
    % Get num of img same category as query
    % This is to calculate Recall later on
    SameCategory = 0;
    for i = 1:NIMG
        imgName = allfiles(i).name;
        imgIndices = extractBefore(imgName, '_s.bmp');
        imgRow = extractBefore(imgIndices, '_');
        
        if queryRow == imgRow
            SameCategory = SameCategory + 1;
        end 
    end 
    
    % Ple-allocate array
    Precision = zeros(2,NIMG);
    Recall = zeros(1,NIMG);
    
    % Initialise variables for PR 
    relevantImg = 0;
    
    for i = 1:NIMG
        % get category index of candidate img
        imgName = allfiles(dst(i,2)).name;
        imgIndices = extractBefore(imgName, '_s.bmp');
        imgRow = extractBefore(imgIndices, '_');
        rel = 0;
    
        if queryRow == imgRow
            relevantImg = relevantImg + 1;
            rel = 1;
        end
    
        Precision(1,i) = relevantImg/i;
        Precision(2,i) = rel;
        Recall(i) = relevantImg/SameCategory;
    end 
    
    % Plotting PR curve
%     figure(2);
%     plot(Recall,Precision(1,:));
%     grid;
%     title('PR plot');
%     xlabel('Recall');
%     ylabel('Precision');
    
    % Summarise PR plot with a single variable Average Precision
    AP(queryimg) = sum(Precision(1,:).*Precision(2,:))/SameCategory;
end

AP = AP'; % Transpose row-vector into column for Excel
MAP = sum(AP)/numel(AP); % Mean Average Precision
toc