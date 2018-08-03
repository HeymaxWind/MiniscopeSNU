a = input('Input any  number to start this code')
close all; clc; clear;

%% Loading the video to be analyzed
file_nm = []; dir_nm = [];
[file_nm, dir_nm] = uigetfile(fullfile(dir_nm, '*.avi'));
filepath = [dir_nm, file_nm];

v = VideoReader(filepath);
frame_num = v.NumberOfFrames;

parfor frameNum = 1:frame_num
    frame = double(v.read(frameNum));
    msFrame(:,:,frameNum) = uint8(frame(:,:,1)); %variable containing the video to analyze
end

%% Definition of ROI

frameNum = 500; % frame on which choosing ROI
frame = double(v.read(frameNum));
imshow(uint8(frame(:,:,1)))
roi = getrect(); roi = ceil(roi); %selection by user of ROI
xmin = roi(1); ymin = roi(2); xmax = roi(3) + roi(1); ymax = roi(4) + roi(2);

%creation of mask according to ROI selected
mask=zeros(size(frame,1),size(frame,2));
for i=xmin:xmax
    for j=ymin:ymax
        mask(j,i)=1;
    end
end

close all

%% Creation of ROI with white borders
%background is defined in white in order to avoid background detection on future segmentation
white_border = (255 .* imcomplement(mask));
for frame = 1:size(msFrame,3)
    other0 = (double(msFrame(:,:,frame)) .* mask) + white_border;
    other0_save(:,:,frame) = uint8(other0);
end

%% Thresholding to discriminate mouse body from background
refFrame=msFrame(:,:,1)<45;

parfor frame=1:size(msFrame,3)
    other1(:,:,frame)=(other0_save(:,:,frame)<45)-refFrame; %thresholding 
    other2(:,:,frame)=bwareaopen(other1(:,:,frame),600); %erase of blobs under 600 pixels
end

%% Enhancement of binary object to avoid wire detection/issues
se2=strel('disk',15);
parfor frame=1:size(other1,3)
    %other3(:,:,frame)=imfill(other1(:,:,frame),'holes');
    other4(:,:,frame)=imclose(other2(:,:,frame),se2);
end

%% properties about regions detected
centers=ones(size(msFrame,3),2);
areas=ones(size(msFrame,3),1);

%center and area detection of blobs for each frame of the video
for frame=1:size(msFrame,3)
    stats=regionprops(other4(:,:,frame),'Centroid','Area');
    if size(stats,1)~=0
        for k=1:length(stats)
            xcenters(frame,k)=stats(k).Centroid(1);
            ycenters(frame,k)=stats(k).Centroid(2);
            centers=uint16(centers);
            areas(frame)=stats.Area;
        end
    end
end

%filling of center values not detected
xcenters_filled=filloutliers(xcenters,'linear','movmedian',50,1);
ycenters_filled=filloutliers(ycenters,'linear','movmedian',50,1);

%smoothing of center coordinates, preventing fluctuation
 for k=1:3
centers(:,1)=smooth(single(xcenters_filled));
centers(:,2)=smooth(single(ycenters_filled));    
 end
%% display white cross on center detected
output=msFrame;

for frame=1:size(other4,3)
  if centers(frame,1)>0&centers(frame,2)>0
    output(centers(frame,2),centers(frame,1),frame)=255;
    output(centers(frame,2)+1,centers(frame,1),frame)=255;
    output(centers(frame,2),centers(frame,1)+1,frame)=255;
  end
  if centers(frame,1)>1&centers(frame,2)>0
      output(centers(frame,2)-1,centers(frame,1),frame)=255;
  end
  if centers(frame,2)>1&centers(frame,1)>0
    output(centers(frame,2),centers(frame,1)-1,frame)=255;
  end
end

%% output movie
clc
filename = ['D:\GPF201802_3\6_8_2018\H9_M53_S16\PositionDetection2.avi'];
ms = VideoWriter(filename);
ms.FrameRate = v.FrameRate; 
open(ms);
for page = 1:size(output,3)
    writeVideo(ms,output(:,:,page));
end
close(ms);
save('D:\GPF201802_3\6_8_2018\H9_M53_S16\Centers2.mat','centers','other4');

%% Display the path detected
start=1;
for frame=1:size(centers,1)
    if centers(frame,1)==1
        start=start+1;
    end
    c(frame)=size(output,2)-centers(frame,2);
end

figure,plot(centers(start+100:end,1),c(start+100:end));
