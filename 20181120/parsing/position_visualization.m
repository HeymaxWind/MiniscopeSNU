
a = input('input any number for start this code')
close all; clc; clear;
file_nm = []; path = []; [file_nm, path] = uigetfile(fullfile(path, '*.mat')); filepath = [path, file_nm];

saveFileList =  msCamVideoFileDetection([path 'tracking\'] , 'cellRegistered', '.mat');
load(cell2mat(saveFileList(1,1)))


%% data size 측정한 뒤, footprints_save_transfer에 row x col x days 로 재배열 하여 저장

rowSize = size(cell2mat(cell_registered_struct.spatial_footprints_corrected(1,1)),2);
colSize = size(cell2mat(cell_registered_struct.spatial_footprints_corrected(1,1)),3);
days = size(cell_registered_struct.centroid_locations_corrected,1);

footprints_save_transfer = zeros(rowSize, colSize, days);

for day = 1:size(cell_registered_struct.spatial_footprints_corrected,1)
    clear footprints_save
    footprints_save(:,:,:) = cell2mat(cell_registered_struct.spatial_footprints_corrected(day,1));
    
    for neuronNum = 1:size(footprints_save,1)
        footprints_save_transfer(:,:,day) = footprints_save_transfer(:,:,day) + reshape(footprints_save(neuronNum,:,:),size(footprints_save,2),size(footprints_save,3));
        
    end
end

%% 0~255로 nmr

for day = 1:size(footprints_save_transfer,3)
    tmp = footprints_save_transfer(:,:,day);
    footprints_save_transfer_nmr(:,:,day) = tmp .* (255/max(max(tmp)));
end

% implay(uint8(footprints_save_transfer_nmr))

%%
% Create empty red, green and blue channel

day12 = mergeGenerator(footprints_save_transfer_nmr(:,:,1), footprints_save_transfer_nmr(:,:,2));
day13 = mergeGenerator(footprints_save_transfer_nmr(:,:,1), footprints_save_transfer_nmr(:,:,3));
day25 = mergeGenerator(footprints_save_transfer_nmr(:,:,1), footprints_save_transfer_nmr(:,:,4));

%%
figure(1)
subplot(1,3,1), imshow(day12),title('Day1 and Day2');

subplot(1,3,2), imshow(day13),title('Day1 and Day3');

subplot(1,3,3), imshow(day25),title('Day1 and Day4');



















