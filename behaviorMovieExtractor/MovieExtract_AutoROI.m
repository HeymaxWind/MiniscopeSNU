% 20180623 MSBak
% I modfied this code more efficiently

a = input('시작하려면 숫자입력')
close all; clc; clear;


% please input freme information !! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
startFrame = 1001; % input the start frame number
endFrame = 9036; % input the end frame number
% 40 for FPS of movie which recored in lonovo laptop
% 3 for minutes (for test session, mice exposed to context in 3 mins as protocol)
% 60, constant number min to second
filename = ['GPF201806_Day1_#3.2.mp4']; % input save location pathway for extracted movie

%% import movie

% file_nm = []; dir_nm = [];
% [file_nm, dir_nm] = uigetfile(fullfile(dir_nm, '*.mp4'));
% filepath = [dir_nm, file_nm];

% filepath = '?E:\MSBak\Miniscope imaging data\Data\201802_3\6_9_2018\H11_M21_S32\GPF201802_Day4_#3.2.mp4';
% filepath = 'E:\MSBak\Miniscope imaging data\Data\201802_3\6_8_2018\H9_M10_S10\GPF201802_Day3_#3.1.mp4'; % ctx B
% 1107

filepath = 'E:\MSBak\Miniscope imaging data\Data\201806\GPF201806_Day1_#3.2\GPF201806_Day1_#3.2.mp4'; % ctx A'
% 2476

v = VideoReader(filepath);
frame_num = v.NumberOfFrames;
%a=double(v.read(5000));
%imwrite(uint8(a),'capture.jpg');

%% auto ROI detection
frameNum = 3000; % snap shot 찍을 frame 선택
frame = double(v.read(frameNum));
tmp = frame; clear frame
frame = tmp(:,:,2);
imshow(uint8(frame))

% 나중에 시간이되면.. 선분이 아니라 ㄱ 자로 detection 하도록 바꿀수 있음

sw = 1; i = 330; ix = 0;
sw_col = 1; sw_row = 1;
while sw
    i = i + 1;
    ix = ix+1;
    visualization_col(ix) = mean(frame(330-150:330+150,i),1);
    visualization_row(ix) = mean(frame(i, 330-200:330+200),2);
    
    if visualization_col(ix) == 0 && sw_col;
        rightPosition = i-1; sw_col = 0;
    end
    
    if visualization_row(ix) == 0 && sw_row;
        downPosition = i-1; sw_row = 0;
    end
    
    if i > 1000; break; end;
end

sw = 1; i = 330;, ix = 0;
sw_col = 1; sw_row = 1;

while sw
    i = i - 1;
    ix = ix+1;
    visualization_left(ix) = mean(frame(330-150:330+150,i),1);
    visualization_up(ix) = std(frame(i, rightPosition-500:rightPosition),0);
    
    if visualization_left(ix) == 0 && sw_col;
        leftPosition = i+1; sw_col = 0;
    end
    
    if round(visualization_up(ix)) == 9 && sw_row;
        if mean(frame(i, rightPosition-500:rightPosition),2) > 200
            upPosition = i+1; sw_row = 0;
        end
    end
    
    if i == 1; break; end;
end

if ~exist('upPosition','var'); upPosition = downPosition-480; end

figure()
imshow(uint8(frame(upPosition:downPosition,leftPosition:rightPosition)))
disp([downPosition-upPosition rightPosition-leftPosition]);

%% 480 by 641이 아니면 쓰지 않음
% if downPosition-upPosition ~= 480 || rightPosition-leftPosition ~= 641
%     return
% end
%%

ms = VideoWriter(filename);
ms.FrameRate = v.FrameRate;
open(ms);

for frameNum = startFrame:endFrame
    frame = double(v.read(frameNum));
    writeVideo(ms, uint8(frame(upPosition:downPosition,leftPosition:rightPosition, 2)));
end

close(ms)
