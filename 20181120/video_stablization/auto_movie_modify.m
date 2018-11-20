a = input('input any number for start this code')
close all; clc; clear;
cnt = 0;
%%
cnt = cnt +1;
% path = 'E:\MSBak\Miniscope imaging data\Data\201711_2_data\GPF201711_2_Day5_#2.2\';

file_nm = []; path = []; [file_nm, path] = uigetfile(fullfile(path, '*.avi')); filepath = [path, file_nm];
path_save{cnt,1} = path;

%%
                      
aviFileList = msCamVideoFileDetection(path, 'msCam', '.avi'); % finding msCam list
timeName = datetimeGeneretor() % load time information

%% video load
cnt1 = 0; % indexing of 'offset_save' var
for fileNum = 1:size(aviFileList,2)
    v = VideoReader(cell2mat(aviFileList(fileNum)))
    frame_num = v.NumberOfFrames;
    
%% calc mean intensity and save at 'offset_save' var
    clear tmp
    for frame = 1:frame_num
        cnt1 = cnt1 + 1;
        tmpFrame = double(v.read(frame));
        msFrame = tmpFrame(:,:,1);

        col_mean = mean(msFrame,1);
        offset = mean(col_mean, 2);
        offset_save(1, cnt1) = offset;

    end
end

%% visualization of offset_save and select threshold at mannualy

figure(1)
plot(offset_save)

thr = 90;
%% calc. start and end frame index, save at 'movie_index' var

start_sw = 1;
end_sw = 0;
index_cnt = 0;
duration_cnt = 0;
tmp_sw = 1;
for frame = 1:size(offset_save,2)
    mean_intensity = offset_save(1, frame);
    
    if mean_intensity >= thr
        if start_sw && tmp_sw
            startFrame_tmp = frame;
            tmp_sw = 0;
        end
        
        duration_cnt = duration_cnt + 1;
    end

    if duration_cnt > 30*10 && ~(end_sw)
        index_cnt = index_cnt+1;
        movie_index(index_cnt, 1) = startFrame_tmp;
        end_sw = 1;
    end
    
    if mean_intensity < 95
        duration_cnt = 0;
        tmp_sw = 1;
    end
    
    if mean_intensity < 95 && end_sw
        movie_index(index_cnt, 2) = frame;
        end_sw = 0;
        start_sw = 1;
        tmp_sw = 1;
        duration_cnt = 0;
    end    
end





