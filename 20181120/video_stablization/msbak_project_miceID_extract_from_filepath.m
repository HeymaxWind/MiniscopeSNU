function [project, miceID, day, start_idx] = msbak_project_miceID_extract_from_filepath(path)

filepath = path;



%% find day
ay_idx = strfind(filepath, 'ay');
for i = ay_idx+2:size(filepath,2) % ay_idx : day 이후 +2 index에 숫자가 나오는것은 고정이므로, 이 때 부터 숫자를 샘
%     disp(filepath(i))
%     isempty(str2num(filepath(i)))
    if isempty(str2num(filepath(i)))
        day_end_idx = i;
        break
    end
end
day = filepath(ay_idx-1:day_end_idx-1);

%% find proejct

GPF_idx = strfind(filepath, 'GPF');
project = filepath(GPF_idx:ay_idx-3);

%% find miceID
shop_idx = strfind(filepath, '#');
shop_idx = shop_idx(size(shop_idx,2)); % # 이 여러개일때는, 마지막 것으로 추정

for i = shop_idx:size(filepath,2) % ay_idx : day 이후 +2 index에 숫자가 나오는것은 고정이므로, 이 때 부터 숫자를 샘
%     disp(filepath(i))
%     isempty(str2num(filepath(i)))
    if strcmp(filepath(i),'_')
        midID_end_idx = i;
        break
    end
end
miceID = filepath(shop_idx:midID_end_idx-1);

%% 용도를 까먹음 (20181120_MSBak)
start_idx = GPF_idx;

















