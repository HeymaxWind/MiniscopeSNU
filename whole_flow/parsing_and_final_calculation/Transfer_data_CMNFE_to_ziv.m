ForCheck = input('시작하려면 아무 숫자를 입력하세요 '); 
% 개발중에 실수로 시작하여 변수가 날아가는것을 방지하기 위한 체크 구문
clc; clear
path = uigetdir('','Select Directory of Your Experiment'); 

%%
aviFiles = dir([path '\*CNMF_E.mat']); % 경로에 모든 mat file을 찾고

savepath = [path '\tracking\'];
 if (exist(savepath, 'dir') == 0)
    disp(['Made a result directory at :', newline, char(9), savepath]);
    mkdir(savepath);
 end

 %%
 load([path '\exclude_info.mat'])
for ix = 1:size(aviFiles,1)
    clearvars -except aviFiles ix path savepath exclude_info
    load([path '\'  aviFiles(ix).name])
    cnt = 0;
    for neuronNum = 1:size(neuron.A,2)
        try
            if isempty(find(exclude_info(ix,:)==neuronNum))
                cnt = cnt + 1;
                msMatrix = zeros(size(neuron.Cn,1)+200,size(neuron.Cn,2)+200);
                msMatrix(100:size(neuron.Cn,1)+99,100:size(neuron.Cn,2)+99,cnt) = reshape(full(neuron.A(:,neuronNum)), size(neuron.Cn,1), size(neuron.Cn,2));
                allFiltersMat(cnt,:,:) = msMatrix(:,:,cnt);
            end
        
        catch
%             cnt = cnt + 1;
%             msMatrix = zeros(size(neuron.Cn,1)+200,size(neuron.Cn,2)+200);
%             msMatrix(100:size(neuron.Cn,1)+99,100:size(neuron.Cn,2)+99,cnt) = reshape(full(neuron.A(:,cnt)), size(neuron.Cn,1), size(neuron.Cn,2));
%             allFiltersMat(cnt,:,:) = msMatrix(:,:,cnt);
        end
    end
    
    savename = [savepath 'spatial_footprints_0' num2str(ix) '.mat'];
    save(savename, 'allFiltersMat')
end

%% exclude info
if 0 
exclude_info = [];
%%
save([path '\exclude_info.mat'], 'exclude_info')
%%
end

%%
disp('done')















