%% 그냥 기존정보로 alignment 하도록 수정 할것

a = input('input any number for start this code')
close all; clc; clear;
file_nm = []; path = []; [file_nm, path] = uigetfile(fullfile(path, '*.mat')); filepath = [path, file_nm];

matFileList = msCamVideoFileDetection([path 'tracking\'] , 'footprints', '.mat'); % finding msCam list
aviFileList = msCamVideoFileDetection(path, 'Intergrated', '.avi'); % finding msCam list

saveFileList =  msCamVideoFileDetection([path 'tracking\'] , 'cellRegistered', '.mat');
load(cell2mat(saveFileList(1,1)))
%%
clear cpPoint
for matFileNum = 1:size(matFileList,2)
    load([cell2mat(matFileList(1,matFileNum))])

    for nueronNum = 1:size(allFiltersMat,1)
        neuronalSignal = reshape(allFiltersMat(nueronNum,:,:),size(allFiltersMat,2),size(allFiltersMat,3));
        s = regionprops(neuronalSignal>0, 'centroid');
        cpPoint(matFileNum,nueronNum,:) = [s.Centroid(1,2), s.Centroid(1,1)];
    end
end

%%
itg_idx = cell_registered_struct.cell_to_index_map;
cnt2 = 0;
for A = 1:size(cpPoint,1)
    for B = 1:size(cpPoint,1)
        cnt = 0; 
        sum_tmp = [0 0];
        for sigNum =  1:size(itg_idx,1)
            if (itg_idx(sigNum,A) ~= 0) && (itg_idx(sigNum,B) ~= 0)
                cnt2 = cnt2 +1;
                between_ix = reshape(cpPoint(A, itg_idx(sigNum,A), :) - cpPoint(B, itg_idx(sigNum,B), :),1,2);
                save_log(cnt2, :) = [A, B, itg_idx(sigNum,A), itg_idx(sigNum,B), between_ix];
                sum_tmp = sum_tmp + between_ix;
                cnt = cnt + 1;
            end
        end
        correction_ix{A,B} = sum_tmp .* (1/cnt);
    end
end

%%
h = fspecial('average', 4); % avg filter setup
h2 = fspecial('average', 50); % avg filter setup

for i = 1:size(aviFileList,2)
    msFrame = ones(500, 800);
    v = VideoReader(cell2mat(aviFileList(1,i)));
    tmp = double(v.read(500));
    msFrame(1:size(tmp,1),1:size(tmp,2)) = tmp(:,:,1);
    
    msFrame_save(:,:,i) = msFrame;
   
    col_mean = mean(msFrame,1);
    offset = mean(col_mean, 2);
    
    for col = 1:size(msFrame,2)
         temp1(:, col) = (msFrame(:, col) / col_mean(1, col)) * offset;
    end
    
    row_mean = mean(temp1,2);
    offset = mean(row_mean, 1);
    
    for row = 1:size(temp1,1)
         dataFrame(row,:) = (temp1(row, :) / row_mean(row, 1)) * offset;
    end
    
    signalFrame(:,:,i) = (filter2(h2,dataFrame) - filter2(h,dataFrame)) > 0.8;
    
end

%%
figure(1)
cnt = 1;
for day = 2:size(aviFileList,2)
    
    ali_ix = round(cell2mat(correction_ix(1,day)));

    signalFrame_unfixed(:,:,3) = zeros(size(signalFrame,1),size(signalFrame,2));
    signalFrame_unfixed(:,:,2) = circshift(circshift(signalFrame(:,:,day),0,1),0,2) .* 255;
    signalFrame_unfixed(:,:,1) = circshift(circshift(signalFrame(:,:,1),0,1),0,2) .* 255;

    signalFrame_fixed(:,:,3) = zeros(size(signalFrame,1),size(signalFrame,2));
    signalFrame_fixed(:,:,2) = circshift(circshift(signalFrame(:,:,day),ali_ix(1,1),1),ali_ix(1,2),2) .* 255;
    signalFrame_fixed(:,:,1) = circshift(circshift(signalFrame(:,:,1),0,1),0,2) .* 255;

    subplot(size(aviFileList,2)-1,2,cnt)
    cnt = cnt+1;
    imshow(uint8(signalFrame_unfixed))
    subplot(size(aviFileList,2)-1,2,cnt)
    cnt = cnt+1;
    imshow(uint8(signalFrame_fixed))
    
%     end
end

%%































