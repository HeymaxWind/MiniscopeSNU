a = input('input any number for start this code')
close all; clc; clear;

%% Selection the pathway which saved miniscope data

path = uigetdir('','Select Directory of Your Experiment'); 

aviFileList = msCamVideoFileDetection(path, 'msCam');
timeName = datetimeGeneretor();

filepath = cell2mat(aviFileList(1,1));
v = VideoReader(filepath);
frame_num = v.NumberOfFrames;

h = fspecial('average', 3);
h2 = fspecial('average', 30);


%% Loading the video to be analyzed
for frame = 1:frame_num
    tmpFrame = double(v.read(frame));
    msFrame(:,:,frame) = double(tmpFrame(:,:,1));
end

%%
meanFrame = mean(msFrame,3);
for frame = 1:frame_num
    dfFrame = msFrame(:,:,frame) - meanFrame;
    dfMask = dfFrame>2;
    compFrame(:,:,frame) = (msFrame(:,:,frame) .* imcomplement(dfMask)) + (meanFrame .* dfMask);
end

%%
frame = 0;
for i = 1:frame_num
    frame = frame + 1;
%     tmpFrame = double(v.read(frame));
%     msFrame = double(tmpFrame(:,:,1)); % variable containing the video to analyze

    msFrame = compFrame(:,:,frame);
    
    col_mean = mean(msFrame,1);
    offset = mean(col_mean, 2);
    
    for col = 1:size(msFrame,2)
         temp1(:, col) = (msFrame(:, col) / col_mean(1, col)) * offset;
    end
    
    row_mean = mean(temp1,2);
    offset = mean(row_mean, 1);
    
    for row = 1:size(temp1,1)
         dataFrame(row, :) = (temp1(row, :) / row_mean(row, 1)) * offset;
    end
    
    tmp1 =  filter2(h2,dataFrame) - filter2(h,dataFrame) - 1;
    movingSignal(:,:,frame) = tmp1 > 0.5;
end
ix = 0;
%% erasing blobs
% this block can be runed repeatedly and also can be canceled any time.

figure( 'Position', [900 150 800 550] )
imshow(mean(movingSignal,3)*10)
implay(movingSignal, 40)
set(findall(0,'tag','spcui_scope_framework'),'position',[50 150 800 550]);

for i = 1:10
    roi = getrect(); roi = ceil(roi);
    xmin = roi(1); ymin = roi(2); xmax = roi(3) + roi(1); ymax = roi(4) + roi(2);
    movingSignal(ymin:ymax, xmin:xmax, :) = 0;
    ix = ix+1;
    ei(ix, :) = [ymin ymax xmin xmax]; % erasing_indexSave
end
close all

%% selecting ROI

% in some case, there is fixed signal such as stain on the lens 
% and it interupt alignment. Therefore see the movie 'implay(movingSignal)'
% than discrete moving and fixed signal, and choose ROI moving signal only 

figure( 'Position', [900 150 800 550] )
imshow(mean(movingSignal,3)*10)

implay(movingSignal, 40)
set(findall(0,'tag','spcui_scope_framework'),'position',[50 150 800 550]);

roi = getrect(); roi = ceil(roi);
xmin = roi(1); ymin = roi(2); xmax = roi(3) + roi(1); ymax = roi(4) + roi(2);

% implay(uint8(msROI))
% implay((msROI))
close all

savepath = [path '\' 'ROIinfomation_' timeName '.mat'];
save(savepath, 'ei', 'xmin', 'ymin', 'xmax', 'ymax')




































