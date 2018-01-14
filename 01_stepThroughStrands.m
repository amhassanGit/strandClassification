%% Step Through Good Strands in 2D

load st-PreThresholdVectorizedStructure.mat
load strandsToPlot.mat
load bad_Strands.mat

for i=1:2692
    Iraw(:,:,i)=imread('st.tif',i);
end;


for istrand=1:10 %size(strandsToPlot,2)
    
    strand = vectorizedStructure.Strands(strandsToPlot(istrand)); % strand info
    ind = strand.StartToEndIndices; % extract StartToEndIndices
    
    % this seems to hold the actual coordinates of the centerline
    coords=vectorizedStructure.Vertices.AllVerts(ind,:); 
    x=coords(:,1); y=coords(:,2); z=coords(:,3);
    radius=vectorizedStructure.Vertices.AllRadii(ind,:);
    
   
    % Display current strand against max intensity projection
    imagesc(max(Iraw(:,:,min(z)-3:max(z)+3),[],3)'); axis image; colormap gray
    hold on;
    plot(x,y,'r','linewidth',1.5);
    hold off;
    
    classification = 5; % initiate an out of bounds value
    prompt = 'Enter 0 for Bad Strands, 1 for Good Strands:';
    while(classification >1 || classification < 0)
        classification = input(prompt);
    end
  
    table(istrand,1) = strandsToPlot(istrand);
    table(istrand,2) = classification;
    
end

%% Step through strands in 3D

for istrand=1:10 %size(strandsToPlot,2)
    
    strand = vectorizedStructure.Strands(strandsToPlot(istrand)); % strand info
    ind = strand.StartToEndIndices; % extract StartToEndIndices
    
    % this seems to hold the actual coordinates of the centerline
    coords=vectorizedStructure.Vertices.AllVerts(ind,:); 
    x=coords(:,1); y=coords(:,2); z=coords(:,3);
    radius=vectorizedStructure.Vertices.AllRadii(ind,:);
    
    
   
    phi=linspace(0,pi,30);
    theta=linspace(0,2*pi,40);
    [phi,theta]=meshgrid(phi,theta);
    for j = 1:size(ind,2)
        a = y(j) + radius(j)*sin(phi).*cos(theta);
        b = x(j) + radius(j).*sin(phi).*sin(theta);
        c = z(j) - min(z) + radius(j).*cos(phi); 
        surf(a,b,c); hold on
    end
    hold off
%    filename = strcat(int2str(strandsToPlot(istrand)),'_',j,'.stl');
%    surf2stl(filename,a,b,c);
    
    
    
    classification = 5; % initiate an out of bounds value
    prompt = 'Enter 0 for Bad Strands, 1 for Good Strands:';
    while(classification >1 || classification < 0)
        classification = input(prompt);
    end
  
    table(istrand,1) = strandsToPlot(istrand);
    table(istrand,2) = classification;
    
end

%%

%% step through strands, save spheres as STLs and cropped subvolumes
cd /Users/hobbes/Downloads

startStrand = 1;


strand = vectorizedStructure.Strands(strandsToPlot(startStrand)); % strand info
ind = strand.StartToEndIndices; % extract StartToEndIndices
coords=vectorizedStructure.Vertices.AllVerts(ind,:); 

mkdir stl
cd stl

for istrand=startStrand:3 %size(strandsToPlot,2)
    
    strand = vectorizedStructure.Strands(strandsToPlot(istrand)); % strand info
    ind = strand.StartToEndIndices; % extract StartToEndIndices
    
    % this seems to hold the actual coordinates of the centerline
    coords=vertcat(coords,vectorizedStructure.Vertices.AllVerts(ind,:)); 
    x=coords(:,1); y=coords(:,2); z=coords(:,3);
    radius=vectorizedStructure.Vertices.AllRadii(ind,:);
   
    phi=linspace(0,pi,30);
    theta=linspace(0,2*pi,40);
    [phi,theta]=meshgrid(phi,theta);
    for j = 1:size(ind,2)
        a = y(j) + radius(j)*sin(phi).*cos(theta);
        b = x(j) + radius(j).*sin(phi).*sin(theta);
        c = z(j) - min(z) + radius(j).*cos(phi); 
        surf(a,b,c); 
        filename = strcat('strand',int2str(strandsToPlot(istrand)),'_ind',int2str(j),'.stl');
        surf2stl(filename,a,b,c);
    end
    
    if min(x)-5 < 0 
       minX = 0;
    else 
        minX = min(x)-5;
    end

    if max(x)+ 5 > size(Iraw,1)
        maxX = 0;
    else 
        maxX = max(x)+5;
    end

    if min(y)- 5 < 0 
        minY = 0;
    else 
        minY = min(y)-5;
    end

    if max(y)+ 5 > size(Iraw,2)
        maxY = 0;
    else 
        maxY = max(y)+5;
    end   

    if min(z)- 5 < 0 
        minZ = 0;
    else 
            minZ = min(z)-5;
    end

    if max(z)+ 5 > size(Iraw,3)
        maxZ = 0;
    else 
        maxZ = max(z)+5; 
    end  
    
    strandDirectory = strcat('strandSV_',int2str(strandsToPlot(istrand)));
    mkdir(strandDirectory)
    cd(strandDirectory)
    for z = minZ:maxZ 
        image = im2uint16(Iraw(minX:maxX,minY:maxY,z));
        fileName = strcat('strand_',int2str(strandsToPlot(istrand)),'_x',int2str(minY),'_y',int2str(minX),'_',int2str(z),'.tif'); % intentionally broken up 
        imwrite(image,fileName)
    end
    cd ../
        
end

cd ../

%% Step through strands in 3D using vol 3d

 %Iraw_new = zeros(size(Iraw,1),size(Iraw,2),size(Iraw,3));
Iraw_new = permute(Iraw,[2 1 3]);
   
    
for istrand=1:50 %size(strandsToPlot,2)
    
    strand = vectorizedStructure.Strands(strandsToPlot(istrand)); % strand info
    ind = strand.StartToEndIndices; % extract StartToEndIndices
    
    % this seems to hold the actual coordinates of the centerline
    coords=vectorizedStructure.Vertices.AllVerts(ind,:); 
    x=coords(:,1); y=coords(:,2); z=coords(:,3);
    radius=vectorizedStructure.Vertices.AllRadii(ind,:);
    
    %ax1=axes;
   
    phi=linspace(0,pi,30);
    theta=linspace(0,2*pi,40);
    [phi,theta]=meshgrid(phi,theta);
    for j = 1:size(ind,2)
        a = radius(j)*sin(phi).*cos(theta);
        b = radius(j).*sin(phi).*sin(theta);
        c = radius(j).*cos(phi); 
        surf(a + y(j),b + x(j), c + z(j)); hold on
    end
    
   
%     vol3d('Cdata',Iraw_new(:, :, 222:275), 'Parent',ax1); 
%     hold off;
%     
%     ax1=axes;
%     vol3d('Cdata',Iraw_new(:, :, 222:275), 'Parent',ax1); 
%     hold off;
%     
%     
%     
%     classification = 5; % initiate an out of bounds value
%     prompt = 'Enter 0 for Bad Strands, 1 for Good Strands:';
%     while(classification >1 || classification < 0)
%         classification = input(prompt);
%     end
%   
%     table(istrand,1) = strandsToPlot(istrand);
%     table(istrand,2) = classification;
    
end

%% step through strands, save lines as tiffs and cropped subvolumes

lines = zeros(size(Iraw));

startStrand = 1;


strand = vectorizedStructure.Strands(strandsToPlot(startStrand)); % strand info
ind = strand.StartToEndIndices; % extract StartToEndIndices
coords=vectorizedStructure.Vertices.AllVerts(ind,:); 


for istrand=startStrand:size(strandsToPlot,2)
    
    strand = vectorizedStructure.Strands(strandsToPlot(istrand)); % strand info
    ind = strand.StartToEndIndices; % extract StartToEndIndices
    
    % this seems to hold the actual coordinates of the centerline
    coords=vertcat(coords,vectorizedStructure.Vertices.AllVerts(ind,:)); 
    x=coords(:,1); y=coords(:,2); z=coords(:,3);
    radius=vectorizedStructure.Vertices.AllRadii(ind,:);
          
end

for i = 1:size(coords,1)
    lines(coords(i,1),coords(i,2),coords(i,3)) = 1;
end 

for z = minZ:maxZ 
    image = im2uint16(Iraw(minX:maxX,minY:maxY,z));
    fileName = strcat('strand_',int2str(strandsToPlot(istrand)),'_x',int2str(minY),'_y',int2str(minX),'_',int2str(z),'.tif'); % intentionally broken up 
    imwrite(image,fileName)
end

%% method 1 to create spheres

r = [5,2,7];
a = [10 15 20];
b = [10 15 20];
c = [10 15 20];

phi=linspace(0,pi,30);
theta=linspace(0,2*pi,40);
[phi,theta]=meshgrid(phi,theta);
for i = 1:3
    x = a(i) + r(i)*sin(phi).*cos(theta);
    y = b(i) + r(i).*sin(phi).*sin(theta);
    z = c(i) + r(i).*cos(phi); 
    surf(x,y,z); hold on
end
hold off


%% method 2 to create spheres

a = 10; b = 10; c = 10;

[x,y,z] = sphere(50);
x = x + a;
y = y + b;
z = z + c;
surf(x,y,z); % where (a,b,c) is center of the sphere


