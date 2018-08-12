function [project, miceID, day, start_idx] = msbak_project_miceID_extract_from_filepath(path)

filepath = path;

ay_idx = strfind(filepath, 'ay');

for i = 1:size(ay_idx,2)
    temp = filepath(ay_idx(i)+2);
    temp2 = filepath(ay_idx(i)-2) == '_';
    if  isnumeric(str2num(temp)) || temp2
        true_ay_idx = ay_idx(i);
    end
end

ub_idx = strfind(filepath, '_');
for i = 1:size(ub_idx,2)
    mstemp(i) = ub_idx(i) - true_ay_idx;
    mstemp2(i) = ub_idx(i) - true_ay_idx;
end

[z, min_idx_1] = min(abs(mstemp));
mstemp(min_idx_1) = inf();
[z, min_idx_2] = min(abs(mstemp));

project_idx_end = ub_idx(min_idx_1);
miceID_idx_start = ub_idx(min_idx_2);

day = filepath(project_idx_end+1:miceID_idx_start-1);

i = project_idx_end;
while 1
    i = i - 1;
    if filepath(i) == '\'
        project_idx_start = i;
        break
    end
    
    if i < 0
        break
    end
end

i = miceID_idx_start;
while 1
    i = i + 1;
    try
        if filepath(i) == '\'
            miceID_idx_end = i;
            break
        end
    catch
        miceID_idx_end = size(filepath,2)+1;
        break
    end
    
    if i > 1000
        break
    end
end

start_idx = project_idx_start;
project = filepath(project_idx_start+1:project_idx_end-1);
miceID = filepath(miceID_idx_start+1:miceID_idx_end-1);

















