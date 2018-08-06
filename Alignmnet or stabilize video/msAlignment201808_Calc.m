function msAlignment201808(aviFileList, path, timeName )

ROImatFile = dir([char(path) '\ROIinfomation*.mat']);
load([path '\' ROImatFile(1).name]);

h = fspecial('average', 3);
h2 = fspecial('average', 30);

roatate_index = rotate_index_Generator(20);

% variables for generating check frame
v = VideoReader(cell2mat(aviFileList(1)));
cRow = fix(v.Height/2);
cCol = fix(v.Width/2);
bBox = ones(20,10);
wBox = bBox*255;

% variable for save
filename_check = [path '\' 'ForCheck_' timeName  '.avi'];
ms_check = VideoWriter(filename_check);
ms_check.FrameRate = 30;
open(ms_check)

filename_ail = [path '\' 'Alignmented_' timeName  '.avi'];
ms_ali = VideoWriter(filename_ail);
ms_ali.FrameRate = 30;
open(ms_ali)


%% Loading the video to be analyzed

frame = 0; % for indexing
for fileNum = 1:size(aviFileList,2)
    v = VideoReader(cell2mat(aviFileList(fileNum)));
    frame_num = v.NumberOfFrames;
    
    % 먼저 file 한개 전부 읽어서 msFrame_tmp에 저장하고.
    clear msFrame_tmp
    for page = 1:frame_num
        tmpFrame = double(v.read(page));
        msFrame_tmp(:,:,page) = double(tmpFrame(:,:,1));
    end
    
    % 평균값 구한뒤 df 찾은 다음 compFrame으로 변환
    clear compFrame
    meanFrame = mean(msFrame_tmp,3);
    for page = 1:frame_num
        dfFrame = msFrame_tmp(:,:,page) - meanFrame;
        dfMask = dfFrame>5;
        compFrame(:,:,page) = (msFrame_tmp(:,:,page) .* imcomplement(dfMask)) + (meanFrame .* dfMask);
%         imshow(uint8(compFrame(:,:,frame)))
    end
    clear msFrame_tmp
    
    %%
    % refFrame을 fileNum 마다 새롭게 만들고
    movingSignal_refSave(:,:,fileNum) = readFrame(compFrame(:,:,fix(frame_num/2)), h, h2);
    for ix2 = 1:size(ei,1)
            movingSignal_refSave(ei(ix2,1):ei(ix2,2),ei(ix2,3):ei(ix2,4),fileNum) = 0;
    end
    
    refFrame = movingSignal_refSave(ymin:ymax, xmin:xmax, fileNum);
    refFrame_refSave(:,:,fileNum) = refFrame;
    
    % refFrame끼리의 보정값 계산
    % globalRefFrame은 1번 ref로 지정
    
    for rix = 1:size(roatate_index,1)
            drow = roatate_index(rix,1);
            dcol = roatate_index(rix,2);

            diffMatrix = refFrame_refSave(:,:,1) .* (movingSignal_refSave(ymin+drow:ymax+drow, xmin+dcol:xmax+dcol,fileNum));
            indicator(1,rix) = sum(sum(diffMatrix,1),2);
    end
    
    [vx, ix] = max(indicator(1,:));
    ad(1, :) = roatate_index(ix, :); % refFrame 간의 보정 값
    
    %%
    
    for i = 1:frame_num
        frame = frame + 1;
%         tmpFrame = double(v.read(i));
%         msFrame = tmpFrame(:,:,1);
        msFrame = compFrame(:,:,i);
        movingSignal = readFrame(msFrame, h, h2);
        
       %% erasing blobs
        for ix2 = 1:size(ei,1)
            movingSignal(ei(ix2,1):ei(ix2,2),ei(ix2,3):ei(ix2,4)) = 0;
        end
        
        %% calc the best match
        
        for rix = 1:size(roatate_index,1)
            drow = roatate_index(rix,1);
            dcol = roatate_index(rix,2);

            diffMatrix = refFrame .* (movingSignal(ymin+drow:ymax+drow, xmin+dcol:xmax+dcol));
            indicator(1,rix) = sum(sum(diffMatrix,1),2);
%             imshow(diffMatrix)
        end
        
%         drow = 0; dcol = 0;
%         
%         A = refFrame ;
%         B = (movingSignal(ymin+drow:ymax+drow, xmin+dcol:xmax+dcol));
%         C = refFrame .* (movingSignal(ymin+drow:ymax+drow, xmin+dcol:xmax+dcol));
% 
%         subplot(3,1,1), imshow(A)
%         subplot(3,1,2), imshow(B)
%         subplot(3,1,3), imshow(C)
%         sum(sum(diffMatrix,1),2);

        [vx, ix] = max(indicator(1,:));
        aliFixInfo(1, :, frame) = roatate_index(ix, :);
        aliFixInfo(1, :, frame) = aliFixInfo(1, :, frame) + ad(1, :);
        
        tmpFrame = double(v.read(i));
        msFrame = tmpFrame(:,:,1);
        
        ali_frame = circshift(circshift(msFrame,-aliFixInfo(1,1, frame),1),-aliFixInfo(1,2, frame),2);
        ForCheck = forCheck(ali_frame, cRow, cCol, bBox, wBox);
        
        writeVideo(ms_ali, uint8(ali_frame));
        writeVideo(ms_check, uint8(ForCheck));
        
%          imshow(ForCheck)
    end
    fileNum
end

close(ms_check)
close(ms_ali)

%% sizeFix info calc.
L = max(reshape(aliFixInfo(1,1,:), 1, frame));
R = min(reshape(aliFixInfo(1,1,:), 1, frame));
T = max(reshape(aliFixInfo(1,2,:), 1, frame));
B = min(reshape(aliFixInfo(1,2,:), 1, frame));


%% preparing save variables

v = VideoReader(filename_ail);
frame_num = v.NumberOfFrames; % 동영상 총 frame 갯수
parfor frame = 1:frame_num
    tmpFrame = double(v.read(frame));
    Y(:,:,frame) = tmpFrame(1+L:end+R,1+T:end+B,1); % Y (1/4)
end
sizefix_info = [T B L R]; % sizefix_info (2/4)
Ysiz = size(Y); % Ysiz (3/4)
%%
Analysis_Method = '201808';
[project, miceID, day, start_idx] = msbak_project_miceID_extract_from_filepath(path);
relative_address = path(1:strfind(path, '\Data'));
before_day_address = [relative_address 'Analysis\' Analysis_Method '\' project '_' miceID '\'];

if (exist(before_day_address, 'dir') == 0)
    disp(['Made a result directory at :', newline, char(9), before_day_address]);
    mkdir(before_day_address);
end

savename = [before_day_address project '_' miceID '_' day '_Intergrated.mat']; % savename (4/4)

save(savename, 'Y', 'Ysiz', 'sizefix_info', 'savename', '-v7.3');








