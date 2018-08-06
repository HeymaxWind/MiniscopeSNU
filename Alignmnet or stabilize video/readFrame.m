% frame(:,:,3) to movingSignal
function movingSignal = readFrame(msFrame, h, h2)

%     msFrame = double(tmpFrame(:,:,1)); % variable containing the video to analyze
    
    col_mean = mean(msFrame,1);
    offset = mean(col_mean, 2);
    
    for col = 1:size(msFrame,2)
         temp1(:, col) = (msFrame(:, col) / col_mean(1, col)) * offset;
    end
    
    row_mean = mean(temp1,2);
    offset = mean(row_mean, 1);
    
    for row = 1:size(temp1,1)
         dataFrame(row, :) = (temp1(row, :) / row_mean(row, 1)) * offset;
    end
    
    tmp1 =  filter2(h2,dataFrame) - filter2(h,dataFrame) - 1;
    movingSignal = tmp1 > 0.5;
    
end