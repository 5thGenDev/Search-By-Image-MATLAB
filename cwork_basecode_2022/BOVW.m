%% Create Bag of Visual Words for all descriptors
%% and create frequency of visual words histogram for each img
%% and put all histograms into ALLFEAT

function ALLFEAT=BOVW(ALLDESCR,descr_per_img, nAllfiles)
    %% 1) Find clusters' centroids with Kmeans() function
    NClusters = 60;
    DIMENSION = 128; %Sift descriptor always has 128 dimensions
    
    initCentroids = rand(NClusters, DIMENSION); %[N Clusters x 128]
    Centroids = Kmeans(initCentroids,ALLDESCR',zeros(1,14));
    % Centroids are visual words if we give them "name" or index.

    
    %% 2) Find the closest cluster for each descriptor in all database
    alldists=[];
    for n=1:NClusters
       % compute distance of allpoints to this centroid
       dst=ALLDESCR-repmat(Centroids(n,:)',1,size(ALLDESCR,2));
       dst=sqrt(sum(dst.^2));  %find descriptor's magnitude to each cluster
                               %dst will go from 128 x N_ALLDESCR
                               %to 1 x N_ALLDESCR
       alldists=[alldists;dst];
    end
    % Thus alldists has N_clusters x N_ALLDESCR
    % each row has all_descr dsts to 1 particular cluster's centroid
    % each column has alldists of 1 descr to all centroids
    
    mindists=min(alldists); % 1 x N_descriptors
    % Each mindists element(1,j) = min val of column j in alldists
    
    alldists=double(alldists==repmat(mindists,NClusters,1));
    % alldists is a boolean matrix: 128 x N_ALLDESCR. In this Boolean matrix, per each descriptor, 
    % value 1(TRUE) occurs at the row (cluster) where the descriptor has min distance
     
    % line 40-42 are essentially indexing the rows in boolean matrix
    for n=1:NClusters
       alldists(n,:)=alldists(n,:).*n; 
    end
    % So we are indexing the closest cluster for each descriptor

    % this line just take the max value for each column (descriptor)
    classification=max(alldists); % 1 x N_ALL_descriptors matrix
    
    
    %% 3) Create sparse visual-word histogram
    % Each descriptor has its own visual word, but img has hundreds descriptors, 
    % => Per img, we extract hundreds visual words from classification
    % Number of visual words extracted = N descriptors in that img
    % then make a visual words histogram from extracted visual words
    
    % Histogram will have a length = total number of clusters
    ALLFEAT=zeros(nAllfiles:NClusters);
    ALLDESCR_INDEX = 1;
    
    for i = 1:nAllfiles
        START = ALLDESCR_INDEX;
        END = ALLDESCR_INDEX + descr_per_img(2,i)-1;
        extract_visual_words = classification(START:END);
        ALLDESCR_INDEX = ALLDESCR_INDEX + descr_per_img(2,i);
        
        %extract_visual_words is already a row vector 
        %so no need to reshape like other histograms
        H = hist(extract_visual_words,NClusters);
%         H = H./sum(H); % If normalise histogram by its sum
        ALLFEAT(i,:) = H;
    end 
    
    % Normalise histogram by tf-idf
    df = sum(ALLFEAT); % Should reduce [591 x N Cluster]
                       % downto [1 x N cluster]
    idf = log(nAllfiles./df);
    ALLFEAT = ALLFEAT.*idf;    
return;