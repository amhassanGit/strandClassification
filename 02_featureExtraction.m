load PMT01_Red_Raw_Data_8bit_20170308_stack1-PreThresholdVectorizedStructure.mat

%load raw data - is this the right data to use?
clear Iraw
for i=1:201
    Iraw(:,:,i)=imread('OriginalVascBlockTif/PMT01_Red_Raw_Data_8bit_20170308_stack1.tif',i);
end;

% select z indices to use for max intensity projection
slice_ind = 100:125; 
% display MIP of raw data
imagesc(max(Iraw(:,:,slice_ind),[],3)'); axis image; colormap gray
hold on;
% loop through strands and overlay strands that lie in slice_ind
for istrand=1:length(vectorizedStructure.Strands)
    
    strand = vectorizedStructure.Strands(istrand);
    ind = strand.StartToEndIndices; % extract StartToEndIndices
    
    % this seems to hold the actual coordinates of the centerline
    coords=vectorizedStructure.Vertices.AllVerts(ind,:); 
    x=coords(:,1); y=coords(:,2); z=coords(:,3);
    % check whether any of the z coordinates lie in the slice of interest
    % (slice_ind)
    z_ind = find(z>=slice_ind(1) & z<=slice_ind(end));
    if(any(z_ind))
        % overlay a line plot of the xy center line coordinates of this strand but only for
        % ones that lie in the slice of interest
        plot(x(z_ind),y(z_ind),'LineWidth',1)
    end
end
hold off




%% Create Table For machine Learning

load st-PreThresholdVectorizedStructure.mat
load strandsToPlot.mat
load bad_Strands.mat

for i=1:2692
    Iraw(:,:,i)=imread('st.tif',i);
end;

%%
for istrand=1:size(vectorizedStructure.Strands,2)
    
    strand = vectorizedStructure.Strands(istrand); % strand info
    ind = strand.StartToEndIndices; % extract StartToEndIndices
    
    % this seems to hold the actual coordinates of the centerline
    coords=vectorizedStructure.Vertices.AllVerts(ind,:); 
    x=coords(:,1); y=coords(:,2); z=coords(:,3);
    radius=vectorizedStructure.Vertices.AllRadii(ind,:);
    
    length = sqrt(abs(x(1)-x(end))^2 + abs(y(1)-y(end))^2 + abs(z(1)-z(end))^2);
    
    if max(z) > size(Iraw,3)
        meanIntensity = 0;
    else 
        intensity = 0; % initiate intensity value
        for j = 1:size(ind,2)
            intensity = intensity + Iraw(coords(j,1),coords(j,2),coords(j,3)); % sum up intensities along strand
        end
        meanIntensity = intensity/size(ind,2); % mean intensity value of strand
    end
    
    startNeighbors = size(strand.StartVertexNeighborStrands,2);
    endNeighbors =  size(strand.EndVertexNeighborStrands,2);
    junctionPoints = sum(vectorizedStructure.Vertices.JunctionPoints(ind,:));
    freeEndPoints = sum(vectorizedStructure.Vertices.FreeEndPoints(ind,:));
    
    % Find Mean Distance of Strand From Edge
    if mean(x) < size(Iraw,1)/2; edgeX = mean(x) - 1; else; edgeX = size(Iraw,1) - mean(x); end;
    if mean(y) < size(Iraw,2)/2; edgeY = mean(y) - 1; else; edgeY = size(Iraw,2) - mean(y); end;
    
    table(istrand,1) = istrand; % strand
    table(istrand,2) = size(ind,2); % Strand Size
    table(istrand,3) = min(z); % top of strand
    table(istrand,4) = max(z); % bottom of strand
    table(istrand,5) = mean(z); % 
    table(istrand,6) = min(x); % left position
    table(istrand,7) = max(x); % right position
    table(istrand,8) = mean(x); % average x position
    table(istrand,9) = min(y);  
    table(istrand,10) = max(y);
    table(istrand,11) = mean(y);
    table(istrand,12) = mean(radius);
    table(istrand,13) = std(radius);
    table(istrand,14) = length; % distance from endpoint to endpoint
    table(istrand,15) = size(ind,2)/length; % tangle factor, larger means more tortuous
    table(istrand,16) = meanIntensity; % strand brightness
    table(istrand,17) = junctionPoints; % number of jxn points per strand
    table(istrand,18) = freeEndPoints; % number of free endpoints per strand
    table(istrand,19) = edgeX; % mean distance of strand from edge in x dim
    table(istrand,20) = edgeY; % mean distance of strand from edge in y dim
    table(istrand,21) = 2; %temporarily assign values in good/bad column as 2.  1 = good, 0 = bad, 2 = unknown;
    
end

%% Add column to add strand classifications




conflictingStrands = intersect(bad_strands,strandsToPlot); % identify strands that appear in both good and bad array

strandsToPlot=setxor(strandsToPlot,conflictingStrands); % remove conflicting strands from good strands
bad_strands = setxor(bad_strands,conflictingStrands); % remove conflicting strands from bad strands

for j = 1:size(strandsToPlot,2)
    [row,column] = find(table(:,1)==strandsToPlot(j)); % add a 1 to good/bad for the good strands
    table(row,size(table,2)) = 1;
end

for j = 1:size(bad_strands,2)
    [row,column] = find(table(:,1)==bad_strands(j)); % add a 0 to good/bad for the bad strands
    table(row,size(table,2)) = 0;
end

%%

i = 4 (%fifth column)
j = 275.2 (% 8th column)
k = 3.800 (% 11th column)

range = 4
[row] = find(A(:,:,5)==i-range:i+range) & find(A(:,:,8)==j-range:j+range) & find(A(:,:,11)==k-range:k+range);


max(i-range,0):min(i+range,size(Iraw,3))







