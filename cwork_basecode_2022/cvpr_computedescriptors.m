%% EEE3032 - Computer Vision and Pattern Recognition (ee3.cvpr)
%%
%% cvpr_computedescriptors.m
%% Skeleton code provided as part of the coursework assessment
%% This code will iterate through every image in the MSRCv2 dataset
%% and call a function 'extractRandom' to extract a descriptor from the
%% image.  Currently that function returns just a random vector so should
%% be changed as part of the coursework exercise.
%%
%% (c) John Collomosse 2010  (J.Collomosse@surrey.ac.uk)
%% Centre for Vision Speech and Signal Processing (CVSSP)
%% University of Surrey, United Kingdom

close all;
clear all;

%% Edit the following line to the folder you unzipped the MSRCv2 dataset to
DATASET_FOLDER = '/user/HS402/nt00601/Documents/MATLAB/CV/MSRC_ObjCategImageDatabase_v2';

%% Create a folder to hold the results...
OUT_FOLDER = '/user/HS402/nt00601/Documents/MATLAB/CV/descriptors';
%% and within that folder, create another folder to hold these descriptors
%% the idea is all your descriptors are in individual folders - within
%% the folder specified as 'OUT_FOLDER'.
OUT_SUBFOLDER='/globalRGBhisto';
tic
allfiles=dir (fullfile([DATASET_FOLDER,'/Images/*.bmp']));
for filenum=1:length(allfiles)
    fname=allfiles(filenum).name;
    fprintf('Processing file %d/%d - %s\n',filenum,length(allfiles),fname);

    imgfname_full=([DATASET_FOLDER,'/Images/',fname]);
    img=double(imread(imgfname_full));
    fout=[OUT_FOLDER,'/',OUT_SUBFOLDER,'/',fname(1:end-4),'.mat'];%replace .bmp with .mat
    
    %F=extractRandom(img);   %% now become extractAverageColour


    %% Grid or RGB_H or EOH Image Descriptor
    blockSize = 30; %blockSize >= 3 to at least fit Sobel filter for EOH
    gridImg=Image2Grids(img,blockSize);

    %RGB Histogram
%     Q_RGB = 4;  % Dont comment this unless not using histogram at all
%     colourChannels = size(img,3); % if use grid
%     rgbH = zeros(1,Q_RGB^colourChannels); % if use grid
%     rgbH =ComputeRGBHistogram(img,Q_RGB); % if no grid

    %Edge Orientation Histogram, same rule applies
%     Q_Angle = 8;  % Dont comment this unless not using histogram at all
%     EOH = zeros(1,Q_Angle);  % if use grid
%     EOH = ComputeEOH(img,Q_Angle);  % if no grid
   
    % uncomment this loop if use grid
%     for i=1:numel(gridImg)        
%         tempGridImg = cell2mat(gridImg(i));
%         rgbH = rgbH + ComputeRGBHistogram(tempGridImg,Q_RGB);
%         EOH = EOH + ComputeEOH(tempGridImg, Q_Angle);
%     end

%     F = [rgbH, EOH]; % If use both rgbH and EOH
%     F = rgbH;
%     F = EOH;
%     save(fout, 'F');

    %% Sift descriptor
    img = img./255;
    img = rgb2gray(img);
    
    [frames,F] = sift(img,'Verbosity',0); % F = 128 x N_descriptors_per_img
    % Descriptor's dimension = 128. This applies to all output of SIFT
    save(fout,'F');
    
end
toc