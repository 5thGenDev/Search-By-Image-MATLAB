function H=ComputeRGBHistogram(img,Q)
    % Step 1
    qimg=double(img)./256;
    qimg=floor(qimg.*Q); % This is basically normalised[0,Q-1] 3D qimg
    
    % Step 2
    bin = qimg(:,:,1)*Q^2 + qimg(:,:,2)*Q^1 + qimg(:,:,3);
    
    % Step 3
    vals=reshape(bin,1,size(bin,1)*size(bin,2));
    
    % Step 4
    H = hist(vals,Q^3);
    H = H./sum(H); % Normalise histogram so all its values sums up to 1.
return;