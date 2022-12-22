%% Edge Orientation Histogram
function H=ComputeEOH(img,Q)
    % EO processing step 1
    img = img./255;
    img = rgb2gray(img);

    % EO processing step 2 
    img = imgaussfilt(img,1.6);
    
    % EO processing step 3
    [imgMag, imgAngle] = imgradient(img,'sobel');
    % Each element of imgAngle ranges from (-180,180)
    % So we add element-wise by 180 to get orientation range from (0,360)
    imgAngle = imgAngle+repmat(180,size(imgAngle,1),size(imgAngle,2));
    
    % Step 1
    imgAngle = imgAngle./360;
    bin=floor(imgAngle.*Q);
    
    % Step 3
    vals = reshape(bin, 1, size(bin,1)*size(bin,2));

    % Step 4
    H = hist(vals,Q);
    H = H./sum(H);
return;

