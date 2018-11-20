a = input('input any number for start this code')
close all; clc; clear;
cnt = 0;
%%
cnt = cnt +1;
% path = 'E:\MSBak\Miniscope imaging data\Data\201711_2_data\GPF201711_2_Day5_#2.2\';

file_nm = []; path = []; [file_nm, path] = uigetfile(fullfile(path, '*.avi')); filepath = [path, file_nm];
path_save{cnt,1} = path;



%%
for cnt = 1:size(path_save,1)
    clearvars -except path_save cnt
    path = cell2mat(path_save(cnt,1));
                            
aviFileList = msCamVideoFileDetection(path, 'msCam', '.avi'); % finding msCam list

ROImatFile = dir([char(path) '\ROIinfomation*.mat']); % fidning saved ROI information
try load([path '\' ROImatFile(1).name]); end % load ROI information

timeName = datetimeGeneretor() % load time information
rotate_index = rotate_index_Generator(20); % load rotate_index for calc. of alignment

h = fspecial('average', 4); % avg filter setup
h2 = fspecial('average', 50); % avg filter setup
roi_sw = 1;
fileNum = 2;
ix = 0;
%%
for fileNum = 1:size(aviFileList,2)
    v = VideoReader(cell2mat(aviFileList(fileNum)))
    frame_num = v.NumberOfFrames;
    
%% video load
clear tmp
for frame = 1:frame_num
    tmpFrame = double(v.read(frame));
    msFrame = tmpFrame(:,:,1);
    
    col_mean = mean(msFrame,1);
    offset = mean(col_mean, 2);
    
    for col = 1:size(msFrame,2)
         temp1(:, col) = (msFrame(:, col) / col_mean(1, col)) * offset;
    end
    
    row_mean = mean(temp1,2);
    offset = mean(row_mean, 1);
    
    for row = 1:size(temp1,1)
         dataFrame(row, :, frame) = (temp1(row, :) / row_mean(row, 1)) * offset;
    end
    
%     imshow(uint8(dataFrame(:, :, frame)))
    signalFrame(:,:,frame) = (filter2(h2,dataFrame(:, :, frame)) - filter2(h,dataFrame(:,:,frame))) > 0.9;
%     imshow(tmp)
%     imshow(uint8(dataFrame(:, :, frame)))
end
%% erasing blobs
% this block can be runed repeatedly and also can be canceled any time.
if fileNum == 1 && ~(size(ROImatFile,1) >= 1) && ~exist('ei', 'var')
    figure( 'Position', [900 150 800 550] )
    imshow(mean(signalFrame,3)*10)
    implay(signalFrame, 40)
    set(findall(0,'tag','spcui_scope_framework'),'position',[50 150 800 550]);

    for i = 1:1
        roi = getrect(); roi = ceil(roi);
        xmin = roi(1); ymin = roi(2); xmax = roi(3) + roi(1); ymax = roi(4) + roi(2);
        signalFrame(ymin:ymax, xmin:xmax, :) = 0;
        ix = ix+1;
        ei(ix, :) = [ymin ymax xmin xmax]; % erasing_indexSave
    end
    close all
    
else
    for ix2 = 1:size(ei,1)
        signalFrame(ei(ix2,1):ei(ix2,2),ei(ix2,3):ei(ix2,4),:) = 0;
    end
end

%% selection ROI
refFrame = signalFrame(:,:,round(frame_num/2));
if fileNum == 1 GlobalRefFrame = refFrame; end

if size(ROImatFile,1) >= 1
    if fileNum == 1; disp('1개 이상의 ROI 정보가 존재합니다. "selection ROI" session 은 실행되지 않습니다'); end
elseif roi_sw
    roi_sw = 0;
    figure( 'Position', [900 150 800 550] )
    imshow(refFrame);
    implay(signalFrame, 40)
    set(findall(0,'tag','spcui_scope_framework'),'position',[50 150 800 550]);

    roi = getrect(); roi = ceil(roi);
    xmin = roi(1); ymin = roi(2); xmax = roi(3) + roi(1); ymax = roi(4) + roi(2);

    savepath = [path '\' 'ROIinfomation_' timeName '.mat'];
    save(savepath, 'ei', 'xmin', 'ymin', 'xmax', 'ymax')
end

%% refFrame setup

for rix = 1:size(rotate_index,1)
    drow = rotate_index(rix,1);
    dcol = rotate_index(rix,2);

    try
        C_match = GlobalRefFrame(ymin:ymax, xmin:xmax) .* signalFrame(ymin+drow:ymax+drow, xmin+dcol:xmax+dcol,round(frame_num/2));
        indicator(1,rix) = sum(sum(C_match,1),2);

    catch
        indicator(1,rix) = -inf;
        disp('out of boundary')
    end
end

[vx, ix] = max(indicator(1,:));
g_ix(1, :) = rotate_index(ix, :);

%% save infomation
before_address = [path timeName ];

if (exist(before_address, 'dir') == 0)
    disp(['Made a result directory at :', newline, char(9), before_address]);
    mkdir(before_address);
end

msCam_savePath = [before_address '\msCam' num2str(fileNum) '.avi'];
msCam_save = VideoWriter(msCam_savePath);
open(msCam_save)
%%
for frame = 1:frame_num  
    for rix = 1:size(rotate_index,1)
        drow = rotate_index(rix,1);
        dcol = rotate_index(rix,2);

        try
            C_match = signalFrame(ymin:ymax, xmin:xmax, round(frame_num/2)) .* signalFrame(ymin+drow:ymax+drow, xmin+dcol:xmax+dcol, frame);
            indicator(1,rix) = sum(sum(C_match,1),2);

        catch
            indicator(1,rix) = -inf;
            disp('ROI are in the out of boundary')
        end
    end

    [vx, ix] = max(indicator(1,:));
    aliFixInfo(1, :, frame) = rotate_index(ix, :) + g_ix(1, :);
    
    tmpFrame = double(v.read(frame));
    msFrame = tmpFrame(:,:,1);
    
    ali_frame = circshift(circshift(msFrame,-aliFixInfo(1,1, frame),1),-aliFixInfo(1,2, frame),2);
    writeVideo(msCam_save, uint8(ali_frame));
    
end
close(msCam_save)
% implay(uint8(ali_frame_save))
savepath = [before_address '\ali_info_msCam' num2str(fileNum) '.mat'];
save(savepath, 'aliFixInfo')

end % msCam list 'for loop' end

%% intergration
if ~exist('path', 'var')
    disp('path')
    file_nm = []; path = []; [file_nm, path] = uigetfile(fullfile(path, '*.avi')); filepath = [path, file_nm];
end

if ~exist('before_address', 'var')
    disp('before_address')
    file_nm = []; before_address = []; [file_nm, before_address] = uigetfile(fullfile(before_address, '*.avi'));
end

% intergrated mat file save pathway setup
Analysis_Method = '201808';
[project, miceID, day, start_idx] = msbak_project_miceID_extract_from_filepath(path);
relative_address = path(1:strfind(path, '\Data'));
before_day_address = [relative_address 'Analysis\' Analysis_Method '\' project '\']; % data 저장 folder에 즉 project 이름에
% 쥐 번호를 넣는것으로 변경하기 때문에, 여기에 더이상 mice ID를 추가하지 않음 20181120 MSBak

intergrationFileList = msCamVideoFileDetection([before_address '\'], 'msCam', '.avi'); % finding msCam list
sizeInfoFileList = msCamVideoFileDetection([before_address '\'], 'msCam', '.mat'); % finding msCam list

if (exist(before_day_address, 'dir') == 0)
    disp(['Made a result directory at :', newline, char(9), before_day_address]);
    mkdir(before_day_address);
end

% calc size cut
T = 0; B = 0; L = 0; R = 0;
for aliFileNum = 1:size(sizeInfoFileList,2)
    clear aliFixInfo
    matName = cell2mat(sizeInfoFileList(1,aliFileNum));
    load(matName)
    
    tmp_max = max(aliFixInfo,[],3);
    tmp_min = min(aliFixInfo,[],3);
    
    B = max(tmp_max(1,1), B);
    R = max(tmp_max(1,2), R);
    T = min(tmp_min(1,1), T);
    L = min(tmp_min(1,2), L);
end
sizefix_info = [T B L R]; % sizefix_info (2/4)

V_savePath = [before_day_address project '_' day '_Intergrated.avi'];
V_save = VideoWriter(V_savePath);
open(V_save)

frame = 0;
for msCamNum = 1:size(intergrationFileList,2)
    v = VideoReader(cell2mat(intergrationFileList(1,msCamNum)));
    frame_num = v.NumberOfFrames; % 동영상 총 frame 갯수
    
    for i = 1:frame_num
        frame = frame+1;
        tmpFrame = uint8(v.read(i));
        tmpFrame2 = tmpFrame(:,:,1);
        
        tmpFrame3 = tmpFrame2(1-T:end-B, 1-L:end-R);
        
        tmpFrame4 = ones(480, 752);
        tmpFrame4(1-T:end-B, 1-L:end-R) = tmpFrame3;
        
        blank = ones(500, 770);
        blank(10:size(tmpFrame4,1)+10-1,10:size(tmpFrame4,2)+10-1) = tmpFrame4;
        
        Y(:,:,frame) = blank; % Y (1/4)
        
        writeVideo(V_save, uint8(Y(:,:,frame)));
    end
end
close(V_save)

Ysiz = size(Y); % Ysiz (3/4)
savename = [before_day_address project '_' day '_Intergrated.mat']; % savename (4/4)
save(savename, 'Y', 'Ysiz', 'sizefix_info', 'savename', '-v7.3');

end





























