a = input('input any number for start this code')
close all; clc; clear;
cnt = 0;
%%
cnt = cnt +1;

path_save{cnt,1} = uigetdir('','Select Directory of Your Experiment'); 

%%
cnt = cnt +1;
path_save{cnt,1} = 'E:\MSBak\Miniscope imaging data\Data\201711_2_data\GPF201711_2_Day1_#2.2'

aviFileList_save{cnt,1} = msCamVideoFileDetection(cell2mat(path_save(cnt,1)), 'msCam');

%%
for toDoList = 1:cnt
    disp(cell2mat(path_save(toDoList, 1)))
    timeName = datetimeGeneretor()
    
    path = cell2mat(path_save(toDoList, 1));
    aviFileList = aviFileList_save{toDoList, 1};
    msAlignment201808_Calc(aviFileList, path, timeName);
end