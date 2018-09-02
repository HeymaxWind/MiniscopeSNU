%% CNMF_E code
clear; clc
cd 'E:\MSBak\Miniscope imaging data\Code\201711_CNMF-E\CNMF-E_kwang\02. CNMF-E'
cnmfe_setup();
cnt = 0;
%%
cnt = cnt +1;

file_nm = []; dir_nm = [];
[file_nm, dir_nm] = uigetfile(fullfile(dir_nm, '*.mat'));
filepath = [dir_nm, file_nm];

path_save{cnt,1} = filepath;

%%
for cnt = 1:size(path_save,1)
    clearvars -except dir_nm file_nm filepath oasis_folder optimization_folder path_save save cnt
    filepath = cell2mat(path_save(cnt,1));
    load (filepath);
    cd 'E:\MSBak\Miniscope imaging data\Code\201711_CNMF-E\CNMF-E_kwang\02. CNMF-E\demos'

    nam = [];
    nam = filepath;
    demo_large_data_1p_kwang_auto()
end
 