a = input('input any number for start this code')
close all; clc; clear;
file_nm = []; path = []; [file_nm, path] = uigetfile(fullfile(path, '*.mat')); filepath = [path, file_nm];

saveFileList =  msCamVideoFileDetection([path 'tracking\'] , 'cellRegistered', '.mat');
load(cell2mat(saveFileList(1,1)))

%%

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

figure(1)
imshow(footprints_save_transfer(:,:,1),[]);


figure(2)
imshow(footprints_save_transfer(:,:,2),[]);


%%
day1=footprints_save_transfer(:,:,1);
day2=footprints_save_transfer(:,:,2);
day3=footprints_save_transfer(:,:,3);
day4=footprints_save_transfer(:,:,4);

%Normalization of the pixel values
tmp1 = day1 .* (255/max(max(day1)));
tmmp1=tmp1>50;
tmp2 = day2 .* (255/max(max(day2)));
tmmp2=tmp2>50;
tmp3 = day3 .* (255/max(max(day3)));
tmmp3=tmp3>50;
tmp4 = day4 .* (255/max(max(day4)));
tmmp4=tmp4>50;


% Create empty red, green and blue channel
redChannel = zeros(size(day1,1), size(day1,2), 1);
greenChannel = zeros(size(day1,1), size(day1,2), 1);
blueChannel = zeros(size(day1,1), size(day1,2), 1);

% Choose the color of tmp-x 
redChannel1=uint8(tmp1);
greenChannel2=uint8(tmp2);
blueChannel3 =uint8(tmp3);
redChannel4=uint8(tmp4);
blueChannel4 =uint8(tmp4);
greenChannel4=uint8(tmp4);

% Combine individual masked channels into a new RGB image.
rgbi12 = cat(3, redChannel1, greenChannel2, blueChannel);
rgbi13 = cat(3, redChannel1, greenChannel, blueChannel3);
rgbi14 = cat(3, redChannel1, greenChannel4, blueChannel4);
rgbi234=cat(3, redChannel1, greenChannel2+greenChannel4, blueChannel3+blueChannel4);
figure(1),
subplot(2,3,1),imshow(rgbi12),title('Day1 and Day2');
subplot(2,3,4),imshow(tmmp1&tmmp2),title('Overlapping Day1 and Day2');

%figure(2),
subplot(2,3,2),imshow(rgbi13),title('Day1 and Day3');
subplot(2,3,5),imshow(tmmp1&tmmp3),title('Overlapping Day1 and Day3');

%figure(3),
subplot(2,3,3),imshow(rgbi14),title('Day1 and Day4');
subplot(2,3,6),imshow(tmmp1&tmmp4),title('Overlapping Day1 and Day4');