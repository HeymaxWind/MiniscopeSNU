
a = input('input any number for start this code')
close all; clc; clear;

file_nm = []; path = []; [file_nm, path] = uigetfile(fullfile(path, '*.avi')); filepath = [path, file_nm];
                            
aviFileList = msCamVideoFileDetection(path, 'msCam', '.avi'); % finding msCam list

ROImatFile = dir([char(path) '\ROIinfomation*.mat']); % fidning saved ROI information
try load([path '\' ROImatFile(1).name]); end % load ROI information

timeName = datetimeGeneretor() % load time information
rotate_index = rotate_index_Generator(20); % load rotate_index for calc. of alignment

h = fspecial('average', 4); % avg filter setup
h2 = fspecial('average', 40); % avg filter setup

fileNum = 2;
%%
for fileNum = 1:size(aviFileList,2)
    v = VideoReader(cell2mat(aviFileList(fileNum)))
    frame_num = v.NumberOfFrames;
    
%% video load

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
end



% calc. background
meanFrame = filter2(h2,mean(dataFrame,3));
% imshow(uint8(meanFrame))

% make signalFrame
frame_intensity = sum(sum(dataFrame,1),2);
frame_intensity = reshape(frame_intensity, 1, size(frame_intensity, 3));
mean_intensity = mean(frame_intensity,2);
%%
for frame = 1:frame_num
    tmp = (meanFrame - (filter2(h,dataFrame(:,:,frame)*mean_intensity/frame_intensity(1,frame)))) > 1.2;
    signalFrame(:,:,frame) = tmp;
%     imshow(tmp)
end
% clear dataFrame
%% refFrame setup

refFrame = signalFrame(:,:,500);
if fileNum == 1 GlobalRefFrame = refFrame; end

for rix = 1:size(rotate_index,1)
    drow = rotate_index(rix,1);
    dcol = rotate_index(rix,2);

    try
        C_match = GlobalRefFrame(ymin:ymax, xmin:xmax) .* refFrame(ymin+drow:ymax+drow, xmin+dcol:xmax+dcol);
        indicator(1,rix) = sum(sum(C_match,1),2);

    catch
        indicator(1,rix) = -inf;
        disp('out of boundary')
    end
end

[vx, ix] = max(indicator(1,:));
g_ix(1, :) = rotate_index(ix, :);


%% selection ROI
if size(ROImatFile,1) >= 1
    if fileNum == 1; disp('1개 이상의 ROI 정보가 존재합니다. "selection ROI" session 은 실행되지 않습니다'); end
else
    figure( 'Position', [900 150 800 550] )
    imshow(refFrame);
    implay(signalFrame, 40)
    set(findall(0,'tag','spcui_scope_framework'),'position',[50 150 800 550]);

    roi = getrect(); roi = ceil(roi);
    xmin = roi(1); ymin = roi(2); xmax = roi(3) + roi(1); ymax = roi(4) + roi(2);

    savepath = [path '\' 'ROIinfomation_' timeName '.mat'];
    save(savepath, 'xmin', 'ymin', 'xmax', 'ymax')
end

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
            C_match = refFrame(ymin:ymax, xmin:xmax) .* signalFrame(ymin+drow:ymax+drow, xmin+dcol:xmax+dcol, frame);
            indicator(1,rix) = sum(sum(C_match,1),2);

        catch
            indicator(1,rix) = -inf;
            disp('out of boundary')
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
path = 'E:\MSBak\Miniscope imaging data\Data\201806\GFP201806_20180807_Training\GPF201806_Day1_#3.2\';
before_address = 'E:\MSBak\Miniscope imaging data\Data\201806\GFP201806_20180807_Training\GPF201806_Day1_#3.2\20180812011825';

%%
intergrationFileList = msCamVideoFileDetection([before_address '\'], 'msCam', '.avi'); % finding msCam list
sizeInfoFileList = msCamVideoFileDetection([before_address '\'], 'msCam', '.mat'); % finding msCam list

% intergrated mat file save pathway setup
Analysis_Method = '201808';
[project, miceID, day, start_idx] = msbak_project_miceID_extract_from_filepath(path);
relative_address = path(1:strfind(path, '\Data'));
before_day_address = [relative_address 'Analysis\' Analysis_Method '\' project '_' miceID '\'];

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
    
    T = max(tmp_max(1,1), T);
    L = max(tmp_max(1,2), R);
    B = min(tmp_min(1,1), B);
    R = min(tmp_min(1,2), L);
end
sizefix_info = [T B L R]; % sizefix_info (2/4)

V_savePath = [before_day_address project '_' miceID '_' day '_Intergrated.avi'];
V_save = VideoWriter(V_savePath);
open(V_save)

frame = 0;
for msCamNum = 1:size(intergrationFileList,2)
    v = VideoReader(cell2mat(intergrationFileList(1,msCamNum)));
    frame_num = v.NumberOfFrames; % 동영상 총 frame 갯수
    
    for i = 1:frame_num
        frame = frame+1;
        tmpFrame = uint8(v.read(i));
        Y(:,:,frame) = tmpFrame(1+L:end+R,1+T:end+B,1); % Y (1/4)
        
        writeVideo(V_save, Y(:,:,frame));
    end
end
close(V_save)

Ysiz = size(Y); % Ysiz (3/4)
savename = [before_day_address project '_' miceID '_' day '_Intergrated.mat']; % savename (4/4)
save(savename, 'Y', 'Ysiz', 'sizefix_info', 'savename', '-v7.3');































