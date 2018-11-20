function aviFileList = msCamVideoFileDetection(path, filePrefix, extension)

aviFiles = dir([char(path) '\*' extension]); % 경로에 모든 avi file을 찾고

cnt1 = 0; 
for j = 1:length(aviFiles)
    if strfind([aviFiles(j).name], filePrefix)
%         aviFiles(j).name(1:length(filePrefix)) == filePrefix % 검색된 동영상 앞부분이 filePrefix에 해당하면
        cnt1 = cnt1 + 1; % 저장용 index
        avi_list{cnt1} = aviFiles(j).name; % avi_list 변수에 이름을 저장
    end
end

for i = 1:size(avi_list,2) % 동영상 번호 추출
    filePrefix = 'msCam';
    ms_avi_name = char(avi_list(i));
    ms_name_idx = strfind(ms_avi_name, '.');
    
    ms_avi_num(i) = str2double(ms_avi_name(size(filePrefix,2)+1:ms_name_idx(1)-1));
end

sw1 = 1;
while sw1
    sw1 = 0;
    for i = 1:size(ms_avi_num, 2)-1
        if ms_avi_num(i) > ms_avi_num(i+1)
            temp1 = ms_avi_num(i);
            ms_avi_num(i) = ms_avi_num(i+1);
            ms_avi_num(i+1) = temp1;
            sw1 = 1;
            
            temp2 = avi_list(i);
            avi_list(i) = avi_list(i+1);
            avi_list(i+1) = temp2;
        end
    end
end

for i = 1:size(avi_list,2)
    aviFileList{1,i} = [path cell2mat(avi_list(1,i))];
end

end