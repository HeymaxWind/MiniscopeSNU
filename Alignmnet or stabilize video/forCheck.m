function ForCheck = forCheck(ali_frame, cRow, cCol, bBox, wBox)

    ForCheck = ali_frame;
    
    ForCheck(cRow-19:cRow,cCol-9:cCol) = bBox;
    ForCheck(cRow-19:cRow,cCol+1:cCol+10) = wBox;
    
    ForCheck(cRow/2-19:cRow/2,cCol/2-9:cCol/2) = bBox;
    ForCheck(cRow/2-19:cRow/2,cCol/2+1:cCol/2+10) = wBox;
    
    ForCheck(cRow*1.5-19:cRow*1.5,cCol*1.5-9:cCol*1.5) = bBox;
    ForCheck(cRow*1.5-19:cRow*1.5,cCol*1.5+1:cCol*1.5+10) = wBox;
    
    ForCheck(cRow*1.5-19:cRow*1.5,cCol/2-9:cCol/2) = bBox;
    ForCheck(cRow*1.5-19:cRow*1.5,cCol/2+1:cCol/2+10) = wBox;
    
    ForCheck(cRow/2-19:cRow/2,cCol*1.5-9:cCol*1.5) = bBox;
    ForCheck(cRow/2-19:cRow/2,cCol*1.5+1:cCol*1.5+10) = wBox;
    
end
    