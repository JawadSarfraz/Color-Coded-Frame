
%read video into array of concatenated images
concatenatedImages = readAerobicsData();
%width and height of one frame
width = 240;
height = 320;

%define threshold
threshold = 0.23;

%linear decay term
decay = 5;

%set initial frame as background
background = concatenatedImages(1:height,1:width);

output = zeros(height,width);
%Each frame process one by one
for i=1:(size(concatenatedImages,2)/width)-1    
    %Get frame
    getFrame = concatenatedImages(1:height,i*width+1:i*width+width);

    %find difference from previous frame
    difference = abs(getFrame-background);
    difference = difference/max(max(difference));

    %apply threshold
    threshold = im2bw(difference,threshold);
    
    temp = max(output-decay,0);
    output = max(255*threshold,temp);
    
    %update background with current frame
    background = getFrame;
end
figure; imshow(output,[]);

%smooth output image by applying gaussian filter
kernel = fspecial('gaussian',[7,7],1);
output = imfilter(output,kernel,'conv');
%find gradient in both directions
dx = [1,0,-1];
dy = [1,0,-1]';
outputX = imfilter(output, dx, 'conv');
outputY = imfilter(output, dy, 'conv');
[outputM,outputD] = imgradient(output);

outputOfResult = zeros(height,width,3);
for i=1:height
   for j=1:width
       if outputM(i,j) > 0
            if outputX(i,j)>0 && outputY(i,j)>0
                if(outputX(i,j)>outputY(i,j))
                    outputOfResult(i,j,1) = 1;
                else
                    outputOfResult(i,j,3) = 1;
                end
            elseif outputX(i,j)<0 && outputY(i,j)>0
                if(abs(outputX(i,j))>outputY(i,j))
                    outputOfResult(i,j,2) = 1;
                else
                    outputOfResult(i,j,3) = 1;
                end
            elseif outputX(i,j)<0 && outputY(i,j)<0
                if(abs(outputX(i,j))>abs(outputY(i,j)))
                    outputOfResult(i,j,2) = 1;
                else
                    outputOfResult(i,j,1) = 1;
                    outputOfResult(i,j,2) = 1;
                end
            else
                if(outputX(i,j)>abs(outputY(i,j)))
                    outputOfResult(i,j,1) = 1;
                else
                    outputOfResult(i,j,1) = 1;
                    outputOfResult(i,j,2) = 1;                    
                end
            end
       end
   end
end
figure; imshow(outputOfResult,[]);