%% This code is meant to divide the image into grid 
% before computing descriptor for every grid by cvpr_computedescriptor
% The goal is to divide image in [DxD] grid that fits Sobel filter

%% Intuition: 
% Each color layer of RGB image is a 2D matrix
% MATLAB mat2cell() divides 2D matrix into sub 2D matrices.

%% Extra implementation challenge and solution
% (3) If you use subplot then the problem is that 
% every element in 2D matrix is indexed by sweeping every row per column 
% while subplot indexs its position by sweeping every column per row
% --> transpose 2D matrix first so the twos share the same index
% DON't that same transposed matrix for histogram 

function gridImg=Image2Grids(img, gridSize)
    %% Step 1:
    [imgRows, imgColumns, colourChannels] = size(img);
    grid_per_column = fix(imgColumns/gridSize);
    grid_per_row = fix(imgRows/gridSize);  
    % New image matrix with trimmed off remainder row, column
    img = img(1:grid_per_row*gridSize, 1:grid_per_column*gridSize,:);


    %% Step 2
    columnDist(1:grid_per_column) = gridSize;
    rowDist(1:grid_per_row) = gridSize; 
    % Let say block size = 3
    % then rowDist = [3 3 3 3 ... 3] where rowDist = [1 x grid_per_row]
    % same applies for columnDist
    
    gridImg = mat2cell(img, rowDist, columnDist, colourChannels);
    
    % Subplot to see the effect of gridding
    %V = gridImg.';
    %for i = 1:numel(V)
    %    subplot(grid_per_row, grid_per_column,i);
    %    imshow(V{i});
    %end
    %imshow(cell2mat(gridImg));
return; 
