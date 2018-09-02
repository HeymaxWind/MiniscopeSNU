%% 20180318 SinalPositionMatrixGenerator by MSBak
% CNMF_E 이후, 필요한 data를 matrix 형태로 가공함

% msSignal : (neuron #, frame) = siganl raw value가 기록됨
% msSignal_cut : 낮은 df는 0으로 값을 바꿈 (계산용)
% 낮은 df의 기준 : 105% 이하
% msPeak_signal : 특정기준을 만족하면 signal peak에서 1로 표기함
% 특정기준 : 낮은 df 기준을 넘어서서 30frame 이상 지속되는 상태
% msPeak_num 은 detection된 neuron 별로 그 neuron이 '특정기준'을 몇 회 넘었는지, 즉 signal이 몇번 뛰었는지 기록함.

%% path 수동 입력
ForCheck = input('시작하려면 아무 숫자를 입력하세요 '); % 개발중에 실수로 시작하여 변수가 날아가는것을 방지하기 위한 체크 구문
clear; clc;

file_nm = []; dir_nm = [];
[file_nm, dir_nm] = uigetfile(fullfile(dir_nm, '*.tif;*.mat;*.h5;*.avi'));
filepath = [dir_nm, file_nm];

CNMF_List =  msCamVideoFileDetection(dir_nm  , 'CNMF_E', '.mat');

%% mat file load
load([dir_nm '\exclude_info.mat'])
for CNMF_Num = 1:size(CNMF_List,2)
    clearvars -except dir_nm file_nm filepath CNMF_List CNMF_Num exclude_info
    load(cell2mat(CNMF_List(1,CNMF_Num)));
    
%% msSignal 변수에 signal을 저장함.
clear msSignal

A = full(neuron.A);
C = neuron.C;
cnt = 0;
for neuronNum = 1:size(C, 1)
     try
        if isempty(find(exclude_info(CNMF_Num,:)==neuronNum))
            cnt = cnt + 1;
            msSignal(cnt, :) = double(C(neuronNum,:) * max(A(:,neuronNum)));
        end

     catch; end
end

%% df 105% 이하 컷
msSignal_cut = msSignal;
for sigNum = 1:size(msSignal, 1)
    for frame = 1:size(msSignal, 2)
        if msSignal(sigNum, frame) < 5
            msSignal_cut(sigNum, frame) = 0;
        end
    end
end

%% 특정기준에 만족하는 signal 유무 detection

% 미분
for sigNum = 1:size(msSignal, 1)
    for df = 1:size(msSignal, 2)-1
        dfSignal(sigNum, df) = msSignal_cut(sigNum, df+1) - msSignal_cut(sigNum, df);
    end
end

msPeak_signal = zeros(size(dfSignal, 1), size(dfSignal, 2));
for sigNum = 1:size(dfSignal, 1)
    temp_max = -inf;
    cnt = 0;
    for frame = 1:size(dfSignal, 2)
        if  temp_max < dfSignal(sigNum, frame)
            temp_max = dfSignal(sigNum, frame);
            cnt = 0;
            
        elseif temp_max >  dfSignal(sigNum, frame)
            cnt = cnt + 1;
            if cnt == 30 % 30 frame 동안 최대값을 유지하면 signal로 ㅇㅈ
                msPeak_signal(sigNum, frame-30) = 1;
                cnt = 0;
                temp_max = -inf;
            end
        end
            
        if frame == size(dfSignal, 2) && cnt > 0
            msPeak_signal(sigNum, frame-cnt) = 1;
        end
    end
end

%% msPeak_num 은 detection된 neuron 별로 그 neuron이 '특정기준'을 몇 회 넘었는지, 즉 signal이 몇번 뛰었는지 기록함.
clear msPeak_num
for sigNum = 1:size(msPeak_signal, 1)
    msPeak_num(sigNum, :) = sum(msPeak_signal(sigNum,:) == 1);
end


%% 2Dplotting - 1/0 detection
% msplot = msPeak_signal;
% 
% frame_axis = 1:size(msplot, 2);
% z_axis = 0;
% for sigNum = 1:size(msplot, 1)
%     z_axis = z_axis + 1;
%     plot(frame_axis, msplot(sigNum, :)+z_axis);
%     hold on;
% end
% 
% axis([-inf inf -inf inf 0 10]);

%% raster plot
% clear spikeTimes
% for sigNum = 1:size(msPeak_signal, 1)
%     clear ms_spikeTimes
%     idx = 0;
%     sw = 1; % signal이 없을 경우 공백의 ms_spikeTimes 만듬
%     for frame = 1:size(msPeak_signal, 2)
%         if msPeak_signal(sigNum, frame) == 1;
%             idx = idx+1;
%             ms_spikeTimes(idx) = frame;
%             sw = 0;
%         end
%     end
%     
%     if sw
%         ms_spikeTimes = NaN;
%     end
%     
%     spikeTimes{sigNum, 1} = ms_spikeTimes;
% end
%  
% plotSpikeRaster(spikeTimes,'PlotType','vertline','RelSpikeStartTime',0.01,'XLimForCell',[0 size(msPeak_signal, 2)]);
% ylabel('Neruons')
% xlabel('Time')
% title('GPF201711 Day1 #2.1 Alignment by MSbak code');
% set(gca,'XTick',[]);

%%
[project, miceID, day, start_idx] = msbak_project_miceID_extract_from_filepath(cell2mat(CNMF_List(1,CNMF_Num)));

savename = [dir_nm project '_' day '_SignalMatrix.mat'];
save(savename, 'msPeak_signal', 'msPeak_num', 'Coor', 'sizefix_info', 'savename', '-v7.3');


end



























