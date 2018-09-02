function roatate_index = rotate_index_Generator(range)

%% generation of rotate_index
cnt = 0;
distance = -1;
roatate_index = [0 0];
while size(roatate_index,1) ~= (range*2+1)*(range*2+1)
    distance = distance+1;
    for i = -range:range
        for j = -range:range
            if (i^2 + j^2)^0.5 <= distance && (i^2 + j^2)^0.5 > distance-1
                cnt = cnt + 1;
                roatate_index(cnt,:) = [i j];
            end
        end
    end
end

end