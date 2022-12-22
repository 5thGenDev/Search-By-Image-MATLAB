function F=extractRandom(img)
    red = img(:,:,1); %extract red layer (x,y) from RGB image as 2D matrix
    red = reshape(red,1,[]); %reshape 2D matrix to row vector
    average_red=mean(red);
    
    %apply same idea to green and blue layers
    green=img(:,:,2);
    green = reshape(green,1,[]);
    average_green=mean(green);

    blue=img(:,:,3);
    blue=reshape(blue,1,[]);
    average_blue=mean(blue);

    % Returns a row [AverageRed AverageGreen AverageBlue] 
    % computed from image 'img' to represent an image descriptor
    F=[average_red average_green average_blue];   
    % Note img is a normalised RGB image 
    % i.e. colours range [0,1] not [0,255].

return;