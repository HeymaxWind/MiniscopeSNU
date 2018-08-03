a = input('input any number for start this code')
close all; clc; clear;

%% Loading the video to be analyzed
file_nm = []; dir_nm = [];
[file_nm, dir_nm] = uigetfile(fullfile(dir_nm, '*.avi'));
filepath = [dir_nm, file_nm];

% filepath = [];
                                 
v = VideoReader(filepath);
frame_num = v.NumberOfFrames;

h = fspecial('average', 3);
h2 = fspecial('average', 30);

for frame = 1:frame_num
    tmpFrame = double(v.read(frame));
    msFrame(:,:,frame) = double(tmpFrame(:,:,1)); % variable containing the video to analyze
    
    col_mean = mean(msFrame(:,:,frame),1);
    offset = mean(col_mean, 2);
    
    for col = 1:size(msFrame,2)
         temp1(:, col) = (msFrame(:, col, frame) / col_mean(1, col)) * offset;
    end
    
    row_mean = mean(temp1,2);
    offset = mean(row_mean, 1);
    
    for row = 1:size(temp1,1)
         dataFrame(row, :, frame) = (temp1(row, :) / row_mean(row, 1)) * offset;
    end
end

%%
parfor frame = 1:size(msFrame,3)
    tmp1 =  filter2(h2,dataFrame(:,:,frame)) - filter2(h,dataFrame(:,:,frame)) - 1;
%     imshow(tmp1)
%     movingSignal_tmp = ((tmp1/abs(mean(mean(tmp1)))) - (dataFrame(:,:,frame)/abs(mean(mean(dataFrame(:,:,frame))))) + 0.5);
%     movingSignal_tmp(movingSignal_tmp<0.5) = 0;
    movingSignal(:,:,frame) = tmp1 > 0.5;
%     BW(:,:,frame)=imfill(movingSignal(:,:,frame),'holes');
%     BW(:,:,frame)=bwareaopen(BW(:,:,frame),70);
end
clear dataFrame
% implay((movingSignal))

%% generation of rotate_index
cnt = 0;
range = 20;
distance = -1;
roatate_index = [0 0];
while size(roatate_index,1) ~= (range*2+1)*(range*2+1)
    distance = distance+1;
    for i = -range:range
        for j = -range:range
            if (i^2 + j^2)^0.5 <= distance && (i^2 + j^2)^0.5 > distance-1
                cnt = cnt + 1;
                roatate_index(cnt,:) = [i j];
            end
        end
    end
end

%%
% fixMask = std(movingSignal,[],3) == 0;
% clear tmp1
% parfor frame = 1:size(msFrame,3)
%     tmp1 = movingSignal(:,:,frame);
%     tmp1(fixMask) = nan;
%     movingSignal_nan(:,:,frame) = tmp1;
% end

% movingSignal_nan = movingSignal;

%% erasure ROI
implay(movingSignal)
imshow(mean(movingSignal,3)*10)

for i = 1:10
    roi = getrect(); roi = ceil(roi);
    xmin = roi(1); ymin = roi(2); xmax = roi(3) + roi(1); ymax = roi(4) + roi(2);
    movingSignal(ymin:ymax, xmin:xmax, :) = 0;
end

close all

%% select ROI

% in some case, there is fixed signal such as stain on the lens 
% and it interupt alignment. Therefore see the movie 'implay(movingSignal)'
% than discrete moving and fixed signal, and choose ROI moving signal only 

implay(movingSignal)
imshow(mean(movingSignal,3)*10)
roi = getrect(); roi = ceil(roi);
xmin = roi(1); ymin = roi(2); xmax = roi(3) + roi(1); ymax = roi(4) + roi(2);
msROI = movingSignal(ymin:ymax, xmin:xmax, :);

% implay(uint8(msROI))
% implay((msROI))
close all

%% calc. differ in ROI
clear refFrame
refFrame = logical(msROI(:,:,500));
movingSignal = logical(movingSignal);
% imshow((refFrame))

for frame = 1:size(msFrame,3)
    for rix = 1:size(roatate_index,1)
        drow = roatate_index(rix,1);
        dcol = roatate_index(rix,2);
        
        diffMatrix = refFrame .* (movingSignal(ymin+drow:ymax+drow, xmin+dcol:xmax+dcol, frame));
        
%         A = refFrame;
%         B = (movingSignal_nan(ymin+drow:ymax+drow, xmin+dcol:xmax+dcol, frame));
%         C =  abs(refFrame - (movingSignal_nan(ymin+drow:ymax+drow, xmin+dcol:xmax+dcol, frame)));
% 
%         subplot(3,1,1), imshow(A)
%         subplot(3,1,2), imshow(B)
%         subplot(3,1,3), imshow(C)
%         nanmean(nanmean(C,1),2)
       

        indicator(frame,rix) = sum(sum(diffMatrix,1),2);

%     diffFrame = double(refFrame).* double(save_tmp2(ymin+drow:ymax+drow, xmin+dcol:xmax+dcol,frame));
        
    end
    
%     [vx, ix] = min(indicator(frame,:));

    [v, ix] = max(indicator(frame,:));
    aliFixInfo(frame, :) = roatate_index(ix, :);
end

%% alignment data use index

parfor frame = 1:size(msFrame,3)
    ali_frame(:,:,frame) = circshift(circshift(msFrame(:,:,frame),-aliFixInfo(frame,1),1),-aliFixInfo(frame,2),2);
end

% genearation of a video for check by human

cRow = fix(size(msFrame,1)/2);
cCol = fix(size(msFrame,2)/2);

bBox = ones(20,10);
wBox = bBox*255;

for frame = 1:size(msFrame,3)
    ForCheck(:,:,frame) = (ali_frame(:,:,frame));
    
    ForCheck(cRow-19:cRow,cCol-9:cCol,frame) = bBox;
    ForCheck(cRow-19:cRow,cCol+1:cCol+10,frame) = wBox;
    
    ForCheck(cRow/2-19:cRow/2,cCol/2-9:cCol/2,frame) = bBox;
    ForCheck(cRow/2-19:cRow/2,cCol/2+1:cCol/2+10,frame) = wBox;
    
    ForCheck(cRow*1.5-19:cRow*1.5,cCol*1.5-9:cCol*1.5,frame) = bBox;
    ForCheck(cRow*1.5-19:cRow*1.5,cCol*1.5+1:cCol*1.5+10,frame) = wBox;
    
    ForCheck(cRow*1.5-19:cRow*1.5,cCol/2-9:cCol/2,frame) = bBox;
    ForCheck(cRow*1.5-19:cRow*1.5,cCol/2+1:cCol/2+10,frame) = wBox;
    
    ForCheck(cRow/2-19:cRow/2,cCol*1.5-9:cCol*1.5,frame) = bBox;
    ForCheck(cRow/2-19:cRow/2,cCol*1.5+1:cCol*1.5+10,frame) = wBox;
    
end

implay(uint8(ForCheck))

%% df video
refFrame = mean(ali_frame,3);
for frame = 1:size(ali_frame ,3)
    diffFrame = (double(ali_frame(:,:,frame)) - refFrame)*8;
    diffFrame_save(:,:,frame) = uint8(diffFrame);
end
implay(diffFrame_save)

%% 최적화, 변수이름변경, dF 동영상 기능 추가, 함수화

filename = ['test.avi'];
ms = VideoWriter(filename);
ms.FrameRate = 30;
open(ms);
for frame = 1:size(msFrame,3)
    writeVideo(ms, uint8(ForCheck(:,:,frame)));
end
close(ms);









































