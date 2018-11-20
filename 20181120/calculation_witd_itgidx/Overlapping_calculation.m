a = input('input any number for start this code')
close all; clc; clear;
file_nm = []; path = []; [file_nm, path] = uigetfile(fullfile(path, '*.mat')); filepath = [path, file_nm];

saveFileList =  msCamVideoFileDetection([path 'tracking\'] , 'cellRegistered', '.mat');
load(cell2mat(saveFileList(1,1)))
%%

itg_idx = cell_registered_struct.cell_to_index_map;
itd_idx_activity = itg_idx>0;
        
%% signal

MatrixList =  msCamVideoFileDetection(path , '_SignalMatrix', '.mat');

for dayNum = 1:size(MatrixList,2)
    clear msPeak_signal
    load(cell2mat(MatrixList(1,dayNum)))
    sortedSignal(dayNum, 1:size(msPeak_signal,1), 1:size(msPeak_signal,2)) = msPeak_signal;
end

try load([path 'FrameLimit.mat']);
catch
    disp("No frame information")
    return
    FrameLimit = []
save([path_forFrameLimit 'FrameLimit.mat'], 'FrameLimit')
end

for dayNum = 1:size(itg_idx,2)
    for neuronNum = 1:size(itg_idx,1)
        value = itg_idx(neuronNum, dayNum);
        if value ~= 0
            itg_idx_signal(neuronNum, dayNum) = sum(sortedSignal(dayNum, value, FrameLimit(dayNum,1):FrameLimit(dayNum,2)),3);
        
        elseif value == 0
            itg_idx_signal(neuronNum, dayNum)  = 0;
        end
    end
end

% signal
for A = 1:size(itg_idx,2)
    for B = 1:size(itg_idx,2)
        overlap_cnt = 0;
        for row = 1:size(itg_idx,1)
            if itg_idx_signal(row,B) > 0 && itg_idx_signal(row,A) > 0
                overlap_cnt = overlap_cnt + itg_idx_signal(row,B);
            end
        end

        Overapping_signalNum(A,B) = overlap_cnt;
    end
end

%% nueron Num
for A = 1:size(itg_idx,2)
    for B = 1:size(itg_idx,2)
        nueron_cnt = 0;
        for row = 1:size(itg_idx,1) 
            if itg_idx_signal(row,B) > 0 && itg_idx_signal(row,A) > 0
                nueron_cnt = nueron_cnt + 1;
            end
        end

        Overapping_neuronNum(A,B) = nueron_cnt;
    end
end

%% engram: training and test in CtxA overlapping

% calc. overlapping idx

for row = 1:size(itg_idx_signal,1)
    if itg_idx_signal(row,1) > 0 && itg_idx_signal(row,2) > 0
        overlapping_engram(row,1) = 1;
    else
        overlapping_engram(row,1) = 0;
    end
end

for A = 1:size(itg_idx_signal,2)
    for B = 1:size(itg_idx_signal,2)
        nueron_cnt = 0;
        for row = 1:size(itg_idx_signal,1)
            if overlapping_engram(row,1) && itg_idx_signal(row,B)
                nueron_cnt = nueron_cnt + 1;
            end
        end
        
        overlapping_engram_neuron(A,B) = nueron_cnt;
    end
end
           
                



















































