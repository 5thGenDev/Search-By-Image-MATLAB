% This function should compare F1 to F2 - 
% compute the distance between the two descriptors
function dst=cvpr_compare(F1, F2, dst_method, Eigenvalues)
    X = (F1 - F2).^2; % L2 Norm
%     X = F1 - F2;      % L1 Norm
    
    switch dst_method
        case 'Euclidean'
%             dst = sum(X);  % If use L1 Norm
            X = sum(X);  % If use L2 Norm
            dst=sqrt(X); % If use L2 Norm
        
        case 'Mahalanobis'
            X = X./(Eigenvalues'); % X and Eval must have same dimensional sizes
%             dst = sum(X);  % If use L1 Norm
            X = sum(X);  % If use L2 Norm
            dst=sqrt(X); % If use L2 Norm
        
        case 'Cosine'    % Cosine doesn't care about L1, L2
            dotProduct = sum(F1.*F2);
            magF1 = sqrt(sum(F1.^2));
            magF2 = sqrt(sum(F2.^2));
            dst = dotProduct/(magF1 + magF2);
    end
return;
